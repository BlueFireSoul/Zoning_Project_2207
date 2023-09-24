import os
import getpass
import sys
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *

scag_dir = "C:/Users/dmh5950/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/SCAG/"
la_name = "2016_Land_Use_Information_for_Los_Angeles_County"
o_name = "2016_Land_Use_Information_for_Orange_County"
r_name = "2016_Land_Use_Information_for_Riverside_County"
sb_name = "2016_Land_Use_Information_for_San_Bernardino_County"
v_name = "2016_Land_Use_Information_for_Ventura_County"

import zipfile
import geopandas as gpd
import pandas as pd

def extract_zip(zip_file_path, dest_folder_path):
    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        zip_ref.extractall(dest_folder_path)
    print(f"All files from {zip_file_path} have been extracted to {dest_folder_path}")

temp_source_folder = os.path.join(temp_dir, 'scag_source')
os.makedirs(temp_source_folder, exist_ok=True)

# for x in [la_name,o_name,r_name,sb_name,v_name]:
#     zip_path = scag_dir + x + ".zip"
#     extract_zip(zip_path, temp_source_folder)

filter_folder = os.path.join(output_dir, 'scag_filter')
os.makedirs(filter_folder, exist_ok=True)

shapefiles = [os.path.join(temp_source_folder, la_name + ".geojson")] + [os.path.join(temp_source_folder, x + ".shp") for x in [o_name,r_name,sb_name,v_name]]
for x in [la_name,o_name,r_name,sb_name,v_name]:
    if x == la_name:
        file_path = os.path.join(temp_source_folder, x + ".geojson")
    else:
        file_path = os.path.join(temp_source_folder, x + ".shp")
    gdf = gpd.read_file(file_path)
    gdf = gdf[gdf['SCAG_GP_CO'].str[:2] == "11"]
    columns_to_keep = ['OBJECTID','geometry','DENSITY', 'LOW', 'HIGH', 'YEAR_ADOPT', 'CITY_GP_CO', 'DENSITY_SP', 'LOW_SP', 'HIGH_SP', 'YR_AD_SP', 'SP_INDEX', 'LU16','ZN12_CITY','CITY_ZN_CO','ACRES','COUNTY','CITY']
    gdf = gdf[columns_to_keep]
    gdf.to_file(os.path.join(filter_folder, x + ".shp"), driver='ESRI Shapefile')
    