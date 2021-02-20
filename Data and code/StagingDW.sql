
-- Staging Data
use ViolenceDWStage

Select Identity(int, 1, 1) as Police_death_ID,
	Person,
	Cause,
	DateKey,
	Dept_name,
	State
Into [dbo].[ViolenceStage_Police_Death]
From [Violence].[dbo].[Police_Deaths_Dimension]

Select Identity(int, 1, 1) as Police_killing_ID,
	Name,
	Age,
	Gender,
	Race,
	DateKey,
	City,
	State,
	County,
	Agency_responsible,
	Cause,
	Status,
	Criminal_charges,
	Mental_illness,
	Unarmed,
	Weapon,
	Threat_level,
	Fleeing,
	Off_duty,
	Geography
Into [dbo].[ViolenceStage_Police_Killing]
From [Violence].[dbo].[Police_Killings_Dimension]

Select 
	date_key as DateKey,
	Full_date,
	Day_of_week,
	Day_name,
	Month,
	Month_name,
	Quarter,
	Year
Into [dbo].[ViolenceStage_Date]
From [Violence].[dbo].[Date_Dimension]

------------------------------------------------------------------------------------------------------------------------------------



-- Create DW table
use ViolenceDW

Create Table Dim_Police_Death
(
Police_death_ID int primary key,
Person nvarchar(50),
Cause nvarchar(19),
Dept_name nvarchar(107),
State nvarchar(15)
)

Create Table Dim_Police_Killing
(
Police_killing_ID int primary key,
Name varchar(32),
Age int,
Gender varchar(6),
Race varchar(15),
City varchar(20),
State varchar(15),
County varchar(15),
Agency_responsible varchar(105),
Cause varchar(33),
Status varchar(33),
Criminal_charges varchar(20),
Mental_illness varchar(20),
Unarmed varchar(15),
Weapon varchar(15),
Threat_level varchar(12),
Fleeing varchar(11),
Off_duty varchar(8),
Geography varchar(9)
)

Create Table Dim_Date
(
DateKey int primary key,
Full_date smalldatetime,
Day_of_week tinyint,
Day_name varchar(9),
Month tinyint,
Month_name varchar(9),
Quarter tinyint,
Year smallint
)

Create Table Fact_Police_Death
(
Police_death_ID int,
DateKey int,
foreign key (Police_death_ID) references Dim_Police_Death (Police_death_ID),
foreign key (DateKey) references Dim_Date (DateKey)
)

Create Table Fact_Police_Killing
(
Police_killing_ID int,
DateKey int,
foreign key (Police_killing_ID) references Dim_Police_Killing (Police_killing_ID),
foreign key (DateKey) references Dim_Date (DateKey)
)
----------------------------------------------------------------------------------------------------------------------------------------------


-- Create database DW
use ViolenceDW

Insert Into [ViolenceDW].[dbo].[Dim_Date]
	(DateKey, Full_date, Day_of_week, Day_name, Month, Month_name, Quarter, Year)
Select DateKey, Full_date, Day_of_week, Day_name, Month, Month_name, Quarter, Year
From [ViolenceDWStage].[dbo].[ViolenceStage_Date]

Insert Into [ViolenceDW].[dbo].[Dim_Police_Death]
	(Police_death_ID, Person, Cause, Dept_name, State)
Select Police_death_ID, Person, Cause, Dept_name, State
From [ViolenceDWStage].[dbo].[ViolenceStage_Police_Death]

Insert Into [ViolenceDW].[dbo].[Dim_Police_Killing]
	(Police_killing_ID, Name, Age, Gender, Race, City, State, County,
	Agency_responsible, Cause, Status, Criminal_charges, Mental_illness,
	Unarmed, Weapon, Threat_level, Fleeing, Off_duty, Geography)
Select Police_killing_ID, Name, Age, Gender, Race, City, State, County,
	Agency_responsible, Cause, Status, Criminal_charges, Mental_illness,
	Unarmed, Weapon, Threat_level, Fleeing, Off_duty, Geography
