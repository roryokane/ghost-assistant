# encoding: utf-8

require_relative 'wordlist_loader'

wordlist = load_wordlist()

# calculate guaranteed-win n-letter words, assuming certain rules about word length
# those rules are “n-letter and shorter words are safe” and
# “n-letter and shorter words are allowable responses to ‘I challenge’”
target_word_length = 2
two_letter_words = wordlist.reject {|word| word.length != target_word_length}
puts "#{target_word_length}-letter words that start no other words:"
two_letter_words.each do |two_letter_word|
	words_starting_with_the_tlw = wordlist.reject { |word| ! word.start_with?(two_letter_word) || word.length < (target_word_length + 1) } [0..10]
	puts two_letter_word if words_starting_with_the_tlw.empty?
end