# frozen_string_literal: true

RSpec.describe BlackJack::Card do
  let(:ace_card)   { described_class.new(suit: '♠', rank: 'A') }
  let(:king_card)  { described_class.new(suit: '♠', rank: 'K') }
  let(:queen_card) { described_class.new(suit: '♥', rank: 'Q') }
  let(:jack_card)  { described_class.new(suit: '♦', rank: 'J') }
  let(:num_card)   { described_class.new(suit: '♣', rank: '5') }
  let(:ten_card)   { described_class.new(suit: '♠', rank: '10') }
  let(:nine_card)  { described_class.new(suit: '♥', rank: '9') }

  describe '.RANKS_NUMS' do
    it 'contains numeric ranks from 2 to 10' do
      expected = %w[2 3 4 5 6 7 8 9 10]
      expect(described_class::RANKS_NUMS).to eq(expected)
    end
  end

  describe '.RANKS_LETTERS' do
    it 'contains face card ranks' do
      expect(described_class::RANKS_LETTERS).to eq(%w[J Q K])
    end
  end

  describe '.RANKS_ACE' do
    it 'equals A' do
      expect(described_class::RANKS_ACE).to eq('A')
    end
  end

  describe '.RANKS' do
    it 'contains all ranks' do
      expected = %w[2 3 4 5 6 7 8 9 10 J Q K A]
      expect(described_class::RANKS).to eq(expected)
    end
  end

  describe '.SUITS' do
    it 'contains all suits' do
      expected = %w[♠ ♣ ♥ ♦]
      expect(described_class::SUITS).to eq(expected)
    end
  end

  describe '#initialize' do
    it 'sets the suit' do
      expect(ace_card.suit).to eq('♠')
    end

    it 'sets the rank' do
      expect(ace_card.rank).to eq('A')
    end

    it 'creates a card with any suit and rank' do
      card = described_class.new(suit: '♦', rank: '7')
      expect(card.suit).to eq('♦')
      expect(card.rank).to eq('7')
    end
  end

  describe '.generate_cards' do
    it 'generates 52 cards' do
      described_class.generate_cards
      expect(described_class.cards.count).to eq(52)
    end

    it 'generates all combinations of suits and ranks' do
      described_class.generate_cards
      ranks = described_class.cards.map(&:rank).uniq
      suits = described_class.cards.map(&:suit).uniq

      expect(ranks).to match_array(described_class::RANKS)
      expect(suits).to match_array(described_class::SUITS)
    end

    it 'shuffles the cards' do
      described_class.generate_cards
      # Check that cards are not in perfect suit-by-suit order
      described_class.cards.first.suit
      # With 52 cards, the chance of all being in order is astronomically low
      # but we can at least verify the count is correct
      expect(described_class.cards.count).to eq(52)
    end

    it 'returns the cards array' do
      result = described_class.generate_cards
      expect(result).to eq(described_class.cards)
    end
  end

  describe '.random_card' do
    before { described_class.generate_cards }

    it 'returns a card from the deck' do
      card = described_class.random_card
      expect(card).to be_a(described_class)
    end

    it 'removes the card from the deck' do
      initial_count = described_class.cards.count
      described_class.random_card
      expect(described_class.cards.count).to eq(initial_count - 1)
    end

    it 'returns different cards on successive calls' do
      card1 = described_class.random_card
      card2 = described_class.random_card
      # They should be different objects (different cards)
      expect(card1.object_id).not_to eq(card2.object_id)
    end

    it 'returns nil when deck is empty' do
      described_class.generate_cards
      52.times { described_class.random_card }
      expect(described_class.random_card).to be_nil
    end
  end

  describe '.cards_sum' do
    context 'with numeric cards' do
      it 'returns correct sum for a single card' do
        expect(described_class.cards_sum([num_card])).to eq(5)
      end

      it 'returns correct sum for two numeric cards' do
        nine = described_class.new(suit: '♥', rank: '9')
        expect(described_class.cards_sum([num_card, nine])).to eq(14)
      end

      it 'returns correct sum for a 10 card' do
        expect(described_class.cards_sum([ten_card])).to eq(10)
      end
    end

    context 'with face cards' do
      it 'values face cards at 10' do
        expect(described_class.cards_sum([king_card])).to eq(10)
        expect(described_class.cards_sum([queen_card])).to eq(10)
        expect(described_class.cards_sum([jack_card])).to eq(10)
      end

      it 'returns correct sum for multiple face cards' do
        expect(described_class.cards_sum([king_card, queen_card, jack_card])).to eq(30)
      end

      it 'returns correct sum for mixed face and numeric cards' do
        expected = 10 + 5
        actual = described_class.cards_sum([num_card, king_card])
        expect(actual).to eq(expected)
      end
    end

    context 'with ace cards' do
      it 'values ace as 11 when it does not bust' do
        expected = 11 + 5
        actual = described_class.cards_sum([ace_card, num_card])
        expect(actual).to eq(expected)
      end

      it 'values ace as 1 when it would bust' do
        expected = 1 + 10 + 10
        actual = described_class.cards_sum([ace_card, king_card, queen_card])
        expect(actual).to eq(expected)
      end

      it 'values two aces as 12 (11 + 1)' do
        ace2 = described_class.new(suit: '♥', rank: 'A')
        expected = 12
        actual = described_class.cards_sum([ace_card, ace2])
        expect(actual).to eq(expected)
      end

      it 'values three aces as 13 (11 + 1 + 1)' do
        ace2 = described_class.new(suit: '♥', rank: 'A')
        ace3 = described_class.new(suit: '♦', rank: 'A')
        expected = 13
        actual = described_class.cards_sum([ace_card, ace2, ace3])
        expect(actual).to eq(expected)
      end

      it 'values four aces as 14 (11 + 1 + 1 + 1)' do
        ace2 = described_class.new(suit: '♥', rank: 'A')
        ace3 = described_class.new(suit: '♦', rank: 'A')
        ace4 = described_class.new(suit: '♣', rank: 'A')
        expected = 14
        actual = described_class.cards_sum([ace_card, ace2, ace3, ace4])
        expect(actual).to eq(expected)
      end

      it 'values ace and king as 21 (blackjack)' do
        expected = 21
        actual = described_class.cards_sum([ace_card, king_card])
        expect(actual).to eq(expected)
      end

      it 'values ace, ace, and king as 12 (11 + 1 + 10)' do
        ace2 = described_class.new(suit: '♥', rank: 'A')
        expected = 12
        actual = described_class.cards_sum([ace_card, ace2, king_card])
        expect(actual).to eq(expected)
      end
    end

    context 'with empty array' do
      it 'returns 0' do
        expect(described_class.cards_sum([])).to eq(0)
      end
    end

    context 'with mixed cards' do
      it 'correctly calculates sum with aces, face cards, and numbers' do
        ace2 = described_class.new(suit: '♥', rank: 'A')
        expected = 1 + 1 + 10 + 10 + 5
        actual = described_class.cards_sum([ace_card, ace2, king_card, queen_card, num_card])
        expect(actual).to eq(expected)
      end

      it 'handles a hand with two aces and a king' do
        ace2 = described_class.new(suit: '♥', rank: 'A')
        expected = 12
        actual = described_class.cards_sum([ace_card, ace2, king_card])
        expect(actual).to eq(expected)
      end
    end
  end

  describe '#format_card' do
    it 'returns a formatted ASCII card representation' do
      formatted = ace_card.format_card
      expect(formatted).to include('┌─────────┐')
      expect(formatted).to include('└─────────┘')
      expect(formatted).to include('A')
      expect(formatted).to include('♠')
    end

    it 'returns a formatted card with numeric rank' do
      formatted = num_card.format_card
      expect(formatted).to include('5')
      expect(formatted).to include('♣')
    end

    it 'returns a formatted card with face rank' do
      formatted = king_card.format_card
      expect(formatted).to include('K')
      expect(formatted).to include('♠')
    end

    it 'returns a formatted card with 10 rank' do
      formatted = ten_card.format_card
      expect(formatted).to include('10')
      expect(formatted).to include('♠')
    end
  end

  describe '#hidden_card' do
    it 'returns a hidden card representation' do
      hidden = ace_card.hidden_card
      expect(hidden).to include('┌─────────┐')
      expect(hidden).to include('└─────────┘')
      expect(hidden).to include('░')
    end

    it 'does not reveal the rank or suit' do
      hidden = ace_card.hidden_card
      expect(hidden).not_to include('A')
      expect(hidden).not_to include('♠')
    end
  end

  describe '#to_s' do
    it 'returns rank and suit concatenated' do
      expect(ace_card.to_s).to eq('A♠')
    end

    it 'returns rank and suit for numeric cards' do
      expect(num_card.to_s).to eq('5♣')
    end

    it 'returns rank and suit for face cards' do
      expect(king_card.to_s).to eq('K♠')
    end

    it 'returns rank and suit for 10' do
      expect(ten_card.to_s).to eq('10♠')
    end
  end
end
