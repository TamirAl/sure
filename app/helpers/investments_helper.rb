module InvestmentsHelper
  def investment_subtype_options_grouped
    Investment.grouped_by_country.map do |country, subtypes|
      country_label = country_with_flag(country)
      options = subtypes.map { |key, value| [value[:long], key] }
      [country_label, options]
    end
  end

  def investment_subtype_options_flat
    Investment::SUBTYPES.map { |key, value| [value[:long], key] }
  end

  def country_with_flag(country)
    flags = {
      "US" => "🇺🇸 United States",
      "CA" => "🇨🇦 Canada", 
      "UK" => "🇬🇧 United Kingdom",
      "International" => "🌍 International"
    }
    flags[country] || country
  end

  def investment_country_filter_options(accounts = [])
    countries = Investment.countries_with_counts(accounts)
    options = [["All Countries", ""]]
    
    countries.each do |item|
      label = "#{country_with_flag(item[:country])} (#{item[:count]})"
      options << [label, item[:country]]
    end
    
    options
  end
end
