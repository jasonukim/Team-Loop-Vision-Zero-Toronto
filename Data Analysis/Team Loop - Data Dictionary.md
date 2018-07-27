# Data Dictionary

In selecting which datasets to use in the short amount of time available, we prioritized datasets which could give us the most information regarding our two outcome variables of interest (`number of collisions` and `KSI risk`) with the least amount of pre-processing and cleaning.    

**Number of Datasets Used:** 12
**Number of Datasets Created:** 3

The original source datasets are linked for reference. All work completed by [Jason U. Kim](mailto:hello@jasonukim.com).


# Primary Datasets 
## Collisions


This dataset is a heavily cleaned and processed version of the [Collisions - Events and Collisions - Involved](https://github.com/CityofToronto/vz_challenge/tree/master/transportation/collisions) datasets.


|Column Name|Type|Description|
|-----|-----|-----|
collision_id|Integer|The unique identifier of the dataset, linking this dataset with the `Collisions Involved` dataset. This is not the identifier used by Toronto Police Services, and is unique to this dataset.
collision_date|Date|Date when the collision took place (yyyy-mm-dd).
collision_time|Integer|Time when the collision occurred. Format is in "hhmm".
px|Integer|Primary identifier of all signalized intersection. Please see [Traffic Signals](../traffic_signals/).
street_1|Text|Street/address that the collision occurred on. 
street_2|Text|Cross-street/address that the collision occurred on.
street_type_2|Text|Suffix/type of the second street.
direction_2|Text|Direction of traffic on the second street that the collision occurred on.
street_3|Text|Third street, if any, the collision occured on.
street_type_3|Text|Suffix/type of the third street.
direction_3|Text|Direction of traffic on the third street that the collision occurred on.
location_class|Text|Class of the location on the road where the collision occurred.
location_desc|Text|Location on the road where the collision occurred.
collision_type|Text|Class/severity of the collision.
impact_type|Text|Type of impact that occurred in the collision.
road_class|Text|Class of road the collision occurred on.
visibility|Text|Visibility conditions at the time and location of the collision.
light|Text|Lighting conditions at the time and location of the collision.
road_surface_cond|Text|Condition of the road surface at the time and location of the collision.
longitude|Numeric|Longitude.
latitude|Numeric|Latitude.
collision_id|Integer|Collision unique identifier.
traffic_control|Text|Type of traffic control at the intersection/road (e.g. traffic light, stop sign etc.).
vehicle_class|Text|Class of the vehicle involved in the collision.
initial_dir|Text|Direction the vehicle/cyclist/pedestrian was travelling.
event1|Text|Object/vehicle involved in the collision.
event2|Text|Action the vehicle undertook.
event3|Text|Fixed object involved in the collision.
involved_class|Text|Type of involved individual.
involved_age|Text|Age of involved individual.
involved_injury_class|Text|Level of injury sustained by the individual.
safety_equip_used|Text|Type of safety equipment used by the vehicle.
driver_action|Text|Apparent driver action.
pedestrian_action|Text|Apparent pedestrian action.
pedestrian_collision_type|Text|Categorization of pedestrian collision type.
cyclist_action|Text|Apparent cyclist action.
cyclist_collision_type|Text|Categorization of cyclist collision type.
manoeuver|Text|Vehicle manoeuver.
ksi_check | binary | "1" if the collision was a KSI; "0" if not
intersection_check | binary | "1" if the collision was at an intersection
is_senior | binary | "1" if the collision involved someone 65+ in age
is_child | binary | "1" if the collision involved someone under 18 years old
daylight_check | binary | "1" if the collision took place in day light 
visibilily_check | binary | "1" if the collision took place in clear conditions
road_surface_cond | binary | "1" if the collision took place with dry road conditions
arterial_check | binary | "1" if the collision took place on an arterial road
pedestrian_check | binary | "1" if the collision involved a pedestrian; "0" if cyclist 

**Note**: Most fields will only be populated if applicable/available.


## Everything Joined 


This dataset is the `Collisions` dataset left joined to all the joinable datasets (below) so that joins don't need to be performed every time a new analysis needs to be done and in case working with multiple tables at once is too cumbersome. 


## Collisions by Neighbourhood 


This dataset was created from the above `Collisions` dataset, except with the records grouped by Neighbourhoods. It was initially created in Hadoop/Hive using the following query:


```SQL
SELECT area_s_cd, area_name, count(*) as collisions, sum(ksi_check), sum(fatal_check), sum(intersection_check), sum(is_senior), sum(is_child), sum(daylight_check), sum(visibilily_check), sum(arterial_check), sum(pedestrian_check) 
FROM vz.collisions 
GROUP BY area_s_cd, area_name 
ORDER BY collisions desc;
``` 


Later, additional fields were added to help create the Toronto High Injury Network and its Composite Score in R. 


## Collisions by Street


This dataset was created from the above `Collisions` dataset, except with the records grouped by unique Street ID (LFN_ID), which is an ID given to actual streets (as opposed to line segments) in the Toronto Centreline shapefile. It was initially created in Hadoop/Hive using the following query:


```SQL
SELECT lfn_id, street1, count(*) as collisions, sum(ksi_check), sum(fatal_check), sum(intersection_check), sum(is_senior), sum(is_child), sum(daylight_check), sum(visibilily_check), sum(arterial_check), sum(pedestrian_check)
FROM vz.collisions 
GROUP BY lfn_id, street1 
ORDER BY collisions desc;
```


Later, additional fields were added to help create the Toronto High Injury Network and its Composite Score in R. 




# Joined Datasets 


## Toronto Centreline


We used the [Centreline](https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-catalogue/#e4ec3384-056f-aa59-70f7-9ad7706f31a3) shapefile as-is and joined relevant attributes to the `Collisions` dataset using a K-Nearest Neighbours and spatial join in QGIS. 


## Neighbourhood Boundaries 


We used the [Neighbourhood](https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-catalogue/#a45bd45a-ede8-730e-1abc-93105b2c439f) shapefile as-is and joined relevant attributes to the `Collisions` dataset using a join on street names in Tableau Prep.


## Civics 


This is a transformed version of the Wellbeing Toronto - Civics dataset availiable through the City of Toronto's [Open Data Catalogue](https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-catalogue/#612399e3-f046-ad8f-a8fd-7694b3dd2c81). We used 2011 measures when available, 2008 if not. 


The `Collisions` dataset doesn't contain any information on the wider social context for a collision, which can be important for collision predictions. The fields in this dataset help paint a bigger picture for almost every single collision, helping us determine whether there are broad neighbourhood-level factors that affect either collision risk or risk of KSIs (killed or seriously injured). 


| Column Name | Type | Description |
|-------------|------|-------------|
Neighbourhood	| Text | Neighbourhood name 
Neighbourhood Id | Integer | Neighbourhood Id 
City Grants Funding $	| Integer | The amount in Canadian dollars that the neighbourhood received in city grant funding
Diversity Index	| Float |Ethnic Diversity Index compiled from Statistics Canada Census 2006. This indicator reflects the ethnic diversity of a neighbourhood, by comparing how many ethnicities (such as Chinese, Scottish, Italian, etc.) there are in a given neighbourhood and how the proportions are distributed (for example, 20%/40%/40% or 5%/5%/90%). The entropy method of determining heterogeneity was used with Census 2006 Ethnic Origin Total Responses data. Higher values indicate greater ethnic diversity (more heterogeneity), lower values indicate lesser ethnic diversity (more homogeneity). 
Voter Turnout	| Float | Percentage of population that voted in 2008
Walk Score | int | Measures walkability on a scale from 0 - 100 based on walking routes to destinations such as grocery stores, schools, parks, restaurants, and retail. More information can be found on the walkscore.com website. Original raw data has been transformed from a 0-100 scale to Wellbeing Toronto's 1-100 scale. 
Neighbourhood Equity Score | float | Composite indicator of 15 neighbourhood outcomes using data from Urban HEART@Toronto. Indicators measure outcomes related to economic opportunities, social development, participation in decision-making, physical surroundings, and healthy lives.
Salvation Army Donors | int | Number of Salvation Army Donors by Neighbourhood, computed from 6-digit postal codes from the Active Donors database for 2011 and aggregated to neighbourhoods. 
equity_check |  binary | If the equity score is *below* average, "1". If not, "0".	
walk_check | binary | If the walk score is *below* average, "1". If not, "0".	
diversity_check | binary |	If the diversity score is *below* average, "1". If not, "0".	
turnout_check | binary | If the voter turnout rate is *below* average, "1". If not, "0".	


## Economics


This is a transformed version of the Wellbeing Toronto - Economics dataset availiable through the City of Toronto's [Open Data Catalogue](https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-catalogue/#e3a085d5-8e94-e279-4c17-33c209141464). 2011 data is used where available; 2008 if not. 


The `Collisions` dataset doesn't contain any information on the wider social context for a collision, which can be important for collision predictions. The fields in this dataset help paint a bigger picture for almost every single collision, helping us determine whether there are broad neighbourhood-level factors that affect either collision risk or risk of KSIs (killed or seriously injured). 


| Column Name | Type | Description |
|-------------|------|-------------|
Number of Businesses | int | Total number of licensed business establishments.
Child Care Spaces | int |Licensed child care spaces 
Social Assistance Recipients | int | Count of recipients of aid qualifying for Ontario Works, Temporary Care (OW), Ontario Disability Support Program (ODSP) or Special Assistance (ODSP/OW) programs
Local Employment | int | Total local employment (jobs), persons aged 15+ years. 
Debt Risk Score | int | The Risk Score is a proprietary index value provided by TransUnion Canada that indicates the likelihood of missing three consecutive loan payments. Low-value scores (<707) indicate a High Risk of missing 3 consecutive loan payments; High-value scores (769+) indicate a low risk. These risk scores are calculated for non-mortgage consumer debt such as lines of credit, credit cards, automobile loans and installment loans. TransUnion data is provided by postal code and covers approximately 92% of all Canadians with credit files. For privacy reasons, postal codes with fewer than 15 credit files are suppressed. TransUnion dataset provided by the [Community Data Program](www.communitydata.ca).
Home Prices | int | Average price for residential real estate sales during the period 2011-2012, in Canadian dollars. Data collated by Realosophy.com.  
businesses_check | binary | If the number of businesses is above city average, "1". If not, "0".
childcare_check | binary |	If the number of child care spaces is above city-wide average, "1". If not, "0".
homeprice_check | binary |	If the average house price is above the city-wide average, "1". If not, "0".
localemployment_check | binary | If the number of local jobs is above the city average, "1". If not, "0".
socialasst_check | binary | If the number of social assistance recepients is above city average, "1". If not, "0".




## Neighbourhood Profiles 


This is a processed and transformed version of the Neighbourhood Profiles dataset availiable through the City of Toronto's [Open Data Catalogue](https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-catalogue/#8c732154-5012-9afe-d0cd-ba3ffc813d5a). It contains data based on the 2016 Census, making it far more up-to-date than related datasets with similar measures like the Wellbeing Toronto datasets. 


The `Collisions` dataset doesn't contain any information on the wider social context for a collision, which can be important for collision predictions. The fields in this dataset help paint a bigger picture for almost every single collision, helping us determine whether there are broad neighbourhood-level factors that affect either collision risk or risk of KSIs (killed or seriously injured). 


| Column Name | Type | Description |
|-------------|------|-------------|
Hood Name | string | Name of the neighbourhood
Hood ID | int | Unique id of neighbourhood
Population 2016 | int | Population of neighbourhood according to 2016 census
Population density per square kilometre | float | Population density per sq km 
Land area in square kilometres | flaot | Land area in sq km 
Children (0-14 years) | int | Number of children living in area
Youth (15-24 years) | int | Number of youth living in area
Working Age (25-54 years) | int | Number of working aged people living in area
Pre-retirement (55-64 years) | int | Number of pre-retirement aged people living in area
Seniors (65+ years) | int | Number of seniors living in area
Older Seniors (85+ years) | int | Number of older seniors living in area
% Immigrants | float | Percentage of neighbourhood population that is an immigrant 
% Visible Minority | float | Percentage of neighbourhood population that identify as a visible minority
Unemployment rate | float | The unemployment rate in percentage 
Commute within census subdivision (CSD) of residence | int | Number of people who work and are age 15+ who commute within the area in which they live 
% Commute in Car truck | float | Percentage of people who work and are age 15+ who commute to work primarily by car or truck 
% Commute in Public transit | float | Percentage of people who work and are age 15+ who commute to work primarily by public transit
% Commute in Walked | float | Percentage of people who work and are age 15+ who commute to work primarily by walking
% Commute by Bicycle | float| Percentage of people who work and are age 15+ who commute to work primarily by bicycle
% Commute by Other | float | Percentage of people who work and are age 15+ who commute to work primarily by other means
Commuting duration - Less than 15 minutes | int | Number of people whose commute lasts the listed duration
Commuting duration - 15 to 29 minutes | int | Number of people who work and are age 15+ whose commute lasts the listed duration
Commuting duration - 30 to 44 minutes | int | Number of people who work and are age 15+ whose commute lasts the listed duration
Commuting duration - 45 to 59 minutes | int | Number of people who work and are age 15+ whose commute lasts the listed duration
Commuting duration - 60 minutes and over | int | Number of people who work and are age 15+ whose commute lasts the listed duration
% Time leaving for work - Between 5 a.m. and 5:59 a.m. | float | Percentage of people who work and are age 15+ who leave for work during the listed time
% Time leaving for work - Between 6 a.m. and 6:59 a.m. | float | Percentage of people who work and are age 15+ who leave for work during the listed time
% Time leaving for work - Between 7 a.m. and 7:59 a.m. | float | Percentage of people who work and are age 15+ who leave for work during the listed time
% Time leaving for work - Between 8 a.m. and 8:59 a.m. | float | Percentage of people who work and are age 15+ who leave for work during the listed time
% Time leaving for work - Between 9 a.m. and 11:59 a.m. | float | Percentage of people who work and are age 15+ who leave for work during the listed time
% Time leaving for work - Between 12 p.m. and 4:59 a.m. | float | Percentage of people who work and are age 15+ who leave for work during the listed time
child_check | binary | If the neighbourhood has an above average number of children living in it a "1" is assigned; if not, "0".
senior_check | binary | If the neighbourhood has an above average number of seniors living in it a "1" is assigned; if not, "0".
minority_check | binary | If the neighbourhood has an above average number of visible minorities living in it a "1" is assigned; if not, "0".
immigrants_check | binary | If the neighbourhood has an above average number of immigrants living in it a "1" is assigned; if not, "0".
commute_car_check | binary | If the neighbourhood has an above average number of people who commute to work by car a "1" is asiigned; if not, "0".




## Income


This is a transformed version of the [Toronto Health Profiles - Income](http://www.torontohealthprofiles.ca/ont/dataTablesON.php?varTab=HPDtbl&select1=7) dataset. This dataset uses income measures from the 2016 Census and also uses Neighbourhoods as the unit of analysis, making it uniquely well-suited to join to our collisions dataset in order to see if there is a relationship between income and collision or injury risk. 


The `Collisions` dataset doesn't contain any information on the wider social context for a collision, which can be important for collision predictions. The fields in this dataset help paint a bigger picture for almost every single collision, helping us determine whether there are broad neighbourhood-level factors that affect either collision risk or risk of KSIs (killed or seriously injured). 


| Column Name | Type | Description |
|-------------|------|-------------|
HOOD ID	| int | Unique ID for neighbourhood
HOOD NAME | string | Name of neighbourhood 
Total % In LIM-AT	| float | Percentage of households who fall into the "low income measure - after tax" category according to the 2016 Census. This measure takes into account the reduced spending power of larger households. You can learn more about the LIM-AT from [Statistics Canada](https://www12.statcan.gc.ca/census-recensement/2016/ref/dict/fam021-eng.cfm). 
lim_check | binary | If an above average number of households fall under the LIM-AT category, "1", If not, "0".




## Language


This is a transformed version of the [Toronto Health Profiles - Language Spoken Most Often at Home](http://www.torontohealthprofiles.ca/ont/dataTablesON.php?varTab=HPDtbl&select1=7) dataset. This dataset uses income measures from the 2016 Census and also uses Neighbourhoods as the unit of analysis, making it uniquely well-suited to join to our collisions dataset. Since the collision reports do not record the ethnic, linguistic, or newcomer status of collision victims, we used the prevalance of non-official languages spoken at home in the area the collision occurred as one of our proxy variables to see if there is a relationship between newcomer status and collisions.


The `Collisions` dataset doesn't contain any information on the wider social context for a collision, which can be important for collision predictions. The fields in this dataset help paint a bigger picture for almost every single collision, helping us determine whether there are broad neighbourhood-level factors that affect either collision risk or risk of KSIs (killed or seriously injured). 
 
 | Column Name | Type | Description |
|-------------|------|-------------|
HOOD ID	| int | Unique ID for neighbourhood
HOOD NAME | string | Name of neighbourhood 
MOST SPOKEN NON-OFFICIAL LANG | string | The most spoken non-official language at home 
2ND MOST SPOKEN NON-OFFICIAL LANG | string | The 2nd most spoken non-official language at home 
3RD MOST SPOKEN NON-OFFICIAL LANG | string | The 3rd most spoken non-official language at home
% OFFICIAL LANG AT HOME	| float | Percentage of people who primarily speak one of Canada's official languages at home
% NON-OFFICIAL LANG AT HOME	| float | Percentage of people who primarily speak a non-official language at home
language_check | binary | If an above average percentage of people speak a non-official language at home, "1". If not, "0".


## Transportation


This is a transformed version of the Wellbeing Toronto - Transportation dataset availiable through the City of Toronto's [Open Data Catalogue](https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-catalogue/#cfa93ad9-7397-e851-f13e-f5097ed0fd55). We used 2011 measures when available, 2008 if not. 


The `Collisions` dataset doesn't contain any information on the wider social context for a collision, which can be important for collision predictions. The fields in this dataset help paint a bigger picture for almost every single collision, helping us determine whether there are broad neighbourhood-level factors that affect either collision risk or risk of KSIs (killed or seriously injured). 


| Column Name | Type | Description |
|-------------|------|-------------|
Neighbourhood	| Text | Neighbourhood name 
Neighbourhood Id | Integer | Unique Neighbourhood Identifier
TTC Stops | Integer | Total number of TTC stops
Pedestrian/Other Collisions	| Integer | Total number of pedestrian, cyclist and private property collisions
Traffic Collisions | Integer | Total number of traffic collisions
Road Kilometres	| Integer | Total number of road kilometres
Road Volume | Integer | Total 24-hour volume (collector roads only)
ttc_check	| binary | If the number of TTC stops is above the average, "1". If not, "0".
road_km_check | binary | If the total road kilometrage is above the average, "1". If not, "0".	
road_vol_check | binary | If the total 24-hour volume of traffic on collector roads is above average, "1". If not, "0".

e, "1". If not, "0".
road_km_check | binary | If the total road kilometrage is above the average, "1". If not, "0".	
road_vol_check | binary | If the total 24-hour volume of traffic on collector roads is above average, "1". If not, "0".


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTM4NDc1MDQzNF19
-->