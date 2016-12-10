require "byebug"

class Hangman
    attr_reader :guesser, :referee, :board

    def initialize(players)
        @referee = players[:referee]
        @guesser = players[:guesser]
        @board = []
    end

    def setup
        word_length = referee.pick_secret_word
        guesser.register_secret_length(word_length)
        word_length.times { |i| board << "-" }
        puts board.join("")
    end

    def take_turn
        guessed_letter = guesser.guess(board)
        puts guessed_letter
        letter_index = referee.check_guess(guessed_letter)
        update_board(letter_index, guessed_letter)
        guesser.handle_response(guessed_letter, letter_index)
    end

    def update_board(index, letter)
        index.each { |idx| board[idx] = letter }
        puts "Secret Word: #{board.join("")}"
    end

    def play
        setup
        while board.include?("-")
            take_turn
        end

        puts "You win, the secret word is #{board.join("")}"
    end

end

class HumanPlayer
    def initialize(name)
        @name = name
    end

    def register_secret_length(length)
        puts "The length of the secret word is #{length}"
    end

    def pick_secret_word
        puts "Enter the length of the word"
        gets.chomp.to_i
    end

    def handle_response
    end

    def guess
        puts "Make a guess"
        gets.chomp
    end

    def check_guess(letter)
        puts "Is #{letter} appearing in the word?"
        gets.chomp.split(",").map(&:to_i)
    end
end

class ComputerPlayer
    attr_reader :dictionary, :word, :candidate_words

    def initialize(dictionary)
        @dictionary = dictionary
    end

    def pick_secret_word
        @word = dictionary.sample.chomp
        word.length
    end

    def check_guess(letter)
        (0...word.length).select { |idx| word[idx] == letter }
    end

    def register_secret_length(length)
        @word_length = length
        @candidate_words = dictionary.select { |word| word.length == @word_length }
    end

    def guess(board)
        most_common_words.each { |char| return char if !board.include?(char) }
    end

    def handle_response(letter, index)
        index.each do |idx|
            @candidate_words = candidate_words.select { |word| word[idx] == letter }
        end

        @candidate_words = candidate_words.select { |word| word.count(letter) == index.length }
    end

    private
    def most_common_words
        characters = candidate_words.join("").chars
        characters.uniq.map { |char| [char, characters.count(char)] }.sort do |x, y|
            y[1] <=> x[1]
        end.map { |char, count| char }
    end
end

if __FILE__ == $PROGRAM_NAME
    dictionary = File.readlines("dictionary.txt").map { |word| word.chomp }
    Hangman.new(referee: HumanPlayer.new("john"), guesser: ComputerPlayer.new(dictionary)).play
end
