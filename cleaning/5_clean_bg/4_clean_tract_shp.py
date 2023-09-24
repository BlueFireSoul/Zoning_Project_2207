import os
import getpass
import sys
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *
import geopandas as gpd
import pandas as pd

counties = ["25021", "25023", "25025", "25027", "25009", "25017"]
tract_sf19 = gpd.read_file(tract2019_shp)
tract_sf19['county_code'] = tract_sf19['STATEFP'].astype(str) + tract_sf19['COUNTYFP'].astype(str)
tract_sf19 = tract_sf19[tract_sf19["county_code"].isin(counties)]
tract_sf19 = tract_sf19.to_crs(epsg=4326)
tract_sf19.rename(columns={'GEOID': 'tractID19'}, inplace=True)
columns_to_keep = ['geometry', 'tractID19']
tract_sf19 = tract_sf19[columns_to_keep]
tract_sidx = tract_sf19.sindex

aei_land_df = pd.read_csv(output_dir + "aei_land.csv")
columns_to_convert = ['tractID19']
aei_land_df[columns_to_convert] = aei_land_df[columns_to_convert].astype(str) # Need to adjust this line if the FIPS state code is single digit.
merged_gdf = tract_sf19.merge(aei_land_df, on=['tractID19'], how='left')

merged_gdf.crs = 'EPSG:4326'
merged_gdf.to_file(output_dir + 'tract2019_v2/tract2019_v2.shp', driver='ESRI Shapefile')
