module Helpers where

maybeOr :: Maybe a -> a -> a
maybeOr (Just a) _ = a
maybeOr Nothing a  = a