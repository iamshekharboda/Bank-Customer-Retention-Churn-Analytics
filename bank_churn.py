"""Clean bank churn records using pandas.

Usage:
    python3 clean_bank_churn.py [input.csv] [output.csv]

Winsorization applies to CreditScore, Age, Balance, and EstimatedSalary.
Other columns in the input are preserved without additional encoding.
"""

import argparse
from pathlib import Path

import pandas as pd


CONTINUOUS = ["CreditScore", "Age", "Balance", "EstimatedSalary"]


def clean_bank_churn(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    required = set(CONTINUOUS + ["Exited", "Geography", "Gender", "Tenure",
                                "NumOfProducts", "HasCrCard", "IsActiveMember"])
    missing = required.difference(df.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")

    df = df.drop(columns=["RowNumber", "CustomerId", "Surname"], errors="ignore")
    df = df.dropna(subset=["Exited"])
    if df.empty:
        raise ValueError("No records remain after dropping missing churn labels.")

    # Normalize before grouping, so whitespace/case variants share a median.
    for col in ["Geography", "Gender"]:
        df[col] = df[col].astype("string").str.strip().str.capitalize()
        df[col] = df[col].replace("", pd.NA)
        modes = df[col].mode()
        if modes.empty:
            raise ValueError(f"Cannot compute a mode for entirely missing {col}.")
        df[col] = df[col].fillna(modes.iloc[0])

    for col in CONTINUOUS:
        df[col] = pd.to_numeric(df[col], errors="coerce")
        df[col] = df[col].replace([float("inf"), float("-inf")], float("nan"))
        df[f"{col}_missing"] = df[col].isna().astype("int8")

    for col in ["EstimatedSalary", "CreditScore"]:
        group_medians = df.groupby("Geography")[col].transform("median")
        # Global fallback covers geographies with no observed values.
        df[col] = df[col].fillna(group_medians).fillna(df[col].median())
        if df[col].isna().any():
            raise ValueError(f"Cannot compute a median for entirely missing {col}.")

    df["Age"] = df["Age"].fillna(df["Age"].median())
    if df["Age"].isna().any():
        raise ValueError("Cannot compute a median for entirely missing Age.")
    df["Balance"] = df["Balance"].fillna(0)
    for col in ["HasCrCard", "IsActiveMember"]:
        df[col] = df[col].fillna(1)

    df["Tenure"] = pd.to_numeric(df["Tenure"], errors="raise")
    df["NumOfProducts"] = pd.to_numeric(df["NumOfProducts"], errors="raise")

    def enforce_bounds(frame: pd.DataFrame) -> None:
        frame["CreditScore"] = frame["CreditScore"].clip(300, 850)
        frame["Age"] = frame["Age"].clip(18, 100)
        frame["Tenure"] = frame["Tenure"].clip(lower=0, upper=frame["Age"] - 18)
        frame["NumOfProducts"] = frame["NumOfProducts"].clip(1, 4)
        for col in ["Balance", "EstimatedSalary"]:
            frame[col] = frame[col].clip(lower=0)

    enforce_bounds(df)
    for col in CONTINUOUS:
        lower, upper = df[col].quantile([0.01, 0.99])
        df[col] = df[col].clip(lower, upper)
    # Winsorizing Age can lower its maximum; recheck the tenure constraint.
    enforce_bounds(df)

    df = df.drop_duplicates()
    df = pd.get_dummies(df, columns=["Geography", "Gender"],
                        drop_first=True, dtype="int8")
    return df.reset_index(drop=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "input", 
        nargs="?", 
        default="/Users/shekhar/Desktop/Bank Project/Customer_Churn_Records.csv"
    )
    parser.add_argument(
        "output", 
        nargs="?", 
        default="/Users/shekhar/Desktop/Bank Project/Customer_Churn_Records-cleaned.csv"
    )
    args = parser.parse_args()
    original = pd.read_csv(args.input)
    cleaned = clean_bank_churn(original)
    cleaned.to_csv(Path(args.output), index=False)
    print(f"Rows: {len(original):,} -> {len(cleaned):,}")
    print(f"Saved cleaned data to {args.output}")


if __name__ == "__main__":
    main()

print(df.head())


