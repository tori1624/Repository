import arcpy
import numpy as np

workspace = 'D:\\Study\\2018\\GISproject\\project\\'
shpPath = 'D:\\Study\\2018\\GISproject\\project\\kostat_seoul_sort.shp'

def spatialProximity(dataPath, shpPath):
    # Data
    data = open(dataPath, 'r')

    index, group1, group2 = 0, [], []

    for line in data:
        index += 1
        if index == 1:
            continue
        g1 = float(line.split(',')[0])
        g2 = float(line.split(',')[1])
        group1.append(g1)
        group2.append(g2)

    # Shp
    ## center point
    arcpy.FeatureToPoint_management(shpPath, workspace + 'center.shp', '')
    arcpy.FeatureToPoint_management(shpPath, workspace + 'center_1.shp', '')

    ## distance between points
    arcpy.PointDistance_analysis(workspace + 'center.shp', workspace + 'center_1.shp',
                                 workspace + 'table.dbf', '')

    ## sort distance table
    arcpy.Sort_management(workspace + 'table.dbf', workspace + 'table_sort.dbf',
                          [['INPUT_FID', 'ASCENDING'], ['NEAR_FID', 'ASCENDING']])

    ## shp length
    shpLength = 0 
    
    with arcpy.da.SearchCursor(shpPath, ['FID']) as cursor:
        for row in cursor:
            shpLength += 1

    ## distance matrix
    distance = []

    with arcpy.da.SearchCursor(workspace + 'table_sort.dbf', ['DISTANCE']) as cursor:
        for row in cursor:
            distance.append(row[0])

    distance = np.divide(distance, 1000) # km
    distanceNegative = [x * -1 for x in distance] # negative
    distance = np.exp(distanceNegative) # exponential function

    distanceMatrix = np.array(distance).reshape((shpLength, shpLength))

    # Calculation
    pa, pb, pt = 0, 0, 0

    total = np.array([group1, group2])
    total = np.sum(total, axis = 0)

    for i in range(shpLength):
        for j in range(shpLength):
            cij = distanceMatrix[i, j]

            ## A
            pai = group1[i] / sum(group1)
            paj = group1[j] / sum(group1)
            paij = (pai * paj * cij)
            pa = pa + paij

            ## B
            pbi = group2[i] / sum(group2)
            pbj = group2[j] / sum(group2)
            pbij = (pbi * pbj * cij)
            pb = pb + pbij

            ## Total
            pti = total[i] / sum(total)
            ptj = total[j] / sum(total)
            ptij = (pti * ptj * cij)
            pt = pt + ptij

    result = ((sum(group1) * pa) + (sum(group2) * pb)) / (sum(total) * pt)
    result = round(result, 4)

    # Delete file
    arcpy.Delete_management(workspace + 'center.shp')
    arcpy.Delete_management(workspace + 'center_1.shp')
    arcpy.Delete_management(workspace + 'table.dbf')
    arcpy.Delete_management(workspace + 'table_sort.dbf')

    data.close()
    return result 

# residence
spatialProximity(workspace + 'residence_low.csv', shpPath) # 1.0234(1.008869)
spatialProximity(workspace + 'residence_middle.csv', shpPath) # 1.0181( 1.005781)
spatialProximity(workspace + 'residence_high.csv', shpPath) # 1.0395(1.020637)

# work
spatialProximity(workspace + 'work_low.csv', shpPath) # 1.011(1.004459)
spatialProximity(workspace + 'work_middle.csv', shpPath) # 1.0055(1.001682)
spatialProximity(workspace + 'work_high.csv', shpPath) # 1.0174(1.007007)

# school
spatialProximity(workspace + 'school_low.csv', shpPath) # 1.0347(1.011612)
spatialProximity(workspace + 'school_middle.csv', shpPath) # 1.0419(1.014616)
spatialProximity(workspace + 'school_high.csv', shpPath) # 1.0377(1.019355)
