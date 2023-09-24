import csv
import sys
import csv
import csv

filename = 'C:/Users/dmh5950/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_cdict_xwalk_ma.csv'
max_rows = 1
rows = []

with open(filename, 'r') as file:
    # Skip header row if it exists
    header = file.readline().strip().split(",")
    
    # Read and process rows
    for i in range(max_rows):
        row = file.readline().strip().split(",")
        if not row:
            break  # Reached end of file
        rows.append(row)

# Print the extracted rows
for row in rows:
    print(row)

# Usage example
output_file = 'C:/Users/dmh5950/OneDrive - The Pennsylvania State University/2207 - Zoning - database/output/property_cdict_xwalk_mas.csv'
num_rows = 100


