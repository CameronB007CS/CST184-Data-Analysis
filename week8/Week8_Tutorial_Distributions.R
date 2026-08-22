library(ggplot2)

# Binomial Distribution - Community Flood Preparedness
n <- 20
p <- 0.65
x_binom <- 0:n
y_binom <- dbinom(x_binom, size = n, prob = p)
expected_binom <- n * p

df_binom <- data.frame(Prepared = x_binom, Probability = y_binom)

ggplot(df_binom, aes(Prepared, Probability)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_vline(xintercept = expected_binom, linetype = "dashed", color = "red") +
  labs(
    title = "Binomial Distribution: Community Flood Preparedness",
    subtitle = "Expected Value (dashed red line)",
    x = "Number of Prepared Communities",
    y = "Probability"
  ) +
  theme_minimal()

# Poisson Distribution - Storm Frequency Forecast
lambda <- 5
x_poisson <- 0:15
y_poisson <- dpois(x_poisson, lambda = lambda)

df_poisson <- data.frame(Events = x_poisson, Probability = y_poisson)

ggplot(df_poisson, aes(Events, Probability)) +
  geom_bar(stat = "identity", fill = "firebrick") +
  geom_vline(xintercept = lambda, linetype = "dashed", color = "black") +
  labs(
    title = "Poisson Distribution: Storm Frequency Forecast",
    subtitle = "Expected Number of Events = lambda",
    x = "Number of Storms",
    y = "Probability"
  ) +
  theme_minimal()

# Normal Distribution - Temperature Anomalies
mean_temp <- 1.1
sd_temp <- 0.4
x_temp <- seq(-0.5, 2.5, length.out = 200)
y_temp <- dnorm(x_temp, mean = mean_temp, sd = sd_temp)

df_temp <- data.frame(Anomaly = x_temp, Density = y_temp)

ggplot(df_temp, aes(Anomaly, Density)) +
  geom_line(color = "darkgreen", linewidth = 1.2) +
  geom_vline(xintercept = mean_temp, linetype = "dashed", color = "blue") +
  labs(
    title = "Normal Distribution: Temperature Anomalies",
    subtitle = "Mean = 1.1 degrees C (dashed line)",
    x = "Temperature Anomaly (degrees C)",
    y = "Density"
  ) +
  theme_minimal()
