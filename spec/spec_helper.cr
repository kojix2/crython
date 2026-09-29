require "spec"
require "complex"
require "../src/crython"
require "../src/crython/*"

def with_crython(&) : Nil
  Crython.init
  yield
end
