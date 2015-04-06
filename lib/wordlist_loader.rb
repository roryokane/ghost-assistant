WORDLIST_FILE_PATH = "config/enable1.txt"

def load_wordlist
	return File.open(WORDLIST_FILE_PATH, 'r') do |wordlist_file|
		wordlist_file.each_line.map(&:chomp)
	end
end
