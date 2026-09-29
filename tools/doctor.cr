require "../src/crython"

Crython.init
sys = Crython.import("sys")
puts "embedded_version=" + sys.attr("version").to_s
puts "embedded_executable=" + sys.attr("executable").to_s
puts "embedded_prefix=" + sys.attr("prefix").to_s
puts "embedded_base_prefix=" + sys.attr("base_prefix").to_s
puts "embedded_path=" + sys.attr("path").to_s
Crython.import("math")
puts "embedded_import=math"
