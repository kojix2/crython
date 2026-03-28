release ?= ## Compile in release mode
stats ?=   ## Enable statistics output
threads ?= ## Maximum number of threads to use
debug ?=   ## Add symbolic debug info
no-debug ?= ## No symbolic debug info
verbose ?= ## Run specs in verbose mode
link-flags ?= ## Additional flags to pass to the linker
CRYTHON_DEBUG ?= 0 ## Set 1 to enable Crython debug logs
PYTHON ?= $(if $(VIRTUAL_ENV),$(VIRTUAL_ENV)/bin/python,python3) ## Python executable path
PYTHON := $(strip $(PYTHON))

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

PYTHON_CONFIG ?= $(shell command -v "$(PYTHON)-config" 2>/dev/null || command -v python3-config 2>/dev/null || echo "$(PYTHON)-config")
PYTHON_CFLAGS := $(shell $(PYTHON_CONFIG) --cflags)
PYTHON_LDFLAGS := $(shell $(PYTHON_CONFIG) --ldflags)
PYTHON_LIBDIR := $(shell $(PYTHON) -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR') or '')")
RUNTIME_LD_LIBRARY_PATH := $(if $(PYTHON_LIBDIR),LD_LIBRARY_PATH="$(PYTHON_LIBDIR):$${LD_LIBRARY_PATH}")
RUNTIME_CRYTHON_DEBUG := $(if $(filter 1,$(CRYTHON_DEBUG)),CRYTHON_DEBUG=1)
RUNTIME_ENV := $(strip $(RUNTIME_CRYTHON_DEBUG) $(RUNTIME_LD_LIBRARY_PATH))

EXAMPLE := $(or $(example),$(word 2,$(MAKECMDGOALS)))

ifneq ($(filter run,$(MAKECMDGOALS)),)
EXTRA_GOALS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(foreach goal,$(EXTRA_GOALS),$(eval $(goal):;@:))
endif

PYTHON_VERSION := $(shell $(PYTHON) -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PYTHON_LIB := -lpython$(PYTHON_VERSION)

CFLAGS += $(PYTHON_CFLAGS)
LDFLAGS += $(PYTHON_LDFLAGS) $(PYTHON_LIB) -lm

.PHONY: all deps test examples run doc clean help doctor

help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: deps

doctor: ## Show detected Python/linker/runtime settings
	@echo "PYTHON=$(PYTHON)"
	@echo "PYTHON_CONFIG=$(PYTHON_CONFIG)"
	@echo "PYTHON_VERSION=$(PYTHON_VERSION)"
	@echo "PYTHON_CFLAGS=$(PYTHON_CFLAGS)"
	@echo "PYTHON_LDFLAGS=$(PYTHON_LDFLAGS)"
	@echo "PYTHON_LIBDIR=$(PYTHON_LIBDIR)"
	@echo "PYTHON_LIB=$(PYTHON_LIB)"
	@echo "RUNTIME_ENV=$(RUNTIME_ENV)"

deps: ## Build dependencies

$(EXAMPLES_TARGETS): $(O)/%: examples/%.cr
	@mkdir -p $(dir $@)
	$(BUILD_PATH) crystal build $(FLAGS) $< --link-flags "$(LDFLAGS)" -o $@ --error-trace

test: deps ## Run tests
	$(RUNTIME_ENV) $(BUILD_PATH) crystal spec $(VERBOSE) --link-flags "$(LDFLAGS)"

examples: $(DEPS) $(EXAMPLES_TARGETS) ## Build all examples

run: ## Run an example (usage: make run hello args="...")
	@test -n "$(EXAMPLE)" || (echo "example is required (e.g. make run hello)" && exit 1)
	@if [ ! -x "$(O)/$(EXAMPLE)" ]; then \
		$(MAKE) $(O)/$(EXAMPLE); \
	fi
	$(RUNTIME_ENV) ./$(O)/$(EXAMPLE) $(args)

doc: deps ## Generate crython library documentation
	@echo "Building documentation..."
	$(BUILD_PATH) crystal doc src/crython.cr

clean: ## Clean up built directories and files
	@echo "Cleaning..."
	rm -rf $(O)
	rm -rf ./doc
	rm -rf $(EXAMPLES_TARGETS)
