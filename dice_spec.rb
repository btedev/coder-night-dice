require './spec_helper.rb'
require './dice.rb'

describe Dice do
  let(:subject) { Dice.new('') }

  it "requires an instruction argument" do
    lambda { Dice.new }.should raise_error(ArgumentError)
    d = Dice.new('3d5')
    d.original_instructions.should == '3d5'
  end

  it "strips quotes from the instruction argument" do
    d = Dice.new('"3d5"')
    d.original_instructions.should == '3d5'
  end

  it "rolls a multisided die" do
    subject.roll_die(1).should == 1
    subject.roll_die(6).should be_between(1, 6)
    subject.roll_die(100).should be_between(1, 100)
  end

  it "rolls multiple times" do
    subject.roll_die(6, 3).should be_between(3, 18)
    subject.roll_die(6, 8).should be_between(8, 48)
  end

  describe "process dice rolls" do
    it "rolls dice when d is followed by an integer" do
      inst = subject.process_dice_roll('d6')
      inst.should =~ /^\d+$/
      inst.to_i.should be_between(1, 6)
    end

    it "rolls dice multiple times when an integer precedes d" do
      inst = subject.process_dice_roll('8d6')
      inst.should =~ /^\d+$/
      inst.to_i.should be_between(8, 48)
    end

    it "processes at most one roll for each call" do
      inst = subject.process_dice_roll('8d6/d7')
      inst.should =~ /^\d+\/d7/
      inst2 = subject.process_dice_roll(inst)
      inst2.should =~ /^\d+\/\d+$/
    end
  end

  it "processes math operations" do
    subject.process_math('7*11', '*').should == '77'
    subject.process_math('10/2', '/').should == '5'
    subject.process_math('7+5', '+').should  == '12'
    subject.process_math('7-5', '-').should  == '2'
  end

  describe "processes with precedence" do
    it "handles dice rolls before math" do
      inst = subject.process('8d6*2d4')
      inst.should =~ /^\d+\*2d4/
        inst2 = subject.process(inst)
      inst2.should =~ /^\d+\*\d+$/
        inst3 = subject.process(inst2)
      inst3.should =~ /^\d+$/
    end

    it "handles math operations in the correct order" do
      inst = subject.process('1000-7+252/9*14')
      inst.should == '1000-7+252/126'
      inst2 = subject.process(inst)
      inst2.should == '1000-7+2'
      inst3 = subject.process(inst2)
      inst3.should == '1000-9'
      inst4 = subject.process(inst3)
      inst4.should == '991'
    end
  end

  describe "process instruction set to integer" do
    it "returns an integer if instruction is a single integer" do
      subject.process_to_integer('42').should == '42'
    end

    it "raises error on invalid syntax" do
      lambda { subject.process_to_integer('4d4*d5/hey yall!') }.should raise_error(ArgumentError, /Invalid syntax/)
    end

    it "processes valid syntax until a single integer remains" do
      result = subject.process_to_integer('8d10/d4')
      result.should =~ /^\d+$/
      result.to_i.should be_between(1,80)
    end
  end

  describe "matching parentheses" do
    it "extracts substrings from parentheses" do
      subject.parse_parentheses('(5d5-4)').should include(:match => '5d5-4')
    end

    it "returns nil if no parentheses" do
      subject.parse_parentheses('5d5-4').should be_nil
    end

    it "returns pre and post-match strings" do
      match = subject.parse_parentheses('d4*(5d5-4)+10')
      match[:match].should      == '5d5-4'
      match[:pre_match].should  == 'd4*'
      match[:post_match].should == '+10'
    end

    it "matches inner parentheses first" do
      subject.parse_parentheses('(d4(5d5-4))').should include(:match => '5d5-4')
    end

    it "matches left-most parentheses first" do
      match = subject.parse_parentheses('(5d5-4)+(3d8)-(4d4)')
      match[:match].should      == '5d5-4'
      match[:post_match].should == '+(3d8)-(4d4)'
    end
  end

  describe "rolling" do
    it "should process a valid instruction without parentheses" do
      Dice.new('7d10*10').roll.should =~ /^\d+$/
    end

    it "should process a valid instruction with parentheses" do
      result = Dice.new('(5d5-4)*4').roll
      result.should =~ /^\d+$/
      result.to_i.should be_between(4,84)
    end

    it "should process a complex example from rubyquiz" do
      Dice.new("(5d5-4)d(16/d4)+3").roll.should =~ /^\d+$/
    end

    it "should process a complex example with nested parentheses" do
      Dice.new("((5d5-4)+(3d4))d(16/d4)+3").roll.should =~ /^\d+$/
    end

    it "should raise an exception on invalid syntax" do
      lambda {
        Dice.new("((DROP TABLE users)+(3d4))d(16/d4)+3").roll
      }.should raise_error(ArgumentError, /Invalid syntax/)
    end
  end
end

