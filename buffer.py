# -*- coding: utf-8 -*-
"""
@author: ZL
e-mail:zhulei@mail.bnu.edu.cn
run in python2.7
this code is to generate PM2.5 concentretion-distance scatter diagram
"""
from __future__ import print_function
import sys
#corresponding path of ArcGIS. To ensure the arcpy can be imported 
arcpy_path = [r'C:\Python27\ArcGIS10.3\Lib\site-packages',
              r'C:\Program Files (x86)\ArcGIS\Desktop10.3\arcpy',
              r'C:\Program Files (x86)\ArcGIS\Desktop10.3\bin',
              r'C:\Program Files (x86)\ArcGIS\Desktop10.3\ArcToolbox\Scripts']
sys.path.extend(arcpy_path)
import arcpy
from arcpy.sa import *
import numpy as np
import pandas as pd
import os

dir_str = r'C:\Users\ZL\Desktop\0606\new\singleshp'#path of point shpfile(the center of the cities)
dir_str = dir_str.decode('utf-8')
file_name = os.listdir(dir_str)
file_dir = []#save the path of each shpfile
name = []#save the name of each shpfile
#selet file with the ending of 'shp'
for x in file_name:
    if x[-1]=='p':
        file_dir.append(os.path.join(dir_str,x))
#selet file name
for x in file_name:
    if x[-1]=='p':
        name.append(x[:-4])

arcpy.env.workspace = (r'C:\Users\ZL\Desktop\0606\1')#define working space
arcpy.env.overwriteOutput = True#enable the overwrite
lenth= len(file_dir)#number of cities
data = np.zeros((50,lenth))#save the final output
for i in range(lenth):#i is the number of cities, j is the distance of the buffer
    for j in range(50):
        if j == 0:
            arcpy.Buffer_analysis(file_dir[i],"33.shp","1 KILOMETERS")
        else:
            eval('arcpy.Buffer_analysis(file_dir[i], "11.shp", "{} KILOMETERS")'.format(j))
            eval('arcpy.Buffer_analysis(file_dir[i], "22.shp", "{} KILOMETERS")'.format(j+1))
            arcpy.Erase_analysis('22.shp','11.shp','33.shp','#')
        outZonalStats = ZonalStatisticsAsTable("33.shp", "Id", "C:/Users/ZL/Desktop/0606/2016-China.tif",
                                               "C:/Users/ZL/Desktop/0606/1/1.dbf", "DATA","MEAN")
        arcpy.TableToTable_conversion("1.dbf", "C:/Users/ZL/Desktop/0606/1", "1.txt")
        res = pd.read_table('C:/Users/ZL/Desktop/0606/1/1.txt',sep=',') 
        data[j][i]=res.loc[0,'MEAN']
    c=(i*100/lenth)
    print("\r{}%".format(c), end = '')

x1 = pd.DataFrame(data)
x1.columns=name
x1.to_excel(r'C:\Users\ZL\Desktop\0606\new\data.xlsx')#save as excel
