require 'memoist'
require_relative 'global_logger'

MINIMUM_WORD_LENGTH = 3

class GhostAnalysis
	include Memoist
	
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
		@env.wordlist.select do |word|
			word.start_with?(@env.current_letters) && word.length >= MINIMUM_WORD_LENGTH
		end
	end
	
	# TODO allow prioritizing the wordlist so the bot attacks a specific player (in 3+-player games)
	# before attacking other players
	# this will also allow score() to choose as if someone or everyone else
	# holds a grudge against you and will always try to get you out
	def good_wordlist
		possible_wordlist \
			.reject { |word| word_would_land_on_the_player(word) } \
			.reject { |word| word_begins_with_another_word(word) }
	end
	
	private
	def word_would_land_on_the_player(word)
		((word.length - @env.current_letters.length) % @env.num_of_players) == 1
	end
	public
	
	private
	def word_begins_with_another_word(word)
		minimum_relevant_subword_length = [@env.current_letters.length+1, MINIMUM_WORD_LENGTH].max
		possible_subword_lengths = minimum_relevant_subword_length..(word.length-1)
		initial_substrings = possible_subword_lengths.lazy.map { |length| word[0, length] }
		return initial_substrings.any? { |substring| possible_wordlist.include?(substring) }
	end
	public
	
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
		@good_words_kind_to_previous_player, @good_words_that_get_previous_player \
			= good_wordlist.partition do |word|
				((word.length - @env.current_letters.length) % @env.num_of_players) == 0
			end
	end
	public
	
	# TODO return word instead of letter (beware of affecting #score)
	# TODO merely calculate and rank words by score, in case people don't know the word
	def best_responses
		if possible_wordlist.empty?
			[:challenge]
		elsif good_wordlist.empty?
			[:lose]
		elsif good_wordlist.first == @env.current_letters
			[:call]
		else
			best_response_letters
		end
	end
	
	private
	def best_response_letters
		possible_letters = possible_response_letters
		$logger.debug { "possible letters for “#{@env.current_letters}”: #{possible_letters.join(" ")}" }
		
		if possible_letters.length > 1
			possible_letter_scores = Hash.new
			possible_letters.each { |letter| possible_letter_scores[letter] = score(letter) }
			$logger.debug do
				printable_letter_scores = possible_letter_scores.map do |letter, score|
					"#{letter}—#{score}"
				end
				"possible letter scores for “#{@env.current_letters}”: #{printable_letter_scores.join(" ")}"
			end
			best_score = possible_letter_scores.values.max
			$logger.debug { "best score for “#{@env.current_letters}”: #{best_score}" }
			best_letters = possible_letter_scores.select { |letter, score| score == best_score }.keys
			best_letters
		else
			possible_letters
		end
	end
	public
	
	def random_best_response
		best_responses.sample
	end
	
	private
	def possible_response_letters
		good_wordlist.map { |word| word[@env.current_letters.length, 1] }.uniq
	end
	public
	
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
			next_prediction = analysis.random_best_response
			$logger.debug { "predicted response to “#{simulated_env.current_letters}”: #{next_prediction}" }
			
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
