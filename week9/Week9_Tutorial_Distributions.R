library(ggplot2)

# Step 2: Binomial Distribution - Community Flood Preparedness
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

# try p = 0.4
n <- 20
p <- 0.4
x_binom <- 0:n
y_binom <- dbinom(x_binom, size = n, prob = p)
expected_binom <- n * p
df_binom <- data.frame(Prepared = x_binom, Probability = y_binom)

ggplot(df_binom, aes(Prepared, Probability)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_vline(xintercept = expected_binom, linetype = "dashed", color = "red") +
  labs(
    title = "Binomial Distribution: Community Flood Preparedness (p = 0.4)",
    subtitle = "Expected Value (dashed red line)",
    x = "Number of Prepared Communities",
    y = "Probability"
  ) +
  theme_minimal()

# Step 3: Poisson Distribution - Storm Frequency
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

# try lambda = 3
lambda <- 3
x_poisson <- 0:15
y_poisson <- dpois(x_poisson, lambda = lambda)
df_poisson <- data.frame(Events = x_poisson, Probability = y_poisson)

ggplot(df_poisson, aes(Events, Probability)) +
  geom_bar(stat = "identity", fill = "firebrick") +
  geom_vline(xintercept = lambda, linetype = "dashed", color = "black") +
  labs(
    title = "Poisson Distribution: Storm Frequency Forecast (lambda = 3)",
    subtitle = "Expected Number of Events = lambda",
    x = "Number of Storms",
    y = "Probability"
  ) +
  theme_minimal()

# Step 4: Normal Distribution - Temperature Anomalies
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

# try sd = 0.8
mean_temp <- 1.1
sd_temp <- 0.8
x_temp <- seq(-0.5, 2.5, length.out = 200)
y_temp <- dnorm(x_temp, mean = mean_temp, sd = sd_temp)
df_temp <- data.frame(Anomaly = x_temp, Density = y_temp)

ggplot(df_temp, aes(Anomaly, Density)) +
  geom_line(color = "darkgreen", linewidth = 1.2) +
  geom_vline(xintercept = mean_temp, linetype = "dashed", color = "blue") +
  labs(
    title = "Normal Distribution: Temperature Anomalies (sd = 0.8)",
    subtitle = "Mean = 1.1 degrees C (dashed line)",
    x = "Temperature Anomaly (degrees C)",
    y = "Density"
  ) +
  theme_minimal()

# Step 5: expected values summary
cat("Expected Values:\n")
cat("Prepared communities: n x p =", 20 * 0.65, "\n")
cat("Storm events: lambda =", 5, "\n")
cat("Temperature anomaly mean: mu =", 1.1, "\n")
