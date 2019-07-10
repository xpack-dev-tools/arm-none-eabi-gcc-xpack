# How to publish the GNU MCU Eclipse ARM Embedded GCC binaries?

## Build

Before starting the build, perform some checks.

### Check the CHANGELOG file

Generally, apart from packing, there should be no local changes compared 
to the original ARM distribution.

Open the `CHANGELOG.txt` file from 
`gnu-mcu-eclipse/arm-none-eabi-gcc-build.git` project git, and check if 
all new entries are in.

Note: if you missed to update the `CHANGELOG.txt` before starting the build, 
edit the file and rerun the build, it should take only a few minutes to 
recreate the archives with the correct file.

### Check the version

The `VERSION` file should refer to the actual release.

### Push the build script git

In `gnu-mcu-eclipse/arm-none-eabi-gcc-build.git`, if necessary, merge 
the `develop` branch into `master`.

Push it to GitHub.

Possibly push the helper project too.

### Run the build scripts

When everything is ready, follow the instructions on the 
[build](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build/blob/master/README.md) 
page.

## Test

Install the binaries on all supported platforms and check if they are 
functional.

For this, on each platform:

- unpack the archive in `Downloads`, and rename the version folder,
  by replacing a dash with a space; this will test paths with spaces;
  on Windows the current paths always use spaces, so renaming is not needed;
- clone the build repo from https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build.git
  locally; on Windows use the Git console;
- in a separate workspace, Import -> General -> Existing Projects into Workspace
  the Eclipse projects available in the 
  `tests/eclipse` folder of the build repo; more details in the 
  [README.md](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build/blob/master/tests/eclipse/README.md)
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

- go to the [GitHub Releases](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc/releases) page
- click **Draft a new release**
- name the tag like **v7.2.1-1.1** (mind the dash in the middle!)
- name the release like **GNU MCU Eclipse ARM Embedded GCC v7.2.1-1.1 20180401** 
(mind the dash and the space)
- as description
  - add a downloads badge like `[![Github Releases (by Release)](https://img.shields.io/github/downloads/gnu-mcu-eclipse/arm-none-eabi-gcc/v7.2.1-1.1/total.svg)]()`; use empty URL for now
  - draft a short paragraph explaining what are the main changes
- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- **enable** the **pre-release** button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients 
watching this project.

## Prepare a new blog post 

In the `gnu-mcu-eclipse.github.io-source.git` web git:

- add a new file to `_posts/arm-none-eabi-gcc/releases`
- name the file like `2018-04-01-arm-none-eabi-gcc-v7-2-1-1-1-released.md`
- name the post like: **GNU MCU Eclipse ARM Embedded GCC v7.2.1-1.1 20180401 released**
- as `download_url` use the tagged URL like `https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc/releases/tag/v7.2.1-1.1/` 
- update the `date:` field with the current date

If any, close [issues](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc/issues) 
on the way. Refer to them as:

- **[Issue:\[#1\]\(...\)]**.

Also close [build issues](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build/issues).

## Update the SHA sums

Copy/paste the build report at the end of the post as:

```console
## Checksums
The SHA-256 hashes for the files are:

4fe99c9122c7f2f84a998640d9b3d3d890a2ae47cbd5469813a3ad015e69bbd7
gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-centos32.tar.xz

ed6c727b859eed4fcb55aa14bdafd329f71b087877d2eb7438abfec2bb533227
gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-centos64.tar.xz

578c4525187c498ec0b8255ac46d4177ed3b51b115cb6ca4cd379baa6b70db7a
gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-win32.zip

fd9573d0b9e89d87b9bf7f237955bbeba206a93c6cecc2fc3996458798d7a05b
gnu-mcu-eclipse-arm-none-eabi-gcc-7.2.1-1.1-20180401-0515-win64.zip
```

## Update the Web

- commit the `gnu-mcu-eclipse.github.io-source` project; use a message 
like **GNU MCU Eclipse ARM Embedded GCC v7.2.1-1.1 released**
- wait for the Travis build to complete; occasionally links to not work,
 and might need to restart the build
- remember the post URL, since it must be updated in the release page

## Create the xPack release

Follow the instructions from the 
[gnu-mcu-eclipse/arm-none-eabi-gcc-xpack](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-xpack/blob/xpack/README.md#maintainer-info)
page.

## Test the xPack

At minimum, test only if the URLs and SHA sums are correct, but for 
extra safety also rerun the tests.

On all available platforms:

- install the new xPack release

```console
$ xpm install --global @gnu-mcu-eclipse/arm-none-eabi-gcc
```

- double check version, to be sure it is the latest release (sometimes 
  the NPM server needs some time to propagate the changes)
- in Eclipse, disable the Workspace ARM Toolchains path (**Restore Defaults**)
- in Eclipse, select the Global ARM Toolchains path to the new xPack release
- remove the toolchain temporarily installed in `Downloads`
- rerun all build and debug tests, as before

## Create a final GitHub release

- go to the [GitHub Releases](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc/releases) page
- update the link behind the badge with the blog URL
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- copy/paste the **Easy install** section
- update the current release version
- copy/paste the **Download analytics** section
- update the current release version
- **disable** the **pre-release** button
- click the **Update Release** button

## Tag the build commit

In the [gnu-mcu-eclipse/arm-none-eabi-gcc-build](https://github.com/gnu-mcu-eclipse/arm-none-eabi-gcc-build)
project, add a tag with the current version, like `v8.2.1-1.1` (with *v*).

## Update the README.md

List the new release in the `gnu-mcu-eclipse/arm-none-eabi-gcc.git` project
README.md.

## Share on Facebook

- go to the new post and follow the Share link.
- DO NOT select **On your own Timeline**, but **On a Page you manage**
- select GNU MCU Eclipse
- posting as GNU MCU Eclipse
- click **Post to Facebook**
- check the post in the [Facebook page](https://www.facebook.com/gnu-mcu-eclipse)

## Share on Twitter

* go to the new post and follow the Tweet link
* copy the content to the clipboard
* DO NOT click the Tweet button here, it'll not use the right account
* in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
* using the `@gnu_mcu_eclipse` account, paste the content
* click the Tweet button
