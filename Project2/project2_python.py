import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import seaborn as sns
import networkx as nx
from scipy import stats
import warnings
warnings.filterwarnings('ignore')

# ─────────────────────────────────────────────
# STEP 1: DATA IMPORT & CLEANING
# ─────────────────────────────────────────────

df_raw = pd.read_csv("732-012_meantrend.csv", skiprows=6,
                     names=['Year','Month','Monthly_MSL','Linear_Trend','High_Conf','Low_Conf','extra'])
df_raw = df_raw.drop(columns=['extra'])
df_raw = df_raw.dropna(subset=['Year','Monthly_MSL'])
df_raw['Year'] = df_raw['Year'].astype(int)
df_raw['Month'] = df_raw['Month'].astype(int)
df_raw['Monthly_MSL'] = df_raw['Monthly_MSL'].astype(float)

# convert to mm relative to 1993 baseline
baseline_1993 = df_raw[df_raw['Year'] == 1993]['Monthly_MSL'].mean()
df_raw['Sea_Level_mm'] = (df_raw['Monthly_MSL'] - baseline_1993) * 1000
df_raw['Country'] = 'Tuvalu'

# annual averages for cleaner analysis
df = df_raw.groupby('Year')['Sea_Level_mm'].mean().reset_index()
df.columns = ['Year', 'Sea_Level_mm']
df['Country'] = 'Tuvalu'

print("=== STEP 1: DATA IMPORT & CLEANING ===")
print(f"Raw monthly rows loaded: {len(df_raw)}")
print(f"Missing values: {df_raw.isnull().sum().sum()}")
print(f"Year range: {df['Year'].min()} to {df['Year'].max()}")
print(f"\nFirst 5 rows (annual averages):")
print(df.head())


# ─────────────────────────────────────────────
# STEP 2: SETS & FUNCTIONS
# ─────────────────────────────────────────────

print("\n=== STEP 2: SETS & FUNCTIONS ===")

countries = set(df['Country'].unique())
print(f"Countries in dataset: {countries}")

years = set(df['Year'].unique())
print(f"Number of unique years: {len(years)}")

def get_country_data(country, year_start, year_end):
    result = df[(df['Country'] == country) &
                (df['Year'] >= year_start) &
                (df['Year'] <= year_end)]
    return result

tuvalu_2000_2020 = get_country_data('Tuvalu', 2000, 2020)
print(f"\nTuvalu data 2000-2020 ({len(tuvalu_2000_2020)} rows):")
print(tuvalu_2000_2020.head())


# ─────────────────────────────────────────────
# STEP 3: LOGICAL FILTERING
# ─────────────────────────────────────────────

print("\n=== STEP 3: LOGICAL FILTERING ===")

mean_rise = df['Sea_Level_mm'].mean()
std_rise = df['Sea_Level_mm'].std()
significant_threshold = mean_rise + std_rise

df_2020 = df[df['Year'] == 2020]
above_significant = df_2020[df_2020['Sea_Level_mm'] > significant_threshold]

print(f"Mean sea level rise: {mean_rise:.2f}mm")
print(f"Std dev: {std_rise:.2f}mm")
print(f"Significance threshold (mean + 1 SD): {significant_threshold:.2f}mm")
print(f"\n2020 sea level: {df_2020['Sea_Level_mm'].values[0]:.2f}mm")
print(f"Above significant threshold in 2020: {len(above_significant) > 0}")
print(df_2020[['Country','Sea_Level_mm']])


# ─────────────────────────────────────────────
# STEP 4: PROBABILITY & SUMMARY STATISTICS
# ─────────────────────────────────────────────

print("\n=== STEP 4: PROBABILITY & SUMMARY STATISTICS ===")

stats_summary = df.groupby('Country')['Sea_Level_mm'].agg(['mean','min','max','std'])
print("Summary stats for Tuvalu:")
print(stats_summary)

threshold_120 = 120
prob_above_120 = (df['Sea_Level_mm'] > threshold_120).mean() * 100
print(f"\nProbability sea level rise exceeds {threshold_120}mm: {prob_above_120:.1f}%")

