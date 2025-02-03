release ?= ## Compile in release mode
stats ?=   ## Enable statistics output
threads ?= ## Maximum number of threads to use
debug ?=   ## Add symbolic debug info
no-debug ?= ## No symbolic debug info
verbose ?= ## Run specs in verbose mode
link-flags ?= ## Additional flags to pass to the linker

OS := $(LC_CTYPE=C $(shell uname -s | tr '[:upper:]' '[:lower:]'))

O := bin
FLAGS := $(if $(release),--release) \
         $(if $(stats),--stats) \
         $(if $(threads),--threads $(threads)) \
         $(if $(debug),-d) \
         $(if $(no-debug),--no-debug)
VERBOSE := $(if $(verbose),-v )

#CFLAGS += -fPIC
CFLAGS += $(if $(debug),-g -O0)
CFLAGS += $(if $(release),-O2)

EXAMPLES_SOURCES := $(shell find examples -type f -name '*.cr')
EXAMPLES_TARGETS := $(patsubst examples/%.cr, $(O)/%, $(EXAMPLES_SOURCES))

PYTHON_CFLAGS := $(shell python3-config --cflags)
PYTHON_LDFLAGS := $(shell python3-config --ldflags)

PYTHON_VERSION := $(shell python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PYTHON_LIB := -lpython$(PYTHON_VERSION)

CFLAGS += $(PYTHON_CFLAGS)
LDFLAGS += $(PYTHON_LDFLAGS) $(PYTHON_LIB)

.PHONY: all deps test examples doc clean help

help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: deps

deps: ## Build dependencies

$(EXAMPLES_TARGETS): $(O)/%: examples/%.cr
	@mkdir -p $(dir $@)
	$(BUILD_PATH) crystal build $(FLAGS) $< --link-flags "$(LDFLAGS)" -o $@ --error-trace

test: deps ## Run tests
	$(BUILD_PATH) crystal spec $(VERBOSE) --link-flags "$(LDFLAGS)"

examples: $(DEPS) $(EXAMPLES_TARGETS) ## Build all examples

doc: deps ## Generate crython library documentation
	@echo "Building documentation..."
	$(BUILD_PATH) crystal doc src/crython.cr

clean: ## Clean up built directories and files
	@echo "Cleaning..."
	rm -rf $(O)
	rm -rf ./doc
	rm -rf $(EXAMPLES_TARGETS)
