require "../../src/crython"

Crython.session do
  np = Crython.import("numpy")
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "white", context: "talk")
  rs = np.random.call("RandomState", 8)

  # Set up the matplotlib figure
  f, ax = plt.subplots(3, 1, figsize: [7, 5], sharex: true)
  ax1, ax2, ax3 = ax

  # Generate some sequential data
  x = np.array("ABCDEFGHIJ".chars)
  y1 = np.arange(1, 11)
  sns.barplot(x: x, y: y1, hue: x, palette: "rocket", ax: ax1)
  ax1.axhline(0, color: "k", clip_on: false)
  ax1.set_ylabel("Sequential")

  # Center the data to make it diverging
  y2 = y1 - 5.5
  sns.barplot(x: x, y: y2, hue: x, palette: "vlag", ax: ax2)
  ax2.axhline(0, color: "k", clip_on: false)
  ax2.set_ylabel("Diverging")

  # Randomly reorder the data to make it qualitative
  y3 = rs.choice(y1, y1.size, replace: false)
  sns.barplot(x: x, y: y3, hue: x, palette: "deep", ax: ax3)
  ax3.axhline(0, color: "k", clip_on: false)
  ax3.set_ylabel("Qualitative")

  # Finalize the plot
  sns.despine(bottom: true)
  plt.setp(f.axes, yticks: [] of Int32)
  plt.tight_layout(h_pad: 2)

  plt.show
end
