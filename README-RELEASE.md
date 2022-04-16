# How to make a new release (maintainer info)

## Release schedule

The xPack GNU Arm Embedded GCC release schedule generally follows the
[GNU Arm Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)
release schedule, which is about two releases per year.

## Prepare the build

Before starting the build, perform some checks and tweaks.

### Check Git

In the `xpack-dev-tools/arm-none-eabi-gcc-xpack` Git repo:

- switch to the `xpack-develop` branch
- if needed, merge the `xpack` branch

No need to add a tag here, it'll be added when the release is created.

### Update to latest Arm release

- download the new _Source Invariant_ archive from
  [Arm](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm)
- clone the `arm-gcc-original-scripts.git` repo
- remove all files except README.md, from the repo
- copy/paste all files, except the PDF, from the new archive
- commit with a message like **10.3-2021.10**; also add a tag;
- check differences from the previous version;
- determine the GCC version (like `10.3.1`) and update the `scripts/VERSION`
  file; the format is `10.3.1-2.3`;
- add a new set of definitions in the `scripts/common-versions-source.sh`,
  with the versions of various components;
- if newer libraries are used, check if they are available from the local git
  cache project.

### Increase the version

Determine the GCC version (like `10.3.1`) and update the `scripts/VERSION`
file; the format is `10.3.1-2.3`. The fourth number is the Arm release
number and the fifth is the xPack release number
of this version. A sixth number will be added when publishing
the package on the `npm` server.

### Fix possible open issues

Check GitHub issues and pull requests:

- <https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/issues/>

and fix them; assign them to a milestone (like `10.3.1-2.3`).

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific release page.

### Update versions in `README` files

- update version in `README-RELEASE.md`
- update version in `README-BUILD.md`
- update version in `README.md`

### Update `CHANGELOG.md`

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _- v10.3.1-2.3 prepared_
- commit with a message like _prepare v10.3.1-2.3_

Note: if you missed to update the `CHANGELOG.md` before starting the build,
edit the file and rerun the build, it should take only a few minutes to
recreate the archives with the correct file.

### Update the version specific code

- open the `common-versions-source.sh` file
- add a new `if` with the new version before the existing code

### Update helper

With a git client, go to the helper repo and update to the latest master commit.

## Build

### Development run the build scripts

Before the real build, run a test build on the development machine (`wks`)
or the production machines (`xbbma`, `xbbmi`):

```sh
sudo rm -rf ~/Work/arm-none-eabi-gcc-*-*

caffeinate bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/build.sh --develop --disable-multilib --macos
```

Similarly on the Intel Linux (`xbbli`):

```sh
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/build.sh --develop --disable-multilib --linux64

bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/build.sh --develop --disable-multilib --win64
```

... the Arm Linux 64-bit (`xbbla64`):

```sh
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/build.sh --develop --disable-multilib --arm64
```

... and on the Arm Linux 32-bit (`xbbla32`):

```sh
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/build.sh --develop --disable-multilib --arm32
```

Work on the scripts until all platforms pass the build.

Possibly add binutils & gdb patches.

## Push the build scripts

In this Git repo:

- push the `xpack-develop` branch to GitHub
- possibly push the helper project too

From here it'll be cloned on the production machines.

## Run the CI build

The automation is provided by GitHub Actions and three self-hosted runners.

It is recommended to do **a first run without the multi-libs**
(see the `defs-source.sh` file), test it,
and, when ready, rerun the full build.

Run the `generate-workflows` to re-generate the
GitHub workflow files; commit and push if necessary.

- on the macOS machine (`xbbmi`) open ssh sessions to the Linux
machines (`xbbli`, `xbbla64` and `xbbla32`):

```sh
caffeinate ssh xbbli

caffeinate ssh xbbla64
caffeinate ssh xbbla32
```

Start the runner on all three machines:

```sh
~/actions-runner/run.sh
```

Check that both the project Git and the submodule are pushed to GitHub.

To trigger the GitHub Actions build, use the xPack actions:

