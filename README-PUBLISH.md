# How to publish the xPack GNU ARM Embedded GCC binaries?

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

### Push the build script git

In this Git repo:

- if necessary, merge the `xpack-develop` branch into `xpack`.
- push it to GitHub.
- possibly push the helper project too.

### Run the build scripts

When everything is ready, follow the instructions from the 
[build](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/README.md) 
page.

## Test

Install the binaries on all supported platforms and check if they are 
functional.

For this, on each platform:

- unpack the archive in `Downloads`, and rename the version folder,
  by replacing a dash with a space; this will test paths with spaces;
  on Windows the current paths always use spaces, so renaming is not needed;
- clone the build repo from https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git
  locally; on Windows use the Git console;
- in a separate workspace, Import -> General -> Existing Projects into Workspace
  the Eclipse projects available in the 
  `tests/eclipse` folder of the build repo; more details in the 
  [README.md](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/blob/xpack/tests/eclipse/README.md)
- define the **Workspace ARM Toolchain path** to use the `Downloads` 
  temporary location
- to test the compiler: for all projects
  - remove all build folders 
  - build all configs
- to test the debugger: for all QEMU debug configurations
  - start the QEMU debug session, 
  - single step a few lines (Step Over)
  - start continuous run (Resume)
  - halt (Suspend)
  - start (Resume)
  - stop (Terminate)
  - (don't miss the LTO cases, since in the past they had problems)

## Create a new GitHub pre-release

- go to the [GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases) page
- click **Draft a new release**
- name the tag like **v8.2.1-1.8** (mind the dash in the middle!)
- name the release like **xPack GNU ARM Embedded GCC v8.2.1-1.8** 
(mind the dash)
- as description
  - add a downloads badge like `[![Github Releases (by Release)](https://img.shields.io/github/downloads/xpack-dev-tools/arm-none-eabi-gcc-xpack/v8.2.1-1.8/total.svg)]()`; use empty URL for now
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
- name the post like: **xPack GNU ARM Embedded GCC v8.2.1-1.8 released**
- as `download_url` use the tagged URL like `https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v8.2.1-1.8/` 
- update the `date:` field with the current date

If any, close [issues](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/issues) 
on the way. Refer to them as:

- **[Issue:\[#1\]\(...\)]**.

## Update the SHA sums

Copy/paste the build report at the end of the post as:

```console
## Checksums
The SHA-256 hashes for the files are:

4fe99c9122c7f2f84a998640d9b3d3d890a2ae47cbd5469813a3ad015e69bbd7
gnu-mcu-eclipse-arm-none-eabi-gcc-8.2.1-1.8-20180401-0515-centos32.tar.xz

ed6c727b859eed4fcb55aa14bdafd329f71b087877d2eb7438abfec2bb533227
gnu-mcu-eclipse-arm-none-eabi-gcc-8.2.1-1.8-20180401-0515-centos64.tar.xz

578c4525187c498ec0b8255ac46d4177ed3b51b115cb6ca4cd379baa6b70db7a
gnu-mcu-eclipse-arm-none-eabi-gcc-8.2.1-1.8-20180401-0515-win32.zip

fd9573d0b9e89d87b9bf7f237955bbeba206a93c6cecc2fc3996458798d7a05b
gnu-mcu-eclipse-arm-none-eabi-gcc-8.2.1-1.8-20180401-0515-win64.zip
```

If you missed this, `cat` the content of the `.sha` files:

```console
$ cd deploy
$ cat *.sha
```

## Update the Web

- commit the `xpack.github.io` web Git; use a message 
like **xPack GNU ARM Embedded GCC v8.2.1-1.8 released**
- wait for the GitHub Pages build to complete
- remember the post URL, since it must be updated in the release page

## Publish on the npmjs server

- open [GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases) 
  and select the latest release
- update the `baseUrl:` with the file URLs (including the tag/version)
- from the release, copy the SHA & file names
- commit all changes, use a message like `package.json: update urls for 8.2.1-1.8 release` (without `v`)
- update `CHANGELOG.md`; commit with a message like 
  _CHANGELOG: prepare npm v8.2.1-1.8.1_
- `npm version 8.2.1-1.8.1`; the first 5 numbers are the same as the 
  GitHub release; the sixth number is the npm specific version
- push all changes to GitHub
- `npm publish` (use `--access public` when publishing for the first time)

## Test the xPack

At minimum, test only if the URLs and SHA sums are correct, but for 
extra safety also rerun the tests.

On all available platforms:

- install the new xPack release

```console
$ xpm install --global @xpack-dev-tools/arm-none-eabi-gcc
```

- double check version, to be sure it is the latest release (sometimes 
  the NPM server needs some time to propagate the changes)
- in Eclipse, disable the Workspace ARM Toolchains path (**Restore Defaults**)
- in Eclipse, select the Global ARM Toolchains path to the new xPack release
- remove the toolchain temporarily installed in `Downloads`
- rerun all build and debug tests, as before

## Create a final GitHub release

- go to the [GitHub Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases) page
- update the link behind the badge with the blog URL
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- copy/paste the **Easy install** section
- update the current release version
- copy/paste the **Download analytics** section
- update the current release version
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack QEMU ARM v2.8.0-7.1 released**
- paste the link to the Github release
- click the **Tweet** button
