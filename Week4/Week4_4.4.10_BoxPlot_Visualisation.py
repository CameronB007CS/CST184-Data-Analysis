# Week 4 – Box Plot Visualization for Categorical Features

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import random

# Step 1: Simulated dataset
regions = ['Asia', 'Africa', 'Europe']
energy_types = ['Solar', 'Wind', 'Hydro']

# Generate combinations
data = []
for region in regions:
    for energy in energy_types:
        for _ in range(10):  # 10 data points per category
            co2 = random.gauss(mu=5 if energy == 'Hydro' else 3, sigma=1.5)
            data.append([region, energy, round(max(co2, 0.2), 2)])  # no negative emissions

df = pd.DataFrame(data, columns=['region', 'energy_type', 'co2_emissions'])

# Step 2: Create new combined category
df['region_energy'] = df['region'] + "_" + df['energy_type']

# Step 3: Plot box plot
plt.figure(figsize=(12, 6))
sns.boxplot(data=df, x='region_energy', y='co2_emissions')
plt.title("CO₂ Emissions by Region + Energy Strategy")
plt.xticks(rotation=45)
plt.ylabel("CO₂ Emissions (tonnes per capita)")
plt.xlabel("Region and Energy Type")
plt.tight_layout()
plt.savefig("boxplot_co2_emissions.png", dpi=150)
plt.show()
