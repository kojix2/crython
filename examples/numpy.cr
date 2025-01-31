require "../src/crython"
require "../src/crython/array"
require "../src/crython/number"

Crython.embed_python do
  np = Crython.import_module("numpy")

  x1 = np.array([1, 2, 3].to_py)
  x2 = np.array([4, 5, 6].to_py)

  y = x1 + x2
  print x1, " + ", x2, " = ", y
end
