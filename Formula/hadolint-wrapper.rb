class HadolintWrapper < Formula
  include Language::Python::Virtualenv

  desc "Pretty output for hadolint"
  homepage "https://github.com/mikybars/hadolint-wrapper"
  url "https://github.com/mikybars/hadolint-wrapper/releases/download/v1.2.1/hadolintw-1.2.1-brew.tar.gz"
  sha256 "62ade57dea14d815ce87f99d65aaa19df7df1bd8d01c0d0b39e43c3b8c0167f0"
  license "MIT"

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
    system "false"
  end
end
