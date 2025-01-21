require "../src/crython"

Crython.embed_python do
  np = Crython.import_module("numpy")

  arg1 = LibPython.build_value("[i,i,i]", 1, 2, 3)
  x1 = np.array(arg1)

  arg2 = LibPython.build_value("[i,i,i]", 4, 5, 6)
  x2 = np.array(arg2)

  y = np.add(x1, x2)
  print x1, " + ", x2, " = ", y
end
