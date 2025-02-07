# Crython

[![test](https://github.com/kojix2/crython/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/crython/actions/workflows/test.yml)

💎 🐍
Crystal meets Python!

This tool is experimental. Please read ([Avoiding Double Free in Crython: Managing Shared Memory Between Crystal and Python #1](https://github.com/kojix2/crython/issues/1)) to see why.

## Overview

Crython is a tool that lets you use [Python](https://github.com/python/cpython) libraries in [Crystal](https://github.com/crystal-lang/crystal), a programming language.

## Installation

- You need Python3. Python is a popular programming language.
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

## Usage

#### Importing a Python Module

```crystal
mod = Crython.import("math")
```

#### Embedding Python Code

```crystal
Crython.session do
  # Write your Python code here
end
```

For more examples, check the [examples](examples) folder. To build all examples, use:

```
make examples
```

Then run:

```
./bin/hello
```

#### Tips

- Use `call("Abc")` to call a function that starts with a capital letter.
- Use `call("Abc", args)` to call a function with arguments.
- Use `"-".to_py.attr("join")` to get a function attribute.
- Use `Crython.slice_full` instead of `:`.

## Building Examples with Custom Python Library

`python3-config` usually provides the correct flags for linking. If it doesn't, you can manually set `LDFLAGS` to your environment's library path. For example, if using micromamba:

```bash
LDFLAGS="-L/Users/<your-username>/micromamba/envs/crython/lib -lpython3.13" make examples
```

Replace `<your-username>` with your actual username and adjust the path as necessary.

## Contributing

Fork ➔ Edit ➔ Commit ➔ Pull Request

## LICENSE

[MIT](LICENSE)

[Romain Franceschini](https://github.com/RomainFranceschini) - The original creator of the Crython project
