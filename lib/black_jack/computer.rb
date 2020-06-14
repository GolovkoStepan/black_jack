# frozen_string_literal: true

require_relative 'common/player'

module BlackJack
  class Computer
    include Common::Player

    def initialize(account)
      @account = account
    end

    def choose_action
      current_score >= 17 ? :skipping : :take_card
    end
  end
end
