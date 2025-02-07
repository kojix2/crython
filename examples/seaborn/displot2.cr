require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")

  sns.set_theme(style: "whitegrid")

  # Load the diamond dataset
  diamonds = sns.load_dataset("diamonds")

  # Plot the distribution of clarity ratings, conditional on carat
  sns.displot(
    data: diamonds,
    x: "carat", hue: "cut",
    kind: "kde", height: 6,
    multiple: "fill", clip: {0, nil},
    palette: "ch:rot=-.25,hue=1,light=.75"
  )

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
