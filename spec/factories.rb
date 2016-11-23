FactoryGirl.define do
  to_create { |instance| instance.save }

  factory :user do
    email 'test@example.com'
  end

  factory :game do
    sequence :id
    version '1.0'
    users []
    deck [1,2,3]
    settings ''
    state :new
    association :user
  end

  factory :action do
  end
end
