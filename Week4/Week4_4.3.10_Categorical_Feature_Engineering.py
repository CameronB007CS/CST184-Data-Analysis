# Week 4 – Categorical Feature Engineering Activity

import pandas as pd
from itertools import product

# Step 1: Define regions and energy types
regions = ['Asia', 'Africa', 'Europe']
energy_types = ['Solar', 'Wind', 'Hydro']

# Step 2: Create Cartesian product (all region-energy combinations)
combos = list(product(regions, energy_types))

# Step 3: Create a DataFrame
df = pd.DataFrame(combos, columns=['region', 'energy_type'])

# Step 4: Create a combined feature
df['region_energy'] = df['region'] + "_" + df['energy_type']

# Step 5: Display the resulting DataFrame
print("Engineered Feature Table:")
print(df)

# Output:
# Engineered Feature Table:
#    region energy_type region_energy
# 0    Asia       Solar    Asia_Solar
# 1    Asia        Wind     Asia_Wind
# 2    Asia       Hydro    Asia_Hydro
# 3  Africa       Solar  Africa_Solar
# 4  Africa        Wind   Africa_Wind
# 5  Africa       Hydro  Africa_Hydro
# 6  Europe       Solar  Europe_Solar
# 7  Europe        Wind   Europe_Wind
# 8  Europe       Hydro  Europe_Hydro
