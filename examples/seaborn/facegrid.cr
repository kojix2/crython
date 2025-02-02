require "../../src/crython"

Crython.embed_python do
  np = Crython.import("numpy")
  pd = Crython.import("pandas")
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "ticks")

  # Create a dataset with many short random walks
  rs = np.random.call("RandomState", 4)
  pos = rs.randint(-1, 2, [20, 5]).cumsum(axis: 1)
  pos -= pos[Crython.slice_full, 0, np.newaxis]
  step = np.tile(np.arange(5), 20)
  walk = np.repeat(np.arange(20), 5)
  df = pd.call("DataFrame", np.c_[pos.flat, step, walk],
               columns: ["position", "step", "walk"])

  # Initialize a grid of plots with an Axes for each walk
  grid = sns.call("FacetGrid", df, col: "walk", hue: "walk", palette: "tab20c",
                  col_wrap: 4, height: 1.5)

  # Draw a horizontal line to show the starting point
  grid.refline(y: 0, linestyle: ":")

  # Draw a line plot to show the trajectory of each random walk
  grid.map(plt.get_attr("plot"), "step", "position", marker: "o")

  # Adjust the tick positions and labels
  grid.set(xticks: np.arange(5), yticks: [-3, 3],
           xlim: [-0.5, 4.5], ylim: [-3.5, 3.5])

  # Adjust the arrangement of the plots
  grid.fig.tight_layout(w_pad: 1)

  plt.show
end
