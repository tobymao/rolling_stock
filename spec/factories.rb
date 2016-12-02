FactoryGirl.define do
  to_create { |instance| instance.save }

  factory :user do
    name 'name'
    email 'test@example.com'
    password 'pass'
  end

  factory :game do
    sequence :id
    version '1.0'
    users [1,2,3]
    deck ['BME', 'BSE']
    settings ''
    state :new
    association :user
  end

  factory :action do
  end
end
