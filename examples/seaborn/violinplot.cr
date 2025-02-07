require "../../src/crython"

# Example: Creating a violin plot using Seaborn
Crython.session do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "dark")

  # Load the example tips dataset
  tips = sns.load_dataset("tips")

  # Draw a nested violinplot and split the violins for easier comparison
  sns.violinplot(data: tips, x: "day", y: "total_bill", hue: "smoker",
    split: true, inner: "quart", fill: false,
    palette: {"Yes" => "g", "No" => ".35"})

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
