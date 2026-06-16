import pandas as pd
import matplotlib.pyplot as plt
from sklearn.tree import DecisionTreeClassifier, plot_tree, export_text
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, accuracy_score

# load the dataset
df = pd.read_csv("week3_policy_data.csv")
print(df.head(10))                                                                                      #I loaded the CSV into a pandas DataFrame and used 
                                                                                                        #head(), info() and describe() to get a feel for the data — checking column types, making sure nothing was missing, and seeing the range of values."
print()

# basic stats like min, max, mean etc
print(df.describe())

# turning yes/no into 1/0 so the model can actually read it
df["Label"] = df["Apply_Policy"].map({"yes": 1, "no": 0})
print(df[["Country", "Apply_Policy", "Label"]])

# X = the inputs, y = what we're trying to predict
X = df[["%Renewable", "CO2_per_capita"]]
y = df["Label"]

# train the tree
tree = DecisionTreeClassifier(max_depth=3, random_state=0)
tree.fit(X, y)

# draw the tree
plt.figure(figsize=(10, 6))
plot_tree(tree, feature_names=X.columns, class_names=["No", "Yes"], filled=True, rounded=True)
plt.title("Decision Tree – Apply Policy A")
plt.show()

# test some new countries
new_data = pd.DataFrame({
    "%Renewable": [52, 20, 75],
    "CO2_per_capita": [1.5, 2.5, 3.0]
})

predictions = tree.predict(new_data)
print(predictions)


# CHALLENGE TASK TIME

# Challenge 1: add Region as a third feature
# Region is text so we encode it into numbers first, same idea as the label encoding above
le = LabelEncoder()
df["Region_Encoded"] = le.fit_transform(df["Region"])

print("\nRegion encoding:")
for original, encoded in zip(le.classes_, le.transform(le.classes_)):
    print(f"  {original} -> {encoded}")

X3 = df[["%Renewable", "CO2_per_capita", "Region_Encoded"]]
tree3 = DecisionTreeClassifier(max_depth=3, random_state=0)
tree3.fit(X3, y)

print("\nTree with Region added:")
print(export_text(tree3, feature_names=["%Renewable", "CO2_per_capita", "Region"]))

plt.figure(figsize=(16, 7))
plot_tree(tree3, feature_names=["%Renewable", "CO2_per_capita", "Region"],
          class_names=["No", "Yes"],
          filled=True, rounded=True, fontsize=9)
plt.title("Decision Tree with Region Added")
plt.tight_layout()
plt.show()


# Challenge 2: use predict_proba to get confidence scores instead of hard yes/no
proba = tree.predict_proba(new_data)

print("\nProbability estimates (No / Yes):")
for i, (row, prob) in enumerate(zip(new_data.itertuples(), proba)):
    print(f"  Country {i+1} — {row._1}% renewable, {row.CO2_per_capita}t CO2")
    print(f"    No: {prob[0]:.0%}  |  Yes: {prob[1]:.0%}")


# Challenge 3: create a new policy label using a stricter CO2 threshold
# instead of the original yes/no we're making our own, qualify if CO2 < 1.5
df["Strict_Policy"] = (df["CO2_per_capita"] < 1.5).astype(int)

print("\nStrict policy (CO2 < 1.5):")
print(df[["Country", "CO2_per_capita", "Strict_Policy"]])

tree_strict = DecisionTreeClassifier(max_depth=3, random_state=0)
tree_strict.fit(X, df["Strict_Policy"])

print("\nStrict policy tree rules:")
print(export_text(tree_strict, feature_names=["%Renewable", "CO2_per_capita"]))

plt.figure(figsize=(10, 6))
plot_tree(tree_strict, feature_names=X.columns, class_names=["No", "Yes"],
          filled=True, rounded=True)
plt.title("Decision Tree – Strict CO2 < 1.5 Policy")
plt.show()
