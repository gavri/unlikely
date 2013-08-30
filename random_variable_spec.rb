require_relative 'random_variable'
r = RandomVariable
describe "Random Variable" do

  it "should create random variable from constructor point_mass" do
    r.point_mass(5).pmf.should == {5 => 1}
  end

  it "should create random variable from constructor equiprobable" do
    r.equiprobable([6, 7, 8]).pmf.should == {6 => Rational(1, 3), 7 => Rational(1, 3), 8 => Rational(1, 3)}
  end

  it "should create random variable from unnormalized pmf" do
    r.parts(1 => 3, 2 => 7).pmf.should == {1 => Rational(3, 10), 2 => Rational(7, 10)}
  end

  it "should operate probabilistically (new events are created through a single path each)" do
    actual = r.equiprobable([100, 200]) + r.equiprobable([1, 2])
    actual.should == r.equiprobable([101, 102, 201, 202])
  end

  it "should operate probabilistically (new events are created through multiple paths)" do
    actual = r.equiprobable([1, 2]) + r.equiprobable([3, 4])
    actual.should == r.parts(4 => 1, 5 => 2, 6 => 1)
  end

  it "should work with a probabilistic choice of function" do
    add_one = 1.method(:+)
    double = 2.method(:*)
    subtract_one = ->(x){x - 1}
    function_random_variable = r.equiprobable([add_one, double, subtract_one])
    argument_random_variable = r.equiprobable([10, 20, 30])
    function_random_variable[argument_random_variable].should == r.equiprobable([9, 11, 21, 31, 20, 29, 40, 60, 19])
  end

  it "should work with a probabilistic choice of function and multiple arguments" do
    function_rv = r.equiprobable([->(x, y){x + y}, ->(x, y) {x - y}])
    first_arg_rv = r.equiprobable([100, 200])
    second_arg_rv = r.equiprobable([1, 2])
    function_rv[first_arg_rv, second_arg_rv].should == r.equiprobable([101, 102, 201, 202, 99, 98, 199, 198])
  end

  it "should work on non-random variables by converting them to random variables of one outcome" do
    actual = r.equiprobable([3, 4, 5]) / 2
    expected = r.parts(1 => 1, 2 => 2)
    actual.should == expected
  end

end
