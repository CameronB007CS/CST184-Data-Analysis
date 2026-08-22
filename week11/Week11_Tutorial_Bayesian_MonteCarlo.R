data <- read.csv("sdg6_sanitation_pre_post.csv")
head(data)

# define prior beliefs - Beta(5,5) means roughly 50/50 starting assumption
alpha_prior <- 5
beta_prior <- 5

# calculate posterior for post-intervention
data$Post_Alpha <- alpha_prior + data$Post_Improved_Sanitation
data$Post_Beta <- beta_prior + (data$Sample_Size - data$Post_Improved_Sanitation)

# also do pre-intervention so we can compare
data$Pre_Alpha <- alpha_prior + data$Pre_Improved_Sanitation
data$Pre_Beta <- beta_prior + (data$Sample_Size - data$Pre_Improved_Sanitation)

# Monte Carlo simulation - probability sanitation access > 70% post intervention
set.seed(42)
data$Prob_Above_70_Post <- sapply(1:nrow(data), function(i) {
  samples <- rbeta(10000, data$Post_Alpha[i], data$Post_Beta[i])
  mean(samples > 0.7)
})

# same for pre-intervention
data$Prob_Above_70_Pre <- sapply(1:nrow(data), function(i) {
  samples <- rbeta(10000, data$Pre_Alpha[i], data$Pre_Beta[i])
  mean(samples > 0.7)
})

# visualise posterior for first country (Kenya)
samples <- rbeta(10000, data$Post_Alpha[1], data$Post_Beta[1])
hist(samples, breaks = 50, col = "skyblue",
     main = paste("Posterior for", data$Country[1]),
     xlab = "Proportion with Improved Sanitation")
abline(v = 0.7, col = "red", lwd = 2)

# summary table
summary_table <- data[c("Country", "Post_Improved_Sanitation", "Prob_Above_70_Post", "Prob_Above_70_Pre")]
print(summary_table)

# try different priors
alpha_flat <- 1
beta_flat <- 1

data$Flat_Alpha <- alpha_flat + data$Post_Improved_Sanitation
data$Flat_Beta <- beta_flat + (data$Sample_Size - data$Post_Improved_Sanitation)

data$Prob_Above_70_Flat <- sapply(1:nrow(data), function(i) {
  samples <- rbeta(10000, data$Flat_Alpha[i], data$Flat_Beta[i])
  mean(samples > 0.7)
})

alpha_strong <- 10
beta_strong <- 10

data$Strong_Alpha <- alpha_strong + data$Post_Improved_Sanitation
data$Strong_Beta <- beta_strong + (data$Sample_Size - data$Post_Improved_Sanitation)

data$Prob_Above_70_Strong <- sapply(1:nrow(data), function(i) {
  samples <- rbeta(10000, data$Strong_Alpha[i], data$Strong_Beta[i])
  mean(samples > 0.7)
})

# compare all three priors
prior_comparison <- data[c("Country", "Prob_Above_70_Flat", "Prob_Above_70_Post", "Prob_Above_70_Strong")]
colnames(prior_comparison) <- c("Country", "Beta(1,1)", "Beta(5,5)", "Beta(10,10)")
print(prior_comparison)

# expected improvement using posterior means
data$Post_Mean <- data$Post_Alpha / (data$Post_Alpha + data$Post_Beta)
data$Pre_Mean <- data$Pre_Alpha / (data$Pre_Alpha + data$Pre_Beta)
data$Expected_Improvement <- data$Post_Mean - data$Pre_Mean

improvement_table <- data[c("Country", "Pre_Mean", "Post_Mean", "Expected_Improvement")]
print(improvement_table)
