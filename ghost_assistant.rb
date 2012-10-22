require 'rubygems'
require 'memoize'
include Memoize


# environment setup section

MINIMUM_WORD_LENGTH = 3
NUM_OF_WORDS_TO_SHOW = 10
DEBUG = false

wordlist = Array.new
File.open("enable1.txt", "r") do |wordlist_file|
	wordlist_file.each_line do |line|
		wordlist.push(line.strip)
	end
end

# TODO input validation and defaults
puts "GHOST word game assistant"
puts "How many people are playing? (default 2)"
num_of_players = gets.chomp.to_i
# num_of_players = 2; puts num_of_players
puts "What letters have been said so far?"
current_letters = gets.chomp.strip.downcase
# current_letters = "lar"; puts current_letters
# TODO fix bug given input above
# current_letters = "pemm"; puts current_letters
# TODO fix bug where score is 1/2 but should be 1 given input above

# TODO optionally, remove a word from the wordlist after it has been used
# TODO make a computer opponent (as opposed to helper) or group of opponents to play in any game (unnecessary)

# TODO if can find a suitable wordlist, use two wordlists:
# a full one, listing the words it will accept, and a subset calculated based on
# frequency of use of the *root* word(s) in various texts, listing words the program will use.
# The difference between the sets are words the program pretends not to know,
# until someone else has used it in a recent game.

# analysis section

class GhostEnvironment
	attr_reader :wordlist, :current_letters, :num_of_players
	# TODO use def_init, initializer, or a customization
	def initialize(wordlist, current_letters, num_of_players)
		@wordlist = wordlist
		@current_letters = current_letters
		@num_of_players = [num_of_players.to_i, 2].max
	end
	
	def env_by_saying_letter(letter)
		GhostEnvironment.new(wordlist, current_letters + letter, num_of_players)
	end
end

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
			# return good_wordlist.choice[@env.current_letters.length, 1]
			
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
				best_letters.choice
				# TODO do I need to do something about choice using the same random seed each run?
				# TODO make variant method that returns all best letters, instead of a random one,
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

ghost_environment = GhostEnvironment.new(wordlist, current_letters, num_of_players)
analysis = GhostAnalysis.new(ghost_environment)


# analysis results output section

def print_truncated_wordlist_with_modified_description(wordlist, description)
	description.sub!("NUM", wordlist.length.to_s)
	description.sub!("WORDS", wordlist.length == 1 ? "word" : "words")
	description += "; random #{NUM_OF_WORDS_TO_SHOW}" if wordlist.length > NUM_OF_WORDS_TO_SHOW
	description += wordlist.length == 0 ? "." : ":"
	puts description
	
	if wordlist.length <= NUM_OF_WORDS_TO_SHOW
		wordlist_subset = wordlist
	else
		starting_word_offset = Kernel::rand(wordlist.length - NUM_OF_WORDS_TO_SHOW)
		wordlist_subset = wordlist[starting_word_offset, NUM_OF_WORDS_TO_SHOW]
	end
	puts wordlist_subset.join("\n")
end

num_possible_words = analysis.possible_wordlist.length
# print "#{num_possible_words} "
# if num_possible_words == 1
# 	print "word starts"
# else
# 	print "words start"
# end
# puts " with “#{current_letters}”"
print_truncated_wordlist_with_modified_description( \
 analysis.possible_wordlist, "NUM WORDS start with “#{current_letters}”")

num_good_words_found = analysis.good_wordlist.length
if num_good_words_found == 0
	
	puts "No suitable words were found."
	if analysis.possible_wordlist.length > 0
		print_truncated_wordlist_with_modified_description( \
		 analysis.possible_wordlist, "NUM WORDS could get you out")
	else
		puts "You should challenge."
	end
	
else
	
	if analysis.good_wordlist.first == current_letters
		puts "“#{current_letters}” is already a word."
		analysis.good_wordlist.shift
		
		if num_good_words_found == 1
			puts "There are no other suitable words."
		else
			if num_of_players > 2				
				if analysis.good_words_kind_to_previous_player.length > 0
					print_truncated_wordlist_with_modified_description( \
					 analysis.good_words_kind_to_previous_player, "NUM other suitable WORDS don’t get the previous player out")
				end
				if analysis.good_words_that_get_previous_player.length > 0
					print_truncated_wordlist_with_modified_description( \
					 analysis.good_words_that_get_previous_player, "NUM other suitable WORDS get the previous player out")
				end
			else
				print_truncated_wordlist_with_modified_description( \
				 analysis.good_wordlist, "NUM other suitable WORDS")
			end
		end
	else
		print_truncated_wordlist_with_modified_description( \
		 analysis.good_wordlist, "NUM suitable WORDS found")
		suggested_response = analysis.suggested_response
		puts "Suggested letter to say: #{suggested_response.upcase}, with score #{analysis.score(suggested_response)}"
		next_env = analysis.environment.env_by_saying_letter(suggested_response)
		next_analysis = GhostAnalysis.new(next_env)
		# TODO show any of the shortest possible words (reject all with more than min length; choose one randomly)
		legitimate_possible_word = next_analysis.possible_wordlist.first
		puts "A word starting with “#{current_letters + suggested_response}”: #{legitimate_possible_word}"
		# TODO move word starting with and score into analysis, and check if was only possible letter
		# TODO for word starting with letters + response, suggest a word that
		# follows the path of both players doing their best
	end
	
end