# frozen_string_literal: true

require "rails_helper"

describe MetadataStandard do

  context "associations" do
    it { is_expected.to have_and_belong_to_many :research_outputs }
  end

  context "scopes" do
    before(:each) do
      @name_part = "Foobar"
      @disciplinary = create(:metadata_standard, discipline_specific: true)
      @generic = create(:metadata_standard, discipline_specific: false)
      @by_title = create(:metadata_standard, title: [Faker::Lorem.sentence, @name_part].join(" "))
      @by_description = create(:metadata_standard, description: [@name_part, Faker::Lorem.paragraph].join(" "))
    end

    it ":disciplinary returns the expected records" do
      results = described_class.disciplinary
      expect(results.include?(@disciplinary)).to eql(true)
      expect(results.include?(@generic)).to eql(false)
    end

    it ":generic returns the expected records" do
      results = described_class.generic
      expect(results.include?(@generic)).to eql(true)
      expect(results.include?(@disciplinary)).to eql(false)
    end

    it ":search returns the expected records" do
      results = described_class.search(@name_part)
      expect(results.include?(@by_title)).to eql(true)
      expect(results.include?(@by_description)).to eql(true)

      results = described_class.search("Zzzzzz")
      expect(results.include?(@by_title)).to eql(false)
      expect(results.include?(@by_description)).to eql(false)
    end

  end

end
