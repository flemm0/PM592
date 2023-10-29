require(LogisticDx)

plot_resid_lev_logistic <- function(model, label.all=F) 
{
  resp <- names(model.frame(model))[1]
  title <- paste("Outlier and Leverage Diagnostics for", 
                 resp)
  
  g <- dx(model, byCov=F) %>% 
    rownames_to_column() %>% 
    as_tibble()
  lthresh <- round(mean(g$h, na.rm=T)*2, 3)
  ann_label <- paste("Threshold:", lthresh)
  f <- g[,c("rowname", "h", "dChisq", "dDev", "dBhat", "sPr")]
  f$numinf <- f$dBhat
    #(f$dChisq > 4) + (f$dDev > 4) + (f$dBhat > 1)

  f$obs <- case_when(
    (f$h > lthresh) & (abs(f$sPr) > 2) ~ "Influence",
    (f$h > lthresh) ~ "Leverage",
    (abs(f$sPr) > 2) ~ "Outlier",
    TRUE ~ "Normal"
  )
if (label.all==F) {
  f$txt <- ifelse(f$obs!="Influence", NA, f$rowname) }
if (label.all==T) {
  f$txt <- ifelse(f$obs=="Normal", NA, f$rowname) }
			
  
           
                  ggplot(f, aes(h, sPr, label = txt)) + 
                    geom_point(shape = 1, aes(colour = obs, size = 0.5+0.5*numinf)) + 
                    scale_colour_manual(values=c("Influence" = "red", "Outlier" = "maroon",
                                                 "Leverage" = "darkgreen", "Normal" = "blue")) +
                    labs(colour = "Observation",
                         x = "Leverage",
                         y = "Pearson's Residual",
                         title = title) +
                    geom_hline(yintercept = c(2, -2), colour = "maroon") + 
                    geom_vline(xintercept = lthresh, colour = "maroon") + 
                    geom_text(vjust = -1, size = 3, family = "serif", 
                              fontface = "italic", colour = "darkred") + 
                    annotate("text", x = Inf, y = Inf, hjust = 1.2, 
                             vjust = 2, family = "serif", fontface = "italic", 
                             colour = "darkred", label = ann_label) +
                    scale_size(guide = "none")




}
