import getpass
current_user = getpass.getuser()
import subprocess
import os
import winsound

if current_user == "dmh5950":
    rscript_path = "C:/Program Files/R/R-4.3.1/bin/Rscript.exe"
elif current_user == "67311":
    rscript_path = "C:/Program Files/R/R-4.2.0/bin/Rscript.exe"

def run_code(filepath,run_name="ma"):
    print(filepath)
    if filepath.endswith(".py"):
        result = subprocess.run(["python" , filepath, run_name], capture_output=True)
    else:
        result = subprocess.run([rscript_path,'--vanilla', filepath, run_name], capture_output=True)
    if result.returncode != 0:
        print(result.stderr.decode())
        raise Exception(f"An error occurred while executing {filepath}.")
        
load_corelogic_data_r = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/cleaning/1_load_corelogic_data/code/1_load_corelogic_data.r"
balanced_adjustment_r = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/cleaning/2_adjust_floor_ratio/code/3_balanced_adjustment.r"
xwalk_with_census_tract_py = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/cleaning/3_xwalk_shp/1_xwalk_with_census_tract.py"
xwalk_adj_r = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/cleaning/3_xwalk_shp/2_clean_aei_land.r"

merge_hmda_r = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/cleaning/7_clean_hmda/2_merge_hmda.r"
full_percentile_r = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/analysis/4_examine_housing_percentile_distribution/1b_check_housing_pattern_apt_full.r"

# run_code(load_corelogic_data_r)
# run_code(balanced_adjustment_r)
# run_code(xwalk_with_census_tract_py)
# run_code(xwalk_adj_r)
run_code("C:/Users/67311/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/analysis/7_tract_level_zoning_map/1_adjust_zoning.r")
run_code("C:/Users/67311/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/analysis/7_tract_level_zoning_map/2_check_consistency.r")
run_code("C:/Users/67311/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/analysis/7_tract_level_zoning_map/3_incorporate_tract_shp.py")
# run_code(xwalk_with_census_tract2_py,'tx')


# files = [
#         balanced_adjustment_r,
#         xwalk_with_census_tract_py,
#         obtain_residential_density_r,
#         update_shp_py
#         ]

# for filepath in files:
#     for run_name in run_names:
#         run_code(filepath,run_name)

# run_code(combine_shp_py)


# bay_area_zoning_py = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/cleaning/1a_additional_data/organize_bay_area_zoning.py"
# los_angeles_zoning_py = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise/cleaning/1a_additional_data/organize_los_angeles_zoning.py"
# # run_code(los_angeles_zoning_py)
# run_code(bay_area_zoning_py)
winsound.Beep(500, 1000)