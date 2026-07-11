# matchDesign in sesame

Notes on the optional `match_design` parameter in `report.Rmd`, which calls `sesame::matchDesign()`.

## What it is

`matchDesign()` in **sesame** normalizes **Infinium I (Type I)** probe betas so their distribution better matches **Infinium II (Type II)** probes. It operates on a per-sample `SigDF` (signal object), before `getBetas()`.

**Method:** 2-state quantile normalization on methylated and unmethylated modes separately; falls back to 1-mode normalization if the modes are too close (`min_dbeta = 0.3`, default).

**In this pipeline:** Controlled by `match_design` in `report.Rmd`. When `true`, it is applied after `openSesame(..., prep = "QCDPB")` and before beta extraction:

```r
if (params$match_design) {
  sdfs_pp = lapply(sdfs_pp, matchDesign)
}
```

## The problem it addresses

Illumina methylation arrays mix two probe chemistries. Type I probes often show **tail inflation** — betas pushed toward **0 and 1** more than Type II, due to technical effects (dye bias, background, two-bead design). That can create artificial structure in QC and exploratory plots and bias downstream analysis.

### What is an inflated tail?

Beta values range from 0 (unmethylated) to 1 (fully methylated). Healthy tissue often shows a bimodal pattern with peaks near 0 and 1. The **tails** are the regions close to those extremes.

**Tail inflation** means more probes than expected sit at those extremes — betas are **pushed outward** toward 0 or 1 compared with Infinium II probes on the same sample. For example, a CpG that might read β ≈ 0.85 on Type II could read β ≈ 0.95 on Type I due to chemistry artifacts, not biology.

`matchDesign()` applies quantile normalization so Type I distributions align with Type II — effectively **deflating** those inflated tails.

## Why sesame does not make it the default

Default `openSesame()` uses **`prep = "QCDPB"`**:

| Code | Step |
|------|------|
| **Q** | Quality mask (mapping, SNPs, etc.) |
| **C** | Infinium-I channel inference |
| **D** | Dye bias correction (nonlinear) |
| **P** | pOOBAH detection masking |
| **B** | NOOB background subtraction |

`matchDesign` maps to code **`M`** in `prepSesame`. The [sesame vignette](https://bioconductor.org/packages/release/bioc/vignettes/sesame/inst/doc/sesame.html) states that functions that normalize β distributions (`M`) should run **last, if needed at all**.

The [SeSAMe supplemental vignette](https://zhou-lab.github.io/sesame/dev/supplemental.html) is explicit:

> *"We do not recommend the use of this (or any such methods) for all data unless your data is known to be relatively well-behaving in methylation distribution, for protection of real biological signal."*

Reasons it stays optional:

1. **Risk to biology** — Forcing I/II distributions to match can remove real signal (e.g. global hypomethylation in tumors).
2. **Partial fix already in the default** — Nonlinear dye bias correction (`D` in `QCDPB`) already adjusts some Type-I effects.
3. **Strong assumption** — I and II probes are assumed to have similar methylated and unmethylated modes; that is not always true.
4. **Context-dependent** — Effects depend on sample type and platform; a universal default is not appropriate.

## When to use it

**Enable** (`match_design: true`) when QC shows clear Type I tail inflation after standard preprocessing, e.g.:

```r
sesameQC_plotBetaByDesign(sdf)                 # before
sesameQC_plotBetaByDesign(matchDesign(sdf))    # after
```

**Keep off** when biology may legitimately differ between probe types, or when distributions already look reasonable after `QCDPB`.

## Takeaway

`matchDesign` is a **probe-chemistry harmonization** step, not batch correction. This pipeline exposes it as **opt-in** via `match_design`, consistent with sesame's approach: fix signals with `QCDPB` first, and only apply distribution matching when QC justifies it.

## References

- [sesame package manual — `matchDesign`](https://bioc.r-universe.dev/sesame/doc/manual.html)
- [sesame vignette — preprocessing](https://bioconductor.org/packages/release/bioc/vignettes/sesame/inst/doc/sesame.html)
- [SeSAMe supplemental vignette — Match Infinium-I/II](https://zhou-lab.github.io/sesame/dev/supplemental.html)
