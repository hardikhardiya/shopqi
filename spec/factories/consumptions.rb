# encoding: utf-8
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :consumption do
    plan_type_id KeyValues::Plan::Type.where(name: 'Professional Edition').first.id
    quantity 2
  end
end
