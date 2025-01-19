# In order to build an efficient portfolio, we must compute correlation matrix in order to see if the stocks are related to each other. In our case, as Frankie is risk-averse investor and she wants an efficient portfolio, we must try to choose the stocks which correlation coefficient is close to 0. 
# Install necessary packages (if not already installed)
install.packages(c("quantmod", "PerformanceAnalytics", "readr","dplyr","purrr","tidyr"))

# Load libraries
library(quantmod) #tool designed for quantitative financial modeling and trading analysis
library(PerformanceAnalytics) #tool for performance and risk analysis of financial portfolios
library(readr) #tool for reading data in csv format
library(dplyr) #tool used for data manipulation and transformation 
library(purrr) #tool for functional programming which ensures consistent return types (we mainly need this for function "reduce")
library(tidyr) #tool used for tidy and organize data

#clear Environment
rm(list=ls())

#clear console
cat("\014")

# Read CSV files for each stock. In my case, as Frankie wants stocks listed on WSE, I have chosen PKO, KRUK, BENEFIT, PKN, and ATC. The data are downloaded from https://stooq.com.
pko_data <- read_csv("/Users/hojunglee/Downloads/pko_d.csv")
kruk_data <- read_csv("/Users/hojunglee/Downloads/kru_d.csv")
benefit_data <- read_csv("/Users/hojunglee/Downloads/bft_d.csv")
pkn_data <- read_csv("/Users/hojunglee/Downloads/pkn_d.csv")
atc_data <- read_csv("/Users/hojunglee/Downloads/atc_d.csv")

# Step 1: Select relevant columns (Date and Close). Once we download stock prices in CSV format from Stooq, there are 6 columns including Date, Close, Open, and more. However, for our analysis we only need the "date" and "closing prices". 
pko_prices <- pko_data %>% select(Date, Close)
kruk_prices <- kruk_data %>% select(Date, Close)
benefit_prices <- benefit_data %>% select(Date, Close)
pkn_prices <- pkn_data %>% select(Date, Close)
atc_prices <- atc_data %>% select(Date, Close)

# Step 2: Merge all datasets by Date. We will rename each columns in each dataset to reflect the stock names for clarity.
pko_prices <- rename(pko_prices, PKO = Close)
kruk_prices <- rename(kruk_prices, KRUK = Close)
benefit_prices <- rename(benefit_prices, BENEFIT = Close)
pkn_prices <- rename(pkn_prices, PKN = Close)
atc_prices <- rename(atc_prices, ATC = Close)

# Merge datasets by Date (inner join to keep only common dates). We will merge each dataset into 1 to ensure all stock prices are aligned by trading dates.
all_prices <- reduce(list(pko_prices, kruk_prices, benefit_prices, pkn_prices, atc_prices),
                     full_join, by = "Date")

# Step 3: Calculate daily returns for each stock. The across function applies returns to be calculated for all the columns except Date. We will also need to remove rows with missing values caused by return calculations. This will omit the first calculated return as return is calculated by dividing today's stock price by yesterday's stock price.
all_prices <- all_prices %>%
  mutate(across(-Date, ~ ROC(.x, type = "discrete"))) %>%
  drop_na()  

# Step 4: Create correlation matrix. We will remove the Date column for correlation matrix calculation.
returns <- all_prices %>% select(-Date)  
cor_matrix <- cor(returns)

# Step 5: Print and visualize the correlation matrix. Most correlation coefficient of 5 chosen stocks are close to 0 except KRUK with PKO and PKN with KRUK. However, as Frankie is moderate risk-averse investor, we can take the stocks as majority of stocks are lowly correlated with each other. 
print("Correlation Matrix:")
print(cor_matrix)


# Now as we have checked that the stocks are lowly correlated to each other, this gives us a green light to continue constructing an efficient portfolio with optimal weights of each stocks. Let's calculate the optimal weights of each stocks to construct the most efficient portfolio!
# Install and load necessary packages
install.packages("PortfolioAnalytics")
install.packages("xts")
install.packages("DEoptim")

