# Quickstart guide to publishing your brew packages

## ⚒️ Required tools

- [Homebrew](https://brew.sh/)
- Git
- [GitHub CLI](https://cli.github.com/)

## 1. Create a tap

```bash
brew tap-new mikybars/tap
```

## 2. Create a repo in GitHub

```bash
cd $(brew --repository mikybars/tap)
gh repo create homebrew-tap --source=. --public --push
```

## 3. Create a formula in the tap

```bash
brew create \
    --tap=mikybars/tap \
    --python \
    --set-name hadolint-wrapper \
    https://github.com/mikybars/hadolint-wrapper/releases/download/v1.2.1/hadolintw-1.2.1-brew.tar.gz
```

## 4. Edit the new formula

```bash
# not really necessary as the `create` command already opens the editor
brew edit mikybars/tap/hadolint-wrapper
```

Don't forget to remove all the generated comments and fill in the required fields:

```ruby
class HadolintWrapper < Formula
  include Language::Python::Virtualenv

  desc "Dockerfile linter, validate inline bash, written in Haskell"
  homepage "https://github.com/hadolint/hadolint"
  url "https://github.com/mikybars/hadolint-wrapper/releases/download/v1.2.1/hadolintw-1.2.1-brew.tar.gz"
  sha256 "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda190b208a8b11d0f600b"
  license "GPL"

  depends_on "python"

  resource "click" do
    url "https://files.pythonhosted.org/[...]/click-8.1.7.tar.gz"
    sha256 "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda190b208a8b11d0f600b"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system "true"
  end
end
```

## 5. Write some test(s) 🙏

```ruby
test do
  resource("testdata") do
    url "https://raw.githubusercontent.com/mikybars/[...]/Dockerfile.example"
    sha256 "495ade[...]04b7ad"
  end

  resource("testdata").stage do
    assert_match "[x] DL3006:", shell_output("#{bin}/hadolintw Dockerfile.example --error DL3006", 1)
  end
end
```

## 6. Create a new branch and submit a PR with the new formula

```bash
git switch --create hadolint-wrapper
git add .
git commit --message "hadolint-wrapper 1.2.1 (new formula)"
git push
gh pr create --fill
```

A new workflow will then be triggered in GitHub that will build [bottles](https://docs.brew.sh/Bottles) for different OSs. Wait until all the jobs are finished:

```bash
gh run watch
```

Watch for any errors and push as new commits as necessary to fix them (e.g. syntax errors, style issues, failing tests).

## 7. Upload built bottles

### 7.1 Grant write permissions to GitHub Actions

This next step involves writing some commits in the repository with the outcome of the previous workflows.

Previously, GitHub Actions would get a `GITHUB_TOKEN` with both read/write permissions by default whenever Actions is enabled on a repository... [but not anymore](https://github.blog/changelog/2023-02-02-github-actions-updating-the-default-github_token-permissions-to-read-only/).

So the recommended action is to go to the Actions permissions setting (Settings -> Actions -> General -> Workflow permissions) and check the `Read and write permissions` option.

### 7.2 Trigger the `publish` workflow

```bash
gh label create pr-pull
gh pr edit --add-label pr-pull
```

Then wait again for the results:

```bash
gh run watch
```

If everything went well then there should be four things to check:

1. The PR is now closed (not merged)

   ```bash
   gh pr view
   ```

2. The commits in your PR are now back in `main`

   ```bash
   git switch main
   git pull
   git log
   ```

3. A new release was created including the built bottles as assets

   ```bash
   gh release view
   ```

4. A new commit was pushed to `main` updating the formula

```bash
git show
```

```ruby
bottle do
  root_url "https://github.com/mikybars/homebrew-tap/releases/download/hadolint-wrapper-1.2.1"
  sha256 cellar: :any_skip_relocation, ventura:      "60c101[...]1bbcd"
  sha256 cellar: :any_skip_relocation, x86_64_linux: "cafe49[...]b619a"
end
```

## 8. Build bottles for your own architecture (bonus 🌟)

This last step is just for when your architecture is fairly new (Apple Silicon M1/arm64) and there is no supporting runner available in GitHub yet for building bottles for it 👀 github/roadmap#528

```bash
brew install --build-bottle hadolint-wrapper
brew bottle hadolint-wrapper
```

The output from the above will be the path to the built bottle file and the block you must add to the formula:

```bash
./hadolint-wrapper--1.2.1.arm64_ventura.bottle.tar.gz
bottle do
   rebuild 1
   sha256 cellar: :any_skip_relocation, arm64_ventura: "1771c2442f6c0cb052d7bb9f796263170698948b25869ff85749161296ce400a"
end
```

```bash
# !! rememeber to rename the file to remove the duplicate dash '-'
mv hadolint-wrapper{--,-}1.2.1.arm64_ventura.bottle.tar.gz
gh release view --json tagName --template '{{.tagName}}'
# --> hadolint-wrapper-1.2.1
gh release upload \
  hadolint-wrapper-1.2.1 \
  hadolint-wrapper-1.2.1.arm64_ventura.bottle.tar.gz

# and then after adding the new bottle block...
git commit --all -m "add hadolint-wrapper bottle for arm64_ventura"
git push
```

# Resources

- <https://til.simonwillison.net/homebrew/packaging-python-cli-for-homebrew> 🩷
- <https://docs.brew.sh/Python-for-Formula-Authors>
- <https://docs.brew.sh/Formula-Cookbook#add-a-test-to-the-formula>
- <https://brew.sh/2020/11/18/homebrew-tap-with-bottles-uploaded-to-github-releases/>

