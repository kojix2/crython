# crython 　

[![test](https://github.com/kojix2/crython/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/crython/actions/workflows/test.yml)

:gem: :snake:　
Crystal meets Python!

## Overview

Crython allows the use of Python libraries within Crystal applications.

## Installation

- A Python interpreter is required as a dependency.
- Ensure `python3-config --ldflags` works.

```yaml
dependencies:
  crython:
    github: kojix2/crython
```

### Prerequisites

- Python 3.x installed on your system.
- Ensure that the `python3-config` command is available and correctly configured.

### Troubleshooting

- If you encounter issues with `python3-config`, ensure that the Python development headers are installed on your system.

## Usage

To use Crython in your Crystal project, simply require the library:

```crystal
require "crython"
```

### Examples

Crython allows you to import and use Python modules directly in Crystal. Here are some basic examples:

#### Importing a Python Module

```crystal
mod = Crython.import_module("math")
```

#### Embedding Python Code

```crystal
Crython.embed_python do
  # Your Python code here
end
```

For more examples, see the [examples](examples) folder. Use `make examples` to build all examples.

## Development

Some constants and functions in Python's C API are provided as preprocessor macros.
To make them easier to use, Crython uses a small static library (see src/ext/crython.c) that turns them into a fixed C API.

## Contributing

Fork ➔ Edit ➔ Commmit ➔ Pull Request

## LICENSE

[MIT](LICENSE)

[Romain Franceschini](https://github.com/RomainFranceschini) - The original creator of the crython project
