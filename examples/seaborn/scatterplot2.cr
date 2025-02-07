require "../../src/crython"

Crython.session do
  np = Crython.import("numpy")
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "dark")

  # Simulate data from a bivariate Gaussian
  n = 10000
  mean = [0, 0]
  cov = [[2, 0.4], [0.4, 0.2]]
  rng = np.random.call("RandomState", 0)
  x, y = rng.multivariate_normal(mean, cov, n).call("T")

  # Draw a combo histogram and scatterplot with density contours
  f, ax = plt.subplots(figsize: [6, 6])
  sns.scatterplot(x: x, y: y, s: 5, color: ".15")
  sns.histplot(x: x, y: y, bins: 50, pthresh: 0.1, cmap: "mako")
  sns.kdeplot(x: x, y: y, levels: 5, color: "w", linewidths: 1)

  plt.show
end
