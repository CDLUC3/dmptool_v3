# frozen_string_literal: true

module Api

  module V1

    # Base API Controller
    class BaseApiController < ApplicationController

      protect_from_forgery with: :null_session

      respond_to :json

      # Verify the JWT
      before_action :authorize_request, except: %i[heartbeat]

      # Prep default instance variables for views
      before_action :base_response_content
      before_action :pagination_params, except: %i[heartbeat]

      # Parse the incoming JSON
      before_action :parse_request, only: %i[create update]

      attr_reader :client

      # GET /api/v1/heartbeat
      def heartbeat
        render "/api/v1/heartbeat", status: :ok
      end

      protected

      def render_error(errors:, status:)
        @payload = { errors: [errors] }
        render "/api/v1/error", status: status and return
      end

      private

      attr_accessor :json

      # ==========================
      # CALLBACKS
      # ==========================
      def authorize_request
        auth_svc = Api::Auth::Jwt::AuthorizationService.new(
          headers: request.headers
        )
        @client = auth_svc.call
        log_access if @client.present?
        return true if @client.present?

        render_error(
          errors: auth_svc.errors, status: :unauthorized
        ) unless @client.present?
      end

      # Set the generic application and caller variables used in all responses
      def base_response_content
        @application = ApplicationService.application_name
        @caller = caller_name
      end

      # Retrieve the requested pagination params or use defaults
      # only allow 100 per page as the max
      def pagination_params
        @page = params.fetch('page', 1).to_i
        @per_page = params.fetch('per_page', 20).to_i
        @per_page = 100 if @per_page > 100
      end

      # Parse the body of the incoming request
      def parse_request
        return false unless request.present? && request.body.present?

        begin
          @json = JSON.parse(request.body.read)

          # Validate the JSON
          errors = validate_json
          render_error(errors: errors, status: :bad_request) if errors.any?
          errors.empty?

        rescue JSON::ParserError => pe
          render_error(errors: _("Invalid JSON format"), status: :bad_request)
          return false
        end
      end

      # ==========================

      def log_access
        obj = client
        return false unless obj.present?

        obj.update(last_access: Time.now) if obj.is_a?(ApiClient)
        obj.update(last_api_access: Time.now) if obj.is_a?(User)
        true
      end

      # Returns either the User name or the ApiClient name
      def caller_name
        obj = client
        return request.remote_ip unless obj.present?

        obj.is_a?(User) ? obj.name(false) : obj.name
      end

      def paginate_response(results:)
        results = results.page(@page).per(@per_page)
        @total_items = results.total_count
        results
      end

      def validate_json
        # Minimum acceptable DMP json:
        #
        # "dmp": {
        #   "title": "My Minimal DMP",
        #   "contact": {
        #     "name": "Charlie Chaplin",
        #     "mbox": "cc@example.com"
        #   }
        # }
        # And a DOI or DMPTool id when updating:
        #   "dmp_ids": [
        #     { "type": "doi", "identifier": "123abc/12e" }
        #     { "type": "dmptool", "identifier": "123" }
        #   ]
        #
        # Or a template_id when creating:
        #
        errors = []
        @json = @json.with_indifferent_access

        @json.fetch(:items, []).each_with_index do |item, idx|
          if item.is_a?(Hash)
            dmp = item[:dmp]
            if dmp.present?
              if dmp.fetch(:title, "").blank?
                errors << _("Expected item #{idx + 1} to have a {'dmp':{'title'}}!")
              end

              if dmp[:contact].present?
                unless dmp[:contact][:mbox].present?
                  errors << _("Expected item #{idx + 1} to have a {'dmp':{'contact':{'mbox'}}}!")
                end
              else
                errors << _("Expected item #{idx + 1} to have a {'dmp':{'contact'}}!")
              end

              # Either the plan id or template id must be present
              app = ApplicationService.application_name
              id = dmp.fetch(:dmp_ids, []).select { |id| ["doi", app].include?(id.fetch(:type, "").downcase) }
              template = dmp.fetch(:extended_attributes, {}).fetch(:"#{app}", {})[:template_id]

              unless id.present? || template.present?
                errors << _("Expected item #{idx + 1} to have either a {'dmp':{'dmp_ids':[{'type':'#{app}','identifier'}]}} when updating or a {'dmp':{'extended_attributes':{'#{app}':{'template_id'}}}} if creating!")
              end
            else
              errors << _("Expected item #{idx + 1} to be {'dmp':{}}")
            end

          else
            errors << _("Expected 'items' to be an array!")
          end
        end

        errors
      end

      # =========================
      # PERMIITTED PARAMS HEPERS
      # =========================
      def plan_permitted_params
        %i[created title description language ethical_issues_exist
           ethical_issues_description ethical_issues_report] +
          [dmp_ids: identifier_permitted_params,
           contact: contributor_permitted_params,
           contributors: contributor_permitted_params,
           costs: cost_permitted_params,
           project: project_permitted_params,
           datasets: dataset_permitted_params]
      end

      def identifier_permitted_params
        %i[type identifier]
      end

      def contributor_permitted_params
        %i[firstname surname mbox role] +
          [affiliations: affiliation_permitted_params,
           contributor_ids: identifier_permitted_params]
      end

      def affiliation_permitted_params
        %i[name abbreviation] +
          [affiliation_ids: identifier_permitted_params]
      end

      def cost_permitted_params
        %i[title description value currency_code]
      end

      def project_permitted_params
        %i[title description start_on end_on] +
          [funding: funding_permitted_params]
      end

      def funding_permitted_params
        %i[name funding_status] +
          [funder_ids: identifier_permitted_params,
           grant_ids: identifier_permitted_params]
      end

      def dataset_permitted_params
        %i[title description type issued language personal_data sensitive_data
           keywords data_quality_assurance preservation_statement] +
          [dataset_ids: identifier_permitted_params,
           metadata: metadatum_permitted_params,
           security_and_privacy_statements: security_and_privacy_statement_permitted_params,
           technical_resources: technical_resource_permitted_params,
           distributions: distribution_permitted_params]
      end

      def metadatum_permitted_params
        %i[description language] + [identifier: identifier_permitted_params]
      end

      def security_and_privacy_statement_permitted_params
        %i[title description]
      end

      def technical_resource_permitted_params
        %i[description] + [identifier: identifier_permitted_params]
      end

      def distribution_permitted_params
        %i[title description format byte_size access_url download_url
           data_access available_until] +
          [licenses: license_permitted_params, host: host_permitted_params]
      end

      def license_permitted_params
        %i[license_ref start_date]
      end

      def host_permitted_params
        %i[title description supports_versioning backup_type backup_frequency
           storage_type availability geo_location certified_with pid_system] +
          [host_ids: identifier_permitted_params]
      end

    end

  end

end