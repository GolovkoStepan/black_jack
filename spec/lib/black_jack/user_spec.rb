# frozen_string_literal: true

require 'black_jack'

RSpec.describe BlackJack::User do
  let(:user) { described_class.new(100) }

  before do
    BlackJack::Card.generate_cards
  end

  describe '#initialize' do
    it 'sets the account to the given value' do
      expect(user.account).to eq(100)
    end

    it 'accepts any account value' do
      user = described_class.new(500)
      expect(user.account).to eq(500)
    end
  end

  describe 'included Common::Player methods' do
    it 'can add a card' do
      card = BlackJack::Card.new(suit: '♠', rank: '5')
      user.add_card(card)
      expect(user.cards).to eq([card])
    end

    it 'can add random cards' do
      user.add_random_card(2)
      expect(user.cards.count).to eq(2)
    end

    it 'calculates current score correctly' do
      ace = BlackJack::Card.new(suit: '♠', rank: 'A')
      king = BlackJack::Card.new(suit: '♥', rank: 'K')
      user.add_card(ace)
      user.add_card(king)
      expect(user.current_score).to eq(21)
    end

    it 'tracks three cards taken' do
      user.add_random_card(3)
      expect(user.three_cards_taken?).to be true
    end

    it 'removes all cards' do
      user.add_random_card(2)
      user.remove_cards
      expect(user.cards).to be_empty
    end
  end
end
