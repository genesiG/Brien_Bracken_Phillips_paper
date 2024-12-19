setwd("./Projects/DepMap_Brien_paper/")

library(dplyr)
library(ggplot2)

cbx4 <- read.csv("model_CBX4.csv")
cellLines <- read.csv("model_cellLine.csv")

# cbx4 %>% head
# cellLines %>% head

cbx4_cellLines <- merge(cbx4, cellLines, by = "ModelID", all.x = TRUE)

cbx4 %>% nrow
cellLines %>% nrow
cbx4_cellLines %>% nrow

cbx4_cellLines %>% head

cbx4_cellLines$CRISPRGeneDependency %>% range

cbx4_cellLines <- cbx4_cellLines %>% arrange(desc(CRISPRGeneDependency))

glioma_effect <- filter(cbx4_cellLines, grepl("Glioma", cbx4_cellLines$OncotreePrimaryDisease))


cbx4_cellLines$Group = NA
cbx4_cellLines$Group[cbx4_cellLines$CRISPRGeneDependency >= 0.5] = "Dependent Cell Lines" 
cbx4_cellLines$Group[cbx4_cellLines$ModelID %in% glioma_effect$ModelID] = "Glioma Cell Lines"

df = na.exclude(cbx4_cellLines)

# Calculate the counts dynamically
dependent_count <- nrow(df[df$Group == "Dependent Cell Lines", ])
glioma_count <- nrow(df[df$Group == "Glioma Cell Lines", ])

plot_colored <- ggplot(data = df,  aes(x = Group, 
                                       y = CRISPRGeneDependency, 
                                       fill = Group)) +
  geom_boxplot(color = "black", width = 0.3) +
  theme_bw() +
  ggtitle("CBX4") +
  labs(
    x = "Group",
    y = "CRISPR Gene Dependency\n(DepMap Public 24Q2)"
  ) +
  theme(
    axis.title.x = element_blank(),
    plot.title = element_text(face = "bold", hjust = 0.5)
  ) +
  scale_fill_manual(values = c("Dependent Cell Lines" = "darkgreen", 
                               "Glioma Cell Lines" = "red")) +
  scale_y_continuous(limits = c(0,1)) +
  scale_x_discrete(labels = c(
    "Dependent Cell Lines" = paste0("Dependent\nCell Lines\n(n = ", dependent_count, ")"),
    "Glioma Cell Lines" = paste0("Glioma\nCell Lines\n(n = ", glioma_count, ")")
  )) +
  guides(fill = "none")

pdf(file = "./CRISPRDependencyPlot_colored.pdf", width = 5, height = 5)
print(plot_colored)
dev.off()

plot <- ggplot(data = df,  aes(x = Group, 
                                       y = CRISPRGeneDependency, 
                                       fill = Group)) +
  geom_boxplot(color = "black", width = 0.3) +
  theme_bw() +
  ggtitle("CBX4") +
  labs(
    x = "Group",
    y = "CRISPR Gene Dependency\n(DepMap Public 24Q2)"
  ) +
  theme(
    axis.title.x = element_blank(),
    plot.title = element_text(face = "bold", hjust = 0.5)
  ) +
  scale_fill_manual(values = c("Dependent Cell Lines" = "white",
                               "Glioma Cell Lines" = "gray")) +
  scale_y_continuous(limits = c(0,1)) +
  scale_x_discrete(labels = c(
    "Dependent Cell Lines" = paste0("Dependent\nCell Lines\n(n = ", dependent_count, ")"),
    "Glioma Cell Lines" = paste0("Glioma\nCell Lines\n(n = ", glioma_count, ")")
  )) +
  guides(fill = "none")

pdf(file = "./CRISPRDependencyPlot.pdf", width = 5, height = 5)
print(plot)
dev.off()


write.csv(df, file = "./cbx4_dependent_vs_glioma_cell_lines.csv", row.names = F)
