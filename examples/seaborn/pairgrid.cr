require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")

  df = sns.load_dataset("penguins")

  g = sns.call("PairGrid", df, diag_sharey: false)
  g.map_upper(sns.attr("scatterplot"), s: 15)
  g.map_lower(sns.attr("kdeplot"))
  g.map_diag(sns.attr("kdeplot"), lw: 2)

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
