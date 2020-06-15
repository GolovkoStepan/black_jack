# frozen_string_literal: true

module BlackJack
  # Playing card model
  class Card
    RANKS_NUMS    = %w[2 3 4 5 6 7 8 9 10].freeze
    RANKS_LETTERS = %w[J Q K].freeze
    RANKS_ACE     = 'A'

    RANKS = RANKS_NUMS + RANKS_LETTERS << RANKS_ACE
    SUITS = %w[♠ ♣ ♥ ♦].freeze

    attr_reader :rank, :suit

    def initialize(suit:, rank:)
      @suit = suit
      @rank = rank
    end

    class << self
      attr_reader :cards

      def generate_cards
        @cards = []

        SUITS.each do |suit|
          RANKS.each { |rank| @cards << new(suit: suit, rank: rank) }
        end

        @cards.shuffle!
      end

      def random_card
        @cards.shift
      end

      def cards_sum(cards)
        ranks_sum = 0
        ace_count = 0

        cards.each do |card|
          ranks_sum += card.rank.to_i if RANKS_NUMS.include? card.rank
          ranks_sum += 10 if RANKS_LETTERS.include? card.rank
          ace_count += 1 if card.rank == RANKS_ACE
        end

        if ranks_sum + 10 + ace_count <= 21 && ace_count.positive?
          ranks_sum += 10
        end

        ranks_sum + ace_count
      end
    end

    def format_card
      format(<<~ASCII, @rank.ljust(2), @suit, @rank)
        ┌─────────┐
        │%2s       │
        │         │
        │         │
        │    %s    │
        │         │
        │         │
        │       %2s│
        └─────────┘
      ASCII
    end

    def hidden_card
      <<~ASCII
        ┌─────────┐
        │░░░░░░░░░│
        │░░░░░░░░░│
        │░░░░░░░░░│
        │░░░░░░░░░│
        │░░░░░░░░░│
        │░░░░░░░░░│
        │░░░░░░░░░│
        └─────────┘
      ASCII
    end

    def to_s
      "#{@rank}#{@suit}"
    end
  end
end
