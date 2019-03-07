# title: pop.make.r
# purpose: datasets of population denominators for CBD project (state, county, tract, mssa)
# notes:
#		county and state level use DOF data; tract and MSSA level use ACS data
#		this code doesn't control ACS to DOF totals, but production code does.
#		acs/dof are mid-year populations.
# history:
#	2019.02.25: moved to GitHub; changing paths; removed version number from filename.
#				option to use local or remote (api) files for ACS 5-year tract populations.
#	v10 2018.10.4: using predownloaded NHGIS ACS files instead of API. dropping DEC.
#	v09 2018.9.27: revised. using code from CCB mainstream.
#	v08 2018.7.19: added ability to combine multiple 5-yr ACS tract-level files; 
#				   collapse ACS ages to common with deaths: age17.
#				   remove code to read/use SEER/NCHS
#	v07 2018.6.12: added month/datum to population datasets.
#	v06	2018.5.10: bug fixes: decennial population datasets (county/state).
#	v05 2018.5.8: added decennial population datasets (tract/MSSA).
#	2018.5.2: fixed bug in section 2.2 when reading data to acs.varlist
#	2018.3.5: first working version (population only)

## 1    SETUP		----------------------------------------------------------------------

## 1.1  packages
.pkg	<- c("data.table","readr","stringr","tidycensus") 
.inst   <- .pkg %in% installed.packages() 
if(length(.pkg[!.inst]) > 0) install.packages(.pkg[!.inst]) 
lapply(.pkg, require, character.only=TRUE)           

## 1.2  path and globals
myDrive <- "c:/users/fieshary/projects/CACommunityBurden"
myPlace <- paste0(myDrive,"/myCBD") 
upPlace <- paste0(myDrive,"/myUpstream") 
.cbdlink	<- paste0(myPlace,"/myInfo/Tract to Community Linkage.csv") # map tract level GEOID to comID
.countylink <- paste0(myPlace,"/myInfo/County Codes to County Names Linkage.xlsx") # map county names to codes
.nxtract	<- paste0(upPlace,"/lifeTables/dataOut/nxTract.rds") # output deaths by tract
.nxmssa		<- paste0(upPlace,"/lifeTables/dataOut/nxMSSA.rds") # output deaths by mssa
.nxcounty	<- paste0(upPlace,"/lifeTables/dataOut/nxCounty.rds") # output deaths by county
.nxstate	<- paste0(upPlace,"/lifeTables/dataOut/nxState.rds") # output deaths by state
.ckey	    <- read_file(paste0(upPlace,"/upstreamInfo/census.api.key.txt")) # census API key
.clabels    <- paste0(myPlace,"/myInfo/B01001_labels.csv") # labels for fields in B01001 table.
setwd(myDrive)

## 2	DATASETS	----------------------------------------------------------------------

## 2.1 	tract-to-MSSA crosswalk
cbd.link <- setDT(read_csv(.cbdlink),
	key="GEOID"	                                  
)

## 2.2  ACS data: vector of variable names which contain tract-level population by age/sex
##		table S0101	contains sex by ages: 5 year age groups, expressed as % of tract total population
##		table B01001 contains sex by ages: 0-4,5-9,10-14,15-17,18-19,20,21,22-24,25-29,
##				30-34,35-39,40-44,45-49,50-54,55-59,60-61,62-64,65-66,67-69,70-74,75-79,80-84,85+
##		tables B01001A-B01001I contain table B01001 for races: WNH, W, B, N, A, P, O, MR
##				with limited ages: 0-4,5-9, 10-14, 15-17, 18-19, 20-24, 25-29, 30-34, 35-44, 45-54, 55-64, 75-84, 85+
##		table B01001_002 through B01001_025 refer to males; B01001_026 through B01001_049 refer to females
##		get full list from https://api.census.gov/data/2016/acs/acs5/variables.html
acs.varlist <- sprintf("B01001_%03dE",c(3:25,27:49)) 		# B01001_*E except totals

## 2.3 	ACS variable descriptive labels (e.g., "B01001_003E = Estimates of Male Population Under 5 years ... " )
##		downloaded from API documentation page and pasted into a .csv
acs.labels <- setDT(read_csv(.clabels),
	key="Name"                                    
)

