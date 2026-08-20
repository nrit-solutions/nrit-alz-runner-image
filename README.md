# nrit-alz-runner-image

The self-hosted runner image for the NRIT ALZ platform, built once here and
published as a public, signed, SemVer-tagged image:

```
ghcr.io/nrit-solutions/alz-runner
```

Customers do not build this image. The bootstrap imports the pinned digest
into an in-tenant ACR with `az acr import` (server-side, anonymous, no
tokens), and the AVM runner module points the Container App job at that
registry. One artifact, scanned and signed once, patched everywhere by a
version bump.

## What is in the image

The upstream AVM `github-runner-aca` image plus one tools layer:

| Layer | Contents |
|---|---|
| Base | `mcr.microsoft.com/azure-powershell:ubuntu-24.04`, az CLI, the GitHub Actions runner (pinned via `GH_RUNNER_VERSION`), helper scripts |
| NRIT tools | `checkov` and `conftest`, pinned by build args, for the nrit-tf-pr-ops policy and scan hook gates |

`checkov` is Python-only with no static binary, which is why it lives in the
image; `infracost` is a static binary the workflow installs per run and is
deliberately not baked. The pins are `ARG` defaults at the top of each layer
in the `Dockerfile`; bumping one is a normal PR plus a release.

## Provenance

Everything above the NRIT markers in the `Dockerfile` is vendored from
`Azure/avm-container-images-cicd-agents-and-runners` at ref `9b4c292` (the
`github-runner-aca` folder), the same source the AVM runner module builds by
default. The four helper scripts (`install_actions.sh`, `token.sh`,
`entrypoint.sh`, `app_token.sh`) are copied verbatim. Two NRIT changes on
top of upstream:

- an `ARG GH_RUNNER_VERSION` pin, because upstream downloads the latest
  runner at build time and a tagged image must not float,
- the tools layer described above.

To pick up a newer upstream base: re-copy the upstream files at a new ref,
re-apply the marked NRIT blocks, update the ref in this README and the
`Dockerfile` comments, and release.

## Releasing

Tag `vX.Y.Z` on main. The release workflow builds the image, fails on
CRITICAL vulnerabilities (trivy, fixed ones only), pushes `X.Y.Z` and
`latest`, signs the digest with cosign (keyless, GitHub OIDC), and attaches
an SPDX SBOM attestation. The run's last step prints the digest; that digest
is what the bootstrap pins. Record every release in `CHANGELOG.md`
(Keep a Changelog).

Versioning is SemVer on the image contract: a tool or runner bump is minor,
a rebuild for CVEs is patch, removing or renaming a baked tool is major.

## Verifying a release

```sh
cosign verify ghcr.io/nrit-solutions/alz-runner:<version> \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/nrit-solutions/nrit-alz-runner-image/'

cosign verify-blob --bundle sbom.spdx.json.bundle \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/nrit-solutions/nrit-alz-runner-image/' \
  sbom.spdx.json
```

The SBOM and its signature bundle are assets on the GitHub release for the
tag, not an in-registry attestation: the full SPDX document is over 16 MB,
which both the public Rekor log and GitHub attestations reject as a payload.
`sign-blob` records only the hash in the transparency log, so the SBOM stays
complete and still verifies keyless.

## Consuming

Per customer, the bootstrap imports the digest into the in-tenant ACR:

```sh
az acr import --name <acr> \
  --source ghcr.io/nrit-solutions/alz-runner@sha256:<digest> \
  --image alz-runner:<version>
```

The import is anonymous (the package is public) and preserves the digest, so
the signature and SBOM verify against the imported copy too. Sovereignty
customers who must build from source keep the opt-in ACR build-task path in
`nrit-alz-bootstrap/runner-image/`.
