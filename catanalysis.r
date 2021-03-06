# Instruction
# 1. Create a folder with the name of the experiment;
# 2. In the experiment folder, create a folder named "zip" and put all participant zip files into the "zip" folder;
# 3. Run the entire script ("function_list_pre.R"), then run "function_list_1.R", followed by "function_list_2.R";
# 4. To create dendrograms at different solutions, manually change the number in the last line of the script.
# 5. Go find the result in the experiment folder

# KlipArt Instruction
# A klipart folder will be created inside the experiment folder. In the klipart folder:
# 1. Zip the matrices folder into a zip file;
# 2. Put a icons.zip file that contains all the icon files.


#install.packages("gplots")
require(gplots)
#install.packages("vegan")
require(vegan)
#install.packages("clusteval")
require(clusteval)
require(grid)

# Clear the workspace
rm(list=ls())

# Begin user input #

# Path to where the experiment folder is
path <- "C:/Users/Sparks/Desktop/cattest/"
setwd(path)

# Define the name of the experiment
scenario.name <- "2501 geotermsN"

# Define the max number of clusters
max.cluster <- 9

# End user input #

# Checks if "/" exists after path. If not, one is added
if(substr(path, nchar(path), nchar(path)) != "/") {
	path <- paste(path, "/", sep = "")
}

# Auto-create two subfolders "ism" and "matrices"
dir.create(paste(path, "ism/", sep=""))
klipart.path <- paste(path, scenario.name, "-klipart/", sep = "")
dir.create(klipart.path)
dir.create(paste(klipart.path, "matrices/", sep="")) 
dir.create(paste(path, "matrices/", sep="")) 

 


# BEGIN: 
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################















#Icon counter: count the number of icons(items) used in the experiment
IconCounter <- function(path) {
	#Construct the zip folder path and list all the zip files
	zip.path <- paste(path, "zip/", sep = "")
	files <- list.files(zip.path)

	#Get the participant number for the first participant
	first.p.number <- substring(files[1], 1, nchar(files[1]) - 4)
	
	#Unzip the file
	first.p <- unzip(paste(zip.path, files[1], sep = ""))
	
	#Construct the full file name for icons.csv
	icons.csv <- paste("./", first.p.number, "/", substring(files[1],1,8), "icons.csv", sep = "")
	
	#Read in icons.csv
	icons <- read.csv(icons.csv, header = F)
	
	#Get the number of icons used in the experiment
	n.icons <- nrow(icons)
	
	#Return the number of icons
	return(n.icons)
}















# Icon list getter: get a list of icon names
# It also saves the icon.csv needed for KlipArt
IconListGetter <- function(path) {
	
	# Construct the zip folder path and list all the zip files 
	zip.path <- paste(path, "zip/", sep = "")
	files <- list.files(zip.path)
	
	# Unzip the zip file from the 1st participant
	first.p <- unzip(paste(zip.path, files[1], sep = ""))
	
	# Get the participant number for the first participant
	first.p.number <- substring(files[1], 1, nchar(files[1]) - 4)
	
	# Construct the full file name for icons.csv
	icons.csv <- paste("./", first.p.number, "/", substring(files[1],1,8), "icons.csv", sep = "")
	
	# Read in icons.csv
	icons <- read.csv(icons.csv, header = F, stringsAsFactors = F)
	
	# Reorder icon names by icon index
	icons <- icons[order(icons[, 1]), ]
	
	# Extract the icon names from the table (excluding the path name and file extensions)
	icon.list <- icons[, 2]
	for(i in 1:length(icon.list)) {
		end <- regexpr("\\.[^\\.]*$", icon.list[i])[1]
		icon.list[i] <- substr(icon.list[i], 9, end - 1)
	}
	
	# Extract the icon names with file type (e.g. .jpg) for KlipArt
	icon.list.klipart <- icons
	for(j in 1:nrow(icon.list.klipart)) {
		icon.list.klipart[j, 2] <- substr(icon.list.klipart[j, 2], 9, nchar(icon.list.klipart[j, 2]))
	}
	colnames(icon.list.klipart) <- c("index", "icon_names")
	
	# Sort the icon list by index
	icon.list.klipart <- icon.list.klipart[order(icon.list.klipart$index), ]
	
	# Export the list as a csv file
	write.table(icon.list.klipart, file = paste(klipart.path, "icon.csv", sep = ""),
			sep = ",", row.names = F,  col.names = F)
	
	#Return the icon list as a vector
	return(icon.list)
}















# Participant counter: count the number of participants
ParticipantCounter <- function(path) {
	
	#Construct the zip folder path and list all zip files
	zip.path <- paste(path, "zip/", sep = "")
	files <- list.files(zip.path)
	
	#Get the total number of participants (zip files)
	np <- length(files)
	
	#Return the total number of participants as an integer
	return(np)
}















# OSM and ISM Generator: extract all individual similarity matrices (ISMs) 
# and generate the overall similarity matrix(OSM) by summing up all ISMs
OsmIsmGenerator <- function(path) {
	# Construct the zip folder path and list all zip files
	zip.path <- paste(path, "zip/", sep = "")
	files <- list.files(zip.path)
	
	# Initialize osm with the 1st ISM
	participant1 <- unzip(paste(zip.path, files[1], sep = ""))
	
	# Get the participant number for the first participant
	first.p.number <- substring(files[1], 1, nchar(files[1]) - 4)
	
	# Construct the full file name for ISM file (mtrx file)
	first.ism <- paste("./", first.p.number, "/", substring(files[1],1,8), ".mtrx", sep = "")
	
	# Read in the ISM from the 1st participant and exclude the non-ism info from the .mtrx file
	first.matrix <- read.delim(first.ism, header = FALSE, sep = " ", stringsAsFactors = F)
	first.matrix <- data.matrix(first.matrix[1:IconCounter(path), ])
	
	# Export the first ISM
	write.table(first.matrix, file = paste(path, "ism/", "participant", 
                                        substr(files[1], 1, nchar(files[1]) - 4),
                                        ".mtrx",sep = ""), sep = " ", row.names = F, col.names = F)
	
	write.table(first.matrix, file = paste(path, "matrices/", "participant", 
                                        substr(files[1], 1, nchar(files[1]) - 4),
                                        ".mtrx",sep = ""), sep = " ", row.names = F, col.names = F)
	
	# Summing up all ISMs for OSM and export each ISM
	osm <- first.matrix
	
	# Process the ISMs of the rest of participants
	for(i in 2:length(files)) {
		# Unzip the participant's zip file
		participant.i <- unzip(paste(zip.path, files[i], sep = ""))
		
		# Get the participant number
		participant.number <- substring(files[i], 1, nchar(files[i]) - 4)
		
		# Construct the full file name for .mtrx file
		matrix.i.name <- paste("./", participant.number, "/", substring(files[i],1,8), ".mtrx", sep = "")
		
		# Read in the ISM from a participant and exclude the non-ism info from the .mtrx file
		matrix.i <- read.delim(matrix.i.name, header = F, sep = " ", stringsAsFactors = F)
		matrix.i <- data.matrix(matrix.i[1:IconCounter(path), ])
		
		# Export the ISM as .mtrx for KlipArt and .csv for catanalysis
		write.table(matrix.i, file = paste(path, "ism/", "participant", 
						substr(files[i], 1, nchar(files[i]) - 4),
						".mtrx", sep = ""), sep = " ", 
						row.names = F, col.names = F)
		
		write.table(matrix.i, file = paste(klipart.path, "matrices/", "participant", 
						substr(files[i], 1, nchar(files[i]) - 4), 
						".mtrx", sep = ""), sep = " ",
						row.names = F, col.names = F)
		
		write.table(matrix.i, file = paste(path, "matrices/", "participant", 
						substr(files[i], 1, nchar(files[i]) - 4), 
						".mtrx", sep = ""), sep = " ",
						row.names = F, col.names = F)
		
		# Add the ISM to OSM
		osm <- osm + matrix.i
	}
	
	# Export OSM
	write.table(osm, file = paste(path, "matrices/", "total.mtrx", sep = ""), 
			sep = " ", row.names = F,  col.names = F)
	
	write.table(osm, file = paste(klipart.path, "matrices/", "total.mtrx", sep = ""), 
			sep = " ", row.names = F,  col.names = F)
	
	osm <- cbind(IconListGetter(path), osm)
	write.table(osm, file = paste(path, "osm.csv", sep = ""), 
			sep = ",", row.names = F,  col.names = F)
}















