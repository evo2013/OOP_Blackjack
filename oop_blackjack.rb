require 'pry'

class Deck
  attr_accessor :cards

  def initialize
    faces = [ 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K", "A"]
    suits = ['♣', '♦', '♥', '♠']
    @cards = []

    faces.each do |face|
      suits.each do |suit|;
        @cards << [face, suit]
      end
    end
    return @cards
  end

  def display_deck #not needed
    cards.each do |card|
      puts
      puts card
      puts 
    end
  end

  def shuffle!
    cards.shuffle!
  end

  def deal_a_card
    cards.pop
  end

  def count  #not needed
    cards.length
  end
end

module Hand

  attr_accessor :cards, :total

  def initialize
    @cards = []
  end

  def hit(new_card)
    @cards << new_card
  end

  def score
    arr = cards.map {|card| card[0] }

    self.total = 0
    arr.each do |value|
      if value == "A"
        self.total += 11 
      elsif value.to_i == 0
        self.total += 10
      else 
        self.total += value
      end
    end

    #correct for Aces
    arr.select{|e| e == "A"}.count.times do
      self.total > 21 ? self.total -= 10 : break
    end
    self.total
  end

  def win_or_bust?
    if self.total == 21
      puts "\nCongratulations, #{self.name} has won!\n"
      abort
    elsif self.total > 21
      puts "\nSorry, #{self.name} has gone bust!\n"
      abort
    end
  end

  def win_by_comparison(winner)
    puts ".......Comparing the two scores......"
    sleep 3
    puts "#{winner} has won this round!"
    abort
  end

  def compare(dealer1, player1)
    puts "#{player1.name} has a total of #{player1.total}. The dealer has a total of #{dealer1.total}."
    sleep 3
    if dealer1.total == player1.total
      win_by_comparison("No one")
      abort
    elsif dealer1.total > player1.total
      win_by_comparison(Dealer)
      abort
    else
      win_by_comparison(player1.name)
      abort
    end
  end

  def display_hand
    puts "\n#{self.name}'s hand holds: #{@cards.first.first} of #{@cards.first.last}  & #{@cards[1][0]} of #{@cards[1][1]}\n"
    puts "For a total score of: #{self.total}"
  end

  def update_hand
    puts "\n#{self.name}, the new card is: #{@cards.last.first} of #{@cards.last.last}\n"
    puts "For a new score of: #{self.total}"
  end
end

class Player
  include Hand

  attr_accessor :name, :cards, :hands, :blackjack
  RESPONSES = ["h", "s"]

  def initialize
    @cards = []
    @name = get_name
    @hands = []
  end

  def get_name
    puts "What is your name?"
    name = gets.chomp.capitalize
    name
  end

  def choose_hit(cards, deck1)
    loop do
      puts "Would you like to [H]it or [S]tay - H/S?"
      hit_or_stay = gets.chomp.downcase
      if hit_or_stay == "h" 
        cards << deck1.deal_a_card 
        self.score
        self.update_hand
        self.win_or_bust?
      elsif hit_or_stay == "s"
        puts "......Dealer's Turn to play......."
        sleep 2
        "s"
        break
      else
        puts "Invalid option"         
      end
    end
  end
end

class Dealer < Player
  include Hand

  attr_accessor :name, :cards, :hands
  MIN_VALUE = 17

  def initialize
    @cards = []
    @name = "dealer"
    @hands = []
  end

  def choose_hit(cards, deck1, dealer1, player1)
    loop do
      dealer1.win_or_bust?
      if dealer1.total >= MIN_VALUE
        compare(dealer1, player1)
      elsif dealer1.total < MIN_VALUE
        puts "......dealer is taking a hit......"
        sleep 2
        cards << deck1.deal_a_card 
        dealer1.score
        dealer1.update_hand
      end         
    end
  end
end

class Blackjack
  include Hand

  def initialize
   puts "
***********************************************************
          Welcome to Command Line Blackjack!
             Winner gets closest to 21.
          Player gets 1st turn before Dealer.
*********************************************************** 
   " 
   @deck1 = Deck.new
   @dealer1 = Dealer.new
   @player1 = Player.new
   2.times do
      @deck1.shuffle!
   end
  end

  def player_turn
    @player1.hit(@deck1.deal_a_card)
    @player1.hit(@deck1.deal_a_card)
    @player1.hands = @player1.cards
    @player1.score
    @player1.display_hand
    @player1.win_or_bust?

    @player1.choose_hit(@player1.cards, @deck1)
    @player1.score
    @player1.update_hand
    @player1.win_or_bust?
  end

  def dealer_turn
    @dealer1.hit(@deck1.deal_a_card)
    @dealer1.hit(@deck1.deal_a_card)
    @dealer1.hands = @dealer1.cards
    @dealer1.score
    @dealer1.display_hand
    @dealer1.win_or_bust?

    @dealer1.choose_hit(@dealer1.cards, @deck1, @dealer1, @player1)
    @dealer1.score
    @dealer1.update_hand
    @dealer1.win_or_bust?
  end

  def play
    loop do 
      player_turn
      dealer_turn
      break if play_again? == "q"
    end
    puts "Bye. Let's Play again sometime."
  end

  # def play_again?
  #   loop do
  #     puts "Would you like to [P]lay again or [Q]uit - P/Q?"
  #     play_answer = gets.chomp.downcase
  #     if play_answer == "p"
  #       @deck1 = Deck.new
  #       @player1.cards = []
  #       @dealer1.cards = []
  #       2.times do
  #         @deck1.shuffle!
  #         @player1.hit(@deck1.deal_a_card)
  #         @dealer1.hit(@deck1.deal_a_card)
  #       end
  #       play
  #     elsif play_answer == "q"
  #       exit
  #     else
  #       puts "Invalid option. Enter 'P' to play again or 'Q' to quit."
  #     end
  #   end
  # end
end

@blackjack = Blackjack.new
@blackjack.play
