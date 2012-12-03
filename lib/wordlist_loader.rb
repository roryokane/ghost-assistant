# encoding: utf-8

def load_wordlist
	wordlist = Array.new
	wordlist_file_path = "lib/enable1.txt"
	File.open(wordlist_file_path, 'r') do |wordlist_file|
		wordlist_file.each_line do |line|
			wordlist.push(line.strip)
		end
	end
	return wordlist
end