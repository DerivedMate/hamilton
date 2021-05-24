{-# LANGUAGE OverloadedStrings #-}


module Main where
import GHC.IO.Encoding (getLocaleEncoding)
import Main.Utf8 (withUtf8)
import System.IO
import Control.Monad
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified InputData as ID
import InputData (RawSong)

main :: IO ()
main = withUtf8 $ do
  inp <- BL.readFile "../lyrics.json" 
  songs <- pure $ decode inp :: IO (Maybe [RawSong])

  aux $ concatMap (map ID.speaker_line . ID.lines) <$> songs

  where 
    aux (Just xs) = mapM_ putStrLn xs
    aux Nothing   = print ""
