{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeApplications #-}

module Mdbx.DatabaseSpec where

import Data.Default
import Data.Int
import Data.Store
import Data.Text (Text)
import GHC.Generics
import Test.Hspec

import Mdbx
import TestUtil

data TestKey = TestKey {
  keyCategory :: NullByteString,
  keyGroup :: Int16,
  keyTs :: Int
} deriving (Eq, Show, Generic, Store)

deriving via (MdbxItemStore TestKey) instance MdbxItem TestKey

spec :: Spec
spec = around withDatabase $
  describe "Database" $ do
    it "should insert and retrieve text keys" $ \(env, db) -> do
      let key k = k :: Text
      let val v = v :: Text

      putItem env db (key "Key 1") (val "Value 1")
      putItem env db (key "Key 22") (val "Value 2")
      putItem env db (key "Key 3") (val "Value 3")
      putItem env db (key "Key 4") (val "Value 4")
      putItem env db (key "Key 5") (val "Value 5")
      getItem env db (key "Key 1") `shouldReturn` Just (val "Value 1")
      getItem env db (key "Key 22") `shouldReturn` Just (val "Value 2")
      getRange env db (key "Key 22") (key "Key 4") `shouldReturn` [val "Value 2", val "Value 3", val "Value 4"]

    it "should insert and retrieve individual items" $ \(env, db) -> do
      let key ts = TestKey "Test" 1 ts

      putItem env db (key 1) ("Value 1" :: Text)
      putItem env db (key 2) ("Value 2" :: Text)
      putItem env db (key 3) ("Value 3" :: Text)

      getItem env db (key 1) `shouldReturn` Just @Text "Value 1"
      getItem env db (key 2) `shouldReturn` Just @Text "Value 2"
      getItem env db (key 3) `shouldReturn` Just @Text "Value 3"

    it "should insert and retrieve a list of items" $ \(env, db) -> do
      let key ts = TestKey "Test" 1 ts

      putItem env db (key 1) ("Value 1" :: Text)
      putItem env db (key 2) ("Value 2" :: Text)
      putItem env db (key 3) ("Value 3" :: Text)

      getItems env db [key 1] `shouldReturn` (["Value 1"] :: [Text])
      getItems env db [key 1, key 2] `shouldReturn` (["Value 1", "Value 2"] :: [Text])
      getItems env db [key 2, key 3] `shouldReturn` (["Value 2", "Value 3"] :: [Text])
      getItems env db [key 1, key 2, key 3] `shouldReturn` (["Value 1", "Value 2", "Value 3"] :: [Text])

    it "should insert and retrieve a range of items using all fields" $ \(env, db) -> do
      let keyA gr ts = TestKey "Category A" gr ts
      let keyB gr ts = TestKey "Category AB" gr ts
      let keyC gr ts = TestKey "Категория с" gr ts

      putItem env db (keyA 1 1) ("Value A 1 1" :: Text)
      putItem env db (keyA 1 2) ("Value A 1 2" :: Text)
      putItem env db (keyA 1 3) ("Value A 1 3" :: Text)

      putItem env db (keyA 2 1) ("Value A 2 1" :: Text)
      putItem env db (keyA 2 2) ("Value A 2 2" :: Text)
      putItem env db (keyA 2 3) ("Value A 2 3" :: Text)

      putItem env db (keyB 1 1) ("Value B 1 1" :: Text)
      putItem env db (keyB 1 2) ("Value B 1 2" :: Text)
      putItem env db (keyB 1 3) ("Value B 1 3" :: Text)

      putItem env db (keyC 1 1) ("Value C 1 1" :: Text)
      putItem env db (keyC 1 2) ("Value C 1 2" :: Text)
      putItem env db (keyC 1 3) ("Value C 1 3" :: Text)

      getRange env db (keyA 1 3) (keyA 1 1) `shouldReturn` ([] :: [Text])
      getRange env db (keyA 1 1) (keyA 1 3) `shouldReturn` (["Value A 1 1", "Value A 1 2", "Value A 1 3"] :: [Text])
      getRange env db (keyA 2 1) (keyA 2 3) `shouldReturn` (["Value A 2 1", "Value A 2 2", "Value A 2 3"] :: [Text])

      getRange env db (keyB 1 1) (keyB 1 3) `shouldReturn` (["Value B 1 1", "Value B 1 2", "Value B 1 3"] :: [Text])
      getRange env db (keyC 1 1) (keyC 1 3) `shouldReturn` (["Value C 1 1", "Value C 1 2", "Value C 1 3"] :: [Text])

      getRange env db (keyA 2 3) (keyB 1 2) `shouldReturn` (["Value A 2 3", "Value B 1 1", "Value B 1 2"] :: [Text])
