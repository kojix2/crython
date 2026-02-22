require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "whitegrid")

  # Load the example exercise dataset
  exercise = sns.load_dataset("exercise")

  # Draw a pointplot to show pulse as a function of three categorical factors
  g = sns.catplot(
    data: exercise, x: "time", y: "pulse", hue: "kind", col: "diet",
    capsize: 0.2, palette: "YlGnBu_d", errorbar: "se",
    kind: "point", height: 6, aspect: 0.75,
  )
  g.despine(left: true)

  plt.show
end
