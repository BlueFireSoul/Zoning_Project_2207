import getpass
import sys
import os
current_user = getpass.getuser()
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *
import subprocess

if current_user == "dmh5950":
    rscript_path = "C:/Program Files/R/R-4.3.1/bin/Rscript.exe"
elif current_user == "67311":
    rscript_path = "C:/Program Files/R/R-4.2.1/bin/Rscript.exe"

def run_code(filepath,run_name="ma"):
    print(filepath)
    if filepath.endswith(".py"):
        result = subprocess.run(["python" , filepath, run_name], capture_output=True)
    else:
        result = subprocess.run([rscript_path,'--vanilla', filepath, run_name], capture_output=True)
    if result.returncode != 0:
        print(result.stderr.decode())
        raise Exception(f"An error occurred while executing {filepath}.")
    
# run_code('2_obtain_distance_matrix.py')
run_code('3_format_matrix_csv.py')
os.startfile(tract_ma_matrix_csv)