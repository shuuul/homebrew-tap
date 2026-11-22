class FirecrawlLocal < Formula
  desc "Scrape, crawl and map websites to Markdown from your own machine"
  homepage "https://docs.firecrawl.dev/quickstarts/firecrawl-local"
  url "https://static.crates.io/crates/firecrawl-local/firecrawl-local-0.1.1.crate"
  sha256 "5a0f837d8b3687aab45c6d4ad5c2dddf21849c883501e24145df4c32787be964"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    strategy :crate
  end

  bottle do
    root_url "https://github.com/shuuul/homebrew-tap/releases/download/firecrawl-local-0.1.1"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1422b2806de5c0d34f385179e1827c26269ebd3843f7ed9994be292405ad4e40"
    sha256 cellar: :any,                 arm64_linux:       "937dfb4891de4f40052d88731b5e80f4419e98632ee669df3fad66d2763b3dca"
    sha256 cellar: :any,                 x86_64_linux:      "deea69912819aadc00cd1b8e8e05e7970b39d2ebe7de6b7809f6cc722885ddfc"
  end

  depends_on "rust" => :build

  def install
    # The published crate carries its Cargo.lock.
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/firecrawl-local --version")
    # Hermetic: an unreachable local port fails inside the JSON envelope,
    # with the Firecrawl Cloud hand-off off.
    ENV["FIRECRAWL_CLOUD"] = "off"
    output = shell_output("#{bin}/firecrawl-local --browser never scrape http://127.0.0.1:9 --timeout 2000", 1)
    assert_match "\"success\":false", output
  end
end
