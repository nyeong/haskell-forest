{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Lib (
  main,
)
where

import Database.PostgreSQL.Simple (Connection)
import Domain.Todo.TaskRepo (TaskRepo (..))
import Domain.Todo.UseCase qualified as TaskUseCase
import Infra.PgDatabase.Connection (withConnection)
import Infra.PgDatabase.Task qualified as PgTask

newtype App a = App {unApp :: ReaderT Connection IO a}
  deriving (Functor, Applicative, Monad, MonadIO, MonadReader Connection)

instance TaskRepo App where
  save task = do
    conn <- ask
    liftIO $ PgTask.insertTask conn task

main :: IO ()
main = do
  withConnection $ \conn -> do
    result <- runReaderT (unApp $ TaskUseCase.createTask "Hello") conn
    print result
