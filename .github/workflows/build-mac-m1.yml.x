name: Build - Mac M1

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
          echo "release_tag=Build_darwin_arm64_$(date +"%Y.%m.%d_%H-%M-%S")" >> $GITHUB_OUTPUT
      - name: Create Release
        id: create_release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ steps.tag.outputs.release_tag }}
          draft: false
          prerelease: false
          generate_release_notes: false

  build-macos:
    needs: create_release
    runs-on: macos-11
    strategy:
      matrix:
        node-version: [10.x, 11.x, 12.x, 13.x, 14.x, 15.x, 16.x, 17.x, 18.x, 19.x, 20.x]

    steps:
      - uses: actions/checkout@v3
      - name: Install OpenSSL
        run: |
          wget https://mac.r-project.org/bin/darwin20/arm64/openssl-1.1.1o-darwin.20-arm64.tar.xz
          tar -xf openssl-1.1.1o-darwin.20-arm64.tar.xz -C /tmp
          rm -rf openssl-1.1.1o-darwin.20-arm64.tar.xz
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - name: Build
        run: |
          npm install --ignore-scripts
          node_modules/.bin/prebuild --backend cmake-js --arch arm64 -- --CDCMAKE_OSX_ARCHITECTURES="arm64"
        env:
          CI: true
          OPENSSL_ROOT_DIR: /tmp/opt/R/arm64
          OPENSSL_LIBRARIES: /tmp/opt/R/arm64/lib
      # Create release
      - name: Rename file
        run:  find . -type f -exec sh -c 'f="{}" ; mv "$f" "${f%/*}/node-${{ matrix.node-version }}-${f##*/}"' \;
      - name: Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ needs.create_release.outputs.release_tag }}
          files: prebuilds/*
      # Done release

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: write
  pages: write
  id-token: write
