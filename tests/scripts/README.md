# Scripts to test the toolchain

https://github.com/xpack-dev-tools/pre-releases/releases

## test-arm-none-eabi-binaries.sh

The test script is part of the arm-none-eabi-gcc xPack:

```
rm -rf ~/Downloads/arm-none-eabi-gcc-xpack.git
git clone --recurse-submodules -b xpack-develop https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack.git  ~/Downloads/arm-none-eabi-gcc-xpack.git
```

To force a new download:

```console
rm ~/Work/cache/xpack-arm-none-eabi-gcc-9.2.1-1.2-darwin-x64.tar.gz
```

### arm64

```
bash ~/Downloads/test-arm-none-eabi-binaries.sh --skip-gdb-py --skip-gdb-py3 https://github.com/xpack-dev-tools/pre-releases/releases/download/v1.0/xpack-arm-none-eabi-gcc-9.2.1-1.2-linux-arm64.tar.gz
```

gdb-py starts without py
gdb-py3 crashes

### arm

```
bash ~/Downloads/test-arm-none-eabi-binaries.sh --skip-gdb-py --skip-gdb-py3 https://github.com/xpack-dev-tools/pre-releases/releases/download/v1.0/xpack-arm-none-eabi-gcc-9.2.1-1.2-linux-arm.tar.gz
```

gdb-py starts without py
gdb-py3 crashes

### macOS

```
bash ~/Downloads/arm-none-eabi-gcc-xpack.git/tests/scripts/test-arm-none-eabi-binaries.sh https://github.com/xpack-dev-tools/pre-releases/releases/download/experimental/xpack-arm-none-eabi-gcc-9.2.1-1.2-darwin-x64.tar.gz
```

ok

## GitHub API endpoint

Programatic access to GitHub is done via the v3 API:

- https://developer.github.com/v3/

```
curl -i https://api.github.com/users/ilg-ul/orgs

curl -i https://api.github.com/repos/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases

curl -v -X GET https://api.github.com/repos/xpack-dev-tools/arm-none-eabi-gcc-xpack/hooks
```

For authenticated requests, preferably create a new token and pass it
via the environment.

- https://developer.github.com/v3/#authentication

## Trigger GitHub action

To trigger a GitHub action it is necessary to send an authenticated POST
at a specific URL:

- https://developer.github.com/v3/repos/#create-a-repository-dispatch-event

```
curl \
  --include \
  --header "Authorization: token ${GITHUB_API_DISPATCH_TOKEN}" \
  --header "Content-Type: application/json" \
  --header "Accept: application/vnd.github.everest-preview+json" \
  --data '{"event_type": "on-demand-test", "client_payload": {}}' \
  https://api.github.com/repos/xpack-dev-tools/arm-none-eabi-gcc-xpack/dispatches
```

The request should return `HTTP/1.1 204 No Content`.

The repository should have an action with `on: repository_dispatch`.