def load_wordlist
	wordlist_file_path = "config/enable1.txt"
	return File.open(wordlist_file_path, 'r') do |wordlist_file|
		wordlist_file.each_line.map(&:strip)
	end
end
