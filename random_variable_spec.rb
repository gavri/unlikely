require_relative 'random_variable'
r = RandomVariable
describe "Random Variable" do

  it "should create random variable from array argument" do
    r.build([6, 7, 8]).pmf.should == {6 => Rational(1, 3), 7 => Rational(1, 3), 8 => Rational(1, 3)}
  end

  it "should create random variable from unnormalized pmf" do
    r.build(1 => 3, 2 => 7).pmf.should == {1 => Rational(3, 10), 2 => Rational(7, 10)}
  end

  it "should operate probabilistically (new events are created through a single path each)" do
    actual = r.build([100, 200]) + r.build([1, 2])
    actual.should == r.build([101, 102, 201, 202])
  end

  it "should operate probabilistically (new events are created through multiple paths)" do
    actual = r.build([1, 2]) + r.build([3, 4])
    actual.should == r.build(4 => 1, 5 => 2, 6 => 1)
  end

  it "should work with a probabilistic choice of function" do
    add_one = 1.method(:+)
    double = 2.method(:*)
    subtract_one = ->(x){x - 1}
    function_random_variable = r.build([add_one, double, subtract_one])
    argument_random_variable = r.build([10, 20, 30])
    function_random_variable[argument_random_variable].should == r.build([9, 11, 21, 31, 20, 29, 40, 60, 19])
  end

  it "should work with a probabilistic choice of function and multiple arguments" do
    function_rv = r.build([->(x, y){x + y}, ->(x, y) {x - y}])
    first_arg_rv = r.build([100, 200])
    second_arg_rv = r.build([1, 2])
    function_rv[first_arg_rv, second_arg_rv].should == r.build([101, 102, 201, 202, 99, 98, 199, 198])
  end

  it "should work on non-random variables by converting them to random variables of one outcome" do
    actual = r.build([3, 4, 5]) / 2
    expected = r.build(1 => 1, 2 => 2)
    actual.should == expected
  end

end
