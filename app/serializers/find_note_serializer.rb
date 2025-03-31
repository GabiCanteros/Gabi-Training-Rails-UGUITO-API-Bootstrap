class FindNoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :note_type, :word_count, :content_length, :created_at
  belongs_to :user, serializer: UserSerializer
end