## 2.4 	cleanup ACS labels read from external file
acs.labels[, c("type","strata","sex","age") 
		   := tstrsplit(Label, "!!")] 		                     # parse elements of descriptive label using "!!"
acs.labels[, sex:=toupper(sex)]                                  # capitalize sex for consistency
acs.labels <- acs.labels[, c("Name","sex","age")]                # retain only needed elements
acs.labels[, Name := substring(Name,0,10)]                       # remove "E" suffix from label for clean merging
acs.labels[age=="Under 5 years", age := "0 to 4 years"
		   ][age=="85 years and over", age := "85 to 199 years"] # relabel age groups to provide upper, lower ages
acs.labels[, c("agell","ageul") 
		   := tstrsplit(age, " ", keep=c(1,3))]                  # parse age ranges out of age label
acs.labels[is.na(ageul), ageul 
		   := agell]                                             # replace NA values of age with the lower age
acs.labels[, age:=NULL]                                          # drop full text age label

## 2.5 	ACS data: tract-level population by age/sex (long format, count and MOE in columns)
# check if already have these data before pulling again from census
.acsyears <- 2017:2017 # first year of 5-yr ACS is 2009
doGetAcs <- function(year) {
	acs.pop.tracts <- 	get_acs(state = 06, geography = "tract",  # all tracts in CA (FIPS state code = 06)
							   survey = "acs5", year = year,         # ACS options
							   variables = acs.varlist,              # ACS variable requested (B01003_001 = total population)
							   key=.ckey, moe_level=90               # global variable containing Census API key
	)
	acs.pop.tracts$year<-year 									  # add in the year of the extract
	return(acs.pop.tracts)	
}
acs.pop.tracts <- lapply(.acsyears, doGetAcs)					# loop over multiple years
acs.pop.tracts <- rbindlist(acs.pop.tracts)						# convert from list to frame

endhere

## 	2.6 merge labels for ACS tracts data
setDT(acs.pop.tracts) 
acs.pop.tracts[, NAME:=NULL]                                     # drop geography label (use GEOID only)
names(acs.pop.tracts)[names(acs.pop.tracts) 
					  == "variable"] = "Name"                    # rename variable to Name (to merge with labels)
setkey(acs.pop.tracts,"Name")                                    # define Name as the key to merge 
acs.pop.tracts<-merge(
	acs.pop.tracts,
	acs.labels, 
	all.x=TRUE                                   # keeping even if no match in acs.labels
)                                                # merge ACS tract dataset with with age, sex labels

##	3.1.3	recode age categories for ACS tracts data
##			collapse 23 ACS age groups into the same 18 groups (drop 18 21 22 62 67)
.maxage<-85
acs.pop.tracts[, agell:=as.integer(agell)]				# eventually move this fix to pop.make.r
acs.pop.tracts[, agell:=5*floor(agell/5)]						 # round to 5-yr ages (17 groups, no '1-4')
acs.pop.tracts[agell<.maxage, ageul:=agell+4]						 # update new age brackets
acs.pop.tracts[agell>=.maxage, ageul:=199]						 # update new age brackets
acs.pop.tracts[, ageul:=as.numeric(ageul)]
acs.pop.tracts<-acs.pop.tracts[,.(estimate=sum(estimate)),
							   by=.(GEOID,year,sex,agell,ageul)]				 # collapse

# ## ACS data: tract level age-sex detail from file B01001 series
# ##		for ease of use, these have been pre-downloaded and saved locally
# ##		long format; variables: (acsyear GEOID agell ageul a f m)
# acs.pop.tracts <- 	setDT(
# 						read.dta13(.acs),
# 						key="GEOID"
# 					)
# acs.pop.tracts <- 	melt.data.table(acs.pop.tracts, 
# 							variable.name="sex",
# 					   		id.vars=c("year","agell","ageul","GEOID"), 
# 					   		value="nx"
# 						 )                                       # convert dataset from wide to long format
# acs.pop.tracts[,sex:=toupper(substr(sex,5,10))]
# setkey(acs.pop.tracts,"GEOID")									 # melt unkeys the DT