# AssignmentGetter: generate the assignment.csv for KlipArt
AssignmentGetter <- function(path) {
	# Create an empty dataframe
	df <- data.frame()
	
	#List all zip files
	zip.path <- paste(path, "zip/", sep = "")
	files <- list.files(zip.path)
	
	for(i in 1:length(files)) {
		# Read in the assignment.csv file
		participant.i <- unzip(paste(zip.path, files[i], sep = ""))
		
		# Get the participant number for the first participant
		participant.number <- substring(files[i], 1, nchar(files[i]) - 4)
		
		# Construct the full file name for assignment.csv file
		participant.assignment <- paste("./", participant.number, "/", substring(files[i],1,8), 
				"assignment.csv", sep = "")
		
		assignment <- read.delim(participant.assignment, header = F, sep = ",", stringsAsFactors = F)
		df <- rbind(df, assignment)
	}
	# Export the assignment.csv
	write.table(df, file = paste(klipart.path, "assignment.csv", sep = ""),
			sep = ",", row.names = F,  col.names = F)
}















# exe
n.icons <- IconCounter(path)

all.icons <- sort(IconListGetter(path))

# ParticipantCounter(path)

OsmIsmGenerator(path)

AssignmentGetter(path)









# BEGIN: Part 2
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
















# Participant info: collect demographic info and basic experiment info (# of groups created
# and time spent in seconds)
ParticipantInfo <- function(path) {
	
	# Read in the zip file
	zip.path <- paste(path, "zip/", sep = "")
	files <- list.files(zip.path)
	
	# Read in to demographic info for the 1st participant
	participant1 <- unzip(paste(zip.path, files[1],sep = ""))
	
	# Get the participant number for the first participant
	first.p.number <- substring(files[1], 1, nchar(files[1]) - 4)
	
	# Construct the full file name for the participant.csv file for the 1st participant
	first.demo <- paste("./", first.p.number, "/", substring(files[1],1,8), "participant.csv", sep = "")
	
	# Read in the participant.csv for the 1st participant
	demo1 <- read.delim(first.demo, header = F, sep = ",",stringsAsFactors = F)
	
	# Aggregate eduction background for participant who use comma(s) in their eduction 
	# background (e.g., geography, education, business)
	while(length(demo1) > 13) {
		demo1[7] <- paste(demo1[7], demo1[8], sep = ",")
		demo1 <- demo1[-8]
	}

	colnames(demo1) <- 1:13
	
	# Initialize the dataframe for demographic info
	demographic <- demo1
	
	# Add demographic info from the rest of participants to the dataframe "demographic"
	for(i in 2:length(files)) {
		participant.i <- unzip(paste(zip.path, files[i], sep=""))
		
		# Get the participant number for the first participant
		participant.number <- substring(files[i], 1, nchar(files[i]) - 4)
		
		# Construct the full file name for participant.csv file
		participant.demo <- paste("./", participant.number, "/", substring(files[i],1,8), 
				"participant.csv", sep = "")
		
		# Read in the participant.csv
		demo <- read.delim(participant.demo, header = F, sep = ",", stringsAsFactors = F)
		while(length(demo) > 13) {
			demo[7] <- paste(demo[7], demo[8], sep = ",")
			demo <- demo[-8]
		}
		colnames(demo) <- 1:13
		demographic <- rbind(demographic, demo)
	}
	
	# Create two vectors to store the # of groups created and time spent (in seconds)
	groups.created <- c()
	time.spent <- c()
	
	for(i in 1:length(files)) {
		# Read in the assignment.csv file
		participant.i <- unzip(paste(zip.path, files[i], sep = ""))
		
		# Get the participant number for the first participant
		participant.number <- substring(files[i], 1, nchar(files[i]) - 4)
		
		# Construct the full file name for assignment.csv file
		participant.groups <- paste("./", participant.number, "/", substring(files[i],1,8), 
				"assignment.csv", sep = "")
		
		groups <- read.delim(participant.groups, header = F, sep = ",", stringsAsFactors = F)
		
		# Count the number of rows in the assignment file and convert it to the # of groups created
		groups <- length(unique(groups[, 2]))
		
		# Append the # of groups created to the vector "groups.created"
		groups.created <- append(groups.created, groups)
	}
	
	
	for(i in 1:length(files)) {
		# Read in the log file
		participant.i <- unzip(paste(zip.path, files[i], sep=""))
		
		# Get the participant number for the first participant
		participant.number <- substring(files[i], 1, nchar(files[i]) - 4)
		
		# Construct the full file name for .log file
		participant.log <- paste("./", participant.number, "/", substring(files[i],1,8), ".log", sep = "")
		
		# Read in the log file
		log <- read.delim(participant.log, header = F, sep=",", stringsAsFactors = F)
		
		# Get the time spent
		time <- log[nrow(log), ]
		time <- substr(time, 33, nchar(time))
		
		# Append the time spent to the vector "time.spent"
		time.spent <- append(time.spent, time)
	}
	
	# Append two vectors (i.e., two columns) - groups.created and time.spent to the demographic dataframe
	demographic <- cbind(demographic, groups.created)
	demographic <- cbind(demographic, time.spent)
	
	# Export the demographic dataframe as a csv file
	write.table(demographic, file = paste(path, "participant.csv", sep = ""),
			sep = ",", row.names = F,  col.names = F)
	
	# Export the participant.csv for KlipArt
	write.table(demographic, file = paste(klipart.path, "participant.csv", sep = ""), sep = ",", row.names = F,  col.names = F)
}















# DescriptionGetter: extract the linguistic labels (both long and short) from all participants and store in a single csv file
DescriptionGetter <- function(path) {
	
	# Construct the path for the zip folder and list all the zip files
	zip.path <- paste(path, "zip/", sep = "")
	files <- list.files(zip.path)
	
	# Unzip the zip file from the 1st participant
	participant1 <- unzip(paste(zip.path, files[1], sep =""))
	
	# Get the participant number for the first participant
	participant.number <- substring(files[1], 1, nchar(files[1]) - 4)
	
	# Construct the full file name for the batch.csv file
	batch <- paste("./", participant.number, "/", substring(files[1],1,8), "batch.csv", sep = "")
	
	description1 <- read.csv(batch, header = F, stringsAsFactors = F)
	
	# Aggregate participants' long descriptions when they use comma in the descriptions.
	while(length(description1) > 4) {
		description1[, 4] <- paste(description1[, 4], description1[,5], sep = ",")
		description1 <- description1[-5]
	}
	
	# Create dummy column names for the dataframe (will not be included when exported)
	colnames(description1) <- 1:4
	
	# Initialize a dataframe for all descriptions
	description <- description1
	
	# Read in the batch.csv for the rest of participants and extract the descriptions
	for(i in 2:length(files)) {
		
		# Read in the zip files
		participant.i <- unzip(paste(zip.path, files[i], sep = ""))
		description.i <- read.csv(sort(participant.i)[5], header = F, stringsAsFactors = F)
		
		# Aggregate participants' long descriptions when they use comma in the descriptions.
		while(length(description.i) > 4) {
			description.i[4] <- paste(description.i[, 4], description.i[, 5], sep = ",")
			description.i <- description.i[-5]
		}
		
		# Create dummy column names for the dataframe (will not be included when exported)
		colnames(description.i) <- 1:4
		
		# Combine descriptions from all participant into a dataframe (row-bind)
		description <- rbind(description, description.i)
	}
	
	# Export the description dataframe as a csv file
	write.table(description, file = paste(path, "description.csv", sep = ""), 
			sep = ",", row.names = F,  col.names = F)
	
	# Export batch.csv for Klipart
	write.table(description, file=paste(klipart.path, "batch.csv", sep = ""), sep = ",", col.names=  F, row.names = F)
}















