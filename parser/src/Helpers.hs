module Helpers where
import Data.List
import Debug.Trace

maybeOr :: Maybe a -> a -> a
maybeOr (Just a) _ = a
maybeOr Nothing a  = a

(?>) = maybeOr

traceS :: Show a => [(String, a)] -> g -> g
traceS xs = trace (intercalate "\n\n" [ l <> " " <> show e | (l, e) <- xs ])