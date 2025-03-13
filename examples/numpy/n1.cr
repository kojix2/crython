require "../../src/crython"

Crython.session do
  np = Crython.import("numpy")
  a = np.array([[1, 2, 3],
                [4, 5, 6]])
  p a
  p a.shape

  a[0][0] = 100
  p a
end
