#!/usr/bin/env python3
import sys
import pandas as pd
from pdb import set_trace
import matplotlib.pyplot as plt

if __name__ == "__main__":
    head = []
    body = []
    for i, line in enumerate(sys.stdin):
        if i == 3:
            head = line.rstrip().split(", ")
        elif i > 3:
            content = line.rstrip().split(", ")
            body.append([float(c) for c in content])

    df = pd.DataFrame(body, columns=head)
    df = df.loc[:, ~df.columns.duplicated()]

    relevant = df[['?t', '<np', '<ep']]
    print(relevant)
    median = relevant.mean()
    twenty5th = relevant.quantile(0.45)
    seventy5th = relevant.quantile(0.55)
    iqr = seventy5th - twenty5th
    fig, ax = plt.subplots()
    median.plot.bar(yerr=iqr, ax=ax, capsize=4, fontsize=15)
    plt.show()
