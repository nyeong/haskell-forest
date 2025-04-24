module Infra.PgDatabase.Connection (withConnection) where

import Control.Exception (bracket)
import Database.PostgreSQL.Simple

withConnection :: (Connection -> IO ()) -> IO ()
withConnection = bracket connect' close
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
