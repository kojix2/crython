# Crython

[![test](https://github.com/kojix2/crython/actions/workflows/test.yml/badge.svg)](https://github.com/kojix2/crython/actions/workflows/test.yml)

💎 🐍
Crystal meets Python!

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
Crython.embed_python do
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

## Contributing

Fork ➔ Edit ➔ Commit ➔ Pull Request

## LICENSE

[MIT](LICENSE)

[Romain Franceschini](https://github.com/RomainFranceschini) - The original creator of the Crython project
