************************//////////Gabby Mora////////////************************

                         /////////*Problem Set 5*//////
                         ////////*Data Management*/////
                         //////////*Fall 2017*/////////

/*------------------------------------------------------------------------------
Research Questions
1- Does socio-economic status affect the number of animal abuse incidents in NYC?
2- Is there a connection between socio-economic status and other demographic items
and the number of animal abuse incidents in NYC?
3- Is there a difference between male and female when it comes to the severity
of animal abuse incidents in NYC?
4- What are the main factors affecting the severity of animal abuse incidents
in NYC?
------------------------------------------------------------------------------*/

/******************************************************************************
--------------------------------HYPOTHESIS-------------------------------------
********************************************************************************
As research in animal abuse points to an increase in incidents in areas of low
income and low education, this analysis of data from New York City should show
that socio-economic status is the main predictor for animal abuse.
With the exception of the Demographics and Animal Abuse datasets, the datasets
used in this research were selected as proxys for low socio-economic status as
areas with access to gardens and farmers markets tend to be areas of higher
socio-economic status. Furthermore, the variables connected to available financial
options found in the HIV Testing Centers dataset serve as a proxy income as it 
is expected that HIV Testing Centers found in areas of lower socio-economic status
will offer more financial options.
*******************************************************************************/
						 
/*------------------------------------------------------------------------------
********************************************************************************
--------------------------------------------------------------------------------
                       CLEAN UP AND RESHAPING MY DATASETS
--------------------------------------------------------------------------------
********************************************************************************
------------------------------------------------------------------------------*/

import excel "https://docs.google.com/uc?id=0BywXSn44t-HlS19LS0Z1cnVoQkE&export=download", firstrow clear
 
/*______________________________________________________________________________
                            ANIMAL CRUELTY DATASET
______________________________________________________________________________*/

drop UniqueKey CreatedDate ClosedDate Agency IncidentAddress StreetName CrossStreet1 CrossStreet2 IntersectionStreet1 IntersectionStreet2 AddressType Landmark Status DueDate ResolutionActionUpdatedDate CommunityBoard Borough XCoordinateStatePlane YCoordinateStatePlane ParkFacilityName ParkBorough SchoolName SchoolNumber SchoolRegion SchoolCode SchoolPhoneNumber SchoolAddress SchoolCity SchoolState SchoolZip SchoolNotFound SchoolorCitywideComplaint VehicleType TaxiCompanyBorough TaxiPickUpLocation BridgeHighwayName BridgeHighwayDirection RoadRamp BridgeHighwaySegment GarageLotName FerryDirection FerryTerminalName Latitude Longitude Location

edit 
 
tab Descriptor

/*This helped me see the number of animal abuse incidents per severity, which I
will use later to collapse into 3 categories according to the level of severity

               Descriptor |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
                  Chained |         40        6.31        6.31
                   In Car |         38        5.99       12.30
                Neglected |        292       46.06       58.36
               No Shelter |         23        3.63       61.99
Other (complaint details) |        149       23.50       85.49
                 Tortured |         92       14.51      100.00
--------------------------+-----------------------------------
                    Total |        634      100.00
*/


encode Descriptor, generate(Descriptor_n)

move Descriptor_n Descriptor

drop Descriptor

rename Descriptor_n Descriptor

tab LocationType

/*This helped me see how many different types of locations were included in the 
dataset ad lead me to combine all residential areas

             Location Type |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
                Commercial |          2        0.32        0.32
           House and Store |          3        0.47        0.79
           Park/Playground |         14        2.21        3.00
      Residential Building |         18        2.84        5.84
Residential Building/House |        379       59.78       65.62
          Store/Commercial |         52        8.20       73.82
           Street/Sidewalk |        166       26.18      100.00
---------------------------+-----------------------------------
                     Total |        634      100.00

*/

describe LocationType

replace LocationType = subinstr(LocationType, "/", "",.)

generate Location=0
//ResPrivate=1, Public=2, NonResidential=0//

replace Location=0 if LocationType=="StoreCommercial" | LocationType=="House and Store" | LocationType=="Commercial" 

replace Location=1 if LocationType=="Residential Building" | LocationType=="Residential BuildingHouse"

replace Location=2 if LocationType=="StreetSidewalk" | LocationType=="ParkPlayground"

