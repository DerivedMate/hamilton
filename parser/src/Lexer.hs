module Lexer where
import Data.Char
import Data.List
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
    aux "except" = Just Except
    aux "with"   = Just With
    aux "and"    = Just And
    aux "both"   = Just Both
    aux _        = Nothing


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

cleanToken :: Token -> Token
cleanToken (Part p) = Part $ dropWhileEnd isSpace p
cleanToken t = t

stringOfPart :: Token -> String
stringOfPart (Part p) = p
-- stringOfPart _ = ""

resolve :: Maybe Token -> Char -> [Token] -> (Maybe Token, [Token])
resolve (Just p@(Part pp)) ' ' tokens = (Just (last splitTokens), init splitTokens <> tokens)
    where
      groupParts (Part _) (Part _) = True
      groupParts _ _               = False
      recombineParts ts
        | any isPart ts = [foldl aux (Part "") ts]
        | otherwise     = ts
        where aux (Part a) (Part b) = Part (a <> b <> " ")
      splitTokens = concatMap recombineParts 
                  $ groupBy groupParts 
                    (aux <$> words pp)

      aux :: String -> Token
      aux s = case keywordOfString s of
        Nothing -> Part s
        Just k  -> Key k

resolve p ' ' tokens                  = (p, tokens)

resolve Nothing c tokens = (Just t, tokens)
    where t = tokenOfChar c

resolve (Just p) c tokens = 
    case (p, t) of
      (Part pp, Part tt)   -> (Just $ Part (pp <> tt), tokens) -- Join parts
      (Part pp, Semicolon) -> (Nothing, tokens)                -- Skip labels
      (Part pp , _)        -> (Just t, maybeOr (Key <$> keywordOfString (toLower <$> pp)) p : tokens)
      (_, Part _)          -> (Just t, p : tokens)
      (Comma, Amp)         -> (Just ComAmp, tokens)
      _                    -> (Just t, p : tokens)
      
  where t = tokenOfChar c

lexer :: String -> [Token]
lexer (c:cs) = aux Nothing c cs []
  where
    aux :: Maybe Token -> Char -> String -> [Token] -> [Token]
    aux prev c "" tokens = map cleanToken $ reverse tokens''
      where 
        (prev', tokens') = resolve prev c tokens
        tokens''         = case prev' of
                            Just (Part t) -> 
                                let t' = case keywordOfString t of
                                          Just k -> Key k
                                          Nothing -> Part t
                                in t' : tokens'
                            Just t        -> t : tokens'
                            Nothing       -> tokens'

    aux prev c (c':cs) tokens = aux prev' c' cs tokens'
      where (prev', tokens') = resolve prev c tokens