require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "ticks")

  df = sns.load_dataset("penguins")
  plot = sns.pairplot(df, hue: "species")

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
