require "../../src/crython"

# Example: Creating a line plot using Seaborn
Crython.session do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "darkgrid")

  # Load an example dataset with long-form data
  fmri = sns.load_dataset("fmri")

  # Plot the responses for different events and regions
  sns.lineplot(x: "timepoint", y: "signal",
    hue: "region", style: "event",
    data: fmri)
  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
