require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme

  flights_long = sns.load_dataset("flights")
  flights = flights_long.pivot(index: "month", columns: "year", values: "passengers")

  f, ax = plt.subplots(figsize: [9, 6])
  sns.heatmap(flights, annot: true, fmt: "d", linewidths: 0.5, ax: ax)

  plt.show
end