# OsmViz: generates a heatmap based on the OSM.
# No dendrograms are generated and the icons are in alphabetical order
# Jinlong: It is intended to be a raw heat map without dendrograms. 
# The cluster heatmap function is right below this function
OsmViz <- function(path, osm.path) {
	
	# Read in the osm.csv file and format the row/column names
	d <- read.csv(osm.path, header = F)
	dm <- as.matrix(d[, -1])
	dimnames(dm) <- list(d[, 1], d[, 1])
	
	# Drawing the heatmap and export as a jpeg file
	jpeg(filename = paste(path, "heat_map.jpeg", sep = ""),width = 2000, height = 2000, units = "px",
			pointsize = 5, bg = "white", res = 700)
	heatmap.2(as.matrix(ParticipantCounter(path) - dm), Rowv = F, Colv = "Rowv", dendrogram = "none", 
			margin = c(4, 4), cexRow = 0.35, cexCol = 0.35, revC = F, trace = "none", key = F)
	dev.off()
}















# ClusterHeatmap: generates a cluster heatmap based on the OSM
ClusterHeatmap <- function(path, osm.path) {
	
	# Read in the osm.csv file and format the row/column names
	d <- read.csv(osm.path, header = F)
	dm <- as.matrix(d[, -1])
	dimnames(dm) <- list(d[, 1], d[, 1])
	
	# Generate the dendrogram using wards method
	cluster <- hclust(method = "ward", as.dist(ParticipantCounter(path) - dm))
	dend <- as.dendrogram(cluster)
	
	# Drawing the cluster heatmap and export as a jpeg file
	jpeg(filename = paste(path, "cluster_heatmap.jpeg", sep = ""), width = 2000, height = 2000, units = "px",
			pointsize = 5, bg = "white", res = 700)
	heatmap.2(as.matrix(ParticipantCounter(path) - dm), Rowv = dend, Colv = dend, 
			margin = c(4, 4), cexRow = 0.35, cexCol = 0.35, dendrogram = "both", 
			revC = T, trace = "none", key = T)
	dev.off()
}















# General cluster analysis
GeneralClusterAnalysis  <- function(path, osm.path) {
	d <- read.csv(osm.path, header = F)
	dm <- as.matrix(d[, -1])
	dimnames(dm) <- list(d[, 1], d[, 1])
	# Old code: dm = as.matrix(d)
	# Jinlong: I'm pretty sure the code above won't work for this function
	
	# Participants minus osm generates dissimilarity
	ave <- hclust(method = "average", as.dist(ParticipantCounter(path) - dm))
	comp <- hclust(method = "complete", as.dist(ParticipantCounter(path) - dm))
	ward <- hclust(method = "ward", as.dist(ParticipantCounter(path) - dm))
	
	# compute and save cophenectic matrices
	
	coph.ave <- as.matrix(cophenetic(ave)) 
	coph.comp <- as.matrix(cophenetic(comp)) 
	coph.ward <- as.matrix(cophenetic(ward)) 
	
	write.table(coph.ave, file = paste(path, "coph_matrix_ave.mtrx", sep = ""), sep = " ", row.names = F, col.names = F)
	write.table(coph.comp, file = paste(path, "coph_matrix_comp.mtrx", sep = ""), sep = " ", row.names = F, col.names = F)
	write.table(coph.ward, file = paste(path, "coph_matrix_ward.mtrx", sep = ""), sep = " ", row.names = F, col.names = F)
	
	# Export the dendrograms as a jpeg files
	dend.ave <- as.dendrogram(ave)
	dend.comp <- as.dendrogram(comp)
	dend.ward <- as.dendrogram(ward)
	
	# png(filename = paste(path, "dendrogram_ave.png", sep =""),
	# 		width = 2000, height=2000, units="px",
	# 		pointsize=5, compression = "none", bg = "white", res = 600)
	jpeg(filename = paste(path, "dendrogram_ave.jpeg", sep =""),
			width = 2000, height=2000, units="px",
			pointsize=5, bg = "white", res = 600)
	plot(dend.ave)
	dev.off()
	
	# png(filename = paste(path, "dendrogram_comp.png", sep =""),
	# 		width = 2000, height=2000, units="px",
	# 		pointsize=5, compression = "none", bg = "white", res = 600)
	jpeg(filename = paste(path, "dendrogram_comp.jpeg", sep =""),
			width = 2000, height=2000, units="px",
			pointsize=5, bg = "white", res = 600)
	plot(dend.comp)
	dev.off()
	
	# png(filename = paste(path, "dendrogram_ward.png", sep =""),
	# 		width = 2000, height=2000, units="px",
	# 		pointsize=5, compression = "none", bg = "white", res = 600)
	jpeg(filename = paste(path, "dendrogram_ward.jpeg", sep =""),
			width = 2000, height=2000, units="px",
			pointsize=5, bg = "white", res = 600)
	plot(dend.ward)
	dev.off()
}

















# Cluster validation
ClusterValidation <- function(path, k, title="") {
	
	ism <- list.files(paste(path, "ism/", sep=""))
	r <- sample(1:100, size=ParticipantCounter(path), replace=TRUE)
	ism.list <- data.frame(ism, r)
	ism.list <- ism.list[order(r), ]
	
	if(ParticipantCounter(path)%%2 == 0) {
		split <- ParticipantCounter(path)/2
	} else {
		split <- (ParticipantCounter(path)-1)/2
	}
	
	# Split the participants
	group1 <- ism.list[1:split, 1]
	group2 <- ism.list[(split+1):ParticipantCounter(path), 1]
	
	# read in group1 matrix
	matrix1 <- read.delim(paste(path, "ism/", group1[1], sep=""), header=F, sep=" ", stringsAsFactors=F)
	osm1 <- data.matrix(matrix1)
	
	for (i in 2:length(group1)) {
		matrix.i <- read.delim(paste(path, "ism/", group1[i], sep=""), header=F, sep=" ", stringsAsFactors=F)
		matrix.i <- data.matrix(matrix.i)
		osm1 <- osm1 + matrix.i
	}
	
	# read in group2 matrix
	matrix2 <- read.delim(paste(path, "ism/", group2[1], sep=""), header=F, sep=" ", stringsAsFactors=F)
	osm2 <- data.matrix(matrix2)
	
	for (i in 2:length(group2)) {
		matrix.i <- read.delim(paste(path, "ism/", group2[i], sep=""), header=F, sep=" ", stringsAsFactors=F)
		matrix.i <- data.matrix(matrix.i)
		osm2 <- osm2 + matrix.i
	}
	
	d1 <- data.frame(IconListGetter(path), osm1)
	d1m <- as.matrix(d1[, -1])
	dimnames(d1m) <- list(d1[, 1], d1[, 1])
	
	d2 <- data.frame(IconListGetter(path), osm2)
	d2m <- as.matrix(d2[, -1])
	dimnames(d2m) <- list(d2[, 1], d2[, 1])
	
	ave1 <- hclust(method = "average", as.dist(ParticipantCounter(path)-d1m))
	ave2 <- hclust(method = "average", as.dist(ParticipantCounter(path)-d2m))
	
	comp1 <- hclust(method = "complete", as.dist(ParticipantCounter(path)-d1m))
	comp2 <- hclust(method = "complete", as.dist(ParticipantCounter(path)-d2m))
	
	ward1 <- hclust(method = "ward", as.dist(ParticipantCounter(path)-d1m))
	ward2 <- hclust(method = "ward", as.dist(ParticipantCounter(path)-d2m))
	
	# load code of A2R function
	source("http://addictedtor.free.fr/packages/A2R/lastVersion/R/code.R")
	
	# Define colors
	pre.colors <- rainbow(k)
	colors <- pre.colors[1:k]
	
	# colored dendrograms
	pdf(file= paste(path, "cluster_validation.pdf", sep=""),onefile=T,width=12, height=4)
	A2Rplot(ave1, k = k, boxes = FALSE, col.up = "gray50", col.down = colors, main=paste(title, " Group 1 Average Linkage", sep=""))
	A2Rplot(ave2, k = k, boxes = FALSE, col.up = "gray50", col.down = colors, main=paste(title, " Group 2 Average Linkage", sep=""))
	
	A2Rplot(comp1, k = k, boxes = FALSE, col.up = "gray50", col.down = colors, main=paste(title, " Group 1 Complete Linkage", sep=""))
	A2Rplot(comp2, k = k, boxes = FALSE, col.up = "gray50", col.down = colors, main=paste(title, " Group 2 Complete Linkage", sep=""))
	
	A2Rplot(ward1, k = k, boxes = FALSE, col.up = "gray50", col.down = colors, main=paste(title, " Group 1 Ward's Method", sep=""))
	A2Rplot(ward2, k = k, boxes = FALSE, col.up = "gray50", col.down = colors, main=paste(title, " Group 2 Ward's Method", sep=""))
	
	dev.off()
}















