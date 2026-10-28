class Aimd < Formula
  desc "Turn URLs, audio/video, and documents into Markdown context for LLMs"
  homepage "https://github.com/shuuul/aimd"
  # Bumped by shuuul/aimd's release workflow (url + sha256 in one PR).
  url "https://github.com/shuuul/aimd/archive/refs/tags/v1.4.0.tar.gz"
  sha256 "31fc9d6deb8a7baa8cc9bf26b89f228b1402e730a5925670e7b93bdfbc48f9ba"
  license "Apache-2.0"
  head "https://github.com/shuuul/aimd.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/shuuul/homebrew-tap/releases/download/aimd-1.3.1"
    sha256 cellar: :any, arm64_golden_gate: "3f9a2ac55493499f51e104538d3e7373ece520c56270b106e6dad272a433a99c"
  end

  # The engine is MLX-only: Metal on macOS arm64 (homebrew-core mlx), CUDA on
  # Linux (this tap's mlx-cuda; NVIDIA driver, CUDA 13, cuDNN 9 and NCCL 2
  # come from the system). Linux installs build from source (no bottle).
  depends_on "rust" => :build
  depends_on "ffmpeg"
  depends_on "mupdf"
  depends_on "pandoc"
  depends_on "yt-dlp"

  on_macos do
    depends_on arch: :arm64
    depends_on "mlx"
  end

  on_linux do
    depends_on "shuuul/tap/mlx-cuda"
  end

  def install
    # crates/aimd-mlx/build.rs links libmlx from here and embeds an rpath to
    # its lib dir; opt_prefix keeps the bottle valid across mlx revisions.
    ENV["MLX_PREFIX"] = formula_opt_prefix(OS.mac? ? "mlx" : "shuuul/tap/mlx-cuda")
    # One shared target dir so the two binaries reuse a single build.
    ENV["CARGO_TARGET_DIR"] = buildpath/"target"
    # The workspace release profile keeps debuginfo for local profiling;
    # bottles do not need it.
    ENV["CARGO_PROFILE_RELEASE_DEBUG"] = "false"

    %w[aimd-cli aimd-mcp].each do |crate|
      system "cargo", "install", *std_cargo_args(path: "crates/#{crate}")
    end
  end

  test do
    # Hermetic: no model weights, no network, no GPU work.
    ENV["AIMD_MLX_DEVICE"] = "cpu"

    assert_match "Usage: aimd", shell_output("#{bin}/aimd --help")

    (testpath/"note.md").write "# Brew Test\n\nhermetic passthrough\n"
    system bin/"aimd", "note.md", "-o", "note_out.md"
    assert_match "hermetic passthrough", (testpath/"note_out.md").read

    # Exercises the pandoc runtime dependency.
    (testpath/"page.html").write "<html><body><h1>Brew</h1><p>pandoc <b>works</b></p></body></html>"
    system bin/"aimd", "page.html", "-o", "page_out.md"
    assert_match "pandoc **works**", (testpath/"page_out.md").read

    assert_path_exists bin/"aimd-mcp"
  end
end
