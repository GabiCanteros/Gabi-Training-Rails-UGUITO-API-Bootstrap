FactoryBot.define do
  factory :note do
    utility
    user
    title { Faker::Lorem.sentence(word_count: 3) }
    content { Faker::Lorem.paragraph(sentence_count: 2) }
    note_type { %w[review critique].sample }
  end
end
