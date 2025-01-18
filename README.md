# Portfolio Optimization
This is a repository that includes codes to construct the most optimally efficient portfolio based on Warsaw Stock Exchange to help risk-averse investors make informed decisions. 

As the financial market and the economy is growing globally, many investors across the globe found investing in financial securities to be a great source of income.
These financial securities can be divided into several different products which institutions offer. For instance, governments tend to issue treasury bills and  bonds which gives the investors coupons (interest earned on the investment) until the time of maturity. Not only does the government is involved in financial sector however, many companies as well. 

At the stock exchange market, there are a lot of companies where they trade various companies' shares. As purchasing companies' stock gives higher return than investing in treasury securities, many investors tend to purchase stocks of companies hoping to earn abnormal returns. However, as the return on the securities are higher, the risk is much higher compared to safer securities as treasury securities. Due to the high level of risk, not every investors purchase stocks of a company but direct to a lot more safer investment options. 

As much as the investment is safer, the low returns on the investment left our client (Frankie Walsh) dissatisfied with the performance of the portfolio and have inquired us to build a whole new portfolio that is efficient. Efficient portfolio refers to a portfolio of stocks with different combination of stocks to receive the highest amount of returns by taking the lowest amount of risk. As Frankie is highly risk-averse investor, residing in Warsaw, Poland, we will construct a portfolio of 5 stocks that are listed in the Warsaw Stock Exchange market. 

# Client Information
Frankie Walsh (25 years old).

No debt/mortgage to pay.

Working in a financial institution.

Goal on investment: to purchase a second-hand car (model: Citroën C1). 

Capital: 10,000 PLN.

Price of a second-hand car in 2025: 29,900 PLN.

Duration: 3 years (01.01.2025 - 01.01.2028).

Highly risk-averse and wishes to pay for the second-hand car entirely with the return earned from portfolio without paying from her own current wallet. 

Strictly wants the stocks listed in the WSE. 

# Efficient Frontier
A concept from Modern Portfolio Theory that represents a set of optimal investment portfolios. These portfolios offer the highest possible expected return for a given level of risk or the lowest possible risk for a given level of return. 
Portfolios that lie below the efficient frontier are considered suboptimal because they either carry unnecessary risk for their level of return or provide less return for their level of risk. The efficient frontier helps investors make decisions about asset allocation based on their risk tolerance and investment goals.
Hence, we need to apply efficient frontier on the portfolio which will be built for Frankie to acheive the investment goal taking into consideration of her risk-preference. 

# Returns
Initial choice of stocks:
MBANK
PKO
KRUK
MONARI
JSW
KGHM
ATT
PGE
MABION
ASBIS
BENEFIT
ORLEN
SANOK
DIGITAL
PZU
EUROCASH
ARCTIC
DEVELIA
CD PROJECT
ALIOR

Stocks are chosen based on stable sectors such as, banking, pharmaceutical, auto-manufacting, oil, and real estate. We have decided to omit highly volatile sectors such as gaming industry and technology sector due to client's risk preference. 

# Correlation Matrix
The matrix shows the relationships between asset returns, with values ranging from -1 (perfect negative correlation) to +1 (perfect positive correlation). 


- Diversification: Identifies less or negatively correlated assets to reduce risk.
- Risk Management: Helps balance the portfolio by understanding how assets move together.
- Optimization: Key input for calculating portfolio risk and selecting optimal asset weights.

In short, it aids in achieving diversification and minimizing risk in portfolio construction.

# Data
We have downloaded the closing prices of each stocks above from https://stooq.pl with frequency of daily prices. 

