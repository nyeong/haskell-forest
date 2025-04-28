module Infra.Web.Error (Error (..)) where

import Data.Aeson

newtype Error = Error
  { error :: Text
  }
  deriving stock (Show, Generic)

instance ToJSON Error
