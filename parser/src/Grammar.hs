module Grammar where

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
  | Both 
  deriving (Eq, Show)

data Lexeme
  = Part        String
  | Parenthesis Enclosing
  | Connector   Connector
  deriving (Eq, Show)