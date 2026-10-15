import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

OUTPUT_DIR = Path(__file__).resolve().parent.parent / "figures"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Aggregated results from BigQuery analysis.
# These values are observed results, not simulated data.

segments = ["Low", "Medium", "High", "Core"]

user_counts = [81872, 40197, 24253, 16219]
rating_counts = [3190713, 4371622, 5761534, 11676226]

# Figure 1: User share vs rating contribution
df = pd.DataFrame({
    "segment": segments,
    "users": user_counts,
    "ratings": rating_counts
})

df["user_pct"] = df["users"] / df["users"].sum() * 100
df["rating_pct"] = df["ratings"] / df["ratings"].sum() * 100

fig, ax = plt.subplots(figsize=(9, 5.5))
x = range(len(df))
width = 0.35

b1 = ax.bar(
    [i - width / 2 for i in x],
    df["user_pct"],
    width,
    label="Share of Users",
    color="#94A3B8"
)
b2 = ax.bar(
    [i + width / 2 for i in x],
    df["rating_pct"],
    width,
    label="Share of Ratings",
    color="#2563EB"
)

ax.bar_label(b1, fmt="%.1f%%", padding=3)
ax.bar_label(b2, fmt="%.1f%%", padding=3)
ax.set_xticks(list(x))
ax.set_xticklabels(segments)
ax.set_ylabel("Percentage (%)")
ax.set_ylim(0, 60)
ax.set_title("User Segments vs. Rating Contributions")
ax.legend(frameon=False)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
plt.tight_layout()
plt.savefig(OUTPUT_DIR / "user_segment_contribution.png", dpi=300)
plt.close()

# Figure 2: Rating distribution by segment
low = [12.96, 13.06, 15.44, 22.26]
medium = [27.48, 28.49, 30.44, 35.95]
high = [59.56, 58.45, 54.12, 41.79]

fig, ax = plt.subplots(figsize=(9, 5.5))
b_low = ax.bar(segments, low, label="Low (<3)", color="#F59E0B")
b_med = ax.bar(
    segments, medium, bottom=low,
    label="Medium (3–3.5)", color="#94A3B8"
)
b_high = ax.bar(
    segments, high,
    bottom=[a + b for a, b in zip(low, medium)],
    label="High (≥4)", color="#2563EB"
)

for bars in [b_low, b_med, b_high]:
    ax.bar_label(
        bars, label_type="center",
        fmt="%.1f%%", color="white"
    )

ax.set_ylim(0, 100)
ax.set_ylabel("Share of Ratings (%)")
ax.set_title("Rating Distribution by User Activity Segment")
ax.legend(
    loc="upper center",
    bbox_to_anchor=(0.5, -0.10),
    ncol=3,
    frameon=False
)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
plt.tight_layout()
plt.savefig(
    OUTPUT_DIR / "rating_distribution_by_segment.png",
    dpi=300, bbox_inches="tight"
)
plt.close()

# Figure 3: Within-movie comparison
categories = [
    "Core users rated lower",
    "Core users rated higher"
]
values = [92.29, 7.71]

fig, ax = plt.subplots(figsize=(9, 3.8))
bars = ax.barh(
    categories, values,
    color=["#2563EB", "#CBD5E1"],
    height=0.48
)

for bar, value in zip(bars, values):
    ax.text(
        value + 1,
        bar.get_y() + bar.get_height() / 2,
        f"{value:.2f}%",
        va="center"
    )

ax.invert_yaxis()
ax.set_xlim(0, 110)
ax.set_xlabel("Share of Comparable Movies (%)")
ax.set_title("Within-Movie Rating Differences")
ax.text(
    0.5, -0.38,
    "5,761 comparable movies; mean difference: -0.331 stars",
    transform=ax.transAxes,
    ha="center", fontsize=10
)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.spines["left"].set_visible(False)
plt.tight_layout()
plt.savefig(
    OUTPUT_DIR / "within_movie_rating_comparison.png",
    dpi=300, bbox_inches="tight"
)
plt.close()

print("All three figures generated successfully.")
