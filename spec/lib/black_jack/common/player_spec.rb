# frozen_string_literal: true

require 'black_jack'

RSpec.describe BlackJack::Common::Player do
  # Создаём тестовый класс, включающий модуль
  let(:test_player_class) do
    Class.new do
      include BlackJack::Common::Player

      attr_accessor :account

      def initialize(account)
        @account = account
      end
    end
  end

  let(:player) { test_player_class.new(100) }

  before do
    # Инициализируем колоду для тестов
    BlackJack::Card.generate_cards
  end

  describe '#add_card' do
    it 'adds a single card to the player' do
      card = BlackJack::Card.random_card
      player.add_card(card)

      expect(player.cards).to eq([card])
    end

    it 'appends cards to existing cards' do
      card1 = BlackJack::Card.random_card
      card2 = BlackJack::Card.random_card

      player.add_card(card1)
      player.add_card(card2)

      expect(player.cards).to eq([card1, card2])
    end
  end

  describe '#add_random_card' do
    it 'adds one random card by default' do
      player.add_random_card
      expect(player.cards.count).to eq(1)
    end

    it 'adds multiple random cards' do
      player.add_random_card(3)
      expect(player.cards.count).to eq(3)
    end

    it 'adds cards from the shuffled deck' do
      player.add_random_card(2)
      expect(player.cards).to all(be_a(BlackJack::Card))
    end
  end

  describe '#cards' do
    it 'returns an empty array when no cards are added' do
      expect(player.cards).to eq([])
    end

    it 'returns the cards array after adding cards' do
      card = BlackJack::Card.random_card
      player.add_card(card)
      expect(player.cards).to include(card)
    end
  end

  describe '#current_score' do
    it 'returns correct score for a single card' do
      card = BlackJack::Card.new(suit: '♠', rank: '5')
      player.add_card(card)
      expect(player.current_score).to eq(5)
    end

    it 'returns correct score for face cards' do
      king = BlackJack::Card.new(suit: '♠', rank: 'K')
      queen = BlackJack::Card.new(suit: '♥', rank: 'Q')
      player.add_card(king)
      player.add_card(queen)
      expect(player.current_score).to eq(20)
    end

    it 'returns correct score with an ace (as 11)' do
      ace = BlackJack::Card.new(suit: '♠', rank: 'A')
      five = BlackJack::Card.new(suit: '♥', rank: '5')
      player.add_card(ace)
      player.add_card(five)
      expect(player.current_score).to eq(16)
    end

    it 'returns correct score with an ace (as 1) when busting' do
      ace = BlackJack::Card.new(suit: '♠', rank: 'A')
      king = BlackJack::Card.new(suit: '♥', rank: 'K')
      player.add_card(ace)
      player.add_card(king)
      expect(player.current_score).to eq(21)
    end

    it 'returns correct score with two aces (11 + 1)' do
      ace1 = BlackJack::Card.new(suit: '♠', rank: 'A')
      ace2 = BlackJack::Card.new(suit: '♥', rank: 'A')
      player.add_card(ace1)
      player.add_card(ace2)
      expect(player.current_score).to eq(12)
    end

    it 'returns correct score for a blackjack (21)' do
      ace = BlackJack::Card.new(suit: '♠', rank: 'A')
      king = BlackJack::Card.new(suit: '♥', rank: 'K')
      player.add_card(ace)
      player.add_card(king)
      expect(player.current_score).to eq(21)
    end
  end

  describe '#three_cards_taken?' do
    it 'returns false when player has less than 3 cards' do
      expect(player.three_cards_taken?).to be false
    end

    it 'returns false when player has exactly 2 cards' do
      player.add_random_card(2)
      expect(player.three_cards_taken?).to be false
    end

    it 'returns true when player has exactly 3 cards' do
      player.add_random_card(3)
      expect(player.three_cards_taken?).to be true
    end

    it 'returns true when player has more than 3 cards' do
      player.add_random_card(4)
      expect(player.three_cards_taken?).to be true
    end
  end

  describe '#remove_cards' do
    it 'clears all cards from the player' do
      player.add_random_card(3)
      expect(player.cards.count).to eq(3)

      player.remove_cards
      expect(player.cards).to eq([])
    end

    it 'resets the cards array to empty' do
      player.add_random_card(2)
      player.remove_cards
      expect(player.cards).to be_empty
    end
  end

  describe '#account' do
    it 'returns the initial account value' do
      expect(player.account).to eq(100)
    end

    it 'allows setting the account value' do
      player.account = 200
      expect(player.account).to eq(200)
    end
  end
end
