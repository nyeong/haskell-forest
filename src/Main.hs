{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}

module Main where

import Database.PostgreSQL.Simple (Connection, query_)
import Domain.Todo.Task (Task (..))
import Domain.Todo.TaskRepo (TaskRepo (..))
import Domain.Todo.UseCase qualified as TaskUseCase
import Infra.PgDatabase.Connection (withConnection)
import Infra.PgDatabase.Task (insertTask)

newtype App a = App {unApp :: ReaderT Connection IO a}
  deriving stock (Functor)
  deriving newtype (Applicative, Monad, MonadIO, MonadReader Connection)

main :: IO ()
main = withConnection runApp
  where
    runApp db = do
      result <- runReaderT (unApp $ TaskUseCase.createTask "Hello") db
      (rows :: [Task]) <- query_ db "SELECT * FROM tasks"
      print rows
      print result
      pass

instance TaskRepo App where
  save :: Task -> App Bool
  save task = do
    conn <- ask
    liftIO $ insertTask conn task
