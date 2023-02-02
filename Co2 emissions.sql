select Country_code as Countries, country_name as name, Series_name, series_code , _1990 as CO2_emissions
from Work.dbo.Climate_change
where Series_code = 'EN.ATM.CO2E.PP.GD.KD' and Country_code in ('CHN', 'USA', 'VNM')

