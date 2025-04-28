module Main where

import Database.PostgreSQL.Simple (Connection)
import Domain.Todo.TaskRepo
import Domain.Todo.UseCase qualified as TaskUseCase
import Infra.PgDatabase.Connection (withConnection)
import Infra.PgDatabase.Task qualified as PgTask
import Network.Wai (Response)
import UnliftIO (MonadUnliftIO)
import Web.Scotty.Trans (html, json, post, scottyT)
import Prelude hiding (get)

newtype App a = App {unApp :: ReaderT Connection IO a}
  deriving stock (Functor)
  deriving newtype (Applicative, Monad, MonadIO, MonadReader Connection, MonadUnliftIO)

instance TaskRepo App where
  save task = do
    conn <- ask
    liftIO $ PgTask.insertTask conn task

runner :: Connection -> App Response -> IO Response
runner conn app = runReaderT (unApp app) conn

main :: IO ()
main = do
  withConnection $ \conn ->
    scottyT 3000 (runner conn) $ do
      post "/tasks" $ do
        result <- lift $ TaskUseCase.createTask "Hello"
        case result of
          Left err -> json err
          Right task -> json task
