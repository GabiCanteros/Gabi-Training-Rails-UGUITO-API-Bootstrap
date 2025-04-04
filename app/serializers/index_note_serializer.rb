class IndexNoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :content_length
  attribute :note_type, key: :type
end
