require "../src/crython"

Crython.embed_python do
  sns = Crython.import_module("seaborn")
  ticks = LibPython.build_value("s", "ticks")
  sns.set_theme(style: ticks)

  penguins = LibPython.build_value("s", "penguins")
  df = sns.load_dataset(penguins)
  species = LibPython.build_value("s", "species")
  plot = sns.pairplot(df, hue: species)

  plt = Crython.import_module("matplotlib.pyplot")
  plt.show
end

