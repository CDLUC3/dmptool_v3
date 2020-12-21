# frozen_string_literal: true

class ResearchOutputPresenter

  attr_accessor :research_output

  def initialize(research_output:)
    @research_output = research_output
  end

  # Returns the output_type list for a select_tag
  def selectable_output_types
    ResearchOutput.output_types
                  .map { |k, _v| [k.humanize, k] }
  end

  # Returns the mime_type list for a select_tag
  def selectable_mime_types
    @research_output.available_mime_types
                    .reject { |mime| mime.description.downcase.include?("deprecated") }
                    .sort { |a, b| a.value.downcase <=> b.value.downcase }
                    .map { |mime| [mime.value, mime.id] }
  end

  # Returns the access options for a select tag
  def selectable_access_types
    ResearchOutput.accesses
                  .map { |k, _v| [k.humanize, k] }
  end

  # Returns the options for file size units
  def selectable_size_units
    [%w[MB mb], %w[GB gb], %w[TB tb], %w[PB pb], ["bytes", ""]]
  end

  # TODO: These values should either live as an enum on the Model or in the DB
  def selectable_coverage_regions
    %w[africa americas antarctic arctic asia australia europe middle_east
       polynesia].map { |region| [region.humanize, region] }
  end

  # Converts the byte_size into a more friendly value (e.g. 15.4 MB)
  def converted_file_size(size:)
    return { size: nil, unit: "mb" } unless size.present? && size.is_a?(Numeric)

    return { size: size.petabytes, unit: "pb" } if size >= 1.petabytes
    return { size: size.terabytes, unit: "tb" } if size >= 1.terabytes
    return { size: size.gigabytes, unit: "gb" } if size >= 1.gigabytes
    return { size: size.megabytes, unit: "mb" } if size >= 1.megabytes

    { size: size, unit: "" }
  end

  # Returns the abbreviation if available or a snippet of the title
  def display_name
    return "" unless @research_output.is_a?(ResearchOutput)
    return @research_output.abbreviation if @research_output.abbreviation.present?

    "#{@research_output.title[0..20]} ..."
  end

  # Returns the abbreviation if available or a snippet of the title
  def display_type
    return "" unless @research_output.is_a?(ResearchOutput)
    # Return the user entered text for the type if they selected 'other'
    return output_type_description if @research_output.other?

    @research_output.output_type.gsub("_", " ").capitalize
  end

end
