class ListNoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :note_type, :content_length
end
