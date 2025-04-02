cask "font-cascadia-code-nf" do
  version "3.3.0"
  sha256 "045c12b3302989c291f92d0ba3bfcb6d37f633711fb8f22d822acb923bff0c94"

  # https://docs.brew.sh/Cask-Cookbook#when-url-and-homepage-domains-differ-add-verified
  url "https://github.com/ryanoasis/nerd-fonts/releases/download/v#{version}/CascadiaCode.zip",
      verified: "github.com/ryanoasis/nerd-fonts/releases/download/"
  name "font-cascadia-code-nf"
  homepage "https://www.nerdfonts.com/"

  # https://docs.brew.sh/Brew-Livecheck
  livecheck do
    url :url
    strategy :github_latest
  end

  font "CaskaydiaCoveNerdFont-Bold.ttf"
  font "CaskaydiaCoveNerdFont-BoldItalic.ttf"
  font "CaskaydiaCoveNerdFont-SemiLightItalic.ttf"
  font "CaskaydiaCoveNerdFont-SemiLight.ttf"
  font "CaskaydiaCoveNerdFont-Italic.ttf"
  font "CaskaydiaCoveNerdFont-Regular.ttf"
  font "CaskaydiaCoveNerdFont-LightItalic.ttf"
  font "CaskaydiaCoveNerdFont-Light.ttf"
  font "CaskaydiaCoveNerdFont-SemiBoldItalic.ttf"
  font "CaskaydiaCoveNerdFont-SemiBold.ttf"
  font "CaskaydiaCoveNerdFont-ExtraLight.ttf"
  font "CaskaydiaCoveNerdFont-ExtraLightItalic.ttf"
end
