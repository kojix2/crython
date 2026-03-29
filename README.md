# Crython

[![test](https://github.com/kojix2/crython/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/crython/actions/workflows/test.yml)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/kojix2/crython)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fcrython%2Flines)](https://tokei.kojix2.net/github/kojix2/crython)

💎 🐍
Crystal meets Python!

## Overview

Crython is a tool that lets you use [Python](https://github.com/python/cpython) libraries in [Crystal](https://github.com/crystal-lang/crystal), a programming language. It provides seamless integration between Crystal and Python, allowing you to leverage Python's ecosystem while enjoying Crystal language.

## Installation

- You need Python3. Python3.14 or later is recommended.
- Make sure `python3-config --ldflags` works.

Add this to your dependencies:

```yaml
dependencies:
  crython:
    github: kojix2/crython
```

## Quick Start (Downstream Project)

Use this when integrating Crython into your own Crystal app (not this repository).

1. Verify your Python toolchain:

```bash
python3-config --ldflags
```

2. Create your minimal app:

```cr
require "crython"

Crython.session do
  Crython.exec("x = 40 + 2")
  puts Crython.eval("x").to_cr  # 42
end
```

3. Install dependencies and build:

```bash
shards install
ver=$(python3 -c 'import sys; print("{}.{}".format(sys.version_info.major, sys.version_info.minor))')
crystal build src/main.cr -o app \
  --link-flags "$(python3-config --ldflags) -lpython$ver -lm"
```

4. Run your app (set runtime library path if needed):

```bash
export LD_LIBRARY_PATH=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))"):$LD_LIBRARY_PATH
./app
```

If this fails, jump to [Troubleshooting](#troubleshooting).

## Environment Setup

Crython can be run either directly with Crystal commands or via `make`.

The `make` commands below are for this Crython repository itself (development, examples, tests), not for your downstream app.

- `make test` / `make run ...` are convenience shortcuts.
- They automatically apply Python linker flags and runtime library paths.
- Run `make doctor` to print detected Python and linker settings when troubleshooting build/runtime issues.

When running binaries directly (without `make`), set `LD_LIBRARY_PATH` manually:

```bash
export LD_LIBRARY_PATH=$(python3 -c \
"import sysconfig; print(sysconfig.get_config_var('LIBDIR'))"):$LD_LIBRARY_PATH
```

This command adds the Python library directory to `LD_LIBRARY_PATH`.

### Useful Environment Variables

- `CRYTHON_DEBUG=1`: Enables Crython debug logs.
- `LD_LIBRARY_PATH=...`: Python shared library search path (mainly needed for direct execution).
- `LDFLAGS=...`: Override link flags when your Python environment is non-standard.

To use Crython in your Crystal project, add this line:

```cr
require "crython"
```

For complex numbers, also add:

```cr
require "complex"
```

## Basic Usage

### Session Lifecycle

- Crython initializes the embedded Python runtime once and reuses it.
- `Crython.session` starts a logical Crython session but does not shut down Python at block end.
- `Crython.finalize` closes the logical Crython session state.
- Internal session identity uses session tokens.

### Importing a Python Module

Import a Python module

```cr
np = Crython.import("numpy")
```

Use the module

```cr
array = np.array([1, 2, 3])
result = array * 2
puts result  # [2 4 6]
```

### Embedding Python Code

```cr
Crython.session do
  # Execute Python statements
  Crython.exec("print('Hello from Python!')")

  # Multiple lines of Python statements
  Crython.exec(<<-PYTHON)
    print('Hello from Python!')
  PYTHON

  # Evaluate a Python expression and get a PyObject back
  value = Crython.eval("1 + 2")
  puts value.to_cr # 3

  # Import modules and use them
  np = Crython.import("numpy")
  array = np.array([1, 2, 3])
  puts array
end
```

If you need to end a logical Crython session explicitly:

```cr
Crython.finalize
```

### Type Conversion

#### Crystal to Python

Convert Crystal objects to Python objects using the `to_py` method:

```cr
42.to_py                    # Python int
3.14.to_py                  # Python float
"hello".to_py               # Python str
[1, 2, 3].to_py             # Python list
{"a" => 1, "b" => 2}.to_py  # Python dict
true.to_py                  # Python bool
nil.to_py                   # Python None
Complex.new(1, 2).to_py     # Python complex
```

#### Python to Crystal

Convert Python objects to Crystal objects using the `to_cr` method:

```cr
py_int = 42.to_py
py_int.to_cr                         # Int64: 42
```

```cr
py_float = 3.14.to_py
py_float.to_cr                       # Float64: 3.14
```

```cr
py_str = "hello".to_py
py_str.to_cr                         # String: "hello"
```

```cr
py_list = [1, 2, 3].to_py
py_list.to_cr                        # Array(PyObject)
```

```cr
py_dict = {"a" => 1, "b" => 2}.to_py
py_dict.to_cr                        # Hash(PyObject, PyObject)
```

```cr
py_bool = true.to_py
py_bool.to_cr                        # Bool: true
```

```cr
py_none = nil.to_py
py_none.to_cr                        # Nil: nil
```

```cr
py_complex = Complex.new(1, 2).to_py
py_complex.to_cr                     # Complex: 1+2i
```

You can also convert Python objects to specific Crystal types:

```cr
py_list = [1, 2, 3].to_py
Array(Int32).new(py_list)            # Array(Int32): [1, 2, 3]
```

```cr
py_dict = {"a" => 1, "b" => 2}.to_py
Hash(String, Int32).new(py_dict)     # Hash(String, Int32): {"a" => 1, "b" => 2}
```

### Working with Python Objects

Call methods on Python objects

```cr
py_str = "hello".to_py
py_str.upper.to_cr  # "HELLO"
```

Access attributes

```cr
np = Crython.import("numpy")
version = np.attr("__version__").to_cr
puts "NumPy version: #{version}"
```

Call methods with arguments

```cr
math = Crython.import("math")
result = math.pow(2, 3).to_cr
puts "2^3 = #{result}"  # 8.0
```

Call methods with keyword arguments

```cr
plt = Crython.import("matplotlib.pyplot")
plt.plot([1, 2, 3], [4, 5, 6], color: "red", marker: "o")
```

## Advanced Usage

### Tips

- Use `obj.call("Abc")` to call a Python attribute whose name is not a valid Crystal method name.
- Use `obj.call("Abc", arg1, arg2)` to call it with positional arguments.
- Prefer `call()` for uppercase Python attribute names such as class constructors: `collections.call("Counter", data)`.
- Keep `obj.method_name(...)` for simple lowercase methods like `math.sqrt(16.0)`.
- Use `"-".to_py.attr("join")` to get a function attribute.
- Use `Crython.slice_full` instead of `:`.
- Use `import?`, `attr?`, `call?` when you want `nil` instead of exceptions on failure.

```cr
math = Crython.import?("math")
pi = math.try &.attr?("pi")
pow = math.try &.call?("pow", 2, 3)

collections = Crython.import("collections")
counter = collections.call("Counter", [1, 2, 1, 3].to_py)
```

### Error Handling

`eval` and `exec` have different roles:

- `Crython.eval("...")`: evaluates a Python expression and returns a `PyObject`.
- `Crython.exec("...")`: executes Python statements and returns `Nil`.

If you pass statements to `eval`, Crython raises an error with guidance to use `exec`.

```cr
Crython.session do
  begin
    # Expression evaluation error
    Crython.eval("1/0")
  rescue ex
    puts "Python error: #{ex.message}"
  end
end
```

```cr
Crython.session do
  # Statement execution
  Crython.exec("x = 40 + 2")

  # Expression evaluation (returns PyObject)
  answer = Crython.eval("x")
  puts answer.to_cr  # 42
end
```

```cr
Crython.session do
  begin
    # This is a statement, so eval raises and suggests exec
    Crython.eval("x = 10")
  rescue ex
    puts ex.message
    # => ... Use Crython.exec for statements
  end
end
```

## Testing

You can run tests either directly or via `make`.

Direct execution (explicit link flags):

```bash
crystal spec --link-flags "$(python3-config --ldflags) -lpython$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")') -lm"
```

Or use `make` as a shortcut:

```bash
make test
```

Or with uv:

```bash
uv run make test
```

Enable Crython debug logs on demand:

```bash
make test CRYTHON_DEBUG=1
```

```bash
uv run make test CRYTHON_DEBUG=1
```

Direct `crystal spec` works as long as you pass proper Python link flags.

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

```cr
Crython.session do
  np = Crython.import("numpy")

  x1 = np.array([1, 2, 3])
  x2 = np.array([4, 5, 6])

  y = x1 + x2
  puts "#{x1} + #{x2} = #{y}"  # [1 2 3] + [4 5 6] = [5 7 9]
end
```

### Matplotlib Example

```cr
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

## Building Examples with Custom Python Library

`python3-config` usually provides the correct flags for linking. If it doesn't, you can manually set `LDFLAGS` to your environment's library path. For example, if using micromamba:

```bash
LDFLAGS="-L/Users/<your-username>/micromamba/envs/crython/lib -lpython3.14" make examples
```

Replace `<your-username>` with your actual username and adjust the path as necessary.

## Troubleshooting

### Library Not Found

If you get an error like `error while loading shared libraries: libpython3.x.so.1.0: cannot open shared object file: No such file or directory`, make sure you've set the `LD_LIBRARY_PATH` correctly:

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
