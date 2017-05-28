class RandomVariable

  attr_accessor :pmf

  def initialize(pmf)
    self.pmf = pmf
  end

  def self.build_from_frequencies(arg)
    raw_frequencies = arg.values
    total_number_of_parts = raw_frequencies.reduce(:+)
    new(arg.each_with_object({}) {|(outcome, number_of_parts), acc| acc[outcome] = Rational(number_of_parts, total_number_of_parts)})
  end

  def self.build_uniform(arg)
    raw_frequencies = [1].cycle
    build_from_frequencies(Hash[arg.zip(raw_frequencies)])
  end

  def self.build(arg)
    arg.is_a?(Array) ? build_uniform(arg) : build_from_frequencies(arg)
  end

  def on_self(method_name, all_args)
    first_outcome = all_args.first.outcome
    rest_outcomes = all_args[1..-1].map(&:outcome)
    Hash[first_outcome.send(method_name, *rest_outcomes), all_args.map(&:probability).inject(:*)]
  end

  def method_missing(method_name, *args)
    other_random_variables = args.map {|arg| arg.kind_of?(RandomVariable) ? arg : self.class.build([arg])}
    other_pmls = other_random_variables.map(&:pml);
    cross = pml.product(*other_pmls);
    final_pmf = cross.each_with_object({}) do |point_masses, acc|
      acc.merge!(on_self(method_name, point_masses)) do |key, old_val, new_val|
        old_val + new_val
      end
    end
    self.class.new(final_pmf)
  end

  def self.context(&block)
    self.instance_eval(&block)
  end

  def pml
    self.pmf.map{|outcome, probability| PointMass.new(outcome, probability)}
  end

  def ==(other)
    self.pmf == other.pmf
  end

end

PointMass = Struct.new("PointMass", :outcome, :probability)
