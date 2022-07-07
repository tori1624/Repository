from pyspark.sql import SparkSession

spark = SparkSession.builder.master("local").appName("SparkSQL").getOrCreate() # 스파크 세션 생성
spark.sparkContext.setLogLevel("ERROR") # 로그 레벨 정의

# 예제 데이터 생성
data = [('001','Smith','M',40,'DA',4000),
        ('002','Rose','M',35,'DA',3000),
        ('003','Williams','M',30,'DE',2500),
        ('004','Anne','F',30,'DE',3000),
        ('005','Mary','F',35,'BE',4000),
        ('006','James','M',30,'FE',3500)]

columns = ["cd","name","gender","age","div","salary"]
df = spark.createDataFrame(data = data, schema = columns)
df.printSchema()
df.show()

# select
df.createOrReplaceTempView("EMP_INFO")
df2 = spark.sql("select name, gender, div, salary from emp_info")
df2.show()

df.select('name', 'gender', 'div', 'salary').show()

# filter
from pyspark.sql import functions as F
df.filter("gender == 'F'").show()
df.filter(
        (F.col("div") == "DA") &
        (F.col("salary") > 3500)
).count()

# group by
df.groupby("div").count().sort("count", ascending=True).show()

# rdd to data frame
test_df = df.select('name', 'gender', 'div', 'salary').toPandas()
