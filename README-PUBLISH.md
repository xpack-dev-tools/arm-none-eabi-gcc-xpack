# How to publish the xPack GNU Arm Embedded GCC binaries

## Build

Before starting the build, perform some checks.

### Check possible open issues

Check GitHub [issues](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/issues)
and fix them; do not close them yet.

### Check the `CHANGELOG.md` file

Open the `CHANGELOG.txt` file and check if
all new entries are in.

Note: if you missed to update the `CHANGELOG.md` before starting the build,
edit the file and rerun the build, it should take only a few minutes to
recreate the archives with the correct file.

### Check the version

The `VERSION` file should refer to the actual release.

### Push the build scripts

In this Git repo:

- if necessary, merge the `xpack-develop` branch into `xpack`.
- push it to GitHub.
- possibly push the helper project too.

### Run the build scripts

When everything is ready, follow the instructions from the
[build](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README-BUILD.md)
page.

## Test

Install the binaries on all supported platforms and check if they are
functional.

For this, on each platform (Mac, GNU/Linux 64/32, Windows 64/32):

- unpack the archive in `Desktop` or in `Downloads`, and rename the version
  folder, by replacing a dash with a space; this will test paths with spaces;
  on Windows the current paths always use spaces, so renaming is not needed;
- clone this repo locally; on Windows use the Git console;

```console
$ git clone --recurse-submodules https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git \
  ~/Downloads/arm-none-eabi-gcc-xpack.git
```

- in a separate workspace, Import → General → Existing Projects into Workspace
  the Eclipse projects available in the
  `tests/eclipse` folder of the build repo; more details in the
  [README.md](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/tests/eclipse/README.md)
- define the **Workspace Arm Toolchain path** to use the `Downloads`
  temporary location
- to test the compiler: for all projects (start with `arm-f4b-fs-lib`)
  - remove all build folders, or **Clean all**
  - build all configs, with the hammer, not with **Build all**, to be sure
    errors are not missed
