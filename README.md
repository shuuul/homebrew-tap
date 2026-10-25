# shuuul/tap

Homebrew tap for [aimd](https://github.com/shuuul/aimd): turn URLs,
audio/video, and documents into Markdown context for LLM workflows.

## Install

```bash
brew install shuuul/tap/aimd
```

Or `brew tap shuuul/tap` and then `brew install aimd`. In a `Brewfile`:

```ruby
tap "shuuul/tap"
brew "aimd"
```

This installs three executables: `aimd` (CLI), `aimd-api` (HTTP API), and
`aimd-mcp` (MCP stdio server). Runtime tools come in as Homebrew
dependencies: `mlx`, `pandoc`, `yt-dlp`, `ffmpeg`, and `mupdf`. Model
weights download from Hugging Face on first use into the HF cache.

Platform: macOS on Apple Silicon (MLX Metal). Linux bottles are planned
once the CUDA-enabled `mlx` formula lands (aimd spec 002, WS-09).

## Releases and bottles

- `shuuul/aimd`'s `rust-release` workflow opens an `aimd <version>` PR here
  that updates the formula `url`/`sha256` to the new release tag.
- `brew test-bot` (`.github/workflows/tests.yml`) builds and tests the
  bottle on that PR (macOS arm64) and uploads it as a workflow artifact.
- After CI passes, run the `brew pr-pull` workflow
  (`.github/workflows/publish.yml`) with the PR number. It uploads the
  bottles to this repo's GitHub Releases, adds the `bottle do` block, and
  pushes to `main`.

## Local development

```bash
brew tap shuuul/tap /path/to/this/checkout
brew install --build-from-source shuuul/tap/aimd
brew test shuuul/tap/aimd
brew audit --strict --formula shuuul/tap/aimd
brew style shuuul/tap
```

## Documentation

`brew help`, `man brew`, or [Homebrew's documentation](https://docs.brew.sh).
