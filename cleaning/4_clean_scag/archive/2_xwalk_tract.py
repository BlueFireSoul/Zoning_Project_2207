import os
import getpass
import sys
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *

import arcpy
import csv
from arcpy import env

# Set workspace
env.workspace = temp_dir

# Define the shapefiles
la_name = "2016_Land_Use_Information_for_Los_Angeles_County"
o_name = "2016_Land_Use_Information_for_Orange_County"
r_name = "2016_Land_Use_Information_for_Riverside_County"
sb_name = "2016_Land_Use_Information_for_San_Bernardino_County"
v_name = "2016_Land_Use_Information_for_Ventura_County"
shapefile1 = tract2019_shp

outCSV = "intersection.csv"

def xwalk_tract(shapefile1,shapefile2,outCSV):

    output_sr = arcpy.SpatialReference(arcpy_spatial_reference)

    if arcpy.Exists("shapefile1_reprojected.shp"):
        arcpy.Delete_management("shapefile1_reprojected.shp")
    if arcpy.Exists("shapefile2_reprojected.shp"):
        arcpy.Delete_management("shapefile2_reprojected.shp")
    shapefile1 = arcpy.management.Project(shapefile1, "shapefile1_reprojected.shp", output_sr)
    shapefile2 = arcpy.management.Project(shapefile2, "shapefile2_reprojected.shp", output_sr)

    # Intersect the shapefiles
    intersected_shapefile_path = "in_memory\\intersected_shapefile"
    if arcpy.Exists(intersected_shapefile_path):
        arcpy.management.Delete(intersected_shapefile_path)
    intersected_shapefile = arcpy.analysis.Intersect([shapefile1, shapefile2], intersected_shapefile_path)

    # Add 'intersect_area' field to the output shapefile and calculate area
    arcpy.AddField_management(intersected_shapefile, 'intersect_area', 'DOUBLE')
    arcpy.CalculateField_management(intersected_shapefile, 'intersect_area', '!shape.area!', 'PYTHON3')

    # Export attributes to CSV
    fields = ['STATEFP','COUNTYFP','TRACTCE','SCAG_GP_CO','HIGH','intersect_area']
    with open(outCSV, 'w') as f:
        f.write(','.join(fields) + "\n")  # csv headers
        with arcpy.da.SearchCursor(intersected_shapefile, fields) as cursor:
            for row in cursor:
                f.write(','.join([str(r) for r in row]) + "\n")

for x in [v_name,la_name,o_name,r_name,sb_name]:
    shapefile2 = temp_dir + 'scag_filter/' + x + ".shp"
    os.makedirs(temp_dir + 'scag_xwalk/', exist_ok=True)
    outCSV = temp_dir + 'scag_xwalk/' + x + ".csv"
    xwalk_tract(shapefile1,shapefile2,outCSV)