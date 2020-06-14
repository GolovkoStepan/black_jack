# frozen_string_literal: true

require 'tty-prompt'

module BlackJack
  module Interface
    def prompt
      @prompt ||= TTY::Prompt.new
    end

    def render_game_board(comp, user)
      puts '=== Карты диллера:'
      puts inline_cards_render comp.cards.map(&:hidden_card)

      puts '=== Ваши карты:'
      puts inline_cards_render user.cards.map(&:format_card)

      puts "=== Ваш счет: #{user.current_score}"
    end

    def render_bets_info(comp, user, bank)
      puts "=== Ваш остаток: $#{user.account}"
      puts "=== Остаток диллера: $#{comp.account}"
      puts "=== Банк: $#{bank}"
      puts ''
    end

    def render_all(comp, user, bank)
      render_bets_info(comp, user, bank)
      render_game_board(comp, user)
    end

    def render_actions_menu(user)
      choices = [
        { name: 'Пропустить ход', value: :skipping },
        { name: 'Добавить карту', value: :take_card },
        { name: 'Открыть карты', value: :open_cards }
      ]

      if user.cards.count == 3
        choices[1].merge!({ disabled: '(у вас уже 3 карты)' })
      end

      prompt.select('Выберите действие', choices)
    end

    def render_all_cards(comp, user, bank)
      render_bets_info(comp, user, bank)

      puts '=== Карты диллера:'
      puts inline_cards_render comp.cards.map(&:format_card)

      puts '=== Ваши карты:'
      puts inline_cards_render user.cards.map(&:format_card)

      puts "=== Ваш счет: #{user.current_score}"
    end

    def render_round_result(comp, user, bank, options)
      wait_and_clean
      render_all_cards(@comp, @user, bank)

      puts ''
      puts "Счет игрока:  #{user.current_score}"
      puts "Счет диллера: #{comp.current_score}"

      case options[:winner]
      when :comp
        puts 'Диллер выйграл!'
      when :user
        puts 'Игрок выйграл!'
      when :dead_heat
        puts 'Ничья!'
      else
        puts 'Победителя нет!'
      end
    end

    def user_move_msg(msg)
      puts "Ход игрока: #{msg}"
    end

    def comp_move_msg(msg)
      puts "Ход диллера: #{msg}"
    end

    def inline_cards_render(cards)
      first, *rest = cards.map { |card| card.split("\n") }
      first.zip(*rest).map { |lines| lines.join('') }.join("\n")
    end

    def wait_and_clean(for_sec: 0, msg: nil)
      puts msg if msg
      sleep for_sec
      system 'clear'
    end

    def wait_user_input
      prompt.keypress('Для продолжения нажмите любую клавишу...')
    end
  end
end
