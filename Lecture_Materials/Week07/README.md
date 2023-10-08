# Week 7 - Variable Coding

# Polynomial Terms

A polynomial regression model includes higher-order polynomial terms for X, such that:

$$
Y = \beta_0+\beta_1X+\beta_2X^2+...+\beta_hX^h+e
$$

Where *h* is the ************degree************ of the polynomial

- this is still considered a “linear” regression as the Y variable is still a linear combination of the regression coefficients

Try fitting the following equations:

1. Linear:  $\hat{Y} = \beta_0+\beta_1X$
2. Quadratic:  $\hat{Y} = \beta_0 + \beta_1 + \beta_2X^2$
3. Cubic:  $\hat{Y} = \beta_0 + \beta_1X+ \beta_2X^2 + \beta_3X^3$

How to determine what polynomial term to include:

1. try all and see how much better fit is added with the extra step of complexity (eyeballing to see what is appropriate)
2. continue to add higher degree terms until they are no longer significant in the model
    1. ******************************************extra sums of squares****************************************** F-test
    2. ********************************************Type I sums of squares******************************************** in an ANOVA table
        1. tells additional sums of squares that are explained by each *******additional******* variable that is added to the model
        2. reported by `anova()` function
            1. `lm(area ~ age + I(age^2) + I(age^3), data=re) %>% anova()`
            2. look at p-val and Sum squares to see importance of each polynomial term
        3. `car::Anova()` provides Type III sums of squares
            1. would show that x^2 and x^3 are redundant — important to do the sums of squares test sequentially

- lets say that the equation derived from the model is:

$$
\hat{Y} = 53.4 - 1.93X + 0.04X^2
$$

