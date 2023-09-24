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

boston_counties = ["25021", "25023", "25025", "25027", "25009", "25017"]

bg_2019_df = gpd.read_file(bg_2019_shp)
bg_2019_df['county_code'] = bg_2019_df['STATEFP'].astype(str) + bg_2019_df['COUNTYFP'].astype(str)
bg_2019_df = bg_2019_df[bg_2019_df["county_code"].isin(boston_counties)]
bg_2019_df = bg_2019_df.to_crs(epsg=4326)
columns_to_keep = ['STATEFP', 'COUNTYFP', 'TRACTCE','BLKGRPCE','geometry']
bg_2019_df = bg_2019_df[columns_to_keep]
bg_2019_sidx = bg_2019_df.sindex

property_df = pd.read_csv(property_coord_dict_csv)
property_gdf = gpd.GeoDataFrame(property_df, geometry=gpd.points_from_xy(property_df["col49"], property_df["col48"]))
property_gdf = property_gdf.set_crs(epsg=4326)
property_sidx = property_gdf.sindex

geodf = gpd.sjoin(bg_2019_df, property_gdf, predicate='intersects', how = "inner")
columns_to_keep = ['col1','col48','col49','STATEFP', 'COUNTYFP', 'TRACTCE','BLKGRPCE']
geodf = geodf[columns_to_keep]

geodf.to_csv(output_dir + 'property_xwalk_bg.csv', index=False)