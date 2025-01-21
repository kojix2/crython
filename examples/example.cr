require "../src/crython"

Crython.embed_python do
  mod = Crython.import_module("os")
  result = mod.getcwd
  puts result
end
