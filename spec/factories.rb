FactoryGirl.define do
  to_create { |instance| instance.save }

  factory :user do
    sequence(:name) { |n| "person#{n}" }
    sequence(:email) { |n| "person#{n}@example.com" }
    password 'pass'
  end

  factory :game do
    sequence :id
    users []
    association :user
  end

  factory :session do
    token  "token"
    association :user
  end


  factory :action do
  end
end
