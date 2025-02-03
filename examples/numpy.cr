require "../src/crython"

Crython.embed_python do
  np = Crython.import("numpy")

  x1 = np.array([1, 2, 3])
  x2 = np.array([4, 5, 6])

  y = x1 + x2
  print "#{x1} + #{x2} = #{y}"
end
