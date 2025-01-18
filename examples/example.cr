require "../src/crython"

@[Link("c")]
lib LibC
  fun fdopen(fd : Int32, mode : Char*) : Void*
end

Crython.init

stdout_fp = LibC.fdopen(STDOUT.fd, "w")

mod = Crython.import_module("os")
# Get a Python object's attribute.
attr = mod.get_attr("getcwd")
# Call a Python object's attribute.
result = LibPython.obj_call_function(attr, nil)
# Print the result.
LibPython.obj_print(result, stdout_fp, 0)

Crython.finalize
