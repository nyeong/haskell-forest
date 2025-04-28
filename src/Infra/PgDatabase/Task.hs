{-# OPTIONS_GHC -Wno-orphans #-}

module Infra.PgDatabase.Task (insertTask) where

import Data.ULID (ULID)
import Database.PostgreSQL.Simple (Connection, FromRow, ToRow, execute)
import Database.PostgreSQL.Simple.FromField (FromField (fromField))
import Database.PostgreSQL.Simple.ToField (ToField (toField))
import Domain.Todo.Task (Task)

instance ToRow Task

instance FromRow Task

instance ToField ULID where
  toField = toField . (show :: ULID -> String)

instance FromField ULID where
  fromField f mbs = fromMaybe (error "ULID parse error") . readMaybe <$> fromField f mbs

insertTask :: Connection -> Task -> IO Bool
insertTask conn task = do
  affectedCount <- execute conn "INSERT INTO tasks (id, content, completed, created_at, updated_at) VALUES (?, ?, ?, ?, ?)" task
  pure $ affectedCount == 1
