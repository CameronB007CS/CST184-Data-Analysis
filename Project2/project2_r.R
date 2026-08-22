# Project 2: Sea Level Rise – Tuvalu (Funafuti)
# Steps 8–12 in R

# install packages if needed
# install.packages(c("ggplot2", "reshape2", "forecast", "tseries"))

library(ggplot2)
library(reshape2)

# ─────────────────────────────────────────────
# LOAD & PREPARE DATA
# ─────────────────────────────────────────────

raw <- read.csv("732-012_meantrend.csv", skip = 6,
                header = FALSE,
                col.names = c("Year","Month","Monthly_MSL","Linear_Trend","High_Conf","Low_Conf","extra"))

raw <- raw[!is.na(raw$Monthly_MSL), ]
raw$Year <- as.integer(raw$Year)
raw$Month <- as.integer(raw$Month)
raw$Monthly_MSL <- as.numeric(raw$Monthly_MSL)

baseline_1993 <- mean(raw$Monthly_MSL[raw$Year == 1993], na.rm = TRUE)
raw$Sea_Level_mm <- (raw$Monthly_MSL - baseline_1993) * 1000

annual <- aggregate(Sea_Level_mm ~ Year, data = raw, FUN = mean)
annual$Country <- "Tuvalu"

cat("Data loaded. Years:", min(annual$Year), "to", max(annual$Year), "\n")
cat("Rows:", nrow(annual), "\n\n")


# ─────────────────────────────────────────────
# STEP 8: CORRELATION MATRIX & HEATMAP
# ─────────────────────────────────────────────

cat("=== STEP 8: CORRELATION MATRIX & HEATMAP ===\n")

# split into 3 decade-based periods to show correlation across time segments
early  <- raw$Sea_Level_mm[raw$Year >= 1977 & raw$Year <= 1993]
mid    <- raw$Sea_Level_mm[raw$Year >= 1993 & raw$Year <= 2008]
recent <- raw$Sea_Level_mm[raw$Year >= 2008 & raw$Year <= 2023]

min_len <- min(length(early), length(mid), length(recent))
wide <- data.frame(
  Early_1977_1993  = early[1:min_len],
  Mid_1993_2008    = mid[1:min_len],
  Recent_2008_2023 = recent[1:min_len]
)

cor_matrix <- cor(wide, use = "complete.obs")
cat("Correlation matrix:\n")
print(round(cor_matrix, 3))

melted <- melt(cor_matrix)

ggplot(melted, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white", linewidth = 0.8) +
  geom_text(aes(label = round(value, 2)), color = "white", fontface = "bold", size = 5) +
  scale_fill_gradient2(low = "#7B2D8B", mid = "#FFFFFF", high = "#E8650A",
                       midpoint = 0, limit = c(-1, 1), name = "Correlation") +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1, face = "bold"),
    axis.text.y = element_text(face = "bold"),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
  ) +
  labs(title = "Correlation Heatmap: Sea Level by Time Period – Tuvalu",
       subtitle = "Comparing Early, Mid and Recent periods",
       x = "", y = "")

ggsave("step8_heatmap.png", dpi = 150, width = 8, height = 6)
cat("Saved: step8_heatmap.png\n\n")


# ─────────────────────────────────────────────
# STEP 9: DISTRIBUTION & EXPECTED VALUE
# ─────────────────────────────────────────────

cat("=== STEP 9: DISTRIBUTION & EXPECTED VALUE ===\n")

tuvalu_sl <- annual$Sea_Level_mm
mean_sl <- mean(tuvalu_sl)
sd_sl   <- sd(tuvalu_sl)

cat(sprintf("Mean sea level rise: %.2f mm\n", mean_sl))
cat(sprintf("Standard deviation: %.2f mm\n", sd_sl))

prob_above_120 <- 1 - pnorm(120, mean = mean_sl, sd = sd_sl)
cat(sprintf("Probability of sea level rise > 120mm: %.1f%%\n\n", prob_above_120 * 100))

x_range <- seq(mean_sl - 3.5*sd_sl, mean_sl + 3.5*sd_sl, length.out = 300)
norm_curve <- dnorm(x_range, mean = mean_sl, sd = sd_sl)
norm_df <- data.frame(x = x_range, y = norm_curve)
shade_df <- norm_df[norm_df$x > 120, ]

