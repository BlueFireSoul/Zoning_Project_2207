Now, I need to sort out the Houston data. The end product is a panel of housing unit. With housing density, lot size, 

The regression is done on the property level. I should have total floorspace, housing unit, total land lot, and geo_identifier. 

The aim is two-fold. First show that total floorspace is increasing in housing density. Second, show that per-housing unit floorspace is decreasing in housing density. Doing all these while controling for location fixed effects. 

---

I should focus on Houston area. 

I will need to incorporate housing unit. 

---

I should look into the data to determine how to adjust the housing unit

land size = col161
floorspace = col202
housing unit = col201
bedroom unit = col165

---


## Los Angeles

```
> model <- lm(logFAR ~ logd, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = logFAR ~ logd, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.25385 -0.25624 -0.01042  0.26558  2.32692 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 3.9157809  0.0025417    1541   <2e-16 ***
logd        0.6023457  0.0002907    2072   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3858 on 5903986 degrees of freedom
Multiple R-squared:  0.421,	Adjusted R-squared:  0.421 
F-statistic: 4.293e+06 on 1 and 5903986 DF,  p-value: < 2.2e-16

> 
> result <- felm(logFAR ~ logd | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = logFAR ~ logd | GEOID, data = property_current_m_subset) 

Residuals:
    Min      1Q  Median      3Q     Max 
-2.6951 -0.1846 -0.0027  0.1905  2.6932 

Coefficients:
      Estimate Std. Error t value Pr(>|t|)    
logd 0.6353748  0.0003057    2079   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3015 on 5897636 degrees of freedom
Multiple R-squared(full model): 0.6467   Adjusted R-squared: 0.6463 
Multiple R-squared(proj model): 0.4228   Adjusted R-squared: 0.4222 
F-statistic(full model): 1700 on 6351 and 5897636 DF, p-value: < 2.2e-16 
F-statistic(proj model): 4.321e+06 on 1 and 5897636 DF, p-value: < 2.2e-16 


> 
> 
> model <- lm(FAR ~ d, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = FAR ~ d, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.81858 -0.07494 -0.02240  0.05740  1.03108 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 1.253e-01  9.203e-05    1362   <2e-16 ***
d           9.116e+02  3.971e-01    2296   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.1262 on 5903986 degrees of freedom
Multiple R-squared:  0.4716,	Adjusted R-squared:  0.4716 
F-statistic: 5.27e+06 on 1 and 5903986 DF,  p-value: < 2.2e-16

> 
> result <- felm(FAR ~ d | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = FAR ~ d | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-0.95173 -0.05356 -0.01002  0.04549  1.18196 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
d 893.0727     0.4091    2183   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.101 on 5897636 degrees of freedom
Multiple R-squared(full model): 0.662   Adjusted R-squared: 0.6616 
Multiple R-squared(proj model): 0.4469   Adjusted R-squared: 0.4463 
F-statistic(full model): 1819 on 6351 and 5897636 DF, p-value: < 2.2e-16 
F-statistic(proj model): 4.766e+06 on 1 and 5897636 DF, p-value: < 2.2e-16 


> 
> model <- lm(FAR ~ b, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = FAR ~ b, data = property_current_m_subset)

Residuals:
    Min      1Q  Median      3Q     Max 
-61.573  -0.087  -0.037   0.049   0.966 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 2.002e-01  9.147e-05    2188   <2e-16 ***
b           1.721e+02  1.205e-01    1428   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.1475 on 5812412 degrees of freedom
  (91574 observations deleted due to missingness)
Multiple R-squared:  0.2596,	Adjusted R-squared:  0.2596 
F-statistic: 2.038e+06 on 1 and 5812412 DF,  p-value: < 2.2e-16

> 
> result <- felm(FAR ~ b | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = FAR ~ b | GEOID, data = property_current_m_subset) 

Residuals:
    Min      1Q  Median      3Q     Max 
-44.519  -0.061  -0.016   0.041   1.065 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
b 124.2205     0.1061    1171   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.1214 on 5806076 degrees of freedom
  (91574 observations deleted due to missingness)
Multiple R-squared(full model): 0.4992   Adjusted R-squared: 0.4986 
Multiple R-squared(proj model): 0.191   Adjusted R-squared: 0.1901 
F-statistic(full model):913.2 on 6337 and 5806076 DF, p-value: < 2.2e-16 
F-statistic(proj model): 1.371e+06 on 1 and 5806076 DF, p-value: < 2.2e-16 


> 
> model <- lm(logFAR ~ logb, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = logFAR ~ logb, data = property_current_m_subset)

Residuals:
    Min      1Q  Median      3Q     Max 
-4.8347 -0.2041 -0.0082  0.1967  4.5771 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 4.8353876  0.0019597    2467   <2e-16 ***
logb        0.8128251  0.0002571    3161   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3055 on 5812412 degrees of freedom
  (91574 observations deleted due to missingness)
Multiple R-squared:  0.6323,	Adjusted R-squared:  0.6323 
F-statistic: 9.994e+06 on 1 and 5812412 DF,  p-value: < 2.2e-16

> 
> result <- felm(logFAR ~ logb | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = logFAR ~ logb | GEOID, data = property_current_m_subset) 

Residuals:
    Min      1Q  Median      3Q     Max 
-4.8947 -0.1512 -0.0058  0.1498  4.6962 

Coefficients:
      Estimate Std. Error t value Pr(>|t|)    
logb 0.7843994  0.0002561    3063   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.2451 on 5806076 degrees of freedom
  (91574 observations deleted due to missingness)
Multiple R-squared(full model): 0.7636   Adjusted R-squared: 0.7633 
Multiple R-squared(proj model): 0.6176   Adjusted R-squared: 0.6172 
F-statistic(full model): 2959 on 6337 and 5806076 DF, p-value: < 2.2e-16 
F-statistic(proj model): 9.379e+06 on 1 and 5806076 DF, p-value: < 2.2e-16 
```

