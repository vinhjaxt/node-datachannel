name: Build - Linux

on:
  issues:
    types: [opened, reopened, closed]
  issue_comment:
    types: [created, edited, deleted]

env:
  ACTIONS_ALLOW_UNSECURE_COMMANDS: true

jobs:
  create_release:
    name: Create Release
    runs-on: ubuntu-latest
    outputs:
      release_tag: ${{ steps.tag.outputs.release_tag }}
    steps:
      - name: Generate release tag
        id: tag
        run: |
          sudo timedatectl set-timezone Asia/Ho_Chi_Minh
          sudo date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"
          echo "release_tag=Build_linux_$(date +"%Y.%m.%d_%H-%M-%S")" >> $GITHUB_OUTPUT
      - name: Create Release
        id: create_release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ steps.tag.outputs.release_tag }}
          draft: false
          prerelease: false
          generate_release_notes: false

  build-linux:
    needs: create_release
    runs-on: ubuntu-20.04
    strategy:
      matrix:
        node-version: [10.x, 11.x, 12.x, 13.x, 14.x, 15.x, 16.x, 17.x, 18.x, 19.x, 20.x]

    steps:
      - uses: actions/checkout@v2
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v1
        with:
          node-version: ${{ matrix.node-version }}
      - name: Build
        run: npm install --build-from-source
        env:
          CI: true
      # Create release
      - name: Rename file
        run:  find . -type f -exec sh -c 'f="{}" ; mv "$f" "${f%/*}/node-${{ matrix.node-version }}-${f##*/}"' \;
      - name: Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ needs.create_release.outputs.release_tag }}
          files: prebuilds/*
      # Done release
  build-linux-armv7:
    needs: create_release
    runs-on: ubuntu-20.04

    strategy:
      matrix:
        node-version: [10.x, 11.x, 12.x, 13.x, 14.x, 15.x, 16.x, 17.x, 18.x, 19.x, 20.x]
    steps:
      - uses: actions/checkout@v2
      - name: Prepare Cross Compile
        run: |
          sudo apt update
          sudo apt install -y g++-arm-linux-gnueabihf gcc-arm-linux-gnueabihf
          mkdir sysroot && cd sysroot
          wget https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/ef5c4f84bcafb7a3796d36bb1db7826317dde51c/debian_sid_arm_sysroot.tar.xz
          tar xf debian_sid_arm_sysroot.tar.xz
          echo "ARM_SYSROOT=$(pwd)" >> $GITHUB_ENV
          ls -l
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v1
        with:
          node-version: ${{ matrix.node-version }}
      - name: Build & Upload
        run: |
          npm install --ignore-scripts
          node_modules/.bin/prebuild --backend cmake-js --arch arm -- --CDCMAKE_TOOLCHAIN_FILE:FILEPATH=./cmake/toolchain/armv7.cmake
        env:
          CI: true
      # Create release
      - name: Rename file
        run:  find . -type f -exec sh -c 'f="{}" ; mv "$f" "${f%/*}/node-${{ matrix.node-version }}-${f##*/}"' \;
      - name: Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ needs.create_release.outputs.release_tag }}
          files: prebuilds/*
      # Done release

  build-linux-arm64:
    needs: create_release
    runs-on: ubuntu-20.04

    strategy:
      matrix:
        node-version: [10.x, 11.x, 12.x, 13.x, 14.x, 15.x, 16.x, 17.x, 18.x, 19.x, 20.x]
    steps:
      - uses: actions/checkout@v2
      - name: Prepare Cross Compile
        run: |
          sudo apt update
          sudo apt install -y g++-aarch64-linux-gnu gcc-aarch64-linux-gnu
          mkdir sysroot && cd sysroot
          wget https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/953c2471bc7e71a788309f6c2d2003e8b703305d/debian_sid_arm64_sysroot.tar.xz
          tar xf debian_sid_arm64_sysroot.tar.xz
          echo "ARM64_SYSROOT=$(pwd)" >> $GITHUB_ENV
          ls -l
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v1
        with:
          node-version: ${{ matrix.node-version }}
      - name: Build & Upload
        run: |
          npm install --ignore-scripts
          node_modules/.bin/prebuild --backend cmake-js --arch arm64 -- --CDCMAKE_TOOLCHAIN_FILE:FILEPATH=./cmake/toolchain/arm64.cmake
        env:
          CI: true
      # Create release
      - name: Rename file
        run:  find . -type f -exec sh -c 'f="{}" ; mv "$f" "${f%/*}/node-${{ matrix.node-version }}-${f##*/}"' \;
      - name: Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ needs.create_release.outputs.release_tag }}
          files: prebuilds/*
      # Done release

  # npm-publish:
  #   needs: [build-linux, build-linux-armv7, build-linux-arm64]
  #   name: npm-publish
  #   runs-on: ubuntu-latest
  #   steps:
  #     - name: Checkout repository
  #       uses: actions/checkout@v2
  #     - name: Set up Node.js
  #       uses: actions/setup-node@v1
  #       with:
  #         node-version: 12.x
  #         registry-url: "https://registry.npmjs.org"
  #     - name: Publish
  #       run: |
  #         npm install
  #         npm publish
  #       env:
  #         NODE_AUTH_TOKEN: ${{ secrets.NPM_AUTH_TOKEN }}

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: write
  pages: write
  id-token: write
