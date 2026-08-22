import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt

# Step 1: load the data
nodes_df = pd.read_csv("week5_tutorial_nodes.csv")
edges_df = pd.read_csv("week5_tutorial_edges.csv")

print("Nodes:")
print(nodes_df)
print("\nEdges:")
print(edges_df)

# build the graph
G = nx.Graph()
for _, row in nodes_df.iterrows():
    G.add_node(row['name'], type=row['type'], gender=row['gender'], region=row['region'])

for _, row in edges_df.iterrows():
    G.add_edge(row['Source'], row['Target'], weight=row['Weight'])

# Step 2: analyze graph structure
print("\nNumber of nodes:", G.number_of_nodes())
print("Number of edges:", G.number_of_edges())
print("Is the network connected?", nx.is_connected(G))

print("\nNode degrees:")
for node in G.nodes():
    print(f"  {node}: Degree = {G.degree(node)}")

# Step 3: centrality and clustering
centrality = nx.betweenness_centrality(G)
print("\nBetweenness Centrality:")
for k, v in centrality.items():
    print(f"  {k}: {round(v, 3)}")

clustering = nx.clustering(G)
print("\nClustering Coefficient:")
for k, v in clustering.items():
    print(f"  {k}: {round(v, 2)}")

# Step 4: visualize with attributes
pos = nx.spring_layout(G, seed=42)
gender_colors = {'Male': 'skyblue', 'Female': 'lightcoral'}
node_colors = [gender_colors[G.nodes[n]['gender']] for n in G.nodes]
node_sizes = [G.degree(n) * 600 for n in G.nodes]

plt.figure(figsize=(10, 6))
nx.draw(G, pos, with_labels=True, node_color=node_colors, node_size=node_sizes)
nx.draw_networkx_edge_labels(G, pos, edge_labels=nx.get_edge_attributes(G, 'weight'))
plt.title("Education Network - Nodes by Gender & Degree")
plt.savefig("week5_network.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: week5_network.png")

# Step 5: modify the network - remove an edge and check connectivity
G.remove_edge("Ben", "Farid")
print("\nAfter removing Ben-Farid edge, is connected?", nx.is_connected(G))

plt.figure(figsize=(10, 6))
nx.draw(G, pos, with_labels=True, node_color=node_colors, node_size=node_sizes)
plt.title("After Removing a Key Connection")
plt.show()

# add a new mentor node
G.add_node("Maya", type="Mentor", gender="Female", region="South")
G.add_edge("Maya", "Ben", weight=3)
G.add_edge("Maya", "Grace", weight=2)
print("\nAfter adding Maya (new mentor):")
print("Number of nodes:", G.number_of_nodes())
print("Is connected?", nx.is_connected(G))

# Step 6: save the final graph
pos2 = nx.spring_layout(G, seed=42)
node_colors2 = [gender_colors.get(G.nodes[n].get('gender', 'Male'), 'skyblue') for n in G.nodes]
node_sizes2 = [G.degree(n) * 600 for n in G.nodes]

plt.figure(figsize=(10, 6))
nx.draw(G, pos2, with_labels=True, node_color=node_colors2, node_size=node_sizes2)
plt.title("Final Network Export")
plt.savefig("week5_network_final.png", dpi=150, bbox_inches='tight')
plt.show()
print("Saved: week5_network_final.png")