- `trigger-workflow-build-xbbli`
- `trigger-workflow-build-xbbla64`
- `trigger-workflow-build-xbbla32`
- `trigger-workflow-build-xbbmi`
- `trigger-workflow-build-xbbma`

This is equivalent to:

```sh
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/trigger-workflow-build.sh --machine xbbli
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/trigger-workflow-build.sh --machine xbbla64
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/trigger-workflow-build.sh --machine xbbla32
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/trigger-workflow-build.sh --machine xbbmi
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/trigger-workflow-build.sh --machine xbbma
```

These scripts require the `GITHUB_API_DISPATCH_TOKEN` variable to be present
in the environment.

These commands use the `xpack-develop` branch of this repo.

The full builds take about 16 hours (about 6 hours without multi-libs)
to complete.

The workflows results and logs are available from the
[Actions](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/actions/) page.

The resulting binaries are available for testing from
[pre-releases/test](https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/).

## Testing

### CI tests

The automation is provided by GitHub Actions.

To trigger the GitHub Actions tests, use the xPack actions:

- `trigger-workflow-test-prime`
- `trigger-workflow-test-docker-linux-intel`
- `trigger-workflow-test-docker-linux-arm`

These are equivalent to:

```sh
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/tests/trigger-workflow-test-prime.sh
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/tests/trigger-workflow-test-docker-linux-intel.sh
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/tests/trigger-workflow-test-docker-linux-arm.sh
```

These scripts require the `GITHUB_API_DISPATCH_TOKEN` variable to be present
in the environment.

These actions use the `xpack-develop` branch of this repo and the
[pre-releases/test](https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/)
binaries.

The tests results are available from the
[Actions](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/actions/) page.

Since GitHub Actions provides a single version of macOS, the
multi-version macOS tests run on Travis.

To trigger the Travis test, use the xPack action:

- `trigger-travis-macos`

This is equivalent to:

```sh
bash ${HOME}/Work/arm-none-eabi-gcc-xpack.git/scripts/helper/tests/trigger-travis-macos.sh
```

This script requires the `TRAVIS_COM_TOKEN` variable to be present
in the environment.

