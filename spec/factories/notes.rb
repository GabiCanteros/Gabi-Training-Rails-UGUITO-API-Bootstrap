FactoryBot.define do
  factory :note do
    utility
    user

    title { Faker::Lorem.sentence(word_count: 3) }  # Genera un título con 3 palabras
    content { Faker::Lorem.paragraph(sentence_count: 2) } # Genera un párrafo de 2 oraciones

    # Enum
    note_type { Faker::Lorem.sample(%w[review critique]) }
  end
end
