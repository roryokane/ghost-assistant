# encoding: utf-8

require 'memoist'
include Memoist

MINIMUM_WORD_LENGTH = 3
DEBUG = false

class GhostAnalysis
	def initialize(ghost_environment)
		@env = ghost_environment
		
		# TODO cache all sub-wordlists for all analyzed letters in a tree
		# TODO optionally save that tree in a file and load it in future sessions
		methods_to_memoize = [:possible_wordlist, :good_wordlist, :good_words_kind_to_previous_player, \
		 :good_words_that_get_previous_player, :score]
		methods_to_memoize.each do |method|
			memoize method
		end
	end
	
	def environment
		@env
	end
	
	def possible_wordlist
		@env.wordlist.reject do |word|
			! word.start_with?(@env.current_letters) || word.length < MINIMUM_WORD_LENGTH
		end
	end
	
	# TODO allow prioritizing the wordlist so the bot attacks a specific player (in 3+-player games)
	# before attacking other players
	# this will also allow score() to choose as if someone or everyone else
	# holds a grudge against you and will always try to get you out
	def good_wordlist
		# reject words that would land on the player
		good_wordlist = possible_wordlist.reject do |word|
			(word.length - @env.current_letters.length) % @env.num_of_players == 1
		end
		
		# reject words that begin with another word
		good_wordlist.reject! do |word|
			found_a_subword = false
			([@env.current_letters.length+1, MINIMUM_WORD_LENGTH].max .. word.length-1).take_while do |substring_length|
				substring = word[0, substring_length]
				substring_is_in_wordlist = possible_wordlist.include?(substring)
				if substring_is_in_wordlist
					found_a_subword = true
					break false
				end
			end
			found_a_subword
		end
		
		good_wordlist
	end
	
	# TODO find way to split array into two arrays based on block
	def good_words_kind_to_previous_player
		categorize_good_words_by_kindness_to_previous_player if ! defined? @good_words_kind_to_previous_player
		@good_words_kind_to_previous_player
	end
	def good_words_that_get_previous_player
		categorize_good_words_by_kindness_to_previous_player if ! defined? @good_words_that_get_previous_player
		@good_words_that_get_previous_player
	end
	
	private
	def categorize_good_words_by_kindness_to_previous_player
		@good_words_kind_to_previous_player = []
		@good_words_that_get_previous_player = []
		good_wordlist.each do |word|
			if (word.length - @env.current_letters.length) % @env.num_of_players == 0
				@good_words_kind_to_previous_player << word
			else
				@good_words_that_get_previous_player << word
			end
		end
	end
	public
	
	# TODO return word instead of letter (beware of affecting #score)
	# TODO merely calculate and rank words by score, in case people don't know the word
	def suggested_response
		if possible_wordlist.empty?
			:challenge
		elsif good_wordlist.empty?
			:lose
		elsif good_wordlist.first == @env.current_letters
			:call
		else
			# return good_wordlist.sample[@env.current_letters.length, 1]
			
			possible_letters = good_wordlist.map { |word| word[@env.current_letters.length, 1] }.uniq
			puts "possible letters for “#{@env.current_letters}”: #{possible_letters.join(" ")}" if DEBUG
			if possible_letters.length > 1
				possible_letter_scores = Hash.new
				possible_letters.each { |letter| possible_letter_scores[letter] = score(letter) }
				if DEBUG
					printable_letter_scores = []
					possible_letter_scores.each { |letter, score| printable_letter_scores << "#{letter}—#{score}" }
					puts "possible letter scores for “#{@env.current_letters}”: #{printable_letter_scores.join(" ")}"
				end
				best_score = possible_letter_scores.values.max
				puts "best score for “#{@env.current_letters}”: #{best_score}" if DEBUG
				best_letters = possible_letter_scores.reject { |letter, score| score != best_score }.keys
				best_letters.sample
				# TODO do I need to do something about #choice using the same random seed each run? (Does #sample do that?)
				# TODO make variant method #best_responses that returns all best letters, instead of a random one,
				# and lets the caller choose one
			else
				possible_letters.first
			end
		end
	end
	
	def respond_to_loss
		random_fraction = Kernel::rand
		# TODO rewrite as case or with statement without involving arbitrary integer (use constant)
		if random_fraction < 0.15
			:challenge
		elsif random_fraction < 0.6
			# TODO bluff, using Markov chain based on all words in wordlist to predict the next letter
			"b"
		else
			# TODO say a letter that gets the player out
			"l"
		end
	end
	
	def num_other_players
		@env.num_of_players - 1
	end
	
	def score(letter_to_say)
		prediction = ""
		simulated_env = @env
		analysis = nil
		num_other_players.times do
			simulated_env = simulated_env.env_by_saying_letter(letter_to_say)
			analysis = GhostAnalysis.new(simulated_env)
			next_prediction = analysis.suggested_response
			puts "predicted response to “#{simulated_env.current_letters}”: #{next_prediction}" if DEBUG
			if next_prediction == :lose
				# cooperate with other players in attacking (assumes other players don’t care who else loses)
				return 1 # 1/1 score = highest
			elsif [:challenge, :call].include?(next_prediction)
				raise "Invalid prediction for opponent: #{next_prediction}"
			else
				letter_to_say = next_prediction
				prediction += next_prediction
			end
		end
		score = analysis.good_wordlist.length.quo(analysis.possible_wordlist.length) # accurate division
		score
	end
end