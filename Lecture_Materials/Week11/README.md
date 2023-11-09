# Week 11 - Poisson & Negative Binomial Models

# Introduction to GLM

Already have seen two types of linear regression in this course:

1. Ordinary least squares regression
2. Logistic regression

Regression framework is desirable when modeling effects because:

- allows for modeling the effects of several independent variables simultaneously
- can control for confounding and examine interaction terms
- have flexibility (linear, categorical, polynomial, etc.) in modeling variables
- obtain parameter estimates with confidence intervals and significance values
- can determine the predicted (expected) values for the outcome

We can use linear models for several types of outcomes:

- continuous
    - OLS regression
    - ANOVA, ANCOVA
- binary
    - logistic regression
    - probit regression
- discrete/count
    - Poisson regression
    - Negative binomial regression

Linear models contain three different components: a random component, a systematic component, and a link function 

$$
g(E(Y)) = g(\mu) = \beta_0+\beta_1X_1+\beta_2X_2 + ...
$$

$$
Y\sim\text{?}
$$

- link function given by g function, systematic are the betas, and random is how the outcome (Y) is distributed

OLS Regression

$$
g(E(Y)) = \beta_0+\beta_1X_1+\beta_2X_2 + ...
$$

- random component: $Y\sim N(\mu, \sigma^2)$
    - for any X value, the outcome is normally distributed with some mean value and some variance value
- link function: $g(E(Y)) = E(Y) = \hat{Y}$
    - link function is just Y itself, no transformation on the outcome is needed

Logistic Regression

$$
g(E(Y)) = \beta_0+\beta_1X_1+\beta_2X_2 + ...
$$

- random component: $Y\sim B(n,\pi)$
- link function: $g(E(Y))=\text{logit}(E(Y)) = \text{logit}(\hat{\pi})$

- this allows us to use “linear” regression in a generalized way:
    - a GLM doesn’t assume that the raw X and Y are necessarily linearly distributed
    - However, it is assumed that there is a linear relationship between the predictors and the transformed response (e.g. between X and $\text{logit}(\pi)$)

So why don’t we just transform the Y variable, use linear regression as usual (`lm`), and then back-transform?

- restrictiveness — the GLM approach doesn’t assume normality or homogeneity of residual variance
- interpretability — if you transform Y, you have to interpret the regression coefficient on the transformed outcome variable
- accuracy — simple transformations like this often don’t achieve normality
- elegance — we are able to use the information about the distribution of Y in our modeling approach

Probit regression also yields predictions constrained between 0 and 1

- probit regression uses information about the normal probability density function
- we know that the probability in this function is constrained between 0 and 1
- $\phi^{-1}$ denotes the inverse cumulative density function
- while appropriate for modeling dichotomous outcomes, probit regression isn’t as commonly used as logistic regression and won’t be covered
- $\text{probit}(\pi) = \phi^{-1}(\pi)=\beta_0+\beta_1x_1+\beta_2x_2+...+\beta_kx_k$
    - transforming in terms of Y: $\phi^{-1}(\beta_0+\beta_1x_1+\beta_2x_2+...+\beta_kx_k)$
    - gives a slightly steeper slope than the logit model

# Poisson Regression

Poisson random variables (used for count data) contain data that are only positive

- Examples of count data:
    - number of publications produced by PhD students at different institutions
    - number of spam phone calls you receive on your cell phone each day
    - number of days an individual stays in recovery in the hospital
- Note that all of the outcomes are going to be integer values — they are not continuous, they are discrete; and they cannot be negative
- What type of link function $(-\infty,+\infty)$ would map to predictions that are constrained between $[0, +\infty)$?

Let’s use the natural log link:

$$
\ln(\mu)=\ln(E(Y))=\beta_0+\beta_1x_1+...+\beta_kx_k
$$

- the prediction is “linear in the log”, to transform in terms of Y:

$$
\mu = E(Y)=e^{\beta_0+\beta_1x_1+...+\beta_kx_k}
$$

