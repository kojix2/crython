require "../src/crython"

Crython.embed_python do
  Crython.eval("print('Hello, World!')")
end
