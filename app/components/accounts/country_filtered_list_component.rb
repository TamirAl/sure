class Accounts::CountryFilteredListComponent < ApplicationComponent
  def initialize(accounts:, current_filter: nil)
    @accounts = accounts
    @current_filter = current_filter
  end

  private

  attr_reader :accounts, :current_filter

  def filtered_accounts
    return accounts unless current_filter.present?
    accounts.select { |account| account.respond_to?(:country) && account.country == current_filter }
  end

  def country_tabs
    countries = accounts.group_by { |account| account.respond_to?(:country) ? account.country : "Unknown" }
    tabs = [{ name: "All", code: "", count: accounts.count, active: current_filter.blank? }]
    
    countries.each do |country, country_accounts|
      tabs << {
        name: country_with_flag(country),
        code: country,
        count: country_accounts.count,
        active: current_filter == country
      }
    end
    
    # Sort tabs: All first, then by country code
    tabs.sort_by { |tab| tab[:code] == "" ? "AAA" : tab[:code] }
  end

  def country_with_flag(country)
    flags = {
      "US" => "🇺🇸 US",
      "CA" => "🇨🇦 Canada",
      "UK" => "🇬🇧 UK",
      "International" => "🌍 Intl"
    }
    flags[country] || country
  end

  def filter_path(country_code)
    # Build URL with country filter parameter
    current_params = request.query_parameters.except("country_filter")
    if country_code.present?
      current_params["country_filter"] = country_code
    end
    
    query_string = current_params.any? ? "?#{current_params.to_query}" : ""
    "#{request.path}#{query_string}"
  end

  def has_accounts?
    accounts.any?
  end

  def empty_state_message
    if current_filter.present?
      "No investment accounts found for #{country_with_flag(current_filter)}."
    else
      "Get started by adding your first investment account."
    end
  end

  def add_account_path
    # Generate path for adding new investment account
    new_account_path(account_type: "Investment")
  rescue
    # Fallback if route doesn't exist
    accounts_path
  end
end