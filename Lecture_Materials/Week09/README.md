# Week 9 - Logistic Regression II

# Assessing Assumptions

Example

In a study of 508 adults, vital characteristics such as blood pressure, height, weight and presence of coronary calcium were assessed. What is the relationship between age and SBP with presence of coronary calcium?

$$
\hat{Y} = -1.72+0.01142X_{sbp}
$$

- SBP is significantly related to coronary calcium (p=0.0335)
- the odds ratio associated with a 1-unit increase in SBP is exp(0.01142) = 1.011
    - since this is a small odds ratio it may be useful to interpret the odds ratio for a 10-unit increase in SBP = exp(10*0.01142) = 1.12
    - “a 10-unit increase in SBP is associated with 1.12 times the odds of coronary calcium”
    - “a 10-unit increase in SBP increases the likelihood of coronary calcium by 12%”
- however, when adjusted for age as a confounding variable, the beta coefficient for SBP is no longer significant (p=0.509) and the beta coefficient has changed by a lot

How do the residuals look?

- because the values can either only be 1 or 0, the residuals do not look to satisfy the assumptions of linear regression
- in fact, the assumptions of OLS do not necessarily apply for generalized linear models

How usual assumptions of linear regression apply to logistic regression:

- ******************Linearity****************** — X and Y cannot be linearly related if Y is binary. However we ***do*** assume linearity ***********in the logit***********
- ************************Independence************************ — we **do** assume all X are independent of each other
- ******************Normality****************** — we ******do not****** assume that the residuals are normally distributed
- ************************Equal Variances************************ — we ******do not****** assume that the residuals have constant variance over all X values

- so, linearity is the assumption that needs to be checked for logistic regression
- there are 3 methods, need to check all and look at the consensus of all of the methods
1. Grouped Smooth
2. Loess Smoothing
3. Fractional Polynomials

### Grouped Smooth

Strategy: Group the x observations by quantiles (quartiles), then see if the quantile groupings are linearly related to the logit

1. Create a dummy variable set that indicates which quantile the individual’s observation belongs to
2. Fit the model, getting a beta term for each quantile indicator relative to quantile 1
3. Assign the midpoint value to the quantile and plot the beta coefficients vs. the midpoint values
4. Re-parameterize x as the plot suggests (e.g. $x^2$)

```r
corcalc <- 
	corcalc %>%
	mutate(age.q4 = cut(age, breaks = quantile(age, probs = 0:4/4), include.lowest = T))

corcalc %>%
	group_by(age.q4) %>%
	summarise(
		mean = mean(age, na.rm = T)
		min = min(age, na.rm = T)
		max = max(age, na.rm = T)
		n = n())

glm(cor_calcium ~ age.q4, data = corcalc, family = binomial) %>%
	summary()
```

- the coefficients will reflect the changes in the logit compared to the reference group
- compared to the lowest quartile, those in the second age quartile have exp(0.626) = 1.87 times the odds of coronary calcium (p=0.025)
- using dummy predictor variables allows for modeling flexibility because we don’t assume linear relationship across all X values
- the relationship between the logit and age quartile may not be perfectly linear, but can be a good approximation
- logit is estimated as a function of the dummy variables for age quartile

$$
\text{logit}(\hat{\pi}) = \beta_0 + \beta_1X_{age.q2} + \beta_2X_{age.q3} + \beta_3X_{age.q4}
$$

- if linear approach is good enough, this relationship can be fit with a straight line:

$$
\text{logit}(\hat{\pi}) = \beta_0 + \beta_1X_{ageq}
$$

- the dummy variable scheme is more flexible; to determine if the flexibility improves model fit:

```r
anova(agequantlin.m, agequant.m, test = "LRT")
```

### LOESS (Locally-Estimated) Smoothing

Strategy: similar to grouped smooth, but instead of using discrete categories, use a moving window/band

- calculate the logit($\hat{\pi}$) for each point in the dataset, using a weighted average regression of adjacent points (weighted by distance from the current point)
- graph will tell you the predicted logit across X values
- the LOESS smoother can be sensitive to actual data and may pick up small departures from linearity

