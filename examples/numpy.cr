require "../src/crython"

@[Link("c")]
lib LibC
  fun fdopen(fd : Int32, mode : Char*) : Void*
end

stdout_fp = LibC.fdopen(STDOUT.fd, "w")

# NumPy example

Crython.init

np = Crython.import_module("numpy")

attr = np.get_attr("array")

arg1 = LibPython.build_value("[i,i,i]", 1, 2, 3)
x1 = LibPython.object_call_function(attr, arg1, nil)

arg2 = LibPython.build_value("[i,i,i]", 4, 5, 6)
x2 = LibPython.object_call_function(attr, arg2, nil)

attr = np.get_attr("add")
result = LibPython.object_call_function(attr, x1, x2, nil)
LibPython.err_print
LibPython.object_print(x1, stdout_fp, 0)
LibPython.object_print(LibPython.build_value("s", " + "), stdout_fp, 0)
LibPython.object_print(x2, stdout_fp, 0)
LibPython.object_print(LibPython.build_value("s", " = "), stdout_fp, 0)
LibPython.object_print(result, stdout_fp, 0)

Crython.finalize