encode LocationType, generate(LocationType_n)

move LocationType_n LocationType

drop LocationType

rename LocationType_n LocationType

rename IncidentZip ZipCode

save Animal_Abuse_COMPLETE, replace

/*______________________________________________________________________________
                          HIV TESTING CENTERS DATASET
______________________________________________________________________________*/
clear

import excel "https://docs.google.com/uc?id=0BywXSn44t-HlSmdVS2swdU4ycVE&export=download", firstrow clear

drop SiteID AgencyID Address City Borough State BriefDescription AgesServed GendersServed RequiredDocuments Website PhoneNumber BuildingFloorSuite AdditionalInformation

drop HoursMonday HoursTuesday HoursWednesday HoursThursday HoursFriday HoursSaturday HoursSunday Intake OtherInsurances SiteLanguages

encode ZipCode, generate(ZipCode_n)

drop ZipCode

rename ZipCode_n ZipCode

replace ZipCode=0 if ZipCode==.

save HIV_Testing_Centers_Clean, replace

/*______________________________________________________________________________
                          DEMOGRAPHICS DATASET
______________________________________________________________________________*/

clear

import excel "https://docs.google.com/uc?id=0BywXSn44t-HlMURzMmVjUExDRjg&export=download", firstrow clear

rename JURISDICTIONNAME ZipCode

drop COUNTGENDERUNKNOWN PERCENTGENDERUNKNOWN PERCENTFEMALE PERCENTMALE COUNTGENDERTOTAL PERCENTGENDERTOTAL PERCENTPACIFICISLANDER PERCENTHISPANICLATINO PERCENTAMERICANINDIAN PERCENTASIANNONHISPANIC PERCENTWHITENONHISPANIC PERCENTBLACKNONHISPANIC PERCENTOTHERETHNICITY PERCENTETHNICITYUNKNOWN COUNTETHNICITYTOTAL PERCENTETHNICITYTOTAL COUNTPERMANENTRESIDENT PERCENTPERMANENTRESIDENT COUNTUSCITIZEN PERCENTUSCITIZEN COUNTOTHERCITIZENSTATUS PERCENTOTHERCITIZENSTATUS COUNTCITIZENSTATUSUNKNOWN PERCENTCITIZENSTATUSUNKNOWN COUNTCITIZENSTATUSTOTAL PERCENTCITIZENSTATUSTOTAL PERCENTRECEIVESPUBLICASSISTAN PERCENTNRECEIVESPUBLICASSISTA PERCENTPUBLICASSISTANCEUNKNOW PERCENTPUBLICASSISTANCETOTAL

rename(COUNTPARTICIPANTS COUNTFEMALE COUNTMALE COUNTPACIFICISLANDER COUNTHISPANICLATINO COUNTAMERICANINDIAN COUNTASIANNONHISPANIC COUNTWHITENONHISPANIC COUNTBLACKNONHISPANIC COUNTOTHERETHNICITY COUNTETHNICITYUNKNOWN COUNTRECEIVESPUBLICASSISTANCE COUNTNRECEIVESPUBLICASSISTANC COUNTPUBLICASSISTANCEUNKNOWN) (TotalParticipants Female Male PacificIslander HispanicLatino AmericanIndian Asian White AfricanAmerican OtherEthnicity EthnicityUnknown PublicAssistance NoPublicAssistance PublicAssistanceUnknown)

save Demographics_Clean, replace

/*______________________________________________________________________________
                           FILMING PERMITS DATASET
______________________________________________________________________________*/

clear

import excel "https://docs.google.com/uc?id=0BywXSn44t-HlWnhZVkFzN1pNZ28&export=download", firstrow clear

drop EventID StartDateTime EndDateTime EnteredOn CommunityBoards Country ParkingHeld EventAgency SubCategoryName 

rename ZipCodes ZipCode

gen newzip=substr(ZipCode, 1, 5)

gen newzip2=substr(ZipCode, -5, 5) 

drop ZipCode

rename newzip ZipCode

drop newzip2

encode ZipCode, generate(ZipCode_n)

drop ZipCode

rename ZipCode_n ZipCode

save Filming_Permits_Clean, replace

/*______________________________________________________________________________
                              GARDENS DATASET
______________________________________________________________________________*/

