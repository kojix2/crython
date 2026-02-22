require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "whitegrid", palette: "muted")

  # Load the penguins dataset
  df = sns.load_dataset("penguins")

  # Draw a categorical scatterplot to show each observation
  ax = sns.swarmplot(data: df, x: "body_mass_g", y: "sex", hue: "species")
  ax.set(ylabel: "")

  plt.show
end
