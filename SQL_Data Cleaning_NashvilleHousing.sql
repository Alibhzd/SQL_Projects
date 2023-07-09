
/*

Data Cleaning

*/

Select *
From NashvilleHousing 

-- Change date format
---remove time from the cells

Alter table NashvilleHousing
Add SaleDateModified Date;

Update NashvilleHousing 
Set SaleDateModified = Convert(Date, Saledate)

Select SaleDateModified, Convert(Date, Saledate) 
From NashvilleHousing



-- Populate Property Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID,  b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
-- isnull: if a.property address is null, we populate it with b.propertyaddress
From NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- breaking Property Address columns into different columns

Select propertyaddress
from NashvilleHousing

SELECT 
-- the below functions replace the comma with a dot and then parse the string into two separated strings by dot. it parse from the right of the string
  PARSENAME(REPLACE(PropertyAddress, ', ', '.'), 2) as Address1,
  PARSENAME(REPLACE(PropertyAddress, ', ', '.'), 1) as Address2
FROM NashvilleHousing

-- the below code is another way of extracting the string before and after comma
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address2
From NashvilleHousing


-- now we update the table with the new and above-created columns
Alter table NashvilleHousing
Add PropertyAddress_Split Nvarchar(255);

Update NashvilleHousing
Set PropertyAddress_Split = PARSENAME(REPLACE(PropertyAddress, ', ', '.'), 2)

Alter table NashvilleHousing
Add PropertyCity Nvarchar(255);

Update NashvilleHousing
Set PropertyCity = PARSENAME(REPLACE(PropertyAddress, ', ', '.'), 1)

Select *
From NashvilleHousing


-- Breaking 'OwnerAddress' into different columns
Select OwnerAddress
From NashvilleHousing


Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing


Alter table NashvilleHousing
Add OwnerAddressOnly Nvarchar(255)

Update NashvilleHousing
Set OwnerAddressOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerCity Nvarchar(255)

Update NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerState Nvarchar(255)

Update NashvilleHousing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From NashvilleHousing



-- Change 'Sold as vacant' column entries from 'Y' and 'N' to Yes and No.

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = 
	 Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing


Select *
From NashvilleHousing



-- Remove duplicates

Select *
From NashvilleHousing


With RowNumCTE as (
Select *, 
	ROW_NUMBER() over (
	partition by ParcelID,  ---- we partition by columns that should have unique entries/rows.
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				 ) as row_num

from NashvilleHousing
)
Delete -- this deletes the duplicate rows.
from RowNumCTE
where row_num > 1




-- Delete unused columns

Select *
from NashvilleHousing

Alter table NashvilleHousing
Drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict







