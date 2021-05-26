module Lexer where
import Data.Char
import Data.List
import Data.Maybe
import Debug.Trace
import Helpers

data Enclosing = Open 
               | Close 
               deriving (Eq, Show)

data Keyword = Except 
             | With 
             | And 
             | Both 
             deriving (Eq, Show)

data Token = Part String
           | Parenthesis Enclosing
           | Key Keyword
           | Comma
           | Amp
           | ComAmp
           | Slash
           | Semicolon 
           deriving (Eq, Show)

{----:
  Check if th given char can constitute a Part
:----}
isWordy :: Char -> Bool
isWordy c = c `elem` ['A'..'Z'] <> ['a'..'z'] <> ['0'..'9']

isPart :: Token -> Bool
isPart (Part _) = True
isPart _        = False

{----:
  Converts a lowercase string to a keyword
:----}
keywordOfString :: String -> Maybe Keyword
keywordOfString str = aux $ clean str
  where 
    clean :: String -> String
    clean s      = toLower <$> dropWhileEnd isSpace s
    aux :: String -> Maybe Keyword
    aux s        = lookup s dict
    dict         = [ ("except", Except)
                   , ("with"  , With)
                   , ("and"   , And)
                   , ("both"  , Both)
                   ]

{----:
  Converts char to tokens
:----}
tokenOfChar :: Char -> Token
tokenOfChar '(' = Parenthesis Open
tokenOfChar ')' = Parenthesis Close
tokenOfChar '&' = Amp
tokenOfChar '/' = Slash
tokenOfChar ':' = Semicolon
tokenOfChar ',' = Comma
tokenOfChar c
  | isWordy c = Part [c]
  -- Purposefully left to throw errors in debugging

{----:
  Removes redundant elements from tokens
:----}
cleanToken :: Token -> Token
cleanToken (Part p) = Part $ dropWhileEnd isSpace p
cleanToken t        = t

{----:
  Extracts string from Part
:----}
stringOfPart :: Token -> String
stringOfPart (Part p) = p
-- stringOfPart _ = ""

{----:
  Resolves the previous lexer state to a new one
  `prev, char, tokens -> prev', tokens'`
:----}
resolve :: Maybe Token -> Char -> [Token] -> (Maybe Token, [Token])
resolve (Just p@(Part pp)) ' ' tokens
  | Just k <- key
  , (not . null) remaining 
  = (key, Part remaining : tokens)
  | Just k <- key
  = (key, tokens)
  | otherwise     
  = (Just (Part (pp <> " ")), tokens)
  where
    parts        = words pp
    possible_key = last parts
    remaining    = unwords (init parts)
    key          = Key <$> keywordOfString possible_key
  
resolve p       ' ' tokens =     (p                     ,      tokens) -- skip spaces in non-part
resolve Nothing  c  tokens =     (Just (tokenOfChar c)  ,      tokens) -- add new token
resolve (Just p) c  tokens =    
    case (p, t) of
      (Part pp, Part tt)   ->    (Just (Part (pp <> tt)),      tokens) -- Expand part
      (Part pp, Semicolon) ->    (Nothing               ,      tokens) -- Skip labels
      (Part pp , _)        -> let 
                                t' = (Key 
                                      <$> keywordOfString 
                                      (toLower <$> pp)
                                     ) ?> p
                              in (Just t                , t' : tokens) -- end part
      (Comma, Amp)         ->    (Just ComAmp           ,      tokens) -- convert ,&
      _                    ->    (Just t                , p  : tokens) -- add new token
      
  where t = tokenOfChar c

{----:
  Converts, and simplifies input strings
  into lexical items, later to be parsed
:----}
lexer :: String -> [Token]
lexer (c:cs) = aux Nothing c cs []
  where
    aux :: Maybe Token -> Char -> String -> [Token] -> [Token]
    aux prev c "" tokens = map cleanToken $ reverse tokens''
      where 
        (prev', tokens') = resolve prev c tokens
        tokens''
          | Just (Part t) <- prev' 
          = (Key <$> keywordOfString t) ?> Part t : tokens'
          | Just t        <- prev' 
          = t : tokens'
          | Nothing       <- prev' 
          = tokens'

    aux prev c (c':cs) tokens = aux prev' c' cs tokens'
      where (prev', tokens') = resolve prev c tokens