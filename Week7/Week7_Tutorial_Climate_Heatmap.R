climate <- matrix(c(
  9.2, 1.1, 0.8, 15,
  6.5, 0.9, 1.2, 30,
  2.3, 0.7, 2.5, 60,
  3.8, 1.0, 1.5, 45,
  7.1, 1.2, 0.9, 25,
  4.2, 1.0, 2.1, 50
), nrow = 6, byrow = TRUE)

colnames(climate) <- c("CO2", "Temp", "Deforestation", "Renewables")
rownames(climate) <- c("A", "B", "C", "D", "E", "F")
print(climate)

scaled_climate <- scale(climate)
print(scaled_climate)

cor_matrix <- cor(scaled_climate)
print(round(cor_matrix, 2))

library(reshape2)
melted <- melt(cor_matrix)

library(ggplot2)

ggplot(melted, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = round(value, 2)), color = "white", fontface = "bold", size = 6) +
  scale_fill_gradient2(
    low = "#7B2D8B",
    mid = "#FFFFFF",
    high = "#E8650A",
    midpoint = 0,
    limit = c(-1, 1),
    name = "Correlation"
  ) +
  guides(fill = guide_colorbar(barwidth = unit(1.1, "cm"), barheight = unit(15, "cm"))) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 14),
    axis.text.y = element_text(angle = 45, hjust = 1, face = "bold", size = 14),
    legend.position = "right",
    legend.title.align = 0.5,
    legend.key.width = unit(1.8, "cm"),
    legend.key.height = unit(8, "cm"),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 20),
    plot.subtitle = element_text(hjust = 0.5, size = 14)
  ) +
  labs(
    title = "Environmental Indicator Correlation Heatmap",
    subtitle = "SDG 13: Climate Action",
    x = "",
    y = ""
  )

# Step 6: modify Country C renewables and replot
climate[3, 4] <- 90
scaled_climate <- scale(climate)
cor_matrix <- cor(scaled_climate)
melted <- melt(cor_matrix)

ggplot(melted, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = round(value, 2)), color = "white", fontface = "bold", size = 6) +
  scale_fill_gradient2(
    low = "#7B2D8B",
    mid = "#FFFFFF",
    high = "#E8650A",
    midpoint = 0,
    limit = c(-1, 1),
    name = "Correlation"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 14),
    axis.text.y = element_text(angle = 45, hjust = 1, face = "bold", size = 14),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 20),
    plot.subtitle = element_text(hjust = 0.5, size = 14)
  ) +
  labs(
    title = "Environmental Indicator Correlation Heatmap (Modified)",
    subtitle = "SDG 13: Climate Action - Country C Renewables = 90%",
    x = "",
    y = ""
  )
