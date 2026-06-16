import math
from itertools import permutations, combinations

# Step 1: Define energy strategies
strategies = ['Solar', 'Wind', 'Hydro', 'Geothermal', 'Biomass']
print("Available strategies:", strategies)

# Step 2: How many combinations of 3 strategies (order doesn't matter)?
n = len(strategies)
r = 3
print("\nCombinations (nCr):")
print(f"From {n} strategies, choosing {r} gives:", math.comb(n, r))

# Step 3: How many permutations of 3 strategies (order matters)?
print("\nPermutations (nPr):")
print(f"From {n} strategies, arranging {r} gives:", math.perm(n, r))

# Step 4: List all combinations
print("\nAll possible combinations of 3 strategies:")
for combo in combinations(strategies, r):
    print(combo)

# Step 5: List first 5 permutations
print("\nSample permutations of 3 strategies (first 5 only):")
for i, perm in enumerate(permutations(strategies, r)):
    print(perm)
    if i == 4:
        break

# Output:
# Available strategies: ['Solar', 'Wind', 'Hydro', 'Geothermal', 'Biomass']
#
# Combinations (nCr):
# From 5 strategies, choosing 3 gives: 10
#
# Permutations (nPr):
# From 5 strategies, arranging 3 gives: 60
#
# All possible combinations of 3 strategies:
# ('Solar', 'Wind', 'Hydro')
# ('Solar', 'Wind', 'Geothermal')
# ('Solar', 'Wind', 'Biomass')
# ('Solar', 'Hydro', 'Geothermal')
# ('Solar', 'Hydro', 'Biomass')
# ('Solar', 'Geothermal', 'Biomass')
# ('Wind', 'Hydro', 'Geothermal')
# ('Wind', 'Hydro', 'Biomass')
# ('Wind', 'Geothermal', 'Biomass')
# ('Hydro', 'Geothermal', 'Biomass')
#
# Sample permutations of 3 strategies (first 5 only):
# ('Solar', 'Wind', 'Hydro')
# ('Solar', 'Wind', 'Geothermal')
# ('Solar', 'Wind', 'Biomass')
# ('Solar', 'Hydro', 'Wind')
# ('Solar', 'Hydro', 'Geothermal')
