# Reproduce the two final fourth-corner GLLVMs from their model-ready CSVs.
# Working directory: repository root.
# Install once if necessary: install.packages("gllvm")
if (!requireNamespace("gllvm", quietly = TRUE)) {
  stop("Install the 'gllvm' package first: install.packages('gllvm')")
}

dir.create("outputs", showWarnings = FALSE)

read_model_data <- function(path, needed_trait) {
  if (!file.exists(path)) stop("Missing model input: ", path)
  d <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  required <- c("id", "sp", "site", "y", "spring_temp", "summer_temp",
                "prev_late_summer_temp", "artificial", "cropland",
                "forest", "forest_edge", "latitude", "longitude",
                "habitat_width", needed_trait)
  missing <- setdiff(required, names(d))
  if (length(missing)) stop(path, ": missing: ", paste(missing, collapse = ", "))
  if (anyNA(d[required])) stop(path, " contains missing model values")
  if (anyDuplicated(d[c("id", "sp")])) stop(path, " has duplicate id/sp pairs")
  d$id <- as.integer(d$id)
  d$sp <- as.integer(d$sp)
  if (anyNA(d$id) || anyNA(d$sp)) stop(path, ": invalid id/sp values")
  d$site <- factor(d$site)
  d <- d[order(d$sp, d$id), , drop = FALSE]
  obs <- unique(d[c("id", "site")])
  obs <- obs[order(obs$id), , drop = FALSE]
  if (nrow(d) != nrow(obs) * length(unique(d$sp))) {
    stop(path, ": incomplete observation/species grid")
  }
  if (!all(vapply(split(d$site, d$id), function(x) length(unique(x)) == 1L, logical(1)))) {
    stop(path, ": an observation maps to multiple sites")
  }
  list(data = d, design = data.frame(site = factor(obs$site)))
}

# Final bumblebee model: fit_bb_random_final in the original analysis.
bb <- read_model_data("gllvm_bumblebee_model_input.csv", "habitat_width")
set.seed(123)
fit_bb_random_final <- gllvm::gllvm(
  data = bb$data,
  formula = y ~ spring_temp + summer_temp + prev_late_summer_temp +
    artificial + cropland + forest + forest_edge + latitude + longitude +
    artificial:habitat_width + cropland:habitat_width,
  family = "negative.binomial",
  num.lv = 1,
  studyDesign = bb$design,
  row.eff = ~(1 | site),
  randomX = ~ artificial + cropland + forest,
  seed = 123,
  control.start = list(n.init = 3, jitter.var = 0.01)
)
saveRDS(fit_bb_random_final, "outputs/final_bumblebee_gllvm.rds")
capture.output(summary(fit_bb_random_final),
               file = "outputs/final_bumblebee_summary.txt")
message("Bumblebee convergence: ", fit_bb_random_final$convergence,
        "; AIC: ", AIC(fit_bb_random_final))

# Final butterfly model: fit_bf_full_STI_s3 -> fit_bf_working -> fit_bf_final.
bf <- read_model_data("gllvm_butterfly_model_input.csv", "STI")
set.seed(987)
fit_bf_final <- gllvm::gllvm(
  data = bf$data,
  formula = y ~ spring_temp + summer_temp + prev_late_summer_temp +
    artificial + cropland + forest + forest_edge + latitude + longitude +
    spring_temp:STI + summer_temp:STI + prev_late_summer_temp:STI +
    artificial:habitat_width,
  family = "negative.binomial",
  num.lv = 1,
  studyDesign = bf$design,
  row.eff = ~(1 | site),
  randomX = ~ spring_temp + summer_temp + prev_late_summer_temp +
    artificial + cropland + forest,
  seed = 987,
  control.start = list(n.init = 10, jitter.var = 0.05)
)
saveRDS(fit_bf_final, "outputs/final_butterfly_gllvm.rds")
capture.output(summary(fit_bf_final),
               file = "outputs/final_butterfly_summary.txt")
message("Butterfly convergence: ", fit_bf_final$convergence,
        "; AIC: ", AIC(fit_bf_final))

writeLines(capture.output(sessionInfo()), "outputs/sessionInfo.txt")
message("Both final models saved to outputs/")
