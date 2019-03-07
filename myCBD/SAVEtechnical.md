
<div style = 'font-size:16px;font-weight: bold;font-family:"Times New Roman", Times, serif';>



- Note regarding data suppression
  - A number of steps have been taken to address data security issue, including 1) aggregation of year into 5-year groups for data displayed at the community and census tract level, 2) showing less granular cause of death data at more granular geographic levels, 3) suppressing all measures for "strata" or "cells" where the corresponding number of deaths is <11, and 4) excluding disaggregated data by sex for neonatal conditions. These procedures assure compliance with the California Health and Human Services Agency [Data De-Identification Guidelines](https://www.dhcs.ca.gov/dataandstats/Documents/DHCS-DDG-V2.0-120116.pdf)(DDG).

- Note regarding YEAR or Year Group
  - At the County and State levels of geography, YEAR is the individual year of death, with current data from 2001 to 2017.  At the Community and Census Tract levels of geography, all data are displayed for the years 2013 to 2017 combined.  These years are combined for statistical stability, so that for these more granular levels of geography, the displayed data are still meaningful, and not just the result of random fluctuations.

- Key definitions
  - Communities:  Throughout the CCB, communities are defined by Medical Service Study Areas (MSSAs), a unique California geographic designation based on aggregation of census tracts, constructed by the California Office of Statewide Health Planning and Development (OSHPD) with each decennial census [CHHS/OSHPD/MSSA](https://oshpd.maps.arcgis.com/home/item.html?id=a20100c4bf374bd081bb49b82cbaaac3#overview). MSSAs provide the CCB with a good surrogate for &quot;communities&quot; because:
    - (1) there are 542 MSSAs for the 2010 census, providing much more geographic granularity than the 58 California counties and much greater numerical/statistical stability than the 8000+ California 2010 census tracts,
    - (2) in general, they are aligned with &quot;communities&quot; in the important sense of geographic, cultural, and sociodemographic similarities (although this is generally more true for urban than rural MSSAs, because of the larger size of MSSAs in rural areas),
    - (3) the names associated with each MSSA have some resonance in many cases with local ideas of &quot;community.&quot;

    - Although not yet implemented in a fully automated fashion, users can work with the CCB project team to create their own customized communities (based on designated census tracts) for incorporation into the CCB.

  - Social Determinants of Health: The conditions in which people are born, grow, live, work, and age, including the health system. These circumstances are shaped by the distribution of money, power and resources at global, national and local levels.

- Data and other key inputs:
  - Death data
    - Provided by California Department of Health (CDPH), Center for Health Statistics and Informatics (CHSI) [CDPH/CHSI/Death Files](https://www.cdph.ca.gov/Programs/CHSI/Pages/Data-Applications.aspx) (with key information and differences about these files [here)](https://www.cdph.ca.gov/Programs/CHSI/CDPH%20Document%20Library/HIRS-Comparison%20of%20CA%20Death%20Data%20Sources.pdf).
      - Files used: &quot;Death Static Master Files (DSMF)&quot;  for 2000 to 2004 and &quot;California Comprehensive Death Files(CCDF)&quot;  2005-2017. 
      - Deaths of California residents that occurred and were recorded outside of California have not yet been incorporated into any of the CCB working data 
      - A death record was considered to be of a California resident based on field &quot;71, Residence State/Province&quot; for the most recent data and on field &quot;46 State of Residence&quot; for 2001-2004 data. A tiny fraction of these records geocoded to locations outside of California, and others had anomalies suggesting the possibility that the residence was not in California.  However, the number of such anomalies is relatively minuscule, such that they are extraordinarily unlikely to have any impact on observed patterns and trends.
      - County was based on field &quot;62, Decedent&#39;s County of Residence Based on City/State (NCHS Code)&quot; for 2011-2017 data and on field &quot;35, Place of Decedent&#39;s Residence&quot; for 2001-2004 data except when modified as noted in &quot;Census Tract Data Issues&quot; below.
      -  California death data are geocoded using the CDPH geocoding service, which uses StreetMap Premium for ArcGIS.  We have not determined if there is a confidence score or match score below which the census tract for an address is not provided. For 2011-2017, the years where the CCB uses these data to determine census tract and (and therefore communities), a high percentage of records geocoded to a valid census tract (96.4% to 97.2%)—the remaining records contained invalid addresses and/or other anomalies. 
      - Other data coding and cleaning issues:

  - Social Determinants of Health (SDOH)
    - The CCB currently contains a small, exploratory set of SDOH variables extracted from the [California Healthy Places Index (HPI)](https://healthyplacesindex.org/) (publicly available files at [HPI](https://healthyplacesindex.org/data-reports/)). The CBD short term road-map includes a plan to extract SDOH data directly from US Census / American Community Survey API (URL) using the [R tidycensus package](https://walkerke.github.io/tidycensus/). Of note, related publicly available data for all census tracts in the United States can be downloaded from the CDC/ASTDR Social Vulnerability Index (SVI) project at [CDC/ASTDR/SVI](https://svi.cdc.gov/data-and-tools-download.html).
                                
  - Population data
    - For census tracts (and therefore communities) population denominator data are based on the [American Community Survey](https://www.census.gov/programs-surveys/acs/guidance.html) 5-year extracts (tables B01001\_001E, B01001\_002E, and B01001\_026E) using the most recent 5-year period available corresponding to the 5-year tract/community data being analyzed in the CBD (e.g. 2013-2017 death data uses the 2016 ACS data, which covers 2012-2016).  Community population data are generated by aggregating these census data up to the community level.
    - ACS data are extracted directly from the Census/ACS API (Application Program Interface) using the [R tidycensus package](https://walkerke.github.io/tidycensus/).
    - For counties, population denominator data are based on [estimates from the California Department of Finances (DOF)](http://www.dof.ca.gov/Forecasting/Demographics/Estimates/), and are downloaded directly via API from the [State of California Open Data Portal](https://data.ca.gov/dataset/california-population-projection-county-age-gender-and-ethnicity).

- GIS
  - Boundary (or &quot;shape&quot;) files for the CBD were generated using the tracts() function of the [R tigris package](https://github.com/walkerke/tigris), modified to be of smaller file size using the ms\_simplify() function of R rmapshaper package, and with removal of islands off the west coast of some counties using a custom island removal function.
  - Maps do not currently use any explicit projection, but easily could, and probably should, based on user input.

- ICD-10 Mapping
  - In the current version of the CBD project, only the single underlying cause of death ICD-10 code is used. A future release of the CBD may incorporate &quot;multiple cause of death&quot; codes for some conditions.
  - We based the hierarchal list of about 70 disease/injury conditions used in the CBD on a variant of the World Health Organization (WHO) global burden of disease condition list, modified to enhance the usefulness and applicability for U.S. public health priorities and programs. The hierarchy has three levels. The &quot;Top Level&quot; includes &quot;Infectious Diseases&quot;, &quot;Coronary Heart Disease&quot;, &quot;Cancer/Malignant Neoplasms&quot;, &quot;Other Chronic Conditions&quot;, and &quot;Injury&quot; as well as all causes combined. For data displayed at the census tract level, only this level of the hierarchy is included due to sample size and statistical reliability limitations. The next, &quot;Public Health&quot; level, splits each of these top levels into about 50 subcategories, and this is the default level for data/maps displayed at the community level. The final detailed level breaks a few of these Public Health level conditions down further, for the total of about 70 categories. All the levels are shown for data/maps displayed at the county level.
    - County:            Top Level, Public Health Level, Detail Level
    - Community:         Top Level, Public Health Level
    - Census Tract:      Top Level
  - Categorization of deaths was extracted from death certificates based on the International Classification of Diseases version 10 (ICD-10). The primary basis for the ICD10–to-condition mapping was the WHO Annex Table A from &quot;[WHO methods and data sources for global burden of disease estimates 2000-2015, January 2017](http://www.who.int/healthinfo/global_burden_disease/GlobalDALYmethods_2000_2015.pdf)&quot;.  We did not use a similar, more recent and more detailed, system developed by the Institute for Health Metrics and Evaluation (IHME) at the University of Washington (recent relevant pulications include [The State of US Health, 1990-2016 Burden of Diseases, Injuries, and Risk Factors Among US States, JAMA 2018](https://jamanetwork.com/journals/jama/fullarticle/2678018) and [US County-Level Trends in Mortality Rates for Major Causes of Death, 1980-2014, JAMA 2016](https://jamanetwork.com/journals/jama/fullarticle/2592499)) in this version of the CBD because that system resulted in 721,783 (19.2%) of California deaths from 2000 to 2015 being mapped to &quot;garbage codes&quot;, for which more sophisticated methods would need to be employed. The possibility of redistributing these &quot;garbage codes&quot; to valid categories at the census tract level and otherwise using the IHME system is being explored and may be implemented in future versions of the CBD.  However, to enhance our use of the WHO system we compared the mapping of 3,758,856 deaths based on the WHO and IHME systems and changed the WHO mapping of ICD codes for several categories wherein the IHME classification was considered more appropriate (e.g., specific cancer sites rather than &quot;other malignant neoplasms.&quot;).  All of these modifications are carefully described in a key resources tool for the CBD, available [here](https://github.com/mcSamuelDataSci/CACommunityBurden/blob/master/myCBD/myInfo/gbd.ICD.Map.xlsx) on our GitHub site. In addition, because our focus was on the &quot;Public health&quot; list of conditions, we remapped a number of ICD-10 codes from the WHO mapping to our own CBD system. All of these modifications are documented in a &quot;key resources&quot; tab for the CBD available noted above.
  - The lastest IHME/GBD results and methods can be found [here](https://www.thelancet.com/journals/lancet/issue/vol392no10159/PIIS0140-6736(18)X0048-8)

- Census Tract Data Issues
  - Of the 8041 California census tracts in the 2010 Census "Tiger" files, five have zero land area (only water), and (not surprisingly...) have zero population and zero deaths. These tracts are excluded from CCB data processing and display.
  - Of the remaining 8036 tracts, 12 have zero population and zero deaths. By definition, these tracts are excluded from all analyses, and will show values of "0" or missing for all measures in all maps. These tracts are wholly comprised of industrial facilities, airports, or parks. 
  - Census tracts (and communities) where greater than 50 percent of the population live in congregant living quarters will noted with an &quot;\*&quot; on relevant maps and charts in an upcoming CCB release.  For some comparisons (e.g. of rates) these tracts could be removed from the larger geographies in which they are contained, based on user request.
  - During a detailed review of multiple data sources, we observed a number of instances where stated county of residence was not consistent with the census tract to which that death was geocoded. In these instances we recoded the county based on the address and subsequent geocode.



-  Formulas and measures
  - Years of Life Lost (YLL)
    - Following the methods of the Global Burden of Disease Study, the YLL for each death is based on the age at death, and the additional number of years a person living in an optimal setting could be expected to live (page 30, [here](http://www.who.int/healthinfo/global_burden_disease/GlobalDALYmethods_2000_2015.pdf)). For example, someone dying at birth would be associated with 91.94 YLL, someone dying at 25 associated with 67.08 years, and someone dying at 98 with 3.70 years. Beyond the published data, we associated 1.0 YLL for anyone dying above age 105.
    - Our mapping of age at death to YLL can be found on our GitHub site [here](https://github.com/mcSamuelDataSci/CACommunityBurden/blob/master/myCBD/myInfo/le.Map.xlsx).
  - Crude rates
    - All rates are expressed per 100,000 people based on the following calculations:
      - 100,000\*(number (e.g. deaths, potential years of life lost) / midyear population)
    - Confidence intervals for crude rates are based on the pois.approx() function of the [R epitools package](https://github.com/cran/epitools).
  - Age adjusted rates
    - Age-adjusted rates are based on the &quot;direct&quot; method, using standard definitions and procedures. Great descriptions and the motivations for these methods can be found [here](https://www26.state.nj.us/doh-shad/sharedstatic/AgeAdjustedDeathRate.pdf), from the New Jersey Department of Health, and [here](https://www.cdc.gov/nchs/data/statnt/statnt06rv.pdf), from CDC.
    - The US 2000 Standard Population from [NCI](https://seer.cancer.gov/stdpopulations/) and [CDC/NCHS](https://www.cdc.gov/nchs/data/statnt/statnt20.pdf) was used; details of the methods and implications of using the 2000 stardard population are described by NCHS and can be found [here](https://www.cdc.gov/nchs/data/nvsr/nvsr47/nvs47_03.pdf)
    - Ten age-groupings were used for these calculations.These groups and the corresponding standard population data can be found [here](https://github.com/mcSamuelDataSci/CACommunityBurden/blob/master/myCBD/myInfo/Age%20Groups%20and%20Standard%20US%202000%20pop.xlsx).
    - The age-adjusted calculation, and generation of confidence intervals was conducted using the &quot;ageAdjust.Direct()&quot; function of the [R epitools package](https://github.com/cran/epitools).
    - Because a very small number of census tracts with otherwise useful data had zero population in one or more age strata (often the youngest or oldest strata, for just one sex), the above-mentioned function was modified such that rates in such strata were assigned to (reasonably enough) be 0 (rather than undefined/infinity), allowing an adjusted rate to be calculated.


</div>

