# frozen_string_literal: true

module Api

  class PlanPresenter

    attr_reader :data_contact
    attr_reader :contributors
    attr_reader :costs

    def initialize(plan:)
      @contributors = []
      return true unless plan.present?

      # Attach the first data_curation role as the data_contact, otherwise
      # add the contributor to the contributors array
      plan.plans_contributors.each do |pc|
        @data_contact = pc.contributor if pc.data_curation? && @data_contact.nil?
        next if @data_contact == pc.contributor

        @contributors << pc
      end

      @costs = plan_costs(plan: plan)
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