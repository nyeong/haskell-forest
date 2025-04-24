{-# OPTIONS_GHC -Wno-orphans #-}

module Infra.PgDatabase.Task (insertTask) where

import Data.ULID (ULID)
import Database.PostgreSQL.Simple (Connection, FromRow, ResultError (ConversionFailed), ToRow, execute)
import Database.PostgreSQL.Simple.FromField (FromField (fromField), returnError)
import Database.PostgreSQL.Simple.ToField (ToField (toField))
import Domain.Todo.Task (Task)

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

insertTask :: Connection -> Task -> IO Bool
insertTask conn task = do
  affectedCount <- execute conn "INSERT INTO tasks (id, content, completed, created_at, updated_at) VALUES (?, ?, ?, ?, ?)" task
  pure $ affectedCount == 1