# Overview
# set the scenario here and file name
OverviewGetter <- function(path) {
	output <- paste(scenario.name, "_overview.pdf", sep = "")
	data <- read.csv(paste(path, "participant.csv", sep = ""), header=F, stringsAsFactors = F)
	
	male <- 0
	female <- 0
	for (i in 1:nrow(data)) {
		if (data[i, 3] == "male") {
			male <- male+1
		} else {
			female <- female+1
		}
	}
	
	aveage <- round(mean(data[, 2]), 2)
	max <- max(data[, 2])
	min <- min(data[, 2])
	
	
	pdf(file = paste(path, output, sep = ""), onefile = T, width=10, height=25)
	
	layout(matrix(c(1,1,2,2,3,3,4,5), 4, 2, byrow = TRUE))
	
	plot.new()
	title(paste("Total participants: ", ParticipantCounter(path), ";", sep = ""), line = -18, cex = 20)
	title(paste("Male: ", male, ", Female: ", female, sep = ""), line = -20, cex = 20)
	title(paste("Average age: ", aveage, " (max: ", max, ", min: ", min, ")", sep = ""), line = -22, cex = 20)
	boxplot(data[, 14],
			horizontal = TRUE, 
			notch = FALSE,  # Notches for CI for median
			col = "slategray3",
			boxwex = 0.5,  # Width of box as proportion of original
			whisklty = 1,  # Whisker line type; 1 = solid line
			staplelty = 0,  # Staple (line at end) type; 0 = none
			outpch = 16,  # Symbols for outliers; 16 = filled circle
			outcol = "slategray3",  # Color for outliers
			main = "Groups Created")
	boxplot(data[, 15],
			horizontal = TRUE, 
			#notch = TRUE,  # Notches for CI for median
			col = "slategray3",
			boxwex = 0.5,  # Width of box as proportion of original
			whisklty = 1,  # Whisker line type; 1 = solid line
			staplelty = 0,  # Staple (line at end) type; 0 = none
			outpch = 16,  # Symbols for outliers; 16 = filled circle
			outcol = "slategray3",  # Color for outliers
			main = "Grouping Time")
	
	groupscount <- data.frame(table(data[, 14]))
	
	a <- groupscount$Var1
	b <- c()
	for (i in 1:length(a)) {
		b[i] <- toString(a[i])
	}
	
	groupmean <- mean(data[, 14])
	groupsd <- round(sd(data[, 14]), 2)
	
	barplot(groupscount$Freq, names.arg = b, 
			main = paste("Groups Created (mean = ", groupmean, ", ", "sd = ", groupsd, ")", sep = ""),
			xlab = "Number of groups created", ylab="Frequency")
	
	hist(data[, 15], col = "grey", main = paste("Grouping Time", " (mean = ", round(mean(data[, 15]), 2), "s", "," , " sd = ", round(sd(data[, 15]), 2), "s", ")", sep = ""), xlab = "Time spent on grouping in second")
	title(scenario.name, outer = T, line = -2, cex.main = 2, col.main = "blue")
	
	dev.off()
}















# Participant similarity analysis
ParticipantSimilarity <- function(path) {

	# List all ISMs
	isms <- list.files(paste(path, "ism/", sep = ""))
	all.isms <- list()
	
	np <- length(isms)
	
	# Read in all ISMs and store them in a list named all.isms
	for (i in 1:length(isms)) {
		aism <- read.delim(paste(paste(path, "ism/", sep = ""), isms[i], sep = ""),
				header = F, sep = " ", stringsAsFactors = F)
		all.isms <- c(all.isms, list(aism))
	}
	
	# Calculate participant similarity matrices of all pairs of partcipants based on the hamming distance of their ISMs (dm) and Jaccard index (dm_jaccard)
	dm <- matrix(0, ncol = np, nrow = np)
	dm.jac <- matrix(0, ncol = np, nrow = np)
	dm.rand <- matrix(0, ncol = np, nrow = np)
	for (i in 1:np) {
		for (j in 1:np) {
			dm[i, j] <- sum(abs(all.isms[[i]] - all.isms[[j]]))
			
			m11 <- sum(all.isms[[i]] * all.isms[[j]])
			m01 <- sum(abs(1-all.isms[[i]]) * all.isms[[j]])
			m10 <- sum(all.isms[[i]] * abs(1-all.isms[[j]]))
			m00 <- sum(abs(1-all.isms[[i]]) * abs(1-all.isms[[j]]))
			
			dm.jac[i, j] <- m11 / (m01+m10+m11) 
			
			dm.rand[i, j] <- (m11 + m00) / (m01+m10+m00+m11)
		}
	}
	
	# Extract the participant number of all participants and store them in a vector named names
	names <- c()
	for (i in 1:length(isms)) {
		name <- isms[i]
		names <- append(names, substr(name, 12, nchar(name) - 5))
	}
	
	# Assign participants numbers as the row&column names of the participant similarity matrix (dm)
	colnames(dm) <- names
	rownames(dm) <- names
	colnames(dm.jac) <- names
	rownames(dm.jac) <- names
	colnames(dm.rand) <- names
	rownames(dm.rand) <- names
	
	write.table(dm, file = paste(path, "participant_similarity_hamming.csv", sep = ""), sep = " ",
			row.names = T, col.names = T)
	
	write.table(dm.jac, file = paste(path, "participant_similarity_jaccard.csv", sep = ""), sep = " ",
			row.names = T, col.names = T)
	
	write.table(dm.rand, file = paste(path, "participant_similarity_rand.csv", sep = ""), sep = " ",
			row.names = T, col.names = T)
	
}

















# Visualize the frequency that each icon is being selected as group prototype
PrototypeFreq <- function(path) {
	
	# Construct the path for the zip folder and list all the zip files
	zip.path <- paste(path, "zip/", sep = "")
	files <- list.files(zip.path)
	
	# Create a dataframe to store the prototype frequency
	freq <- data.frame(icon = IconListGetter(path), 
			icon_index = 0:(length(IconListGetter(path))-1), 
			count = rep(0, length(IconListGetter(path)))
	)
	
	for(p in files) {
		participant <- unzip(paste(zip.path, p, sep =""))
		participant.number <- substring(p, 1, nchar(p) - 4)
		prototype_file <- paste("./", participant.number, "/", substring(p, 1, 8), "gprototypes.csv", sep = "")
		prototype <- read.csv(prototype_file, header = F, stringsAsFactors = F)
		prev <- -1 # workaround to deal with old prototype files
		for(j in 1:nrow(prototype)) {
			if(ncol(prototype) < 4 || (!is.na(prototype[j, 2]) && !is.na(prototype[j, 3]) && !is.na(as.numeric(as.numeric(prototype[j, 3]))) && prototype[j, 2] != prev)) {
				prev <- as.numeric(prototype[j, 2])
				freq[as.numeric(prototype[j, 3]) + 1, 3] <- freq[as.numeric(prototype[j, 3]) + 1, 3] + 1
			}
		}
	}
	
	# Export batch.csv for Klipart
	write.table(freq, file = paste(path, "prototype.csv", sep = ""), sep = ",", col.names = F, row.names = F)
	return(freq)
}















