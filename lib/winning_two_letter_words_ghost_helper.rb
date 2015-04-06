# calculate guaranteed-win n-letter words, assuming certain rules about word length
# those rules are “n-letter and shorter words are safe” and
# “n-letter and shorter words are allowable responses to ‘I challenge’”

require_relative 'wordlist_loader'

wordlist = load_wordlist()
target_word_length = 2
two_letter_words = wordlist.select {|word| word.length == target_word_length}

puts "#{target_word_length}-letter words that start no other words:"
two_letter_words.each do |two_letter_word|
	starts_no_other_words = wordlist.none? do |word|
		word.start_with?(two_letter_word) && word.length >= (target_word_length + 1)
	end
	puts two_letter_word if starts_no_other_words
end
