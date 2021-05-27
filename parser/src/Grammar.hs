{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}


module Grammar where
import Data.Aeson
import Data.List
import Data.Char
import GHC.Generics

data Enclosing 
  = Open 
  | Close 
  deriving (Eq, Show)

data Connector
  = Comma
  | Amp
  | ComAmp
  | Slash
  | Semicolon
  | Except 
  | With 
  | And 
  | Manner
  deriving (Eq, Show)

data Lexeme
  = Part        String
  | Parenthesis Enclosing
  | Connector   Connector
  | Alias       String
  | EOI
  deriving (Eq, Show)

data Operator 
  = Operator { name   :: Connector
             , weight :: Int
             }
  deriving (Show)

instance Eq Operator where
  (==) a b = weight a == weight b

instance Ord Operator where
  compare a b = 
    weight a `compare` weight b

instance ToJSON Operator where
  toJSON op = 
    object [ "name"   .= show (name op)
           , "weight" .= weight op
           ]
  toEncoding op = 
    pairs  ( "name"   .= show (name op)
          <> "weight" .= weight op
           )

operatorOfLexeme :: Lexeme -> Maybe Operator
operatorOfLexeme (Connector c)
  = Operator c <$> lookup c dict
  where 
    dict  = [ Semicolon
            , ComAmp
            , Comma
            , Manner
            , Except 
            , With 
            , Amp
            , And  
            , Slash
            ] `zip` [0..]
operatorOfLexeme _ = Nothing

isManner :: Operator -> Bool
isManner p = name p == Manner
  

data Mode 
  = MSpeaker 
  | MAlias 
  deriving (Show, Eq, Generic)

instance ToJSON Mode where
  toEncoding = genericToEncoding defaultOptions
