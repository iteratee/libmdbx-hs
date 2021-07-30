{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Control.Exception (bracket)
import Data.Store
import Data.String.Interpolate (i)
import Data.Text (Text)
import GHC.Generics

import Mdbx
import Mdbx.Store

data User = User {
  _username :: Text,
  _password :: Text
} deriving (Eq, Show, Generic, Store)

deriving via (MdbxItemStore User) instance MdbxItem User

openEnvDbi :: IO MdbxEnv
openEnvDbi = envOpen "./testdb" [MdbxNosubdir, MdbxCoalesce, MdbxLiforeclaim]

userKey :: User -> Text
userKey user = [i|user-#{_username user}|]

main :: IO ()
main = bracket openEnvDbi envClose $ \env -> do
  dbi <- dbiOpen env Nothing []

  putItems env dbi pairs

  getItems env dbi keys1 >>= print @[User]
  getItems env dbi keys2 >>= print @[User]
  getItems env dbi (_username <$> users) >>= print @[User]

  getRange env dbi range1 range2 >>= mapM_ (print @User)

  where
    keys1 = ["mark", "dale"] :: [Text]
    keys2 = ["john", "carl"] :: [Text]

    range1 = "user-user-327" :: Text
    range2 = "user-user-999" :: Text

    pairs = (\u -> (userKey u, u)) <$> users
    users = [
      User "mark" "hide",
      User "john" "test",
      User "ernest" "password",
      User "dale" "done",
      User "carl" "past",
      User "user-001" "test",
      User "user-101" "test",
      User "user-950" "test",
      User "user-327" "test",
      User "user-425" "test",
      User "user-897" "test"
      ]
