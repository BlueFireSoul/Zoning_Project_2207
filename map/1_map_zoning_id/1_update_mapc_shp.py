import os
import getpass
import sys
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *

import pandas as pd
import geopandas as gpd

zone_info = pd.read_csv(output_dir + 'zoning_atlas_update.csv')

mapc_shp = gpd.read_file(mapc_shp)
mapc_shp = mapc_shp.to_crs(epsg=4326)
merged_gdf = mapc_shp.merge(zone_info, on=['zo_code'], how='left')
merged_gdf['far_adj'] = merged_gdf['far_adj'].fillna(999999)
merged_gdf['far_adj'] = merged_gdf['far_adj'].replace(0,999999)
merged_gdf['dupac_adj'] = merged_gdf['dupac_adj'].fillna(999999)
merged_gdf['dupac_adj'] = merged_gdf['dupac_adj'].replace(0,999999)

merged_gdf.crs = 'EPSG:4326'
merged_gdf.to_file(output_dir + 'mapc_update/mapc_update.shp', driver='ESRI Shapefile')