require "../../src/crython"

# Example: Creating a boxen plot using Seaborn
Crython.session do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "whitegrid")

  # Load the example diamonds dataset
  diamonds = sns.load_dataset("diamonds")
  clarity_ranking = ["I1", "SI2", "SI1", "VS2", "VS1", "VVS2", "VVS1", "IF"]

  # Draw a boxen plot
  sns.boxenplot(
    x: "clarity", y: "carat",
    data: diamonds, color: "b",
    order: clarity_ranking, width_method: "linear"
  )

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
