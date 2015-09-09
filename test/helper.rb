require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!


def assert_each_has_result_after_processing(input_expected_map, &process)
	input_expected_map.each do |input, expected|
		actual = process.call(input)
		assert_equal(expected, actual, "Block parameters: #{input.inspect}")
		assert_equal_with_labeled_data(expected, actual, "Block parameters", input)
	end
end

def assert_all_have_result_after_processing(inputs, expected, &process)
	inputs.each do |input|
		actual = process.call(input)
		assert_equal_with_labeled_data(expected, actual, "Block parameters", input)
	end
end

def assert_equal_given_input(expected, actual, input)
	assert_equal_with_labeled_data(expected, actual, "Input", input)
end

private

def assert_equal_with_labeled_data(expected, actual, label, input)
	assert_equal expected, actual, "#{label}: #{input.inspect}"
end
