## Summary

<!-- Describe what this changes and why it belongs in Huang. -->

Package: `category/package`

Upstream: <!-- Link to the upstream project. -->

## Change type

- [ ] New package
- [ ] Version update
- [ ] Ebuild fix or maintenance
- [ ] Package removal
- [ ] Repository metadata or documentation

## Contributor checklist

- [ ] This pull request contains one package or one logical repository change.
- [ ] For a package contribution, I did not create or personally maintain the upstream software.
- [ ] My commits follow [Gentoo's commit-message guidelines](https://devmanual.gentoo.org/ebuild-maintenance/git/index.html).
- [ ] If I used an LLM, I personally reviewed and understand every submitted change.
- [ ] I can explain and maintain the submitted changes during review.

## Validation

- [ ] I generated or updated the Manifest with `pkgdev manifest category/package` when applicable.
- [ ] I ran `pkgcheck scan --net category/package`.
- [ ] I ran `pkgcheck scan --commits`.
- [ ] I ran `git diff --check`.
- [ ] I successfully installed the package through Portage.
- [ ] I tested relevant USE flag combinations, or the package has none.
- [ ] I documented all warnings, skipped tests, network-dependent checks, and other validation limitations below.

## Validation notes

<!-- Include relevant results, warnings, skipped checks, or limitations. Write "None" when everything passed. -->