clear

import excel "https://docs.google.com/uc?id=0BywXSn44t-HlRGQ5ZC1aYW9nYzA&export=download", firstrow clear

drop PropID Boro CommunityBoard CouncilDistrict CrossStreets Latitude Longitude CensusTract BIN BBL NTA

rename Postcode ZipCode

encode ZipCode, generate(ZipCode_n)

drop ZipCode

rename ZipCode_n ZipCode

replace ZipCode=0 if ZipCode==.

save Gardens_Clean, replace

/*______________________________________________________________________________
                          FARMERS MARKET DATASET
________________________________________________________________________________*/

clear

import excel "https://docs.google.com/uc?id=0BywXSn44t-HlTUhfR3ZQQ3hyZlE&export=download", firstrow clear

drop AdditionalInformation Latitude Longitude

save Farmers_Markets_Clean, replace

/*------------------------------------------------------------------------------
********************************************************************************
--------------------------------------------------------------------------------
                GETTING MY DATA READY FOR CROSS DATASET ANALYSIS
--------------------------------------------------------------------------------
********************************************************************************
------------------------------------------------------------------------------*/

clear

use "Demographics_Clean"

merge 1:m ZipCode using "Animal_Abuse_Complete" 

drop if Descriptor==.

drop _merge


recode Descriptor (6=6) (1=5) (2=4) (3=2) (4=3) (5=1), gen (Severity) 
/*I recoded so I could analyze the level of abuse (Descriptor) according to the
severity of the issue with 1 being the least severe and 6 the most: Other, 
Neglected, No Shelter, In Car, Chained, Torture).*/

save "Animal_Abuse_COMPLETE", replace


/*------------------------------------------------------------------------------
********************************************************************************
--------------------------------------------------------------------------------
                        ANALIZING MY DATA WITH GRAPHS
--------------------------------------------------------------------------------
********************************************************************************
------------------------------------------------------------------------------*/

hist Location, freq

/*This graph helped me quickly see that the majority of the animal abuse incidents
in the dataset ocurred in private/residential locations. I had previously recoded
all residential locations to be represented by 1 because I believe that abuse in
residential locations would mean that people are doing it in private while abuse
in the street or sidewalks would be done in public*/

hist Severity, freq

/*This graph showed me that Other is the most common incident of animal
abuse in NYC, with Neglected being the second most common. Unfortunately, no data
was found in reference to what "Other" applied to. The third most common incident
was Torture, which was surprising as I did not expect that many people to still
engage in torture of dogs. This lead me to want to look more into the level of
education and socio-economic status associated with these cases but I did not 
have the data on educational level so I will only focus on socio-economic status*/

/*------------------------------------------------------------------------------
********************************************************************************
--------------------------------------------------------------------------------
                          DESCRIPTIVE STATISTICS
--------------------------------------------------------------------------------
********************************************************************************
------------------------------------------------------------------------------*/

clear

/*I became interested in looking at what are of NYC had the largest amount of
animal abuse incidents, so I did a tabulation to quickly see the number.*/

use "Animal_Abuse_COMPLETE"

tabulate ZipCode Descriptor

/*
Incident |                            Descriptor
Zip      |Chained In Car  Neglected  No Shelte     Other  Tortured |     Total
---------+-----------------------------------------------------------+----------
   10002 |    18    12        111          9         50         36 |       236 
   10003 |     4    14         47          6         39          6 |       116 
   10009 |    14    11        120          8         50         46 |       249 
   10013 |     1     1          1          0          1          1 |         5 
   10038 |     3     0         13          0          9          3 |        28 
---------+---------------------------------------------------------+----------
   Total |    40    38        292         23        149         92 |       634 
*/
/*This allowed me to see how many incidents per incident type happened in each 
zip code I went online to look up where zip code 10009 was located in NYC (since 
it has the largest number of incidents, and found it is the East Village//
Once I found this information I was realized that my Gardens dataset has 
information on specific neighborhoords, including the East Village, so I 
decided to look at some of the observations in that dataset*/

use "Gardens_Clean"

tab NeighborhoodName


/*by looking at the frequency distribution, I can see that the East Village has 
35 parks out of the total 323 parks in NYC. This could help connect to the idea
of low socio-economic status in the East Village, where the number of animal
abuse incidents is the largest. However, additional data points are needed to
develop a solid argument and this will be explored in future research through
the use of both quantitative and qualitative research on the conditions and 
resources related to animal welfare in the East Village*/

