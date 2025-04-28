module HelloSpec where

import Test.Hspec

spec :: Spec
spec = do
  describe "(+) 함수" $ do
    it "1 + 1 = 2" $ do
      (1 + 1) `shouldBe` (3 :: Int)
