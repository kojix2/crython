require "../../src/crython"

Crython.embed_python do
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "ticks")

  # Load the penguins dataset
  penguins = sns.load_dataset("penguins")

  # Show the joint distribution using kernel density estimation
  g = sns.jointplot(
    data: penguins,
    x: "bill_length_mm", y: "bill_depth_mm", hue: "species",
    kind: "kde",
  )

  plt.show
end
