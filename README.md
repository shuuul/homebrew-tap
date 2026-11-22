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

This installs `aimd` (CLI) and `aimd-mcp` (MCP stdio server). Homebrew
installs MLX, Pandoc, yt-dlp, FFmpeg, MuPDF, and Firecrawl Local as runtime
dependencies. Model weights download from Hugging Face on first use.

The tap offers bottles for macOS arm64 and, starting with `aimd 1.5.0`,
Linux x86_64 with glibc 2.35 or newer. Homebrew and its dependencies may
require a newer runtime. Linux aarch64 builds from source.
Both Linux architectures use this tap's `mlx-cuda`, which repackages MLX's
official `mlx-cuda-13` wheel. The NVIDIA driver, CUDA 13, cuDNN 9, and NCCL 2
come from the system and must be on the dynamic loader path. See
`brew info shuuul/tap/mlx-cuda` for details.

## Releases and bottles

- `shuuul/aimd`'s `release` workflow opens an `aimd <version>` PR here
  that updates the formula `url`/`sha256` to the new release tag.
- `brew test-bot` (`.github/workflows/tests.yml`) builds and tests the
  macOS arm64 bottle on that PR and uploads it as a workflow artifact.
- After CI passes, run the `brew pr-pull` workflow
  (`.github/workflows/publish.yml`) with the PR number. It uploads the
  bottles to this repo's GitHub Releases, updates the `bottle do` block, and
  pushes to `main`.
- For Linux x86_64, build both binaries from the locked release source on
  Ubuntu 22.04 with Rust and with the NVIDIA libraries above on the loader
  path. This keeps the binary ABI at glibc 2.35, the floor for `mlx-cuda`.
  On a compatible Homebrew packaging host, run
  `brew install --build-bottle shuuul/tap/aimd` and stage those binaries in
  the freshly built keg before `brew test shuuul/tap/aimd` and
  `brew bottle --no-rebuild --json --root-url=<existing-bottle-root-url> shuuul/tap/aimd`.
  Upload the bottle to the existing tap release and add its checksum to the
  formula. Verify a regular Homebrew install uses the published bottle.

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
