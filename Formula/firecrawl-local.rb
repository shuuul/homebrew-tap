class FirecrawlLocal < Formula
  desc "Scrape, crawl and map websites to Markdown from your own machine"
  homepage "https://docs.firecrawl.dev/quickstarts/firecrawl-local"
  url "https://static.crates.io/crates/firecrawl-local/firecrawl-local-0.1.1.crate"
  sha256 "5a0f837d8b3687aab45c6d4ad5c2dddf21849c883501e24145df4c32787be964"
  license "AGPL-3.0-only"

  livecheck do
    url "https://crates.io/api/v1/crates/firecrawl-local"
    strategy :json do |json|
      json.dig("crate", "max_stable_version")
    end
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
