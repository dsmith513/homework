# 1. A pepper enthusiast puts together the following data set about different peppers (ranked
# from least spicy to most spicy), how hot they are, and how many days it takes to grow
# the pepper plants from seed. Pepper is the name of the pepper, Scoville Units is how hot
# the pepper is in thousands (the larger the number, the hotter the pepper), and Growing
# Time represents how many days on average it takes to grow the pepper from seed.

# (a) Create a vector called pepper consisting of the words Bell, Tabasco, Ghost.

pepper <- c("Bell", "Tabasco", "Ghost")

# (b) Create a vector called scoville consisting of the Scoville Units as numbers.

scoville <- c(0, 50, 855)

# (c) Create a vector called days consisting of the Growing Times as numbers.

days <- c(75, 80, 120)

# (d) Combine these three vectors to create a data frame called HeatScale.

HeatScale <- data.frame(pepper, scoville, days)

# (e) One of the hottest peppers in the world is the Carolina Reaper. The Reaper has a
# Scoville Unit (in thousands) of 2000, and a growing time in days of about 95 days.
# Create a vector called reaper_row consisting of the values "Reaper", 2000, 95.

reaper_row <- c("Reaper", 2000, 95)

# (f) Add reaper_row as a row to HeatScale. Make sure you work with the data frame
# you previously created, and not the original vectors.

HeatScale <- rbind(HeatScale, reaper_row)

# (g) Determine the variable type of each variable in HeatScale and describe any issues,
# if any, you observe. Include any code used and include your values as a comment.

# > str(HeatScale)
# 'data.frame':	4 obs. of  3 variables:
#   $ pepper  : chr  "Bell" "Tabasco" "Ghost" "Reaper"
# $ scoville: chr  "0" "50" "855" "2000"
# $ days    : chr  "75" "80" "120" "95"
# 
# The scoville and days variables are characters when logically
# it would make more sense for them to be numbers.

# (h) Convert each variable to an appropriate type (numeric, character, factor, or ordered
# factor) within the data frame. For each type you choose, explain why you picked that
# type. Include your values as a comment in your code. Notice that as we go from Bell
# to Reaper that the Scoville units gets larger (least hot to most hot). Hint: Here is a
# list of functions you might use in your conversions: as.numeric(), as.character(),
# factor(), ordered().

HeatScale$days <- as.numeric(HeatScale$days)
HeatScale$scoville <- as.numeric(HeatScale$scoville)
