import os
import getpass
import sys
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *

import geopandas as gpd

mapc_sf = gpd.read_file(mapc_shp)
mapc_sf = mapc_sf.to_crs(epsg=4326)

gdf = gpd.read_file(tract2019_shp)
centroid_list = gdf[['STATEFP','COUNTYFP','TRACTCE','INTPTLAT','INTPTLON']]
centroid_gdf = gpd.GeoDataFrame(centroid_list, geometry=gpd.points_from_xy(centroid_list["INTPTLON"], centroid_list["INTPTLAT"]))
centroid_gdf = centroid_gdf.set_crs(epsg=4326)

geodf = gpd.sjoin(centroid_gdf, mapc_sf, predicate='intersects', how = "inner")

geodf_list = geodf[['STATEFP','COUNTYFP','TRACTCE','INTPTLAT','INTPTLON']]
N = len(geodf_list)
geodf_list['tract_index'] = range(N)

merged_gdf = gdf.merge(geodf_list, on=['STATEFP','COUNTYFP','TRACTCE','INTPTLAT','INTPTLON'], how='inner')
merged_gdf.to_file(tract2019_bo_shp)

geodf_list.to_csv(tract_ma_2019_csv,index = False)