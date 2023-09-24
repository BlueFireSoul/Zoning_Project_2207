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
import numpy as np

gdf = gpd.read_file(output_dir + 'bo_shp/tract2019_bo.shp')
gdf = gdf.to_crs(epsg=4326)
gdf['tractID19'] = gdf['TRACTCE'] + gdf['COUNTYFP'] * 1e6 + gdf['STATEFP'] * 1e9
gdf[['tractID19']] = gdf[['tractID19']].astype(np.int64)

zone_tract_stat_df = pd.read_csv(output_dir + 'tract_zoning_summary.csv')
merged_gdf = gdf.merge(zone_tract_stat_df, on=['tractID19'], how='left')
merged_gdf['year_diff10'] = merged_gdf['year_diff10'].replace(0, -999)
merged_gdf['year_diff20'] = merged_gdf['year_diff20'].replace(0, -999)

merged_gdf.crs = 'EPSG:4326'
merged_gdf.to_file(output_dir + 'bo_shp/tract2019_bo_zstat.shp', driver='ESRI Shapefile')

print(merged_gdf)