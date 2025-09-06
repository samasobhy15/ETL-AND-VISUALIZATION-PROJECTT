import pandas as pd
from sklearn.preprocessing import LabelEncoder
file_path = "Book_multisources_dataset.xlsx"   
df = pd.read_excel(file_path, sheet_name="Sheet1")
df_clean = df.copy()
df_clean["Image URL"] = df_clean["Image URL"].fillna("Unknown")
df_clean["Book Link"] = df_clean["Book Link"].fillna("Unknown")
df_clean["Category"] = df_clean["Category"].fillna("Unknown")
df_clean = df_clean.drop_duplicates()
df_clean["Book Title"] = df_clean["Book Title"].str.strip()
df_clean["Price_Normalized"] = (
    (df_clean["Price"] - df_clean["Price"].min()) /
    (df_clean["Price"].max() - df_clean["Price"].min())
)
encoder = LabelEncoder()
df_clean["Category_Encoded"] = encoder.fit_transform(df_clean["Category"])
output_path = "Book_dataset_clean.csv" 
df_clean.to_csv(output_path, index=False)

print("Cleaned dataset saved as -->", output_path)
df_clean.to_csv("Book_dataset_clean.csv", index=False)
