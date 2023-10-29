# logit_plot is a function that will plot the estimated logits of a binary Y
# over some continuous X variable
require(psych)

logit_plot <- function(x, y, dat) {
  
  formula <- as.formula(paste0(y, "~", x))
  
  logit_table <-
    loess(formula, data = dat) %>% 
    {
	tibble(
		logits = predict(.) %>%
			psych::logit(),
		model.frame(.) %>%
			.[x] )}
  
  logit_table %>%
    ggplot(aes(x = .data[[x]], y = logits)) +
    geom_count(alpha = 0.5) +
    stat_smooth(geom='line', color = "blue", method = "glm", se=FALSE) +
    labs(x = x, y = paste("logit(p(", y, "))"))
}