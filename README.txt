======================
Coder Night 2013-03-28
======================

Challenge from http://web.archive.org/web/20130215052933/http://rubyquiz.com/quiz61.html

For this challenge, I initially planned to cheat on Ruby with Erlang, but in the end decided my regular boo was a better choice. While Erlang has great pattern matching in selecting functions (something foreign to Ruby), its string parsing completely sucks. My dabbling in Erlang did, however, inspire the approach I took in Ruby. The program has just two instance variables (the original BNF instruction and a regex-to-method hash) and works by making single changes at a time to the instruction set until a single integer remains or until invalid syntax causes it to raise an error.

For example, this is a trace from that one time at band camp when I had logging statements:

  original: ((5d5-4)+(3d4))d(16/d4)+3
  in paren: (8+(3d4))d(16/d4)+3
  in paren: (8+7)d(16/d4)+3
  in paren: 15d(16/d4)+3
  in paren: 15d5+3
  after paren: 15d5+3
  after paren: 47+3
  final: 50

An "instruction" string is passed through a series of functions which make 0 to 1 changes and return a string. If parentheses are present, the class starts with the inner-most and left-most set of parentheses and processes its contents to an integer, substituting that integer for the parenthetical clause in the larger instruction string.

One side-effect of the approach I took is that readability suffers - the pattern /instruction/ is found 28 times in the dice.rb class. As always, TDD was helpful in not over-engineering. I wrote the minimum code to first parse simple BNF's like "3d6" and left the parsing of parentheses for last.

To run the specs:

  $ bundle
  $ rspec dice_spec.rb

To run via roll.rb:

  $ ./roll.rb "(3d6)d4" 3

