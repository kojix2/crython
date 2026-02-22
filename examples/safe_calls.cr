require "../src/crython"

Crython.session do
  math = Crython.import?("math")
  if math.nil?
    puts "math import failed"
    exit 1
  end

  pi = math.not_nil!.attr?("pi")
  pow = math.not_nil!.call?("pow", 2, 8)
  missing_method = math.not_nil!.call?("definitely_missing_method")

  puts "math imported: #{!math.nil?}"
  puts "pi: #{pi ? pi.not_nil!.to_cr : "nil"}"
  puts "2^8 via call?: #{pow ? pow.not_nil!.to_cr : "nil"}"
  puts "missing method via call?: #{missing_method.nil? ? "nil" : "unexpected"}"
end
