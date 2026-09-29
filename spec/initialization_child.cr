require "../src/crython"

case ARGV.first?
when "before"
  begin
    Crython.eval("40 + 2")
  rescue Crython::InitializationError
    exit 0
  end
when "normal"
  Crython.init
  exit(Crython.import("math").to_unsafe.null? ? 1 : 0)
when "venv"
  executable = ENV["CRYTHON_TEST_VENV"]? || exit(1)
  Crython.init(python_executable: executable)
  exit(Crython.import("crython_venv_probe").to_unsafe.null? ? 1 : 0)
when "different"
  Crython.init
  begin
    Crython.init(python_executable: "/different/python")
  rescue Crython::InitializationError
    exit 0
  end
when "external"
  Crython::LibPython.init
  begin
    Crython.init
  rescue Crython::InitializationError
    exit 0
  end
end

exit 1
