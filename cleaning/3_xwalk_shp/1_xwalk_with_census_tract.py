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
import subprocess
from shapely.geometry import Polygon

'''
    This code directly assigned mapping to property data without prior adjustments
'''
def define_counties(run_code):
    if run_code in ["ca","cas"]:
        sf_counties = ["06001", "06013", "06041", "06047", "06055", "06069", "06075", "06077", "06081", "06085", "06087", "06095", "06097", "06099"]
        los_counties = ["06037", "06059", "06111", "06071", "06065"]
        san_diego = ["06073"]
        counties = los_counties
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
        boston_counties = ["25021", "25023", "25025", "25027", "25009", "25017"]
        counties = boston_counties
    return counties

counties = define_counties(run_code)

if run_code == "ma":
    tract_sf20 = gpd.read_file(tract2020_shp)
    tract_sf20['county_code'] = tract_sf20['STATEFP'].astype(str) + tract_sf20['COUNTYFP'].astype(str)
    tract_sf20 = tract_sf20[tract_sf20["county_code"].isin(counties)]
    tract_sf20 = tract_sf20.to_crs(epsg=4326)
    tract_sf20.rename(columns={'GEOID': 'tractID20'}, inplace=True)
    columns_to_keep = ['geometry', 'tractID20']
    tract_sf20 = tract_sf20[columns_to_keep]
    tract_sidx = tract_sf20.sindex

    tract_sf08 = gpd.read_file(tract2008_shp)
    tract_sf08['county_code'] = tract_sf08['STATEFP00'].astype(str) + tract_sf08['COUNTYFP00'].astype(str)
    tract_sf08 = tract_sf08[tract_sf08["county_code"].isin(counties)]
    tract_sf08 = tract_sf08.to_crs(epsg=4326)
    tract_sf08.rename(columns={'CTIDFP00': 'tractID08'}, inplace=True)
    columns_to_keep = ['geometry', 'tractID08']
    tract_sf08 = tract_sf08[columns_to_keep]
    tract_sidx = tract_sf08.sindex

    zoning_shp = gpd.read_file(mapc_shp)
    zoning_shp['zoning_shp_id'] = range(len(zoning_shp))
    zoning_shp = zoning_shp.to_crs(epsg=4326)
    zoning_shp_sidx = zoning_shp.sindex

    # parcel_shp = gpd.read_file(data_dir + 'ma_local/ma_parcel/ma_parcel.shp')
    # columns_to_keep = ['geometry', 'bldg_area', 'units_est', 'lot_areaft']
    # parcel_shp = parcel_shp[columns_to_keep]
    # parcel_shp = parcel_shp.to_crs(epsg=4326)
    # parcel_shp_sidx = parcel_shp.sindex

tract_sf19 = gpd.read_file(tract2019_shp)
tract_sf19['county_code'] = tract_sf19['STATEFP'].astype(str) + tract_sf19['COUNTYFP'].astype(str)
tract_sf19 = tract_sf19[tract_sf19["county_code"].isin(counties)]
tract_sf19 = tract_sf19.to_crs(epsg=4326)
tract_sf19.rename(columns={'GEOID': 'tractID19'}, inplace=True)
columns_to_keep = ['geometry', 'tractID19']
tract_sf19 = tract_sf19[columns_to_keep]
tract_sidx = tract_sf19.sindex

property_df = pd.read_csv(property_coord_dict_csv)
columns_to_keep = ['col1','col49','col48']
property_df = property_df[columns_to_keep]
property_gdf = gpd.GeoDataFrame(property_df, geometry=gpd.points_from_xy(property_df["col49"], property_df["col48"]))
property_gdf = property_gdf.set_crs(epsg=4326)
property_sidx = property_gdf.sindex

geodf19 = gpd.sjoin(tract_sf19, property_gdf, predicate='intersects', how = "inner")
columns_to_keep = ['col1','col48','col49','tractID19']
geodf19 = geodf19[columns_to_keep]

if run_code == 'ma':
    geodf20 = gpd.sjoin(tract_sf20, property_gdf, predicate='intersects', how = "inner")
    columns_to_keep = ['col1','col48','col49','tractID20']
    geodf20 = geodf20[columns_to_keep]

    geodf08 = gpd.sjoin(tract_sf08, property_gdf, predicate='intersects', how = "inner")
    columns_to_keep = ['col1','col48','col49','tractID08']
    geodf08 = geodf08[columns_to_keep]

    geodf_zone = gpd.sjoin(zoning_shp, property_gdf, predicate='intersects', how = "inner")
    columns_to_keep = ['col1','zo_code']
    geodf_zone = geodf_zone[columns_to_keep]

    # geodf_parcel = gpd.sjoin(parcel_shp, property_gdf, predicate='intersects', how = "inner")
    # columns_to_keep = ['col1','bldg_area', 'units_est', 'lot_areaft']
    # geodf_parcel = geodf_parcel[columns_to_keep]

    geodf = (geodf20.merge(geodf19, on='col1', how='outer')
             .merge(geodf08, on='col1', how='outer')
             .merge(geodf_zone, on='col1', how='inner')
            #  .merge(geodf_parcel, on='col1', how='inner')
             )
else:
    geodf = geodf19


la_name = "2016_Land_Use_Information_for_Los_Angeles_County"
o_name = "2016_Land_Use_Information_for_Orange_County"
r_name = "2016_Land_Use_Information_for_Riverside_County"
sb_name = "2016_Land_Use_Information_for_San_Bernardino_County"
v_name = "2016_Land_Use_Information_for_Ventura_County"

if run_code in ['ca','cas']:
    geodf_old = gpd.GeoDataFrame(geodf, geometry=gpd.points_from_xy(geodf["col49"], geodf["col48"]))
    geodf_old = geodf_old.set_crs(epsg=4326)
    geodf_old_sidx = geodf_old.sindex
    df_list = []

    filter_folder = os.path.join(output_dir, 'scag_filter')
    for x in [la_name,o_name,r_name,sb_name,v_name]:
        zoning_shp = gpd.read_file(os.path.join(filter_folder, x + ".shp"))
        zoning_shp = zoning_shp.to_crs(epsg=4326)
        zoning_shp_sidx = zoning_shp.sindex

        geodf_new = gpd.sjoin(geodf_old, zoning_shp, predicate='intersects', how = "inner")
        columns_to_keep = ['col1','col48','col49','tractID19',
                        'DENSITY', 'LOW', 'HIGH', 'YEAR_ADOPT', 'CITY_GP_CO', 'DENSITY_SP', 'LOW_SP', 'HIGH_SP', 'YR_AD_SP', 'SP_INDEX', 'LU16','ZN12_CITY','CITY_ZN_CO','ACRES','COUNTY','CITY']
        geodf_new = geodf_new[columns_to_keep]
        df_list.append(geodf_new)
    geodf = pd.concat(df_list, ignore_index=True)

geodf.to_csv(property_cdict_xwalk_csv, index=False)
