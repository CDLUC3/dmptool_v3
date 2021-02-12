# frozen_string_literal: true

require "csv"

# DMPRoadmap constants
#
# This file is a consolidation of the old custom configuration previously spread
# across the application.rb, branding.yml and the contact_us, devise, recaptcha,
# constants and wicked_pdf initializers
#
# It works in conjunction with the new Rails 5 config/credentials.yml.enc file
# for information on how to use the credentials file see:
#    https://medium.com/cedarcode/rails-5-2-credentials-9b3324851336
#
# This file's name begins with an underscore so that it is processed first and its
# values are available to all other initializers within this directory!
module DMPRoadmap

  class Application < Rails::Application

    # --------------------- #
    # ORGANISATION SETTINGS #
    # --------------------- #

    # Your organisation name, used in various places throught the application
    config.x.organisation.name = "University of California Curation Center (UC3)"
    # Your organisation's abbreviation
    config.x.organisation.abbreviation = "DMPTool"
    # Your organisation's homepage, used in some of the public facing pages
    config.x.organisation.url = "https://www.cdlib.org/"
    # Your organisation's legal (official) name - used in the copyright portion of the footer
    config.x.organisation.copywrite_name = "The Regents of the University of California"
    # This email is used as the 'from' address for emails generated by the application
    config.x.organisation.email = ENV["HELPDESK_EMAIL"]
    # This email is used as the 'from' address for the feedback_complete email to users
    config.x.organisation.do_not_reply_email = ENV["DO_NOT_REPLY_EMAIL"]
    # This email is used in email communications
    config.x.organisation.helpdesk_email = ENV["HELPDESK_EMAIL"]
    # Your organisation's telephone number - used on the contact us page
    config.x.organisation.telephone = "+1-510-987-0555"
    # Your organisation's address - used on the contact us page
    # rubocop:disable Naming/VariableNumber
    config.x.organisation.address = {
      line_1: "University of California",
      line_2: "Office of the President",
      line_3: "1111 Franklin Street",
      line_4: "Oakland, CA 94607",
      country: "USA"
    }
    # rubocop:enable Naming/VariableNumber

    # The Google maps link to your organisation's location - used to display the
    # Google map on the contact us page.
    # To find your organisation's Google maps URL, open maps.google.com, search for
    # your orgnaisation and then click the menu link to the left of the search box,
    # once the menu opens, click the 'share or embed' link and the 'embed' tab on
    # the dialog window that opens. DO NOT place the entire <iframe> tag below, just
    # the address!
    config.x.organisation.google_maps_link = "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3152.2214785789347!2d-122.26972218390863!3d37.80828097975344!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x808f80b28e26ec6d%3A0x61d8b66ecd97a18c!2s415+20th+St%2C+Oakland%2C+CA+94612!5e0!3m2!1sen!2sus!4v1479338425002"

    # Uncomment the following line if you want to redirect your users to an
    # organisational contact/help page instead of using the built-in contact_us form
    config.x.organisation.contact_us_url = "https://dmptool.org/contact-us"

    # -------------------- #
    # APPLICATION SETTINGS #
    # -------------------- #

    # Used throughout the system via ApplicationService.application_name
    config.x.application.name = ENV["APPLICATION_NAME"]
    # Used as the default domain when 'archiving' (aka anonymizing) a user account
    # for example `jane.doe@uni.edu` becomes `1234@removed_accounts-example.org`
    config.x.application.archived_accounts_email_suffix = "@removed_accounts-dmptool.org"
    # Available CSV separators, the default is ','
    config.x.application.csv_separators = [",", "|", "#"]
    # The largest page size allowed in requests to the API (all versions)
    config.x.application.api_max_page_size = 100
    # The link to the API documentation - used in emails about the API
    config.x.application.api_documentation_urls = {
      v0: "https://github.com/DMPRoadmap/roadmap/wiki/API-V0-Documentation",
      v1: "https://github.com/DMPRoadmap/roadmap/wiki/API-Documentation-V1"
    }
    # The link to our release notes
    config.x.application.release_notes_url = "https://github.com/CDLUC3/dmptool/wiki/Releases"
    # The link to our issues list
    config.x.application.issue_list_url = "https://github.com/CDLUC3/dmptool/issues"
    # The link to our Listserv
    config.x.application.user_group_subscription_url = "http://listserv.ucop.edu/cgi-bin/wa.exe?SUBED1=ROADMAP-L&A=1"
    # The link to the DMPTool blog
    config.x.application.blog_rss = "https://blog.dmptool.org/feed"
    # The links that appear on the home page. Add any number of links
    config.x.application.welcome_links = [
      {
        title: "University of California Curation Center (UC3)",
        url: "https://www.cdlib.org/uc3/"
      }, {
        title: "California Digital Library",
        url: "https://www.cdlib.org/"
      }, {
        title: "US funder requirements for Data Management Plans",
        url: "https://dmptool.org/guidance"
      }, {
        title: "DCC Checklist for a Data Management Plan",
        url: "https://dmponline.dcc.ac.uk/files/DMP_Checklist_2013.pdf"
      }
    ]
    # The default user email preferences used when a new account is created
    config.x.application.preferences = {
      email: {
        users: {
          new_comment: false,
          admin_privileges: true,
          added_as_coowner: true,
          feedback_requested: true,
          feedback_provided: true
        },
        owners_and_coowners: {
          visibility_changed: true
        }
      }
    }

    # ------------------- #
    # SHIBBOLETH SETTINGS #
    # ------------------- #

    # Enable shibboleth as an alternative authentication method
    # Requires server configuration and omniauth shibboleth provider configuration
    # See config/initializers/devise.rb
    config.x.shibboleth.enabled = ENV["SHIBBOLETH_ENABLED"]

    # Relative path to Shibboleth SSO Logouts
    config.x.shibboleth.login_url = "/Shibboleth.sso/Login"
    config.x.shibboleth.logout_url = "/Shibboleth.sso/Logout?return="

    # If this value is set to true your users will be presented with a list of orgs that have a
    # shibboleth identifier in the orgs_identifiers table. If it is set to false (default), the user
    # will be driven out to your federation's discovery service
    #
    # A super admin will also be able to associate orgs with their shibboleth entityIds if this is
    # set to true
    config.x.shibboleth.use_filtered_discovery_service = true

    # ------- #
    # LOCALES #
    # ------- #

    # The default locale (use the i18n format!)
    config.x.locales.default = "en-US"
    # The character that separates a locale's ISO code for i18n. (e.g. `en-GB` or `en`)
    # Changing this value is not recommended!
    config.x.locales.i18n_join_character = "-"
    # The character that separates a locale's ISO code for Gettext. (e.g. `en_GB` or `en`)
    # Changing this value is not recommended!
    config.x.locales.gettext_join_character = "_"

    # ---------- #
    # THRESHOLDS #
    # ---------- #

    # Determines the number of links a funder is allowed to add to their template
    config.x.max_number_links_funder = 5
    # Maximum number of links to display for an Org
    config.x.max_number_links_org = 3
    # Determines the number of links a funder can add for sample plans for their template
    config.x.max_number_links_sample_plan = 5
    # Determines the maximum number of themes to display per column when an org admin
    # updates a template question or guidance
    config.x.max_number_themes_per_column = 5
    # default results per page
    config.x.results_per_page = 10

    # ------------- #
    # PLAN DEFAULTS #
    # ------------- #

    # The default visibility a plan receives when it is created.
    # options: 'privately_visible', 'organisationally_visible' and 'publicly_visibile'
    config.x.plans.default_visibility = "privately_visible"

    # The percentage of answers that have been filled out that determine if a plan
    # will be marked as complete. Plan completion has implications on whether or
    # not plan visibility settings are editable by the user and whether or not the
    # plan can be submitted for feedback
    config.x.plans.default_percentage_answered = 50

    # Whether or not Super adminis can read all of the user's plans regardless of
    # the plans visibility and whether or not the plan has been shared
    config.x.plans.org_admins_read_all = true
    # Whether or not Organisational administrators can read all of the user's plans
    # regardless of the plans visibility and whether or not the plan has been shared
    config.x.plans.super_admins_read_all = true

    # ---------------------------------------------------- #
    # CACHING - all values are in seconds (86400 == 1 Day) #
    # ---------------------------------------------------- #

    # Determines how long to cache results for OrgSelection::SearchService
    config.x.cache.org_selection_expiration = 86_400
    # Determines how long to cache results for the ResearchProjectsController
    config.x.cache.research_projects_expiration = 86_400

    # ---------------- #
    # Google Analytics #
    # ---------------- #
    # this is the abbreviation for the installation's root org as set in the org table
    config.x.google_analytics.tracker_root = ENV["GOOGLE_ANALYTICS_TRACKER_ROOT"]

    # ------------------------------------------------------------------------ #
    # reCAPTCHA - recaptcha appears on the create account and contact us forms #
    # ------------------------------------------------------------------------ #
    config.x.recaptcha.enabled = Rails.env.development? ? false : ENV["RECAPTCHA_ENABLED"]

    # ----------- #
    # DOI Minting
    # ----------- #
    config.x.allow_doi_minting = ENV["DOI_MINTING_ENABLED"]

  end

end
