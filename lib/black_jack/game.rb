# frozen_string_literal: true

require_relative 'interface'

module BlackJack
  class Game
    include Interface

    OPENING_ACCOUNT = 100
    BET_PER_STEP    = 10

    attr_reader :bank

    def initialize
      @user = User.new OPENING_ACCOUNT
      @comp = Computer.new OPENING_ACCOUNT

      loop do
        wait_and_clean
        start_game_round

        if @user.account.zero?
          print_msg 'У вас закончились деньги. Вы не можете больше играть!'
          break
        end

        if @comp.account.zero?
          print_msg 'У диллера закончились деньги. Он не может больше играть!'
          break
        end

        break unless continue_game?
      end
    end

    def start_game_round
      Card.generate_cards
      make_bets { |comp, user, bank| render_bets_info(comp, user, bank) }
      deal_cards { |comp, user| render_game_board(comp, user) }

      @end_round = false
      loop do
        if @end_round || (@user.three_cards_taken? && @comp.three_cards_taken?)
          break
        end

        user_move { render_actions_menu(@user) }
        comp_move unless @end_round

        wait_and_clean for_sec: 2.5
        render_all(@comp, @user, bank)
      end

      round_result do |options|
        render_round_result(@comp, @user, bank, options)
      end
    end

    private

    def round_result
      comp_score = @comp.current_score
      user_score = @user.current_score

      return yield({ winner: nil }) if comp_score > 21 && user_score > 21

      if user_score > 21 || (comp_score > user_score && comp_score <= 21)
        @comp.account += bank
        @bank = 0
        return yield({ winner: :comp })
      end

      if comp_score > 21 || (user_score > comp_score && user_score <= 21)
        @user.account += bank
        @bank = 0
        return yield({ winner: :user })
      end

      @user.account += bank / 2
      @comp.account += bank / 2
      @bank = 0

      yield({ winner: :dead_heat })
    end

    def user_move
      choice = yield
      send("user_#{choice}")
    end

    def comp_move
      choice = @comp.choose_action
      send("comp_#{choice}")
    end

    def user_skipping
      user_move_msg 'Вы пропускаете ход'
    end

    def user_take_card
      return user_skipping if @user.three_cards_taken?

      @user.add_random_card
      user_move_msg 'Вы берете карту'
    end

    def user_open_cards
      @end_round = true
      user_move_msg 'Все открывают карты'
    end

    def comp_skipping
      comp_move_msg 'Диллер пропускает ход'
    end

    def comp_take_card
      return comp_skipping if @comp.three_cards_taken?

      @comp.add_random_card
      comp_move_msg 'Диллер берет карту'
    end

    def make_bets
      @user.account -= BET_PER_STEP
      @comp.account -= BET_PER_STEP
      @bank = @bank.nil? ? BET_PER_STEP * 2 : @bank + BET_PER_STEP * 2

      yield(@comp, @user, @bank) if block_given?
    end

    def deal_cards
      @user.remove_cards
      @user.add_random_card 2

      @comp.remove_cards
      @comp.add_random_card 2

      yield(@comp, @user) if block_given?
    end
  end
end
