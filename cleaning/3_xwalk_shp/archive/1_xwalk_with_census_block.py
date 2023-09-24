import os
import getpass
import sys
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *
import geopandas as gpd
from rpy2.robjects.packages import importr
from rpy2.robjects import r, pandas2ri
import pandas as pd
import subprocess

sf_counties = ["001", "013", "041", "047", "055", "069", "075", "077", "081", "085", "087", "095", "097", "099"]
block_sf = gpd.read_file(block2010_shp)
block_sf = block_sf[block_sf["COUNTYFP10"].isin(sf_counties)]
block_sidx = block_sf.sindex

rdata = r['readRDS'](property_c_fadj_rds)
property_df = pandas2ri.rpy2py_dataframe(rdata)
property_gdf = gpd.GeoDataFrame(property_df, geometry=gpd.points_from_xy(property_df["col49"], property_df["col48"]))
property_gdf = property_gdf.set_crs(epsg=4326).to_crs(block_sf.crs)
property_sidx = property_gdf.sindex

geodf = gpd.sjoin(block_sf, property_gdf, predicate='intersects', how = "inner")
geodf = geodf.drop(['STATEFP10', 'COUNTYFP10', 'TRACTCE10', 'BLOCKCE', 'PARTFLG', 'geometry', 'index_right'], axis=1)

geodf.to_csv(os.path.join(temp_dir, "property_block_xwalk.csv"), index=False)