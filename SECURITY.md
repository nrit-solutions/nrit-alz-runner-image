# Security

## Reporting a vulnerability

Report a vulnerability in this repository privately, through its
**Security** tab: choose **Report a vulnerability**. Do not open a public
issue or pull request for it.

Licensed operators can also report through the support channel named in
their license agreement.

Include the image tag or digest, the affected file, package or tool, the
steps to reproduce and the impact you expect. Leave out real credentials,
tokens and runner logs from a customer tenant.

## Scope

- The image definition: the `Dockerfile`, `entrypoint.sh` and the token
  scripts
- The packages and tools baked into the published
  `ghcr.io/nrit-solutions/alz-runner` image
- The build, scan, sign and release workflows under `.github/workflows/`

Vulnerabilities in the GitHub Actions runner itself or in an upstream base
image belong with their maintainers. Vulnerabilities in the PR-ops engine
belong with the engine: report them on `nrit-solutions/tfpr`. Problems in
how a tenant deploys the runners belong with `nrit-solutions/nrit-alz-bootstrap`.

## What happens next

The report is acknowledged within one business day. A vulnerability rated
critical is fixed within ten business days of confirming it, as a patch
release of the image. Other fixes ship in the next release.
