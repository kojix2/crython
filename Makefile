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

LIB_CRYTHON = src/ext/crython.c
LIB_CRYTHON_OBJ = $(subst .c,.o,$(LIB_CRYTHON))
LIB_CRYTHON_TARGET = src/ext/libcrython.a

DEPS = $(LIB_CRYTHON_TARGET)

EXAMPLES_SOURCES := $(shell find examples -type f -name '*.cr')
EXAMPLES_TARGETS := $(patsubst examples/%.cr, $(O)/%, $(EXAMPLES_SOURCES))

PYTHON_CFLAGS := $(shell python3-config --cflags)
PYTHON_LDFLAGS := $(shell python3-config --ldflags)

PYTHON_VERSION := $(shell python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PYTHON_LIB := -lpython$(PYTHON_VERSION)

CFLAGS += $(PYTHON_CFLAGS)
LDFLAGS += $(PYTHON_LDFLAGS) $(PYTHON_LIB)

.PHONY: all deps libcrython test examples doc clean

all: deps

deps: libcrython ## Build dependencies

libcrython: $(LIB_CRYTHON_TARGET)

$(LIB_CRYTHON_OBJ): $(LIB_CRYTHON)
	$(CC) -o $@ -c $< $(CFLAGS)

$(LIB_CRYTHON_TARGET): $(LIB_CRYTHON_OBJ)
	$(AR) -rcs $@ $^

$(EXAMPLES_TARGETS): $(O)/%: examples/%.cr
	@mkdir -p $(dir $@)
	$(BUILD_PATH) crystal build $(FLAGS) $< --link-flags "$(LDFLAGS)" -o $@ --error-trace

test: deps ## Run tests
	$(BUILD_PATH) crystal spec $(VERBOSE) --link-flags "$(LDFLAGS)"

examples: $(DEPS) $(EXAMPLES_TARGETS)

doc: deps ## Generate crython library documentation
	@echo "Building documentation..."
	$(BUILD_PATH) crystal doc src/crython.cr

clean: ## Clean up built directories and files
	@echo "Cleaning..."
	rm -rf $(O)
	rm -rf ./doc
	rm -rf $(LIB_CRYTHON_OBJ)
	rm -rf $(LIB_CRYTHON_TARGET)
	rm -rf $(EXAMPLES_TARGETS)