hist_df <- data.frame(value = tuvalu_sl)

ggplot(hist_df, aes(x = value)) +
  geom_histogram(aes(y = after_stat(density)), bins = 15,
                 fill = "steelblue", color = "white", alpha = 0.7) +
  geom_line(data = norm_df, aes(x = x, y = y), color = "darkred", linewidth = 1.2) +
  geom_area(data = shade_df, aes(x = x, y = y), fill = "red", alpha = 0.3) +
  geom_vline(xintercept = 120, color = "red", linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = mean_sl, color = "darkblue", linetype = "dashed", linewidth = 1) +
  annotate("text", x = 130, y = max(norm_curve)*0.8,
           label = paste0("P(>120mm) = ", round(prob_above_120*100, 1), "%"),
           color = "red", fontface = "bold", size = 4) +
  annotate("text", x = mean_sl - 30, y = max(norm_curve)*0.95,
           label = paste0("Mean = ", round(mean_sl, 1), "mm"),
           color = "darkblue", fontface = "bold", size = 4) +
  labs(title = "Distribution of Annual Sea Level Rise – Tuvalu",
       subtitle = "With normal curve overlay and 120mm threshold",
       x = "Sea Level Change (mm)", y = "Density") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14))

ggsave("step9_distribution.png", dpi = 150, width = 9, height = 6)
cat("Saved: step9_distribution.png\n\n")


# ─────────────────────────────────────────────
# STEP 10: LINEAR REGRESSION & HYPOTHESIS TESTING
# ─────────────────────────────────────────────

cat("=== STEP 10: LINEAR REGRESSION & HYPOTHESIS TESTING ===\n")

model <- lm(Sea_Level_mm ~ Year, data = annual)
cat("Regression summary:\n")
print(summary(model))

cat("\nConfidence intervals for slope:\n")
print(confint(model))

slope <- coef(model)["Year"]
cat(sprintf("\nSlope: %.3f mm per year\n", slope))
cat(sprintf("Projected rise 1977-2030: %.1f mm\n", slope * (2030 - 1977)))

annual$Predicted <- predict(model, annual)
annual$Resid <- resid(model)

ggplot(annual, aes(x = Year, y = Sea_Level_mm)) +
  geom_point(color = "steelblue", size = 2.5, alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE, color = "firebrick", fill = "pink", alpha = 0.3) +
  geom_hline(yintercept = 0, linetype = "dotted", color = "gray50") +
  labs(title = "Linear Regression: Sea Level Rise vs Year – Tuvalu",
       subtitle = paste0("Slope = ", round(slope, 2), " mm/year | p < 0.001"),
       x = "Year", y = "Sea Level Change (mm)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14))

ggsave("step10_regression.png", dpi = 150, width = 10, height = 6)
cat("Saved: step10_regression.png\n\n")


# ─────────────────────────────────────────────
# STEP 11: BAYESIAN UPDATE & MONTE CARLO
# ─────────────────────────────────────────────

cat("=== STEP 11: BAYESIAN UPDATE & MONTE CARLO ===\n")

# prior: believe average sea level rise is 100-110mm
# using Beta distribution scaled to our data range
# define "success" as a year where sea level > 110mm
n_obs <- length(tuvalu_sl)
successes <- sum(tuvalu_sl > 110)
failures  <- n_obs - successes

cat(sprintf("Years observed: %d\n", n_obs))
cat(sprintf("Years with sea level > 110mm: %d\n", successes))
cat(sprintf("Years below 110mm: %d\n\n", failures))

# prior Beta(2,5) -- slightly pessimistic prior (less likely to exceed 110)
alpha_prior <- 2
beta_prior  <- 5

alpha_post <- alpha_prior + successes
beta_post  <- beta_prior + failures

cat(sprintf("Prior: Beta(%d, %d)\n", alpha_prior, beta_prior))
cat(sprintf("Posterior: Beta(%d, %d)\n", alpha_post, beta_post))

set.seed(42)
prior_samples    <- rbeta(10000, alpha_prior, beta_prior)
posterior_samples <- rbeta(10000, alpha_post, beta_post)

prob_above_115 <- mean(posterior_samples > 0.5)
cat(sprintf("\nProbability true proportion > 50%% (above 110mm majority): %.1f%%\n", prob_above_115 * 100))

bayes_df <- data.frame(
  value = c(prior_samples, posterior_samples),
  type  = c(rep("Prior Beta(2,5)", 10000), rep("Posterior", 10000))
)

ggplot(bayes_df, aes(x = value, fill = type)) +
  geom_histogram(aes(y = after_stat(density)), bins = 60,
                 position = "identity", alpha = 0.5, color = NA) +
  geom_vline(xintercept = 0.5, color = "red", linetype = "dashed", linewidth = 1) +
  scale_fill_manual(values = c("Prior Beta(2,5)" = "steelblue", "Posterior" = "darkorange")) +
  annotate("text", x = 0.55, y = 5,
           label = paste0("P(>50%) = ", round(prob_above_115*100, 1), "%"),
           color = "red", fontface = "bold", size = 4) +
  labs(title = "Bayesian Update: Probability Sea Level Exceeds 110mm",
       subtitle = "Prior vs Posterior after observing Tuvalu data",
       x = "Proportion of Years Exceeding 110mm", y = "Density", fill = "") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
        legend.position = "top")

