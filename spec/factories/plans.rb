# frozen_string_literal: true

# == Schema Information
#
# Table name: plans
#
#  id                                :integer          not null, primary key
#  complete                          :boolean          default(FALSE)
#  data_contact                      :string(255)
#  data_contact_email                :string(255)
#  data_contact_phone                :string(255)
#  description                       :text(65535)
#  end_date                          :datetime
#  ethical_issues                    :boolean
#  ethical_issues_description        :text(65535)
#  ethical_issues_report             :string(255)
#  feedback_requested                :boolean          default(FALSE)
#  funder_name                       :string(255)
#  grant_number                      :string(255)
#  identifier                        :string(255)
#  principal_investigator            :string(255)
#  principal_investigator_email      :string(255)
#  principal_investigator_identifier :string(255)
#  principal_investigator_phone      :string(255)
#  start_date                        :datetime
#  title                             :string(255)
#  visibility                        :integer          default("privately_visible"), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#  funder_id                         :integer
#  grant_id                          :integer
#  org_id                            :integer
#  template_id                       :integer
#
# Indexes
#
#  index_plans_on_funder_id    (funder_id)
#  index_plans_on_grant_id     (grant_id)
#  index_plans_on_org_id       (org_id)
#  index_plans_on_template_id  (template_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (template_id => templates.id)
#

FactoryBot.define do
  factory :plan do
    title { Faker::Company.bs }
    template
    org
    # TODO: Drop this column once the funder_id has been back filled
    #       and we're removing the is_other org stuff
    grant_number { SecureRandom.rand(1_000) }
    identifier { SecureRandom.hex }
    description { Faker::Lorem.paragraph }
    principal_investigator { Faker::Name.name }
    # TODO: Drop this column once the funder_id has been back filled
    #       and we're removing the is_other org stuff
    funder_name { Faker::Company.name }
    data_contact_email { Faker::Internet.safe_email }
    principal_investigator_email { Faker::Internet.safe_email }
    feedback_requested { false }
    complete { false }
    start_date { Time.now }
    end_date { start_date + 2.years }
    ethical_issues { [true, false].sample }
    ethical_issues_description { Faker::Lorem.paragraph }
    ethical_issues_report { Faker::Internet.url }

    transient do
      phases { 0 }
      answers { 0 }
      guidance_groups { 0 }
    end
    trait :creator do
      after(:create) do |obj|
        obj.roles << create(:role, :creator, user: create(:user, org: create(:org)))
      end
    end
    trait :commenter do
      after(:create) do |obj|
        obj.roles << create(:role, :commenter, user: create(:user, org: create(:org)))
      end
    end
    trait :organisationally_visible do
      visibility { "organisationally_visible" }
    end

    trait :publicly_visible do
      visibility { "publicly_visible" }
    end

    trait :is_test do
      visibility { "is_test" }
    end

    trait :privately_visible do
      visibility { "privately_visible" }
    end

    after(:create) do |plan, evaluator|
      create_list(:answer, evaluator.answers, plan: plan)
    end

    after(:create) do |plan, evaluator|
      plan.guidance_groups << create_list(:guidance_group, evaluator.guidance_groups)
    end

  end
end
