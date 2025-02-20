require "../../src/crython"

# Example: Creating a pair grid plot using Seaborn and Matplotlib
Crython.session do
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")
  sns.set_theme(style: "whitegrid")

  # Load the example Titanic dataset
  titanic = sns.load_dataset("titanic")

  # Set up a grid to plot survival probability against several variables
  g = sns.call("PairGrid", titanic, y_vars: "survived",
    x_vars: ["class", "sex", "who", "alone"],
    height: 5, aspect: 0.5)

  # Draw a seaborn pointplot onto each Axes
  g.map(sns.attr("pointplot"), color: "xkcd:plum")
  g.set(ylim: {0, 1})
  sns.despine(fig: g.fig, left: true)
  plt.show
end
