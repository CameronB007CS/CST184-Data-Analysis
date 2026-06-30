import pandas as pd

# Step 1: load the data
df = pd.read_csv("Week6_Tutorial_Aggregation_Grouping_Data.csv")
print(df.head())
print()
df.info()
print()
print(df.describe())

# Step 2: average attendance by region
regional_avg = df.groupby('Region')['Attendance'].mean().reset_index()
print("\nAverage attendance by region:")
print(regional_avg)

highest_region = regional_avg.loc[regional_avg['Attendance'].idxmax()]
print(f"\nHighest average attendance: {highest_region['Region']} ({highest_region['Attendance']:.2f}%)")

# Step 3: attendance by region and gender
by_region_gender = df.groupby(['Region', 'Gender'])['Attendance'].mean().reset_index()
print("\nAttendance by region and gender:")
print(by_region_gender)

# easier to read as a pivot table
pivot = df.pivot_table(values='Attendance', index='Region', columns='Gender', aggfunc='mean')
print("\nPivot table version:")
print(pivot)

# Step 4: focus on 2023 only
df_2023 = df[df['Year'] == 2023]
avg_2023 = df_2023.groupby(['Region'])['Attendance'].mean().reset_index()
print("\n2023 attendance by region:")
print(avg_2023)

print("\nComparison -- overall avg vs 2023 avg:")
comparison = regional_avg.merge(avg_2023, on='Region', suffixes=('_overall', '_2023'))
comparison['difference'] = comparison['Attendance_2023'] - comparison['Attendance_overall']
print(comparison)

# Step 5: custom filters

# only female students
female_only = df[df['Gender'] == 'Female']
print("\nFemale students average attendance by region:")
print(female_only.groupby('Region')['Attendance'].mean())

# attendance over 85%
high_attendance = df[df['Attendance'] > 85]
print("\nStudents with attendance over 85%, count by region:")
print(high_attendance.groupby('Region')['Attendance'].count())

# specific region example
south_only = df[df['Region'] == 'South']
print("\nSouth region attendance summary:")
print(south_only['Attendance'].describe())

# combined filter -- high attendance female students
filtered = df[(df['Gender'] == 'Female') & (df['Attendance'] > 85)]
summary = filtered.groupby('Region')['Attendance'].mean()
print("\nHigh attendance (>85%) female students by region:")
print(summary)
