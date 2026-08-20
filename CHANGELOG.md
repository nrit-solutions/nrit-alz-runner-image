# Changelog

Every release of the `ghcr.io/nrit-solutions/alz-runner` image. The version
is the image tag; the digest printed by the release run is the value the
bootstrap pins. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the image
follows Semantic Versioning on its contract: tool or runner bumps are minor,
CVE rebuilds are patch, removing or renaming a baked tool is major.

## [Unreleased]

## [1.0.0] - 2026-08-20

### Added

- First published image, replacing the per-customer ACR build tasks. Contents
  match what those tasks built: the vendored AVM `github-runner-aca` base at
  ref `9b4c292` with the GitHub Actions runner (now pinned, 2.336.0), az CLI,
  plus the NRIT tools layer with checkov 3.3.8 and conftest 0.68.2 for the
  nrit-tf-pr-ops hook gates.
- Release pipeline: trivy scan failing on fixed CRITICAL findings, cosign
  keyless signature, and an SPDX SBOM on every release digest, attached as
  a GitHub attestation (`gh attestation verify`; the SBOM is too large for
  the public Rekor log).

### Known waived findings

- CVE-2026-59873 (node-tar gzip-bomb DoS) in the npm bundled inside the
  GitHub Actions runner. No runner release ships the fixed tar yet; waived
  in `.trivyignore` with the re-check condition documented there.
