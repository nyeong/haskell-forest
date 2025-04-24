module Domain.Todo.UseCase (createTask) where

import Control.Error.Util ((??))
import Control.Monad.Except (MonadError (throwError))
import Data.Time (getCurrentTime)
import Data.ULID (getULID)
import Domain.Todo.Task (Task, mkTask)
import Domain.Todo.TaskRepo (TaskRepo (..))
import Prelude hiding ((??))

createTask :: (MonadIO m, TaskRepo m) => Text -> m (Either Text Task)
createTask content = runExceptT $ do
  taskId <- liftIO getULID
  now <- liftIO getCurrentTime
  task <- mkTask taskId content now ?? "Task content must be less than 12 characters"
  result <- lift (save task)
  if result
    then pure task
    else throwError "Task save failed"
