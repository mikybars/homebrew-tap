HOMEBREW_TAG_VERSION="v1.4.0".freeze
class Mytest < Formula
  desc "Instantly jump to your ag or ripgrep matches"
  homepage "https://github.com/aykamko/tag"
  url "https://github.com/aykamko/tag/archive/refs/tags/v1.4.0.tar.gz"
  sha256 "d3a02466e600634cf0ffff9ad8c5f70eba97e44758edf35cc4efbda9cbfdff9a"

  head "https://github.com/aykamko/tag.git", branch: "master"

  bottle do
    root_url "https://github.com/mikybars/homebrew-tap/releases/download/tag-1.4.0"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "40c8cd866713479af552da4f3d36fc0f049d802cfc4b976b5b007500aa5099e4"
  end

  depends_on "go" => :build
  depends_on "hg" => :build
  depends_on "the_silver_searcher" => :build

  def install
    go_build
    bin.install "tag"
  end

  def go_build
    ENV["GOPATH"] = buildpath
    system "go", "mod", "init", "tag"
    system "go", "get", "github.com/fatih/color"
    mkdir_p buildpath/"src/github.com/aykamko"
    ln_s buildpath, buildpath/"src/github.com/aykamko/tag"
    system "go", "build", "-o", "tag"
  end

  test do
    resource("testdata").stage do
      assert_match "hola", shell_output("echo hola", 1)
    end
  end
end