# multi-dimensional scaling
MdsScaling <- function(path, osm.path) {
	d <-  read.csv(osm.path, header = F)
	dm <- as.matrix(d[, -1])
	dimnames(dm) <- list(d[, 1], d[, 1])
	dm.dist <- dist(dm, method = "euclidean")
	mds <- cmdscale(dm.dist)
	col <- rainbow(50)
	jpeg(filename = paste(path, "mds.jpeg", sep = ""), width = 3, height =3, units = "in", pointsize = 5, bg = "white", res = 600)
	plot(min(mds[, 1], mds[, 2]):max(mds[, 1],mds[, 2]), min(mds[, 1], mds[, 2]):max(mds[, 1], mds[, 2]), type = "n", xlab = "", ylab = "", main = "Multidimensional Scaling")
	for(i in 1:nrow(mds)) {
		points(mds[i, 1], mds[i, 2], type = "p", cex = 1.5)
	}
	dev.off()
	return(mds)
}














# Part 2 Executables
#####################################################################################################
#####################################################################################################
#####################################################################################################

# OSM file should now be created from function_list_pre's OsmIsmGenerator function.
# define path to OSM file below, as it is used as a parameter for functions below
# rather than it being a dependency
osm.path <- paste(path, "osm.csv", sep="")

ParticipantInfo(path)

prototypes <- PrototypeFreq(path)

OsmViz(path, osm.path)

ClusterHeatmap(path, osm.path)

GeneralClusterAnalysis(path, osm.path)

OverviewGetter(path)

DescriptionGetter(path)

ParticipantSimilarity(path) # sluggish 

mds <- MdsScaling(path, osm.path) # no text labels on plot. Just points.

ClusterValidation(path, 3, "geo terms")









# BEGIN: Part 3
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################










# Creates a sample of participants of size sample_size and computes the hclust objects and cophenetic matrices for this sample.
# The return value is a 6 element list (hclust_ave,coph.ave,hclust_comp,coph.comp,hclust_ward,coph.ward)
SamplingRun <- function(path, osm.path, ism.list, sample_size) {
	d <- read.csv(osm.path, header = F)
	
	# Construct the zip folder path and list all zip files
	ism.path <- paste(path, "ism/", sep = "")
	files <- ism.list
	
	# Initialize OSM
	osm <- matrix(0,nrow(d),nrow(d))
	
	# create random sample numbers
	r <- sample(length(ism.list), size=sample_size, replace=FALSE)
	
	# create OSM for sample
	for (i in 1:sample_size) {
		matrix.i.name <- files[r[i]]
		# print(paste("reading",matrix.i.name))
		
		# Read in the ISM from a participant and exclude the non-ism info from the .mtrx file
		matrix.i <- read.delim(paste(ism.path,matrix.i.name,sep=""), header = F, sep = " ", stringsAsFactors = F)
		matrix.i <- data.matrix(matrix.i[1:nrow(d), ])
		
		osm <- osm + matrix.i
	}
	
	# create hclust objects for different methods
	ave <- hclust(method = "average", as.dist(sample_size - osm))
	comp <- hclust(method = "complete", as.dist(sample_size - osm))
	ward <- hclust(method = "ward", as.dist(sample_size - osm))
	
	# compute cophenetic matrices
	coph.ave <- as.matrix(cophenetic(ave)) 
	coph.comp <- as.matrix(cophenetic(comp)) 
	coph.ward <- as.matrix(cophenetic(ward)) 
	
	return(list(ave,coph.ave,comp,coph.comp,ward,coph.ward,r))
}















# Perform a complete sampling experiment in which an average cophenetic matrix for samples of participants is compared
# to that of the entire set of participnats. The number of trials is given by paramter 'trials' and a sample size 
# of 'sample_size' 
CopheneticSampling <- function(path, osm.path, ism.list, trials, sample_size) {
	# read overall osm
	d <- read.csv(osm.path, header = F)
	dm <- as.matrix(d[, -1])
	dimnames(dm) <- list(d[, 1], d[, 1])
	
	# derive cophenetic matrices for all participants
	ave.all <- hclust(method = "average", as.dist(ParticipantCounter(path) - dm))
	comp.all <- hclust(method = "complete", as.dist(ParticipantCounter(path) - dm))
	ward.all <- hclust(method = "ward", as.dist(ParticipantCounter(path) - dm))
	
	coph.ave.total <- matrix(0,nrow(d),nrow(d))
	coph.comp.total <- matrix(0,nrow(d),nrow(d))
	coph.ward.total <- matrix(0,nrow(d),nrow(d))
	
	# sample and sum up the cophenetic matrices for different clustering methods
	for (i in 1:trials) {
		result <- SamplingRun(path, osm.path, ism.list, sample_size)
		coph.ave.total <- coph.ave.total + result[[2]]
		coph.comp.total <- coph.comp.total + result[[4]]
		coph.ward.total <- coph.ward.total + result[[6]]
	}
	
	# turn into average matrices
	coph.ave.total <- coph.ave.total / trials
	coph.comp.total <- coph.comp.total / trials
	coph.ward.total <- coph.ward.total / trials
	
	# write average matrices to file
	write.table(coph.ave.total, file = paste(path, "coph_matrix_sampled_ave.mtrx", sep = ""), sep = " ", row.names = F, col.names = F)
	write.table(coph.comp.total, file = paste(path, "coph_matrix_sampled_comp.mtrx", sep = ""), sep = " ", row.names = F, col.names = F)
	write.table(coph.ward.total, file = paste(path, "coph_matrix_sampled_ward.mtrx", sep = ""), sep = " ", row.names = F, col.names = F)
	
	# compute differences to all participant matrices
	diff.ave <- abs(as.matrix(cophenetic(ave.all)) - coph.ave.total)
	diff.comp <- abs(as.matrix(cophenetic(comp.all)) - coph.comp.total)
	diff.ward <- abs(as.matrix(cophenetic(ward.all)) - coph.ward.total)
	
	# print out average devigation per cell
	print (sum(diff.ave) / (nrow(d)^2))
	print (sum(diff.comp) / (nrow(d)^2))
	print (sum(diff.ward) / (nrow(d)^2))
}















