require_relative '../config/environment'
require_relative '../app/models/interface'

cli = Interface.new
cli.run

puts "Program finish"
