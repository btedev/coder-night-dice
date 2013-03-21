#!/usr/bin/env ruby
require './dice.rb'

d = Dice.new(ARGV[0])
(ARGV[1] || 1).to_i.times { print "#{d.roll}  " }
puts

