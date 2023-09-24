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

def define_counties(run_code):
    if run_code == "ca":
        sf_counties = ["06001", "06013", "06041", "06047", "06055", "06069", "06075", "06077", "06081", "06085", "06087", "06095", "06097", "06099"]
        los_counties = ["06037", "06059", "06111", "06071", "06065"]
        san_diego = ["06073"]
        counties = sf_counties + los_counties + san_diego
    elif run_code == "tx":
        dallas_counties = ["48085", "48113", "48121", "48139", "48231", "48257", "48397", "48251", "48367", "48439", "48497"]
        houston_counties = ["48015", "48039", "48071", "48157", "48167", "48201", "48291", "48339", "48473"]
        counties = dallas_counties + houston_counties
    elif run_code == "ny":
        ny_ny_counties = ["36047", "36081", "36061", "36005", "36085", "36119", "36079", "36071", "36087", "36059", "36103"]
        counties = ny_ny_counties
    elif run_code == "nj":
        ny_nj_counties = ["34003", "34017", "34031", "34023", "34025", "34029", "34035", "34013", "34039", "34027", "34037", "34019"]
        counties = ny_nj_counties
    elif run_code == "ma":
        boston_counties = ["25021", "25023", "25025", "25009", "25017"]
        counties = boston_counties
    return counties

# read in the tract density CSV file
tract_density = pd.read_csv(tract_density_2019_csv)
tract_density["GEOID"] = tract_density["GEOID"].astype(str)
if run_code == 'ca':
    tract_density["GEOID"] = '0' + tract_density["GEOID"]

# read in the block shapefile for SF counties and filter by county
counties = define_counties(run_code)
block_sf = gpd.read_file(tract2019_shp)
block_sf['county_code'] = block_sf['STATEFP'].astype(str) + block_sf['COUNTYFP'].astype(str)
block_sf = block_sf[block_sf["county_code"].isin(counties)]

merged_sf = pd.merge(block_sf, tract_density, on="GEOID")

tract_sf = gpd.GeoDataFrame(merged_sf, geometry="geometry")
tract_sf.to_file(tract2019_v1_shp, driver="ESRI Shapefile")