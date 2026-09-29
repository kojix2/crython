require "../../src/crython"

Crython.init
np = Crython.import("numpy")
a = np.array([[1, 2, 3],
              [4, 5, 6]])
puts a
puts a.shape

a[0][0] = 100
puts a
