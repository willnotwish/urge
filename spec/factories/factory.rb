FactoryGirl.define do

  factory :client do
    name "Cash It In Limited"
    code "9999"
  end

  factory :guest do
    sequence :joined_at do |n|
      n.weeks.ago
    end

    first_name "Freddy"
    sequence :last_name do |n|
      "Starr#{n}"
    end
    
    sequence :email do |n|
      "fs#{n}@example.com"
    end
    
  end

end