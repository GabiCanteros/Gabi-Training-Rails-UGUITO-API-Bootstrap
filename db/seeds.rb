# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command
# (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Admin User
FactoryBot.create(:admin_user, email: 'admin@example.com', password: 'password',
                               password_confirmation: 'password')

# Utilities
north_utility = FactoryBot.create(:north_utility, code: 1)
south_utility = FactoryBot.create(:south_utility, code: 2)

# Users
FactoryBot.create_list(:user, 20, utility: north_utility,
                                  password: '12345678', password_confirmation: '12345678')
FactoryBot.create_list(:user, 20, utility: south_utility,
                                  password: '12345678', password_confirmation: '12345678')

FactoryBot.create(:user, utility: south_utility, email: 'test_south@widergy.com',
                         password: '12345678', password_confirmation: '12345678')

FactoryBot.create(:user, utility: north_utility, email: 'test_north@widergy.com',
                         password: '12345678', password_confirmation: '12345678')

User.all.find_each do |user|
  random_books_amount = [1, 2, 3].sample
  FactoryBot.create_list(:book, random_books_amount, user: user, utility: user.utility)
end

north_user = north_utility.users.first
south_user = south_utility.users.first

# CASOS DE TAMAÑOS VARIADOS 
# Las líneas comentadas no se pueden ejecutar porque no superan la etapa de validación

FactoryBot.create_list(:note, 2, title: '5-word North user review',content: 'this is a magic note', note_type: 'review', user: north_user)

#FactoryBot.create_list(:note, 2, title: '54-word North user review',content: 'word '*54, note_type: 'review', user: north_user)

#FactoryBot.create_list(:note, 2, title: '67-word North user review',content: 'word '*67, note_type: 'review', user: north_user)

FactoryBot.create_list(:note, 2, title: '5-word North user critique',content: 'this is a magic note', note_type: 'critique', user: north_user)

FactoryBot.create_list(:note, 2, title: '54-word North user critique',content: 'word '*54, note_type: 'critique', user: north_user)

FactoryBot.create_list(:note, 2, title: '67-word North user critique',content: 'word '*67, note_type: 'critique', user: north_user)

FactoryBot.create_list(:note, 2, title: '110-word North user critique',content: 'word '*110, note_type: 'critique', user: north_user)

FactoryBot.create_list(:note, 2, title: '130-word North user critique',content: 'word '*130, note_type: 'critique', user: north_user)

FactoryBot.create_list(:note, 2, title: '5-word South user review',content: 'this is a magic note', note_type: 'review', user: south_user)

FactoryBot.create_list(:note, 2, title: '54-word South user review',content: 'word '*54, note_type: 'review', user: south_user)

#FactoryBot.create_list(:note, 2, title: '67-word South user review',content: 'word '*67, note_type: 'review', user: south_user)

FactoryBot.create_list(:note, 2, title: '5-word South user critique',content: 'this is a magic note', note_type: 'critique', user: south_user)

FactoryBot.create_list(:note, 2, title: '54-word South user critique',content: 'word '*54, note_type: 'critique', user: south_user)

FactoryBot.create_list(:note, 2, title: '67-word South user critique',content: 'word '*67, note_type: 'critique', user: south_user)

FactoryBot.create_list(:note, 2, title: '110-word South user critique',content: 'word '*110, note_type: 'critique', user: south_user)

FactoryBot.create_list(:note, 2, title: '130-word South user critique',content: 'word '*130, note_type: 'critique', user: south_user)


# CASOS BORDE DE TAMAÑO

FactoryBot.create_list(:note, 2, title: '50-word North user critique',content: 'word '*50, note_type: 'critique', user: north_user)

FactoryBot.create_list(:note, 2, title: '100-word North user critique',content: 'word '*100, note_type: 'critique', user: north_user)

FactoryBot.create_list(:note, 2, title: '60-word South user critique',content: 'word '*60, note_type: 'critique', user: south_user)

FactoryBot.create_list(:note, 2, title: '120-word South user critique',content: 'word '*120, note_type: 'critique', user: south_user)