# by decade
df['Decade'] = (df['Year'] // 10) * 10
decade_stats = df.groupby('Decade')['Sea_Level_mm'].agg(['mean','min','max'])
print("\nDecade averages:")
print(decade_stats)


# ─────────────────────────────────────────────
# STEP 5: COUNTING PRINCIPLES
# ─────────────────────────────────────────────

print("\n=== STEP 5: COUNTING PRINCIPLES ===")

unique_combos = df[['Year','Country','Sea_Level_mm']].drop_duplicates()
print(f"Unique Year-Country-SeaLevel combinations: {len(unique_combos)}")
print(f"Unique years: {df['Year'].nunique()}")
print(f"Unique countries: {df['Country'].nunique()}")
print(f"Total data points (monthly): {len(df_raw)}")
print("\nThis tells us the dataset covers one station (Funafuti, Tuvalu) with")
print(f"{df['Year'].nunique()} annual observations from {df['Year'].min()} to {df['Year'].max()}.")


# ─────────────────────────────────────────────
# STEP 6: GRAPH THEORY & NETWORKS
# ─────────────────────────────────────────────

print("\n=== STEP 6: GRAPH THEORY & NETWORKS ===")

decade_nodes = df.groupby('Decade')['Sea_Level_mm'].mean().reset_index()
decade_nodes.columns = ['Decade','Avg_Sea_Level']

G = nx.Graph()
for _, row in decade_nodes.iterrows():
    G.add_node(str(int(row['Decade'])), sea_level=row['Avg_Sea_Level'])

for i, row_i in decade_nodes.iterrows():
    for j, row_j in decade_nodes.iterrows():
        if i < j:
            diff = abs(row_i['Avg_Sea_Level'] - row_j['Avg_Sea_Level'])
            if diff < 50:
                G.add_edge(str(int(row_i['Decade'])), str(int(row_j['Decade'])),
                          weight=round(diff, 2))

print(f"Nodes (decades): {list(G.nodes())}")
print(f"Edges (similar sea levels, diff < 50mm): {list(G.edges(data=True))}")

fig, ax = plt.subplots(figsize=(10, 7))
pos = nx.spring_layout(G, seed=42)
sea_levels = [G.nodes[n]['sea_level'] for n in G.nodes()]
norm = plt.Normalize(min(sea_levels), max(sea_levels))
node_colors = plt.cm.coolwarm(norm(sea_levels))
nx.draw_networkx_nodes(G, pos, node_color=node_colors, node_size=1200, ax=ax)
nx.draw_networkx_labels(G, pos, font_size=10, font_weight='bold', ax=ax)
nx.draw_networkx_edges(G, pos, width=2, alpha=0.5, ax=ax)
edge_labels = nx.get_edge_attributes(G, 'weight')
nx.draw_networkx_edge_labels(G, pos, edge_labels, ax=ax)
sm = plt.cm.ScalarMappable(cmap='coolwarm', norm=norm)
sm.set_array([])
plt.colorbar(sm, ax=ax, label='Avg Sea Level (mm)')
ax.set_title("Network Graph: Decade Sea Level Similarity\n(Edges connect decades with <50mm difference)",
          fontsize=13, fontweight='bold')
ax.axis('off')
plt.tight_layout()
plt.savefig("step6_network.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: step6_network.png")


# ─────────────────────────────────────────────
# STEP 7: AGGREGATION & VISUALISATION
# ─────────────────────────────────────────────

print("\n=== STEP 7: AGGREGATION & VISUALISATION ===")

# line chart: sea level rise over time
plt.figure(figsize=(12, 6))
plt.plot(df['Year'], df['Sea_Level_mm'], color='steelblue', linewidth=2, marker='o', markersize=3)
z = np.polyfit(df['Year'], df['Sea_Level_mm'], 1)
p = np.poly1d(z)
plt.plot(df['Year'], p(df['Year']), 'r--', linewidth=1.5, label=f'Trend line')
plt.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
plt.fill_between(df['Year'], df['Sea_Level_mm'], 0,
                 where=(df['Sea_Level_mm'] > 0), alpha=0.1, color='red')
plt.fill_between(df['Year'], df['Sea_Level_mm'], 0,
                 where=(df['Sea_Level_mm'] < 0), alpha=0.1, color='blue')
plt.title("Average Annual Sea Level Rise – Tuvalu (Funafuti)\nRelative to 1993 Baseline",
          fontsize=14, fontweight='bold')
plt.xlabel("Year")
plt.ylabel("Sea Level Change (mm)")
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("step7_linechart.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: step7_linechart.png")

# bar chart: sea level by decade
decade_avg = df.groupby('Decade')['Sea_Level_mm'].mean()
plt.figure(figsize=(10, 6))
colors = ['steelblue' if v < 0 else 'firebrick' for v in decade_avg.values]
bars = plt.bar(decade_avg.index.astype(str), decade_avg.values, color=colors, edgecolor='black', width=0.6)
plt.axhline(y=0, color='black', linewidth=0.8)
for bar, val in zip(bars, decade_avg.values):
    plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 2,
             f'{val:.1f}mm', ha='center', va='bottom', fontsize=10, fontweight='bold')
plt.title("Average Sea Level Rise by Decade – Tuvalu",
          fontsize=14, fontweight='bold')
plt.xlabel("Decade")
plt.ylabel("Average Sea Level Change (mm)")
plt.grid(axis='y', alpha=0.3)
plt.tight_layout()
plt.savefig("step7_barchart.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: step7_barchart.png")

# scatterplot: sea level vs year with trend
post_1993 = df[df['Year'] >= 1993]
plt.figure(figsize=(10, 6))
scatter = plt.scatter(post_1993['Year'], post_1993['Sea_Level_mm'],
                      c=post_1993['Sea_Level_mm'], cmap='RdYlBu_r',
                      s=80, edgecolor='black', linewidth=0.5, zorder=3)
z2 = np.polyfit(post_1993['Year'], post_1993['Sea_Level_mm'], 1)
p2 = np.poly1d(z2)
plt.plot(post_1993['Year'], p2(post_1993['Year']), 'r--',
         linewidth=2, label=f'Trend: +{z2[0]:.1f}mm/year')
plt.colorbar(scatter, label='Sea Level Change (mm)')
plt.title("Sea Level Rise Scatterplot – Tuvalu (1993–2023)",
          fontsize=14, fontweight='bold')
plt.xlabel("Year")
plt.ylabel("Sea Level Change (mm)")
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("step7_scatter.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: step7_scatter.png")

print("\n=== ALL PYTHON STEPS COMPLETE ===")
print("Charts saved: step6_network.png, step7_linechart.png, step7_barchart.png, step7_scatter.png")
