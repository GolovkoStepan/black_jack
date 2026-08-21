# frozen_string_literal: true

require 'black_jack'

RSpec.describe BlackJack::Game do
  # Тестовый класс, наследующийся от Game, но без игрового цикла в initialize
  let(:game_class) do
    Class.new(BlackJack::Game) do
      attr_reader :user, :comp, :bank

      def initialize
        @user = BlackJack::User.new(BlackJack::Game::OPENING_ACCOUNT)
        @comp = BlackJack::Computer.new(BlackJack::Game::OPENING_ACCOUNT)
        @bank = nil
      end

      # Обёртки для приватных методов
      def test_round_result
        round_result { |options| options }
      end

      def test_make_bets
        make_bets
      end

      def test_deal_cards
        deal_cards
      end

      def test_user_move(choice)
        user_move { choice }
      end

      def test_comp_move
        comp_move
      end

      def test_user_skipping
        user_skipping
      end

      def test_user_take_card
        user_take_card
      end

      def test_user_open_cards
        user_open_cards
      end

      def test_comp_skipping
        comp_skipping
      end

      def test_comp_take_card
        comp_take_card
      end
    end
  end

  let(:game) { game_class.new }

  before do
    BlackJack::Card.generate_cards
  end

  describe '#initialize' do
    it 'creates a user with opening account' do
      expect(game.user.account).to eq(BlackJack::Game::OPENING_ACCOUNT)
    end

    it 'creates a computer with opening account' do
      expect(game.comp.account).to eq(BlackJack::Game::OPENING_ACCOUNT)
    end

    it 'initializes bank as nil' do
      expect(game.bank).to be_nil
    end
  end

  describe '#make_bets' do
    it 'subtracts bet from user account' do
      expect { game.test_make_bets }.to change { game.user.account }.by(-BlackJack::Game::BET_PER_STEP)
    end

    it 'subtracts bet from computer account' do
      expect { game.test_make_bets }.to change { game.comp.account }.by(-BlackJack::Game::BET_PER_STEP)
    end

    it 'sets bank to sum of bets on first call' do
      game.test_make_bets
      expect(game.bank).to eq(BlackJack::Game::BET_PER_STEP * 2)
    end

    it 'adds to existing bank on subsequent calls' do
      game.test_make_bets
      game.test_make_bets
      expect(game.bank).to eq(BlackJack::Game::BET_PER_STEP * 4)
    end
  end

  describe '#deal_cards' do
    it 'deals 2 cards to user' do
      game.test_deal_cards
      expect(game.user.cards.count).to eq(2)
    end

    it 'deals 2 cards to computer' do
      game.test_deal_cards
      expect(game.comp.cards.count).to eq(2)
    end

    it 'clears user cards before dealing' do
      game.user.add_random_card(2)
      game.test_deal_cards
      expect(game.user.cards.count).to eq(2)
    end

    it 'clears computer cards before dealing' do
      game.comp.add_random_card(2)
      game.test_deal_cards
      expect(game.comp.cards.count).to eq(2)
    end
  end

  describe '#round_result' do
    context 'when both player and dealer bust' do
      it 'yields winner as nil' do
        allow(game.comp).to receive(:current_score).and_return(25)
        allow(game.user).to receive(:current_score).and_return(24)

        result = game.test_round_result
        expect(result[:winner]).to be_nil
      end
    end

    context 'when user wins' do
      it 'yields winner as :user and adds bank to user account' do
        game.test_make_bets
        initial_user_account = game.user.account
        bank_amount = game.bank

        allow(game.comp).to receive(:current_score).and_return(18)
        allow(game.user).to receive(:current_score).and_return(20)

        result = game.test_round_result

        expect(result[:winner]).to eq(:user)
        expect(game.user.account).to eq(initial_user_account + bank_amount)
        expect(game.bank).to eq(0)
      end
    end

    context 'when computer wins' do
      it 'yields winner as :comp and adds bank to computer account' do
        game.test_make_bets
        initial_comp_account = game.comp.account
        bank_amount = game.bank

        allow(game.comp).to receive(:current_score).and_return(20)
        allow(game.user).to receive(:current_score).and_return(18)

        result = game.test_round_result

        expect(result[:winner]).to eq(:comp)
        expect(game.comp.account).to eq(initial_comp_account + bank_amount)
        expect(game.bank).to eq(0)
      end
    end

    context 'when computer busts and user does not' do
      it 'yields winner as :user' do
        game.test_make_bets
        initial_user_account = game.user.account
        bank_amount = game.bank

        allow(game.comp).to receive(:current_score).and_return(25)
        allow(game.user).to receive(:current_score).and_return(19)

        result = game.test_round_result

        expect(result[:winner]).to eq(:user)
        expect(game.user.account).to eq(initial_user_account + bank_amount)
      end
    end

    context 'when it is a dead heat' do
      it 'yields winner as :dead_heat and splits bank' do
        game.test_make_bets
        initial_user_account = game.user.account
        initial_comp_account = game.comp.account
        bank_amount = game.bank

        allow(game.comp).to receive(:current_score).and_return(19)
        allow(game.user).to receive(:current_score).and_return(19)

        result = game.test_round_result

        expect(result[:winner]).to eq(:dead_heat)
        expect(game.user.account).to eq(initial_user_account + (bank_amount / 2))
        expect(game.comp.account).to eq(initial_comp_account + (bank_amount / 2))
        expect(game.bank).to eq(0)
      end
    end
  end

  describe '#user_move' do
    it 'calls user_skipping when :skipping is chosen' do
      allow(game).to receive(:user_skipping)
      game.test_user_move(:skipping)
      expect(game).to have_received(:user_skipping)
    end

    it 'calls user_take_card when :take_card is chosen' do
      allow(game).to receive(:user_take_card)
      game.test_user_move(:take_card)
      expect(game).to have_received(:user_take_card)
    end

    it 'calls user_open_cards when :open_cards is chosen' do
      allow(game).to receive(:user_open_cards)
      game.test_user_move(:open_cards)
      expect(game).to have_received(:user_open_cards)
    end
  end

  describe '#comp_move' do
    it 'calls comp_skipping when computer chooses :skipping' do
      allow(game.comp).to receive(:choose_action).and_return(:skipping)
      allow(game).to receive(:comp_skipping)
      game.test_comp_move
      expect(game).to have_received(:comp_skipping)
    end

    it 'calls comp_take_card when computer chooses :take_card' do
      allow(game.comp).to receive(:choose_action).and_return(:take_card)
      allow(game).to receive(:comp_take_card)
      game.test_comp_move
      expect(game).to have_received(:comp_take_card)
    end
  end

  describe '#user_skipping' do
    it 'outputs a message' do
      expect { game.test_user_skipping }.to output(/Ход игрока: Вы пропускаете ход/).to_stdout
    end
  end

  describe '#user_take_card' do
    context 'when user has less than 3 cards' do
      it 'adds a random card to user' do
        game.user.remove_cards
        game.test_user_take_card
        expect(game.user.cards.count).to eq(1)
      end

      it 'outputs a message' do
        game.user.remove_cards
        expect { game.test_user_take_card }.to output(/Ход игрока: Вы берете карту/).to_stdout
      end
    end

    context 'when user has 3 cards' do
      it 'does not add a card' do
        game.user.add_random_card(3)
        game.test_user_take_card
        expect(game.user.cards.count).to eq(3)
      end

      it 'outputs skipping message instead' do
        game.user.add_random_card(3)
        expect { game.test_user_take_card }.to output(/Ход игрока: Вы пропускаете ход/).to_stdout
      end
    end
  end

  describe '#user_open_cards' do
    it 'sets @end_round to true' do
      game.instance_variable_set(:@end_round, false)
      game.test_user_open_cards
      expect(game.instance_variable_get(:@end_round)).to be true
    end

    it 'outputs a message' do
      expect { game.test_user_open_cards }.to output(/Ход игрока: Все открывают карты/).to_stdout
    end
  end

  describe '#comp_skipping' do
    it 'outputs a message' do
      expect { game.test_comp_skipping }.to output(/Ход диллера: Диллер пропускает ход/).to_stdout
    end
  end

  describe '#comp_take_card' do
    context 'when computer has less than 3 cards' do
      it 'adds a random card to computer' do
        game.comp.remove_cards
        game.test_comp_take_card
        expect(game.comp.cards.count).to eq(1)
      end

      it 'outputs a message' do
        game.comp.remove_cards
        expect { game.test_comp_take_card }.to output(/Ход диллера: Диллер берет карту/).to_stdout
      end
    end

    context 'when computer has 3 cards' do
      it 'does not add a card' do
        game.comp.add_random_card(3)
        game.test_comp_take_card
        expect(game.comp.cards.count).to eq(3)
      end

      it 'outputs skipping message instead' do
        game.comp.add_random_card(3)
        expect { game.test_comp_take_card }.to output(/Ход диллера: Диллер пропускает ход/).to_stdout
      end
    end
  end
end