library(PortfolioAnalytics)
library(xts)
library(DEoptim)

# Step 6: Define the portfolio.
portfolio <- portfolio.spec(assets = colnames(returns))

# Step 7: Add constraints. Box constraint ensures that each weight of stocks is between 0 and 1.The weight_sum constraint ensures that total weights sums up to 1 = 100%. This also can be close to 1 such as 0.99 to 1.01.
portfolio <- add.constraint(portfolio, type = "box", min = 0, max = 1)  # Weight limits
portfolio <- add.constraint(portfolio, type = "weight_sum", min_sum = 0.99, max_sum = 1.01)  # Full investment constraint

# Step 8: Add objectives of Frankie's request. 
# Minimize risk (Standard Deviation)
portfolio <- add.objective(portfolio, type = "risk", name = "StdDev")
# Maximize returns (mean)
portfolio <- add.objective(portfolio, type = "return", name = "mean")

# Step 9: Prepare returns data. Convert returns to xts time-series object for it to be compatible with optimization functions.
returns_xts <- xts(returns, order.by = as.Date(all_prices$Date))

# Step 10: Optimize the portfolio. We are using DEoptim method to optimize our portfolio as it maximizes returns while minimizing risks according to our constraints and objectives above.
optimized_portfolio <- optimize.portfolio(
  R = returns_xts,
  portfolio = portfolio,
  optimize_method = "DEoptim",
  trace = TRUE
)

# Step 11: Display results. This will show us weights of each stocks for the most efficient portfolio. Portfolio metrics shows us the risk of our portfolio and expected return (mean).
print("Optimized Portfolio Weights:")
print(extractWeights(optimized_portfolio))
print("Portfolio Metrics:")
print(optimized_portfolio)

# Step 12: Efficient frontier calculation
efficient_frontier <- create.EfficientFrontier(
  R = returns_xts,          
  portfolio = portfolio,    
  type = "mean-StdDev"      # Risk-return type (mean and StdDev)
)

# Now that we have the optimal weights, we can move on to plotting the efficient frontier and check if our portfolio lies on the frontier according to the weights calculated above!
install.packages("ROI") #tool for handling optimization problems in a flexible and extensible way
install.packages("PerformanceAnalytics") 
install.packages("quadprog") #tool used for solving quadratic programming problems efficiently

library(ROI)
library(PerformanceAnalytics)
library(quadprog)

# Step 13: Calculate the total risk of the portfolio based on the optimal weights of stocks and their covariance matrix.
portfolio_risk <- function(weights, cov_matrix) {
  sqrt(t(weights) %*% cov_matrix %*% weights)
}

# Step 14: Number of stocks
n_assets <- ncol(returns_xts)

# Step 15: Expected returns for stocks
mean_returns <- colMeans(returns_xts)

# Step 16: Covariance matrix of returns
cov_matrix <- cov(returns_xts)

# Step 17: Create sequence of target returns for the efficient frontier.
target_returns <- seq(min(mean_returns), max(mean_returns), length.out = 100)

# Step 18: Store the risks and weights for each portfolio on the efficient frontier.
frontier_risk <- numeric(length(target_returns))
frontier_weights <- matrix(NA, nrow = length(target_returns), ncol = n_assets)

# Step 19: Loop to calculate Efficient Frontier
for (i in seq_along(target_returns)) { #finds portfolio weights that minimize risks and loops it together 
  Dmat <- 2 * cov_matrix  #used to calculate portfolio risk in the optimization process. It tells us how much each stock's return fluctuates and how they are affected by each other. 
  dvec <- rep(0, n_assets)  # set to 0 as we want the risk to be minimized 
  Amat <- cbind(1, mean_returns, diag(n_assets))  # all the weights need to sum up to 1 and must achieve the target return, we also can't sell any stocks (only buy).
  bvec <- c(1, target_returns[i], rep(0, n_assets)) 
  solution <- solve.QP(Dmat, dvec, Amat, bvec, meq = 2)  #calculates the exact amount of weights we need to achieve the target return with the lowest level of risk.
  frontier_weights[i, ] <- solution$solution #stores the amount of weights calculated
  frontier_risk[i] <- portfolio_risk(solution$solution, cov_matrix) #stored the level of risks calculated
}

