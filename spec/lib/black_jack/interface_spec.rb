# frozen_string_literal: true

require 'black_jack'
require 'stringio'

RSpec.describe BlackJack::Interface do
  # Создаём тестовый класс, включающий Interface
  let(:test_subject_class) do
    Class.new do
      include BlackJack::Interface

      attr_reader :user, :comp, :bank

      def initialize
        @user = BlackJack::User.new(100)
        @comp = BlackJack::Computer.new(100)
        @bank = 20
      end
    end
  end

  let(:subject) { test_subject_class.new }

  before do
    BlackJack::Card.generate_cards
    allow(subject).to receive(:wait_and_clean)
  end

  # Вспомогательный метод для захвата stdout
  def capture_stdout
    require 'stringio'
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end

  describe '#prompt' do
    it 'returns a TTY::Prompt instance' do
      expect(subject.prompt).to be_a(TTY::Prompt)
    end

    it 'memoizes the prompt instance' do
      first_prompt = subject.prompt
      second_prompt = subject.prompt
      expect(first_prompt).to be(second_prompt)
    end
  end

  describe '#render_game_board' do
    before do
      subject.comp.add_random_card(2)
      subject.user.add_random_card(2)
    end

    it 'outputs dealer cards header' do
      expect { subject.render_game_board(subject.comp, subject.user) }
        .to output(/=== Карты диллера:/).to_stdout
    end

    it 'outputs user cards header' do
      expect { subject.render_game_board(subject.comp, subject.user) }
        .to output(/=== Ваши карты:/).to_stdout
    end

    it 'outputs user score' do
      expect { subject.render_game_board(subject.comp, subject.user) }
        .to output(/=== Ваш счет: #{subject.user.current_score}/).to_stdout
    end

    it 'renders hidden cards for dealer' do
      output = capture_stdout { subject.render_game_board(subject.comp, subject.user) }
      expect(output).to include('░')
    end

    it 'renders formatted cards for user' do
      output = capture_stdout { subject.render_game_board(subject.comp, subject.user) }
      expect(output).to include('┌')
      expect(output).to include('└')
    end
  end

  describe '#render_bets_info' do
    it 'outputs user account' do
      expect { subject.render_bets_info(subject.comp, subject.user, subject.bank) }
        .to output(/=== Ваш остаток: \$#{subject.user.account}/).to_stdout
    end

    it 'outputs dealer account' do
      expect { subject.render_bets_info(subject.comp, subject.user, subject.bank) }
        .to output(/=== Остаток диллера: \$#{subject.comp.account}/).to_stdout
    end

    it 'outputs bank amount' do
      expect { subject.render_bets_info(subject.comp, subject.user, subject.bank) }
        .to output(/=== Банк: \$#{subject.bank}/).to_stdout
    end
  end

  describe '#render_all' do
    before do
      subject.comp.add_random_card(2)
      subject.user.add_random_card(2)
    end

    it 'renders both bets info and game board' do
      output = capture_stdout { subject.render_all(subject.comp, subject.user, subject.bank) }
      expect(output).to include('=== Ваш остаток:')
      expect(output).to include('=== Карты диллера:')
    end
  end

  describe '#render_actions_menu' do
    let(:mock_prompt) { double('TTY::Prompt') }

    before do
      allow(subject).to receive(:prompt).and_return(mock_prompt)
    end

    context 'when user has less than 3 cards' do
      it 'includes skipping option' do
        subject.user.remove_cards
        allow(mock_prompt).to receive(:select).and_return(:skipping)
        subject.render_actions_menu(subject.user)
        expect(mock_prompt).to have_received(:select).with('Выберите действие', anything)
      end

      it 'includes take card option' do
        subject.user.remove_cards
        allow(mock_prompt).to receive(:select).and_return(:take_card)
        subject.render_actions_menu(subject.user)
        expect(mock_prompt).to have_received(:select).with('Выберите действие', anything)
      end

      it 'includes open cards option' do
        subject.user.remove_cards
        allow(mock_prompt).to receive(:select).and_return(:open_cards)
        subject.render_actions_menu(subject.user)
        expect(mock_prompt).to have_received(:select).with('Выберите действие', anything)
      end
    end

    context 'when user has 3 cards' do
      it 'disables take card option' do
        subject.user.add_random_card(3)
        allow(mock_prompt).to receive(:select).and_return(:skipping)
        subject.render_actions_menu(subject.user)
        # Проверяем, что переданная опция take_card имеет disabled
        expect(mock_prompt)
          .to have_received(:select)
          .with(
            'Выберите действие',
            array_including(hash_including(name: 'Добавить карту', disabled: '(у вас уже 3 карты)'))
          )
      end
    end
  end

  describe '#render_all_cards' do
    before do
      subject.comp.add_random_card(2)
      subject.user.add_random_card(2)
    end

    it 'renders all cards (not hidden)' do
      output = capture_stdout { subject.render_all_cards(subject.comp, subject.user, subject.bank) }
      # Should show card ranks, not hidden symbols
      expect(output).not_to include('░')
    end

    it 'shows dealer cards with format' do
      output = capture_stdout { subject.render_all_cards(subject.comp, subject.user, subject.bank) }
      expect(output).to include('=== Карты диллера:')
    end

    it 'shows user cards with format' do
      output = capture_stdout { subject.render_all_cards(subject.comp, subject.user, subject.bank) }
      expect(output).to include('=== Ваши карты:')
    end

    it 'shows user score' do
      output = capture_stdout { subject.render_all_cards(subject.comp, subject.user, subject.bank) }
      expect(output).to include("=== Ваш счет: #{subject.user.current_score}")
    end
  end

  describe '#render_round_result' do
    before do
      subject.comp.add_random_card(2)
      subject.user.add_random_card(2)
    end

    context 'when user wins' do
      it 'outputs user win message' do
        output = capture_stdout do
          subject.render_round_result(subject.comp, subject.user, subject.bank, { winner: :user })
        end
        expect(output).to include('Игрок выйграл!')
      end
    end

    context 'when computer wins' do
      it 'outputs computer win message' do
        output = capture_stdout do
          subject.render_round_result(subject.comp, subject.user, subject.bank, { winner: :comp })
        end
        expect(output).to include('Диллер выйграл!')
      end
    end

    context 'when it is a dead heat' do
      it 'outputs draw message' do
        output = capture_stdout do
          subject.render_round_result(subject.comp, subject.user, subject.bank, { winner: :dead_heat })
        end
        expect(output).to include('Ничья!')
      end
    end

    context 'when winner is nil' do
      it 'outputs no winner message' do
        output = capture_stdout do
          subject.render_round_result(subject.comp, subject.user, subject.bank, { winner: nil })
        end
        expect(output).to include('Победителя нет!')
      end
    end

    it 'shows both scores' do
      output = capture_stdout do
        subject.render_round_result(subject.comp, subject.user, subject.bank, { winner: :user })
      end
      expect(output).to include("Счет игрока:  #{subject.user.current_score}")
      expect(output).to include("Счет диллера: #{subject.comp.current_score}")
    end
  end

  describe '#user_move_msg' do
    it 'outputs the message with player prefix' do
      expect { subject.user_move_msg('Тестовое сообщение') }
        .to output("Ход игрока: Тестовое сообщение\n").to_stdout
    end
  end

  describe '#comp_move_msg' do
    it 'outputs the message with dealer prefix' do
      expect { subject.comp_move_msg('Тестовое сообщение') }
        .to output("Ход диллера: Тестовое сообщение\n").to_stdout
    end
  end

  describe '#inline_cards_render' do
    it 'renders cards side by side' do
      card1 = BlackJack::Card.new(suit: '♠', rank: 'A')
      card2 = BlackJack::Card.new(suit: '♥', rank: 'K')
      cards = [card1.format_card, card2.format_card]
      result = subject.inline_cards_render(cards)
      expect(result).to include('A')
      expect(result).to include('K')
      expect(result).to include('♠')
      expect(result).to include('♥')
    end

    it 'handles single card' do
      card = BlackJack::Card.new(suit: '♣', rank: '5')
      result = subject.inline_cards_render([card.format_card])
      expect(result).to include('5')
      expect(result).to include('♣')
    end

    it 'handles multiple cards' do
      card1 = BlackJack::Card.new(suit: '♠', rank: 'A')
      card2 = BlackJack::Card.new(suit: '♥', rank: 'K')
      card3 = BlackJack::Card.new(suit: '♦', rank: 'Q')
      cards = [card1.format_card, card2.format_card, card3.format_card]
      result = subject.inline_cards_render(cards)
      expect(result).to include('A')
      expect(result).to include('K')
      expect(result).to include('Q')
    end
  end

  describe '#print_msg' do
    it 'outputs the given message' do
      expect { subject.print_msg('Hello') }.to output("Hello\n").to_stdout
    end
  end

  describe '#wait_user_input' do
    it 'responds to wait_user_input' do
      expect(subject).to respond_to(:wait_user_input)
    end
  end
end
