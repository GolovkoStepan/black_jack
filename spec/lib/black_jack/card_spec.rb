# frozen_string_literal: true

RSpec.describe BlackJack::Card do
  let(:ace_card)   { described_class.new(suit: '♠', rank: 'A') }
  let(:king_card)  { described_class.new(suit: '♠', rank: 'K') }
  let(:queen_card) { described_class.new(suit: '♠', rank: 'Q') }
  let(:num_card)   { described_class.new(suit: '♠', rank: '5') }

  context 'calc cards ranks sum' do
    it 'should correct calc sum' do
      expected = 10 + 5
      actual   = described_class.cards_sum([num_card, king_card])

      expect(actual).to eq(expected)
    end

    it 'should correct calc sum without ace card' do
      expected = 5 + 10 + 10
      actual   = described_class.cards_sum([num_card, king_card, queen_card])

      expect(actual).to eq(expected)
    end

    it 'should correct calc sum with one ace card' do
      expected = 1 + 10 + 10
      actual   = described_class.cards_sum([ace_card, king_card, queen_card])

      expect(actual).to eq(expected)
    end

    it 'should correct calc sum with 2 ace card' do
      expected = 11 + 1 + 5
      actual   = described_class.cards_sum([ace_card, ace_card, num_card])

      expect(actual).to eq(expected)
    end

    it 'should correct calc sum with 3 ace card' do
      expected = 1 + 1 + 1 + 10
      actual   = described_class.cards_sum(
        [ace_card, ace_card, ace_card, queen_card]
      )

      expect(actual).to eq(expected)
    end

    it 'should correct calc sum with 4 ace card' do
      expected = 11 + 1 + 1 + 1
      actual   = described_class.cards_sum(
        [ace_card, ace_card, ace_card, ace_card]
      )

      expect(actual).to eq(expected)
    end
  end
end
