require "test_helper"

class InvestmentAccountIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @family = families(:dylan_family)
    @user = @family.users.first
    sign_in(@user)
  end

  test "user can view investment accounts with country filtering" do
    # Create investment accounts from different countries
    us_account = @family.accounts.create!(
      name: "Robinhood Brokerage",
      accountable: Investment.new(subtype: "brokerage"),
      balance: 15000,
      currency: "USD"
    )
    
    ca_account = @family.accounts.create!(
      name: "TD RRSP",
      accountable: Investment.new(subtype: "rrsp"),
      balance: 25000,
      currency: "CAD"
    )

    # Visit accounts page
    get accounts_path
    assert_response :success
    
    # Should see both accounts in the listing
    assert_select "div", text: /Robinhood Brokerage/
    assert_select "div", text: /TD RRSP/
    
    # Should see country filter tabs
    assert_select "a", text: /All Countries/
    assert_select "a", text: /United States/
    assert_select "a", text: /Canada/
  end

  test "user can filter investment accounts by country" do
    # Create accounts from different countries
    us_account = @family.accounts.create!(
      name: "US Brokerage",
      accountable: Investment.new(subtype: "brokerage"),
      balance: 10000,
      currency: "USD"
    )
    
    ca_account = @family.accounts.create!(
      name: "Canadian RRSP",
      accountable: Investment.new(subtype: "rrsp"),
      balance: 20000,
      currency: "CAD"
    )

    # Filter by US accounts
    get accounts_path(country_filter: "US")
    assert_response :success
    
    # Should see US account but not Canadian account  
    assert_select "div", text: /US Brokerage/
    assert_select "div", text: /Canadian RRSP/, count: 0
    
    # Filter by Canadian accounts
    get accounts_path(country_filter: "CA")
    assert_response :success
    
    # Should see Canadian account but not US account
    assert_select "div", text: /Canadian RRSP/
    assert_select "div", text: /US Brokerage/, count: 0
  end

  test "user can create new investment account with enhanced form" do
    get new_investment_path
    assert_response :success
    
    # Should see enhanced investment form with country filtering
    assert_select "select#country_filter"
    assert_select "select", id: /subtype/
    
    # Should see grouped options in the subtype dropdown
    assert_select "optgroup[label='US']"
    assert_select "optgroup[label='CA']" 
    assert_select "optgroup[label='UK']"
    
    # Create a Canadian TFSA
    post investments_path, params: {
      account: {
        name: "My TFSA",
        balance: 5000,
        currency: "CAD",
        accountable_attributes: {
          subtype: "tfsa"
        }
      }
    }
    
    # Should redirect to account show page
    created_account = @family.accounts.joins(:accountable).where(
      accountable: { subtype: "tfsa" }
    ).first
    
    assert_not_nil created_account
    assert_redirected_to account_path(created_account)
    
    # Follow redirect and verify account details
    follow_redirect!
    assert_response :success
    assert_select "h1", text: /My TFSA/
  end

  test "investment account displays country and tax information in balance sheet" do
    # Create accounts from different countries with different tax treatments
    us_roth = @family.accounts.create!(
      name: "Roth IRA",
      accountable: Investment.new(subtype: "roth_ira"),
      balance: 30000,
      currency: "USD"
    )
    
    ca_rrsp = @family.accounts.create!(
      name: "RRSP Account", 
      accountable: Investment.new(subtype: "rrsp"),
      balance: 45000,
      currency: "CAD"
    )

    # Visit dashboard to see balance sheet
    get root_path
    assert_response :success
    
    # Should see investment accounts in balance sheet
    assert_select "div", text: /Roth IRA/
    assert_select "div", text: /RRSP Account/
    
    # Should show country indicators for non-US accounts
    assert_select "span", text: "🇨🇦"
    
    # Should show investment account balances
    assert_select "div", text: /\$30,000/
    assert_select "div", text: /\$45,000/
  end

  test "investment account sidebar shows enhanced investment cards" do
    investment_account = @family.accounts.create!(
      name: "Fidelity 401k",
      accountable: Investment.new(subtype: "401k"),
      balance: 75000,
      currency: "USD"
    )

    get accounts_path
    assert_response :success
    
    # Should see investment account in sidebar with enhanced display
    assert_select "div[data-controller*='investment']", text: /Fidelity 401k/
    
    # Should show tax treatment information
    assert_select "span", text: /Tax Deferred/
    
    # Should show formatted balance
    assert_select "p", text: /\$75,000/
  end

  test "API endpoints work with proper authentication" do
    # Create API key for the user
    api_key = @user.api_keys.create!(
      name: "Integration Test Key",
      scopes: ["read"],
      raw_key: "integration_test_key_123"
    )

    # Test subtype data endpoint
    get api_v1_investments_subtype_data_path,
        headers: { "Authorization" => "Bearer #{api_key.raw_key}" }
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.key?("subtypes")
    assert json_response["subtypes"].length > 0
    
    # Test countries endpoint
    get api_v1_investments_countries_path,
        headers: { "Authorization" => "Bearer #{api_key.raw_key}" }
    
    assert_response :success
    
    # Test filtered subtypes endpoint
    get api_v1_investments_subtypes_by_country_path(country: "US"),
        headers: { "Authorization" => "Bearer #{api_key.raw_key}" }
    
    assert_response :success
  end

  test "user sees proper error handling for invalid account creation" do
    get new_investment_path
    assert_response :success
    
    # Try to create account with invalid data
    post investments_path, params: {
      account: {
        name: "", # Invalid: empty name
        balance: "invalid_amount", # Invalid: non-numeric balance
        accountable_attributes: {
          subtype: "invalid_subtype" # Invalid: not in allowed list
        }
      }
    }
    
    # Should re-render form with errors
    assert_response :unprocessable_entity
    assert_select "div.error", count: 1 # Should show validation errors
  end

  test "investment account filtering persists across page navigation" do
    # Create accounts from different countries
    us_account = @family.accounts.create!(
      name: "US 401k",
      accountable: Investment.new(subtype: "401k"),
      balance: 50000,
      currency: "USD"
    )

    # Visit with country filter
    get accounts_path(country_filter: "US")
    assert_response :success
    
    # Filter parameter should be preserved in links
    assert_select "a[href*='country_filter=US']"
  end

  test "complete user journey from account creation to management" do
    # Step 1: Visit new investment form
    get new_investment_path
    assert_response :success

    # Step 2: Create Canadian RRSP account
    post investments_path, params: {
      account: {
        name: "My Retirement Savings",
        balance: 12500,
        currency: "CAD",
        accountable_attributes: {
          subtype: "rrsp"
        }
      }
    }

    created_account = @family.accounts.joins(:accountable).where(
      accountable: { subtype: "rrsp" }
    ).first
    
    assert_redirected_to account_path(created_account)

    # Step 3: View account details
    follow_redirect!
    assert_response :success
    assert_select "h1", text: /My Retirement Savings/

    # Step 4: Go back to accounts index and verify filtering
    get accounts_path(country_filter: "CA")
    assert_response :success
    assert_select "div", text: /My Retirement Savings/

    # Step 5: View in dashboard balance sheet
    get root_path
    assert_response :success
    assert_select "div", text: /My Retirement Savings/
    assert_select "span", text: "🇨🇦" # Should show Canadian flag
  end

  private

  def sign_in(user)
    post sessions_path, params: {
      email: user.email,
      password: "password" # Assuming test fixture password
    }
  end
end