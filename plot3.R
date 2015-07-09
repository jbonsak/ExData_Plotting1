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

datafolder <- file.path("./data" , "household_power_consumption.txt")

if (!file.exists(datafolder)) { # Unzip it if is not already done
        unzip(destfile, exdir='./data')  
}


#############   Estimate memory usage for entire file    ###############

top1000.size <- object.size(read.table("./data/household_power_consumption.txt", sep=";", nrow=1000))
lines <- 2075259 
size.estimate <- lines / 1000 * top1000.size # Est. < 300 Mb, ok


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
df$DateTime <- as.POSIXct(paste(df$Date, df$Time))#, format="%Y-%m-%d %H:%M:%S") #Combine Date and Time into one object

###########    Plot 3     ##############

png("plot3.png",480,480)

oldlocale <- Sys.getlocale(category="LC_ALL") ## store current locale setting

Sys.setlocale(category = "LC_ALL", locale = "C")  ## change my locale to C language default locale, 
                                                  ## to show "Thu Fri Sat" 

with(df, plot(Sub_metering_1 ~ DateTime, type="l", xlab="", ylab="Energy sub metering")) 
lines(df$Sub_metering_2 ~ df$DateTime, col="red")
lines(df$Sub_metering_3 ~ df$DateTime, col="blue")
legend("topright", lwd=2, col=c("black", "red", "blue"), legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))

Sys.setlocale(category = "LC_ALL", locale = oldlocale)  ## switch back to original setting

dev.off()
