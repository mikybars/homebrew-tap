class HadolintWrapper < Formula
  include Language::Python::Virtualenv

  desc "Pretty output for hadolint"
  homepage "https://github.com/mikybars/hadolint-wrapper"
  url "https://github.com/mikybars/hadolint-wrapper/releases/download/v1.2.1/hadolintw-1.2.1-brew.tar.gz"
  sha256 "62ade57dea14d815ce87f99d65aaa19df7df1bd8d01c0d0b39e43c3b8c0167f0"
  license "MIT"

  bottle do
    root_url "https://github.com/mikybars/homebrew-tools/releases/download/hadolint-wrapper-1.2.1"
    sha256 cellar: :any_skip_relocation, ventura:      "82756f5d2e34f3827e7a65a8d64905d708c770bc5ea436b3ebfb060a90caf214"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "457dbbf8ea4892ea1afec0948bc7f2dedf15d98da6d4986598d84687c3628d6d"
  end

  depends_on "hadolint"
  depends_on "python"

  resource "click" do
    url "https://files.pythonhosted.org/packages/96/d3/f04c7bfcf5c1862a2a5b845c6b2b360488cf47af55dfa79c98f6a6bf98b5/click-8.1.7.tar.gz"
    sha256 "ca9853ad459e787e2192211578cc907e7594e294c7ccc834310722b41b9ca6de"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    resource("testdata") do
      url "https://raw.githubusercontent.com/mikybars/hadolint-wrapper/f01c150e195d7b8e8af0fec794a997167c413f41/Dockerfile.example"
      sha256 "495ade97a264e4194d3e933699291834a39dbe36a6cc067840a2ac6d2f04b7ad"
    end

    resource("testdata").stage do
      assert_match "[x] DL3006:", shell_output("#{bin}/hadolintw Dockerfile.example --error DL3006", 1)
    end
  end
end
