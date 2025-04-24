{-# OPTIONS_GHC -Wno-orphans #-}

module Domain.Todo.Task (
  mkTask,
  Task (..),
)
where

import Data.Aeson (ToJSON (..), Value (..))
import Data.Text (length)
import Data.Time (UTCTime)
import Data.ULID (ULID)
import Prelude hiding (id, length)

data Task where
  Task ::
    { id :: ULID
    , content :: Text
    , completed :: Bool
    , createdAt :: UTCTime
    , updatedAt :: Maybe UTCTime
    } ->
    Task
  deriving stock (Show, Generic)

instance ToJSON ULID where
  toJSON = String . show

instance ToJSON Task

mkTask :: ULID -> Text -> UTCTime -> Maybe Task
mkTask taskId content createdAt =
  if length content > 12
    then Nothing
    else
      Just $
        Task
          { id = taskId
          , content = content
          , completed = False
          , createdAt = createdAt
          , updatedAt = Nothing
          }
