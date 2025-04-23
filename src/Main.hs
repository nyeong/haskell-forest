{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Main where

import Control.Exception (bracket)
import Data.ULID (ULID)
import Database.PostgreSQL.Simple (ConnectInfo (..), Connection, FromRow, ResultError (ConversionFailed), ToRow, close, connect, execute, query_)
import Database.PostgreSQL.Simple.FromField (FromField (fromField), returnError)
import Database.PostgreSQL.Simple.ToField (ToField (toField))
import Domain.Todo.Task (Task (..))
import Domain.Todo.TaskRepo (TaskRepo (..))
import Domain.Todo.UseCase qualified as TaskUseCase

type Database = Connection

newtype App a = App {unApp :: ReaderT Database IO a}
  deriving stock (Functor)
  deriving newtype (Applicative, Monad, MonadIO, MonadReader Database)

instance ToRow Task

instance FromRow Task

instance ToField ULID where
  toField = toField . (show :: ULID -> String)

instance FromField ULID where
  fromField f mbs = do
    str <- fromField f mbs
    case readMaybe @ULID str of
      Nothing -> returnError ConversionFailed f "Could not parse ULID"
      Just ulid -> pure ulid

main :: IO ()
main = bracket connect' close runApp
  where
    connect' =
      connect
        ConnectInfo
          { connectHost = "localhost"
          , connectPort = 5432
          , connectDatabase = "todoapp"
          , connectUser = "postgres"
          , connectPassword = "postgres"
          }
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
    affectedCount <- liftIO $ execute conn "INSERT INTO tasks (id, content, completed, created_at, updated_at) VALUES (?, ?, ?, ?, ?)" task
    pure $ affectedCount == 1
