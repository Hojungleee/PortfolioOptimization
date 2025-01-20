# In order to build an efficient portfolio, we must compute correlation matrix in order to see if the stocks are related to each other. In our case, as Frankie is risk-averse investor and she wants an efficient portfolio, we must try to choose the stocks which correlation coefficient is close to 0. 
# Install and load necessary packages
install.packages(c("quantmod", "PerformanceAnalytics", "PortfolioAnalytics", "xts", "quadprog"))
library(quantmod) #tool designed for quantitative financial modeling and trading analysis
library(PerformanceAnalytics) #tool used for performance and risk analysis of financial portfolios
library(PortfolioAnalytics) #tool used for creating, analyzing, and optimizing portfolios using various risk-return objectives and constraint
library(xts) #tool used for managing and manipulating time-series data which is crucial when using finacial data
library(quadprog) #tool used for solving quadratic programming problems efficiently

# Clear environment and console
rm(list = ls())
cat("\014")

# Step 1: Read CSV files for each stock. In my case, as Frankie wants stocks listed on WSE, I have chosen PKO, KRUK, BENEFIT, DVL, ATC, and JSW. The data are downloaded from https://stooq.com.
pko_data <- read.csv("/Users/hojunglee/Downloads/pko_d.csv")
kruk_data <- read.csv("/Users/hojunglee/Downloads/kru_d.csv")
benefit_data <- read.csv("/Users/hojunglee/Downloads/bft_d.csv")
dvl_data <- read.csv("/Users/hojunglee/Downloads/dvl_d.csv")
atc_data <- read.csv("/Users/hojunglee/Downloads/atc_d.csv")
jsw_data <- read.csv("/Users/hojunglee/Downloads/jsw_d.csv")

# Step 2: Extract relevant columns (Date and Close prices). Once we download stock prices in CSV format from Stooq, there are 6 columns including Date, Close, Open, and more. However, for our analysis we only need the "date" and "closing prices". 
pko_prices <- pko_data[, c("Date", "Close")]
kruk_prices <- kruk_data[, c("Date", "Close")]
benefit_prices <- benefit_data[, c("Date", "Close")]
dvl_prices <- dvl_data[, c("Date", "Close")]
atc_prices <- atc_data[, c("Date", "Close")]
jsw_prices <- jsw_data[, c("Date", "Close")]

# Rename columns for clarity.
names(pko_prices)[2] <- "PKO"
names(kruk_prices)[2] <- "KRUK"
names(benefit_prices)[2] <- "BENEFIT"
names(dvl_prices)[2] <- "DVL"
names(atc_prices)[2] <- "ATC"
names(jsw_prices)[2] <- "JSW"

# Step 3: Merge all data by Date.We will merge each dataset into 1 to ensure all stock prices are aligned by trading dates.
all_prices <- Reduce(function(x, y) merge(x, y, by = "Date", all = FALSE), 
                     list(pko_prices, kruk_prices, benefit_prices, dvl_prices, atc_prices, jsw_prices))

# Step 4: Calculate daily returns. We will omit the first row as the returns are calculated by substracting yesterday's price from today's price then dividing it by yesterday's price. Hence, the first price will remain empty giving 749 observations. 
returns <- all_prices
returns[-1] <- apply(all_prices[-1], 2, function(x) c(NA, diff(x) / head(x, -1)))
returns <- na.omit(returns)  # Remove NA rows

# Step 5: Calculate correlation matrix. Most correlation coefficient of 6 chosen stocks are close to 0 except KRUK with PKO and DVL with PKO However, as Frankie is moderate risk-averse investor, we can take the stocks as majority of stocks are lowly correlated with each other. 
cor_matrix <- cor(returns[-1])
cat("Correlation Matrix:\n")
print(cor_matrix)

# Now as we have checked that the stocks are lowly correlated to each other, this gives us a green light to continue constructing an efficient portfolio with optimal weights of each stocks. Let's calculate the optimal weights of each stocks to construct the most efficient portfolio!
# Step 6: Define portfolio specification.
portfolio <- portfolio.spec(assets = colnames(returns)[-1])

# Add constraints. Box constraint ensures that each weight of stocks is between 0 and 1.The weight_sum constraint ensures that total weights sums up to 1 = 100%. This also can be close to 1 such as 0.99 to 1.01.
portfolio <- add.constraint(portfolio, type = "box", min = 0, max = 1)
portfolio <- add.constraint(portfolio, type = "weight_sum", min_sum = 0.99, max_sum = 1.01)

# Add objectives of Frankie's request.
portfolio <- add.objective(portfolio, type = "risk", name = "StdDev")
portfolio <- add.objective(portfolio, type = "return", name = "mean")

# Convert returns to xts format. Convert returns to xts time-series object for it to be compatible with optimization functions.
returns_xts <- xts(returns[-1], order.by = as.Date(returns$Date))

# Step 7: Optimize the portfolio. We are using DEoptim method to optimize our portfolio as it maximizes returns while minimizing risks according to our constraints and objectives above.
optimized_portfolio <- optimize.portfolio(R = returns_xts, portfolio = portfolio, 
                                          optimize_method = "DEoptim", trace = TRUE)

