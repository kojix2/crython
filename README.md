# crython　

[![test](https://github.com/kojix2/crython/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/crython/actions/workflows/test.yml)

:gem: :snake:　
Crystal meets Python!

## Installation

- A Python interpreter is required as a dependency.
- Ensure `python3-config --ldflags` works.

```yaml
dependencies:
  crython:
    github: kojix2/crython
```

## Usage

```crystal
require "crython"
```

See [examples](examples) folder.
Use `make examples` to build all examples.

## Development

Some constants and functions in Python's C API are provided as preprocessor macros. 
To make them easier to use, Crython uses a small static library (see src/ext/crython.c) that turns them into a fixed C API.

## Contributing

Fork ➔ Edit ➔ Commmit ➔ Pull Request

## LICENSE

[MIT](LICENSE)

[Romain Franceschini](https://github.com/RomainFranceschini) - The original creator of the crython project
