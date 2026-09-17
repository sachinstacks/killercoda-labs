# Done

You produced an SBOM in two formats, scanned it without touching the image, turned a few hundred matches into a
gate on the findings a rebuild can remove, and confirmed that scanning the SBOM and scanning the image give the
same answer.

## The SBOM ages well, the image does not

Re-run the SBOM scan in a week. The file has not changed; the database has, and the counts will be higher. That is
not a bug. It is the reason to store the SBOM next to the release artifact and scan it on a schedule: an image that
passed the gate at build time can fail it a week later without a single byte changing, and the scheduled scan of
stored SBOMs is how you find out before someone else does.

Attach SBOMs to releases as OCI artifacts alongside the image (`cosign attach sbom`, or the registry's referrers
API), or at least as CI artifacts with the same retention as the image. An SBOM you cannot find during an incident
has the same value as one you never generated.

## Cleanup

This environment is discarded when you leave it. On your own machine the cache directory holds the multi-gigabyte
database; remove it with `rm -rf ~/labs/sbom` (or `~/.cache/grype`).

## Further reading

Read the full engineering notes and explanation on sachinchaurasiya.com:
[Generate an SBOM with Syft and Scan It with Grype](https://sachinchaurasiya.com/labs/generate-an-sbom-with-syft-and-scan-it-with-grype).