# Display results. This will show us weights of each stocks for the most efficient portfolio. Portfolio metrics shows us the risk of our portfolio and expected return (mean).
cat("Optimized Portfolio Weights:\n")
optimal_weights <- extractWeights(optimized_portfolio)
print(optimal_weights)
cat("Portfolio Metrics:\n")
print(optimized_portfolio)

# Step 8: Calculate efficient frontier
mean_returns <- colMeans(returns_xts)
cov_matrix <- cov(returns_xts)
n_assets <- ncol(returns_xts)
target_returns <- seq(min(mean_returns), max(mean_returns), length.out = 100)

frontier_risk <- numeric(length(target_returns))
frontier_weights <- matrix(NA, nrow = length(target_returns), ncol = n_assets)

for (i in seq_along(target_returns)) { #finds portfolio weights that minimize risks and loops it together 
  Dmat <- 2 * cov_matrix #used to calculate portfolio risk in the optimization process. It tells us how much each stock's return fluctuates and how they are affected by each other. 
  dvec <- rep(0, n_assets) #set to 0 as we want the risk to be minimized 
  Amat <- cbind(1, mean_returns, diag(n_assets)) #all the weights need to sum up to 1 and must achieve the target return, we also can't sell any stocks (only buy).
  bvec <- c(1, target_returns[i], rep(0, n_assets)) 
  solution <- solve.QP(Dmat, dvec, Amat, bvec, meq = 2) #calculates the exact amount of weights we need to achieve the target return with the lowest level of risk.
  frontier_weights[i, ] <- solution$solution #stores the amount of weights calculated
  frontier_risk[i] <- sqrt(t(solution$solution) %*% cov_matrix %*% solution$solution) #stores the level of risks calculated
}

# Now that we have the optimal weights, we can move on to plotting the efficient frontier and check if our portfolio lies on the frontier according to the weights calculated above!
# Step 9: Plot Efficient Frontier with individual stocks and optimal portfolio
plot(frontier_risk, target_returns, type = "l", col = "blue", lwd = 2,
     main = "Efficient Frontier of Portfolio",
     xlab = "Risk (Standard Deviation)", ylab = "Return")

# Add individual stocks to the plot.
points(apply(returns_xts, 2, sd), mean_returns, col = "red", pch = 16)

# Add the optimized portfolio to the plot. As the portfolio (green triangle) lies on the efficient frontier, this suggests that the portfolio is efficient and we have achieved client's goal! Additionally, the portfolio lying on the frontier suggests that our portfolio is both well-diversified and meets the specified objectives (e.g., highest Sharpe ratio or target return). Compared to the individual stocks, the optimized portfolio achieves a better return-to-risk ratio, showcasing the benefits of combining assets into a portfolio rather than investing in a single stock.
optimized_risk <- sqrt(t(optimal_weights) %*% cov_matrix %*% optimal_weights)
optimized_return <- sum(mean_returns * optimal_weights)
points(optimized_risk, optimized_return, col = "green", pch = 17, cex = 2)

# Add a legend
legend("bottomright", legend = c("Efficient Frontier", "Individual Stocks", "Optimized Portfolio"),
       col = c("blue", "red", "green"), lwd = 2, pch = c(NA, 16, 17), pt.cex = c(NA, 1, 2))





# Equally Weighted Portfolio for comparison! This is one of the most simplest way to diversify a portfolio attempting to achieve efficient portfolio.
install.packages("tidyverse") #tool for data manipulation, visualization and analysis
install.packages("matrixStats") #tool that helps us to do quick and easy math on rows and columns of a table

library(tidyverse)
library(matrixStats)

# Equal weights for the portfolio. In our case, it will be 16.7% for each stock. 
weights <- rep(1 / n_assets, n_assets)

# Portfolio expected return
portfolio_return <- sum(weights * mean_returns)

# Portfolio variance and standard deviation (risk). We will need to convert our variance to standard deviation as Efficient Frontier of Portfolio computed risk of the portfolio in standard deviation and not variance.
portfolio_variance <- t(weights) %*% cov_matrix %*% weights
portfolio_std_dev <- sqrt(portfolio_variance)

# Output results
cat("Portfolio Expected Return:", round(portfolio_return, 4), "\n")
cat("Portfolio Risk (Standard Deviation):", round(portfolio_std_dev, 4), "\n")

#Efficient Frontier Results 
# Expected Return = 0.001347
# Risk = 0.01497
# PKO weight = 0.1219
# KRUK weight = 0.2323
# BENEFIT weight = 0.2064
# DVL weight = 0.1170
# ATC weight = 0.2750
# JSW weight = 0.0417

#Equally Weighted Portfolio Results
# Expected Return = 0.0011
# Risk = 0.0153
# PKO weight = 0.167
# KRUK weight = 0.167
# BENEFIT weight = 0.167
# PKN weight = 0.167
# ATC weight = 0.167
# JSW weight = 0.167
#In the end, the portfolio's final results are very similar to each other however, as Efficient Frontier results are slighlty higher in terms of returns and lower in terms of risks. We should recommend Frankie to invest in portfolio constructed using efficient frontier concept where each weight of the stocks vary. 