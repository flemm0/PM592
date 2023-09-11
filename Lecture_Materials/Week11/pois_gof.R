
pois_pearson_gof <-
  function(model) {
    return(
      list(
        pval = tibble(
          pred = predict(model, type = "response"),
          y = model$y
        ) %>%
        {sum((.$y - .$pred)^2/.$pred)} %>%
          pchisq(., model$df.residual, lower.tail = F),
        df = model$df.residual
      )
    )
  }

pois_dev_gof <-
  function(model) {
    return(
      list(
        pval = pchisq(model$deviance, model$df.residual, lower.tail=F),
        df = model$df.residual
      )
    )
  }