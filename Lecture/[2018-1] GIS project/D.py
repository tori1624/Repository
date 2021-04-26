import numpy as np

workspace = 'D:\\Study\\2018\\GISproject\\project\\'

def dissimilarity(dataPath):
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

    # Calculation
    groupRatio1 = np.divide(group1, sum(group1))
    groupRatio2 = np.divide(group2, sum(group2))
    result = sum(np.abs(np.subtract(groupRatio1, groupRatio2))) / 2
    result = round(result, 4)
    
    data.close()
    return result

# residence
dissimilarity(workspace + 'residence_low.csv') # 0.2955
dissimilarity(workspace + 'residence_middle.csv') # 0.2100
dissimilarity(workspace + 'residence_high.csv') # 0.3121

# work
dissimilarity(workspace + 'work_low.csv') # 0.2189
dissimilarity(workspace + 'work_middle.csv') # 0.1069
dissimilarity(workspace + 'work_high.csv') # 0.1729

# school
dissimilarity(workspace + 'school_low.csv') # 0.4286
dissimilarity(workspace + 'school_middle.csv') # 0.2936
dissimilarity(workspace + 'school_high.csv') # 0.2885
