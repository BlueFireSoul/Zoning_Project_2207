import getpass
import os
import sys

current_user = getpass.getuser()

run_code = ""
if not sys.argv:
    run_code = "ma"
else:
    try:
        run_code = sys.argv[1]
    except IndexError:
        run_code = "ma"
if len(run_code) != 2:
    run_code = "ma"

def append_path(file_path):
    directory, file_name = os.path.split(file_path)
    base_name, extension = os.path.splitext(file_name)
    new_base_name = base_name + "_" + run_code
    new_file_path = os.path.join(directory, new_base_name + extension)
    return new_file_path

def append_ori_path(file_path, run_code = run_code):
    directory, file_name = os.path.split(file_path)
    base_name, extension = os.path.splitext(file_name)
    if run_code == 'cas':
        run_code = 'ca'
    new_base_name = base_name + "_" + run_code
    new_file_path = os.path.join(directory, new_base_name + extension)
    return new_file_path

arcpy_spatial_reference = "NAD 1983 StatePlane California V FIPS 0405 (US Feet)"

# routine folder
output_dir = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/"
output2_dir = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output2/"
data_dir = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/"
if current_user == "dmh5950":
    temp_dir = "C:/Users/dmh5950/Desktop/temp/"
else:
    temp_dir = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/temp/"
os.makedirs(temp_dir, exist_ok=True)
graph_output_dir = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/graph_output/"
# raw data
property_current = append_ori_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/CoreLogic/current/property_basic2/property_basic2.txt")

tract2019_shp = append_ori_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/tl_2019_tract/tl_2019_tract.shp")
tract2020_shp = append_ori_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/tl_2020_tract/tl_2020_tract.shp")
tract2008_shp = append_ori_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/tl_2008_tract/tl_2008_tract.shp")
mapc_shp = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/MAPC/Base Districts/zoning_atlas.shp"
bg_2019_shp = append_ori_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/tl_2019_bg/tl_2019_bg.shp")

tract_pop_2019_csv = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/nhgis/tract_pop_2019.csv"
block_0010_xwalk_csv = append_ori_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/nhgis/blk2000_blk2010.csv")
block_pop_2000_csv = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/nhgis/block_pop_2000.csv"
bg_2019_csv = append_ori_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/nhgis/bg_2019.csv")

sf_zoning_folder = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/BayAreaZoning-master/data/shapefile"
ls_zoning_folder = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/SCAGZoning-main/data"
# standard processed data
property_current_rds = append_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_current.RDS")
property_coord_dict_csv = append_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_coord_dict.csv")
property_c_fadj_rds = append_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_c_fadj_rds.RDS")
property_c_block_rds = append_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_c_block.RDS")
property_c_xwalk_csv =  append_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_c_xwalk.csv")
property_cdict_xwalk_csv =  append_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_cdict_xwalk.csv")

tract_density_2019_csv = append_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/tract_density_2019.csv")

tract2019_v1_shp = append_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/tract2019_v1/tract2019_v1.shp")
tract2019_combine_v1_shp = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/combine/tract2019_v1/tract2019_combine_v1.shp"

bg2019_v1_shp = append_path(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/bg2019_v1/bg2019_v1.shp")

sf_zoning_shp = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/sf_zoning/san_francisco_zoning.shp"
ls_zoning_shp = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/ls_zoning/los_angeles_zoning.shp"

tract_ma_2019_csv = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/tract_ma_2019.csv"
tract_ma_matrix_json = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/tract_ma_matrix.json"
tract_ma_matrix_csv = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/tract_ma_matrix.csv"

tract2019_bo_shp = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/bo_shp/tract2019_bo.shp"