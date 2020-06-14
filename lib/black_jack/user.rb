# frozen_string_literal: true

require_relative 'common/player'

module BlackJack
  class User
    include Common::Player

    def initialize(account)
      @account = account
    end
  end
end
