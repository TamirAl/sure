class Accounts::InvestmentCardComponent < ApplicationComponent
  def initialize(account:, show_country: true, show_tax_treatment: true, compact: false, link_to_account: false, account_group_color: nil)
    @account = account
    @show_country = show_country
    @show_tax_treatment = show_tax_treatment
    @compact = compact
    @link_to_account = link_to_account
    @account_group_color = account_group_color
  end

  private

  attr_reader :account, :show_country, :show_tax_treatment, :compact, :link_to_account, :account_group_color

  def country_indicator
    return unless show_country && account.respond_to?(:country)
    "#{account.country_flag} #{account.country}"
  end

  def tax_treatment_badge
    return unless show_tax_treatment && account.respond_to?(:tax_treatment_badge)
    account.tax_treatment_badge
  end

  def subtype_display_name
    return "Investment Account" unless account.subtype.present?
    Investment::SUBTYPES.dig(account.subtype, :long) || account.subtype.humanize
  end

  def account_path_helper
    # Use Rails route helper for account path
    helpers.account_path(account)
  end

  def account_edit_path_helper
    # Use Rails route helper for edit account path
    helpers.edit_account_path(account)
  end

  def sparkline_account_path(account)
    helpers.sparkline_account_path(account)
  end
end