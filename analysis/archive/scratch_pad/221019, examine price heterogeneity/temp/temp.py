import csv
import os
import arcpy

newFile = r"C:\Users\67311\OneDrive - The Pennsylvania State University\Los Angeles Zoning, 2022\analysis\scratch_pad\221019, examine price heterogeneity\temp\data.csv"

# arcpy.MakeTableView_management(in_table=newFile, out_view='viewtemp')

out_gdb = r"C:\Users\67311\OneDrive - The Pennsylvania State University\Los Angeles Zoning, 2022\analysis\scratch_pad\221019, examine price heterogeneity\temp"

# arcpy.TableToTable_conversion('viewtemp', out_gdb, 'tempTable')

# arcpy.CreateFileGDB_management(out_gdb, "fGDB.gdb")

arcpy.MakeXYEventLayer_management("tempTable.dbf", "x", "y", 
                                  "fGDB.gdb/firestations_points", "", "")
arcpy.Delete_management("fGDB.gdb")
# arcpy.SaveToLayerFile_management("firestations_points", "firestations_points")

print(type(firestations_points))