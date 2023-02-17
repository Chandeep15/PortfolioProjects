Select * 
from NashvileHousing
order by uniqueID asc

-- Standardize the date format
Select SaleDate, CONVERT(Date,SaleDate)
from NashvileHousing



ALTER TABLE NashvileHousing
ADD SALEDATECONVERTED DATE

UPDATE NashvileHousing
SET SALEDATECONVERTED = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------

-- Filling null Property Address
Select *
from NashvileHousing
where PropertyAddress is null


Select a.ParcelID , a.propertyaddress , b.ParcelID , b.propertyaddress , isnull(a.propertyaddress, b.propertyaddress)
from NashvileHousing a
 join NashvileHousing b
on a.ParcelID = b.ParcelID
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

Update a
Set Propertyaddress =  isnull(a.propertyaddress, b.propertyaddress)
from NashvileHousing a
 join NashvileHousing b
on a.ParcelID = b.ParcelID
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

------------------------------------------------------------------------------------------------------------
-- Breaking out Property Address into City , State 
-- , is the delimiter
Select PropertyAddress
from NashvileHousing
--where PropertyAddress is null
order by ParcelID

SELECT 
SUBSTRING(PropertyAddress , 1, CHARINDEX(',' , PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) as Address
from NashvileHousing


ALTER TABLE NashvileHousing
ADD NewPropertyAddress nvarchar(255)

UPDATE NashvileHousing
SET NewPropertyAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',' , PropertyAddress)-1)

ALTER TABLE NashvileHousing
ADD NewCity nvarchar(255)

UPDATE NashvileHousing
SET NewCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))
Select *
from NashvileHousing
order by ParcelID

-----------------------------------------------------------------------------
-- Changing owner address

Select *
from NashvileHousing
order by ParcelID

Select 
PARSENAME(REPLACE(owneraddress , ',' , '.') ,3),
PARSENAME(REPLACE(owneraddress , ',' , '.') ,2),
PARSENAME(REPLACE(owneraddress , ',' , '.') ,1)
from NashvileHousing

Alter table  NashvileHousing
Add NewOwnerAddress nvarchar(250);
UPDATE NashvileHousing
Set NewOwnerAddress = PARSENAME(REPLACE(owneraddress , ',' , '.') ,3)

Alter table  NashvileHousing
Add NewOwnerCity nvarchar(250);
UPDATE NashvileHousing
Set NewOwnerCity = PARSENAME(REPLACE(owneraddress , ',' , '.') ,2)

Alter table  NashvileHousing
Add NewOwnerState nvarchar(250);
UPDATE NashvileHousing
Set NewOwnerState = PARSENAME(REPLACE(owneraddress , ',' , '.') ,1)

Select *
from NashvileHousing
order by ParcelID

-------------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant field
Select distinct(Soldasvacant) , Count(Soldasvacant)
from NashvileHousing
group by Soldasvacant
order by 2

Select Soldasvacant ,
CASE WHEN Soldasvacant = 'Y' THEN 'Yes' 
 WHEN Soldasvacant = 'N' THEN 'No' 
 Else Soldasvacant 
 END
from NashvileHousing

UPDATE NashvileHousing
SET SoldAsVacant = CASE WHEN Soldasvacant = 'Y' THEN 'Yes' 
 WHEN Soldasvacant = 'N' THEN 'No' 
 Else Soldasvacant 
 END

-----------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference

				 Order by 
				 UniqueID
				 ) row_num
from NashvileHousing


--order by ParcelID
)

Select * from RowNumCTE
where row_num > 1
--order by propertyaddress

-------------------------------------------------------------------------------------------------

-- Delete Unused Columns
Select * from NashvileHousing

ALTER TABLE NashvileHousing
drop column  SaleDate