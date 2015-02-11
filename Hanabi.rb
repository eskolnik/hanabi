#TODO Hint history
#TODO Hint Legality check
#TODO UI improvements
$colors = ["r", "y", "b", "g", "w"]
$ranks = ["1", "2", "3", '4', '5']

class Card
  attr_accessor :color, :rank
  def initialize color, rank
    @rank = rank
    @color = color
  end
  def to_s
    @color.to_s + " " +@rank.to_s
  end
  
end

#TODO readability
class Meta
  attr_accessor :colors, :ranks
  def initialize 
    @colors = $colors.clone
    @ranks = $ranks.clone
  end
  def to_s
    @colors.join + "/" + @ranks.join
  end
   
end

class Player
  attr_accessor :hand, :name
  def initialize name
    @name = name
    @hand = []
  end
  def draw c
    @hand.push [c, Meta.new] unless c.nil?
  end

  def discard pos
    return nil if @hand.size <= 0
    discard = @hand[pos]
    @hand.delete_at pos
    return discard[0]
  end
  
  #TODO - Convert display to actual card names
  def show_hand
    return hand.collect {|x| x[0].to_s}
  end
  def show_meta
    return hand.collect {|x| x[1].to_s}
  end
  
  #FIXME finish this thing
  #check if the hand contains any cards with the given propery
  def legal_hint(key)
    #!@hand.index {|x| x.include? key}.nil?
    true
  end
  
  #FIXME check hint legality  
  def give_hint key
    counter=0
    @hand.each do |card, meta|
      if $colors.include? key
        if card.color==key 
          meta.colors=[key]
          counter+=1
        else
          meta.colors.delete key
        end       
      else
        if card.rank==key 
          counter+=1
          meta.ranks=[key]
        else
          meta.ranks.delete key
        end
      end
    end
    return counter
   end
   
end

class Board
  attr_accessor :piles, :deck, :discard, :fuse, :hints
  def initialize
    @deck = new_deck
    @discard=[]
    @piles = Hash[$colors.collect {|x| [x,0]}]
    @fuse = 3
    @hints = 8
  end
  def legal? card
    piles[card.color] == card.rank.to_i - 1
  end
  def play card
    if legal? card
      piles[card.color] +=1
    end
  end  
  def new_deck
    $colors.inject([]) do |deck, color|
      deck+=[1,1,1,2,2,3,3,4,4,5].collect{|x| Card.new color, x.to_s}
    end.shuffle
  end
  def draw
    return @deck.pop
  end
  def discard c
    @discard.push c
  end
  def mistake
    @fuse -= 1
  end
  
  # return a pile as a string
  def dp x
    if x.to_i >= 1 
      return (1..x.to_i).to_a.join " "
    else
      return 0
    end
  end
  
  # TODO
  # show discarded cards in readable format
  def display
    puts "---BOARD---"
    puts "Red: #{dp @piles['r']}, Yellow: #{dp @piles['y']}, Blue: #{dp @piles['b']}, Green: #{dp @piles['g']}, White: #{dp @piles['w']}"
    puts "Fuse Remaining: #{@fuse}"
    puts "Discards: #{@discard}"
  end
end

def main 
  board = Board.new
  players = [(Player.new "Rose"), (Player.new "Colin")]
  players.each {|x| 5.times {x.draw board.draw}}
  gameloop board, players[0], players[1]
end

# TODO
# Catch illegal input types
# implement win and lose conditions
# -- implement mistake detection
# -- implement deck depletion  
# -- better display
# -- >2players
def gameloop board, active, passive
  #on a players turn, show all other players hands.
  #show own hand meta info
  #allow choice of 3 moves: play, discard, hint  
  puts "#{active.name}'s Turn"
  puts "#{active.name}'s Hand: #{active.show_meta}"
  puts "#{passive.name}'s Hand: #{passive.show_hand}"
  
  #show board state
  board.display
  
  #menu loop
  while true
    puts "Choose play, discard, or hint"
    menu1 = gets.chomp.downcase
    case menu1 
    when 'play', 'p', '1'
      puts "Play which card?"
      play = gets.chomp.to_i - 1
      if play < 0 || play >= active.hand.size
        puts "That's not a card in your hand"
        next
      else
        card = active.discard play
        if board.legal? card
          board.play card
          puts "#{active.name} successfully played #{card.to_s}"
        else 
          board.mistake
          puts "BOOM! #{card.to_s} exploded! #{board.fuse} errors remain."
        end
        active.draw board.draw
        break
      end
      
    when 'discard', 'd', '2'
      puts "Discard which card?"
      discard = gets.chomp.to_i - 1
      if discard < 0 || discard >= active.hand.size
        puts "That's not a card in your hand"
        next
      else
        card = active.discard discard
        board.discard card
        active.draw board.draw
        puts "#{active.name} discarded #{card.to_s}"
        break
      end
    
    when 'hint', 'h', '3'
      puts "Hint about which attribute?"
      hint=gets.chomp
      if passive.legal_hint(hint)
        c=passive.give_hint hint
        puts "#{active.name} told #{passive.name} that they have #{c} #{hint} cards."
        break
      else
        puts "Illegal hint"
      end
    #DEBUG TOOL 
    #when 'myhand'
    #  puts "#{active.name}'s Hand: #{active.show_hand}"
    else
      puts "Try again"
    end
  end
  
  gameloop board, passive, active
end

main

