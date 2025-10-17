module PlaidAccount::TypeMappable
  extend ActiveSupport::Concern

  UnknownAccountTypeError = Class.new(StandardError)

  def map_accountable(plaid_type)
    accountable_class = TYPE_MAPPING.dig(
      plaid_type.to_sym,
      :accountable
    )

    unless accountable_class
      raise UnknownAccountTypeError, "Unknown account type: #{plaid_type}"
    end

    accountable_class.new
  end

  def map_subtype(plaid_type, plaid_subtype)
    TYPE_MAPPING.dig(
      plaid_type.to_sym,
      :subtype_mapping,
      plaid_subtype
    ) || "other"
  end

  # Plaid Account Types -> Accountable Types
  # https://plaid.com/docs/api/accounts/#account-type-schema
  TYPE_MAPPING = {
    depository: {
      accountable: Depository,
      subtype_mapping: {
        "checking" => "checking",
        "savings" => "savings",
        "hsa" => "hsa",
        "cd" => "cd",
        "money market" => "money_market"
      }
    },
    credit: {
      accountable: CreditCard,
      subtype_mapping: {
        "credit card" => "credit_card"
      }
    },
    loan: {
      accountable: Loan,
      subtype_mapping: {
        "mortgage" => "mortgage",
        "student" => "student",
        "auto" => "auto",
        "business" => "business",
        "home equity" => "home_equity",
        "line of credit" => "line_of_credit"
      }
    },
    investment: {
      accountable: Investment,
      subtype_mapping: {
        # Existing mappings (keep for backward compatibility)
        "brokerage" => "brokerage",
        "pension" => "pension",
        "retirement" => "retirement",
        "401k" => "401k",
        "roth 401k" => "roth_401k",
        "529" => "529_plan",
        "hsa" => "hsa",
        "mutual fund" => "mutual_fund",
        "roth" => "roth_ira",
        "ira" => "ira",
        
        # Additional US retirement mappings
        "403b" => "403b",
        "457b" => "457b",
        "sep ira" => "sep_ira",
        "simple ira" => "simple_ira",
        "keogh" => "keogh",
        "thrift savings plan" => "thrift_savings_plan",
        "profit sharing plan" => "profit_sharing_plan",
        
        # Canadian retirement mappings
        "rrsp" => "rrsp",
        "rrif" => "rrif", 
        "tfsa" => "tfsa",
        "lira" => "lira",
        "lrif" => "lrif",
        "lrsp" => "lrsp",
        "prif" => "prif",
        
        # International mappings
        "isa" => "isa",
        "sipp" => "sipp",
        
        # Specialized accounts
        "ebt" => "ebt",
        "gic" => "gic",
        
        # Trust & estate mappings
        "trust" => "trust",
        "ugma" => "ugma",
        "utma" => "utma",
        "qtip" => "qtip",
        "qdro" => "qdro",
        
        # Other investment types
        "crypto" => "crypto",
        "cryptocurrency" => "crypto",
        "stock plan" => "stock_plan",
        "life insurance" => "life_insurance",
        "lif" => "lif",
        "angel" => "angel"
      }
    },
    other: {
      accountable: OtherAsset,
      subtype_mapping: {}
    }
  }
end
