require "../../src/crython"

# Example: Creating a categorical plot using Seaborn
Crython.session do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "whitegrid")

  penguins = sns.load_dataset("penguins")

  # Draw a nested barplot by species and sex
  g = sns.catplot(
    data: penguins, kind: "bar",
    x: "species", y: "body_mass_g", hue: "sex",
    errorbar: "sd", palette: "dark", alpha: 0.6, height: 6
  )
  g.despine(left: true)
  g.set_axis_labels("", "Body mass (g)")
  g.legend.set_title("aa")

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