/*Based on earlier findings of the commonality of each animal abuse incident by
severity, I did a regression between socio-economic status (where I used Public
Assistance as a proxy)*/

regress Severity PublicAssitance

/*
      Source |       SS           df       MS      Number of obs   =       634
-------------+----------------------------------   F(1, 632)       =      0.16
       Model |  .482185243         1  .482185243   Prob > F        =    0.6852
    Residual |  1852.92475       632  2.93184297   R-squared       =    0.0003
-------------+----------------------------------   Adj R-squared   =   -0.0013
       Total |  1853.40694       633  2.92797305   Root MSE        =    1.7123

----------------------------------------------------------------------------------
        Severity |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-----------------+----------------------------------------------------------------
PublicAssistance |     .02616   .0645061     0.41   0.685    -.1005122    .1528322
           _cons |   2.667704   .0887825    30.05   0.000     2.493359    2.842048
----------------------------------------------------------------------------------
Since the t value is below p=0.05 and positive, Public Assistance does not have a 
significant impact on the increase of severity of the animal abuse incident*/


/*I went back to my research questions and did a regression between the descriptor
and Public Assistance and Race. I will then crosstabulate race and
socio-economic status to see if there is a correlation*/

regress Severity PublicAssistance PacificIslander HispanicLatino AmericanIndian Asian White AfricanAmerican

/*note: PacificIslander omitted because of collinearity
note: HispanicLatino omitted because of collinearity
note: AmericanIndian omitted because of collinearity

      Source |       SS           df       MS      Number of obs   =       634
-------------+----------------------------------   F(4, 629)       =      2.84
       Model |  32.8777794         4  8.21944485   Prob > F        =    0.0236
    Residual |  1820.52916       629  2.89432299   R-squared       =    0.0177
-------------+----------------------------------   Adj R-squared   =    0.0115
       Total |  1853.40694       633  2.92797305   Root MSE        =    1.7013

----------------------------------------------------------------------------------
        Severity |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-----------------+----------------------------------------------------------------
PublicAssistance |  -2.587716   1.430618    -1.81   0.071    -5.397082    .2216495
 PacificIslander |          0  (omitted)
  HispanicLatino |          0  (omitted)
  AmericanIndian |          0  (omitted)
           Asian |   .5600679   .1912455     2.93   0.004     .1845109    .9356248
           White |  -1.574449   .5050454    -3.12   0.002    -2.566228   -.5826695
 AfricanAmerican |   .6887873   .6417678     1.07   0.284    -.5714796    1.949054
           _cons |   1.707174   .3338084     5.11   0.000      1.05166    2.362687
----------------------------------------------------------------------------------

I looked up what collinearity means and it means that a predictor variable
(in this case, Descriptor) can be linearly predicted with great certainty from 
the other variables.
Though the coefficient shows that Public Assistance has a negative impact on the 
increaseof the severity of the animal abuse cases, the P value tells me that this 
is not significant as it cannot only be traced to Public Assistance*/

/*After running these regressions I looked back at the dataset and realized that
PublicAssistance included the number of people who received public assistance
in each observation, so I recoded and generated a new Variable that would only
show me if people received it or not*/

recode PublicAssistance (1 2 3 = 1), gen (ReceivesPA)

regress Severity ReceivesPA

/*


-------------+----------------------------------   F(1, 632)       =      0.51
       Model |  1.48420237         1  1.48420237   Prob > F        =    0.4769
    Residual |  1851.92274       632   2.9302575   R-squared       =    0.0008
-------------+----------------------------------   Adj R-squared   =   -0.0008
       Total |  1853.40694       633  2.92797305   Root MSE        =    1.7118

------------------------------------------------------------------------------
    Severity |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
  ReceivesPA |   .0978968   .1375545     0.71   0.477    -.1722224    .3680161
       _cons |   2.649315   .0895997    29.57   0.000     2.473366    2.825264
------------------------------------------------------------------------------
*/

save "Animal_Abuse_COMPLETE", save

findit estout 

estout [Severity ReceivesPA] using "Animal_Abuse_COMPLETE"
