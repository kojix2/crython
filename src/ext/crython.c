#include <Python.h>

/* ---- Reference Counting Functions ---- */
extern void py_incref(PyObject *o)
{
  if (o == NULL) {
    fprintf(stderr, "py_incref: NULL pointer\n");
    return;
  }
  Py_INCREF(o); // Increment reference count
}

extern void py_xincref(PyObject *o)
{
  if (o == NULL) {
    fprintf(stderr, "py_xincref: NULL pointer\n");
    return;
  }
  Py_XINCREF(o); // Increment reference count if not NULL
}

extern void py_decref(PyObject *o)
{
  if (o == NULL) {
    fprintf(stderr, "py_decref: NULL pointer\n");
    return;
  }
  Py_DECREF(o); // Decrement reference count
}

extern void py_xdecref(PyObject *o)
{
  if (o == NULL) {
    fprintf(stderr, "py_xdecref: NULL pointer\n");
    return;
  }
  Py_XDECREF(o); // Decrement reference count if not NULL
}

extern void py_clear(PyObject *o)
{
  if (o == NULL) {
    fprintf(stderr, "py_clear: NULL pointer\n");
    return;
  }
  Py_CLEAR(o); // Decrement reference count and set to NULL
}

/* ---- Basic Object Checks ---- */
extern int py_bool_check(PyObject *b)
{
  return PyBool_Check(b); // Check if object is a boolean
}

extern int is_py_none(PyObject *o)
{
  return o == Py_None; // Check if object is None
}

/* ---- List Type Checks & Operations ---- */
extern int py_list_check(PyObject *l)
{
  return PyList_Check(l); // Check if object is a list or its subclass
}

extern int py_list_check_exact(PyObject *l)
{
  return PyList_CheckExact(l); // Check if object is exactly a list (not subclass)
}

extern size_t list_item_count(PyObject *list)
{
  return PyList_Size(list); // Get number of items in a list
}

/* ---- Tuple Type Checks & Operations ---- */
extern int py_tuple_check(PyObject *t)
{
  return PyTuple_Check(t); // Check if object is a tuple or its subclass
}

extern int py_tuple_check_exact(PyObject *t)
{
  return PyTuple_CheckExact(t); // Check if object is exactly a tuple (not subclass)
}

extern size_t tuple_item_count(PyObject *tuple)
{
  return PyTuple_Size(tuple); // Get number of items in a tuple
}

/* ---- Hash & Comparison ---- */
extern long key_hash(PyObject *key)
{
  return PyObject_Hash(key); // Get hash value of an object
}

extern int key_eq(PyObject *key, PyObject *other)
{
  return PyObject_RichCompareBool(key, other, Py_EQ); // Compare two objects for equality
}

/* ---- Module Handling ---- */
extern PyObject *load_module(char *module_name)
{
  PyObject *pName, *pModule;
  pName = PyUnicode_FromString(module_name);
  pModule = PyImport_Import(pName); // Import a Python module by name
  Py_DECREF(pName);
  return pModule;
}

/* ---- Class Instantiation ---- */
extern PyObject *instantiate_python_class(PyObject *class)
{
  return PyObject_CallFunctionObjArgs(class, NULL); // Instantiate a Python class (no arguments)
}

/* ---- Singleton Object Access ---- */
extern PyObject *py_none()
{
  return Py_None; // Return Py_None singleton
}

/* ---- Boolean Object Access ---- */
extern PyObject *py_true()
{
  return Py_True; // Return Py_True singleton
}

extern PyObject *py_false()
{
  return Py_False; // Return Py_False singleton
}

/* ---- Slice Object Creation ---- */
extern PyObject *slice_full()
{
  return PySlice_New(Py_None, Py_None, Py_None); // Create a full slice object
}