# Portfolio Optimization & Project Description
This is a repository that includes codes to construct the most optimally efficient portfolio based on Warsaw Stock Exchange to help risk-averse investors make informed decisions. 

As the financial market and the economy is growing globally, many investors across the globe found investing in financial securities to be a great source of income.
These financial securities can be divided into several different products which institutions offer. For instance, governments tend to issue treasury bills and  bonds which gives the investors coupons (interest earned on the investment) until the time of maturity. Not only does the government is involved in financial sector however, many companies as well. 

At the stock exchange market, there are a lot of companies where they trade various companies' shares. As purchasing companies' stock gives higher return than investing in treasury securities, many investors tend to purchase stocks of companies hoping to earn abnormal returns. However, as the return on the securities are higher, the risk is much higher compared to safer securities as treasury securities. Due to the high level of risk, not every investors purchase stocks of a company but direct to a lot more safer investment options. 

As much as the investment is safer, the low returns on the investment left our client (Frankie Walsh) dissatisfied with the performance of the portfolio and have inquired us to build a whole new portfolio that is efficient. Efficient portfolio refers to a portfolio of stocks with different combination of stocks to receive the highest amount of returns by taking the lowest amount of risk. As Frankie is moderate risk-averse investor, residing in Warsaw, Poland, we will construct a portfolio of 6 stocks that are listed in the Warsaw Stock Exchange market. Hence, our goal for this investment/project is to write a code that would maximize the return of Frankie's investment by minimizing the risk. 

# Client Information
Frankie Walsh (25 years old).

No debt/mortgage to pay.

Goal on investment: to gain the highest amount of yield (return) by taking the lowest level of risk according to stocks listed on WSE.

Duration: 3 years (01.01.2022 - 01.01.2025).

Risk preference: moderate risk-averse. 

Strictly wants to invest in stocks listed in the WSE. 

# Returns
Choice of 6 stocks:

PKO: a multinational banking and financial services company in Poland. 

KRUK: a receivables management market in Poland. 

BENEFIT: an institution that provides solutions in the field of non-wage benefits for employees in the area of ​​sports and recreation and employee well-being.

DVL: the largest real estate developer in Poland.

ATC: a company specializes in production and sale of paper and pulp.

JSW: the largest producer of high-quality type of coal in Poland and EU. 

Stocks are chosen based on stable sectors such as, banking, oil, raw material manufacturing, real estate and more. We have decided to omit highly volatile sectors such as, gaming industry and technology sector due to client's risk preference. 

# Data
We have downloaded the closing prices of each stocks above from https://stooq.pl with frequency of daily prices. 

# Correlation Matrix
As Frankie is a moderate risk-averse investor, it is crucial to find stocks that are lowly correlated to each other. This is one of the key assumptions of efficient portfolio, all the stocks must be lowly correlated in order to minimize the risk. If the stocks are highly correlated to each other, we need to find a new stock where the correlation coefficient is closer to 0. 
Hence, it is crucial to conduct correlation matrix prior to constructing an efficient portfolio. Computing the matrix does not only help with detecting highly correlated assets to reduce risk however, helps balance portfolio by interpreting how assets move together and selecting optimal weights for each stocks. 
The correlation coefficient of each stocks with each other (in our case, PKO, KRUK, BENEFIT, DVL, ATC, JSW) should be close to 0. Once it is close to 0, we can move onto calculating the optimal weights for each stocks that will be plotted on the efficient frontier.

# Efficient Frontier
Efficient frontier is a graph that plots a set of optimal portfolios that provides the investor with the highest expected return for a certain level of risk which the investor can tolerate or the lowest risk level. It is one of a concept from modern portfolio theory. 
The efficient frontier plots a curve of a risk-return graph. The X-axis represents risk (standard deviation) of portfolio and the Y-axis represents return of portfolio. 
The portfolio which lies on the frontier is considered to be optimal and most efficient portfolio that provides maximum expected return for a certain level of risk. Portfolios which are not lying on the frontier are not optimal and should be disregarded as it does not match our investment goal (finding the most efficient portfolio). 
Plotting the efficient frontier and checking if our portfolio lies on the frontier will help Frankie to make deicsions by identifying portfolios that are in line with her risk preference and return expectations. 

# Equally Weighted Portfolio
Equally Weighted Portfolio is a portfolio which assigns equal amount of weights to each stocks in the portfolio irrespective of their risk and expected return. Efficient frontier concept is not used in MVP as we do not have to find out optimal weights for each stocks to construct the most efficient portfolio. This concept is one of the simplest method of attempting to build the most efficient portfolio. We can compare the expected return and the level of risk of our portfolio when we equally weight the stocks to our portfolio's performance using optimally weighted stocks based on Efficient Frontier. 

For our portfolio, as we chose 6 stocks, all the stocks will be assigned with 16.7% of weights.

# Final Advice
As Frankie wishes to achieve the highest return at the minimum level of risk, we should recommend Frankie to choose portfolios with optimally weighted stocks as it gives higher return for lower risk. 
