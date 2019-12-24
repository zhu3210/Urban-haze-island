# -*- coding: utf-8 -*-
"""
Created on Thu Jun  6 16:04:31 2019
this code is to split shpfile into single shpfile
@author: ZL
"""
import sys
arcpy_path = [r'C:\Python27\ArcGIS10.3\Lib\site-packages',
              r'C:\Program Files (x86)\ArcGIS\Desktop10.3\arcpy',
              r'C:\Program Files (x86)\ArcGIS\Desktop10.3\bin',
              r'C:\Program Files (x86)\ArcGIS\Desktop10.3\ArcToolbox\Scripts']
sys.path.extend(arcpy_path)
import arcpy
from arcpy import env
env.workspace = r"C:\Users\ZL\Desktop\0606\new"#define working space
shp = "newcity.shp"#The file to be processed
out_path=r"C:\Users\ZL\Desktop\0606\new\singleshp"#output file path

with arcpy.da.SearchCursor(shp, ["SHAPE@",'NAME']) as cursor:
    for row in cursor:
        out_name=row[1]+'.shp'#output file name
        arcpy.FeatureClassToFeatureClass_conversion (row[0],out_path,out_name)
