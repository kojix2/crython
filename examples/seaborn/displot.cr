require "../../src/crython"

# Example: Creating a distribution plot using Seaborn
Crython.embed_python do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "darkgrid")

  df = sns.load_dataset("penguins")

  sns.displot(
    df, x: "flipper_length_mm", col: "species", row: "sex",
    binwidth: 3, height: 3, facet_kws: {margin_titles: true},
  )
  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
