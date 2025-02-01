require "../src/crython"
require "../src/crython/string"

Crython.embed_python do
  sns = Crython.import_module("seaborn")
  sns.set_theme(style: "ticks")

  df = sns.load_dataset("penguins")
  plot = sns.pairplot(df, hue: "species")

  plt = Crython.import_module("matplotlib.pyplot")
  plt.show
end
