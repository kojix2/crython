require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")
  sns.set_theme

  seaice = sns.load_dataset("seaice")
  seaice["Decade"] = seaice["Date"].dt.year.round(-1)
  sns.violinplot(seaice,
    x: "Extent", y: "Decade",
    orient: "y", fill: false
  )

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
