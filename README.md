# Trait–environment relationships in Norwegian bumblebees and butterflies

Minimal reproducibility repository for the **two final fourth-corner generalized linear latent variable models (GLLVMs)** used to investigate associations between species traits, climate, landscape characteristics, and abundance in Norwegian bumblebees and butterflies.

The models are **separate for bumblebees and butterflies**, which have different species and trait matrices.

## Files

| File | Purpose |
| --- | --- |
| `fit_final_gllvm_models.R` | Standalone script that imports both model-ready CSVs and fits the final models. |
| `gllvm_bumblebee_model_input.csv` | **bumblebee model inputs only. |
| `gllvm_butterfly_model_input.csv` | **butterfly model inputs only. |
| `CITATION.cff` | Repository citation metadata. |
| `.gitignore` | Excludes generated model results and temporary R files. |

## Reproduce the models

Install R and the `gllvm` package. From the repository directory:

```r
install.packages("gllvm")  # only once
source("02_fit_final_gllvm_models.R")
```

The script writes fitted models (`.rds`), summaries (`.txt`), and an R session record into `outputs/`. No access to NINA databases, spatial services, Excel trait workbooks, or private model `.rds` files is required for this step.

## Final specifications

Both models use a negative binomial family, one latent variable (`num.lv = 1`), a site random intercept (`row.eff = ~(1 | site)`), and species-specific random slopes (`randomX`). Environmental predictors are spring, summer and previous late-summer temperature anomalies, artificial land, cropland, forest, forest edge, latitude and longitude. Model input predictors are standardized as in the original analysis; **do not standardize them again**.

**Bumblebees — `fit_bb_random_final`**

- Fixed trait interactions: artificial land × habitat niche width; cropland × habitat niche width.
- Species-specific random slopes: artificial land, cropland and forest.
- Original fitting settings: seed 123; `n.init = 3`; `jitter.var = 0.01`.

**Butterflies — `fit_bf_final`**

- Fixed trait interactions: spring, summer and previous late-summer temperature × species temperature index (STI); artificial land × habitat niche width.
- Species-specific random slopes: the three temperature variables, artificial land, cropland and forest.
- Original final refit: `fit_bf_full_STI_s3` (seed 987; `n.init = 10`; `jitter.var = 0.05`), subsequently assigned to `fit_bf_final`.

## Input data dictionary

Each CSV has **one row per sampled locality-year × retained species** (long format). Species with fewer than 10 occupied locality-years and those with missing primary trait data were already excluded in the original preparation. Locality-years with zero total abundance across retained species were also excluded. All these decisions take place **before export**.

| Column | Meaning |
| --- | --- |
| `id` | Integer observation/community ID from the original long-format dataset. |
| `sp` | Integer species index within its taxon dataset. |
| `site` | Locality grouping for the site random effect. |
| `y` | Species-specific abundance count. |
| `spring_temp` | Standardized spring temperature anomaly. |
| `summer_temp` | Standardized summer temperature anomaly. |
| `prev_late_summer_temp` | Standardized previous late-summer temperature anomaly. |
| `artificial` | Standardized area of artificial land within a 3 km buffer. |
| `cropland` | Standardized cropland within a 3 km buffer. |
| `forest` | Standardized forest within a 3 km buffer. |
| `forest_edge` | Standardized forest-edge length within a 3 km buffer. |
| `latitude`, `longitude` | Standardized geographical controls. |
| `habitat_width` | Standardized species habitat-niche width. |
| `STI` | Standardized species temperature index (butterflies only). |

The release files contain only the variables used by each final model. No coordinates in original geographic units or original taxon trait workbook are required to reproduce the fits. However, locality identifiers, species-level counts, and covariates should still be reviewed for data-sharing restrictions before publication.

## Notes on reproducibility

- The public fitting script **refits** the final models; it does not require pre-saved fitted models.
- GLLVM optimization can be computationally expensive and can depend on the installed `gllvm` version and numerical libraries. Inspect convergence and the saved summaries and compare them with the original manuscript results.
- This stripped-down package reproduces the **final statistical models**, not all figures or exploratory/model-selection analyses.

## Citation and licensing

Please cite the associated manuscript and this repository when using the code or model inputs.
