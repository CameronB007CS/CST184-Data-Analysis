library(ggplot2)

# Lab 1: Asthma Rates by Pollution Exposure
set.seed(42)

low_pollution <- rnorm(30, mean = 11, sd = 3)
high_pollution <- rnorm(30, mean = 18, sd = 4)

asthma_df <- data.frame(
  rate = c(low_pollution, high_pollution),
  group = c(rep("Low Pollution", 30), rep("High Pollution", 30))
)

head(asthma_df)

t_result <- t.test(rate ~ group, data = asthma_df)
print(t_result)

ggplot(asthma_df, aes(x = group, y = rate, fill = group)) +
  geom_boxplot() +
  labs(
    title = "Asthma Rates by Pollution Exposure",
    y = "Asthma Rate (per 1000 people)",
    x = "Region"
  ) +
  theme_minimal()

# modified version - mean changed to 14
low_pollution <- rnorm(30, mean = 11, sd = 3)
high_pollution <- rnorm(30, mean = 14, sd = 4)

asthma_df <- data.frame(
  rate = c(low_pollution, high_pollution),
  group = c(rep("Low Pollution", 30), rep("High Pollution", 30))
)

t_result <- t.test(rate ~ group, data = asthma_df)
print(t_result)

# higher SD version
low_pollution_sd <- rnorm(30, mean = 11, sd = 8)
high_pollution_sd <- rnorm(30, mean = 14, sd = 8)

asthma_df_sd <- data.frame(
  rate = c(low_pollution_sd, high_pollution_sd),
  group = c(rep("Low Pollution", 30), rep("High Pollution", 30))
)

t_result_sd <- t.test(rate ~ group, data = asthma_df_sd)
print(t_result_sd)

ggplot(asthma_df_sd, aes(x = group, y = rate, fill = group)) +
  geom_boxplot() +
  labs(
    title = "Asthma Rates by Pollution Exposure (Higher SD)",
    y = "Asthma Rate (per 1000 people)",
    x = "Region"
  ) +
  theme_minimal()

# Lab 2: CO2 vs Temperature Anomaly Regression
set.seed(123)

co2 <- runif(50, min = 2, max = 20)
temperature_anomaly <- 0.3 * co2 + rnorm(50, mean = 0, sd = 1.5)

climate_df <- data.frame(co2, temperature_anomaly)
head(climate_df)

ggplot(climate_df, aes(x = co2, y = temperature_anomaly)) +
  geom_point(color = "darkblue") +
  labs(
    title = "CO2 Emissions vs. Temperature Anomaly",
    x = "CO2 Emissions (tonnes per capita)",
    y = "Temperature Anomaly (degrees C)"
  ) +
  theme_minimal()

model <- lm(temperature_anomaly ~ co2, data = climate_df)
summary(model)

ggplot(climate_df, aes(x = co2, y = temperature_anomaly)) +
  geom_point(color = "darkblue") +
  geom_smooth(method = "lm", se = TRUE, color = "red") +
  labs(
    title = "Regression: CO2 vs. Temperature Anomaly",
    x = "CO2 Emissions (tonnes per capita)",
    y = "Temperature Anomaly (degrees C)"
  ) +
  theme_minimal()

# Lab 3: Sugar Intake vs Obesity Rate
set.seed(2025)

sugar_intake <- runif(50, min = 30, max = 120)
obesity_rate <- 0.35 * sugar_intake + rnorm(50, mean = 0, sd = 5)

health_df <- data.frame(sugar_intake, obesity_rate)
head(health_df)

ggplot(health_df, aes(x = sugar_intake, y = obesity_rate)) +
  geom_point(color = "darkgreen") +
  labs(
    title = "Sugar Intake vs. Obesity Rate",
    x = "Daily Sugar Intake (g)",
    y = "Obesity Rate (%)"
  ) +
  theme_minimal()

model <- lm(obesity_rate ~ sugar_intake, data = health_df)
summary(model)

ggplot(health_df, aes(x = sugar_intake, y = obesity_rate)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", se = TRUE, color = "red") +
  labs(
    title = "Regression Model: Sugar Intake vs. Obesity Rate",
    x = "Sugar Intake (grams/day)",
    y = "Obesity Rate (%)"
  ) +
  theme_minimal()

# Lab 4: Real dataset - SDG3 sugar obesity data
data <- read.csv("sdg3_sugar_obesity_data.csv")
summary(data)

plot(data$Sugar_Intake_g_per_day, data$Obesity_Rate_percent,
     main = "Sugar Intake vs Obesity Rate",
     xlab = "Sugar Intake (g/day)",
     ylab = "Obesity Rate (%)")

avg_sugar <- mean(data$Sugar_Intake_g_per_day)
data$Group <- ifelse(data$Sugar_Intake_g_per_day > avg_sugar, "High", "Low")
t.test(Obesity_Rate_percent ~ Group, data = data)

model <- lm(Obesity_Rate_percent ~ Sugar_Intake_g_per_day, data = data)
summary(model)

ggplot(data, aes(x = Sugar_Intake_g_per_day, y = Obesity_Rate_percent)) +
  geom_point(color = "darkred") +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "Regression: Sugar Intake vs Obesity Rate",
    x = "Sugar Intake (g/day)",
    y = "Obesity Rate (%)"
  ) +
  theme_minimal()

ggsave("my_plot.png")

# remove outlier and rerun
data_no_outlier <- data[data$Sugar_Intake_g_per_day < max(data$Sugar_Intake_g_per_day), ]
model_no_outlier <- lm(Obesity_Rate_percent ~ Sugar_Intake_g_per_day, data = data_no_outlier)
summary(model_no_outlier)
