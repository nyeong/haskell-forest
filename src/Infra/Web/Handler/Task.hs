module Infra.Web.Handler.Task where

import Data.Aeson (FromJSON)
import Domain.Todo.TaskRepo (TaskRepo)
import Domain.Todo.UseCase qualified as TaskUseCase
import Infra.Web.Error (Error (..))
import Network.HTTP.Types (status400)
import Web.Scotty.Trans (ActionT, json, jsonData, status)

newtype CreateTaskInput = CreateTaskInput
  {content :: Text}
  deriving stock (Show, Generic)

instance FromJSON CreateTaskInput

createTask :: (MonadIO m, TaskRepo m) => ActionT m ()
createTask = do
  input <- jsonData
  result <- lift $ TaskUseCase.createTask (content input)
  case result of
    Left msg -> do
      status status400
      json $ Error msg
    Right task -> json task
