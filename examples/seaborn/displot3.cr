require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "ticks")
  mpg = sns.load_dataset("mpg")

  colors = [{250, 70, 50}, {350, 70, 50}]
  cmap = sns.blend_palette(colors, input: "husl", as_cmap: true)

  sns.displot(
    mpg,
    x: "displacement", col: "origin", hue: "model_year",
    kind: "ecdf", aspect: 0.75, linewidth: 2, palette: cmap
  )

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
