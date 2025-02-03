# :nodoc:
@[Link(ldflags: "#{__DIR__}/../ext/libcrython.a")]
lib LibCrython
  alias PyObject = Void*

  # Reference Counting Functions
  fun refcnt = py_refcnt(o : PyObject) : LibC::SizeT
  fun set_refcnt = py_set_refcnt(o : PyObject, refcnt : LibC::SizeT)
  fun clear = py_clear(o : PyObject)

  # Basic Object Checks
  fun none? = is_py_none(o : PyObject) : LibC::Int
  fun bool? = py_bool_check(b : PyObject) : LibC::Int

  # Singleton Object Access
  fun none = py_none : PyObject

  # Boolean Object Access
  fun py_true = py_true : PyObject
  fun py_false = py_false : PyObject

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

  # Slice Object Creation
  fun slice_full = slice_full : PyObject
end
