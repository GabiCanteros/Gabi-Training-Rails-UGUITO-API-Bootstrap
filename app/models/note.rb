# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string
#  content    :string
#  note_type  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#
class Note < ApplicationRecord
  belongs_to :user

  validates :title, :content, presence: true
  validates :note_type, presence: true
  enum note_type: { review: 'review', critique: 'critique' }
  validate :validate_review_word_count, if: :review?

  def word_count
    return 0 if content.blank?
    content.split(/\s+/).size
  end

  def content_length
    case word_count
    when 0..utility.max_word_short_content
      'short'
    when (utility.max_word_short_content + 1)..utility.max_word_medium_content
      'medium'
    else
      'long'
    end
  end

  private

  def validate_review_word_count
    return unless word_count > utility.max_word_valid_review
    errors.add(:content,
               I18n.t('activerecord.errors.models.note.attributes.content.review_word_count',
                      max_word_limit: utility.max_word_valid_review))
  end
  has_one :utility, through: :user
end
