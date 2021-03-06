# frozen_string_literal: true

require_relative "boot"

require "rails/all"

require "csv"
require "uc3-ssm"

# Question: is there a nicer way to do this require_relative?
require_relative "../lib/ssm_config_loader"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Ensure our custom config loader ssm_parameter_store is inserted into Anyway.loaders
# prior to instantiating our custom Anyway::Config classes.
::Anyway.loaders.insert_before(:env, :ssm_parameter_store, SsmConfigLoader)

# Load master_key into ENV
if ENV.has_key?('SSM_ROOT_PATH')
  begin
    ssm = Uc3Ssm::ConfigResolver.new
    master_key = ssm.parameter_for_key('master_key')
    ENV['RAILS_MASTER_KEY'] = master_key.chomp unless master_key.nil? or master_key.empty?
  rescue => e
    ActiveSupport::Logger.new($stdout).warn("Could not retrieve master_key from SSM Parameter Store: #{e.full_message}")
  end
end

module DMPRoadmap

  class Application < Rails::Application

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # --------------------------------- #
    # OVERRIDES TO DEFAULT RAILS CONFIG #
    # --------------------------------- #

    config.autoload_paths += %W[#{config.root}/lib]

    # HTML tags that are allowed to pass through `sanitize`.
    config.action_view.sanitized_allowed_tags = %w[
      p br strong em a table thead tbody tr td th tfoot caption ul ol li
    ]

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Allow controllers to access view helpers
    # TODO: We should see what methods specifically are used by the controllers
    #       and include them specifically in the controllers. We should also consider
    #       moving our helper methods into Presenters if it makes sense
    config.action_controller.include_all_helpers = true

    # Load AnywayConfig class, but not if running `rails credentials:edit`
    unless defined?(::Rails::Command::CredentialsCommand)
      config.x.dmproadmap = DmproadmapConfig.new
    end

    # Set the default host for mailer URLs
    config.action_mailer.default_url_options = { host: config.x.dmproadmap.server_host }
  end

end
