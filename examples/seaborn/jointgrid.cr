require "../../src/crython"

Crython.embed_python do
  sns = Crython.import("seaborn")

  sns.set_theme(style: "white", color_codes: true)
  mpg = sns.load_dataset("mpg")

  # Use JointGrid directly to draw a custom plot
  g = sns.call("JointGrid", data: mpg, x: "mpg", y: "acceleration", space: 0, ratio: 17)
  g.plot_joint(sns.scatterplot, size: mpg["horsepower"], sizes: [30, 120],
               color: "g", alpha: 0.6, legend: false)
  g.plot_marginals(sns.rugplot, height: 1, color: "g", alpha: 0.6)

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