![image-20230703021553010](45.assets/image-20230703021553010.png)

#### Norm Floorspace

```
Call:
lm(formula = lognorm_floorspace ~ logd, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.65690 -0.27466 -0.01606  0.26865  2.32354 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 7.4573833  0.0001629   45780   <2e-16 ***
logd        0.5659355  0.0002998    1888   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3897 on 6117127 degrees of freedom
Multiple R-squared:  0.3681,	Adjusted R-squared:  0.3681 
F-statistic: 3.564e+06 on 1 and 6117127 DF,  p-value: < 2.2e-16

> 
> result <- felm(lognorm_floorspace ~ logd | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = lognorm_floorspace ~ logd | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-2.91501 -0.18500 -0.00499  0.18612  2.67229 

Coefficients:
     Estimate Std. Error t value Pr(>|t|)    
logd 0.607705   0.000261    2328   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.291 on 6110754 degrees of freedom
Multiple R-squared(full model): 0.6479   Adjusted R-squared: 0.6475 
Multiple R-squared(proj model): 0.4701   Adjusted R-squared: 0.4696 
F-statistic(full model): 1764 on 6374 and 6110754 DF, p-value: < 2.2e-16 
F-statistic(proj model): 5.422e+06 on 1 and 6110754 DF, p-value: < 2.2e-16 


> 
> 
> model <- lm(norm_floorspace ~ d, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = norm_floorspace ~ d, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-16742.3   -607.4   -209.1    423.5   6526.8 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 1246.2383     0.5808    2146   <2e-16 ***
d            645.8518     0.3188    2026   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 945.1 on 6117127 degrees of freedom
Multiple R-squared:  0.4015,	Adjusted R-squared:  0.4015 
F-statistic: 4.104e+06 on 1 and 6117127 DF,  p-value: < 2.2e-16

> 
> result <- felm(norm_floorspace ~ d | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = norm_floorspace ~ d | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-16752.1   -400.4    -85.7    316.9   9008.7 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
d 650.4408     0.3078    2113   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 759.1 on 6110754 degrees of freedom
Multiple R-squared(full model): 0.6143   Adjusted R-squared: 0.6139 
Multiple R-squared(proj model): 0.4221   Adjusted R-squared: 0.4215 
F-statistic(full model): 1527 on 6374 and 6110754 DF, p-value: < 2.2e-16 
F-statistic(proj model): 4.464e+06 on 1 and 6110754 DF, p-value: < 2.2e-16 


> 
> model <- lm(norm_floorspace ~ b, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = norm_floorspace ~ b, data = property_current_m_subset)

Residuals:
    Min      1Q  Median      3Q     Max 
-753787    -692    -297     378    6231 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 1624.4746     0.6218    2612   <2e-16 ***
b            127.7060     0.1102    1159   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 1097 on 5995134 degrees of freedom
  (121993 observations deleted due to missingness)
Multiple R-squared:  0.1829,	Adjusted R-squared:  0.1829 
F-statistic: 1.342e+06 on 1 and 5995134 DF,  p-value: < 2.2e-16

> 
> result <- felm(norm_floorspace ~ b | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = norm_floorspace ~ b | GEOID, data = property_current_m_subset) 

Residuals:
    Min      1Q  Median      3Q     Max 
-587046    -457    -121     308    6445 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
b 99.68360    0.09437    1056   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 911.2 on 5988771 degrees of freedom
  (121993 observations deleted due to missingness)
Multiple R-squared(full model): 0.4368   Adjusted R-squared: 0.4362 
Multiple R-squared(proj model): 0.1571   Adjusted R-squared: 0.1562 
F-statistic(full model):729.9 on 6364 and 5988771 DF, p-value: < 2.2e-16 
F-statistic(proj model): 1.116e+06 on 1 and 5988771 DF, p-value: < 2.2e-16 


> 
> model <- lm(lognorm_floorspace ~ logb, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = lognorm_floorspace ~ logb, data = property_current_m_subset)

Residuals:
    Min      1Q  Median      3Q     Max 
-5.0886 -0.2145 -0.0148  0.1966  4.6420 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 6.4881068  0.0003720   17440   <2e-16 ***
logb        0.8338568  0.0002793    2985   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3097 on 5995134 degrees of freedom
  (121993 observations deleted due to missingness)
Multiple R-squared:  0.5979,	Adjusted R-squared:  0.5979 
F-statistic: 8.913e+06 on 1 and 5995134 DF,  p-value: < 2.2e-16

> 
> result <- felm(lognorm_floorspace ~ logb | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = lognorm_floorspace ~ logb | GEOID, data = property_current_m_subset) 

Residuals:
    Min      1Q  Median      3Q     Max 
-4.8560 -0.1530 -0.0079  0.1474  4.5136 

Coefficients:
      Estimate Std. Error t value Pr(>|t|)    
logb 0.7713321  0.0002373    3250   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.2395 on 5988771 degrees of freedom
  (121993 observations deleted due to missingness)
Multiple R-squared(full model): 0.7596   Adjusted R-squared: 0.7594 
Multiple R-squared(proj model): 0.6382   Adjusted R-squared: 0.6378 
F-statistic(full model): 2974 on 6364 and 5988771 DF, p-value: < 2.2e-16 
F-statistic(proj model): 1.056e+07 on 1 and 5988771 DF, p-value: < 2.2e-16 
```



