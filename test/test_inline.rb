require 'test/unit'
require 'pry-inline'

class TestInline < Test::Unit::TestCase
  test 'assignment of local variable' do
    def greet
      message = 'Hello, world!'
      @binding = binding
      message
    end

    expected = <<-EOF.split("\n").map(&:lstrip)
    def greet
      message = 'Hello, world!' # message: "Hello, world!"
      @binding = binding
      message
    end
    EOF
    actual = output_of_whereami { greet }
    assert { actual.zip(expected).all? { |a, e| a.end_with?(e) } }
  end

  test 'multiple assignment of local variables' do
    def multiple_assign
      x, y = 10, 20
      @binding = binding
    end

    expected = <<-EOF.split("\n").map(&:lstrip)
    def multiple_assign
      x, y = 10, 20 # x: 10, y: 20
      @binding = binding
    end
    EOF
    actual = output_of_whereami { multiple_assign }

    assert { actual.zip(expected).all? { |a, e| a.end_with?(e) } }
  end

  test 'parameters of block' do
    def block_parameters
      (1..10).each do |i|
        @binding = binding if i == 5
      end
    end

    expected = <<-EOF.split("\n").map(&:lstrip)
    def block_parameters
      (1..10).each do |i| # i: 5
        @binding = binding if i == 5
      end
    end
    EOF
    actual = output_of_whereami { block_parameters }

    assert { actual.zip(expected).all? { |a, e| a.end_with?(e) } }
  end

  test 'assignment of instance variable' do
    def assign_instance_variable
      @x = [1, 2, 3]
      @binding = binding
      @y = [4, 5, 6]
    end

    expected = <<-EOF.split("\n").map(&:lstrip)
    def assign_instance_variable
      @x = [1, 2, 3] # @x: [1, 2, 3]
      @binding = binding
      @y = [4, 5, 6]
    end
    EOF
    actual = output_of_whereami { assign_instance_variable }

    assert { actual.zip(expected).all? { |a, e| a.end_with?(e) } }
  end

  test 'assignment of class variable' do
    def assign_class_variable
      @@var = { x: 10 }
      @binding = binding
    end

    expected = <<-EOF.split("\n").map(&:lstrip)
    def assign_class_variable
      @@var = { x: 10 } # @@var: {:x=>10}
      @binding = binding
    end
    EOF
    actual = output_of_whereami { assign_class_variable }

    assert { actual.zip(expected).all? { |a, e| a.end_with?(e) } }
  end

  test 'assignment of var args' do
    def use_var_args(*args)
      @binding = binding
    end

    expected = <<-EOF.split("\n").map(&:lstrip)
    def use_var_args(*args) # args: [1, 2, 3]
      @binding = binding
    end
    EOF
    actual = output_of_whereami { use_var_args(1, 2, 3) }

    assert { actual.zip(expected).all? { |a, e| a.end_with?(e) } }
  end

  test 'assignment after binding.pry' do
    def assignment_after_binding
      x = 10
      @binding = binding
      y = 10
    end

    expected = <<-EOF.split("\n").map(&:lstrip)
    def assignment_after_binding
      x = 10 # x: 10
      @binding = binding
      y = 10
    end
    EOF
    actual = output_of_whereami { assignment_after_binding }
    assert { actual.zip(expected).all? { |a, e| a.end_with?(e) } }
  end

  private

  def output_of_whereami(&block)
    block.call
    output = StringIO.new
    Pry.start(@binding,
              input: StringIO.new('exit'),
              output: output,
              color: false,
              pager: false)
    output.string.split("\n").slice(3..-1)
  end
end
