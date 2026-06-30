import pandas as pd

# Step 1: load the data
df = pd.read_csv("Week6_Tutorial_Grouping_Filtering_Data.csv")
print(df.head())
print()
df.info()

# Step 2: check for missing values and clean
print("\nMissing values per column:")
print(df.isnull().sum())

df_cleaned = df.dropna(subset=['Attendance'])
print("\nRows before cleaning:", len(df))
print("Rows after cleaning:", len(df_cleaned))
print("Rows removed:", len(df) - len(df_cleaned))

# Step 3: filter to 2023 only
df_2023 = df_cleaned[df_cleaned['Year'] == 2023]
print("\n2023 data preview:")
print(df_2023.head())
print("\nRows for 2023 only:", len(df_2023))

# Step 4: group by region and gender
summary = df_2023.groupby(['Region', 'Gender'])['Attendance'].agg(['mean', 'count']).reset_index()
print("\nSummary by region and gender:")
print(summary)

# pivot table version, easier to read
pivot = df_2023.pivot_table(values='Attendance', index='Region', columns='Gender', aggfunc='mean')
print("\nPivot table version:")
print(pivot)

# Step 5: filter for high attendance regions
region_avg = df_2023.groupby('Region')['Attendance'].mean()
print("\nAverage attendance by region (2023):")
print(region_avg)

high_regions = region_avg[region_avg > 85]
print("\nRegions with average attendance over 85%:")
print(high_regions)

# Step 6: combine everything into one pipeline
result = (
    df_cleaned[df_cleaned['Year'] == 2023]
    .groupby(['Region', 'Gender'])['Attendance']
    .agg(['mean', 'count'])
    .reset_index()
)
print("\nFull pipeline result (filter -> group -> aggregate -> reset index):")
print(result)
