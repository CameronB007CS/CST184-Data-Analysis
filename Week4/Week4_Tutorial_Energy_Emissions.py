import pandas as pd
import math
import seaborn as sns
import matplotlib.pyplot as plt
from itertools import product

# Step 1: load the dataset
df = pd.read_csv("week4_energy_emissions.csv")
print(df.head())
print()
df.info()
print()
print(df.describe())

# Step 2: figure out how many combinations are possible
regions = df["Region"].unique()
types = df["Energy_Type"].unique()

print("\nRegions:", regions)
print("Energy types:", types)

# nCr -- how many ways to pick 2 things from the combined pool of regions + types
print("\nCombinations (nCr):", math.comb(len(regions) + len(types), 2))

# cartesian product -- every region paired with every energy type
pairs = list(product(regions, types))
print("Region x Energy combinations:", len(pairs))
for p in pairs:
    print(" ", p)

# try this: what if we added a new region?
regions_extended = ['Asia', 'Africa', 'Europe', 'South America']
types_extended = list(types)
pairs_extended = list(product(regions_extended, types_extended))
print("\nWith South America added:", len(pairs_extended), "combinations")

# Step 3: engineer a new feature combining region and energy type
df["Region_Energy"] = df["Region"] + "_" + df["Energy_Type"]
print("\nNew feature added:")
print(df.head())

# try this: reverse the order
df["Energy_Region"] = df["Energy_Type"] + "_" + df["Region"]
print("\nReversed version:")
print(df[["Region", "Energy_Type", "Region_Energy", "Energy_Region"]].head())

# Step 4: box plot comparing emissions across region-energy pairs
plt.figure(figsize=(12, 6))
sns.boxplot(data=df, x="Region_Energy", y="CO2_Emissions")
plt.title("CO₂ Emissions by Region + Energy Type")
plt.xticks(rotation=45)
plt.ylabel("CO₂ Emissions (tonnes)")
plt.xlabel("Region and Energy Type")
plt.tight_layout()
plt.savefig("week4_boxplot.png", dpi=150)
plt.show()
