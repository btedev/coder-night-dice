class Dice
  attr_reader :original_instructions

  def initialize(original_instructions)
    @original_instructions = original_instructions.gsub(/\"/,'')
  end

  def roll
    instructions = @original_instructions.clone
    while match = parse_parentheses(instructions)
      result       = process_to_integer(match[:match])
      instructions = [match[:pre_match], result, match[:post_match]].join('')
    end
    process_to_integer(instructions)
  end

  def roll_die(sides, rolls=1)
    rolls.times.inject(0) { |sum| sum + rand(sides) + 1 }
  end

  def process_to_integer(instructions)
    while instructions !~ /^\d+$/
      instructions = process(instructions)
      raise ArgumentError, "Invalid syntax" unless instructions
    end
    instructions
  end

  def process(instructions)
    @instruction_map ||= {
      /\d*d\d+/  => 'process_dice_roll',
      /\d+\*\d+/ => '*',
      /\d+\/\d+/ => '/',
      /\d+\+\d+/ => '+',
      /\d+\-\d+/ => '-',
    }

    @instruction_map.each do |pattern, method|
      if instructions =~ pattern
        return instructions = send(method, instructions)
      end
    end

    false
  end

  def process_dice_roll(instructions)
    match  = instructions.match(/(?<rolls>\d*)d(?<sides>\d+)/)
    rolls  = (match[:rolls].to_i > 0 ? match[:rolls].to_i : 1)
    sides  = match[:sides].to_i
    instructions[match.begin(0)...match.end(0)] = roll_die(sides, rolls).to_s
    instructions
  end

  def process_math(instructions, operator)
    match = instructions.match(/\d+#{Regexp.escape(operator)}\d+/)
    instructions[match.begin(0)...match.end(0)] = eval(match[0]).to_s
    instructions
  end

  def method_missing(op, *args)
    process_math(*args, op)
  end

  def parse_parentheses(instructions)
    if instructions =~ /\(.*\)/
      match = instructions.match(/\((?<subset>[^()]*)\)/)
      {
        :match      => match[:subset],
        :pre_match  => match.pre_match,
        :post_match => match.post_match
      }
    end
  end
end