ggsave("step11_bayesian.png", dpi = 150, width = 9, height = 6)
cat("Saved: step11_bayesian.png\n\n")


# ─────────────────────────────────────────────
# STEP 12: ARIMA FORECASTING TO 2030
# ─────────────────────────────────────────────

cat("=== STEP 12: ARIMA FORECASTING TO 2030 ===\n")

library(forecast)

tuvalu_ts <- ts(annual$Sea_Level_mm,
                start = min(annual$Year),
                frequency = 1)

arima_model <- auto.arima(tuvalu_ts)
cat("ARIMA model selected:\n")
print(arima_model)

years_to_forecast <- 2030 - max(annual$Year)
fc <- forecast(arima_model, h = years_to_forecast)
cat(sprintf("\nForecasting %d years ahead (to 2030)\n", years_to_forecast))
print(fc)

forecast_years <- seq(max(annual$Year) + 1, 2030)
fc_df <- data.frame(
  Year     = forecast_years,
  Forecast = as.numeric(fc$mean),
  Lo80     = as.numeric(fc$lower[,1]),
  Hi80     = as.numeric(fc$upper[,1]),
  Lo95     = as.numeric(fc$lower[,2]),
  Hi95     = as.numeric(fc$upper[,2])
)

ggplot() +
  geom_ribbon(data = fc_df, aes(x = Year, ymin = Lo95, ymax = Hi95),
              fill = "lightblue", alpha = 0.4) +
  geom_ribbon(data = fc_df, aes(x = Year, ymin = Lo80, ymax = Hi80),
              fill = "steelblue", alpha = 0.4) +
  geom_line(data = annual, aes(x = Year, y = Sea_Level_mm),
            color = "black", linewidth = 1) +
  geom_point(data = annual, aes(x = Year, y = Sea_Level_mm),
             color = "black", size = 1.5) +
  geom_line(data = fc_df, aes(x = Year, y = Forecast),
            color = "firebrick", linewidth = 1.2, linetype = "dashed") +
  geom_vline(xintercept = max(annual$Year), linetype = "dotted", color = "gray40") +
  annotate("text", x = max(annual$Year) + 0.5, y = min(annual$Sea_Level_mm),
           label = "Forecast →", color = "firebrick", fontface = "bold", size = 4, hjust = 0) +
  labs(title = "ARIMA Forecast: Sea Level Rise to 2030 – Tuvalu",
       subtitle = "Shaded bands show 80% and 95% prediction intervals",
       x = "Year", y = "Sea Level Change (mm)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14))

ggsave("step12_arima.png", dpi = 150, width = 11, height = 6)
cat("Saved: step12_arima.png\n\n")

cat("=== ALL R STEPS COMPLETE ===\n")
cat("Charts saved: step8_heatmap.png, step9_distribution.png,\n")
cat("              step10_regression.png, step11_bayesian.png, step12_arima.png\n")
