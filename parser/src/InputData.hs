{-# LANGUAGE OverloadedStrings #-}


module InputData where
import Data.Aeson
import Data.Text.Lazy (Text)

data RawLine = 
  RawLine { speaker_line :: String
          , text         :: [Text]
          } deriving Show

instance FromJSON RawLine where
  parseJSON = withObject "RawLine" dec
    where 
      dec v = RawLine 
              <$> v .: "speaker_line"
              <*> v .: "text"

data RawSong = 
  RawSong { title  :: String
          , lines  :: [RawLine]
          , origin :: String
          , i      :: Int
          } deriving Show

instance FromJSON RawSong where
  parseJSON = withObject "RawSong" dec
    where 
      dec v = RawSong
              <$> v .: "title"
              <*> v .: "lines"
              <*> v .: "origin"
              <*> v .: "i"