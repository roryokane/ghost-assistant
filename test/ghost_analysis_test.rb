# encoding: utf-8

require_relative 'helper'

require_relative '../lib/ghost_analysis'
require_relative '../lib/ghost_environment'
require_relative '../lib/wordlist_loader'

class TestGhostAnalysis < MiniTest::Unit::TestCase
	def setup
		@wordlist = load_wordlist()
	end
	
	def test_false_prefixes_cause_challenge
		["qqq", "bettermnmn", "misssspelling", "notaprefix"].each do |false_prefix|
			(2..3).each do |num_players|
				env = GhostEnvironment.new(@wordlist, false_prefix, num_players)
				analysis = GhostAnalysis.new(env)
				assert_equal(:challenge, analysis.suggested_response())
			end
		end
	end
end