{-# LANGUAGE DeriveGeneric #-}


module Song where
import Prelude hiding (lines)
import GHC.Generics
import Data.Aeson
import qualified Data.Text.Lazy as T
import Parser
import Lexer
import qualified InputData as ID

data Line
  = Line { speakers :: AST'
         , text     :: [String]
         } deriving (Eq, Show, Generic)

instance ToJSON Line where
  toEncoding = genericToEncoding defaultOptions

data Song = 
  Song { title  :: String
       , lyrics :: [Line]
       , origin :: String
       , i      :: Int
       } deriving (Eq, Show, Generic)

instance ToJSON Song where
  toEncoding = genericToEncoding defaultOptions

songOfRaw :: ID.RawSong -> Song
songOfRaw s = 
  Song { title  = ID.title s
       , lyrics = map aux (ID.lines s)
       , origin = ID.origin s
       , i      = ID.i s
       }
  where 
    aux l = 
      Line { speakers = (fst . parse . lexer . ID.speaker_line) l
           , text     = T.unpack <$> ID.text l
           }