- to test the debugger: for all QEMU debug configurations (start with
  `arm-f4b-fs-debug-lto-qemu`)
  - start the QEMU debug session,
  - single step a few lines (Step Over)
  - start continuous run (Resume)
  - halt (Suspend)
  - start (Resume)
  - stop (Terminate)
  - (don't miss the LTO cases, since in the past they had problems)
- to test the Python debugger, start it with `--version`

## Publish the binaries as pre-release/test

Use the [test pre-release](https://github.com/xpack-dev-tools/pre-releases/releases/tag/test)
to publish the binaries, for other to test them.

## Run the pre-release Travis tests

In the `tests/scripts/trigger-travis-*.sh` files, check and update the
URL to use something like

```
base_url="https://github.com/xpack-dev-tools/pre-releases/releases/download/test/"
```

Trigger the stable and latest Travis builds (on a Mac by double-clicking 
on the command scripts):

- `tests/scripts/trigger-travis-stable.mac.command
- `tests/scripts/trigger-travis-latest.mac.command

## Create a new GitHub pre-release

- in `CHANGELOG.md`, add release date
- commit and push the repo
- go to the [GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases) page
- click **Draft a new release**
- name the tag like **v9.3.1-1.3** (mind the dash in the middle!)
- name the release like **xPack GNU Arm Embedded GCC v9.3.1-1.3**
(mind the dash)
- as description
  - add a downloads badge like `![Github Releases (by Release)](https://img.shields.io/github/downloads/xpack-dev-tools/arm-none-eabi-gcc-xpack/v9.3.1-1.3/total.svg)`
  - draft a short paragraph explaining what are the main changes
- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- **enable** the **pre-release** button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients
watching this project.

## Run the release Travis tests

In the `tests/scripts/trigger-travis-*.sh` files, check and update the
URL, use something like

```
base_url="https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v9.3.1-1.3/"
```

For more details, see `tests/scripts/README.md`.

## Prepare a new blog post

In the `xpack.github.io` web Git:

- add a new file to `_posts/arm-none-eabi-gcc/releases`
- name the file like `2020-07-03-arm-none-eabi-gcc-v9-3-1-1-1-released.md`
- name the post like: **xPack GNU Arm Embedded GCC v9.3.1-1.3 released**
- as `download_url` use the tagged URL like `https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v9.3.1-1.3/`
- update the `date:` field with the current date

If any, close [issues](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/issues)
on the way. Refer to them as:

- **[Issue:\[#1\]\(...\)]**.

### Update the SHA sums

Copy/paste the build report at the end of the post as:

```console
## Checksums
The SHA-256 hashes for the files are:

6f5e5b94ecf2afece992b46a60465e3ed5aae172202c2a4e34f8e81e5b0da790  
xpack-arm-none-eabi-gcc-9.3.1-1.3-darwin-x64.tar.gz

8791f653f1fc15b004987a2b84a7c0aabd71bde11e0e68eb32846e9b1ad80986  
xpack-arm-none-eabi-gcc-9.3.1-1.3-linux-arm64.tar.gz

bb4e1f6c72e32a1696edcfdec57d32ece64ac691a0363e4781db559addac7b79  
xpack-arm-none-eabi-gcc-9.3.1-1.3-linux-arm.tar.gz

be98731e1bb05fd78e2ec5727f7d6c9a6f2ae548970bbd0998de7079021d8e11  
xpack-arm-none-eabi-gcc-9.3.1-1.3-linux-x32.tar.gz

10b859d83c7a451add58eaf79afdb9a4a66fc38920884e8a54c809e0a1f4ed3e  
xpack-arm-none-eabi-gcc-9.3.1-1.3-linux-x64.tar.gz

5cc86c9d17c4fda97107b374ae939fedf9d7428d06e6c31418ea0e5ff1e6aa41  
xpack-arm-none-eabi-gcc-9.3.1-1.3-win32-x32.zip

91ab5e1b9b3ffcc606262e2be96bd70ab0be26a42d21e610340412f65de2bb16  
xpack-arm-none-eabi-gcc-9.3.1-1.3-win32-x64.zip
```

If you missed this, `cat` the content of the `.sha` files:

```console
$ cd ~Downloads/xpack-binaries/arm
$ cat *.sha
```

## Update the Web

- commit the `xpack.github.io` web Git; use a message
like **xPack GNU Arm Embedded GCC v9.3.1-1.3 released**
- adjust timestamps
- wait for the GitHub Pages build to complete
- remember the post URL, since it must be updated in the release page

## Publish on the npmjs.com server

- open [GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases)
  and select the latest release
- update the `baseUrl:` with the file URLs (including the tag/version)
- from the release, copy the SHA & file names
- check the executable names
- commit all changes, use a message like `package.json: update urls for 9.3.1-1.3 release` (without `v`)
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`; commit with a message like
  _CHANGELOG: prepare npm v9.3.1-1.3.1_
- `npm version 9.3.1-1.3.1`; the first 5 numbers are the same as the
  GitHub release; the sixth number is the npm specific version
- `npm pack` and check the content of the archive
- push all changes to GitHub
- `npm publish --tag next` (use `--access public` when publishing for the first time)

## Test the npm binaries with xpm

Run the `tests/scripts/trigger-travis-xpm-install.sh` file, this
will install the package on Intel Linux 64-bit, macOS and Windows 64-bit.

For the 32-bit platforms, install the binaries manually.

```console
$ xpm install --global @xpack-dev-tools/arm-none-eabi-gcc@next
```

## Create a final GitHub release

- go to the [GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- **disable** the **pre-release** button
- click the **Update Release** button

## Promote next to latest

Promote the release as `latest`:

- `npm dist-tag ls @xpack-dev-tools/arm-none-eabi-gcc`
- `npm dist-tag add @xpack-dev-tools/arm-none-eabi-gcc@9.3.1-1.3.1 latest`
- `npm dist-tag ls @xpack-dev-tools/arm-none-eabi-gcc`

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack GNU Arm Embedded GCC v9.3.1-1.3 released**
- paste the link to the Web page release
- click the **Tweet** button

## Announce to Arm community

Add a new topic in the **GNU Toolchain forum** category of the
[Arm Developer Community](https://community.arm.com/developer/tools-software/oss-platforms/f/gnu-toolchain-forum)
