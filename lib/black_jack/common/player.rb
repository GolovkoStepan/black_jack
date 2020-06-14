# frozen_string_literal: true

module BlackJack
  module Common
    module Player
      attr_accessor :account

      def add_card(card)
        @cards << card
      end

      def add_random_card(count = 1)
        @cards ||= []
        count.times { @cards << Card.random_card }
      end

      def cards
        @cards ||= []
      end

      def current_score
        Card.cards_sum(@cards)
      end

      def three_cards_taken?
        cards.count == 3
      end
    end
  end
end
