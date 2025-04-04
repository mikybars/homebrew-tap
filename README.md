# Quickstart guide to publishing your own brew packages

These notes intend to be a notebook-style of guide and are inspired by [Homebrew tap with bottles uploaded to GitHub Releases
](https://brew.sh/2020/11/18/homebrew-tap-with-bottles-uploaded-to-github-releases/)

<a href="https://app.warp.dev/drive/folder/Homebrew-ss5WmBfhmXcHGl5fLxt2Mp">
  <img src="https://github.com/user-attachments/assets/be2cbf2e-84ff-40f7-b048-993af4db532c" alt="Follow tutorial in Warp">
</a>

## Prerequisites

- Git
- [Homebrew](https://brew.sh/)
- [GitHub CLI](https://cli.github.com/)

## 1. Create a new tap (only once)

If this is your first time *brewing*, first bootstrap the new tap locally:

```bash
brew tap-new mikybars/tap
```

Then share it on GitHub:

```bash
cd $(brew --repository mikybars/tap)
gh repo create homebrew-tap --source=. --public --push
```

## 2. Create a new formula in the tap

```bash
brew create \
    --tap=mikybars/tap \
    --cask \     # template for casks (e.g. fonts)
    --python \   # create from template (go, node, ruby)
    --set-name hadolint-wrapper \
    https://github.com/mikybars/hadolint-wrapper/releases/download/v1.2.1/hadolintw-1.2.1-brew.tar.gz
```

## 3. Edit the new formula

```bash
# not really necessary as the `create` command will already leave you in edit mode
brew edit mikybars/tap/hadolint-wrapper
```

Don't forget to remove all the generated comments and fill in the required fields. Take a look at the already existing
formulae in this repo for inspiration.

## 4. [Write some tests](https://docs.brew.sh/Formula-Cookbook#add-a-test-to-the-formula) 🙏

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

## 5. Validate your formula

Run the same checks and validations as the CI/CD before pushing for a shorter feedback loop 😌

```bash
brew audit hadolint-wrapper --online --new
```

## 6. Create a new branch and submit a PR with the new formula

```bash
git switch --create hadolint-wrapper
git add .
git commit --message "hadolint-wrapper 1.2.1 (new formula)"
gh pr create --fill
```

A new [workflow](https://github.com/mikybars/homebrew-tap/actions/workflows/tests.yml) will then be triggered in GitHub
that will build [bottles](https://docs.brew.sh/Bottles) (Homebrew lingo for binary packages) for your [OS](https://github.com/actions/runner-images/tree/main?tab=readme-ov-file#available-images). Wait until all the jobs are finished:

```bash
gh run watch
```

Watch for any errors and push as new commits as necessary to fix them (e.g. syntax errors, style issues, failing tests).

## 7. Publish the formula

> [!WARNING]
> First check if the previous workflow yielded any bottles (some formulae like fonts do not need them) by running `gh run view` and looking for any ARTIFACTS section. It there aren't any then you can merge as usual and skip the rest of the section:
>
> ```bash
> gh pr merge --squash --delete-branch
> ```

> [!NOTE]
> This next step involves writing some commits in the repository with the outcome of the previous workflows.
>
> Previously, GitHub Actions would get a `GITHUB_TOKEN` with both read/write permissions by default whenever Actions is enabled on a repository... [but not anymore](https://github.blog/changelog/2023-02-02-github-actions-updating-the-default-github_token-permissions-to-read-only/).
>
> So the recommended action is to go to the Actions permissions setting (Settings -> Actions -> General -> Workflow permissions) and check the `Read and write permissions` option.

Start by labeling the PR to trigger the [publish](https://github.com/mikybars/homebrew-tap/actions/workflows/publish.yml) workflow:

```bash
gh label create --force pr-pull
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

There should be a `bottle` declaration in the diff:

```ruby
bottle do
  root_url "https://github.com/mikybars/homebrew-tap/releases/download/hadolint-wrapper-1.2.1"
  sha256 cellar: :any_skip_relocation, ventura:      "60c101[...]1bbcd"
  sha256 cellar: :any_skip_relocation, x86_64_linux: "cafe49[...]b619a"
end
```

## Troubleshooting

> My architecture is not yet supported by any of the [GitHub Actions runners available](https://github.com/actions/runner-images/tree/main?tab=readme-ov-file#available-images) and so no bottles are built that I can use.

It turns out that bottles can also be built locally:

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

Upload the tarball generated to the last release and don't forget to include the modified `bottle` block in your formula:

> [!WARNING]
> Remember to rename the file to remove the duplicate dash '-'
> ```bash
> mv hadolint-wrapper{--,-}1.2.1.arm64_ventura.bottle.tar.gz
> ```

```bash
bottle=$(ls *.bottle.tar.gz)
releaseName=$(gh release view --json tagName --template '{{.tagName}}')
gh release upload $releaseName $bottle

# and then after adding the new bottle block...
git commit --all -m "add hadolint-wrapper bottle for arm64_ventura [skip ci]"
git push
```

## Resources

- <https://til.simonwillison.net/homebrew/packaging-python-cli-for-homebrew> 🩷
- <https://docs.brew.sh/Python-for-Formula-Authors>
- <https://docs.brew.sh/Formula-Cookbook#add-a-test-to-the-formula>
- <https://brew.sh/2020/11/18/homebrew-tap-with-bottles-uploaded-to-github-releases/>