# Perform complete sample experiments for deviations of clusterings resulting from different methods using Jaccard's index
# Parameters are:
# output.name: name of output file without extension
# ism.list: vector of .mtrx files from which to sample
# trials: number of runs averaged per sample size and cluster number
# sample.size.start: smallest sample size to be used
# sample.size.end: largest sample size to be used
# n.cluster.start: smallest number of clusters to used
# n.cluster.end: largest number of clusters to used
IndexSampling <- function(path, ism.list, output.name, trials, sample.size.start, sample.size.end, n.cluster.start, n.cluster.end) {
	
	# set up data frame for results
	log <- data.frame(col_names = c("cluster number", "sample size", "trial", "sample", "sim ave-comp jac", "sim ave-ward jac", "sim comp-ward jac", "sim avg diff jac", "sim ave-comp rand", "sim ave-ward rand", "sim comp-ward rand", "sim avg diff rand"), stringsAsFactors = FALSE)
	
	result.df.jac <- data.frame(row_names = c("sample size", c(sample.size.start:sample.size.end)), stringsAsFactors=FALSE)
	result.df.rand <- data.frame(row_names = c("sample size", c(sample.size.start:sample.size.end)), stringsAsFactors=FALSE)
	for (i in 1:(n.cluster.end-n.cluster.start+1)) {
		result.df.jac[1, ((i-1)*2)+2] <- paste("cluster=", n.cluster.start + i - 1, " avg", sep = "")
		result.df.jac[1, ((i-1)*2)+3] <- paste("cluster=", n.cluster.start + i - 1, " sd", sep = "")
		result.df.rand[1, ((i-1)*2)+2] <- paste("cluster=", n.cluster.start + i - 1, " avg", sep = "")
		result.df.rand[1, ((i-1)*2)+3] <- paste("cluster=", n.cluster.start + i - 1, " sd", sep = "")
	}
	
	# run experiments and enter average Jaccard similarity over all three cluster methods in the data frame
	count <- 1
	for (j in n.cluster.start:n.cluster.end) {
		for (l in sample.size.start:sample.size.end) {
			print(paste(((((j-n.cluster.start)*(sample.size.end-sample.size.start+1))+(l-sample.size.start+1)) / ((n.cluster.end-n.cluster.start+1) * (sample.size.end-sample.size.start+1)))*100,"% done" ))
			avg.jac <- 0 
			sq.jac <- 0
			avg.rand <- 0 
			sq.rand <- 0
			for (i in 1:trials) {
				result <- SamplingRun(path,ism.list,l)
				sim.ave.comp.jac <- cluster_similarity(cutree(result[[1]], k=j), cutree(result[[3]], k = j), similarity = c("jaccard"), method = "independence")
				sim.ave.ward.jac <- cluster_similarity(cutree(result[[1]], k=j), cutree(result[[5]], k = j), similarity = c("jaccard"), method = "independence")
				sim.comp.ward.jac <- cluster_similarity(cutree(result[[3]], k=j), cutree(result[[5]], k = j), similarity = c("jaccard"), method = "independence")
				sim.ave.comp.rand <- cluster_similarity(cutree(result[[1]], k=j), cutree(result[[3]], k = j), similarity = c("rand"), method = "independence")
				sim.ave.ward.rand <- cluster_similarity(cutree(result[[1]], k=j), cutree(result[[5]], k = j), similarity = c("rand"), method = "independence")
				sim.comp.ward.rand <- cluster_similarity(cutree(result[[3]], k=j), cutree(result[[5]], k = j), similarity = c("rand"), method = "independence")
				
				sim.avg.jac <- (sim.ave.comp.jac + sim.ave.ward.jac + sim.comp.ward.jac) / 3
				sim.avg.rand <- (sim.ave.comp.rand + sim.ave.ward.rand + sim.comp.ward.rand) / 3
				avg.jac <- avg.jac + sim.avg.jac
				sq.jac <- sq.jac + (sim.avg.jac)^2
				avg.rand <- avg.rand + sim.avg.rand
				sq.rand <- sq.rand + (sim.avg.rand)^2
				
				log[count, 1] <- j
				log[count, 2] <- l
				log[count, 3] <- i
				log[count, 4] <- paste(result[7], collapse = "")
				log[count, 5] <- sim.ave.comp.jac
				log[count, 6] <- sim.ave.ward.jac
				log[count, 7] <- sim.comp.ward.jac
				log[count, 8] <- sim.avg.jac
				log[count, 9] <- sim.ave.comp.rand
				log[count, 10] <- sim.ave.ward.rand
				log[count, 11] <- sim.comp.ward.rand
				log[count, 12] <- sim.avg.rand
				
				count <- count + 1
			}
			var.jac <- ((trials * sq.jac) - avg.jac^2) / (trials * (trials - 1))
			avg.jac <- avg.jac / trials
			
			var.rand <- ((trials * sq.rand) - avg.rand^2) / (trials * (trials - 1))
			avg.rand <- avg.rand / trials
			
			result.df.jac[l - sample.size.start + 2, (j - n.cluster.start) * 2 + 2] <- avg.jac
			result.df.jac[l - sample.size.start + 2, (j - n.cluster.start) * 2 + 3] <- sqrt(var.jac)
			result.df.rand[l - sample.size.start + 2, (j - n.cluster.start) * 2 + 2] <- avg.rand
			result.df.rand[l - sample.size.start + 2, (j - n.cluster.start) * 2 + 3] <- sqrt(var.rand)
		}
	}
	
	# write data frame to file
	write.table(result.df.jac, file = paste(path, output.name, "_jac.csv", sep = ""), sep = ",", row.names = F,  col.names = F)
	write.table(result.df.rand, file = paste(path, output.name, "_rand.csv", sep = ""), sep = ",", row.names = F,  col.names = F)
	write.table(log, file = paste(path, output.name, "_log.csv", sep = ""), sep = ",", row.names = T,  col.names = T)
	
	# produce plots
	cols <- c("blue", "green", "red", "brown", "yellow")
	
	pdf(file = paste(path, output.name, "_jac.pdf", sep = ""), onefile = T, width = 12, height = 4)
	# png(filename=paste(path, output.name, "_jac.png",sep=""), height=1600, width=1600, bg="white")
	for (i in 1:(n.cluster.end-n.cluster.start+1)) {
		if (i == 1) {
			par(mar = c(5.1, 4.1, 4.1, 5.1), xpd = TRUE)
			plot(result.df.jac[2:(sample.size.end-sample.size.start+2),2], type = "o", ylim = c(0, 1), col = cols[((i-1) %% length(cols)) + 1 ], pch = 21+i-1, lty = i, axes = FALSE, ann = FALSE, bty = 'L') 
			axis(1, at = 1:(sample.size.end-sample.size.start+1), labels = c(sample.size.start:sample.size.end))
			axis(2, at = c(0, 0.2, 0.4, 0.6, 0.8, 1), labels = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"))
			box()
			title(main = "CMSI based on Jaccard coefficient", col = rgb(0, 0.5, 0))
		} else {
			lines(result.df.jac[2:(sample.size.end-sample.size.start+2), (i-1)*2+2], type="o", col = cols[((i-1) %% length(cols)) + 1 ], pch = 21+i-1, lty = i)
		}
	}
	legend("topright", inset = c(-0.08, 0), legend = c(n.cluster.start:n.cluster.end), cex = 0.8, col = cols, pch = 21:(21+(n.cluster.end-n.cluster.start)), lty = 1:(n.cluster.end-n.cluster.start+1))
	title(xlab = "Sample size", col.lab = rgb(0, 0.5, 0))
	title(ylab = "CMSI", col.lab = rgb(0, 0.5, 0))
	dev.off()
	
	pdf(file = paste(path, output.name, "_rand.pdf", sep = ""), onefile = T, width = 12, height = 4)
	#png(filename=paste(path, output.name, "_rand.png",sep=""), height=1600, width=1600, bg="white")
	for (i in 1:(n.cluster.end-n.cluster.start+1)) {
		if (i == 1) {
			par(mar = c(5.1, 4.1, 4.1,5.1), xpd = TRUE)
			plot(result.df.rand[2:(sample.size.end-sample.size.start+2), 2], type = "o", ylim = c(0, 1), col = cols[((i-1) %% length(cols)) + 1], pch = 21+i-1, lty = i, axes = FALSE, ann = FALSE) 
			axis(1, at = 1:(sample.size.end-sample.size.start+1), labels = c(sample.size.start:sample.size.end))
			axis(2, at = c(0, 0.2, 0.4, 0.6, 0.8, 1), labels = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"))
			box()
			title(main = "CMSI based on Rand coefficient", col = rgb(0, 0.5, 0))
		} else {
			lines(result.df.rand[2:(sample.size.end-sample.size.start+2), (i-1)*2+2], type = "o", col = cols[((i-1) %% length(cols)) + 1], pch = 21+i-1, lty = i)
		}
	}
	legend("topright", inset = c(-0.08,0), legend = c(n.cluster.start:n.cluster.end), cex = 0.8, col = cols, pch = 21:(21+(n.cluster.end-n.cluster.start)), lty = 1:(n.cluster.end-n.cluster.start+1))
	title(xlab = "Sample size", col.lab = rgb(0, 0.5, 0))
	title(ylab = "CMSI", col.lab = rgb(0, 0.5, 0))
	dev.off()
}















# Participant similarity analysis
ParticipantSimilarityClusters <- function(path) {
	dm <- as.matrix(read.table(file = paste(path, "participant_similarity_hamming.csv", sep = ""), sep = " ",
			header = T))
	
	dm.jac <- as.matrix(read.table(file = paste(path, "participant_similarity_jaccard.csv", sep = ""), sep = " ",
			header = T))
	
	dm.rand <- as.matrix(read.table(file = paste(path, "participant_similarity_rand.csv", sep = ""), sep = " ",
			header = T))
	
	# Perform cluster analysis based on participant similarity matrix using Ward's method and construct a dendrogram
	cluster <- hclust(method = "ward", as.dist(dm))
	cluster.jac <- hclust(method = "ward", as.dist(dm.jac))
	cluster.rand <- hclust(method = "ward", as.dist(dm.rand))
	dend <- as.dendrogram(cluster)
	dend.jac <- as.dendrogram(cluster.jac)
	dend.rand <- as.dendrogram(cluster.rand)
	
	#Create overview table showing cluster membership for all possible numbers of clusters
	tree <- cutree(cluster, k = c(1:nrow(dm)))
	write.csv(tree, file=paste(path, "participant_similarity_ward_clusters", ".csv", sep = ""))
}















# Participant similarity analysis
ParticipantSimilarityVisualizations <- function(path) {
	
	dm <- as.matrix(read.table(file = paste(path, "participant_similarity_hamming.csv", sep = ""), sep = " ",
					header = T))
	
	dm.jac <- as.matrix(read.table(file = paste(path, "participant_similarity_jaccard.csv", sep = ""), sep = " ",
					header = T))
	
	dm.rand <- as.matrix(read.table(file = paste(path, "participant_similarity_rand.csv", sep = ""), sep = " ",
					header = T))
	
	# Perform cluster analysis based on participant similarity matrix using Ward's method and construct a dendrogram
	cluster <- hclust(method = "ward", as.dist(dm))
	cluster.jac <- hclust(method = "ward", as.dist(dm.jac))
	cluster.rand <- hclust(method = "ward", as.dist(dm.rand))
	dend <- as.dendrogram(cluster)
	dend.jac <- as.dendrogram(cluster.jac)
	dend.rand <- as.dendrogram(cluster.rand)
	
	# Export the dendrogram as a pdf file
	pdf(file = paste(path, "participant_similarity.pdf", sep = ""), onefile = T, width = 12, height = 4)
	#tiff(filename = paste(path, "participant_similarity.tiff", sep =""),
	#		width = 4000, height=4000, units="px",
	#		pointsize=5, compression = "none", bg = "white", res = 400)
	plot(dend)
	dev.off()
	
	pdf(file = paste(path, "participant_similarity_jac.pdf", sep = ""), onefile = T, width = 12, height = 4)
	#tiff(filename = paste(path, "participant_similarity_jac.tiff", sep =""),
	#		width = 4000, height=4000, units="px",
	#		pointsize=5, compression = "none", bg = "white", res = 400)
	plot(dend.jac)
	dev.off()
	
	pdf(file = paste(path, "participant_similarity_rand.pdf", sep = ""), onefile = T, width = 12, height = 4)
	#tiff(filename = paste(path, "participant_similarity_rand.tiff", sep =""),
	#		width = 4000, height=4000, units="px",
	#		pointsize=5, compression = "none", bg = "white", res = 400)
	plot(dend.rand)
	dev.off()
  
	# Create a cluster heatmap for participant similarities
	jpeg(filename = paste(path, "HM-Clust-PartSimHam.jpeg", sep = ""), width = 2000, height = 2000, units = "px",
	    pointsize = 5, bg = "white", res = 600)
	heatmap.2(as.matrix(dm), col=cm.colors(255), Rowv = dend, Colv = dend, 
	          margin = c(3,3), cexRow = 0.5, cexCol = 0.5, dendrogram = "both", 
	          revC = TRUE, trace = "none", key = TRUE)
	dev.off()
  
	# Generate the dendrogram using wards method for
	# Participant similarity using Jaccard coefficient
	dend <- as.dendrogram(cluster.jac)
	# Create a cluster heatmap for participant similarities
	jpeg(filename = paste(path, "HM-Clust-PartSimJac.jpeg", sep = ""), width = 2000, height = 2000, units = "px",
	    pointsize = 5, bg = "white", res = 600)
	heatmap.2(as.matrix(dm.jac), Rowv = dend, Colv = dend, 
	          margin = c(3, 3), cexRow = 0.5, cexCol = 0.5, dendrogram = "both", 
	          revC = TRUE, trace = "none", key = TRUE)
	dev.off()
}















# Numerical cluster validation
# cluster validation is accomplished by comparing cluster membership
# for a certain number of clusters across different clustering methods (ave, comp, ward)
# Parameters: path of experiment and k (maximum number of clusters)
# There could be an issue as cluster membership is a number that may not be the same
# across cluster method!!!
NumClusVal <- function(path, osm.path, k) {
	# read in matrix and column/row names
	d <- read.csv(osm.path, header = F)
	dm <- as.matrix(d[, -1])
	dimnames(dm) <- list(d[, 1], d[, 1])
	
	# Participants minus osm generates dissimilarity
	ave <- hclust(method = "average", as.dist(ParticipantCounter(path) - dm))
	comp <- hclust(method = "complete", as.dist(ParticipantCounter(path) - dm))
	ward <- hclust(method = "ward", as.dist(ParticipantCounter(path) - dm))
	# cluster validation
	cut.Results <- data.frame() # create empty data frame
	for (i in 2:k) {
		cut.ave <- as.data.frame(cutree(ave, i))
		cut.comp <- as.data.frame(cutree(comp, i))
		cut.ward <- as.data.frame(cutree(ward, i))
		cut.Results <- as.data.frame(cbind(cut.ave[, 1], cut.comp[, 1], cut.ward[, 1]))
		colnames(cut.Results) <- c(paste("ave", sep = ""), paste("comp", sep = ""), paste("ward", sep = ""))
		cut.Results$Equal[cut.Results$ave == cut.Results$comp & cut.Results$comp == cut.Results$ward] <- "Equal"
		cut.Results$Equal[cut.Results$ave != cut.Results$comp | cut.Results$comp != cut.Results$ward] <- "Dif"
		rownames(cut.Results) <- rownames(cut.ave)
		write.csv(cut.Results, file = paste(path, "cluVal", i, ".csv", sep = ""))
	} 
}















# print standard dendrograms
# Author: Alexander Klippel
# input variable: path
# OSM needs to be present
StanDen <- function(path, osm.path) {
  d <- read.csv(osm.path, header = F)
  dm <- as.matrix(d[, -1])
  dimnames(dm) <- list(d[, 1], d[, 1])
  clu.meth <- c("ave", "comp", "ward.D")
  for (i in clu.meth) {
    # ALTERNATIVE 1
      dummy <- hclust(method = i, as.dist(ParticipantCounter(path) - dm))
      jpeg(file = paste(path, "dendro", i, ".jpeg", sep=""), width = 1200, height = 1200, pointsize = 12)
      plot(dummy)
    # ALTERNATIVE 2
#     dummy = as.dendrogram(hclust(method = i, as.dist(ParticipantCounter(path) - dm)))
#     png(file = paste(path, "dendro", i, ".png", sep=""), width = 1400, height = 1200)
#     plot(dummy, type = "triangle", nodePar = list(pch = 10:1, cex = .5*4:1, col = 2:3),
#          edgePar = list(col = 1:2, lty = 2:3), 
#          horiz = TRUE, 
#          #center = FALSE, dLeaf = -2, edge.root = FALSE
#     )
    myTitle <- paste(scenario.name, i, sep="//")
    title(main = myTitle)
    dev.off()
    }
  }
# StanDen(path)















# ploting individual "heatmaps" as black/white images
# Author: Alexander Klippel
# input: path
# output: results for each participant are stored in folder 'indISM'
# required package:
VisIndIsm <- function(path) {
  # read in all ISMs and store as a list
  indISM <- as.list(list.files(paste(path, "ism/", sep = "")))
  dir.create(paste(path, "indISM/", sep = ""))
  indISM.Path <- paste(path, "indISM/", sep = "")
  #iterate through the list and plot each matrix using 'grid.raster'
  #individusal images are stored as png files
  for (i in indISM) {
    indISM.matrix <- read.delim(paste(path, "ism/", i, sep = ""), header = FALSE, sep = " ", stringsAsFactors = F)
    indISM.matrix <- data.matrix(indISM.matrix)
    jpeg(paste(indISM.Path, i, ".jpeg", sep = ""), width = 480, height = 480)
    grid.raster(as.raster(indISM.matrix), interpolate = FALSE)
    dev.off()
  }
}
# VisIndIsm(path)















# Not finished
# ploting reordered individual "heatmaps"
# read in all ISMs and store as a list
# indISM <- as.list(list.files(paste(path,"ism/",sep="")))
# dir.create(paste(path, "indISM-reordered/", sep=""))
# indISM.Path <- paste(path, "indISM-reordered/", sep="")
# #read in file names with new order
# my.names <- read.csv((paste(path, "newNameOrder.csv", sep = "")), header = TRUE)
# #iterate through the list and plot each matrix using 'grid.raster'
# #individusal images are stored as png files
# for (i in indISM) {
#   indISM.matrix <- read.delim(paste(path, "ism/", i, sep = ""), header = FALSE, sep = " ", stringsAsFactors = F)
#   indISM.matrix <- data.matrix(indISM.matrix)
#   colnames(indISM.matrix) <- my.names$new
#   rownames(indISM.matrix) <- my.names$new
#   new.indISM.matrix <- indISM.matrix[sort(rownames(indISM.matrix)),sort(colnames(indISM.matrix)), drop = F]
#   png(paste(indISM.Path, i, ".png", sep = ""), width = 480, height = 480)
#   grid.raster(as.raster(new.indISM.matrix), interpolate = FALSE)
#   dev.off()
# }















# Visualizing participant similarities by groups
# Author: Alexander Klippel
# Input: path, number of participants (np), number of clusters (k)
# TODO: np needs to be set manually at the moment!
PartSimGroupVis <- function(path, np, k) {
  # List all ISMs
  isms <- list.files(paste(path, "ism/", sep = ""))
  all.isms <- list()
  
  # Read in all ISMs and store them in a list named all.isms
  for (i in 1:length(isms)) {
    aism <- read.delim(paste(paste(path, "ism/", sep = ""), isms[i], sep = ""),
                       header = F, sep = " ", stringsAsFactors = F)
    all.isms <- c(all.isms, list(aism))
  }
  
  # Calculate participant similarity matrix (dm) of all pairs of partcipants based on the hamming distance of their ISMs
  dm <- matrix(0, ncol = np, nrow = np)
  for (i in 1: np) {
    for (j in 1: np) {
      dm[i, j] <- sum(abs(all.isms[[i]] - all.isms[[j]]))
    }
  }
  
  # Extract the participant number of all participants and store them in a vector named names
  names <- c()
  for (i in 1: length(isms)) {
    name <- isms[i]
    names <- append(names, substr(name, 12, nchar(name) - 5))
  }
  
  # Assign participants numbers as the row&column names of the participant similarity matrix (dm)
  colnames(dm) <- names
  rownames(dm) <- names
  
  # Perform cluster analysis based on participant similarity matrix using Ward's method and construct a dendrogram
  ward.P <- hclust(method = "ward", as.dist(dm))
  clus.mem <- cutree(ward.P, k)
  clus.mem <- as.data.frame(clus.mem)
  
  # store images of clusters in corresponding html files
  for (i in 1:k) {
    # select one cluster and store all the members in cluster.members
    cluster.members <- subset(clus.mem, (clus.mem %in% c(i))) 
    # Store all the row names (image names) of that cluster in iconNames
    part.names <- rownames(cluster.members)
    # define output file using the cluster number as a name variable
    output <- paste(k, "_partClus", i, ".html", sep = "")
    HTML.output<-file.path(path, output)
    # specify where the icons/images are located at
    icon.path <- paste(path, "indISM/", sep = "")
    # write all the images/icons of one cluster into the html file
    # MyHTMLInsertGraph is necessary as there is no parameter to switch off the line break
    for (i in part.names) {
      MyHTMLInsertGraph(paste(icon.path, "participant", i, ".mtrx", ".jpeg", sep = ""), file = HTML.output, caption = i)
    }
  }
  
}















# Comparing results from 2 experiments / 2 OSMs
# Here: Substracting two OSMs from one another and visualizing the difference
# Author: Alexander Klippel
Dif2Osm <- function(osm1.path, osm2.path) {
  # load first OSM
  d1 <- read.csv(osm1.path, header = F)
  dm1 <- as.matrix(d1[, -1])
  
  # load second OSM
  d2 <- read.csv(osm2.path, header = F)
  dm2 <- as.matrix(d2[, -1])
  
  # substract the two OSMs
  dm.diff <- dm1 - dm2
  dimnames(dm.diff) <- list(d1[, 1], d1[, 1])
  # Output results
  jpeg(filename = paste(substr(osm1.path, 1, nchar(osm1.path)-7), "heatDif.jpeg", sep = ""), width = 2000, height = 2000, units = "px",
       pointsize = 5, compression = "none", bg = "white", res = 600)
  heatmap.2(as.matrix(dm.diff), Rowv = F, Colv = "Rowv", dendrogram = "none", 
            margin = c(3, 3), cexRow = 0.6, cexCol = 0.6, revC = F, trace = "none", key = TRUE)
  dev.off()
  min(dm.diff)
  #max(dm.diff)
}















# Detailed cluster analysis
DetailedClusterAnalysis <- function(path, osm.path, k, title = "") {
	d <- read.csv(osm.path, header = F)
	dm <- as.matrix(d[, -1])
	dimnames(dm) <- list(d[, 1], d[, 1])
	# Old code: dm = as.matrix(d)
	# Jinlong: I'm pretty sure the code above won't work for this function
	
	# Participants minus osm generates dissimilarity
	ave <- hclust(method = "average", as.dist(ParticipantCounter(path) - dm))
	comp <- hclust(method = "complete", as.dist(ParticipantCounter(path) - dm))
	ward <- hclust(method = "ward", as.dist(ParticipantCounter(path) - dm))
	
	# load code of A2R function
	# Explain what this function is doing!
	source("http://addictedtor.free.fr/packages/A2R/lastVersion/R/code.R")
	
	# Create a color scheme from rainbow color scheme
	pre.colors <- rainbow(k)
	colors <- pre.colors[1: k]
	
	pdf(file = paste(path, "dendrograms_", k, "_cluster.pdf", sep=""),
			width = 6, height = 2.5, 
			bg = "white", pointsize = 0.5)
	
	A2Rplot(ave, k = k, boxes = F, col.up = "gray50", col.down = colors, 
			main = paste(title, " Average Linkage ", k, " clusters", sep = ""))
	A2Rplot(comp, k = k, boxes = F, col.up = "gray50", col.down = colors, 
			main = paste(title, " Complete Linkage ", k, " clusters", sep = ""))
	A2Rplot(ward, k = k, boxes = F, col.up = "gray50", col.down = colors, 
			main = paste(title, " Ward's Method ", k, " clusters", sep = ""))
	
	dev.off()
	
}











# Function list Pt. 2 - Executables
#####################################################################################################
#####################################################################################################
#####################################################################################################

# generate output file for icon viewer containing mds results and prototype frequencies
mdsc <- cbind(mds, prototypes[3])
write.table(mdsc, file = paste(path, "mds.txt", sep = ""), sep = " ", quote = FALSE,
		row.names = T, col.names = T)

###Change the number here to create colored-dendrograms at different solutions
for(i in 2: max.cluster) {
	DetailedClusterAnalysis(path, osm.path, i, scenario.name)
}

StanDen(path, osm.path) 

VisIndIsm(path) 

CopheneticSampling(path, osm.path, list.files(paste(path, "ism/", sep = "")), 100, 20)

# Error in sample.int(x, size, replace, prob) : 
  # cannot take a sample larger than the population when 'replace = FALSE'
IndexSampling(path, list.files(paste(path, "ism/", sep = "")), "CMSI-2500", 100, 5, 100, 2, 10) # sluggish

# Can someone email me these files? Or dropbox me these files?
## NOTE THESE SHOULD NO LONGER BE PATHS TO DIRECTORIES, BUT PATHS TO EACH OSM FILE
path1 <- "E:/My Documents/Dropbox/qstr_collaboration/Catscan experiments/Experiments/1209 mturk directions 3D mugs final 225deg/"
path2 <- path <- "E:/My Documents/Dropbox/qstr_collaboration/Catscan experiments/Experiments/1208 mturk directions 3D mugs final 0deg/"
Dif2Osm(path1, path2)











# Removes all the unzipped participant folders in working directory
CatCleanUp <- function(path) {
  zip.path <- paste(path, "zip/", sep = "")
  zip.files <- list.files(zip.path)
  folder.names <- substr(zip.files, 1, nchar(zip.files)-4)
  for(folder in folder.names) {
    unlink(paste(getwd(), "/", folder, sep = ""), recursive = TRUE)
  }
}

CatCleanUp(path)






