# makeVolcanoPlot.R

# Prepare function to make volcano plot
# Function will take the results data frame from DESeq2 as input
makeVolcanoPlot <- function(results_df, 
                            lfc.threshold = 1, 
                            ylim = NULL,
                            color_by = effect,
                            label_by = Label,
                            y_lab = (expression(bold(bolditalic(-Log[10]) ~ "FDR"))),
                            x_lab = (expression(bold(bolditalic(Log[2]) ~ "Fold-Change"))),
                            color_labels = c("Downregulated", "NS", "Upregulated"), 
                            color_values = c("navyblue", "gray", "red"),
                            x_axis=log2FoldChange, 
                            y_axis=padj,
                            nbreaks = 7,
                            nudgex = 0,
                            nudgey = 0,
                            maxoverlaps = 10) {
  
  # Ensure that the number of labels matches the number of colors provided
  if (length(color_labels) != length(color_values)) {
    stop("The number of color labels must match the number of color values.")
  }
  
  # Convert `color_labels` and `color_values` into a named vector for scale_color_manual
  color_map <- setNames(color_values, color_labels)
  
  
  volcanoPlot <- ggplot(data=results_df, 
                        aes(x=x_axis, 
                            y=-log10(y_axis),
                            color = color_by, 
                            label = label_by))  
    
  volcanoPlot <- volcanoPlot + geom_point() 
    
  
  volcanoPlot <- volcanoPlot + 
    theme_classic() +
    # Add axes labels
    ylab(y_lab) +
    xlab(x_lab) +
    # Add plot tile based on which comparison was made
    ggtitle(comparison) +
    # Add vertical lines for log2FoldChange thresholds, and one horizontal line for the p-value threshold 
    geom_vline(xintercept = -lfc.threshold, lty = "dashed") +
    geom_vline(xintercept = lfc.threshold, lty = "dashed") +
    geom_hline(yintercept = -log10(alpha), lty = "dashed") +
    scale_x_continuous(n.breaks = nbreaks, 
    ) +
    scale_y_continuous(limits = ylim) +
    # Modify plotting theme
    theme(legend.title = element_blank(),
          plot.title = element_text(hjust = 0.5),
          panel.border = element_rect(color = "black", fill = NA),
          panel.grid.minor = element_blank()) +
    # Apply custom color scale based on user-defined labels and colors
    scale_color_manual(values = color_map) + 
    # Organize labels in the plot
    geom_text_repel(nudge_x = nudgex, nudge_y = nudgey, max.overlaps = maxoverlaps)  
  
  return(volcanoPlot)
}


# Prepare function to make volcano plot for all genes
# Function will take two data frames as input
makeVolcanoPlot2 <- function(results_allgenes, 
                             results_subset, 
                             lfc.threshold = 1, 
                             ylim = NULL){
  
  volcanoPlot <- ggplot(data=results_allgenes, 
                        aes(x=log2FoldChange, 
                            y=-log10(padj),
                            fill = effect,
                            color = effect,
                            label = Label)) +
    
    geom_point(alpha = 0.5, shape = 21) +
    geom_point(data = results_subset, 
               aes(x=log2FoldChange, 
                   y=-log10(padj), 
                   fill = effect), 
               shape = 21, 
               size = 2, 
               color = "black") +
    
    theme_classic() +
    # Add axes labels
    ylab(expression(bold(bolditalic(-Log[10]) ~ "FDR"))) +
    xlab(expression(bold(bolditalic(Log[2]) ~ "Fold-Change"))) +
    # Add plot tile based on which comparison was made
    ggtitle(comparison) +
    # Add vertical lines for log2FoldChange thresholds, and one horizontal line for the p-value threshold 
    geom_vline(xintercept = -lfc.threshold, lty = "dashed") +
    geom_vline(xintercept = lfc.threshold, lty = "dashed") +
    geom_hline(yintercept = -log10(alpha), lty = "dashed") +
    scale_x_continuous(n.breaks = 7, 
    ) +
    scale_y_continuous(limits = ylim) +
    # Modify plotting theme
    theme(legend.title = element_blank(),
          plot.title = element_text(hjust = 0.5),
          panel.border = element_rect(color = "black", fill = NA),
          panel.grid.minor = element_blank()) +
    # Change point color 
    scale_fill_manual(values=c("Downregulated" = "blue",
                               "NS" = "gray", 
                               "Upregulated" = "red")) + 
    scale_color_manual(values=c("Downregulated" = "blue",
                                "NS" = "gray", 
                                "Upregulated" = "red")) + 
    guides(color = "none")  + 
    # Organize labels in the plot
    geom_text_repel(color = "black", nudge_x = 0.25 * results_allgenes$log2FoldChange) 
  
  return(volcanoPlot)
}
