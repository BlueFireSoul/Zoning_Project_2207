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

gdf = gpd.read_file(bg_2019_shp)
column_rename_dict = {
    'STATEA': 'STATEFP',
    'COUNTYA': 'COUNTYFP',
    'TRACTA': 'TRACTCE',
    'BLKGRPA' : 'BLKGRPCE'
}
bg_2019_df = pd.read_csv(bg_2019_csv).rename(columns=column_rename_dict)
bg_2019_df = bg_2019_df[['STATEFP', 'COUNTYFP', 'TRACTCE','BLKGRPCE', 'ALW1E001','ALX5E001','ALW2E001','ALUBE001']]
columns_to_convert = ['STATEFP', 'COUNTYFP', 'TRACTCE', 'BLKGRPCE']
gdf[columns_to_convert] = gdf[columns_to_convert].astype(int)
merged_gdf = gdf.merge(bg_2019_df, on=['STATEFP', 'COUNTYFP', 'TRACTCE','BLKGRPCE'], how='left')

bg_2019_df = pd.read_csv(output_dir + "bg_total_land.csv")
merged_gdf = merged_gdf.merge(bg_2019_df, on=['STATEFP', 'COUNTYFP', 'TRACTCE','BLKGRPCE'], how='left')

merged_gdf['rsq_income'] = merged_gdf['ALW2E001'] / merged_gdf['total_land']
merged_gdf['sq_income'] = merged_gdf['ALW2E001'] / merged_gdf['ALAND']
merged_gdf['rsq_pop'] = merged_gdf['ALUBE001'] / merged_gdf['total_land']

merged_gdf.crs = 'EPSG:4326'
merged_gdf.to_file(bg2019_v1_shp, driver='ESRI Shapefile')

print(merged_gdf)
print(gdf.shape[0])