import os
import numpy as np
import csv
import pandas as pd
from pandas import DataFrame as df
from pathlib import Path
import sys
import gzip
import json
from dfply import X, mutate, arrange, select, mask, distinct, drop, rename
import time
import subprocess
start_time = time.time()



def A_preparation(full_set):
    if os.getlogin( ) == '67311':
        parameters = ({
            "primary_directory" : "C:/Users/67311/OneDrive - The Pennsylvania State University/Los Angeles Zoning, 2022/"
        })
    elif os.getlogin( ) == 'dmh5950':
        parameters = ({
            "primary_directory" : "C:/Users/dmh5950/OneDrive - The Pennsylvania State University/Los Angeles Zoning, 2022/"
        })

    parameters.update({
        "full_set" : full_set,
        "property_data_folder" : parameters['primary_directory'] + "cleaning/output/",
        "SCAGzoing_data_folder" : parameters['primary_directory'] + "raw/SCAGZoning-main/data/",
        "temp_folder" : parameters['primary_directory'] + "temp/"
    })

    parameters.update({
        "property_data_csv" : parameters['property_data_folder'] + "hist_property_basic5_Los_adj10p.csv"
    })

    return parameters

def B_load_data(parameters):
    if parameters['full_set']== False:
        row_limit = 1000
    else: 
        row_limit = None

    property_data = pd.read_csv(parameters['property_data_csv'], skipinitialspace=True, nrows = row_limit, dtype=str)
    # variable_names = df(property_data.columns)
    # variable_names.to_csv("temp2.csv")  

    property_data >>= select(['clip', 'fips_code','cbsa','number_of_buildings', 
        'lat', 'lon', 
        'assessed_total_value', 'assessed_land_value','assessed_improvement_value',
        'adjustment_note',
        'living_square_feet_all_buildings','property_indicator_code',
        'effective_year_built','number_of_units'])


    return property_data

parameters = A_preparation(full_set = False)
property_data = B_load_data(parameters)

# with gzip.open( parameters['SCAGzoing_data_folder'] + "Adelanto_zoning.geojson.gz", "r") as f:
#     data = f.read()

# with open('association.json', 'w') as json_file:  
#      json.dump(data.decode('utf-8'), json_file)

import arcpy
arcpy.env.workspace = "C:/Users/67311/Desktop"
subprocess.Popen(r'explorer /select',parameters['SCAGzoing_data_folder'])
# print(parameters['SCAGzoing_data_folder'] + "Adelanto_zoning.geojson")
# arcpy.conversion.JSONToFeatures( os.path.join(parameters['SCAGzoing_data_folder'], "Adelanto_zoning.geojson")   , os.path.join("outgdb.gdb", "myfeatures"))

# property_data.to_csv("temp.csv")

# print("--- %s seconds ---" % (time.time() - start_time))