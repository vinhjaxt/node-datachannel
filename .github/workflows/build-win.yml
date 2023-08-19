name: Build - Win

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
          echo "release_tag=Build_winx64_$(date +"%Y.%m.%d_%H-%M-%S")" >> $GITHUB_OUTPUT
      - name: Create Release
        id: create_release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ steps.tag.outputs.release_tag }}
          draft: false
          prerelease: false
          generate_release_notes: false

  build-windows-x64:
    needs: create_release
    runs-on: windows-2019
    strategy:
      matrix:
        node-version: [10.x, 11.x, 12.x, 13.x, 14.x, 15.x, 16.x, 17.x, 18.x, 19.x, 20.x]

    steps:
      - uses: actions/checkout@v2
      - uses: ilammy/msvc-dev-cmd@v1
      - name: Install OpenSSL
        run: choco install openssl
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v1
        with:
          node-version: ${{ matrix.node-version }}
      - name: Build
        run: set npm_config_cache= && set NPM_CONFIG_CACHE= && npm install --build-from-source
        env:
          CI: true
      # Create release
      - name: Rename file
        run: Get-ChildItem -Recurse -File ./prebuilds/ | Rename-Item -NewName { "node-${{ matrix.node-version }}-"+$_.Name }
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
