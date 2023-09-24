import os
import getpass
import sys
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *
import csv
import json
import pandas as pd

def read_csv_as_dict(file_path):
    data_dict = {}
    with open(file_path, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            key = row.pop('tract_index')  # Remove 'id' column from the row and use it as the key
            data_dict[key] = row  # Store the rest of the row as the value in the dictionary
    return data_dict

tract_dict = read_csv_as_dict(tract_ma_2019_csv)
with open(tract_ma_matrix_json, 'r') as json_file:
    tract_matrix_dict = json.load(json_file)

tract_matrix_df = {'origin' : [],'destination' : [], 'driving' : [],'walking' : [],'transit' : []}
tract_matrix_df = pd.DataFrame(tract_matrix_df)

for o in range(len(tract_dict)):
    for d in range(o,len(tract_dict)):
        o = str(o)
        d = str(d)
        data = {'origin' : [o],'destination' : [d]}
        for mode in ['driving','walking','transit']:
            if o+","+d in tract_matrix_dict[mode]:
                data[mode] = [tract_matrix_dict[mode][o+","+d]]
            else:
                data[mode] = [tract_matrix_dict[mode][d+","+o]]
        data = pd.DataFrame(data)
        tract_matrix_df = pd.concat([tract_matrix_df,data], ignore_index=True)

tract_matrix_df.loc[(tract_matrix_df['transit'] == 0) | (tract_matrix_df['transit'] == -1), 'transit'] = tract_matrix_df['walking']
tract_matrix_df.loc[tract_matrix_df['transit'] < tract_matrix_df['driving'], 'transit'] = tract_matrix_df['driving']
tract_matrix_df.to_csv(tract_ma_matrix_csv, index=False)