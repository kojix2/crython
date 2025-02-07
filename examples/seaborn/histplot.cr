require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")
  mpl = Crython.import("matplotlib")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "ticks")

  diamonds = sns.load_dataset("diamonds")

  f, ax = plt.subplots(figsize: [7, 5])
  sns.despine(f)

  sns.histplot(
    diamonds,
    x: "price", hue: "cut",
    multiple: "stack",
    palette: "light:m_r",
    edgecolor: ".3",
    linewidth: 0.5,
    log_scale: true,
  )
  ax.xaxis.set_major_formatter(mpl.ticker.call("ScalarFormatter"))
  ax.set_xticks([500, 1000, 2000, 5000, 10000])

  plt.show
end
