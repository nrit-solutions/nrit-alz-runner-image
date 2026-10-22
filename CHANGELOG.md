# Changelog

Every release of the `ghcr.io/nrit-solutions/alz-runner` image. The version
is the image tag; the digest printed by the release run is the value the
bootstrap pins. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the image
follows Semantic Versioning on its contract: tool or runner bumps are minor,
CVE rebuilds are patch, removing or renaming a baked tool is major.

## [Unreleased]

## [2.0.1] - 2026-10-22

### Security

- The az CLI's bundled Python gets certifi 2026.10.19 or later and pip
  26.2.2 or later. Its own certifi 2024.7.4 and the certifi 2026.6.17 that
  its pip 26.2.1 vendors trust emSign root CAs whose intermediate keys were
  compromised (GHSA-6q48-6c7w-9gw2, critical), and the release scan failed
  every build on them. Closes #12.

## [2.0.0] - 2026-10-12

### Changed

- **Breaking:** jobs run as the `runner` user (uid 1001) instead of root, and
  `sudo` is no longer installed. A probe on 2026-10-12 confirmed that a job
  step running as root could read the runners App private key from the
  entrypoint's environment (`/proc/1/environ`); a non-root job cannot. Any
  workflow step that relied on root or `sudo` on the self-hosted runner
  breaks. Nothing in the engine, the gate scripts or the consumer callers
  did. `RUN_AS_ROOT=true` restores the old behaviour for a single
  deployment and is not recommended. Closes #6.
- `gosu` added so the entrypoint can drop privileges, as the upstream
  entrypoint already expected.

### Security

- PyJWT lifted to 2.14.0 or later inside the az CLI's bundled Python
  (CVE-2026-102268, critical). The release scan had failed on it since
  2026-10-08. Drop the step once an az release ships the fix.
- CI and release free the hosted runner's disk before the trivy scan; the
  image export no longer runs out of space.

## [1.0.0] - 2026-08-20

### Added

- First published image, replacing the per-customer ACR build tasks. Contents
  match what those tasks built: the vendored AVM `github-runner-aca` base at
  ref `9b4c292` with the GitHub Actions runner (now pinned, 2.336.0), az CLI,
  plus the NRIT tools layer with checkov 3.3.8 and conftest 0.68.2 for the
  nrit-tf-pr-ops hook gates.
- Release pipeline: trivy scan failing on fixed CRITICAL findings, cosign
  keyless signature on the image digest, and the full SPDX SBOM published
  as a cosign-signed asset on the GitHub release (the document is too large
  for the public Rekor log and for GitHub attestations, so sign-blob
  records its hash in the transparency log instead).

### Known waived findings

- CVE-2026-59873 (node-tar gzip-bomb DoS) in the npm bundled inside the
  GitHub Actions runner. No runner release ships the fixed tar yet; waived
  in `.trivyignore` with the re-check condition documented there.
