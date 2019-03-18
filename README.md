# password-store-extensions

A series of extensions for `password-store`.

* `pass l` - list entries.
  This command lists results one per line, instead of
  password-store's tree structure.
* `pass f <text>` - search for matching entries.
  This command lists results one per line, instead of
  password-store's tree structure.
* `pass i <path>` - insert a new entry.
  This command accepts a multiline entry, so it's equivalent
  to password-store's `pass insert --multiline pass-name`

## Attachments

These commands allow files to be included in a store.

The files are Base64 encoded.

* `pass attach insert <path> <file>` - add a file from the file system.
* `pass attach export <path> <file>` - export a file to the file system.

# Install

Copy the files from this repo under your password store in a
directory called `.extensions`.

Add the following to your shell configuration (`.bashrc`, `.zshrc`, etc):

```shell
export PASSWORD_STORE_ENABLE_EXTENSIONS=true
```