From [ViolenceDWStage].[dbo].[ViolenceStage_Police_Killing]

Insert Into [ViolenceDW].[dbo].[Fact_Police_Death]
	(Police_death_ID, DateKey)
Select Police_death_ID, DateKey
From [ViolenceDWStage].[dbo].[ViolenceStage_Police_Death]

Insert Into [ViolenceDW].[dbo].[Fact_Police_Killing]
	(Police_killing_ID, DateKey)
Select Police_killing_ID, DateKey
From [ViolenceDWStage].[dbo].[ViolenceStage_Police_Killing]



-- Query

-- Tổng số người chết theo chủng tộc
Select Race, num_of_victims, total_death,
	(num_of_victims/total_death) as Ratio
From
(
Select Race, count(*) as num_of_victims, 
	sum(count(*)) over () as total_death
From Dim_Police_Killing
Group by Race
) T

-- Số người chết theo từng năm và từng tháng
Select da.Year, da.Month, count(*) as num_of_victims
From Dim_Police_Killing di join Fact_Police_Killing f on di.Police_killing_ID = f.Police_killing_ID
	join Dim_Date da on da.DateKey = f.DateKey
Group by da.Year, da.Month
Order by Year, Month

-- Số người chết theo giới tính
Select Gender, count(*) as num_of_victims
From Dim_Police_Killing
Group by Gender
-- Suy ra cứ 19 người đàn ông sẽ có 1 phụ nữ bị bắn

-- Top các bang xảy ra nổ súng do CS nhiều nhất
Select State, count(*) as num_of_victims,
	Row_number() over (Order by count(*) desc) as Rank
From Dim_Police_Killing PK
Group By State

-- Top 5 bang nguy hiểm nhất cho từng màu da
Select Race, State, num_of_victims
From
(
Select Race, State, count(*) as num_of_victims,
	Row_number() over (Partition by Race Order by count(*) desc) as Rank
From Dim_Police_Killing PK
Where Race != 'Unknown race'
Group By Race, State
) T
Where Rank <= 5

-- Top 10 bang có nhiều vụ CS nổ súng nhất
Select top 10 State, count(*) as num_of_victims,
	Rank() over (Order by count(*) desc) as Rank
From Dim_Police_Killing PK
Group by State

-- Số người bỏ chạy mà bị bắn, phân chia theo chủng tộc
Select d.Fleeing, d.Race, Count(*) num_of_victims
From Dim_Police_Killing d
Group by ROLLUP(d.Fleeing, d.Race) 

-- Số người có vũ trang bị bắn, phân chia theo chủng tộc
Select d.Unarmed, d.Weapon, d.Race, Count(*) num_of_victims
From Dim_Police_Killing d
Group by d.Unarmed, ROLLUP(d.Weapon, d.Race)

Select d.Unarmed, d.Race, Count(*) num_of_victims
From Dim_Police_Killing d
Group by ROLLUP(d.Unarmed, d.Race)

-- Số người bị giết có vấn đề về tâm thần, phân theo chủng tộc
Select d.Mental_illness, d.Race, Count(*) num_of_victims
From Dim_Police_Killing d
Group by ROLLUP(d.Mental_illness, d.Race)

-- Top những bang có số lượng CS chết do bị tấn công nhiều nhất
Select 
 State, count(*) as num_of_victims,
	Rank() over (Order by count(*) desc) as Rank
From Dim_Police_Death d
Group by State

-- Những nguyên nhân mà các CS chết
Select Distinct Cause
From Dim_Police_Death

Select Distinct Mental_illness
From Dim_Police_Killing

Select replace(Mental_illness, 'Unkown', 'Unknown'),
	replace(Mental_illness, NULL, 'Unknown')
From Dim_Police_Killing

update Dim_Police_Killing
set Mental_illness = replace(Mental_illness, 'Unkown', 'Unknown')

update Dim_Police_Killing
set Mental_illness = ISNULL(Mental_illness, 'Unknown')