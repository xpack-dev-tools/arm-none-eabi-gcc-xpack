# Developer info

To access the ARM branch in the upstream repo:

```sh
git remote add upstream git://gcc.gnu.org/git/gcc.git
git config --add remote.upstream.fetch "+refs/vendors/ARM/heads/*:refs/remotes/upstream/ARM/*"
git fetch upstream
```
