# frozen_string_literal: true

require 'black_jack'

RSpec.describe BlackJack::Computer do
  let(:computer) { described_class.new(100) }

  before do
    BlackJack::Card.generate_cards
  end

  describe '#initialize' do
    it 'sets the account to the given value' do
      expect(computer.account).to eq(100)
    end

    it 'accepts any account value' do
      comp = described_class.new(200)
      expect(comp.account).to eq(200)
    end
  end

  describe '#choose_action' do
    context 'when current_score is less than 17' do
      it 'returns :take_card with one card (5)' do
        card = BlackJack::Card.new(suit: '♠', rank: '5')
        computer.add_card(card)
        expect(computer.choose_action).to eq(:take_card)
      end

      it 'returns :take_card with two cards (10 + 5)' do
        king = BlackJack::Card.new(suit: '♠', rank: 'K')
        five = BlackJack::Card.new(suit: '♥', rank: '5')
        computer.add_card(king)
        computer.add_card(five)
        expect(computer.choose_action).to eq(:take_card)
      end

      it 'returns :take_card with two aces (11 + 1 = 12)' do
        ace1 = BlackJack::Card.new(suit: '♠', rank: 'A')
        ace2 = BlackJack::Card.new(suit: '♥', rank: 'A')
        computer.add_card(ace1)
        computer.add_card(ace2)
        expect(computer.choose_action).to eq(:take_card)
      end
    end

    context 'when current_score is exactly 17' do
      it 'returns :skipping' do
        five = BlackJack::Card.new(suit: '♠', rank: '7')
        queen = BlackJack::Card.new(suit: '♥', rank: '10')
        computer.add_card(five)
        computer.add_card(queen)
        expect(computer.choose_action).to eq(:skipping)
      end
    end

    context 'when current_score is greater than 17' do
      it 'returns :skipping with score 18' do
        king = BlackJack::Card.new(suit: '♠', rank: 'K')
        eight = BlackJack::Card.new(suit: '♥', rank: '8')
        computer.add_card(king)
        computer.add_card(eight)
        expect(computer.choose_action).to eq(:skipping)
      end

      it 'returns :skipping with score 21 (blackjack)' do
        ace = BlackJack::Card.new(suit: '♠', rank: 'A')
        king = BlackJack::Card.new(suit: '♥', rank: 'K')
        computer.add_card(ace)
        computer.add_card(king)
        expect(computer.choose_action).to eq(:skipping)
      end

      it 'returns :skipping with score over 21 (bust)' do
        king = BlackJack::Card.new(suit: '♠', rank: 'K')
        queen = BlackJack::Card.new(suit: '♥', rank: 'Q')
        ace = BlackJack::Card.new(suit: '♦', rank: 'A')
        computer.add_card(king)
        computer.add_card(queen)
        computer.add_card(ace)
        expect(computer.choose_action).to eq(:skipping)
      end
    end
  end

  describe 'included Common::Player methods' do
    it 'can add a card' do
      card = BlackJack::Card.new(suit: '♠', rank: '5')
      computer.add_card(card)
      expect(computer.cards).to eq([card])
    end

    it 'can add random cards' do
      computer.add_random_card(2)
      expect(computer.cards.count).to eq(2)
    end

    it 'calculates current score correctly' do
      ace = BlackJack::Card.new(suit: '♠', rank: 'A')
      king = BlackJack::Card.new(suit: '♥', rank: 'K')
      computer.add_card(ace)
      computer.add_card(king)
      expect(computer.current_score).to eq(21)
    end

    it 'tracks three cards taken' do
      computer.add_random_card(3)
      expect(computer.three_cards_taken?).to be true
    end

    it 'removes all cards' do
      computer.add_random_card(2)
      computer.remove_cards
      expect(computer.cards).to be_empty
    end
  end
end