## Houston
```
Call:
lm(formula = logFAR ~ logd, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-1.96248 -0.26519  0.01348  0.28611  1.89403 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 4.4531747  0.0070721   629.7   <2e-16 ***
logd        0.6489606  0.0007814   830.5   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3889 on 1473963 degrees of freedom
Multiple R-squared:  0.3188,	Adjusted R-squared:  0.3188 
F-statistic: 6.897e+05 on 1 and 1473963 DF,  p-value: < 2.2e-16

> 
> result <- felm(logFAR ~ logd | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = logFAR ~ logd | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-2.12462 -0.17624 -0.00141  0.17967  1.83576 

Coefficients:
     Estimate Std. Error t value Pr(>|t|)    
logd 0.698961   0.000674    1037   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.2778 on 1472936 degrees of freedom
Multiple R-squared(full model): 0.6526   Adjusted R-squared: 0.6524 
Multiple R-squared(proj model): 0.422   Adjusted R-squared: 0.4216 
F-statistic(full model): 2692 on 1028 and 1472936 DF, p-value: < 2.2e-16 
F-statistic(proj model): 1.075e+06 on 1 and 1472936 DF, p-value: < 2.2e-16 


> 
> 
> model <- lm(FAR ~ d, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = FAR ~ d, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-0.33514 -0.07551 -0.01417  0.06437  0.50436 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 1.174e-01  2.588e-04   453.6   <2e-16 ***
d           1.187e+03  1.932e+00   614.6   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.09928 on 1473963 degrees of freedom
Multiple R-squared:  0.204,	Adjusted R-squared:  0.204 
F-statistic: 3.777e+05 on 1 and 1473963 DF,  p-value: < 2.2e-16

> 
> result <- felm(FAR ~ d | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = FAR ~ d | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-0.41994 -0.04774 -0.00759  0.03986  0.53405 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
d 1368.651      1.779   769.4   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.07471 on 1472936 degrees of freedom
Multiple R-squared(full model): 0.5496   Adjusted R-squared: 0.5493 
Multiple R-squared(proj model): 0.2867   Adjusted R-squared: 0.2862 
F-statistic(full model): 1748 on 1028 and 1472936 DF, p-value: < 2.2e-16 
F-statistic(proj model): 5.92e+05 on 1 and 1472936 DF, p-value: < 2.2e-16 


> 
> model <- lm(FAR ~ b, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = FAR ~ b, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.60881 -0.05398 -0.00953  0.04771  0.52183 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 6.257e-02  2.368e-04   264.2   <2e-16 ***
b           4.802e+02  5.014e-01   957.8   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.08134 on 1144582 degrees of freedom
  (329381 observations deleted due to missingness)
Multiple R-squared:  0.4449,	Adjusted R-squared:  0.4449 
F-statistic: 9.174e+05 on 1 and 1144582 DF,  p-value: < 2.2e-16

> 
> result <- felm(FAR ~ b | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = FAR ~ b | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-2.42445 -0.03869 -0.00484  0.03363  0.52959 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
b 457.2180     0.4467    1024   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.06356 on 1143650 degrees of freedom
  (329381 observations deleted due to missingness)
Multiple R-squared(full model): 0.6613   Adjusted R-squared: 0.661 
Multiple R-squared(proj model): 0.4781   Adjusted R-squared: 0.4777 
F-statistic(full model): 2393 on 933 and 1143650 DF, p-value: < 2.2e-16 
F-statistic(proj model): 1.048e+06 on 1 and 1143650 DF, p-value: < 2.2e-16 


> 
> model <- lm(logFAR ~ logb, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = logFAR ~ logb, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.60394 -0.18982  0.00809  0.20080  1.93780 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 4.9403397  0.0056352   876.7   <2e-16 ***
logb        0.8110052  0.0007236  1120.8   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.2992 on 1144582 degrees of freedom
  (329381 observations deleted due to missingness)
Multiple R-squared:  0.5232,	Adjusted R-squared:  0.5232 
F-statistic: 1.256e+06 on 1 and 1144582 DF,  p-value: < 2.2e-16

> 
> result <- felm(logFAR ~ logb | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = logFAR ~ logb | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-2.17084 -0.13908 -0.00028  0.14033  1.67830 

Coefficients:
      Estimate Std. Error t value Pr(>|t|)    
logb 0.7680527  0.0006264    1226   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.2249 on 1143650 degrees of freedom
  (329381 observations deleted due to missingness)
Multiple R-squared(full model): 0.7308   Adjusted R-squared: 0.7305 
Multiple R-squared(proj model): 0.568   Adjusted R-squared: 0.5676 
F-statistic(full model): 3327 on 933 and 1143650 DF, p-value: < 2.2e-16 
F-statistic(proj model): 1.504e+06 on 1 and 1143650 DF, p-value: < 2.2e-16 

```

