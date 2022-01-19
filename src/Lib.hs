{-# LANGUAGE OverloadedStrings #-}

module Lib (defaultMain) where

import Control.Monad.State
import Data.Char (isAsciiLower, isAsciiUpper, toUpper)
import Data.Function (on)
import Data.Histogram (Histogram)
import qualified Data.Histogram as H
import Data.List (groupBy, nub)
import Data.Text (Text)
import qualified Data.Text.IO as T
import Data.Void (Void)
import qualified System.Environment as Env
import qualified System.Exit as Sys
import Text.Megaparsec hiding (State)
import Text.Megaparsec.Char
import Text.Megaparsec.Char.Lexer (decimal)
import Text.PrettyPrint.Boxes as Box hiding ((<>))

data Stats = Stats
  { _nrWords :: Int,
    _points :: Int,
    _nrPangrams :: Int,
    _histSingle :: Histogram (Char, Int),
    _histDouble :: Histogram (Char, Char)
  }
  deriving (Show)

untally :: Stats -> [String] -> Stats
untally = foldr f'
  where
    f' :: String -> Stats -> Stats
    f' word@(c1 : c2 : _) (Stats nw pts np hs hd) =
      let isPangram = length (nub word) == 7
          n = length word
          pts' = if n == 4 then 1 else n + if isPangram then 7 else 0
       in Stats (nw - 1) (pts - pts') (if isPangram then np - 1 else np) (H.decrement (c1, n) hs) (H.decrement (c1, c2) hd)
    f' _ _ = undefined

showStats :: Stats -> String
showStats (Stats nWords points nPangrams nSingles nPairs) =
  Box.render $ summary /+/ singles /+/ doubles
  where
    boxs :: Show a => a -> Box
    boxs = text . show
    summary = ("Remaining words:" // "Remaining points:" // "Remaining pangrams:") <+> (boxs nWords // boxs points // boxs nPangrams)
    singles = letterCol <+> table <+> sumCol
      where
        (letters, counts) = let (ls, cs) = unzip $ H.keys nSingles in (nub ls, nub cs)
        letterCol = " " // vcat left (fmap Box.char letters) // "Σ"
        table = hsep 1 top $ do
          count <- counts
          let rows = vcat left $ do
                letter <- letters
                let n = H.lookup (letter, count) nSingles
                pure $ if n == 0 then Box.char '-' else boxs n
              total = sum [H.lookup (l, count) nSingles | l <- letters]
          pure $ boxs count // rows // boxs total
        sumCol = "Σ" // vcat left [boxs (sum [H.lookup (letter, count) nSingles | count <- counts]) | letter <- letters] // boxs nWords
    doubles =
      let table = groupBy (on (==) (fst . fst)) (H.toList nPairs)
          entry ((c1, c2), n) = Box.text (c1 : c2 : '-' : show n)
       in vcat left $ fmap (hsep 1 top . fmap entry) table

defaultMain :: IO ()
defaultMain = do
  (hintsP, wordsP) <- do
    args <- Env.getArgs
    case args of
      [h, w] -> pure (h, w)
      _ -> Sys.die "usage: spelling-beetle <path to hint file> <path to word list>"
  txt <- T.readFile hintsP
  stats <- either (fail . errorBundlePretty) pure $ runParser parseStats hintsP txt
  ws <- words . fmap toUpper <$> readFile wordsP
  putStrLn $ showStats $ untally stats ws

type Parser = Parsec Void Text

parseStats :: Parser Stats
parseStats = do
  seek "WORDS:"
  nrWords <- next decimal
  seek "POINTS:"
  points <- next decimal
  seek "PANGRAMS:"
  pangrams <- next decimal
  nextLine
  space1
  countsHeader <- many (try $ decimal <* space)
  counts <- many . try $ do
    nextLine
    char <- ascii
    forM countsHeader $ \len -> do
      count <- next (decimal <|> (0 <$ single '-'))
      pure ((char, len), count)
  seek "Two letter list:"
  pairs <- many . try $ do
    c1 <- next ascii
    c2 <- ascii
    single '-'
    count <- decimal
    pure ((c1, c2), count)
  pure $ Stats nrWords points pangrams (H.fromCountList $ concat counts) (H.fromCountList pairs)
  where
    nextLine = void $ next eol
    ascii = satisfy isAsciiUpper <|> (toUpper <$> satisfy isAsciiLower)
    seek = void . next . chunk
    next = skipManyTill anySingle