### Fractional Polynomials

Strategy: Find a transformation of X (e.g., log(X), X^2) that fits the data best

- Look at whether fractional polynomials approach improves the model relative to using just a linear variable
- Look at the reduction in deviance that you get when adding fractional polynomial terms into the model
    - if 1-term and 2-term polynomial terms do not reduce deviance much, it suggests that the linear term is best

```r
mfp(cor_calcium ~ fp(age), data = corcalc, family = binomial)

# if you specify verbose = TRUE, you can see best one-term and two-term polynomial transformations

mfp(cor_calcium ~ fp(age), data = corcalc, family = binomial, verbose = T)
```

- For the linear model, DF = 1
- For the one-term polynomial, DF = 2
- For the two-term polynomial, DF = 4
- can use chi-square test on difference in deviance scores and DFs to compare models

# Assessing Linearity for BMI

LOESS plot for BMI

```r
bmi_pred_logits <-
	loess(cor_calcium ~ bmi, data = corcalc, span = .8) %>%
	predict(.) %>%
	psych::logit()

corcalc %>%
	ggplot(aes(x = bmi, y = bmi_pred_logits)) +
	geom_count(alpha = .5) +
	stat_smooth(geom = 'line', color = 'blue', method = 'glm', se = FALSE)
```

# Goodness of Fit

Things to look for when model building:

- Does model contain correct main effects?
- Are continuous independent variables modeled according to the correct functional form?
- Have all sensible interactions been considered?
- [Model of association] Have all potential confounders been examined?
- [Prediction model] Have all predictive variables been considered appropriately, and does the model only include these predictive variables?

Even though some of the assumptions used in OLS were relaxed in logistic regression, still want to see if the model fits the data well. Similarly, the model fits the data well if:

- the distance between observed Y and predicted $\hat{Y}$ is small (low error)
- each individual make a small, unsystematic contribution (no observations making undue influence)

To test the fit:

- examine **********************************overall goodness-of-fit**********************************
- examine lack-of-fit by specific departures from the model

To obtain summary measures, the observed and expected values are enumerate for each covariate pattern

For example, if we have a model with gender (dichotomous) and race (black/Hispanic vs. otherwise), we will have 4 covariate patterns

We can create a 2xj table with n subjects (i = 1, …, n) and j covariate patterns ($X_1$ …$X_j$; j$\le$n)

The ******************residuals****************** of logistic regression are the difference between observed and expected values, for ************each covariate pattern************

$$
\hat{\pi}_j = \frac{\text{exp}(\hat{\beta}x)}{1+\text{exp}(\hat{\beta}x)}
$$

- where $\hat{\pi}_j$ is the predicted probability of outcome for covariate pattern j
- $\hat{Y}_j = m_j\hat{\pi}_j$ — the expected number with Y=1 in covariate pattern j is the total number that have covariate pattern j multiplied by the probability of outcome for this group

The Pearson residuals are given as:

$$
r_j = \frac{y_j-m_j\hat{\pi}_j}{\sqrt{m_j\hat{\pi}_j(1-\hat{\pi}_j)}}
$$

- (observed minus expected divided by measure of variation)
- essentially, the residual will be higher if the observed - expected is larger

Corresponding goodness-of-fit summary statistic is:

$$
\sum{r_j^2\sim\chi^2(\text{df}=J-(p+1))}
$$

- where p = the number of variables in the model
- Null: the model fits the data (the observed matches what we expected)
- Alternative: the model departs from good fit

Examine fit statistics for each covariate pattern:

```r
dx(gender_race.model)
```

