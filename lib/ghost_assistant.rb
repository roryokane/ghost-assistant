# encoding: utf-8

# environment setup section

NUM_OF_WORDS_TO_SHOW = 10

require_relative 'wordlist_loader'
wordlist = load_wordlist()

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

require_relative 'ghost_environment'
require_relative 'ghost_analysis'

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
		new_letters = current_letters + suggested_response
		puts "Suggested letter to say: #{suggested_response.upcase} (forming “#{new_letters}”), with score #{analysis.score(suggested_response)}"
		next_env = analysis.environment.env_by_saying_letter(suggested_response)
		next_analysis = GhostAnalysis.new(next_env)
		# TODO show any of the shortest possible words (reject all with more than min length; choose one randomly)
		legitimate_possible_word = next_analysis.possible_wordlist.first
		puts "A word starting with “#{new_letters}”: #{legitimate_possible_word}"
		# TODO move word starting with and score into analysis, and check if was only possible letter
		# TODO for word starting with letters + response, suggest a word that
		# follows the path of both players doing their best
	end
	
end