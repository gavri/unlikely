require_relative 'random_variable'

describe "Random Variable" do
  include RandomVariableBuilders

  it "should create random variable from unnormalized pmf" do
    raw(1 => 3, 2 => 7).should == raw(1 => Rational(3, 10), 2 => Rational(7, 10))
  end

  it "should create random variable of an uniform spread from array argument" do
    uniform([6, 7, 8]).should == raw(6 => 1, 7 => 1, 8 => 1)
  end

  it "should operate probabilistically (new events are created through a single path each)" do
    (uniform([100, 200]) + uniform([1, 2])).should == uniform([101, 102, 201, 202])
  end

  it "should operate probabilistically (new events are created through multiple paths)" do
    (uniform([1, 2]) + uniform([3, 4])).should == raw(4 => 1, 5 => 2, 6 => 1)
  end

  it "should work with a probabilistic choice of function" do
    add_one = 1.method(:+)
    double = 2.method(:*)
    subtract_one = ->(x){x - 1}
    function_random_variable = uniform ([add_one, double, subtract_one])
    argument_random_variable = uniform([10, 20, 30])
    function_random_variable[argument_random_variable].should == uniform([9, 11, 21, 31, 20, 29, 40, 60, 19])
  end

  it "should work with a probabilistic choice of function and multiple arguments" do
    function_rv = uniform([->(x, y){x + y}, ->(x, y) {x - y}])
    first_arg_rv = uniform([100, 200])
    second_arg_rv = uniform([1, 2])
    function_rv[first_arg_rv, second_arg_rv].should == uniform([101, 102, 201, 202, 99, 98, 199, 198])
  end

  it "should work on non-random variables by converting them to random variables of one outcome" do
    actual = uniform([3, 4, 5]) / 2
    expected = raw(1 => 1, 2 => 2)
    actual.should == expected
  end

end
