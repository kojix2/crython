require "../../src/crython"

# Example: Creating a box plot using Seaborn
Crython.session do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "ticks", palette: "pastel")

  # Load the example tips dataset
  tips = sns.load_dataset("tips")

  # Draw a nested boxplot to show bills by day and time
  sns.boxplot(x: "day", y: "total_bill",
    hue: "smoker", palette: ["m", "g"],
    data: tips)
  sns.despine(offset: 10, trim: true)

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
