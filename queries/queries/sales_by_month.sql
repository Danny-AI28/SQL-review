--Câu 1: Từ bảng FactResellerSales, tính toán tổng doanh thu theo từng tháng (đặt tên là SalesMonthAmount)
select extract(year from OrderDate) OrderYear
  , extract(month from OrderDate) as OrderMonth
  , sum(SalesAmount) as SalesMonthAmount
from `datawarehouse_jda.FactResellerSales`
group by 1,2
Order by 1,2,3
--Câu 2: Từ các bảng FactInternetSales, FactInternetSalesReason, DimSalesReason, DimProduct, DimProductCategory, hãy truy vấn ra 
--các thông tin sau của các đơn hàng được đặt trong quý 3 năm 2018 và quý 3 năm 2019, đồng thời SalesReasonReasonType là  “Marketing”: 
with raw as
(select extract(quarter from OrderDate) as Quarter
  , extract(year from OrderDate) as Year_
  , dp.EnglishProductName
  , dsr.SalesReasonReasonType
  , dpc.EnglishProductCategoryName
  , sum(SalesAmount)
from `datawarehouse_jda.FactInternetSales` fis
left join `datawarehouse_jda.DimProduct` dp
    on fis.ProductKey = dp.ProductKey
left join `datawarehouse_jda.FactInternetSalesReason` fisr
    on fis.SalesOrderNumber = fisr.SalesOrderNumber
LEFT JOIN jda-k1.datawarehouse_jda.FactInternetSalesReason fisr
    ON fis.SalesOrderNumber = fisr.SalesOrderNumber
    AND fis.SalesOrderLineNumber = fisr.SalesOrderLineNumber
left join `datawarehouse_jda.DimProductSubcategory` dps
    on dps.ProductSubcategoryKey = dp.ProductSubcategoryKey
left join `datawarehouse_jda.DimProductCategory` dpc
    on dps.ProductCategoryKey=dpc.ProductCategoryKey
group by 1,2,3,4,5
order by 1,2,6)
select *
from Raw
where Quarter = 3 and (Year_= 2019
or Year_ = 2018)
and SalesReasonReasonType = 'Marketing'
-- Câu 3: Từ bảng DimProduct, DimSalesTerritory và FactInternetSales, hãy tính toán % tỷ trọng doanh thu của từng sản phẩm (đặt tên là  PercentofTotaInCountry) 
-- trong Tổng doanh thu của mỗi quốc gia. Nếu tỷ trọng doanh thu của từng sản phẩm trong Tổng doanh  thu mỗi quốc gia lớn hơn 1%, đánh dấu tỷ trọng này là “Cao”, 
-- ngược lại đánh dấu là “Thấp” (đặt tên là Check). Kết quả trả về gồm có các thông tin sau: 
with raw as
(select dst.SalesTerritoryCountry
  , dp.EnglishProductName
  , sum(SalesAmount) as InternettotalSale
from `datawarehouse_jda.FactInternetSales` fis
left join `datawarehouse_jda.DimProduct` dp
on fis.ProductKey=dp.ProductKey
left join `datawarehouse_jda.DimSalesTerritory` dst
on dst.SalesTerritoryKey = fis.SalesTerritoryKey
group by 1,2
order by 3),
raw2 as
(select *
  , concat(round((raw.InternettotalSale/sum(raw.InternettotalSale)over(partition by SalesTerritoryCountry))*100,2),'%') as PercentofTotaInCountry
from raw)


select *
  , case when PercentofTotaInCountry > '1%' then 'Cao'
  else 'Thấp'
  end as Check
from raw2
-- Câu 4: Từ bảng FactInternetSales, và DimPromotion, hãy truy vấn ra tìm ra Promotion tạo ra tổng doanh thu tháng (đặt tên là SalesMonthAmount) 
-- cao nhất trong hệ thống theo mỗi tháng.
with raw as
(select extract(year from OrderDate) as OrderYear
  , format_date('%Y-%m', OrderDate) as OrderMonth
  , dpr.PromotionKey
  , dpr.EnglishPromotionName
  , sum(fis.SalesAmount) as SalesMonthAmount
from `datawarehouse_jda.FactInternetSales` fis
left join `datawarehouse_jda.DimPromotion` dpr
on dpr.PromotionKey = fis.PromotionKey
group by 1,2,3,4
order by 5),
raw2 as
(select *
  , rank()over(partition by OrderMonth order by SalesMonthAmount) as rank_
from raw)
select *
from raw2
where rank_ < 2

--Câu 5: Bảng Employee thể hiện id của tất cả các thành viên trong công ty, tên của từng thành viên, mức lương tương ứng và id của quản lý của họ.
-- Viết query tìm ra các nhân viên có lương cao hơn quản lý của họ.  
WITH Employee AS (  
SELECT 1 as Id, 'Joe' as Name, 7000 as Salary, 3 as ManagerId UNION ALL  
SELECT 2 as Id, 'Henry' as Name, 8000 as Salary, 4 as ManagerId UNION ALL  
SELECT 3 as Id, 'Sam' as Name, 6000 as Salary, null as ManagerId UNION ALL
SELECT 4 as Id, 'Max' as Name, 9000 as Salary, null as ManagerId UNION ALL  SELECT 5 as Id, 'Harry' as Name, 10000 as Salary, null as ManagerId UNION ALL  SELECT 6 as Id, 'Potter' as Name, 11000 as Salary, 5 as ManagerId  ) 
SELECT * FROM Employee


SELECT *
FROM Employee t1
left join Employee t2
on t1.Id=t2.ManagerId
where t1.Salary < t2.Salary


 



