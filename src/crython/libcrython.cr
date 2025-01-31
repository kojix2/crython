# :nodoc:
@[Link(ldflags: "#{__DIR__}/../ext/libcrython.a")]
lib LibCrython
  alias PyObject = Void*

  # Reference Counting Functions
  fun incref = py_incref(o : PyObject)
  fun decref = py_decref(o : PyObject)
  fun xincref = py_xincref(o : PyObject)
  fun xdecref = py_xdecref(o : PyObject)
  fun clear = py_clear(o : PyObject)

  # Basic Object Checks
  fun none? = is_py_none(o : PyObject) : LibC::Int
  fun bool? = py_bool_check(b : PyObject) : LibC::Int

  # Singleton Object Access
  fun none = py_none : PyObject

  # List Type Checks & Operations
  fun list? = py_list_check(l : PyObject) : LibC::Int
  fun list_exact? = py_list_check_exact(l : PyObject) : LibC::Int
  fun list_size = list_item_count(list : PyObject) : LibC::SizeT

  # Tuple Type Checks & Operations
  fun tuple? = py_tuple_check(t : PyObject) : LibC::Int
  fun tuple_exact? = py_tuple_check_exact(t : PyObject) : LibC::Int
  fun tuple_size = tuple_item_count(tuple : PyObject) : LibC::SizeT

  # Hash & Comparison
  fun hash = key_hash(key : PyObject) : LibC::Long
  fun eq? = key_eq(key : PyObject, other : PyObject) : LibC::Int

  # Module Handling
  fun load_module = load_module(module_name : LibC::Char*) : PyObject

  # Class Instantiation
  fun instantiate = instantiate_python_class(class : PyObject) : PyObject

  # Attribute Access
  fun get_name = get_name(pObject : PyObject) : PyObject
end
