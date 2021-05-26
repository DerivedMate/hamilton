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
  deriving (Eq, Show)

data Alias
  = Both 
  deriving (Eq, Show)

data Lexeme
  = Part        String
  | Parenthesis Enclosing
  | Connector   Connector
  | Alias       Alias
  deriving (Eq, Show)

