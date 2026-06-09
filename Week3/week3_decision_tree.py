import pandas as pd
import matplotlib.pyplot as plt
from sklearn.tree import DecisionTreeClassifier, plot_tree, export_text
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, accuracy_score

# ── Load Data ──────────────────────────────────────────────
df = pd.read_csv("week3_policy_data.csv")
print(df.head(10))
print()
df.info()
print()
print(df.describe())

# ── Encode Target ──────────────────────────────────────────
le = LabelEncoder()
df["Policy_Label"] = le.fit_transform(df["Apply_Policy"])
print("\nLabel mapping:", dict(zip(le.classes_, le.transform(le.classes_))))

# ── Features & Target ──────────────────────────────────────
X = df[["%Renewable", "CO2_per_capita"]]
y = df["Policy_Label"]

print("\nClass distribution:")
print(df["Apply_Policy"].value_counts())

# ── Train Decision Tree ────────────────────────────────────
clf = DecisionTreeClassifier(max_depth=3, random_state=42)
clf.fit(X, y)

print("\nTree depth:", clf.get_depth())
print("Leaves:", clf.get_n_leaves())
print()
print(export_text(clf, feature_names=["%Renewable", "CO2_per_capita"]))

# ── Visualise Tree ─────────────────────────────────────────
plt.figure(figsize=(14, 6))
plot_tree(clf, feature_names=["%Renewable", "CO2_per_capita"],
          class_names=["No Policy", "Apply Policy"],
          filled=True, rounded=True, fontsize=10)
plt.title("Decision Tree: SDG 7 Policy Classification")
plt.tight_layout()
plt.savefig("decision_tree.png", dpi=150)
plt.show()

# ── Evaluate ───────────────────────────────────────────────
y_pred = clf.predict(X)
print("Accuracy:", accuracy_score(y, y_pred))
print()
print(classification_report(y, y_pred, target_names=["No Policy", "Apply Policy"]))

df["Predicted"] = le.inverse_transform(y_pred)
print(df[["Country", "Apply_Policy", "Predicted", "%Renewable", "CO2_per_capita"]])

# ── Feature Importance ─────────────────────────────────────
importances = pd.Series(clf.feature_importances_, index=["%Renewable", "CO2_per_capita"])
print("\nFeature Importance:")
print(importances)

importances.sort_values().plot(kind="barh", color=["steelblue", "coral"], edgecolor="black")
plt.title("Feature Importance")
plt.xlabel("Importance Score")
plt.tight_layout()
plt.show()

# ── Predict New Countries ──────────────────────────────────
test_cases = [
    {"country": "Hypothetical A", "%Renewable": 70, "CO2_per_capita": 2.0},
    {"country": "Hypothetical B", "%Renewable": 10, "CO2_per_capita": 12.0},
    {"country": "Hypothetical C", "%Renewable": 90, "CO2_per_capita": 5.0},
]

print("\nPredictions for new countries:")
for tc in test_cases:
    X_new = pd.DataFrame([[tc["%Renewable"], tc["CO2_per_capita"]]],
                         columns=["%Renewable", "CO2_per_capita"])
    pred = le.inverse_transform(clf.predict(X_new))[0]
    print(f"  {tc['country']} — {tc['%Renewable']}% renewable, {tc['CO2_per_capita']}t CO2 → {pred}")
