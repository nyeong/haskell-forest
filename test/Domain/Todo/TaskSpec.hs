module Domain.Todo.TaskSpec where

import Data.Text (pack)
import Data.Time (getCurrentTime)
import Data.ULID (getULID)
import Domain.Todo.Task (mkTask)
import Test.Hspec

spec :: Spec
spec = do
  describe "mkTask" $ do
    it "Task를 생성할 수 있어야함" $ do
      let title = "할 일"
      taskId <- liftIO getULID
      now <- liftIO getCurrentTime
      mkTask taskId title now `shouldSatisfy` isJust

    it "제목이 12자를 넘을 수 없어야 함" $ do
      let title = toText $ replicate 12 'a'
      taskId <- liftIO getULID
      now <- liftIO getCurrentTime
      mkTask taskId title now `shouldSatisfy` isNothing
