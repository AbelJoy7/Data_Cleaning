SELECT * 
FROM abel.dbo.nationalnasvillehousing

--Standardize date format

SELECT SaleDate,CONVERT(DATE,SaleDate) AS formatted_salesdate
FROM abel.dbo.nationalnasvillehousing

ALTER TABLE nationalnasvillehousing
ADD salesdateconverted DATE

UPDATE nationalnasvillehousing
SET salesdateconverted=CONVERT(DATE,saledate)

SELECT salesdateconverted
FROM nationalnasvillehousing

--populate property address data

SELECT PropertyAddress
FROM nationalnasvillehousing
WHERE PropertyAdDress IS NULL

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
FROM nationalnasvillehousing AS a
join nationalnasvillehousing AS b
ON a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nationalnasvillehousing AS a
join nationalnasvillehousing AS b
ON a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL

SELECT PropertyAddress
FROM nationalnasvillehousing

--breaking out address into individual columns(address,city,states)

SELECT PropertyAddress
FROM abel.dbo.nationalnasvillehousing

SELECT
  SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS city
FROM nationalnasvillehousing

ALTER TABLE nationalnasvillehousing
ADD propertysplitaddress NVARCHAR(255)


ALTER TABLE nationalnasvillehousing
ADD prpertysplitcity NVARCHAR(255)

UPDATE nationalnasvillehousing
SET propertysplitaddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE nationalnasvillehousing
SET prpertysplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM nationalnasvillehousing


SELECT OwnerAddress
FROM nationalnasvillehousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
FROM nationalnasvillehousing


ALTER TABLE nationalnasvillehousing
ADD ownersplitstate NVARCHAR(100)

ALTER TABLE nationalnasvillehousing
ADD ownersplitcity NVARCHAR(100)

ALTER TABLE nationalnasvillehousing
ADD ownersplitaddress NVARCHAR(100)

UPDATE nationalnasvillehousing
SET ownersplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

UPDATE nationalnasvillehousing
SET ownersplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE nationalnasvillehousing
SET ownersplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

SELECT *
FROM nationalnasvillehousing

--change solidvacant coumn, y and n to yes and no

SELECT SoldAsVacant,COUNT(SoldAsVacant)
FROM nationalnasvillehousing
GROUP BY SoldAsVacant

UPDATE nationalnasvillehousing
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
   WHEN SoldAsVacant = 'N' THEN 'NO'
   ELSE SoldAsVacant END

SELECT SoldAsVacant 
FROM nationalnasvillehousing

--REMOVE DUPLICATE VALUES

WITH rownumadded AS
(
SELECT *,
  ROW_NUMBER() OVER (
     PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
	   ORDER BY UniqueID) AS rownum
FROM nationalnasvillehousing)

SELECT * 
FROM rownumadded
WHERE rownum>1

DELETE  
FROM rownumadded
WHERE rownum >1

--DELETE UNUSED COLUMNS

SELECT * 
FROM nationalnasvillehousing

ALTER TABLE nationalnasvillehousing
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict