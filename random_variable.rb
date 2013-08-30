class RandomVariable

  attr_accessor :pmf

  def initialize(pmf)
    self.pmf = pmf
  end

  def self.equiprobable(outcomes)
    number_of_outcomes = outcomes.size
    probability_of_individual_outcome = Rational(1) / number_of_outcomes
    self.new(outcomes.each_with_object({}){|outcome, acc| acc[outcome] = probability_of_individual_outcome})
  end

  def self.point_mass(outcome)
    self.new(outcome => Rational(1))
  end

  def self.parts(unnormalized_pmf)
    total_number_of_parts = unnormalized_pmf.values.inject(:+)
    self.new(unnormalized_pmf.each_with_object({}) {|(outcome, number_of_parts), acc| acc[outcome] = Rational(number_of_parts, total_number_of_parts)})
  end

  def on_self(method_name, all_args)
    first_outcome = all_args.first.outcome
    rest_outcomes = all_args[1..-1].map(&:outcome)
    Hash[first_outcome.send(method_name, *rest_outcomes), all_args.map(&:probability).inject(:*)]
  end

  def method_missing(method_name, *args)
    other_random_variables = args.map {|arg| arg.kind_of?(RandomVariable) ? arg : self.class.point_mass(arg)}
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
