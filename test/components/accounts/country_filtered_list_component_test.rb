require "test_helper"

class Accounts::CountryFilteredListComponentTest < ViewComponent::TestCase
  def setup
    @family = families(:dylan_family)
    
    # Create accounts with different countries
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
    
    @uk_account = @family.accounts.create!(
      name: "ISA Account",
      accountable: Investment.new(subtype: "isa"),
      balance: 8000,
      currency: "GBP"
    )
    
    @all_accounts = [@us_account, @ca_account, @uk_account]
  end

  test "renders all accounts when no filter specified" do
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: @all_accounts,
      current_filter: nil
    ))

    assert_selector "div", text: "US Brokerage"
    assert_selector "div", text: "RRSP Account" 
    assert_selector "div", text: "ISA Account"
  end

  test "renders only US accounts when US filter applied" do
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: @all_accounts,
      current_filter: "US"
    ))

    assert_selector "div", text: "US Brokerage"
    assert_no_text "RRSP Account"
    assert_no_text "ISA Account"
  end

  test "renders only Canadian accounts when CA filter applied" do
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: @all_accounts,
      current_filter: "CA"
    ))

    assert_selector "div", text: "RRSP Account"
    assert_no_text "US Brokerage"
    assert_no_text "ISA Account"
  end

  test "shows country filter tabs with correct counts" do
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: @all_accounts,
      current_filter: nil
    ))

    # Should show tabs for each country with counts
    assert_text "US (1)"
    assert_text "CA (1)" 
    assert_text "UK (1)"
    assert_text "All Countries (3)"
  end

  test "highlights active filter tab" do
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: @all_accounts,
      current_filter: "US"
    ))

    # Active tab should have different styling
    assert_selector ".bg-primary", text: "US (1)"
    assert_selector ".bg-surface-hover", text: "CA (1)"
  end

  test "shows empty state when no accounts match filter" do
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: @all_accounts,
      current_filter: "International"
    ))

    assert_text "No investment accounts found"
    assert_text "Try selecting a different country filter"
  end

  test "shows total balance for filtered accounts" do
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: [@us_account], # Only US account
      current_filter: "US"
    ))

    assert_text "$10,000.00" # Should show balance
  end

  test "handles empty account list gracefully" do
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: [],
      current_filter: nil
    ))

    assert_text "No investment accounts found"
  end

  test "groups accounts by country correctly" do
    # Test the private method indirectly through rendering
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: @all_accounts,
      current_filter: nil
    ))

    # Should render accounts in country groups
    assert_selector "div[data-country='US']"
    assert_selector "div[data-country='CA']"  
    assert_selector "div[data-country='UK']"
  end

  test "integrates with Stimulus controller" do
    render_inline(Accounts::CountryFilteredListComponent.new(
      accounts: @all_accounts,
      current_filter: nil
    ))

    # Should have controller data attributes
    assert_selector "[data-controller='country-filter']"
    assert_selector "[data-country-filter-target='tabs']"
  end
end