# Step 20: Calculate optimized portfolio return and risk
optimized_weights <- frontier_weights[which.max(target_returns / frontier_risk), ]  #finds the portfolio with the highest Sharpe Ratio. Higher ratio, suggests better performance of the portfolio.
optimized_return <- sum(mean_returns * optimized_weights) #by using the optimized_weights, it calculates the return
optimized_risk <- portfolio_risk(optimized_weights, cov_matrix) #by using the optimized weights, it calculates the risks

# Step 21: Plot the Efficient Frontier
plot(frontier_risk, target_returns, type = "l", col = "blue", lwd = 2,
     main = "Efficient Frontier of Portfolio",
     xlab = "Risk (Standard Deviation)", ylab = "Return")

# Step 22: Add individual stocks to the plot
points(apply(returns_xts, 2, sd), mean_returns, col = "red", pch = 16)

# Step 23: Add the optimized portfolio to the plot. As the portfolio lies on the efficient frontier, this suggests that the portfolio is efficient and we have achieved client's goal!
points(optimized_risk, optimized_return, col = "green", pch = 17, cex = 2)  # Optimized Portfolio

# Step 24: Add a legend (optional)
legend("bottomright", legend = c("Efficient Frontier", "Individual Stocks", "Optimized Portfolio"),
       col = c("blue", "red", "green"), lwd = 2, pch = c(NA, 16, 17), pt.cex = c(NA, 1, 2))


# Equally Weighted Portfolio for comparison
# Install necessary packages (if not already installed)
install.packages("tidyverse") #tool for data manipulation, visualization and analysis
install.packages("matrixStats") #tool that helps us to do quick and easy math on rows and columns of a table

library(tidyverse)
library(matrixStats)

# Equal weights for the portfolio. In our case, it will be 20% for each stock. 
weights <- rep(1 / n_assets, n_assets)

# Calculate the mean return (expected return without weights) for each stock.
mean_returns <- colMeans(returns_xts, na.rm = TRUE)

# Calculate the covariance matrix of stock returns. Covariance matrix will help us understand how each stocks are related to each other.
cov_matrix <- cov(returns_xts, use = "complete.obs")

# Portfolio expected return
portfolio_return <- sum(weights * mean_returns)

# Portfolio variance and standard deviation (risk). We will need to convert our variance to standard deviation as Efficient Frontier of Portfolio computed risk of the portfolio in standard deviation and not variance.
portfolio_variance <- t(weights) %*% cov_matrix %*% weights
portfolio_std_dev <- sqrt(portfolio_variance)

# Output results
cat("Portfolio Expected Return:", round(portfolio_return, 4), "\n")
cat("Portfolio Risk (Standard Deviation):", round(portfolio_std_dev, 4), "\n")

#Efficient Frontier Results 
# Expected Return = 0.001118
# Risk = 0.01482
# PKO weight = 0.152
# KRUK weight = 0.262
# BENEFIT weight = 0.214
# PKN weight = 0.156
# ATC weight = 0.208

#Equally Weighted Portfolio Results
# Expected Return = 0.0011
# Risk = 0.0149
# PKO weight = 0.2
# KRUK weight = 0.2
# BENEFIT weight = 0.2
# PKN weight = 0.2
# ATC weight = 0.2

#In the end, the portfolio's final results are very similar to each other however, as Efficient Frontier results are slighlty higher in terms of returns and lower in terms of risks. We should recommend Frankie to invest in portfolio constructed using efficient frontier concept where each weight of the stocks vary. 