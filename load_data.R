#############   Download and unzip data if not already done    ###############

if (!file.exists("./data")) { # Create a data folder if needed
        dir.create("./data") 
} 

url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip?accessType=DOWNLOAD"

destfile = file.path( "./data" , "Household Power Consumption.zip" )

if (!file.exists(destfile)) { # Download zipped file if it is not already done
        download.file( url = url, 
                       destfile = destfile, 
                       mode = "wb") # Windows. Other OS may use method=curl
} 

datafolder <- file.path("./data" , "Household Power Consumption")

if (!file.exists(datafolder)) { # Unzip it if is not already done
        unzip(destfile, exdir='./data')  
}


#############   Estimate memory usage for entire file    ###############

top1000.size <- object.size(read.table("./data/household_power_consumption.txt", sep=";", nrow=1000))
lines <- 2075259 
size.estimate <- lines / 1000 * top1000.size # Est. < 300 Mb


#############   Read data, subset to given dates and convert to date/time   ###############

df <- read.table("./data/household_power_consumption.txt", 
                 header = TRUE,
                 sep = ";",
                 na.strings = "?",
                 stringsAsFactors = FALSE
                 )

df <- subset(df, Date=="1/2/2007" | Date=="2/2/2007") 

df$Date <- as.Date(df$Date, "%d/%m/%Y")
df$Time <- strftime(strptime(df$Time, format="%T"), "%T") ## %T equals %H:%M:%S

#############    Alternative read.csv.sql approach   ##############
library(sqldf)
file <- "data/household_power_consumption.txt"
sql <- "select Date, Time, case when Global_active_power = '?' then replace(Global_active_power,'?','-999') else Global_active_power end as Global_active_power from file where Date = '21/12/2006'"
df2 <- read.csv.sql(file=file, 
                    sql=sql, 
                    header=TRUE, 
                    sep = ";")
# no time to complete, would have to select all fields like this, and then change -999 to NA in the data frame


#############     Readlines approach    ################
# no time to analyze this viable option

