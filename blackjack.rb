class Card
  attr_accessor :suit, :name, :value

  def initialize(suit, name, value)
    @suit, @name, @value = suit, name, value
  end
end

class Deck
  attr_accessor :playable_cards
  SUITS = [:hearts, :diamonds, :spades, :clubs]
  NAME_VALUES = {
    :two   => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 10,
    :queen => 10,
    :king  => 10,
    :ace   => [11, 1]}

  def initialize
    shuffle
  end

  def deal_card
    random = rand(@playable_cards.size)
    @playable_cards.delete_at(random)
  end

  def shuffle
    @playable_cards = []
    SUITS.each do |suite|
      NAME_VALUES.each do |name, value|
        @playable_cards << Card.new(suite, name, value)
      end
    end
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

end


class Round

  attr_accessor :gamedeck, :player, :dealer, :playerscore, :dealerscore, :playerstand, :playersofthand, :dealersofthand

  def initialize
    @gamedeck = Deck.new
    @player = Hand.new
    @dealer= Hand.new
    @playerstand = false
    @playersofthand = 0
    @dealersofthand = 0
    start_round
    display_table
  end

  def start_round
    @player.cards << @gamedeck.deal_card
    @dealer.cards << @gamedeck.deal_card
    @player.cards << @gamedeck.deal_card
    @dealer.cards << @gamedeck.deal_card
    update_scores
  end

  def display_table
    puts "---------------------------------"
    puts
     puts " Score: "
     puts " Player #{@playerscore}"
     puts " Dealer #{@dealerscore}"
    puts
    puts "  Player has: "
    for card in @player.cards
      puts "  [#{card.name} of #{card.suit}]"
    end
    puts
    puts "  Dealer has: "
    if playerstand == false
      puts "  [##############]"
      puts "  [#{@dealer.cards[1].name} of #{@dealer.cards[1].suit}]"
    else
      for card in @dealer.cards
        puts "  [#{card.name} of #{card.suit}]"
      end
    end
     puts
     puts "---------------------------------"
     
  end

    def update_scores
      @playerscore = 0
      @dealerscore = 0
      for card in @player.cards
        if card.name == :ace
          @playersofthand += 1
          if @playerscore >= 11
            @playerscore += 1
          else
            @playerscore += 11
          end
        else
          @playerscore += card.value
        end
      end

      if playerstand == false
        if @dealer.cards[1].name == :ace
          @dealersofthand += 1
          @dealerscore += 11
        else
          @dealerscore += @dealer.cards[1].value
        end
      else
        for card in @dealer.cards
          if card.name == :ace
            @dealersofthand += 1
            if @dealerscore >= 11
              @dealerscore += 1
            else
              @dealerscore += 11
            end
          else
            @dealerscore += card.value
          end
        end
      end

      if @playerscore > 21 && playersofthand > 0
        @playerscore -= 10
        @playersofthand -= 1
      end

      if @dealerscore > 21 && dealersofthand > 0
          @dealerscore -= 10
          @dealersofthand -= 1
      end
    end

    def dealers_turn
      update_scores
      display_table
      while @dealerscore < 21
        if @dealerscore >= 17
          break
        end
        sleep(5)
        @dealer.cards << @gamedeck.deal_card
        update_scores
        display_table

      end
    end

     
    

end

class Game
  
  while true

    puts
    puts "Welcome to blackjack! A new round will begin shortly. To exit at any time, type 'exit' when prompted for stand or hit move"
    puts 
    sleep(7)

    round = Round.new
    while round.playerscore < 21
      puts "stand or hit?(S/H)"
      decision = gets.chomp
      if decision == "S"
        round.playerstand = true
        round.dealers_turn
        break
      elsif decision == "H"
        round.player.cards << round.gamedeck.deal_card
        round.update_scores
        round.display_table

      

      elsif decision == "exit"
        exit(0)
      else
        puts "An error has occured on input"
      end
    end

    puts

    if round.playerscore == 21 && round.player.cards.size == 2
      puts ">>>Blackjack! You win!<<<"
    elsif round.playerscore == 21
      puts ">>>21! You win!<<<"
    elsif round.playerscore > 21
      puts ">>>Bust. You lose.<<<"
    elsif round.dealerscore == 21
      puts ">>>Dealer 21. You lose.<<<"
    elsif round.dealerscore > 21
      puts ">>>Dealer bust. You win!<<<"
    elsif round.playerscore > round.dealerscore
      puts ">>>You win!<<<"
    elsif round.playerscore < round.dealerscore
      puts ">>>You lose.<<<"
    else
      puts ">>>Push. No contest.<<<"
    end
    puts

    while true
      puts "Keep Playing?(Y/N)"
      decision = gets.chomp
      if decision == "N"
        exit(0)
      elsif decision == "Y"
        break
      else
        puts "An error has occured on input"
        next
      end
    end

  end
end

game = Game.new

require 'test/unit'

class CardTest < Test::Unit::TestCase
  def setup
    @card = Card.new(:hearts, :ten, 10)
  end
  
  def test_card_suit_is_correct
    assert_equal @card.suit, :hearts
  end

  def test_card_name_is_correct
    assert_equal @card.name, :ten
  end
  def test_card_value_is_correct
    assert_equal @card.value, 10
  end
end

class DeckTest < Test::Unit::TestCase
  def setup
    @deck = Deck.new
  end
  
  def test_new_deck_has_52_playable_cards
    assert_equal @deck.playable_cards.size, 52
  end
  
  ####
  def test_dealt_card_should_not_be_included_in_playable_cards
    card = @deck.deal_card
    refute(@deck.playable_cards.include?(card))
  end

  def test_shuffled_deck_has_52_playable_cards
    @deck.shuffle
    assert_equal @deck.playable_cards.size, 52
  end
end

