-- Standardize Date Format


ALTER TABLE NashvilleHousing
Add SaleDateConverted7 Date;

Update NashvilleHousing
SET SaleDateConverted = CAST(saleDate as Date)

select SaleDateConverted
from PortfolioProyect..NashvilleHousing

-- Populate Property Address data

Select *
From PortfolioProyect.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProyect.dbo.NashvilleHousing a
JOIN PortfolioProyect.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProyect.dbo.NashvilleHousing a
JOIN PortfolioProyect.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProyect..NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) AS Address,
RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress) ) AS City
from PortfolioProyect..NashvilleHousing


ALTER TABLE PortfolioProyect..NashvilleHousing
Add PropertyAddressOnly nvarchar(255);

Update PortfolioProyect..NashvilleHousing
SET PropertyAddressOnly = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE PortfolioProyect..NashvilleHousing
Add City Nvarchar(255);

Update PortfolioProyect..NashvilleHousing
SET City = RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress) -1)

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProyect..NashvilleHousing



ALTER TABLE PortfolioProyect..NashvilleHousing

Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProyect..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProyect..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProyect..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProyect..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProyect..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT*
FROM PortfolioProyect..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProyect..NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yez'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProyect..NashvilleHousing

Update PortfolioProyect..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yezz'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



	   -- Remove Duplicates


	WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProyect..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1


SELECT * 
FROM PortfolioProyect..NashvilleHousing
WHERE OwnerName like '%Wang%' 
ORDER BY SaleDate

-- Delete Unused Columns



Select *
From PortfolioProyect..NashvilleHousing


ALTER TABLE PortfolioProyect..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

