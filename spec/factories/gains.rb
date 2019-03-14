FactoryGirl.define do
    factory :gain do
        description { Faker::Lorem.sentence }
        value "50"
        date { Faker::Date.forward }
        user
    end
end