require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    build(:note, user: user)
  end

  let(:user) { create(:user, utility: utility) }
  let(:utility) { create(:utility) }

  let(:south_utility) { create(:south_utility) }
  let(:north_utility) { create(:north_utility) }
  let(:user_south) { create(:user, utility: south_utility) }
  let(:user_north) { create(:user, utility: north_utility) }

  let(:note_south_valid) { create(:note, user: user_south, utility: south_utility, note_type: :review, content: 'word ' * 51) }
  let(:note_north_valid) { create(:note, user: user_north, utility: north_utility, note_type: :critique, content: 'word ' * 50) }
  let(:note_south_invalid) { build(:note, user: user_south, utility: south_utility, note_type: :review, content: 'word ' * 71) }
  let(:note_north_invalid) { build(:note, user: user_north, utility: north_utility, note_type: :review, content: 'word ' * 71) }

  it { is_expected.to validate_presence_of(:title) }

  it { is_expected.to validate_presence_of(:content) }

  it { is_expected.to validate_presence_of(:note_type) }

  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_one(:utility).through(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  context 'When Note has invalid note_type' do
    let(:note) { build(:note, note_type: 'invalid') }

    it 'raises an error when creating a duplicate' do
      expect { note.save! }.to raise_error(ArgumentError)
    end
  end

  describe 'content_length' do
    context 'when user has SouthUtility' do
      it 'returns "short" if content is within the short limit' do
        expect(note_south_valid.content_length).to eq('short')
      end

      it 'returns "medium" if content is within the medium limit' do
        note_south_valid.update(content: 'word ' * 101)
        expect(note_south_valid.content_length).to eq('medium')
      end

      it 'returns "long" if content exceeds the medium limit' do
        note_south_valid.update(content: 'word ' * 131)
        expect(note_south_valid.content_length).to eq('long')
      end
    end

    context 'when user has NorthUtility' do
      it 'returns "short" if content is within the short limit' do
        expect(note_north_valid.content_length).to eq('short')
      end

      it 'returns "medium" if content is within the medium limit' do
        note_north_valid.update(content: 'word ' * 81)
        expect(note_north_valid.content_length).to eq('medium')
      end

      it 'returns "long" if content exceeds the medium limit' do
        note_north_valid.update(content: 'word ' * 121)
        expect(note_north_valid.content_length).to eq('long')
      end
    end
  end

  describe 'validate_review_word_count' do
    context 'when note_type is review' do
      context 'and user has SouthUtility' do
        it 'is valid if content word count is within the limit (60)' do
          expect(note_south_valid).to be_valid
        end

        it 'is invalid if content word count exceeds the limit (60)' do
          expect(note_south_invalid).not_to be_valid
          expect(note_south_invalid.errors[:content]).to include(I18n.t('activerecord.errors.models.note.attributes.content.review_word_count', max_word_limit: south_utility.max_word_valid_review))
        end
      end

      context 'and user has NorthUtility' do
        it 'is valid if content word count is within the limit (50)' do
          expect(note_north_valid).to be_valid
        end

        it 'is invalid if content word count exceeds the limit (50)' do
          expect(note_north_invalid).not_to be_valid
          expect(note_north_invalid.errors[:content]).to include(I18n.t('activerecord.errors.models.note.attributes.content.review_word_count', max_word_limit: north_utility.max_word_valid_review))
        end
      end
    end
  end
end
