require "../../src/crython"

Crython.session do
  np = Crython.import("numpy")
  pd = Crython.import("pandas")
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "white")

  # Generate a large random dataset
  rs = np.random.call("RandomState", 33)
  d = pd.call("DataFrame", data: rs.normal(size: {100, 26}),
    columns: ('A'..'Z').to_a)

  # Compute the correlation matrix
  corr = d.corr

  # Generate a mask for the upper triangle
  mask = np.triu(np.ones_like(corr, dtype: "bool"))

  # Set up the matplotlib figure
  f, ax = plt.subplots(figsize: [11, 9])

  # Generate a custom diverging colormap
  cmap = sns.diverging_palette(230, 20, as_cmap: true)

  # Draw the heatmap with the mask and correct aspect ratio
  sns.heatmap(corr, mask: mask, cmap: cmap, vmax: 0.3, center: 0,
    square: true, linewidths: 0.5, cbar_kws: {"shrink" => 0.5})

  plt.show
end
