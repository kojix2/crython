@[Link(ldflags: "#{__DIR__}/crython_runtime.c -std=c11")]
lib Crython::LibCrythonRuntime
  fun initialize = crython_initialize(program_name : LibC::Char*, error_message : LibC::Char**) : Int32
  fun free_string = crython_free_string(value : LibC::Char*)
  fun release_node_new = crython_release_node_new(object : LibPython::PyObject) : Void*
  fun release_node_enqueue = crython_release_node_enqueue(node : Void*)
  fun release_node_dispose = crython_release_node_dispose(node : Void*)
  fun release_node_drain = crython_release_node_drain
  fun format_exception = crython_format_exception(exception : LibPython::PyObject, size : LibC::SizeT*) : LibC::Char*
  fun list_check = crython_list_check(object : LibPython::PyObject) : Int32
  fun tuple_check = crython_tuple_check(object : LibPython::PyObject) : Int32
  fun dict_check = crython_dict_check(object : LibPython::PyObject) : Int32
  fun long_check = crython_long_check(object : LibPython::PyObject) : Int32
  fun float_check = crython_float_check(object : LibPython::PyObject) : Int32
  fun unicode_check = crython_unicode_check(object : LibPython::PyObject) : Int32
  fun bool_check = crython_bool_check(object : LibPython::PyObject) : Int32
  fun none_check = crython_none_check(object : LibPython::PyObject) : Int32
  fun complex_check = crython_complex_check(object : LibPython::PyObject) : Int32
end
