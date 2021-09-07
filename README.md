# libmdbx-hs

A [libmdbx](https://github.com/erthink/libmdbx) wrapper, providing low level
access to its API plus a set of high level functions for common operations.

Excerpt from libmdbx's [documentation](https://github.com/erthink/libmdbx):

_**libmdbx** is an extremely fast, compact, powerful, embedded,
transactional [key-value database](https://en.wikipedia.org/wiki/Key-value_database),
with permissive license._

_Historically, **libmdbx** is a deeply revised and extended descendant of the amazing
[Lightning Memory-Mapped Database](https://en.wikipedia.org/wiki/Lightning_Memory-Mapped_Database).
**libmdbx** inherits all benefits from _LMDB_, but resolves some issues and adds a set of improvements._

## Usage

### Low level interface

Using libmdbx's low level interface involves the following steps:

- Opening an environment. This is the equivalent of a database.
- Opening a database. This is the equivalent of a table.
- Creating a transaction.
- Performing CRUD operations, or using a cursor.
- Committing or aborting the transaction.

See [Hackage](https://hackage.haskell.org/package/libmdbx-hs/Mdbx-API.html) for
the low level interface or [libmdbx's](https://erthink.github.io/libmdbx)
documentation for more details on internals.

### High level interface

Alternatively you can use the high level interface which, although providing
a limited set of operations, takes care of transaction handling and makes the
common use cases really simple.

```haskell
data User = User {
  _username :: !Text,
  _password :: !Text
} deriving (Eq, Show, Generic, Store)

deriving via (MdbxItemStore User) instance MdbxItem User

openEnvDbi :: IO MdbxEnv
openEnvDbi = envOpen "./test.db" def [MdbxNosubdir, MdbxCoalesce, MdbxLiforeclaim]

userKey :: User -> Text
userKey user = "user-" <> _username user

main :: IO ()
main = bracket openEnvDbi envClose $ \env -> do
  db <- dbiOpen env Nothing []

  putItem env db (userKey user1) user1
  putItem env db (userKey user2) user2

  getItem env db (userKey user2) >>= print @(Maybe User)
  getRange env db (userKey user1) (userKey user2) >>= print @[User]
  where
    user1 = User "john" "secret"
    user2 = User "mark" "password"
```

For the high level interface see [Hackage](https://hackage.haskell.org/package/libmdbx-hs/Mdbx-Database.html)
or the sample application [here](app/Main.hs).

### Common

In both scenarios, you will want to check [Hackage](https://hackage.haskell.org/package/libmdbx-hs/Mdbx-Types.html)
for information on how to make your data types compatible with libmdbx-hs.

It is recommended that your serializable data types have strict fields, to avoid
issues related to lazy IO. The library loads data from pointers that are valid
only during a transaction; delaying the operation may cause an invalid read and
consequently a crash.

Write operations should always be performed from the same OS thread.

## Dependencies

Source code for libmdbx is included in the repository and built with the rest of
the project, to avoid requiring a separate library install.

## License

libmdbx is licensed under the [The OpenLDAP Public License](https://github.com/erthink/libmdbx/blob/master/LICENSE).

libmdbx-hs is licensed under the [BSD-3 License](LICENSE).
