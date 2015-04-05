class GhostEnvironment
	attr_reader :wordlist, :current_letters, :num_of_players
	# TODO use def_init, initializer, or a customization
	def initialize(wordlist, current_letters, num_of_players)
		@wordlist = wordlist
		@current_letters = current_letters
		@num_of_players = num_of_players.to_i
		
		raise "the number of players must be at least 2" if @num_of_players < 2
	end
	
	def env_by_saying_letter(letter)
		GhostEnvironment.new(wordlist, current_letters + letter, num_of_players)
	end
end
