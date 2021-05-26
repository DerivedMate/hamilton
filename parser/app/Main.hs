{-# LANGUAGE OverloadedStrings #-}


module Main where
import GHC.IO.Encoding (getLocaleEncoding)
import Main.Utf8 (withUtf8)
import System.IO
import Control.Monad
import Data.List
import Data.Aeson
import Data.Aeson.Encode.Pretty
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified InputData as ID
import InputData (RawSong)
import Helpers
import LexerV2

data LexerTest = 
  LexerTest {
    input  :: String,
    output :: [String]
  }

instance ToJSON LexerTest where
  toJSON (LexerTest input output) =
    object [ "input"  .= input
           , "output" .= output
           ]
  
  toEncoding (LexerTest input output) =
    pairs ( "input"  .= input 
         <> "output" .= output
          )


main :: IO ()
main = withUtf8 $ do
  inp   <- BL.readFile "../lyrics.json" 
  songs <- pure $ maybeOr (decode inp) [] :: IO [RawSong]

  BL.writeFile "./out.json" 
    $ encodePretty 
    $ map aux 
    $ nub 
    $ concatMap (map ID.speaker_line . ID.lines) songs

  where aux s = LexerTest s (show <$> lexer s)
