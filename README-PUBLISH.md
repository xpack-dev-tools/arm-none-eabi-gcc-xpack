# How to publish the xPack GNU Arm Embedded GCC binaries?

## Build

Before starting the build, perform some checks.

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

- - unpack the archive in `Desktop` or in `Downloads`, and rename the version
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
- to test the Python debugger, start it with `--version`; on Windows, to test with different versions, set the path with:
```
C:\Users\ilg>set PYTHONHOME=C:\Python27.16
```

## Create a new GitHub pre-release

- in `CHANGELOG.md`, add release date
- commit and push the repo
- go to the [GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases) page
- click **Draft a new release**
- name the tag like **v8.2.1-1.8** (mind the dash in the middle!)
- name the release like **xPack GNU Arm Embedded GCC v8.2.1-1.8**
(mind the dash)
- as description
  - add a downloads badge like `![Github Releases (by Release)](https://img.shields.io/github/downloads/xpack-dev-tools/arm-none-eabi-gcc-xpack/v8.2.1-1.8/total.svg)`
  - draft a short paragraph explaining what are the main changes
- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- **enable** the **pre-release** button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients
watching this project.

## Prepare a new blog post

In the `xpack.github.io` web Git:

- add a new file to `_posts/arm-none-eabi-gcc/releases`
- name the file like `2018-04-01-arm-none-eabi-gcc-v8-2-1-1-8-released.md`
- name the post like: **xPack GNU Arm Embedded GCC v8.2.1-1.8 released**
- as `download_url` use the tagged URL like `https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v8.2.1-1.8/`
- update the `date:` field with the current date

If any, close [issues](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/issues)
on the way. Refer to them as:

- **[Issue:\[#1\]\(...\)]**.

### Update the SHA sums

Copy/paste the build report at the end of the post as:

```console
## Checksums
The SHA-256 hashes for the files are:

4fe99c9122c7f2f84a998640d9b3d3d890a2ae47cbd5469813a3ad015e69bbd7
xpack-arm-none-eabi-gcc-8.2.1-1.8-linux-x32.tar.xz

ed6c727b859eed4fcb55aa14bdafd329f71b087877d2eb7438abfec2bb533227
xpack-arm-none-eabi-gcc-8.2.1-1.8-linux-x64.tar.xz

578c4525187c498ec0b8255ac46d4177ed3b51b115cb6ca4cd379baa6b70db7a
xpack-arm-none-eabi-gcc-8.2.1-1.8-win32-x32.zip

fd9573d0b9e89d87b9bf7f237955bbeba206a93c6cecc2fc3996458798d7a05b
xpack-arm-none-eabi-gcc-8.2.1-1.8-win32-x64.zip
```

If you missed this, `cat` the content of the `.sha` files:

```console
$ cd ~Downloads/xpack-binaries/arm
$ cat *.sha
```

## Update the Web

- commit the `xpack.github.io` web Git; use a message
like **xPack GNU Arm Embedded GCC v8.2.1-1.8 released**
- adjust timestamps
- wait for the GitHub Pages build to complete
- remember the post URL, since it must be updated in the release page

## Publish on the npmjs.com server

- open [GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases)
  and select the latest release
- update the `baseUrl:` with the file URLs (including the tag/version)
- from the release, copy the SHA & file names
- check the executable names
- commit all changes, use a message like `package.json: update urls for 8.2.1-1.8 release` (without `v`)
- update `CHANGELOG.md`; commit with a message like
  _CHANGELOG: prepare npm v8.2.1-1.8.1_
- `npm version 8.2.1-1.8.1`; the first 5 numbers are the same as the
  GitHub release; the sixth number is the npm specific version
- `npm pack` and check the content of the archive
- push all changes to GitHub
- `npm publish` (use `--access public` when publishing for the first time)

## Test npm binaries

Install the binaries on all platforms.

```console
$ xpm install --global @xpack-dev-tools/arm-none-eabi-gcc@latest
```

## Create a final GitHub release

- go to the [GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack GNU Arm Embedded GCC v8.2.1-1.8 released**
- paste the link to the Web page release
- click the **Tweet** button

## Announce to Arm community

Add a new topic in the **GNU Toolchain forum** category of the
[Arm Developer Community](https://community.arm.com/developer/tools-software/oss-platforms/f/gnu-toolchain-forum)