- `y` column is the observed number with Y=1 (# of people that have the outcome)
- `n` column is number of people with that particular covariate pattern
- `P` column is predicted probability according to the model
- `yhat` column is predicted number of people that have the outcome (Y=1)
- `Pr` is the Pearson residual

Perform Pearson goodness-of-fit (GOF) test:

```r
gof(gender_race.m, g=4, plotROC=F) %>% unclass()
```

- look for the `PrG` row under `$chiSq`, which gives the Pearson residuals on the groups
- a significant p-value indicates departure from goodness-of-fit

The Pearson chi-square GOF requires m-asymptotics

- means total sample size isn’t as important as the number of observations within each covariate pattern
- therefore when the number of covariate patterns approaches sample size, the chi-square approximation does not hold for this test
    - this is a problem with continuous variables — they add a lot of covariate patterns

An alternative to the Pearson GOF test that “fixes” the problem of having too many covariate patterns is the ************************************************Hosmer-Lemeshow GOF Test************************************************

1. collapse J covariate patterns into g groups (g<J, and fix g << n). Then calculate observed and expected frequencies
2. Obtain predicted probabilities, $\hat{\pi}_j$, for each covariate pattern j
3. Order the j columns (covariate patterns) from lowest to highest predicted probabilities
4. Calculate the expected values for each of the 10 categories (sum over all subjects in the cells with Y=1 or in cells with Y=0)
5. Perform chi-square test and compare to a $\chi^2$ with g-2 degrees of freedom

```r
hoslem.test(gender_race_age.m$y, fitted(gender_race_age.m), g=10)
```

- the range of predicted probabilities is split into 10 quantiles
    - within each quantile, we calculate how many observations with Y=0 and Y=1 we expect, and compare that to how many we would observe

Comparative Model Fit

Information Criteria are derived from the model log-likelihood (-2LL) and can be used to compare models when making decisions about which is better

- unlike the likelihood ratio test, AIC and BIC can be used to compare models with different independent variables
- AIC: Akaike’s Information Criterion: -2LL + 2k (k = # of model parameters estimated)
- BIC: Bayesian Information Criterion: -2LL + kln(N) (N = sample size)
    - smaller values indicate comparatively better model fit
    - the BIC imposes a penalty for having more model parameters
    - two models that differ in AIC or BIC by about 10 represent considerable difference in fit between the two models

# Diagnostics

As with OLS, we need to check: collinearity, leverage, influence

Collinearity:

```r
DescTools::VIF(gender_race_age.m)
```

- remember > 10 VIF is of concern

Leverage

- recall, leverage indicates observations that have the potential to be influential because they are far away from the average value of a covariate
- in linear regression leverage values are obtained from the hat matrix: H = X(X’X)-1X’
- in logistic regression, H = V1/2 X(X’VX)-1X’V1/2, where V is a JxJ diagonal matrix with element $\nu_j=m_j\hat{\pi}(x_j)(1-\hat{\pi}(x_j))$

Influence

- observations are influential when it has high **residual** and a large value of **leverage**
- influence assessed by estimating the effect of deleting all subjects with a particular covariate pattern J
- we can see how this affects: estimated coefficients (betas), and summary GOF measures
- We will want to see the following plots:
    - $\Delta\chi^2_j\:\text{vs}\:\hat{\pi}_j$ (Change in Pearson GOF)
        - poorly fit points will lie in upper corners
            - typically the covariate patterns that influence the model the most are the ones with either a low predicted probability or a high predicted probability
        - 4 is a crude approximation of the upper 95th percentile of the distribution of $\Delta\chi^2_j$
    - $\Delta\text{D}_j\:\text{vs}\:\hat{\pi}_j$ (Change in Deviance GOF)
        - same, poorly fit points lie in upper corners
        - and 4 is the 95th percentile approximation
    - $\Delta\hat{\beta}_j\:\text{vs}\:\hat{\pi}_j$ (Change in Cook’s Distance)
        - values above 1.0 indicate removal of the covariate pattern is associated with considerable changes to the parameter estimates
- These values can be produced for either each covariate pattern `dx(model)` or for each individual `dx(model, bycov = F)`

What happens when we find problematic observations?

- list the covariate pattern to see why the observation is influential
- delete these patterns and refit the model to determine the true effect of these observations on your $\hat{\beta}$ of interest
- then decide:
    - what is the reason for the outliers? need a valid reason to delete the observations
    - are the outlying patterns reasonable? or are they due to mistakes?
    - is there a variable or set of variables you didn’t include that would fix the model?

What if there are multiple suspect patterns?

Check the following:

- did you use the correct link?
- did you omit an important predictor or interaction?
- are the covariates on the proper scale?
- is there “extra-binomial variation”? (more or less variation in predicted probabilities than expected under the binomial model; can occur when observations are clustered)

# Variable Selection

Recall the two goals of regression analysis:

1. determine most accurate association between X and Y (model of association)
2. find the best model to predict Y (prediction model)

Logistic regression models are especially important when it comes to prediction:

- is this patient at risk for heart attack?
- is this particular growth malignant cancer?
- does this test indicate infection with COVID-19?

Example: can we use characteristics of the mother to predict low birth weight?

- when faced with several possible predictive variables, it can be cumbersome to manually arrive at a good model
- ************************************************Automatic selection procedures************************************************ (while criticized for being too “hands-off”) provide a way to assess which variables may be important:
    - selection algorithms:
        1. Best Subsets
        2. Backward Elimination
        3. Forward Selection
        4. Stepwise Selection
- traditionally, selection algorithms were based on p-values (i.e. add the most significant variables to the model according to their p-value until they’re no longer significant)
    - however, reusing p-values over and over causes them to lose meaning
    - so recently, there has been a push to turn to other measures such as R-squared or information criteria (AIC/BIC/etc.)

### Best Subsets

For K variates under consideration, assess the fit of all models with k = 1, 2, 3, … K variables included in the model

- the best subset is chosen using some criteria (Information Criterion, R-squared, Mallow’s $C_p$, etc.)
- this approach is computationally intensive, as it requires fitting $2^K-1$ models
    - once we approach 20 or so variables, the computational time becomes very long

```r
best_subset_low <-
	glmulti(LOW ~ AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV, data=lbw, level=1, family=binomial, crit="aicc", confsetsize=128)
```

- Get top 6 models: (top models are within 2 IC units of top model)

```r
weighttable(best_subset_low) %>% head()
```

- `wieghts` column gives the probability that given model is the best model out of all models considered

We can also look at the relative importance of all predictors, averaged across *all* the models. This is the sum of the weights for all models containing that variable

- 0.8 is a somewhat arbitrary cutoff used for determining importance in the model

### Sequential Selection

- less computationally demanding than best subsets

****************Backward:**************** Start with a “full” model and sequentially remove variables that do not contribute to model fit

****************Forward:**************** Start with an empty model and sequentially add variables that contribute to model fit

****************Stepwise****************: A mix of adding and deleting variables at each step

```r
# forward selection
forward_low <-
	MASS::stepAIC(
		glm(LOW ~ 1, data = lbw, family = binomial),
		scope = list(upper = ~AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV, lower = ~1),
		direction = "forward"
	)

summary(forward_low)	

# backward selection
backward_low <-
	MASS::stepAIC(
		glm(LOW ~ AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV, data = lbw, family = binomial),
		scope = list(upper = ~AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV, lower = ~1),
		direction = "backward"
	)

summary(backward_low)	

# stepwise selection
stepwise_low <-
	MASS::stepAIC(
		glm(LOW ~ 1, data = lbw, family = binomial),
		scope = list(upper = ~AGE + LWT + RACE + SMOKE + PTL + HT + UI + FTV, lower = ~1),
		direction = "both"
	)

summary(stepwise_low)	
```

- automated selection procedures have been criticized for being too data-driven and for removing input from the analyst

### Recap

- Linearity is the only regression assumption that needs to be checked for logistic regression, but it is considerably more difficult to do so
- Goodness of fit tests are a way to describe how well your logistic regression model fits your data; not rejecting the null hypothesis (p>.05) indicates an acceptable fit
- Diagnostics are performed similarly to linear regression, but on covariate patterns. Influence is still a combination of being an outlier with high leverage