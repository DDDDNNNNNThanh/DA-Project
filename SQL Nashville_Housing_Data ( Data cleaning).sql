--- Observing the data
select * from Work.dbo.Nashville_Housing_Data;

-- Finding total number of records present:
-- select count(*) from Work.dbo.Nashville_Housing_Data;

/* Data cleaning in SQL */

----------------------------------------------Observing & Populate Property Address data where it is null---------------------------------------------------------------
select PropertyAddress from Work.dbo.Nashville_Housing_Data where PropertyAddress is null;

select * from (
select d.[UniqueID ],d.ParcelID,d.PropertyAddress , ROW_NUMBER() over(partition by parcelID order by parcelID) as rn from Work.dbo.Nashville_Housing_Data as d) as w;

-- As for same ParcelID PropertyAddress has been same so we can use those address to fill null Property Address
select d.ParcelID,d.PropertyAddress,d2.ParcelID,d2.PropertyAddress, coalesce(d.PropertyAddress,d2.PropertyAddress) from Work.dbo.Nashville_Housing_Data as d join Work.dbo.Nashville_Housing_Data as d2 
on d.ParcelID = d2.ParcelID where d.[UniqueID ]<>d2.[UniqueID ] and d.PropertyAddress is null;

--Updating the PropertyAddress by filling null values
update d set PropertyAddress = coalesce(d.PropertyAddress,d2.PropertyAddress) from Work.dbo.Nashville_Housing_Data as d join Work.dbo.Nashville_Housing_Data as d2 
on d.ParcelID = d2.ParcelID where d.[UniqueID ]<>d2.[UniqueID ] and d.PropertyAddress is null;

--Observing the data
select PropertyAddress from Work.dbo.Nashville_Housing_Data where PropertyAddress is null;


----------------------------------------------Splitting out PropertyAddress into Individual Columns (Address, City)-----------------------------------------------------
Select PropertyAddress , substring(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) - 1 ) as PropertyAddressNew ,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , len(PropertyAddress)) as PropertyCityN
from Work.dbo.Nashville_Housing_Data;

--Adding 2 new columns in Nashville Housing Data
alter table Work.dbo.Nashville_Housing_Data add PropertyAddressNew varchar(255), PropertyCityN varchar(255);

--Updating those newly added columns with the values of Property address and property city
update Work.dbo.Nashville_Housing_Data set PropertyAddressNew = substring(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress) - 1 );

update Work.dbo.Nashville_Housing_Data set PropertyCityN = substring(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1 , len(PropertyAddress));

select * from Work.dbo.Nashville_Housing_Data;


-----------------------------------------------Splitting out OwnerAddress into Individual Columns (Address, City, State)------------------------------------------------
select * from Work.dbo.Nashville_Housing_Data;

select OwnerAddress from Work.dbo.Nashville_Housing_Data;

--Using replace we replace the ',' with '.' then use parsename to fetch the address , city & state from Property Address
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as OwnerAddressN
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as OwnerCityN
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as OwnerStateN
From Work.dbo.Nashville_Housing_Data;

--Add 3 new columns in Nashville housing data 
alter table Work.dbo.Nashville_Housing_Data add OwnerAddressN varchar(255), OwnerCityN varchar(255), OwnerStateN varchar(255);

--Updating those newly added columns with the values of owner address, city & state
update Work.dbo.Nashville_Housing_Data set OwnerAddressN = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

update Work.dbo.Nashville_Housing_Data set OwnerCityN = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

update Work.dbo.Nashville_Housing_Data set OwnerStateN = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

select * from Work.dbo.Nashville_Housing_Data;


--------------------------------------------------------Standardize Date Format using cast function---------------------------------------------------------------------
select SaleDate, cast(SaleDate as date) as SaleDateConverted from Work.dbo.Nashville_Housing_Data;

--Adding new column 
alter table Work.dbo.Nashville_Housing_Data add SaleDateConverted Date;
--updating the newly added date column 
update Work.dbo.Nashville_Housing_Data
set SaleDateConverted = cast(SaleDate as date);

---------------------------------------------------Change Y and N to Yes and No in "Sold as Vacant" field---------------------------------------------------------------
select * from Work.dbo.Nashville_Housing_Data;

select SoldAsVacant, count(SoldAsVacant) as total from Work.dbo.Nashville_Housing_Data group by SoldAsVacant order by total desc ; 

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
end
from Work.dbo.Nashville_Housing_Data;

update Work.dbo.Nashville_Housing_Data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
end;


---------------------------------------------------------------------Delete Unused Columns------------------------------------------------------------------------------
alter table Work.dbo.Nashville_Housing_Data drop column PropertyAddress, SaleDate,OwnerAddress;
select * from Work.dbo.Nashville_Housing_Data;

----------------------------------------------------------------------Creating a View-----------------------------------------------------------------------------------
Create or alter view[Propertyinfo] as
select PropertyAddressNew, PropertyCityN,OwnerName,LandUse,YearBuilt,Bedrooms,year(SaleDateConverted) as Year,Format(SaleDateConverted,'MMMM') as Month,SalePrice,SoldAsVacant  from Work.dbo.Nashville_Housing_Data;


-----------------------------------------------------------Exploring data to get some useful insights-------------------------------------------------------------------
select * from Propertyinfo;

select Top 10 PropertyCityN , count(PropertyCityN) as total from [PropertyInfo] group by PropertyCityN order by total desc;

select Top 10 LandUse , count(LandUse) as total from [PropertyInfo] group by LandUse order by total desc;
 
select min(Bedrooms) as Minimum_Bedrooms, max(Bedrooms) as Maximum_Bedrooms, round(avg(Bedrooms),0) as Average_Bedrooms from Propertyinfo;

select Year,count(Year) as total from [PropertyInfo] group by year order by total desc;

select Month,count(Month) as total from [PropertyInfo] group by Month order by total desc;

select min(SalePrice) as Min_SalePrice,max(SalePrice) as Max_Saleprice,round(avg(SalePrice),2) as Average_Sale_Price from PropertyInfo ;

select SoldAsVacant,count(SoldAsVacant) as total from [PropertyInfo] group by SoldAsVacant order by total desc;

