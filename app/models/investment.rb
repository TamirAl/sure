
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

  validates :subtype, inclusion: { 
    in: SUBTYPES.keys,
    message: "is not a valid investment account subtype",
    allow_nil: true
  }

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
  end
end
