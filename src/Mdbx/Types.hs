{-|
Module      : Mdbx.Types
Copyright   : (c) 2021 Francisco Vallarino
License     : BSD-3-Clause (see the LICENSE file)
Maintainer  : fjvallarino@gmail.com
Stability   : experimental
Portability : non-portable

Types used by the library. Mainly re exports the types generated by c2hs in the
FFI module, while also adding some types used by the high level interface.
-}
module Mdbx.Types (
  -- * Re-exported from FFI
  MdbxEnv,
  MdbxTxn,
  MdbxDbi,
  MdbxVal(..),
  MdbxEnvMode(..),
  MdbxEnvFlags(..),
  MdbxTxnFlags(..),
  MdbxDbFlags(..),
  MdbxPutFlags(..),
  MdbxCursorOp(..),
  -- * High level interface
  MdbxItem(..)
) where

import Data.Text (Text)
import Data.Text.Foreign (fromPtr, useAsPtr)
import Foreign.Ptr (castPtr)

import Mdbx.FFI

{-|
Converts an instance to/from the representation needed by libmdbx. This type is
used for both keys and values.

Only the 'Text' instance is provided, since it is commonly used as the key when
storing/retrieving a value.

For your own types, in general, you will want to use a serialization library
such as <https://hackage.haskell.org/package/store store>,
<https://hackage.haskell.org/package/cereal cereal>, etc, and apply the newtype
deriving via trick.

The 'Data.Store.Store' instance can be defined as:

@
newtype MdbxItemStore a = MdbxItemStore {
  unwrapStore :: a
}

instance Store a => MdbxItem (MdbxItemStore a) where
  fromMdbxVal item = MdbxItemStore <$> fromMdbxStore item
  toMdbxVal item = withMdbxStore (unwrapStore item)

fromMdbxStore :: Store v => MdbxVal -> IO v
fromMdbxStore (MdbxVal size ptr) = do
  bs <- unsafePackCStringLen (castPtr ptr, fromIntegral size)
  decodeIO bs

withMdbxStore :: Store v => v -> (MdbxVal -> IO a) -> IO a
withMdbxStore val fn =
  unsafeUseAsCStringLen bsV $ \(ptrV, sizeV) -> do
    let mval = MdbxVal (fromIntegral sizeV) (castPtr ptrV)
    fn mval
  where
    bsV = encode val
@

This code can be adaptad to other serialization libraries. It is not provided as
part of libmdbx-hs itself to avoid forcing dependencies.

Then, to derive the instance for your owwn type:

@
data User = User {
  _username :: Text,
  _password :: Text
} deriving (Eq, Show, Generic, Store)

deriving via (MdbxItemStore User) instance MdbxItem User
@

Note: if you plan on using a custom type as the key, be careful if it contains
'Text' or 'Data.ByteString.ByteString' instances, since these types have a
length field which is, in general, before the data. This causes issues when
using cursors, since they depend on key ordering and the length field will make
shorter instances lower than longer ones, even if the content indicates the
opposite. In general, it is simpler to use 'Text' as the key.
-}
class MdbxItem i where
  {-|
  Converts a block of memory provided by libmdbx to a user data type. There are
  no guarantees provided by the library that the block of memory matches the
  expected type, and a crash can happen if not careful.
  -}
  fromMdbxVal :: MdbxVal -> IO i
  {-
  Converts a user data type to a block of memory.
  -}
  toMdbxVal :: i -> (MdbxVal -> IO b) -> IO b

instance MdbxItem Text where
  fromMdbxVal (MdbxVal sz ptr) =
    fromPtr (castPtr ptr) (fromIntegral sz `div` 2)

  toMdbxVal val fn = useAsPtr val $ \ptr size ->
    fn $ MdbxVal (fromIntegral size * 2) (castPtr ptr)
