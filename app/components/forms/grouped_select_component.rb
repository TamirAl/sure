class Forms::GroupedSelectComponent < ApplicationComponent
  def initialize(form:, field:, grouped_options:, **options)
    @form = form
    @field = field
    @grouped_options = grouped_options
    @options = options
  end

  private

  attr_reader :form, :field, :grouped_options, :options
end