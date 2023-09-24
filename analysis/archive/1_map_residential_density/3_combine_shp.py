import os
import getpass
import sys
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *

import glob
import geopandas as gpd
import pandas as pd

def combine_shapefiles(folder_path, output_file):
    target_crs="EPSG:4326"
    # Get a list of all the shapefiles in the folder
    shapefiles = glob.glob(os.path.join(folder_path, "*.shp"))

    # Read each shapefile into a separate GeoDataFrame
    gdfs = []
    for shapefile in shapefiles:
        gdf = gpd.read_file(shapefile)
        gdf = gdf.to_crs(target_crs)
        gdfs.append(gdf)

    # Concatenate the GeoDataFrames into a single GeoDataFrame
    combined_gdf = pd.concat(gdfs, ignore_index=True)

    # Save the combined shapefile to a new file
    combined_gdf.to_file(output_file)

combine_shapefiles(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/tract2019_v1", tract2019_combine_v1_shp)