import pandas as pd
import matplotlib.pyplot as plt

# Step 1: load the data
df = pd.read_csv("renewable_energy.csv")
print(df.head())

# print just country and renewable columns
print(df[["Country", "%Renewable"]])

# Step 2: filter the data
high_renewable = df[df["%Renewable"] > 50]
print("\nCountries with >50% renewable:")
print(high_renewable)

# try threshold at 70%
high_renewable_70 = df[df["%Renewable"] > 70]
print("\nCountries with >70% renewable:")
print(high_renewable_70)

# Step 3: create a set
high_set = set(high_renewable["Country"])
print("\nCountries with >50% renewable energy:", high_set)
print("Cardinality:", len(high_set))

# Step 4: create a dictionary
emissions_dict = dict(zip(df["Country"], df["CO2_Emissions"]))
print("\nBrazil CO2 emissions:", emissions_dict["Brazil"])

# Step 5: bar chart - CO2 emissions
plt.bar(emissions_dict.keys(), emissions_dict.values(), color="green")
plt.xticks(rotation=45)
plt.title("CO2 Emissions per Capita by Country")
plt.ylabel("Tonnes")
plt.grid(True)
plt.tight_layout()
plt.savefig("week1_co2_bar.png", dpi=150)
plt.show()

# Step 6: scatterplot - population vs renewable
plt.scatter(df["Population"], df["%Renewable"])

for i in range(len(df)):
    plt.text(df["Population"][i], df["%Renewable"][i], df["Country"][i])

plt.title("Population vs % Renewable Energy Use")
plt.xlabel("Population (millions)")
plt.ylabel("% Renewable")
plt.grid(True)
plt.tight_layout()
plt.savefig("week1_scatter.png", dpi=150)
plt.show()

# challenge: plot only Asia region
asia = df[df["Region"] == "Asia"]
plt.scatter(asia["Population"], asia["%Renewable"], color="orange")

for i in asia.index:
    plt.text(asia["Population"][i], asia["%Renewable"][i], asia["Country"][i])

plt.title("Population vs % Renewable - Asia Only")
plt.xlabel("Population (millions)")
plt.ylabel("% Renewable")
plt.grid(True)
plt.tight_layout()
plt.savefig("week1_scatter_asia.png", dpi=150)
plt.show()

# Step 7: save filtered subset
subset = df[df["%Renewable"] > 60]
subset.to_csv("high_renewable_countries.csv", index=False)
print("\nSaved high_renewable_countries.csv")
print(subset)
