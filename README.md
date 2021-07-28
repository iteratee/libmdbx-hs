# libmdbx-hs

A [libmdbx](https://github.com/erthink/libmdbx) wrapper, providing low level
access to its API plus a set of high level functions for common operations.

Excerpt from libmdbx's [documentation](https://github.com/erthink/libmdbx):

_**libmdbx** is an extremely fast, compact, powerful, embedded,
transactional [key-value database](https://en.wikipedia.org/wiki/Key-value_database),
with [permissive license](./LICENSE)._

_Historically, **libmdbx** is a deeply revised and extended descendant of the amazing
[Lightning Memory-Mapped Database](https://en.wikipedia.org/wiki/Lightning_Memory-Mapped_Database).
**libmdbx** inherits all benefits from _LMDB_, but resolves some issues and adds [a set of improvements](#improvements-beyond-lmdb)._

## Usage

### Low level interface

Using libmdbx low level interface involves the following steps:

- Opening an environment. This is the equivalent of a database.
- Opening a database. This is the equivalent of a table.
- Creating a transaction.
- Performing CRUD operations/using a cursor.
- Committing or aborting the transaction.

You can check [Hackage](https://hackage.haskell.org/package/libmdbx-hs/Mdbx-API.html)
for the low level interface or [libmdbx](https://erthink.github.io/libmdbx)
documentation for more details on internals.

### High level interface

Alternatively you can use the higher level interface which, although it provides
a more limited set of operations, takes care of transaction handling and makes
the common use cases really simple.

For the high level interface check [Hackage](https://hackage.haskell.org/package/libmdbx-hs/Mdbx-Database.html)
or the sample application [here](app/Main.hs).

### Common

In both scenarios, you will want to check [Hackage](https://hackage.haskell.org/package/libmdbx-hs/Mdbx-Types.html)
for information on how to make your data types compatible with libmdbx-hs.

## Dependencies

Source code for libmdbx is included in the repository and built with the rest of
the project, to avoid requiring a separate library install.

## License

libmdbx is licensed under the [The OpenLDAP Public License](https://github.com/erthink/libmdbx/blob/master/LICENSE).

libmdbx-hs is licensed under the [BSD-3 License](LICENSE).
