require "../../src/crython"

Crython.session do
  np = Crython.import("numpy")
  sns = Crython.import("seaborn")

  sns.set_theme(style: "ticks")

  rs = np.random.call("RandomState", 11)
  x = rs.gamma(2, size: 1000)
  c = rs.normal(size: 1000)
  y = -0.5 * x + c
  sns.jointplot(x: x, y: y, kind: "hex", color: "#4CB391")

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
