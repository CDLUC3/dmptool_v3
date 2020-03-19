# frozen_string_literal: true

# locals: plan

json.schema "https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard/tree/master/examples/JSON/JSON-schema/1.0"

presenter = Api::V1::PlanPresenter.new(plan: plan)

# A JSON representation of a Data Management Plan in the
# RDA Common Standard format
json.title plan.title
json.description plan.description
json.language Api::V1::LanguagePresenter.three_char_code(
  lang: ApplicationService.default_language
)
json.created plan.created_at.utc.to_s
json.modified plan.updated_at.utc.to_s

# TODO: Update this to pull from the appropriate question once the work is complete
json.ethical_issues_exist "unknown"
#json.ethical_issues_description ""
#json.ethical_issues_report ""

id = presenter.identifier
if id.present?
  json.dmp_id do
    json.partial! 'api/v1/identifiers/show', identifier: id
  end
end

if presenter.data_contact.present?
  json.contact do
    json.partial! "api/v1/contributors/show", contributor: presenter.data_contact,
                                              is_contact: true
  end
end

if presenter.contributors.any?
  json.contributor presenter.contributors do |contributor|
    json.partial! "api/v1/contributors/show", contributor: contributor,
                                              is_contact: false
  end
end

if presenter.costs.any?
  json.cost presenter.costs do |cost|
    json.partial! 'api/v1/plans/cost', cost: cost
  end
end

json.project [plan] do |pln|
  json.partial! 'api/v1/plans/project', plan: pln
end

json.dataset [plan] do |dataset|
  json.partial! 'api/v1/datasets/show', plan: plan
end

json.extension [plan.template] do |template|
  json.set! ApplicationService.application_name.split("-").first.to_sym do
    json.template do
      json.id template.id
      json.title template.title
    end
  end
end