![image-20230703021836823](45.assets/image-20230703021836823.png)

#### Norm Floorspace

```
Call:
lm(formula = lognorm_floorspace ~ logd, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.05036 -0.27192  0.01172  0.28299  2.01357 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 7.6136347  0.0003125 24362.2   <2e-16 ***
logd        0.5951257  0.0008412   707.4   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.3855 on 1530639 degrees of freedom
Multiple R-squared:  0.2464,	Adjusted R-squared:  0.2464 
F-statistic: 5.005e+05 on 1 and 1530639 DF,  p-value: < 2.2e-16

> 
> result <- felm(lognorm_floorspace ~ logd | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = lognorm_floorspace ~ logd | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-2.16403 -0.17490 -0.00169  0.17717  1.80098 

Coefficients:
      Estimate Std. Error t value Pr(>|t|)    
logd 0.6413696  0.0006049    1060   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.272 on 1529602 degrees of freedom
Multiple R-squared(full model): 0.625   Adjusted R-squared: 0.6247 
Multiple R-squared(proj model): 0.4236   Adjusted R-squared: 0.4232 
F-statistic(full model): 2456 on 1038 and 1529602 DF, p-value: < 2.2e-16 
F-statistic(proj model): 1.124e+06 on 1 and 1529602 DF, p-value: < 2.2e-16 


> 
> 
> model <- lm(norm_floorspace ~ d, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = norm_floorspace ~ d, data = property_current_m_subset)

Residuals:
    Min      1Q  Median      3Q     Max 
-5205.9  -617.9  -132.0   521.7  3782.5 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) 1036.981      1.912   542.4   <2e-16 ***
d           1110.119      1.728   642.5   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 828.7 on 1530639 degrees of freedom
Multiple R-squared:  0.2124,	Adjusted R-squared:  0.2124 
F-statistic: 4.128e+05 on 1 and 1530639 DF,  p-value: < 2.2e-16

> 
> result <- felm(norm_floorspace ~ d | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = norm_floorspace ~ d | GEOID, data = property_current_m_subset) 

Residuals:
    Min      1Q  Median      3Q     Max 
-5479.9  -379.1   -60.2   329.6  4030.8 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
d 1203.742      1.311   918.5   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 607.7 on 1529602 degrees of freedom
Multiple R-squared(full model): 0.5767   Adjusted R-squared: 0.5764 
Multiple R-squared(proj model): 0.3555   Adjusted R-squared: 0.355 
F-statistic(full model): 2007 on 1038 and 1529602 DF, p-value: < 2.2e-16 
F-statistic(proj model): 8.436e+05 on 1 and 1529602 DF, p-value: < 2.2e-16 


> 
> model <- lm(norm_floorspace ~ b, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = norm_floorspace ~ b, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-22656.4   -426.5    -90.0    362.9   3972.7 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) 321.0657     1.8605   172.6   <2e-16 ***
b           536.5494     0.5079  1056.4   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 654.3 on 1179479 degrees of freedom
  (351160 observations deleted due to missingness)
Multiple R-squared:  0.4862,	Adjusted R-squared:  0.4862 
F-statistic: 1.116e+06 on 1 and 1179479 DF,  p-value: < 2.2e-16

> 
> result <- felm(norm_floorspace ~ b | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = norm_floorspace ~ b | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-19499.0   -297.5    -36.9    260.0   3729.6 

Coefficients:
  Estimate Std. Error t value Pr(>|t|)    
b 456.4904     0.4032    1132   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 491.6 on 1178532 degrees of freedom
  (351160 observations deleted due to missingness)
Multiple R-squared(full model): 0.7101   Adjusted R-squared: 0.7099 
Multiple R-squared(proj model): 0.521   Adjusted R-squared: 0.5207 
F-statistic(full model): 3046 on 948 and 1178532 DF, p-value: < 2.2e-16 
F-statistic(proj model): 1.282e+06 on 1 and 1178532 DF, p-value: < 2.2e-16 


> 
> model <- lm(lognorm_floorspace ~ logb, data = property_current_m_subset)
> summary(model)

Call:
lm(formula = lognorm_floorspace ~ logb, data = property_current_m_subset)

Residuals:
     Min       1Q   Median       3Q      Max 
-2.57843 -0.19541  0.00194  0.20005  2.13116 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) 6.5523994  0.0009672    6775   <2e-16 ***
logb        0.8827036  0.0007827    1128   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.2994 on 1179479 degrees of freedom
  (351160 observations deleted due to missingness)
Multiple R-squared:  0.5188,	Adjusted R-squared:  0.5188 
F-statistic: 1.272e+06 on 1 and 1179479 DF,  p-value: < 2.2e-16

> 
> result <- felm(lognorm_floorspace ~ logb | GEOID, data = property_current_m_subset)
> summary(result)

Call:
   felm(formula = lognorm_floorspace ~ logb | GEOID, data = property_current_m_subset) 

Residuals:
     Min       1Q   Median       3Q      Max 
-2.10823 -0.13891 -0.00105  0.13812  1.70827 

Coefficients:
      Estimate Std. Error t value Pr(>|t|)    
logb 0.7493334  0.0006059    1237   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.2196 on 1178532 degrees of freedom
  (351160 observations deleted due to missingness)
Multiple R-squared(full model): 0.7414   Adjusted R-squared: 0.7412 
Multiple R-squared(proj model): 0.5648   Adjusted R-squared: 0.5644 
F-statistic(full model): 3565 on 948 and 1178532 DF, p-value: < 2.2e-16 
F-statistic(proj model): 1.529e+06 on 1 and 1178532 DF, p-value: < 2.2e-16 
```

I should try other cities with less zoning policy, just because Houston data is so bad. Nevertheless, I can start here and calibrate my model. 

land_share distribution

![image-20230703120058875](45.assets/image-20230703120058875.png)

SFH 

![image-20230703120759815](45.assets/image-20230703120759815.png)

![image-20230703120825178](45.assets/image-20230703120825178.png)



---

explore d

multiple the median single-family lot. 

---

I should run an elasticity regression first, then anchor around median single-family lot size, and run again. 

---

Houston: try something else. this beta * f is too high

beta * f = 1203.742 

median SF lot price = 29950

land cost share = 0.141

maybe try bedroom instead?

---

LA

land cost share = 0.409

median SF lot price = 144359

beta * f = 650

f = 900

beta = 0.72

----

