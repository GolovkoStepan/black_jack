# frozen_string_literal: true

module BlackJack
  module Common
    module Player
      attr_accessor :account

      def add_card(card)
        @cards << card
      end

      def add_random_card
        @cards << Card.random_card
      end

      def cards
        @cards ||= []
      end

      def current_score
        Card.cards_sum(@cards)
      end
    end
  end
end
