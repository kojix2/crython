require "../../src/crython"

# Example: Creating a bar plot using Seaborn and Matplotlib
Crython.session do
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "whitegrid")

  # Initialize the matplotlib figure
  f, ax = plt.subplots(figsize: {6, 15})

  # Load the example car crash dataset
  crashes = sns.load_dataset("car_crashes").sort_values("total", ascending: false)

  # Plot the total crashes
  sns.set_color_codes("pastel")
  sns.barplot(x: "total", y: "abbrev", data: crashes,
    label: "Total", color: "b")

  # Plot the crashes where alcohol was involved
  sns.set_color_codes("muted")
  sns.barplot(x: "alcohol", y: "abbrev", data: crashes,
    label: "Alcohol-involved", color: "b")

  # Add a legend and informative axis label
  ax.legend(ncol: 2, loc: "lower right", frameon: true)
  ax.set(xlim: {0, 24}, ylabel: "",
    xlabel: "Automobile collisions per billion miles")
  sns.despine(left: true, bottom: true)

  plt.show
end
