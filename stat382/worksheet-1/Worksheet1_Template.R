## Worksheet 1 Solutions


## Question 1 - Download file to your computer. No code required.




## Question 2 - Import Dataset and save it as laptop
laptop <- read.csv("laptop.csv")



## Question 3 - Use str() to determine the structure of your dataset
	# View the structure
  str(laptop)



	# Copy and Paste Results
  
  # 'data.frame':	1014 obs. of  8 variables:
  #   $ model_name     : chr  "Lenovo V15 ITL G2 82KBA033IH Laptop" "HP Pavilion 15-ec2004AX Gaming Laptop" "Lenovo V15 82KBA03HIH Laptop" "Asus Vivobook 16X 2022 M1603QA-MB502WS Laptop" ...
  # $ brand          : chr  "Lenovo" "HP" "Lenovo" "Asus" ...
  # $ processor_name : chr  "11th Gen Core i3" "AMD Ryzen 5 5600H" "11th Gen Core i3" "Ryzen 5-5600H" ...
  # $ ram            : int  8 8 8 8 8 8 16 8 8 8 ...
  # $ ssd            : int  512 512 256 512 512 256 512 512 512 512 ...
  # $ OperatingSystem: chr  "Windows" "Windows" "Windows" "Windows" ...
  # $ screen_size    : num  15.6 15.6 15.6 16 15.6 ...
  # $ no_of_cores    : int  2 6 2 6 4 4 14 2 6 2 ...



	# How many observations are there?
  # 1014

	# How many variables are there?
  # 8



## Question 4 - Create a vector called brand (see instructions for criteria)
brand <- laptop$brand



## Question 5 - Create the laptop2 data frame (see instructions for criteria)
laptop2 <- laptop[c("OperatingSystem", "screen_size", "no_of_cores")]

	
	
## Question 6 - Create the laptop3 data frame (see instructions for criteria)
laptop3 <- laptop[laptop$ram > 16 , ]


	
## Question 7 - Give the code that changes OperatingSystem to a factor on the laptop data frame
laptop$OperatingSystem <- factor(laptop$OperatingSystem)



	
	