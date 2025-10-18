require "test_helper"

class InvestmentTest < ActiveSupport::TestCase
  def setup
    @investment = investments(:one)
  end

  # Test SUBTYPE_COUNTRIES constant and country detection
  test "has comprehensive subtype countries mapping" do
    # Test US account types
    assert_equal "US", Investment::SUBTYPE_COUNTRIES["brokerage"]
    assert_equal "US", Investment::SUBTYPE_COUNTRIES["401k"]
    assert_equal "US", Investment::SUBTYPE_COUNTRIES["ira"]
    
    # Test Canadian account types
    assert_equal "CA", Investment::SUBTYPE_COUNTRIES["rrsp"]
    assert_equal "CA", Investment::SUBTYPE_COUNTRIES["tfsa"]
    assert_equal "CA", Investment::SUBTYPE_COUNTRIES["resp"]
    
    # Test UK account types
    assert_equal "UK", Investment::SUBTYPE_COUNTRIES["isa"]
    assert_equal "UK", Investment::SUBTYPE_COUNTRIES["sipp"]
    
    # Test International account types
    assert_equal "International", Investment::SUBTYPE_COUNTRIES["international_brokerage"]
    
    # Verify we have comprehensive coverage (40+ subtypes)
    assert_operator Investment::SUBTYPE_COUNTRIES.keys.length, :>=, 40
  end

  test "has tax treatments mapping" do
    # Test tax-deferred accounts
    assert_includes Investment::TAX_TREATMENTS["tax_deferred"], "401k"
    assert_includes Investment::TAX_TREATMENTS["tax_deferred"], "rrsp"
    assert_includes Investment::TAX_TREATMENTS["tax_deferred"], "pension"
    
    # Test tax-free accounts
    assert_includes Investment::TAX_TREATMENTS["tax_free"], "roth_ira"
    assert_includes Investment::TAX_TREATMENTS["tax_free"], "tfsa"
    assert_includes Investment::TAX_TREATMENTS["tax_free"], "isa"
    
    # Test taxable accounts
    assert_includes Investment::TAX_TREATMENTS["taxable"], "brokerage"
    assert_includes Investment::TAX_TREATMENTS["taxable"], "international_brokerage"
  end

  test "country method returns correct country code" do
    investment = Investment.new(subtype: "brokerage")
    assert_equal "US", investment.country
    
    investment = Investment.new(subtype: "rrsp")
    assert_equal "CA", investment.country
    
    investment = Investment.new(subtype: "isa")
    assert_equal "UK", investment.country
    
    investment = Investment.new(subtype: "international_brokerage")
    assert_equal "International", investment.country
    
    # Test unknown subtype defaults to US
    investment = Investment.new(subtype: "unknown_type")
    assert_equal "US", investment.country
  end

  test "country_flag method returns correct emoji flags" do
    investment = Investment.new(subtype: "brokerage")
    assert_equal "🇺🇸", investment.country_flag
    
    investment = Investment.new(subtype: "rrsp")
    assert_equal "🇨🇦", investment.country_flag
    
    investment = Investment.new(subtype: "isa")
    assert_equal "🇬🇧", investment.country_flag
    
    investment = Investment.new(subtype: "international_brokerage")
    assert_equal "🌍", investment.country_flag
    
    # Test unknown subtype defaults to US flag
    investment = Investment.new(subtype: "unknown_type")
    assert_equal "🇺🇸", investment.country_flag
  end

  test "tax_treatment method returns correct tax category" do
    investment = Investment.new(subtype: "401k")
    assert_equal "tax_deferred", investment.tax_treatment
    
    investment = Investment.new(subtype: "roth_ira")
    assert_equal "tax_free", investment.tax_treatment
    
    investment = Investment.new(subtype: "brokerage")
    assert_equal "taxable", investment.tax_treatment
    
    # Test unknown subtype defaults to taxable
    investment = Investment.new(subtype: "unknown_type")
    assert_equal "taxable", investment.tax_treatment
  end

  test "tax_treatment_badge method returns styled badge hash" do
    investment = Investment.new(subtype: "401k")
    badge = investment.tax_treatment_badge
    
    assert_equal "Tax Deferred", badge[:text]
    assert_includes badge[:class], "bg-yellow-100"
    assert_includes badge[:class], "text-yellow-800"
    
    investment = Investment.new(subtype: "roth_ira")
    badge = investment.tax_treatment_badge
    
    assert_equal "Tax Free", badge[:text]
    assert_includes badge[:class], "bg-green-100"
    assert_includes badge[:class], "text-green-800"
    
    investment = Investment.new(subtype: "brokerage")
    badge = investment.tax_treatment_badge
    
    assert_equal "Taxable", badge[:text]
    assert_includes badge[:class], "bg-gray-100"
    assert_includes badge[:class], "text-gray-600"
  end

  # Test class methods
  test "grouped_by_country returns subtypes grouped by country" do
    grouped = Investment.grouped_by_country
    
    assert_includes grouped.keys, "US"
    assert_includes grouped.keys, "CA"
    assert_includes grouped.keys, "UK"
    assert_includes grouped.keys, "International"
    
    # Verify specific subtypes are in correct groups
    assert_includes grouped["US"], "brokerage"
    assert_includes grouped["CA"], "rrsp"
    assert_includes grouped["UK"], "isa"
    assert_includes grouped["International"], "international_brokerage"
  end

  test "subtypes_for_country filters subtypes by country" do
    us_subtypes = Investment.subtypes_for_country("US")
    ca_subtypes = Investment.subtypes_for_country("CA")
    
    assert_includes us_subtypes, "brokerage"
    assert_includes us_subtypes, "401k"
    assert_not_includes us_subtypes, "rrsp"
    
    assert_includes ca_subtypes, "rrsp"
    assert_includes ca_subtypes, "tfsa"
    assert_not_includes ca_subtypes, "401k"
    
    # Test invalid country
    invalid_subtypes = Investment.subtypes_for_country("INVALID")
    assert_empty invalid_subtypes
  end

  test "countries_with_counts returns countries with account counts" do
    # Create test accounts with different subtypes
    family = families(:dylan_family)
    
    us_account = family.accounts.create!(
      name: "US Brokerage",
      accountable: Investment.new(subtype: "brokerage"),
      balance: 1000,
      currency: "USD"
    )
    
    ca_account = family.accounts.create!(
      name: "RRSP Account", 
      accountable: Investment.new(subtype: "rrsp"),
      balance: 2000,
      currency: "CAD"
    )
    
    accounts = [us_account, ca_account]
    countries = Investment.countries_with_counts(accounts)
    
    assert_equal 1, countries["US"]
    assert_equal 1, countries["CA"]
    assert_nil countries["UK"]
  end

  # Test validations
  test "validates subtype inclusion in SUBTYPES" do
    investment = Investment.new(subtype: "invalid_subtype")
    assert_not investment.valid?
    assert_includes investment.errors[:subtype], "is not included in the list"
    
    investment = Investment.new(subtype: "brokerage")
    investment.valid? # This will trigger validation
    assert_not_includes investment.errors[:subtype], "is not included in the list"
  end

  test "inherits accountable behavior" do
    assert_includes Investment.included_modules, Accountable
    assert_respond_to Investment, :classification
    assert_respond_to Investment, :icon
    assert_respond_to Investment, :color
  end
end