The test results are available from
[travis-ci.com](https://app.travis-ci.com/github/xpack-dev-tools/arm-none-eabi-gcc-xpack/builds/).

### Manual tests

Install the binaries on all supported platforms and check if they are
functional.

For this, on each platform (Mac, GNU/Linux 64/32, Windows 64/32):

- unpack the archive in `Desktop` or in `Downloads`, and rename the version
  folder, by replacing a dash with a space; this will test paths with spaces;
  on Windows the current paths always use spaces, so renaming is not needed;
- on macOS it is necessarry to remove the `com.apple.quarantine`
  attribute of archive and possibly the expanded folder:

```sh
xattr -dr com.apple.quarantine xpack-arm-none-eabi-gcc-*
```

- clone this repo locally; on Windows use the Git console;

```sh
rm -rf ${HOME}/Work/arm-none-eabi-gcc-xpack.git; \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git \
  ${HOME}/Work/arm-none-eabi-gcc-xpack.git; \
git -C ${HOME}/Work/arm-none-eabi-gcc-xpack.git submodule update --init --recursive
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

## Create a new GitHub pre-release draft

- in `CHANGELOG.md`, add the release date and a message like _- v10.3.1-2.3 released_
- commit and push the `xpack-develop` branch
- run the xPack action `trigger-workflow-publish-release`

The result is a
[draft pre-release](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/)
tagged like **v10.3.1-2.3** (mind the dash in the middle!) and
named like **xPack GNU Arm Embedded GCC v10.3.1-2.3** (mind the dash),
with all binaries attached.

- edit the draft and attach it to the `xpack-develop` branch (important!)
- save the draft (do **not** publish yet!)

## Prepare a new blog post

Run the xPack action `generate-jekyll-post`; this will leave a file
on the Desktop.

In the `xpack/web-jekyll` GitHub repo:

- select the `develop` branch
- copy the new file to `_posts/releases/arm-none-eabi-gcc`

If any, refer to closed
[issues](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/issues/).

## Update the preview Web

- commit the `develop` branch of `xpack/web-jekyll` GitHub repo;
  use a message like **xPack GNU Arm Embedded GCC v10.3.1-2.3 released**
- push to GitHub
- wait for the GitHub Pages build to complete
- the preview web is <https://xpack.github.io/web-preview/news/>

## Create the pre-release

- go to the GitHub [Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/) page
- perform the final edits and check if everything is fine
- temporarily fill in the _Continue Reading »_ with the URL of the
  web-preview release
- **keep the pre-release button enabled**
- do not enable Discussions yet
- publish the release

Note: at this moment the system should send a notification to all clients
watching this project.

## Update package.json binaries

- select the `xpack-develop` branch
- run the xPack action `update-package-binaries`
- open the `package.json` file
- check the `baseUrl:` it should match the file URLs (including the tag/version);
  no terminating `/` is required
- from the release, check the SHA & file names
- compare the SHA sums with those shown by `cat *.sha`
- check the executable names
- commit all changes, use a message like
  `package.json: update urls for 10.3.1-2.3 release` (without `v`)

## Publish on the npmjs.com server

- select the `xpack-develop` branch
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`, add a line like _- v10.3.1-2.3.1 published on npmjs.com_
- commit with a message like _CHANGELOG: publish npm v10.3.1-2.3.1_
- `npm pack` and check the content of the archive, which should list
  only the `package.json`, the `README.md`, `LICENSE` and `CHANGELOG.md`;
  possibly adjust `.npmignore`
- `npm version 10.3.1-2.3.1`; the first 5 numbers are the same as the
  GitHub release; the sixth number is the npm specific version
- the commits and the tag should have beed pushed by the `postversion` script;
  if not, push them with `git push origin --tags`
- `npm publish --tag next` (use `--access public` when publishing for
  the first time)

After a few moments the version will be visible at:

- <https://www.npmjs.com/package/@xpack-dev-tools/arm-none-eabi-gcc?activeTab=versions>

## Test if the binaries can be installed with xpm

Run the xPack action `trigger-workflow-test-xpm`, this
will install the package via `xpm install` on all supported platforms.

The tests results are available from the
[Actions](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/actions/) page.

## Update the repo

- merge `xpack-develop` into `xpack`
- push to GitHub

## Tag the npm package as `latest`

When the release is considered stable, promote it as `latest`:

- `npm dist-tag ls @xpack-dev-tools/arm-none-eabi-gcc`
- `npm dist-tag add @xpack-dev-tools/arm-none-eabi-gcc@10.3.1-2.3.1 latest`
- `npm dist-tag ls @xpack-dev-tools/arm-none-eabi-gcc`

In case the previous version is not functional and needs to be unpublished:

- `npm unpublish @xpack-dev-tools/arm-none-eabi-gcc@10.3.1-2.3.X`

## Update the Web

- in the `master` branch, merge the `develop` branch
- wait for the GitHub Pages build to complete
- the result is in <https://xpack.github.io/news/>
- remember the post URL, since it must be updated in the release page

## Create the final GitHub release

- go to the GitHub [Releases](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- remove the _tests only_ notice
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack GNU Arm Embedded GCC v10.3.1-2.3 released**
- paste the link to the Web page
  [release](https://xpack.github.io/arm-none-eabi-gcc/releases/)
- click the **Tweet** button

## Remove pre-release binaries

- go to <https://github.com/xpack-dev-tools/pre-releases/releases/tag/test/>
- remove the test binaries

## Announce to Arm community

Add a new topic in the **Compilers and Libraries** forum of the
[Arm Developer Community](https://community.arm.com/support-forums/f/compilers-and-libraries-forum)

- title: copy release title
- content:
  - The **xPack GNU Arm Embedded GCC** is an alternate binary distribution that complements the official GNU Arm Embedded Toolchain maintained by Arm.
  - The latest release is [10.3.1-2.3]() following Arm release from October 21, 2021 (version 10.3-2021.10).
- tags: xpack, gnu, gcc, arm, toolchain
