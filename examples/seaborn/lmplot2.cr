require "../../src/crython"

Crython.embed_python do
  sns = Crython.import("seaborn")

  sns.set_theme(style: "darkgrid")

  # Load the example Titanic dataset
  df = sns.load_dataset("titanic")

  # Make a custom palette with gendered colors
  pal = {"male" => "#6495ED", "female" => "#F08080"}

  # Show the survival probability as a function of age and sex
  g = sns.lmplot(x: "age", y: "survived", col: "sex", hue: "sex", data: df,
                 palette: pal, y_jitter: 0.02, logistic: true, truncate: false)
  g.set(xlim: {0, 80}, ylim: {-0.05, 1.05})

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