# 	3.1.4	collapse ACS tract data into MSSAs
#!! 		this method does not export tracts which do not match, which previously were exported to subTracts.csv
#!! 		choose whether to merge and collapse to MSSA level or merely merge MSSA labels
setkey(acs.pop.tracts,"GEOID") 									 # set GEOID as key for this file for merging
acs.pop.mssa <- acs.pop.tracts[cbd.link,nomatch=0                # merge tracts data with cbd.link	
							   ][,.(estimate=sum(estimate)),     
							     by=.(comID,year,sex,agell,ageul)] 	 # calculate the sum of estimates by MSSA id variables


## 2.3	DOF data: county-level population by county/sex/age
##		several	options here. (1): P-3 file (compressed CSV file with complete age/race/sex/ethnic detail)
##							  (2): P-2 file (5-year age groups by sex, xlsx file)
##							  (3): data.ca.gov portal via API (sex, age); SKIP county text label and pop_total
dof.pop.county <- 	setDT(
						read_csv(.dof,
			 				col_types="i_iiii_"
						)
			 		)
dof.pop.county[,pop_all:=pop_female+pop_male]					 # total pop by age
dof.pop.county[, GEOID
			   :=sprintf("%05d000000",dof.pop.county$fips)]      # convert 4-digit FIPS into 11-character GEOID
setkey(dof.pop.county,"GEOID")									 # key for later merging
dof.pop.county[,fips:=NULL]                                      # drop fips variable, now that GEOID has been added
# recode age to categories
dof.pop.county[,agell:=age]
dof.pop.county[agell>=2 & agell<=4,agell:=1]
dof.pop.county[agell>=5 & agell<=85,agell:=as.integer(5*floor(agell/5))]
dof.pop.county[agell>=86,agell:=85]
dof.pop.county[agell==0,ageul:=1]
dof.pop.county[agell==1,ageul:=4]
dof.pop.county[agell>1 & agell<85,ageul:=agell+4]
dof.pop.county[agell==85,ageul:=199]
dof.pop.county[,age:=NULL]                                        # drop age variable, now that GEOID has been added
dof.pop.county  <- 	melt.data.table(dof.pop.county, 
							variable.name="sex",
					   		id.vars=c("year","agell","ageul","GEOID"), 
					   		value="nx"
						 )                                       # convert dataset from wide to long format
dof.pop.county[,sex:=toupper(substr(sex,5,10))]
dof.pop.county<-dof.pop.county[,.(nx=sum(nx)),
							by=.(year,GEOID,sex,agell,ageul)]	 # collapse
dof.pop.state<-dof.pop.county[,.(nx=sum(nx)),
							by=.(year,sex,agell,ageul)]			 # collapse
dof.pop.state[,GEOID:="06000000000"]                             # new GEOID for state level dataset

##	3	ANALYSIS	----------------------------------------------------------------------

## 	3.1 	ACS tract estimates controlled to DOF total county population
##			!! TBD

# 	3.2		collapse ACS tract data into MSSAs
#!! 		this method does not export tracts which do not match, which previously were exported to subTracts.csv
#!! 		choose whether to merge and collapse to MSSA level or merely merge MSSA labels
acs.pop.mssa <- acs.pop.tracts[cbd.link,nomatch=0                # merge tracts data with cbd.link	
							   ][,.(nx=sum(nx)),     
							     by=.(comID,year,sex,agell,ageul)] 	 # calculate the sum of estimates by MSSA id variables

##	4	CLEANUP		----------------------------------------------------------------------

##	4.2	export results for CCB calculations: county, tract, MSSA level datasets
##		ACS age17: 0,5,10,15,...85+
##		DOF age18: 0,1,5,10,15,...85+
##		variables: (GEOID or comID) year sex agell ageul estimate
saveRDS(acs.pop.tracts, file=.nxtract)  		# GEOID
saveRDS(acs.pop.mssa,   file=.nxmssa)  		# comID
saveRDS(dof.pop.county, file=.nxcounty) 		# GEOID
saveRDS(dof.pop.state,  file=.nxstate)  		# GEOID

# END