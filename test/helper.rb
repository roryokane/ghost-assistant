require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!


def assert_each_has_result_after_processing(input_expected_map, &process)
	input_expected_map.each do |input, expected|
		actual = process.call(input)
		assert_equal(expected, actual, "Block parameters: #{input.inspect}")
	end
end
