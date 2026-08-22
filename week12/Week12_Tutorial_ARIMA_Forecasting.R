library(ggplot2)

# Step 1: load and inspect the data
data <- read.csv("sdg7_renewable_energy_percent.csv")
head(data)
summary(data)

# Step 2: visualize the raw trend
ggplot(data, aes(x = Year, y = Renewable_Energy_Percent)) +
  geom_line(color = "darkgreen") +
  geom_point() +
  labs(title = "Renewable Energy (% of Total)", y = "Percent", x = "Year") +
  theme_minimal()

# with smooth line
ggplot(data, aes(x = Year, y = Renewable_Energy_Percent)) +
  geom_line(color = "darkgreen") +
  geom_point() +
  geom_smooth(method = "loess", se = TRUE, color = "blue") +
  labs(title = "Renewable Energy (% of Total)", y = "Percent", x = "Year") +
  theme_minimal()

# Step 3: create a time series object
ts_data <- ts(data$Renewable_Energy_Percent, start = 1990, frequency = 1)
plot(ts_data, main = "Renewable Energy Time Series", ylab = "% of Energy", xlab = "Year")

# Step 4: check for stationarity
install.packages("tseries")
library(tseries)

adf.test(ts_data)

# first difference if non-stationary
diff_ts <- diff(ts_data)
plot(diff_ts, main = "First Differenced Renewable Energy Series", ylab = "Difference", xlab = "Year")
adf.test(diff_ts)

# Step 5: fit ARIMA model
install.packages("forecast")
library(forecast)

model <- auto.arima(ts_data)
summary(model)

# Step 6: forecast to 2030
forecasted <- forecast(model, h = 8)
plot(forecasted, main = "Forecast of Renewable Energy to 2030")
print(forecasted)

# confidence intervals for 2030
lo_80 <- forecasted$lower[8, "80%"]
hi_80 <- forecasted$upper[8, "80%"]
lo_95 <- forecasted$lower[8, "95%"]
hi_95 <- forecasted$upper[8, "95%"]

cat("2030 80% Confidence Interval:", round(lo_80, 2), "% to", round(hi_80, 2), "%\n")
cat("2030 95% Confidence Interval:", round(lo_95, 2), "% to", round(hi_95, 2), "%\n")

# Step 7: extend horizon to 15 years
forecasted <- forecast(model, h = 15)
plot(forecasted, main = "Forecast of Renewable Energy to 2037")

# log transformation
log_ts <- log(ts_data)
log_model <- auto.arima(log_ts)
summary(log_model)

log_forecast <- forecast(log_model, h = 8)
forecast_original <- log_forecast
forecast_original$mean <- exp(log_forecast$mean)
forecast_original$lower <- exp(log_forecast$lower)
forecast_original$upper <- exp(log_forecast$upper)
forecast_original$x <- exp(log_forecast$x)

plot(forecast_original, main = "Forecast of Renewable Energy (Log Transformed)",
     ylab = "Percent", xlab = "Year")

checkresiduals(model)

# Step 8: enhanced ggplot2 visualization
forecasted <- forecast(model, h = 8)

forecast_df <- data.frame(
  Year = 2023:2030,
  Forecast = as.numeric(forecasted$mean),
  Lower = as.numeric(forecasted$lower[,2]),
  Upper = as.numeric(forecasted$upper[,2])
)

ggplot() +
  geom_line(data = data, aes(x = Year, y = Renewable_Energy_Percent), color = "darkgreen") +
  geom_line(data = forecast_df, aes(x = Year, y = Forecast), color = "blue") +
  geom_ribbon(data = forecast_df, aes(x = Year, ymin = Lower, ymax = Upper), alpha = 0.3) +
  labs(title = "Forecast of Renewable Energy Usage", y = "% Renewable", x = "Year") +
  theme_minimal()

# Step 9: what-if scenarios
years <- 2023:2030
growth_boost <- 2 * (1:length(years))
accelerated_forecast <- as.numeric(forecasted$mean) + growth_boost

scenario_df <- data.frame(
  Year = years,
  Baseline = as.numeric(forecasted$mean),
  Accelerated = accelerated_forecast,
  Lower_95 = as.numeric(forecasted$lower[, 2]) + growth_boost,
  Upper_95 = as.numeric(forecasted$upper[, 2]) + growth_boost
)

ggplot() +
  geom_line(data = data, aes(x = Year, y = Renewable_Energy_Percent, color = "Historical"), linewidth = 1) +
  geom_line(data = scenario_df, aes(x = Year, y = Baseline, color = "Baseline Forecast"), linewidth = 1, linetype = "dashed") +
  geom_line(data = scenario_df, aes(x = Year, y = Accelerated, color = "Policy Acceleration (+2%/yr)"), linewidth = 1) +
  geom_ribbon(data = scenario_df, aes(x = Year, ymin = Lower_95, ymax = Upper_95), fill = "orange", alpha = 0.15) +
  scale_color_manual(values = c("Historical" = "darkgreen", "Baseline Forecast" = "blue", "Policy Acceleration (+2%/yr)" = "orange")) +
  labs(title = "Renewable Energy Projections: Baseline vs. Policy Acceleration Scenario",
       y = "% Renewable", x = "Year", color = "Scenario") +
  theme_minimal()

print(tail(scenario_df, 1))
