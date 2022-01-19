import Test.Hspec

main :: IO ()
main =
  hspec $
    describe "spelling-beetle-test" $
      it "works" $
        2 + 2 `shouldBe` (4 :: Int)
