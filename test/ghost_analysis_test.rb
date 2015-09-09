require_relative 'helper'

require_relative '../lib/ghost_analysis'
require_relative '../lib/ghost_environment'
require_relative '../lib/wordlist_loader'

class TestGhostAnalysis < MiniTest::Test
	def setup
		@wordlist = load_wordlist()
	end
	
	NUM_PLAYERS_TEST_RANGE = (2..3)
	
	def test_suggests_best_letter_responses
		inputs_and_expected_responses = {
			["xylophoni", 2] => ["s"],
			["marb", 2] => ["l"],
			["marb", 3] => ["l"],
			["marbl", 2] => ["i"],
			["marbl", 3] => ["i"],
			["marbli", 2] => ["n"],
			["doli", 2] => ["n"],
			["doli", 3] => ["n"],
			["doli", 4] => ["n"],
		}
		assert_each_has_result_after_processing(inputs_and_expected_responses) do |current_letters, num_players|
			analysis_best_responses(current_letters, num_players)
		end
	end
	
	def test_gives_multiple_options_when_equally_good
		inputs_and_expected_responses = {
			["marbli", 3] => ["e", "n"],
			["qa", 9] => ["i", "n"],
		}
		assert_each_has_result_after_processing(inputs_and_expected_responses) do |current_letters, num_players|
			analysis_best_responses(current_letters, num_players)
		end
	end
	
	def test_num_players_can_change_suggested_response
		letters_and_expected_responses_per_num_players = {
			"qa" => {2=>["i"], 3=>["i", "n"], 4=>["i", "n"]},
			"marbli" => {2=>["n"], 3=>["e","n"], 4=>["e","n"]},
		}
		
		inputs_and_expected_responses = letters_and_expected_responses_per_num_players.flat_map do |current_letters, responses_per_num_players|
			responses_per_num_players.map do |num_players, expected_response|
				{[current_letters, num_players] => expected_response}
			end
		end.reduce(:merge)
		
		assert_each_has_result_after_processing(inputs_and_expected_responses) do |current_letters, num_players|
			analysis_best_responses(current_letters, num_players)
		end
	end
	
	def test_knows_when_the_player_can_only_lose
		loss_causing_states = ["censo", "xylograp"]
		assert_best_responses_for_all_nums_players_are_always(loss_causing_states, [:lose])
	end
	
	def test_calls_when_the_current_letters_are_a_word
		words = ["mar", "qua", "caul", "malign"]
		assert_best_responses_for_all_nums_players_are_always(words, [:call])
	end
	
	def test_false_prefixes_cause_challenge
		false_prefixes = ["qqq", "bettermnmn", "misssspelling", "notaprefix"]
		assert_best_responses_for_all_nums_players_are_always(false_prefixes, [:challenge])
	end
	
	def test_score_accounts_for_letters_said_on_your_turn
		skip "not yet implemented"
		env = GhostEnvironment.new(["pemmican", "pemmicans"], "pemm", 2)
		# In this situation, even though “pemmicans” lands on you, it will never be
		# reached, because you will have the option to call “it’s a word” before then.
		# So ‘i’ is perfectly safe to say. So its score should be 1.
		analysis = GhostAnalysis.new(env)
		assert_equal 1, analysis.score("i")
	end
	
	private
	
	def analysis_best_responses(current_letters, num_players)
		env = GhostEnvironment.new(@wordlist, current_letters, num_players)
		analysis = GhostAnalysis.new(env)
		return analysis.best_responses
	end
	
	def assert_best_responses_for_all_nums_players_are_always(current_letter_inputs, expected)
		current_letter_inputs.each do |current_letters|
			NUM_PLAYERS_TEST_RANGE.each do |num_players|
				args = [current_letters, num_players]
				actual = analysis_best_responses(*args)
				assert_equal_given_input(expected, actual, args)
			end
		end
	end
		end
	end
end
