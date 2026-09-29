#include <Python.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct CrythonReleaseNode {
    PyObject *object;
    struct CrythonReleaseNode *next;
} CrythonReleaseNode;

static _Atomic(CrythonReleaseNode *) crython_pending_releases = NULL;

static char *crython_copy_string(const char *source) {
    if (source == NULL) return NULL;
    size_t size = strlen(source);
    char *copy = malloc(size + 1);
    if (copy != NULL) memcpy(copy, source, size + 1);
    return copy;
}

int crython_initialize(const char *program_name, char **error_message) {
    PyConfig config;
    PyStatus status;
    PyConfig_InitPythonConfig(&config);
    config.parse_argv = 0;
    config.install_signal_handlers = 0;
    if (program_name != NULL) {
        status = PyConfig_SetBytesString(&config, &config.program_name, program_name);
        if (PyStatus_Exception(status)) {
            *error_message = crython_copy_string(status.err_msg);
            PyConfig_Clear(&config);
            return -1;
        }
    }
    status = Py_InitializeFromConfig(&config);
    PyConfig_Clear(&config);
    if (PyStatus_Exception(status)) {
        *error_message = crython_copy_string(status.err_msg);
        return -1;
    }
    return 0;
}

void crython_free_string(char *value) { free(value); }

CrythonReleaseNode *crython_release_node_new(PyObject *object) {
    CrythonReleaseNode *node = malloc(sizeof(*node));
    if (node == NULL) return NULL;
    node->object = object;
    node->next = NULL;
    return node;
}

void crython_release_node_enqueue(CrythonReleaseNode *node) {
    CrythonReleaseNode *head;
    do {
        head = atomic_load_explicit(&crython_pending_releases, memory_order_relaxed);
        node->next = head;
    } while (!atomic_compare_exchange_weak_explicit(&crython_pending_releases, &head, node, memory_order_release, memory_order_relaxed));
}

void crython_release_node_dispose(CrythonReleaseNode *node) {
    if (node == NULL) return;
    Py_DECREF(node->object);
    free(node);
}

void crython_release_node_drain(void) {
    CrythonReleaseNode *node = atomic_exchange_explicit(&crython_pending_releases, NULL, memory_order_acquire);
    while (node != NULL) {
        CrythonReleaseNode *next = node->next;
        Py_DECREF(node->object);
        free(node);
        node = next;
    }
}

char *crython_format_exception(PyObject *exception, size_t *size_out) {
    char *result = NULL;
    PyObject *traceback = NULL, *formatter = NULL, *lines = NULL, *empty = NULL, *text = NULL;
    traceback = PyImport_ImportModule("traceback");
    if (traceback == NULL) goto done;
    formatter = PyObject_GetAttrString(traceback, "format_exception");
    if (formatter == NULL) goto done;
    lines = PyObject_CallOneArg(formatter, exception);
    if (lines == NULL) goto done;
    empty = PyUnicode_FromStringAndSize("", 0);
    if (empty == NULL) goto done;
    text = PyUnicode_Join(empty, lines);
    if (text == NULL) goto done;
    Py_ssize_t size = 0;
    const char *utf8 = PyUnicode_AsUTF8AndSize(text, &size);
    if (utf8 == NULL) goto done;
    result = malloc((size_t)size + 1);
    if (result == NULL) goto done;
    memcpy(result, utf8, (size_t)size);
    result[size] = 0;
    *size_out = (size_t)size;
done:
    Py_XDECREF(text);
    Py_XDECREF(empty);
    Py_XDECREF(lines);
    Py_XDECREF(formatter);
    Py_XDECREF(traceback);
    if (PyErr_Occurred()) PyErr_Clear();
    return result;
}
int crython_list_check(PyObject *object) { return PyList_Check(object); }
int crython_tuple_check(PyObject *object) { return PyTuple_Check(object); }
int crython_dict_check(PyObject *object) { return PyDict_Check(object); }
int crython_long_check(PyObject *object) { return PyLong_Check(object); }
int crython_float_check(PyObject *object) { return PyFloat_Check(object); }
int crython_unicode_check(PyObject *object) { return PyUnicode_Check(object); }
int crython_bool_check(PyObject *object) { return PyBool_Check(object); }
int crython_none_check(PyObject *object) { return object == Py_None; }
int crython_complex_check(PyObject *object) { return PyComplex_Check(object); }
