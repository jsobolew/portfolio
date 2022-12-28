library(ggplot2)
library(tidyr)

inflation <- read.csv(file = 'C:/Users/QbaSo/Desktop/sem2/SAD/projekt/EU_Inflation_HICP_data.csv',sep = ',')
deposits <- read.csv(file = 'C:/Users/QbaSo/Desktop/sem2/SAD/projekt/EU_deposits_1yr_data.csv',sep = ',')

# 1
ggplot(data = inflation[1:180,], aes(x = X, y = Germany, group=1)) + 
  theme(legend.position="top") +
  geom_line(color="red") +
  geom_line(aes(y=Spain), color="red") +
  geom_line(aes(y=France), color="red") +
  geom_line(aes(y=Poland), color="blue") +
  geom_line(aes(y=Bulgaria), color="blue") +
  geom_line(aes(y=Hungary), color="blue") +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) + 
  xlab("data") + ylab("inflacja")

ggplot(data = inflation[1:180,], aes(x = X, y = Austria, group=1)) +
  geom_line(color="red") +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
  xlab("data")

# 2

ggplot(data = inflation[1:180,], aes(x = X, y = Germany, group=1)) +
geom_line(color="blue") +
geom_line(data=deposits[1:180,], aes(x=Time, y = Germany), color="red")+ 
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE))

ggplot(data = inflation[1:180,], aes(x = X, y = Spain, group=1)) +
  geom_line(color="blue") +
  geom_line(data=deposits[1:180,], aes(x=Time, y = Spain), color="red")+ 
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE))

ggplot(data = inflation[1:180,], aes(x = X, y = Poland, group=1)) +
  geom_line(color="blue") +
  geom_line(data=deposits[1:180,], aes(x=Time, y = Poland), color="red")+ 
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE))


# 3

hist(inflation[1:180, 'France'], freq=FALSE)
x <- seq(-1, 8, by=0.01)
y <- dnorm(x, mean(inflation[1:180, 'France']), sqrt(var(inflation[1:180, 'France'])))
lines(x, y)


makeHistogram <- function(country, from, to) {
  data <- drop_na(inflation[country])
  data <- (data[from:to, country])
  hist(data, freq=FALSE, main=paste("inflation in ",country, "from", inflation[to,'X'], "to", inflation[from,'X']))
  x <- seq(min(data), max(data), by=0.01)
  y <- dnorm(x, mean(data), sqrt(var(data)[1]))
  lines(x, y)
}

makeHistogramDiff <- function(country, from, to) {
  data <- drop_na(inflation[country])
  data <- -diff(data[from:to, country])
  hist(data, freq=FALSE, main=paste("diff inflation in ",country, "from", inflation[to,'X'], "to", inflation[from,'X']))
  x <- seq(min(data), max(data), by=0.01)
  y <- dnorm(x, mean(data), sqrt(var(data)[1]))
  lines(x, y)
}

makeHistogram("Germany", 1, 180)
makeHistogramDiff("Germany", 1, 180)

makeHistogram("Germany", 150, 170)
makeHistogramDiff("Germany", 150, 170)

makeHistogram("Poland", 1, 180)
makeHistogramDiff("Poland", 1, 180)

makeHistogram("Poland", 150, 170)
makeHistogramDiff("Poland", 150, 170)

makeHistogram("Germany", 1, 30)
makeHistogramDiff("Germany", 1, 30)

makeHistogram("Poland", 1, 30)
makeHistogramDiff("Poland", 1, 30)


makeHistogram("Bulgaria", 1, 180)
makeHistogramDiff("Bulgaria", 1, 180)

makeHistogram("Bulgaria", 150, 170)
makeHistogramDiff("Bulgaria", 150, 170)

makeHistogram("Bulgaria", 1, 30)
makeHistogramDiff("Bulgaria", 1, 30)

require(zoo)
to <- 1
from <- 280
country = "Poland"
data <- drop_na(inflation[country])
data <- (data[from:to, country])

TS <- zoo(data)
averageInflationPL <- rollapply(TS, width = 24, by = 1, FUN = mean, align = "left")
inflation[257:1,'averageInflationPL'] = averageInflationPL

ggplot(data = inflation[1:180,], aes(x = X, y = Poland, group=1)) +
  geom_line(color="blue") + 
  geom_line(aes(x=X, y = averageInflationPL), color="red")

# PROBLEM 2
Energy <- read.csv(file = 'C:/Users/QbaSo/Desktop/sem2/SAD/projekt/amChartsenergy.csv',sep = ',')
Energy['s1'] = Energy['s1']/2

ggplot(data = inflation[1:180,], aes(x = X, y = Austria, group=1)) +
  geom_line(data = Energy[150:320,], aes(x = date, y = s1, group=1)) +
  geom_line(color="red") +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
  xlab("data")

Shugar <- read.csv(file = 'C:/Users/QbaSo/Desktop/sem2/SAD/projekt/amChartsShugar.csv',sep = ',')
Shugar['s1'] = Shugar['s1']

ggplot(data = inflation[1:180,], aes(x = X, y = Austria, group=1)) +
  geom_line(color="red") +
  geom_line(data = Shugar[150:320,], aes(x = date, y = s1, group=1)) +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE))
