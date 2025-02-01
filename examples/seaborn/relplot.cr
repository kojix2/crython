require "../../src/crython"

# Example: Creating a relational plot using Seaborn
Crython.embed_python do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "ticks")

  dots = sns.load_dataset("dots")

  # Define the palette as a list to specify exact values
  palette = sns.color_palette("rocket_r")

  # Plot the lines on two facets
  sns.relplot(
    data: dots,
    x: "time", y: "firing_rate",
    hue: "coherence", size: "choice", col: "align",
    kind: "line", size_order: ["T1", "T2"], palette: palette,
    height: 5, aspect: 0.75, facet_kws: {"sharex" => false},
  )
  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
