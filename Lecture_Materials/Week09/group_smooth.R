# group_smooth is a function that will plot the predicted logits of outcome
# over quantiles of x (or actual x if x has few categories)

group_smooth <- function(x, y, dat, q=4) {
  
  breaks = quantile(dat[[x]], probs = (0:q)/q, na.rm=T)
  
  if (sum(duplicated(breaks)) > 0) {
    if (length(unique(dat[[x]])) <= 20) {
      x.q = dat[[x]] 
    } else {
      stop("Variable not appropriate for Grouped Smooth.")
    }
  } else {
    x.q = cut(dat[[x]],
              breaks = breaks,
              include.lowest = T)
  }
  
  dat2 <- tibble(
    y = dat[[y]],
    x = dat[[x]],
    x.q = x.q
  )
  
  mean_merger <-
    tibble(
      dat2 %>%
        group_by(x.q) %>%
        summarise(meanx = mean(x, na.rm=T)) %>%
        ungroup()
    )
  
  dat3 <- dat2 %>%
    left_join(mean_merger, by = "x.q")
  
  linmod <- glm(y ~ meanx, data = dat3, family = binomial)
  catmod <- glm(y ~ factor(meanx), data = dat3, family = binomial)
  
  lrtest <- anova(linmod, catmod, test = "LRT")
  
  dat4 <-
    tibble(
      mean_merger %>% filter(!is.na(x.q)),
      plogit = c(catmod$coefficients[1],
                 catmod$coefficients[1] + catmod$coefficients[2:length(catmod$coefficients)])
    )
  
  g <-
    dat4 %>%
    ggplot(aes(x = meanx, y = plogit)) +
    geom_point() +
    geom_line() +
    geom_smooth(method = "glm", color = "red", se = F, size = 1) +
    labs(x = x, y = paste0("Predicted Logit of P(", y, ")"))
  
  print(lrtest)
  g
}