- in general for these types of functions, there is a small increase in the beginning and then it starts to increase more and more

What distributions of Y are suitable for this type of analysis?

- count data really comes from binomial processes (the probability of a certain number of successes, given some probability)
- the **************************************Poisson limit theorem************************************** states that the Poisson($\lambda$) distribution is the limit of the Binomial($n,\pi$) distribution with $\lambda=n\pi$ as $n$→$\infty$
    - where n is given by the number of observations for an outcome, and pi is the probability of the outcome
- in this situation, $\lambda$ is the expected number of events

Example

- An ER department performs 500 surgeries per month (n=500). On average, one surgery of the 500 will result in patient death (p=1/500). How can we model this?
    1. X ~ Binomial(500, 1/500)
    2. X ~ Poisson(1)
- Notice, the lambda parameter of the Poisson distribution is the ****************************expected value****************************. That is, we would expect to observe 1 fatality in this department
- $\lambda = E(Y)$

![https://www.scribbr.nl/wp-content/uploads/2022/08/Poisson-distribution-graph.webp](https://www.scribbr.nl/wp-content/uploads/2022/08/Poisson-distribution-graph.webp)

Under the Poisson distribution,

$$
P(Y=y)=\frac{e^{-\lambda}\lambda^y}{y!}
$$

This distribution only has one parameter:

$$
\lambda=E(Y)=V(Y)>0
$$

- this implies the following:
    - ************************************************************************************************************the mean of a Poisson distribution equals its variance************************************************************************************************************
    - we expect more variation in Y when E(Y) is larger
    - for many count variables, $\lambda$ is small and there are many observed zeroes
    - as $\lambda$ increases, the Poisson distribution approaches a normal distribution
        - this would suggest that Poisson models are best suited for when we have a small expected value, because if we have a large expected value, we might as well use the normal distribution

Back to the ER example:

- 500 surgeries per month, p=1/500 of patient death
- what is the probability of observing no deaths in a given month?
    - $P(Y=0)=\frac{e^{-1}1^0}{0!}=0.3679$
- what is the probability of observing 3 deaths in a given month?
    - $P(Y=0)=\frac{e^-11^3}{3!}=0.0613$

Properties of Poisson regression

- $-\infty<\ln{\mu_{Y|X}}<\infty$ and $\text{Y}\sim\text{Poisson}(\mu)$
- this lets us use our linear predictor (with a range of $-\infty$, $\infty$) to predict outcomes ranging from 0 to $\infty$
- we assume at each X, Y has a specific Poisson distribution with mean and variance as a function of X

![https://bookdown.org/roback/bookdown-BeyondMLR/bookdown-BeyondMLR_files/figure-html/OLSpois-1.png](https://bookdown.org/roback/bookdown-BeyondMLR/bookdown-BeyondMLR_files/figure-html/OLSpois-1.png)

If $\ln\mu_{Y|X}=\beta_0+\beta_1x$, then we can solve for outcome directly:

$\mu_{Y|X} = \text{exp}(\beta_0+\beta_1x_1)=\text{exp}(\beta_0)*\text{exp}(\beta_1x)$

- when X=0, the expected count outcome is $\text{exp}(\beta_0)$
- a one-unit increase in X has a **multiplicative effect** on outcome, multiplying the baseline mean count by $\text{exp}(\beta_1x)$
    - if $\beta_1$> 0 then the mean of Y increases as X increases (the mean of Y increases by a multiplicative factor of exp($\beta_1$) per unit of X)
    - if $\beta_1$ < 0 then the mean of Y decreases as X increases (the mean of Y decreases by a multiplicative factor of exp($\beta_1$) per unit of X)
- in epidemiology, $\mu$ can be thought of as the incidence rate, and exp($\beta_1$) is the incidence rate ratio

Recap

- Poisson regression can be used to model data where the outcome is a discrete “count” variable that has a lower limit of 0, but is unlimited in range in the positive direction
- the model assumes the outcome follows a Poisson distribution
- since the Poisson distribution approaches a normal distribution as $\lambda$ becomes large, Poisson regression is the most useful when the mean of the outcome is close to 0
- the Poisson regression approach is also used in epidemiology to study rates of disease occurrence

# Poisson Regression: An Example

Dr. Sangre was examining the factors that related to the number of units of RBC (red blood cells) administered in the operating room during aortic valve surgery. He was interested in whether the new minimally invasive surgery was associated with fewer RBC units, adjusting for patient factors. The independent variables are:

- miavr (1=minimally invasive surgery, 0=standard surgery)
- agecent (continuous, in years)
- white (1=white, 0=otherwise)
- male (1=male, 0=female)
- hx_db (1=history of diabetes, 0=otherwise)
- bmicat (2=30+, 1=25-29.9, 0=<25)

How is the outcome variable distributed?

```r
rbcunits %>%
	select(units) %>%
	skimr::skim()

# check: does the mean = the variance?
```

Using the calculated mean of 1.47, we can compute the Poisson probability of number of units used:

$$
(Y=0)=\frac{e^{-1.47}1.47^0}{0!}=0.23
$$

$$
(Y=1)=\frac{e^{-1.47}1.47^1}{1!}=0.34
$$

$$
(Y=10)=\frac{e^{-1.47}1.47^10}{10!}=3e10^{-6}
$$

How do our independent variables relate to outcome?

```r
# looking at mean rbcunits across different groups:

rbcunits %>%
	group_by(miavr) %>%
	summarise(n = n(), mean = mean(units), sd = sd(units))

rbcunits %>%
	group_by(male) %>%
	summarise(n = n(), mean = mean(units), sd = sd(units))

rbcunits %>%
	group_by(white) %>%
	summarise(n = n(), mean = mean(units), sd = sd(units))
```

Run the Poisson regression on no covariates (null model)

```r
glm(formula = units ~ 1, family = "poisson", data = rbcunits)
```

- the $\beta_0$ value given - 0.38631 - when exponentiated, is 1.47, which is the overall mean

Now add some covariates

- Note: Poisson regression allows us to model heterogeneity across patients based on their observed characteristics (independent variables). Each person has their own Poisson mean, based on their X values.
- The model we will use is:

$$
\ln{\mu_{\text{units}|X}}=\beta_0+\beta_1X_{miavr}+\beta_2X_{agecent}+\beta_3X_{white}+\beta_4X_{male}+\beta_5X_{hxdb}+\beta_6X_{overwt}+\beta_7X_{obese}
$$

- technicality, we use mean number of units because a prediction can be a decimal, but the actual observed outcome will not be so we would say that on average we expect the predicted value

```r
glm(formula = units ~ miavr, family = "poisson", data = rbcunits)

exp(rbc1.m$coefficients) # 1.9 (intercept), 0.62 (slope)
```

- the rate ratio for a 1-unit increase in “miavr” (having minimally invasive surgery vs. not) is 0.62
- that is, those that have minimally invasive surgery are expected to have 62% the number of RBC units as those who didn’t
- those who have minimally invasive surgery are expected to have 38% fewer RBC units compared to those who don’t

Full Model

```r
glm(formula = units ~ miavr + agecent + white + male + hx_db + factor(bmicat), family = "poisson", data = rbcunits)

# looking at the output, white can be dropped as it isn't significant and doesn't change slope for units that much when removed
```

Obtain the risk ratio values

```r
tibble(
	parameter = names(rbc3.m$coefficients),
	rr = exp(rbc3.m$coefficients),
	as.data.frame.matrix(exp(confint.default(rbc3.m)) # 95% CI for exponentiated coefs
)
```

Recap:

- Poisson model-building approach is similar to that in other types of regression
- in Poisson regression, a change in independent variables is associated with a multiplicative change in outcome

# Poisson Goodness-of-Fit

Recall that, in general, goodness-of-fit tests always compare the observed counts in each category to the expected number of counts in each category

For the **Pearson chi-square goodness of fit** test, we compare the observed counts to the the model-predicted counts

$$
\text{Pearson }\chi^2 = \sum_{j=1}^{n}\frac{(y_i-\hat{\mu}_{Y|X})^2}{\hat{\mu}_{Y|X}}
$$

- for each person, calculate their observed - expected (i.e., the “residual”)
- this test has df = n - (k+1)
- where k = the number of independent variables
- Recall that the $H_0$ for the GOF test is “no departure from goodness of fit”. Therefore, larger p-values indicate better model fit:
    - `pois_pearson_gof(model)` , `pois_dev_gof(model)`

The **deviance chi-square goodness of fit** test compares the model log-likelihood (i.e. deviance) to the maximum possible log-likelihood given the data

- The maximum possible log-likelihood is called the saturated model, and contains a separate parameter ($\mu_i$) for each observation *i*.
- This means that, under the saturated model, $\hat{\mu_i} = y_i$
    - a dummy variable is created for each observation and dummy variables tell exactly what the value of Y is for that observation

$$
\ln\text{L}_{maximum} = \sum_{i=1}^{n}(-y_i+y_i\ln(y_i)-\ln(y_i!))
$$

- Then Deviance $\chi^2 = -2(\ln{L(model)} - \ln{L(maximum)}) \text{ with n - (k+1) df}$

Recall that goodness of fit measures can be used to compare models that may or may not be nested.

They are also called “comparative” because their utility comes from the ability to compare different models. However, they are not absolute measures of fit (i.e., you won’t get a p-value out of it)

- AIC = Akaike’s Information Criterion = -2LL + 2k, k = number of parameters
- BIC = Bayesian Information Criterion = -2LL + k(ln(N)), n = number of observations

For both of these, lower values indicate better fit

There is penalty for more model parameters, and this penalty is stricter for the BIC

- Rule of thumb, a difference of AIC or BIC < 3 indicates no appreciable difference in fit
- And in most cases, a difference of > 10 indicates strong difference in fit

Poisson Restrictiveness

- In practice, Poisson regression imposes strict assumptions on the distribution of Y
- This is because the Poisson distribution has only one parameter, $\lambda$, so the mean of Y must equal the variance of Y
- Other models exist in this situation, such as a **zero-inflated Poisson model**
    - Zero-inflated Poisson model allows you to model zero counts differently, and can be used if the data has more zero counts than is expected under the Poisson distribution
        - having lots of zeroes than expected would result in lots of negative residuals

Overdispersion

- Recall in Poisson regression $\lambda = \bar{Y} = s_Y^2$
- A quasi-Poisson model allows more flexibility in that $S_Y^2 = \tau \cdot \bar{Y}$, where $\tau$ is the overdispersion parameter (that tells us whether the variance is larger or smaller than what we would expect under a Poisson distribution)
    - under a Poisson distribution, $\tau$ would equal 1
- We can use the `AER` package to test $H_0:\tau=1;H_A:\tau \ne1$

```r
AER::dispersiontest(rbc3.m)

# shows that dispersion is actually 2.3, p << 0.001
```

Our original Poisson model did not account for the variation (********************dispersion********************) that exists in the outcome

The consequences of having an over-dispersed outcome:

- smaller estimated standard errors than what is realistic
- smaller p-values
- we will incorrectly find more variables as being statistically significant (higher “false discovery rate”)
- regression coefficients (betas) are appropriately estimated — but the standard error of the coefficients are not

Recap

- The Poisson GOF or deviance GOF tests can be used to assess the fit of a Poisson regression model
- In practice, the Poisson model is rarely fit well as it assumes the mean is equal to the variance
- One way to accommodate this strict assumption is to fit a quasi-Poisson model, which allows for a different value of the variance

# Negative Binomial Regression

We can use the negative binomial distribution to account for overdispersed outcome variables

A little bit about this distribution:

- used to model the number of failures in a series of Bernoulli trials until a success is observed (e.g. how many times would you have to flip a coin until it came up heads?)
- Conditional on the mean, the random variable Y is distributed as Poisson
- The mean is a function of the gamma distribution with shape parameter *k*
- Gamma distributions are a family of probability distributions for continuous random variables, defined by both a scale and shape parameter

For count data (y=0, 1, 2, etc.) the negative binomial distribution function is:

$$
P(Y=y|\mu,k) = \frac{\Gamma(y+k)}{\Gamma(k)\Gamma(y+1)}(\frac{k}{\mu+k})^k(1-\frac{k}{\mu+k})^y
$$

To simplify with interpretation later, let $\alpha$ = 1/*k*.

For the variable in question:

E(Y) = $\mu$

Var(Y) = $\mu + \alpha\mu^2$

Note a couple things about this:

- without the $\alpha\mu^2$ part, the expected value and variance would be the same as a Poisson variable
- the $\alpha$ term explicitly models the overdispersion (i.e. the “extra-Poisson variation”)
- the $\alpha$ term is assumed constant over all values of X
- In R, there is a different notation: Var(Y) = $\mu + \frac{\mu^2}{\theta}$. Therefore, $\theta = \frac{1}{\alpha}$

Re-running the RBC model with negative binomial regression:

```r
MASS::glm.nb(formula = units ~ miavr + agecent + male + hx_db + factor(bmicat), data = rbcunits)
```

1. the p-values have changed from the Poisson model
2. the deviance and AIC is much lower compared to the Poisson model
3. the estimate of $\theta$ is outputted

Recap

- for almost all purposes, negative binomial regression is treated the same as Poisson regression
- Negative binomial regression explicitly models the overdispersion in the dependent variable

# Rate Outcomes

What is a rate?

- a rate is just a count divided by some population denominator
- examples:
    - number of unemployment claims ************************per 100 people in the state************************
    - number of automobile deaths *******************************per 10,000 truck miles traveled*******************************
    - number of false start penalties *****************************per minute of football played*****************************
    - number of people signing a petition **************************per 1000 people solicited**************************
- a rate is a way of making a count ********************comparable******************** across different-sized populations

Example 2

A case management program for depression was tested in a local hospital that cares for the indigent and homeless, who often access health care by arriving in the emergency room. Investigators wanted to know whether implementation of the new program reduced the number of times individuals visited the ER.

Y = number of ER visits in the year following treatment for depression

TRT = treatment group (0=usual care, 1=new program)

Investigators noted that ER visits vary greatly depending on whether the individual uses alcohol or IV drugs. They wanted to control for:

RACE = (0=white, 1=non-white)

ALC (continuous measure of alcohol use)

DRUG (continuous measure of IV drug use)

In this dataset we observed the following:

- 1/3 of the subjects had Y=0 (no ER visits within one yar)
- 1/2 had either Y=0 or Y=1
- This means that the event is rare. Since it is unlikely to occur, the number of observed counts is low
- For rare events, the Poisson distribution is strongly skewed with many 0 and 1 values

In OLS regression, if the outcome is heavily skewed, a transformation can be applied to it

- however, in this case, the variable is highly non-normal and cannot be transformed to normality using a natural log (or other) transformation
- fortunately, a Poisson model is a good way to model this type of data

In this example, our Poisson regression equation for the number of ER visits in the year following treatment is given by:

$$
\ln{(E(Y_i))} = \beta_0 + \beta_1TRT_i+\beta_2RACE_i+\beta_3DRB_i+\beta_4ALC_i
$$

Where $Y_i \sim \text{Poisson}(\mu_i)$ 

The above model assumes that we have followed individuals for one year to track their ER visits. However, what if an individual was followed for only half a year?

e.g. Person A had 2 ER visits in the past year. Person B had 1 ER visit, but was only followed for half a year.

- Person A’s rate is $\frac{\text{2 ER visits}}{\text{1 year}} = \text{2 visits/year}$
- Person B’s rate is $\frac{\text{1 ER visit1}}{\text{1/2 year}} = \text{2 visits/year}$

One way to accommodate difference among subjects with regard to follow-up time is to model the mean count per unit time.

- We typically model the expected number of counts $E(Y_i)$
- However, we can also model the expected rate $E(Y_i)/t_i$
    - the expected counts divided by time
- How would this change our regression equation?

$$
\text{rate: } \ln{(E(Y_i)/t_i)} = \beta_0 + \beta_1TRT_i+\beta_2RACE_i+\beta_3DRB_i+\beta_4ALC_i
$$

$$
\ln{(E(Y_i))} - \ln{t_i} = \beta_0 + \beta_1TRT_i+\beta_2RACE_i+\beta_3DRB_i+\beta_4ALC_i
$$

$$
\text{count: } \ln{(E(Y_i))} = \beta_0 + \beta_1TRT_i+\beta_2RACE_i+\beta_3DRB_i+\beta_4ALC_i + \ln{(t_i)}
$$

- this adds an extra time term at the end of the Poisson count model
- it ********************doesn’t have a beta coefficient******************** to estimate; the term associated with it is fixed to 1
- this term accounts for follow-up time, and is called an ************offset************

We can also use the offset to account for having different maximum possible counts:

- if the count is the number of games won, the offset could be the number of games played
- if the count is the number of individuals who voted, the offset could be the total population of individuals under consideration

Why do we have to use the offset? Can’t we just calculate the rate and then use it directly as the dependent variable?

- No, Poisson requires that the outcome variable to be a discrete count variable, not a continuous rate
- Furthermore, modelling the offset is mathematically equivalent to modelling a rate

Example 3 (Agresti)

Suppose we want to model whether accidents at road/train crossings has been increasing over time. Our observations are number of accidents at the year level. However, there is more train activity in some years, so we want to include an offset for the total km (in millions) in train travel that year.

- should we include km as a covariate or an offset?
    - since km of train travel sets a limit to the number of car accidents that could happen, we should model it as an offset

The equation for the model will be:

$$
\ln{(\text{E(\#collisions}_i)/km_i)} = \beta_0+\beta_1(time)_i
$$

$$
\ln{(\text{E(\#collisions}_i))} = \beta_0+\beta_1(time)_i +\ln(km_i)
$$

```r
glm(collisions ~ time.1975 + offset(log(km)), family = poisson, data = railroad)
```

The fit equation is

- the equation that gives the estimated number of accidents:

$$
\ln{(\text{E(\#collisions}_i))} = -4.21142-0.03292(time)_i +\ln(km_i)
$$

$$
\text{E(\#collisions}_i) = (km_i)e^{-4.21142-0.03292(time)_i +\ln(km_i)}
$$

- the equation that gives the estimated number of accidents ****************************per million km:****************************

$$
\ln{(\text{E(\#collisions}_i)/km_i)} = -4.21142-0.03292(time)_i +\ln(km_i)
$$

$$
\text{E(\#collisions}_i)/km_i = e^{-4.21142-0.03292(time)_i +\ln(km_i)}
$$

The `predict()` function will automatically predict ln(E(Y))

- it uses information about X and the offset to make predictions
- to get the predicted ****rate****, you must feed `predict()` an offset variable of 1 value

```r
railroad %>%
	mutate(pred_rate = predict(rr1.m, tibble(time.1975 = railroad$time.1975, km = 1), type = "response", 
		pred_count = predict(rr1.m, ., type = "response"))
```

Note: predicted rates are modeled as an exponential trend over time, but there are some “hiccups” with the counts. These are probably in years when the total km of train traffic was particularly high or low.

From assessing the goodness of fit, we see that the observed counts in any given year are sometimes vastly different from the predicted counts. — What could this be saying about our model?

- maybe year is not the only thing affecting train travel and there are other covariates needing to be considered