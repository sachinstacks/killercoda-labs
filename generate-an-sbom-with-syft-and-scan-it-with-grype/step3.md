# A gate that fails on what you can fix

`--only-fixed` is Grype's equivalent of Trivy's `--ignore-unfixed`; `--fail-on high` makes the process exit
non-zero when any remaining finding is High or above. Record both exit codes in `gate.txt`:

Run the two gates one after the other (Grype's progress display takes over the terminal while it runs, so each
is its own command):

```plain
cd /root/labs/sbom && grype sbom:./py311.cdx.json --only-fixed --fail-on critical -q; echo "critical=$?" | tee gate.txt
```{{exec}}

```plain
grype sbom:./py311.cdx.json --only-fixed --fail-on high -q; echo "high=$?" | tee -a gate.txt
```{{exec}}

```plain
cat gate.txt
```{{exec}}

In the reference run the SBOM passed at `critical` (`exit=0`) and failed at `high` (`exit=2`), and the table Grype
printed told you exactly what a rebuild needs to change: a newer Python image, `pip install --upgrade` for two
packages, and a Debian package update. Which threshold you start with is a policy decision; the mechanism is the
same either way.

**CHECK** re-runs both gates against your SBOM and compares the real exit codes with the ones in `gate.txt`.

<details><summary>Solution</summary>

```plain
cd /root/labs/sbom && grype sbom:./py311.cdx.json --only-fixed --fail-on critical -q >/dev/null 2>&1; echo "critical=$?" > gate.txt; grype sbom:./py311.cdx.json --only-fixed --fail-on high -q >/dev/null 2>&1; echo "high=$?" >> gate.txt; cat gate.txt
```{{exec}}

</details>
