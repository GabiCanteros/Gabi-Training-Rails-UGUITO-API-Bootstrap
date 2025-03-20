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


  validates :title, presence: true
  validates :content, presence: true
  validates :note_type, presence: true, inclusion: { in: ['review', 'critique'] }

  has_one :utility, through: :user
end
