# crython 　

[![test](https://github.com/kojix2/crython/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/crython/actions/workflows/test.yml)

:gem: :snake:　
Crystal meets Python!

## Overview

Crython allows the use of Python libraries within Crystal applications.

## Installation

- A Python3 interpreter is required as a dependency.
- Ensure `python3-config --ldflags` works.

```yaml
dependencies:
  crython:
    github: kojix2/crython
```

## Environment Setup

Set the `LD_LIBRARY_PATH` to include Python's library directory to ensure shared libraries are found:

```bash
export LD_LIBRARY_PATH=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))"):$LD_LIBRARY_PATH
```

This command appends the Python library directory to the existing `LD_LIBRARY_PATH`.

To use Crython in your Crystal project, simply require the library:

```crystal
require "crython"
```

## Usage

#### Importing a Python Module

```crystal
mod = Crython.import("math")
```

#### Embedding Python Code

```crystal
Crython.embed_python do
  # Your Python code here
end
```

For more examples, see the [examples](examples) folder. Use `make examples` to build all examples.

```
make examples
```

```
./bin/hello
```
#### Workarounds

- Use `call("Abc")` to call a function that starts with a capital letter.
- Use `call("Abc", args)` to call a function with arguments.
- Use `"-".to_py.get_attr("join")` to get a function attribute.

## Development

Some constants and functions in Python's C API are provided as preprocessor macros.
To make them easier to use, Crython uses a small static library (see src/ext/crython.c) that turns them into a fixed C API.

## Contributing

Fork ➔ Edit ➔ Commmit ➔ Pull Request

## LICENSE

[MIT](LICENSE)

[Romain Franceschini](https://github.com/RomainFranceschini) - The original creator of the crython project
