require "../src/crython"

# Example 1: Using the Python 'os' module to get the current working directory
Crython.init
  mod = Crython.import("os")
  result = mod.getcwd
  puts "Current Working Directory: #{result}"

# Example 2: Using the Python 'math' module to calculate the square root
Crython.init
  mod = Crython.import("math")
  result = mod.sqrt(16.0)
  puts "Square root of 16 is: #{result}"
