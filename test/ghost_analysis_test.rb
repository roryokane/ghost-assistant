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
			["xylophoni", 2] => "s",
			["marb", 2] => "l",
			["marb", 3] => "l",
			["marbl", 2] => "i",
			["marbl", 3] => "i",
			["marbli", 2] => "n",
			["doli", 2] => "n",
			["doli", 3] => "n",
			["doli", 4] => "n",
			["qa", 2] => "i",
			["qa", 3] => "i",
		}
		assert_each_has_result_after_processing(inputs_and_expected_responses) do |current_letters, num_players|
			analysis_suggested_response(current_letters, num_players)
		end
	end
	
	def test_num_players_can_change_suggested_response
		skip "can’t write test cases until I implement returning multiple equally-good options"
		letters_and_expected_responses_per_num_players = {
			"marbli" => {2=>"n", 3=>["e","n"], 4=>["e","n"]},
		}
		letters_and_expected_responses_per_num_players.each do |current_letters, responses_per_num_players|
			responses_per_num_players.each do |num_players, expected_response|
				assert_equal expected_response, analysis_suggested_response(current_letters, num_players), [current_letters, responses_per_num_players].inspect
			end
		end
	end
	
	def test_gives_multiple_options_when_equally_good
		skip "not yet implemented"
		# Not sure about the desired format.
		# Hash? Two-element array (like a tuple)? Just an array? Struct object?
		inputs_and_expected_responses = {
			["marbli", 3] => {type: :tie, possible_responses: ["e", "n"]},
			["margari", 2] => {type: :tie, possible_responses: ["n", "t"]},
			["qa", 9] => {type: :tie, possible_responses: ["i", "n"]},
		}
		assert_each_has_result_after_processing(inputs_and_expected_responses) do |current_letters, num_players|
			analysis_suggested_response(current_letters, num_players)
		end
	end
	
	def test_knows_when_the_player_can_only_lose
		["censo", "xylograp"].each do |loss_causing_state|
			NUM_PLAYERS_TEST_RANGE.each do |num_players|
				assert_equal(:lose, analysis_suggested_response(loss_causing_state, num_players), loss_causing_state.inspect)
			end
		end
	end
	
	def test_calls_when_the_current_letters_are_a_word
		["mar", "qua", "caul", "malign"].each do |word|
			NUM_PLAYERS_TEST_RANGE.each do |num_players|
				assert_equal(:call, analysis_suggested_response(word, num_players), word.inspect)
			end
		end
	end
	
	def test_false_prefixes_cause_challenge
		["qqq", "bettermnmn", "misssspelling", "notaprefix"].each do |false_prefix|
			NUM_PLAYERS_TEST_RANGE.each do |num_players|
				assert_equal(:challenge, analysis_suggested_response(false_prefix, num_players), false_prefix.inspect)
			end
		end
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
	
	def analysis_suggested_response(current_letters, num_players)
		env = GhostEnvironment.new(@wordlist, current_letters, num_players)
		analysis = GhostAnalysis.new(env)
		return analysis.suggested_response()
	end
end
