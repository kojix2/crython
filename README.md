# Crython

[![test](https://github.com/kojix2/crython/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/crython/actions/workflows/test.yml)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/kojix2/crython)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fcrython%2Flines)](https://tokei.kojix2.net/github/kojix2/crython)

💎 🐍
Crystal meets Python!

## Overview

Crython is a tool that lets you use [Python](https://github.com/python/cpython) libraries in [Crystal](https://github.com/crystal-lang/crystal), a programming language. It provides seamless integration between Crystal and Python, allowing you to leverage Python's rich ecosystem while enjoying Crystal's performance and type safety.

## Features

- Import and use Python modules directly from Crystal
- Convert between Crystal and Python data types
- Embed Python code within Crystal applications
- Call Python functions with Crystal arguments
- Access Python object attributes and methods
- Handle Python exceptions in Crystal
- Support for complex data structures (arrays, hashes, etc.)

## Installation

- You need Python3. Python3.12 or later is recommended.
- Make sure `python3-config --ldflags` works.

Add this to your dependencies:

```yaml
dependencies:
  crython:
    github: kojix2/crython
```

## Environment Setup

To find Python libraries, set the `LD_LIBRARY_PATH`:

```bash
export LD_LIBRARY_PATH=$(python3 -c \
"import sysconfig; print(sysconfig.get_config_var('LIBDIR'))"):$LD_LIBRARY_PATH
```

This command adds the Python library directory to `LD_LIBRARY_PATH`.

To use Crython in your Crystal project, add this line:

```crystal
require "crython"
```

For complex numbers, also add:

```crystal
require "complex"
```

## Basic Usage

### Importing a Python Module

```crystal
# Import a Python module
np = Crython.import("numpy")

# Use the module
array = np.array([1, 2, 3])
result = array * 2
puts result  # [2 4 6]
```

### Embedding Python Code

```crystal
Crython.session do
  # Write your Python code here
  Crython.eval("print('Hello from Python!')")

  # Import modules and use them
  np = Crython.import("numpy")
  array = np.array([1, 2, 3])
  puts array
end
```

### Type Conversion

#### Crystal to Python

Convert Crystal objects to Python objects using the `to_py` method:

```crystal
42.to_py                # Python int
3.14.to_py              # Python float
"hello".to_py           # Python str
[1, 2, 3].to_py         # Python list
{"a" => 1, "b" => 2}.to_py  # Python dict
true.to_py              # Python bool
nil.to_py               # Python None
Complex.new(1, 2).to_py # Python complex
```

#### Python to Crystal

Convert Python objects to Crystal objects using the `to_cr` method:

```crystal
py_int = 42.to_py
py_int.to_cr  # Crystal Int64: 42

py_float = 3.14.to_py
py_float.to_cr  # Crystal Float64: 3.14

py_str = "hello".to_py
py_str.to_cr  # Crystal String: "hello"

py_list = [1, 2, 3].to_py
py_list.to_cr  # Crystal Array(PyObject)

py_dict = {"a" => 1, "b" => 2}.to_py
py_dict.to_cr  # Crystal Hash(PyObject, PyObject)

py_bool = true.to_py
py_bool.to_cr  # Crystal Bool: true

py_none = nil.to_py
py_none.to_cr  # Crystal Nil: nil

py_complex = Complex.new(1, 2).to_py
py_complex.to_cr  # Crystal Complex: 1+2i
```

You can also convert Python objects to specific Crystal types:

```crystal
py_list = [1, 2, 3].to_py
Array(Int32).new(py_list)  # Crystal Array(Int32): [1, 2, 3]

py_dict = {"a" => 1, "b" => 2}.to_py
Hash(String, Int32).new(py_dict)  # Crystal Hash(String, Int32): {"a" => 1, "b" => 2}
```

### Working with Python Objects

```crystal
# Call methods on Python objects
py_str = "hello".to_py
py_str.upper.to_cr  # "HELLO"

# Access attributes
np = Crython.import("numpy")
version = np.attr("__version__").to_cr
puts "NumPy version: #{version}"

# Call methods with arguments
math = Crython.import("math")
result = math.pow(2, 3).to_cr
puts "2^3 = #{result}"  # 8.0

# Call methods with keyword arguments
plt = Crython.import("matplotlib.pyplot")
plt.plot([1, 2, 3], [4, 5, 6], color: "red", marker: "o")
```

## Advanced Usage

### Tips

- Use `call("Abc")` to call a function that starts with a capital letter.
- Use `call("Abc", args)` to call a function with arguments.
- Use `"-".to_py.attr("join")` to get a function attribute.
- Use `Crython.slice_full` instead of `:`.

### Error Handling

```crystal
Crython.session do
  begin
    # This will raise an error
    Crython.eval("1/0")
  rescue ex
    puts "Python error: #{ex.message}"
  end
end
```

## Examples

For more examples, check the [examples](examples) folder. To build all examples, use:

```
make examples
```

Then run:

```
./bin/hello
```

### NumPy Example

```crystal
Crython.session do
  np = Crython.import("numpy")

  x1 = np.array([1, 2, 3])
  x2 = np.array([4, 5, 6])

  y = x1 + x2
  puts "#{x1} + #{x2} = #{y}"  # [1 2 3] + [4 5 6] = [5 7 9]
end
```

### Matplotlib Example

```crystal
Crython.session do
  plt = Crython.import("matplotlib.pyplot")

  # Create data
  x = [1, 2, 3, 4, 5]
  y = [1, 4, 9, 16, 25]

  # Create plot
  plt.plot(x, y, marker: "o", linestyle: "--")
  plt.title("Square Numbers")
  plt.xlabel("Number")
  plt.ylabel("Square")

  # Show plot
  plt.show
end
```

## Known Limitations

- Symbol conversion: Crystal cannot create Symbols at runtime, so Python strings cannot be converted to Crystal Symbols.
- Union types: Converting Python collections with mixed types to Crystal collections with union types is not fully supported.
- Performance: There is some overhead in type conversion between Crystal and Python.

## Building Examples with Custom Python Library

`python3-config` usually provides the correct flags for linking. If it doesn't, you can manually set `LDFLAGS` to your environment's library path. For example, if using micromamba:

```bash
LDFLAGS="-L/Users/<your-username>/micromamba/envs/crython/lib -lpython3.13" make examples
```

Replace `<your-username>` with your actual username and adjust the path as necessary.

## Troubleshooting

### Library Not Found

If you get an error like `error while loading shared libraries: libpython3.13.so.1.0: cannot open shared object file: No such file or directory`, make sure you've set the `LD_LIBRARY_PATH` correctly:

```bash
export LD_LIBRARY_PATH=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))"):$LD_LIBRARY_PATH
```

### Linking Errors

If you encounter linking errors during compilation, check that `python3-config --ldflags` returns the correct flags for your Python installation.

## Contributing

Fork ➔ Edit ➔ Commit ➔ Pull Request

## LICENSE

[MIT](LICENSE)

## Credits

[Romain Franceschini](https://github.com/RomainFranceschini) - The original creator of the Crython project
