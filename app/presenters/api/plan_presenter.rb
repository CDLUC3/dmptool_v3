# frozen_string_literal: true

module Api

  class PlanPresenter

    attr_reader :data_contact
    attr_reader :contributors
    attr_reader :costs

    def initialize(plan:)
      @contributors = []
      return true unless plan.present?

      @plan = plan

      # Attach the first data_curation role as the data_contact, otherwise
      # add the contributor to the contributors array
      @plan.contributors.each do |contributor|
        @data_contact = contributor if contributor.data_curation? && @data_contact.nil?
        next if @data_contact == contributor

        @contributors << contributor
      end

      @costs = plan_costs(plan: @plan)
    end

    def identifiers
      ids = @plan.identifiers.select { |id| id.identifier_scheme.name != "grant" }
      scheme = IdentifierScheme.new(name: ApplicationService.application_name)
      ids << Identifier.new(identifier_scheme: scheme, value: @plan.id)
      ids
    end

    private

    # Retrieve the answers that have the Budget theme
    def plan_costs(plan:)
      theme = Theme.where(title: "Cost").first
      return [] unless theme.present?

      # TODO: define a new 'Currency' question type that includes a float field
      #       any currency type selector (e.g GBP or USD)
      answers = plan.answers.includes(question: :themes).select do |answer|
        answer.question.themes.include?(theme)
      end

      answers.map do |answer|
        # TODO: Investigate whether question level guidance should be the description
        { title: answer.question.text, description: nil,
          currency_code: "usd", value: answer.text }
      end
    end

  end

end