- the model is now less interpretable, because the effect of a one-unit increase in X on Y depends on the value of X
- example:
    - $\Delta\hat{Y}_{x=2vsx=1}=(53.4-1.93(2)+0.04(2^2))-(53.4-1.93(1) + 0.04(1^2) = -1.81$
    - $\Delta\hat{Y}_{x=1vsx=0}=(53.4-1.93(1)+0.04(1^2))-(53.4-1.93(0) + 0.04(0^2) = -1.89$
- however, the intercept is still interpreted the same way: “the expected selling price is $53.4 per unit area for a house age = 0

- The Hierarchy Principle:
    - in general, if your model includes $X^h$ as a statistically significant predictor of Y, then your model should include $X^j$ for all j<h, regardless of whether the lower-degree terms are significant in the model
    - are there exceptions? consider the following quadratic equation:
    - $\hat{Y} = \beta_0 + \beta_1X + \beta_2X^2 = \beta_2(X-\gamma_1)^2+\gamma_2$
        - $= \beta_2(X^2+2X\gamma_1+\gamma_1^2) + \gamma_2$
        - $=(\beta_2\gamma_1^2+\gamma_2) - 2\beta_2\gamma_1X+\beta_2X^2$, where
        - $-2\beta_2\gamma_1 = \beta_1$ and
        - $\beta_2\gamma_1^2 + \gamma_2 = \beta_0$
    - In this equation, the value $x=\gamma_1$ reflects the extremum/vertex of the quadratic relationship (”dip” or “peak” of the parabola)
    - $\hat{Y} = \beta_2(X-\gamma_1)^2+\gamma_2$
    - if we don’t include a linear term, the equation becomes
    - $\hat{Y} = \beta_0 + \beta_2X^2 = \beta(X-0)^2+\gamma_2$
    - so this essentially forces the vertex of the parabola at X = 0
    - don’t need to include the linear term if we are certain the vertex of the parabola is at X = 0
    - if you are unsure of this, you need to include the linear term
    - reasoning extends to higher order polynomial terms as well
    - generally a good idea to center your X variables on their means
        - one criticism of polynomial equations is that higher- and lower- order terms are strongly related
        - mean-centering reduces amount of correlation among polynomial terms

Example conclusion statement:

- Upon visual inspection we found that age was not linearly related to house selling price. We found that a quadratic model fir the data well (p < .001) and a cubic term did not improve model fit (p = 0.22). Our best-fit equation for selling price was $\hat{Y} = 53.4 - 1.93X_{AGE}+0.04X_{AGE}^2$, as selling price decreased until house age of approximately 22 years, and then subsequently began to rebound.

# Fractional Polynomials

- Fractional Polynomials approach provides a more flexible way to parameterize variables
- Strategy: find a transformation of X (e.g., log(X), X^2) that fits the data best

$$
g(x,\beta) = \beta_0+\sum_{j=1}^{J}F_j(x)\beta_j
$$

- summation just means that we’ll have some combination of transformations of our X variable in the model
- $F_j(x)=x^{p_j}$, if $p_j \ne p_{j-1}$ — transformation of X is just X to some power, if the power under consideration is not equal to the power before it
- $F_j(x)=F_{j-1}ln(x)$, if $p_j=p_{j-1}$ — if power under consideration is equal to the previous power, we last transformation times the log of x
- notice that this is similar to Box-Cox transformation but it is for X variables and up to two terms are chosen

- the `mfp` (Multiple Fractional Polynomial) package in R allows for this testing
- it assesses 4 things:
    1. Null/unconditional model (no x)
    2. Linear model (linear x, $\beta_0+\beta_1x$)
    3. Best fitting J=1 (1-term) model ($\beta_0+\beta_1x^{p1}$)
    4. Best fitting J=2 (2-term) model ($\beta_0+\beta_1x^{p1}+\beta_2x^{p2}$)

```r
mfp(area ~ fp(age), data = re)
```

- the `Deviance table`:
    - deviance is another name for SSE
    - “how much of the model is not explained”
- note: fractional polynomials does not like having X = 0 in it, so it will transform the x variable
    - this will make the interpretation very difficult to do
    - because the transformation can be complex, this approach is better suited for prediction models (vs. models of association)
    - can lead to overfitting
    - can be used to test for departure from linearity

# Splines

Splines: modeling approach where the regression equation between Y and x is broken into “chunks” based on values of X

![https://bradleyboehmke.github.io/HOML/06b-mars_files/figure-html/examples-of-multiple-knots-1.png](https://bradleyboehmke.github.io/HOML/06b-mars_files/figure-html/examples-of-multiple-knots-1.png)

- the relationship between X and Y depends on the range of X under consideration
- Choice of where to create spline “knot” points can depend on:
    1. Data-Driven Approach: choose knot points that fit the data the best
        1. Good for machine learning and prediction modeling
    2. Theory-Driven Approach: choose knot points a priori to answer specific research question
        1. Good for hypothesis testing
- Some example of where splines are applicable:
    1. You’re modeling out-of-pocket medical expenditures (Y). You’re told that HMOs typically only pay for the first week of a hospital stay, after which out-of-pocket expenditures will likely increase dramatically
    2. In the US, older adults are eligible for Medicare once they reach the age of 65. Therefor their medical expenditure patterns (Y) may be drastically different after they reach age 65.
    3. Children in the CHS are followed into early adulthood. We expect a non-linear relationship between FEV1 and age during adolescence

Formula for introducing a spline (using example of out-of-pocket medical cost (Y) vs. length of stay (X):

$X_{LOS.C7} = \{^{X_{LOS}-7, if X_{LOS}>7}_{0, if X_{LOS}\le7}$

- for which the model then becomes:

$\hat{Y} = \beta_0+\beta_1X_{LOS}+\beta_2X_{LOS.C7^+}$

- $\beta_1X_{LOS}$  — equation for line
- $\beta_2X_{LOS.C7^+}$, where $X_{LOS.C7^+}$ is the length of stay (centered on 7), where length of stay is > 7
    - becomes 0 when length of stay is less than 7
    - if length of stay is > 7, then a one-unit increase in stay is associated with a $\beta_1 + \beta_2$ increase in out-of-pocket expenditures
    - (allows for different slope after 7 days)
- So, the value of the spline term $\beta_2$ quantifies the difference in slopes before the given X value and after
- The test of $H_0: \beta_2=0$ is a test of whether there is a significant change in slope after the specified value of X

Another example: testing to see if medical expenditures decreased after passing of Affordable Care Act in 2010:

```r
lm(hepc ~ yearnum + I((yearnum-10)*(yearnum>10)), data = hccp) %>% summary()

# the year was centered on 10, and defined as nonzero when year is greater than 10
```

- Results:
    - The predicted per capita health expenditure increase is $314.89 for years 200-2010. After year 2010, this increase was significantly attenuated by $100.38/year (p=.02). The annual increase in HEPc was (314.89 - 100.38) = $214.51

To re-parameterize the spline model to obtain slope for year *****after***** 2010 and the change in slope for years 2010 and prior:

```r
lm(hepc ~ yearnum + I((yearnum-10)*(yearnum<=10)), data = hccp) %>% summary()
```

- Now, after 2010: $\hat{Y} = 214.5X$
- Before 2010: $\hat{Y} = 214.5X + 100.38(X-10)$

# Dose-Response [Optional]

Applications

- We often find variables that are only applicable when the participant has the existence of some health behavior:
    - For those who smoke, how many packs per weeks do you smoke?
    - For those who exercise, how many hours per week do you exercise?
    - What is the percent of your named friendships that are reciprocated (reciprocation is undefined for those naming no friends)?

Example:

- children in high schools surveyed about the peers at school they considered a friend. They were also given a survey asking them about their “maladaptive coping” habits (e.g. turning to drugs/alcohol when under duress)
- two network measures computed:
    - reciprocity: proportion (in percent) of friendships named by student that were also named in return
    - out-degree: number of friendship nominations made (number of peers deemed as a friend)
    - outcome is “maladaptive coping” z-score
- reciprocity is undefined for those who did not name friends, so how to include these two concepts in a model?
- consider the following coding scheme:
    - $X_{any\_friends} = \{^{1, named\ge1friends}_{0,named 0 friends}$
    - ($X_{any\_friends}$ = 1 if named 1 or more friends, else 0)
    - $X_{recip} = \{^{reciprocity,named\ge1friends}_{0, named 0 friends}$
    - ($X_{recip}$ = reciprocity if named 1 or more friends, else 0)
    - the baseline category is when the individual named 0 friends
    - $\beta_{any\_friends}$ represents the effect on Y associated with naming any friends (vs. naming no friends), holding reciprocity constant (by necessity, at 0)
        - i.e., the difference in Y for a student with zero reciprocity who named any friends, compared to a student who named no friends
        - a coefficient of -0.24011 represents the decrease in maladaptive coping score associated with a 1-unit increase in reciprocity, for those who named any friends
    - $\beta_{recip}$ represents predicted change in Y for a 1-unit increase in reciprocity, holding $X_{any\_friends}$ constant (by necessity, at 1).
        - the only way we would see a change in reciprocity is if someone names one or more friends
        - i.e., the difference in Y for a one-unit increase in reciprocity among those who named any friends
        - a coefficient of -0.29826 represents the decrease in maladaptive coping score associated with naming any friends but having 0 reciprocity, compared to somebody who named no friends
    - in other words, the model says reciprocity decreases maladaptive coping scores, and furthermore, naming any friends additionally decreases maladaptive coping
- this particular coding scheme is useful when one variable is an indicator of the presence of a phenomenon, and the second effect is an additional effect that is contingent on the first variable

# Overfitting & Adjusted R-Squared

Overfitting

- When we try to model phenomena, there is always some random component *e* associated with that phenomena that cannot be explained
- overfitting occurs when model is fit too well to the data and no longer an accurate representation of the underlying process
- an example of this is using an 8-order polynomial term to explain a quadratic relationship
    - has ridiculous amount of complexity and will be difficult to interpret
    - if a set of data points from the same distribution was redrawn, the model fit to new data would look very different
- error is inherent in life
    - be realistic about what your model can and can’t explain
    - parsimony — having the simplest model that still does well explaining an outcome is desirable

Adjusted R-Squared

- In multiple regression, each additional X variable should improve model fit, even if just due to chance
- Models with several variables tend to have better fit simply because they have more terms
- adjusted R-squared is a version of R-squared that adjusts for the number of predictors in the model
    - good way to prevent overfitting

$$
R_{adj}^2=1-(\frac{(1-R^2)(n-1)}{n-k-1})
$$

- where n is sample size and k is the number of predictors
- from the example of modeling a quadratic relationship with 8-degree polynomial, the R-squared value increased by the adjusted R-squared did not increase by much

- Predicted R-Squared
    - measure of how good model is at estimating new values
    - takes out individual observations and sees how well model is fit
    - (”what percent in the variation in **********new values********** can be explained by the model?”)
    - even better measure of overfitting