require "test_helper"

class Accounts::InvestmentCardComponentTest < ViewComponent::TestCase
  def setup
    @family = families(:dylan_family)
    @investment_account = accounts(:investment)
    @investment_account.accountable.update!(subtype: "brokerage")
  end

  test "renders investment card with default options" do
    render_inline(Accounts::InvestmentCardComponent.new(
      account: @investment_account,
      show_country: true,
      show_tax_treatment: true
    ))

    assert_selector "div", text: @investment_account.name
    assert_selector "span", text: "🇺🇸" # US flag for brokerage
  end

  test "renders compact mode for sidebar" do
    render_inline(Accounts::InvestmentCardComponent.new(
      account: @investment_account,
      compact: true,
      link_to_account: true,
      account_group_color: "#3B82F6"
    ))

    assert_selector "a[href='#{account_path(@investment_account)}']"
    assert_selector "p", text: @investment_account.name
  end

  test "shows country flag when show_country is true" do
    canadian_account = @family.accounts.create!(
      name: "RRSP Account",
      accountable: Investment.new(subtype: "rrsp"),
      balance: 5000,
      currency: "CAD"
    )

    render_inline(Accounts::InvestmentCardComponent.new(
      account: canadian_account,
      show_country: true,
      show_tax_treatment: false
    ))

    assert_selector "span", text: "🇨🇦" # Canadian flag for RRSP
  end

  test "hides country flag when show_country is false" do
    render_inline(Accounts::InvestmentCardComponent.new(
      account: @investment_account,
      show_country: false,
      show_tax_treatment: true
    ))

    assert_no_selector "span", text: "🇺🇸"
  end

  test "shows tax treatment badge when show_tax_treatment is true" do
    roth_account = @family.accounts.create!(
      name: "Roth IRA",
      accountable: Investment.new(subtype: "roth_ira"),
      balance: 3000,
      currency: "USD"
    )

    render_inline(Accounts::InvestmentCardComponent.new(
      account: roth_account,
      show_country: true,
      show_tax_treatment: true
    ))

    assert_selector "span", text: "Tax Free"
    assert_selector "span.bg-green-100"
  end

  test "hides tax treatment badge when show_tax_treatment is false" do
    render_inline(Accounts::InvestmentCardComponent.new(
      account: @investment_account,
      show_country: true,
      show_tax_treatment: false
    ))

    assert_no_selector "span", text: "Taxable"
  end

  test "renders balance with proper formatting" do
    render_inline(Accounts::InvestmentCardComponent.new(
      account: @investment_account,
      show_country: true,
      show_tax_treatment: true
    ))

    # Should show formatted balance
    assert_text "$10,000.00"
  end

  test "handles missing accountable gracefully" do
    # Create account without proper accountable setup
    account_without_accountable = Account.new(
      name: "Test Account",
      balance: 1000,
      currency: "USD"
    )
    account_without_accountable.stubs(:accountable).returns(nil)

    # Should not raise error
    assert_nothing_raised do
      render_inline(Accounts::InvestmentCardComponent.new(
        account: account_without_accountable,
        show_country: true,
        show_tax_treatment: true
      ))
    end
  end

  private

  def account_path(account)
    "/accounts/#{account.id}"
  end
end