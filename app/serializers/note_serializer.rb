class NoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :word_count, :content_length, :created_at
  attribute :note_type, key: :type
  belongs_to :user, serializer: UserSerializer
end

