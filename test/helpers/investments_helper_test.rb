require "test_helper"

class InvestmentsHelperTest < ActionView::TestCase
  def setup
    @family = families(:dylan_family)
    
    # Create investment accounts with different countries for testing
    @us_account = @family.accounts.create!(
      name: "US Brokerage",
      accountable: Investment.new(subtype: "brokerage"),
      balance: 10000,
      currency: "USD"
    )
    
    @ca_account = @family.accounts.create!(
      name: "RRSP Account",
      accountable: Investment.new(subtype: "rrsp"),
      balance: 15000,
      currency: "CAD"
    )
  end

  test "investment_subtype_options_grouped returns properly formatted grouped options" do
    grouped = investment_subtype_options_grouped
    
    # Should be a hash with country keys
    assert_kind_of Hash, grouped
    assert_includes grouped.keys, "US"
    assert_includes grouped.keys, "CA"
    assert_includes grouped.keys, "UK"
    assert_includes grouped.keys, "International"
    
    # Each group should have array of [label, value] pairs
    us_options = grouped["US"]
    assert_kind_of Array, us_options
    assert us_options.length > 0
    
    # Check structure of individual options
    first_option = us_options.first
    assert_kind_of Array, first_option
    assert_equal 2, first_option.length
    assert_kind_of String, first_option[0] # label
    assert_kind_of String, first_option[1] # value
    
    # Verify specific expected options
    us_labels = us_options.map(&:first)
    assert_includes us_labels, "Brokerage"
    assert_includes us_labels, "401(k)"
    
    ca_options = grouped["CA"]
    ca_labels = ca_options.map(&:first)  
    assert_includes ca_labels, "RRSP"
    assert_includes ca_labels, "TFSA"
  end

  test "investment_subtype_options_flat returns flattened options array" do
    flat_options = investment_subtype_options_flat
    
    assert_kind_of Array, flat_options
    assert flat_options.length > 0
    
    # Should contain all subtypes from all countries
    labels = flat_options.map(&:first)
    assert_includes labels, "Brokerage" # US
    assert_includes labels, "RRSP"      # CA  
    assert_includes labels, "ISA"       # UK
    
    # Check option structure
    first_option = flat_options.first
    assert_equal 2, first_option.length
    assert_kind_of String, first_option[0]
    assert_kind_of String, first_option[1]
  end

  test "country_with_flag formats country names with flags" do
    assert_equal "🇺🇸 United States", country_with_flag("US")
    assert_equal "🇨🇦 Canada", country_with_flag("CA") 
    assert_equal "🇬🇧 United Kingdom", country_with_flag("UK")
    assert_equal "🌍 International", country_with_flag("International")
    
    # Test invalid country
    assert_equal "🇺🇸 Unknown", country_with_flag("INVALID")
    assert_equal "🇺🇸 Unknown", country_with_flag(nil)
  end

  test "investment_country_filter_options returns options with account counts" do
    investment_accounts = [@us_account, @ca_account]
    options = investment_country_filter_options(investment_accounts)
    
    assert_kind_of Array, options
    
    # Should have entries for countries with accounts
    option_labels = options.map(&:first)
    option_values = options.map(&:second)
    
    assert_includes option_labels, "🇺🇸 United States (1)"
    assert_includes option_values, "US"
    
    assert_includes option_labels, "🇨🇦 Canada (1)" 
    assert_includes option_values, "CA"
    
    # Should not have entries for countries without accounts
    assert_not_includes option_labels.join, "United Kingdom"
  end

  test "investment_country_filter_options handles empty account list" do
    options = investment_country_filter_options([])
    
    assert_kind_of Array, options
    assert_empty options
  end

  test "investment_country_filter_options handles multiple accounts per country" do
    # Create second US account
    second_us_account = @family.accounts.create!(
      name: "401k Account",
      accountable: Investment.new(subtype: "401k"),
      balance: 25000,
      currency: "USD"
    )
    
    investment_accounts = [@us_account, @ca_account, second_us_account]
    options = investment_country_filter_options(investment_accounts)
    
    # Should show correct count for US (2 accounts)
    us_option = options.find { |opt| opt[1] == "US" }
    assert_not_nil us_option
    assert_includes us_option[0], "(2)"
    
    # Should still show 1 for Canada
    ca_option = options.find { |opt| opt[1] == "CA" }
    assert_not_nil ca_option
    assert_includes ca_option[0], "(1)"
  end

  test "investment_country_filter_options sorts countries predictably" do
    investment_accounts = [@us_account, @ca_account]
    options = investment_country_filter_options(investment_accounts)
    
    # Should be sorted by country code
    values = options.map(&:second)
    assert_equal values.sort, values
  end

  test "helper methods handle nil inputs gracefully" do
    assert_nothing_raised do
      investment_country_filter_options(nil)
      country_with_flag(nil)
    end
  end

  test "helper methods integrate with Investment model correctly" do
    # Verify helpers use Investment model constants
    grouped = investment_subtype_options_grouped
    
    # Check that helper output matches model data
    Investment::SUBTYPE_COUNTRIES.each do |subtype, country|
      country_options = grouped[country]
      assert_not_nil country_options, "Missing options for country: #{country}"
      
      subtype_exists = country_options.any? { |opt| opt[1] == subtype }
      assert subtype_exists, "Missing subtype #{subtype} in #{country} options"
    end
  end
end