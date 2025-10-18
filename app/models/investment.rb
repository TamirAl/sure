
class Investment < ApplicationRecord
  include Accountable

  SUBTYPES = {
    # Brokerage & General
    "brokerage" => { short: "Brokerage", long: "Brokerage Account" },
    "non_taxable_brokerage" => { short: "Non-Taxable", long: "Non-Taxable Brokerage Account" },
    "mutual_fund" => { short: "Mutual Fund", long: "Mutual Fund" },
    "crypto" => { short: "Crypto", long: "Cryptocurrency" },
    "angel" => { short: "Angel", long: "Angel Investment" },
    "other" => { short: "Other", long: "Other Investment Account" },

    # US Retirement Accounts
    "401k" => { short: "401(k)", long: "401(k)" },
    "403b" => { short: "403(b)", long: "403(b)" },
    "457b" => { short: "457(b)", long: "457(b)" },
    "roth_401k" => { short: "Roth 401(k)", long: "Roth 401(k)" },
    "ira" => { short: "IRA", long: "Traditional IRA" },
    "roth_ira" => { short: "Roth IRA", long: "Roth IRA" },
    "sep_ira" => { short: "SEP IRA", long: "SEP IRA" },
    "simple_ira" => { short: "SIMPLE IRA", long: "SIMPLE IRA" },
    "sarsep" => { short: "SARSEP", long: "Salary Reduction Simplified Employee Pension" },
    "keogh" => { short: "Keogh", long: "Keogh Plan" },
    "thrift_savings_plan" => { short: "TSP", long: "Thrift Savings Plan (TSP)" },
    "profit_sharing_plan" => { short: "Profit Share", long: "Profit Sharing Plan" },
    
    # Canadian Retirement Accounts
    "rrsp" => { short: "RRSP", long: "RRSP (Registered Retirement Savings Plan)" },
    "rrif" => { short: "RRIF", long: "RRIF (Registered Retirement Income Fund)" },
    "tfsa" => { short: "TFSA", long: "TFSA (Tax-Free Savings Account)" },
    "lira" => { short: "LIRA", long: "LIRA (Locked-in Retirement Account)" },
    "lrif" => { short: "LRIF", long: "LRIF (Locked-in Retirement Income Fund)" },
    "lrsp" => { short: "LRSP", long: "LRSP (Locked-in Retirement Savings Plan)" },
    "prif" => { short: "PRIF", long: "Prescribed Retirement Income Fund" },
    
    # International Accounts
    "isa" => { short: "ISA", long: "Individual Savings Account (ISA)" },
    "sipp" => { short: "SIPP", long: "Self-Invested Personal Pension" },
    
    # Specialized Accounts
    "529" => { short: "529", long: "529 Education Savings Plan" },
    "529_plan" => { short: "529 Plan", long: "529 Plan" }, # Keep for backward compatibility
    "hsa" => { short: "HSA", long: "Health Savings Account" },
    "health_savings_account" => { short: "HSA", long: "Health Savings Account" }, # Alternative naming
    "ebt" => { short: "EBT", long: "Employee Benefit Trust" },
    "gic" => { short: "GIC", long: "Guaranteed Investment Certificate" },
    
    # Trust & Estate Accounts
    "trust" => { short: "Trust", long: "Trust Account" },
    "ugma" => { short: "UGMA", long: "Uniform Gifts to Minors Act" },
    "utma" => { short: "UTMA", long: "Uniform Transfers to Minors Act" },
    "qtip" => { short: "QTIP", long: "Qualified Terminable Interest Property" },
    "qdro" => { short: "QDRO", long: "Qualified Domestic Relations Order" },
    
    # Business & Employee Plans
    "stock_plan" => { short: "Stock Plan", long: "Employee Stock Plan" },
    "pension" => { short: "Pension", long: "Pension" },
    "retirement" => { short: "Retirement", long: "Retirement" }, # Keep for backward compatibility
    "life_insurance" => { short: "Life Insurance", long: "Life Insurance" },
    "lif" => { short: "LIF", long: "Life Income Fund" },
    
    # Specialized Financial Products
    "qshr" => { short: "QSHR", long: "Qualified Shared Responsibility" }
  }.freeze

  # Country mappings for investment subtypes
  SUBTYPE_COUNTRIES = {
    # US accounts
    "401k" => "US", "403b" => "US", "457b" => "US", "roth_401k" => "US",
    "ira" => "US", "roth_ira" => "US", "sep_ira" => "US", "simple_ira" => "US",
    "sarsep" => "US", "keogh" => "US", "thrift_savings_plan" => "US",
    "profit_sharing_plan" => "US", "529" => "US", "529_plan" => "US",
    "hsa" => "US", "health_savings_account" => "US", "ugma" => "US", "utma" => "US",
    
    # Canadian accounts
    "rrsp" => "CA", "rrif" => "CA", "tfsa" => "CA", "lira" => "CA",
    "lrif" => "CA", "lrsp" => "CA", "prif" => "CA", "gic" => "CA", "lif" => "CA",
    
    # UK accounts
    "isa" => "UK", "sipp" => "UK",
    
    # International/Universal
    "brokerage" => "International", "non_taxable_brokerage" => "International",
    "mutual_fund" => "International", "crypto" => "International",
    "angel" => "International", "other" => "International", "trust" => "International",
    "stock_plan" => "International", "pension" => "International",
    "retirement" => "International", "life_insurance" => "International",
    "ebt" => "International", "qtip" => "International", "qdro" => "International",
    "qshr" => "International"
  }.freeze

  # Tax treatment categories
  TAX_TREATMENTS = {
    # Tax-deferred (US)
    "401k" => "tax_deferred", "403b" => "tax_deferred", "457b" => "tax_deferred",
    "ira" => "tax_deferred", "sep_ira" => "tax_deferred", "simple_ira" => "tax_deferred",
    "sarsep" => "tax_deferred", "keogh" => "tax_deferred", "thrift_savings_plan" => "tax_deferred",
    
    # Tax-free (US)
    "roth_401k" => "tax_free", "roth_ira" => "tax_free", "529" => "tax_free",
    "529_plan" => "tax_free", "hsa" => "tax_free", "health_savings_account" => "tax_free",
    
    # Tax-deferred (Canada)
    "rrsp" => "tax_deferred", "lira" => "tax_deferred", "lrsp" => "tax_deferred",
    
    # Tax-free (Canada)
    "tfsa" => "tax_free", "rrif" => "tax_free", "lrif" => "tax_free", "prif" => "tax_free",
    
    # Taxable
    "brokerage" => "taxable", "non_taxable_brokerage" => "taxable", "mutual_fund" => "taxable",
    "crypto" => "taxable", "angel" => "taxable", "other" => "taxable", "trust" => "taxable",
    "stock_plan" => "taxable", "pension" => "taxable", "retirement" => "taxable",
    "life_insurance" => "taxable", "ebt" => "taxable", "qtip" => "taxable", 
    "qdro" => "taxable", "qshr" => "taxable", "gic" => "taxable", "lif" => "taxable",
    
    # International accounts (default to taxable unless specified)
    "isa" => "tax_free", "sipp" => "tax_deferred", "ugma" => "taxable", "utma" => "taxable"
  }.freeze

  validates :subtype, inclusion: { 
    in: SUBTYPES.keys,
    message: "is not a valid investment account subtype",
    allow_nil: true
  }

  # Instance methods for country and tax treatment information
  def country
    SUBTYPE_COUNTRIES[subtype] || "Unknown"
  end

  def tax_treatment
    TAX_TREATMENTS[subtype] || "taxable"
  end

  def country_flag
    case country
    when "US" then "🇺🇸"
    when "CA" then "🇨🇦"
    when "UK" then "🇬🇧"
    else "🌍"
    end
  end

  def tax_treatment_badge
    case tax_treatment
    when "tax_deferred" then { text: "Tax-Deferred", class: "bg-yellow-100 text-yellow-800" }
    when "tax_free" then { text: "Tax-Free", class: "bg-green-100 text-green-800" }
    when "taxable" then { text: "Taxable", class: "bg-gray-100 text-gray-800" }
    else { text: "Unknown", class: "bg-gray-100 text-gray-600" }
    end
  end

  class << self
    def color
      "#1570EF"
    end

    def classification
      "asset"
    end

    def icon
      "line-chart"
    end

    # Class methods for UI helpers
    def grouped_by_country
      SUBTYPES.group_by { |key, _| SUBTYPE_COUNTRIES[key] || "International" }
               .transform_values { |subtypes| subtypes.to_h }
    end

    def subtypes_for_country(country_code)
      SUBTYPES.select { |key, _| SUBTYPE_COUNTRIES[key] == country_code }
    end

    def countries_with_counts(user_accounts = [])
      user_subtypes = user_accounts.map(&:subtype)
      SUBTYPE_COUNTRIES.values.uniq.map do |country|
        count = user_subtypes.count { |subtype| SUBTYPE_COUNTRIES[subtype] == country }
        { country: country, count: count }
      end.sort_by { |item| -item[:count] }
    end
  end
end
