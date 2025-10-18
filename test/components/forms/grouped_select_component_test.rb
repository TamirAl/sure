require "test_helper"

class Forms::GroupedSelectComponentTest < ViewComponent::TestCase
  def setup
    @form_object = OpenStruct.new(subtype: "brokerage")
    @grouped_options = {
      "US" => [["Brokerage", "brokerage"], ["401(k)", "401k"]],
      "CA" => [["RRSP", "rrsp"], ["TFSA", "tfsa"]],
      "UK" => [["ISA", "isa"], ["SIPP", "sipp"]]
    }
  end

  test "renders grouped select with all optgroups" do
    with_form_for(@form_object) do |form|
      render_inline(Forms::GroupedSelectComponent.new(
        form: form,
        field: :subtype,
        grouped_options: @grouped_options,
        prompt: "Select account type"
      ))
      
      assert_selector "select[name='subtype']"
      assert_selector "option[value='']", text: "Select account type"
      
      # Should have optgroups for each country
      assert_selector "optgroup[label='US']"
      assert_selector "optgroup[label='CA']"
      assert_selector "optgroup[label='UK']"
      
      # Should have options within groups
      assert_selector "optgroup[label='US'] option[value='brokerage']", text: "Brokerage"
      assert_selector "optgroup[label='CA'] option[value='rrsp']", text: "RRSP"
    end
  end

  test "filters options by country when filter_by_country specified" do
    with_form_for(@form_object) do |form|
      render_inline(Forms::GroupedSelectComponent.new(
        form: form,
        field: :subtype,
        grouped_options: @grouped_options,
        filter_by_country: "CA"
      ))
      
      # Should only show Canadian optgroup
      assert_selector "optgroup[label='CA']"
      assert_no_selector "optgroup[label='US']"
      assert_no_selector "optgroup[label='UK']"
      
      assert_selector "option[value='rrsp']", text: "RRSP"
      assert_no_selector "option[value='brokerage']"
    end
  end

  test "includes Stimulus controller data attributes" do
    with_form_for(@form_object) do |form|
      render_inline(Forms::GroupedSelectComponent.new(
        form: form,
        field: :subtype,
        grouped_options: @grouped_options
      ))
      
      assert_selector "select[data-controller*='investment-subtype-filter']"
    end
  end

  test "applies proper CSS classes" do
    with_form_for(@form_object) do |form|
      render_inline(Forms::GroupedSelectComponent.new(
        form: form,
        field: :subtype,
        grouped_options: @grouped_options
      ))
      
      # Should have Tailwind classes from design system
      assert_selector "select.block"
      assert_selector "select.w-full"
      assert_selector "select.rounded-md"
      assert_selector "select.border-secondary"
    end
  end

  test "handles include_blank option" do
    with_form_for(@form_object) do |form|
      render_inline(Forms::GroupedSelectComponent.new(
        form: form,
        field: :subtype,
        grouped_options: @grouped_options,
        include_blank: "None selected"
      ))
      
      assert_selector "option[value='']", text: "None selected"
    end
  end

  test "selects current value when form object has value" do
    @form_object.subtype = "rrsp"
    
    with_form_for(@form_object) do |form|
      render_inline(Forms::GroupedSelectComponent.new(
        form: form,
        field: :subtype,
        grouped_options: @grouped_options
      ))
      
      assert_selector "option[value='rrsp'][selected]"
    end
  end

  test "handles empty grouped_options gracefully" do
    with_form_for(@form_object) do |form|
      render_inline(Forms::GroupedSelectComponent.new(
        form: form,
        field: :subtype,
        grouped_options: {}
      ))
      
      assert_selector "select"
      assert_no_selector "optgroup"
    end
  end

  test "handles malformed grouped_options gracefully" do
    malformed_options = {
      "US" => nil,
      "CA" => []
    }
    
    with_form_for(@form_object) do |form|
      assert_nothing_raised do
        render_inline(Forms::GroupedSelectComponent.new(
          form: form,
          field: :subtype,
          grouped_options: malformed_options
        ))
      end
    end
  end

  private

  def with_form_for(object, &block)
    form_builder = ActionView::Helpers::FormBuilder.new(:test, object, self, {})
    block.call(form_builder)
  end
end