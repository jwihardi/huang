# Contributing

Anyone is free to open pull requests to add packages they would like to see in
Huang. Do not submit software that you created or personally maintain.

Keep each pull request focused on one package or one logical repository change.

## Commit messages

Follow Gentoo's
[official commit-message guidelines](https://devmanual.gentoo.org/ebuild-maintenance/git/index.html).
Huang does not require cryptographic commit signing or `Signed-off-by` trailers.

## LLM-assisted contributions

Using an LLM to help write or review an ebuild is allowed. Contributors must
personally review and understand everything they submit.

The contributor remains responsible for the correctness, security, licensing,
dependencies, and maintainability of the package. Do not submit generated
changes that you cannot explain or maintain during review.

## Validation

Before opening a pull request, run the following commands from the repository
root:

```bash
pkgdev manifest category/package
pkgcheck scan --net category/package
pkgcheck scan --commits
git diff --check
```

Test the package through Portage:

```bash
sudo emerge --ask --verbose =category/package-version::huang
```

Test relevant USE flag combinations when applicable. Explain any warnings,
skipped tests, network-dependent checks, or other validation limitations in the
pull request description.
