# Project Tasks: Multi-Country Investment Account UI Enhancement

## Overview
This project enhances the investment account management system to better support users with accounts across multiple countries (US, Canada, UK, International). The current system has a limited list of 11 investment account types, which doesn't adequately serve Canadian users or those with diverse investment portfolios.

## Prerequisites
- Ruby on Rails 7.2+ application
- Hotwire (Turbo + Stimulus) for frontend interactivity
- Tailwind CSS for styling
- Minitest for testing
- Basic understanding of Rails MVC pattern and ViewComponents

## Project Structure Overview
```
app/
├── models/
│   └── investment.rb (main model to enhance)
├── components/
│   ├── forms/
│   └── accounts/
├── controllers/
│   └── api/v1/investments_controller.rb (new)
├── helpers/
│   └── investments_helper.rb (enhance)
├── views/
│   └── investments/
└── javascript/
    └── controllers/
```

---

## Phase 1: Backend Model Enhancements

### Task 1.1: Add Country Detection and Tax Treatment Constants
**Estimated Time:** 2-3 hours  
**Difficulty:** Medium  
**Files to modify:** `app/models/investment.rb`

**Objective:** Add comprehensive country mapping and tax treatment categorization to the Investment model.

**Steps:**

1. **Open the Investment model file:**
   ```bash
   code app/models/investment.rb
   ```

2. **Add country mapping constants after the existing SUBTYPES constant:**
   ```ruby
   # Add this after the SUBTYPES constant and before the validates line
   
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
   ```

3. **Add tax treatment mapping:**
   ```ruby
   # Add this after SUBTYPE_COUNTRIES
   
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
     "crypto" => "taxable", "angel" => "taxable", "other" => "taxable", "trust" => "taxable"
   }.freeze
   ```

**Testing:**
```bash
# Test in Rails console
bin/rails console
Investment::SUBTYPE_COUNTRIES["rrsp"]  # Should return "CA"
Investment::TAX_TREATMENTS["roth_ira"]  # Should return "tax_free"
```

### Task 1.2: Add Instance Methods for Country and Tax Treatment
**Estimated Time:** 1-2 hours  
**Difficulty:** Easy  
**Files to modify:** `app/models/investment.rb`

**Objective:** Add helper methods to Investment instances for easy access to country and tax treatment information.

**Steps:**

1. **Add instance methods before the existing `class << self` block:**
   ```ruby
   # Add these methods before the "class << self" line
   
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
   ```

**Testing:**
```bash
# Test in Rails console
bin/rails console
investment = Investment.new(subtype: "rrsp")
investment.country          # Should return "CA"
investment.country_flag     # Should return "🇨🇦"
investment.tax_treatment    # Should return "tax_deferred"
```

### Task 1.3: Add Class Methods for UI Helpers
**Estimated Time:** 2 hours  
**Difficulty:** Medium  
**Files to modify:** `app/models/investment.rb`

**Objective:** Add class-level methods to support grouped displays and filtering in the UI.

**Steps:**

1. **Add class methods inside the existing `class << self` block (after the existing methods):**
   ```ruby
   # Add these methods inside the "class << self" block, after the existing icon method
   
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
   ```

**Testing:**
```bash
# Test in Rails console
bin/rails console
Investment.grouped_by_country.keys  # Should include "US", "CA", "UK", "International"
Investment.subtypes_for_country("CA").keys  # Should include "rrsp", "tfsa", etc.
```

---

## Phase 2: Create Helper Methods for Forms

### Task 2.1: Create Investment Helper Methods
**Estimated Time:** 1-2 hours  
**Difficulty:** Easy  
**Files to modify:** `app/helpers/investments_helper.rb` (create if doesn't exist)

**Objective:** Create helper methods to support the enhanced investment forms with grouped options.

**Steps:**

1. **Check if the helper file exists:**
   ```bash
   ls app/helpers/investments_helper.rb
   ```

2. **If the file doesn't exist, create it:**
   ```ruby
   # Create app/helpers/investments_helper.rb
   module InvestmentsHelper
   end
   ```

3. **Add helper methods:**
   ```ruby
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
   ```

**Testing:**
```bash
# Test in Rails console
bin/rails console
helper.investment_subtype_options_grouped.first  # Should return grouped options
```

---

## Phase 3: Create Form Components

### Task 3.1: Create Grouped Select Component
**Estimated Time:** 2-3 hours  
**Difficulty:** Medium  
**Files to create:** 
- `app/components/forms/grouped_select_component.rb`
- `app/components/forms/grouped_select_component.html.erb`

**Objective:** Create a reusable ViewComponent for grouped select dropdowns.

**Steps:**

1. **Create the component directory if it doesn't exist:**
   ```bash
   mkdir -p app/components/forms
   ```

2. **Create the Ruby component file:**
   ```ruby
   # Create app/components/forms/grouped_select_component.rb
   class Forms::GroupedSelectComponent < ApplicationComponent
     def initialize(form:, field:, grouped_options:, **options)
       @form = form
       @field = field
       @grouped_options = grouped_options
       @options = options
     end

     private

     attr_reader :form, :field, :grouped_options, :options
   end
   ```

3. **Create the ERB template:**
   ```erb
   <!-- Create app/components/forms/grouped_select_component.html.erb -->
   <div class="space-y-2">
     <%= form.label field, class: "block text-sm font-medium text-primary" %>
     <%= form.grouped_select field, grouped_options, 
                             { prompt: options[:prompt], include_blank: options[:include_blank] },
                             { 
                               class: "block w-full rounded-md border border-secondary bg-white px-3 py-2 text-sm placeholder:text-gray-400 focus:border-blue-500 focus:ring-blue-500",
                               data: { 
                                 controller: "investment-subtype-filter",
                                 investment_subtype_filter_country_value: options[:filter_by_country],
                                 action: "change->investment-form#subtypeChanged"
                               }
                             } %>
   </div>
   ```

**Testing:**
```bash
# Create a simple test to verify the component loads
bin/rails console
Forms::GroupedSelectComponent.new(form: nil, field: :test, grouped_options: [])
```

### Task 3.2: Update Investment Form View
**Estimated Time:** 3-4 hours  
**Difficulty:** Medium  
**Files to modify:** `app/views/investments/_form.html.erb`

**Objective:** Enhance the investment form with country filtering and enhanced subtype selection.

**Steps:**

1. **First, backup the current form:**
   ```bash
   cp app/views/investments/_form.html.erb app/views/investments/_form.html.erb.backup
   ```

2. **Locate the current subtype selection in the form (should look like this):**
   ```erb
   <%= form.select :subtype,
                  Investment::SUBTYPES.map { |k, v| [v[:long], k] },
                  { label: true, prompt: t("investments.form.subtype_prompt"), include_blank: t("investments.form.none") } %>
   ```

3. **Replace it with the enhanced version:**
   ```erb
   <!-- Enhanced Country-Aware Subtype Selection -->
   <div data-controller="investment-form" data-investment-form-current-country-value="<%= params[:country_filter] %>">
     
     <!-- Country Filter (Optional) -->
     <div class="mb-4">
       <%= label_tag :country_filter, "Filter by Country", class: "block text-sm font-medium text-primary" %>
       <%= select_tag :country_filter, 
                      options_for_select(investment_country_filter_options(Current.family.accounts.investment), params[:country_filter]),
                      { 
                        class: "block w-full rounded-md border border-secondary bg-white px-3 py-2 text-sm",
                        data: { 
                          action: "change->investment-form#filterByCountry",
                          investment_form_target: "countryFilter"
                        },
                        prompt: "All Countries"
                      } %>
     </div>

     <!-- Subtype Selection with Search -->
     <div class="relative">
       <%= render Forms::GroupedSelectComponent.new(
             form: form,
             field: :subtype,
             grouped_options: investment_subtype_options_grouped,
             prompt: t("investments.form.subtype_prompt"),
             include_blank: t("investments.form.none"),
             filter_by_country: params[:country_filter]
           ) %>
       
       <!-- Search Input Overlay -->
       <div class="absolute top-8 right-0 pr-3 pointer-events-none">
         <%= icon "search", class: "h-4 w-4 text-gray-400" %>
       </div>
     </div>

     <!-- Selected Account Info Panel -->
     <div data-investment-form-target="infoPanel" class="hidden mt-4 p-4 bg-gray-50 rounded-lg border border-secondary">
       <div class="flex items-center space-x-3">
         <span data-investment-form-target="countryFlag" class="text-lg"></span>
         <div>
           <p class="font-medium text-primary" data-investment-form-target="subtypeName"></p>
           <div class="flex items-center space-x-2 mt-1">
             <span data-investment-form-target="taxBadge" class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"></span>
             <span data-investment-form-target="countryName" class="text-sm text-gray-600"></span>
           </div>
         </div>
       </div>
     </div>
   </div>
   ```

**Testing:**
```bash
# Start the development server and test the form
bin/dev
# Navigate to /investments/new in your browser
```

---

## Phase 4: Create Stimulus Controllers

### Task 4.1: Create Investment Form Stimulus Controller
**Estimated Time:** 3-4 hours  
**Difficulty:** Medium-Hard  
**Files to create:** `app/javascript/controllers/investment_form_controller.js`

**Objective:** Add interactive functionality to the investment form for country filtering and real-time feedback.

**Steps:**

1. **Create the Stimulus controller:**
   ```javascript
   // Create app/javascript/controllers/investment_form_controller.js
   import { Controller } from "@hotwired/stimulus"

   export default class extends Controller {
     static targets = ["countryFilter", "subtypeSelect", "infoPanel", "countryFlag", "subtypeName", "taxBadge", "countryName"]
     static values = { 
       currentCountry: String,
       subtypeData: Object 
     }

     connect() {
       this.loadSubtypeData()
       this.updateSubtypeOptions()
     }

     async loadSubtypeData() {
       try {
         const response = await fetch('/api/v1/investments/subtype_data.json')
         this.subtypeDataValue = await response.json()
       } catch (error) {
         console.error('Failed to load subtype data:', error)
         // Fallback to basic functionality without enhanced data
       }
     }

     filterByCountry() {
       const selectedCountry = this.countryFilterTarget.value
       this.currentCountryValue = selectedCountry
       this.updateSubtypeOptions()
     }

     updateSubtypeOptions() {
       const select = this.element.querySelector('select[name*="subtype"]')
       if (!select) return

       const currentCountry = this.currentCountryValue

       // Show/hide optgroups based on country filter
       Array.from(select.querySelectorAll('optgroup')).forEach(optgroup => {
         if (!currentCountry || optgroup.label.includes(currentCountry) || optgroup.label.includes('International')) {
           optgroup.style.display = ''
         } else {
           optgroup.style.display = 'none'
         }
       })
     }

     subtypeChanged() {
       const select = this.element.querySelector('select[name*="subtype"]')
       const selectedSubtype = select ? select.value : null
       
       if (selectedSubtype && this.subtypeDataValue) {
         this.showAccountInfo(selectedSubtype)
       } else {
         this.hideAccountInfo()
       }
     }

     showAccountInfo(subtype) {
       const data = this.subtypeDataValue[subtype]
       if (!data || !this.hasInfoPanelTarget) return

       this.infoPanelTarget.classList.remove('hidden')
       this.countryFlagTarget.textContent = data.flag
       this.subtypeNameTarget.textContent = data.long_name
       this.countryNameTarget.textContent = data.country
       
       // Update tax treatment badge
       const badge = this.taxBadgeTarget
       badge.textContent = data.tax_treatment.text
       badge.className = `inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${data.tax_treatment.class}`
     }

     hideAccountInfo() {
       if (this.hasInfoPanelTarget) {
         this.infoPanelTarget.classList.add('hidden')
       }
     }
   }
   ```

2. **Make sure the controller is registered (check `app/javascript/controllers/index.js`):**
   ```javascript
   // This should be automatically generated, but verify it exists:
   import InvestmentFormController from "./investment_form_controller"
   application.register("investment-form", InvestmentFormController)
   ```

**Testing:**
```bash
# Test the JavaScript in browser developer tools
# Navigate to the investment form and check console for errors
```

### Task 4.2: Create Subtype Filter Stimulus Controller
**Estimated Time:** 1-2 hours  
**Difficulty:** Easy-Medium  
**Files to create:** `app/javascript/controllers/investment_subtype_filter_controller.js`

**Objective:** Create a lightweight controller for filtering subtypes within grouped selects.

**Steps:**

1. **Create the controller:**
   ```javascript
   // Create app/javascript/controllers/investment_subtype_filter_controller.js
   import { Controller } from "@hotwired/stimulus"

   export default class extends Controller {
     static values = { country: String }

     connect() {
       this.filterOptions()
     }

     countryValueChanged() {
       this.filterOptions()
     }

     filterOptions() {
       if (!this.countryValue) return

       const select = this.element.tagName === 'SELECT' ? this.element : this.element.querySelector('select')
       if (!select) return

       Array.from(select.querySelectorAll('optgroup')).forEach(optgroup => {
         const shouldShow = optgroup.label.includes(this.countryValue) || 
                           optgroup.label.includes('International')
         optgroup.style.display = shouldShow ? '' : 'none'
       })
     }
   }
   ```

2. **Register the controller if needed:**
   ```javascript
   // Add to app/javascript/controllers/index.js if not auto-generated
   import InvestmentSubtypeFilterController from "./investment_subtype_filter_controller"
   application.register("investment-subtype-filter", InvestmentSubtypeFilterController)
   ```

---

## Phase 5: Create API Endpoints

### Task 5.1: Create API Controller for Subtype Data
**Estimated Time:** 2 hours  
**Difficulty:** Medium  
**Files to create:** `app/controllers/api/v1/investments_controller.rb`

**Objective:** Provide JSON data for dynamic frontend functionality.

**Steps:**

1. **Create the API directory structure:**
   ```bash
   mkdir -p app/controllers/api/v1
   ```

2. **Create the API controller:**
   ```ruby
   # Create app/controllers/api/v1/investments_controller.rb
   class Api::V1::InvestmentsController < Api::V1::ApplicationController
     def subtype_data
       data = Investment::SUBTYPES.transform_values do |subtype_info|
         # Create a temporary investment object to access instance methods
         temp_investment = Investment.new
         temp_investment.subtype = subtype_info.keys.first
         
         {
           short_name: subtype_info[:short],
           long_name: subtype_info[:long],
           country: temp_investment.country,
           flag: temp_investment.country_flag,
           tax_treatment: temp_investment.tax_treatment_badge
         }
       end

       render json: data
     end
   end
   ```

3. **Check if `Api::V1::ApplicationController` exists, create if needed:**
   ```ruby
   # Check if app/controllers/api/v1/application_controller.rb exists
   # If not, create it:
   class Api::V1::ApplicationController < ApplicationController
     protect_from_forgery with: :null_session
     
     private

     def authenticate_user!
       # Add authentication logic as needed for your app
       # For now, we'll allow access for logged-in users
       redirect_to root_path unless user_signed_in?
     end
   end
   ```

### Task 5.2: Add API Routes
**Estimated Time:** 30 minutes  
**Difficulty:** Easy  
**Files to modify:** `config/routes.rb`

**Objective:** Add routing for the new API endpoints.

**Steps:**

1. **Find the existing API routes (if any) or add a new namespace:**
   ```ruby
   # Add this to config/routes.rb, within the existing routes block
   namespace :api do
     namespace :v1 do
       resources :investments, only: [] do
         collection do
           get :subtype_data
         end
       end
     end
   end
   ```

2. **Test the route:**
   ```bash
   bin/rails routes | grep subtype_data
   # Should show: GET /api/v1/investments/subtype_data
   ```

**Testing:**
```bash
# Test the API endpoint
curl http://localhost:3000/api/v1/investments/subtype_data.json
# Or visit the URL in your browser after starting the server
```

---

## Phase 6: Create Account Dashboard Components

### Task 6.1: Create Enhanced Investment Card Component
**Estimated Time:** 3-4 hours  
**Difficulty:** Medium  
**Files to create:** 
- `app/components/accounts/investment_card_component.rb`
- `app/components/accounts/investment_card_component.html.erb`

**Objective:** Create a card component that displays investment accounts with country and tax treatment indicators.

**Steps:**

1. **Create the component directory:**
   ```bash
   mkdir -p app/components/accounts
   ```

2. **Create the Ruby component:**
   ```ruby
   # Create app/components/accounts/investment_card_component.rb
   class Accounts::InvestmentCardComponent < ApplicationComponent
     def initialize(account:, show_country: true, show_tax_treatment: true)
       @account = account
       @show_country = show_country
       @show_tax_treatment = show_tax_treatment
     end

     private

     attr_reader :account, :show_country, :show_tax_treatment

     def country_indicator
       return unless show_country && account.respond_to?(:country)
       "#{account.country_flag} #{account.country}"
     end

     def tax_treatment_badge
       return unless show_tax_treatment && account.respond_to?(:tax_treatment_badge)
       account.tax_treatment_badge
     end

     def subtype_display_name
       return "Investment Account" unless account.subtype
       Investment::SUBTYPES.dig(account.subtype, :long) || account.subtype.humanize
     end
   end
   ```

3. **Create the ERB template:**
   ```erb
   <!-- Create app/components/accounts/investment_card_component.html.erb -->
   <div class="bg-white rounded-lg border border-secondary p-4 hover:shadow-md transition-shadow">
     <!-- Account Header -->
     <div class="flex items-start justify-between mb-3">
       <div class="flex items-center space-x-3">
         <%= icon "line-chart", class: "h-5 w-5 text-blue-600" %>
         <div>
           <h3 class="font-medium text-primary"><%= account.name %></h3>
           <p class="text-sm text-gray-600"><%= subtype_display_name %></p>
         </div>
       </div>
       
       <!-- Country Flag -->
       <% if show_country && country_indicator %>
         <div class="flex items-center text-sm text-gray-500">
           <%= country_indicator %>
         </div>
       <% end %>
     </div>

     <!-- Balance -->
     <div class="mb-3">
       <p class="text-2xl font-bold text-primary"><%= account.balance.format %></p>
       <p class="text-sm text-gray-500">Current Balance</p>
     </div>

     <!-- Badges -->
     <div class="flex flex-wrap gap-2 mb-3">
       <% if show_tax_treatment && tax_treatment_badge %>
         <span class="<%= tax_treatment_badge[:class] %> inline-flex items-center px-2 py-1 rounded-full text-xs font-medium">
           <%= tax_treatment_badge[:text] %>
         </span>
       <% end %>
       
       <span class="bg-blue-100 text-blue-800 inline-flex items-center px-2 py-1 rounded-full text-xs font-medium">
         Investment
       </span>
     </div>

     <!-- Actions -->
     <div class="flex justify-end space-x-2">
       <%= link_to account, class: "text-sm text-blue-600 hover:text-blue-800 font-medium" do %>
         View Details
       <% end %>
     </div>
   </div>
   ```

### Task 6.2: Create Country-Filtered Account List Component
**Estimated Time:** 4-5 hours  
**Difficulty:** Medium-Hard  
**Files to create:**
- `app/components/accounts/country_filtered_list_component.rb`
- `app/components/accounts/country_filtered_list_component.html.erb`

**Objective:** Create a component that displays investment accounts with country-based filtering tabs.

**Steps:**

1. **Create the Ruby component:**
   ```ruby
   # Create app/components/accounts/country_filtered_list_component.rb
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
   end
   ```

2. **Create the ERB template:**
   ```erb
   <!-- Create app/components/accounts/country_filtered_list_component.html.erb -->
   <div data-controller="country-filter">
     <!-- Country Filter Tabs -->
     <div class="border-b border-secondary mb-6">
       <nav class="-mb-px flex space-x-8">
         <% country_tabs.each do |tab| %>
           <%= link_to request.path + "?country_filter=#{tab[:code]}", 
                       class: "#{tab[:active] ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'} whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm",
                       data: { 
                         action: "click->country-filter#filterAccounts",
                         country_filter_country_param: tab[:code]
                       } %>
             <%= tab[:name] %>
             <% if tab[:count] > 0 %>
               <span class="ml-2 bg-gray-100 text-gray-900 rounded-full py-0.5 px-2 text-xs font-medium">
                 <%= tab[:count] %>
               </span>
             <% end %>
           <% end %>
         <% end %>
       </nav>
     </div>

     <!-- Account Grid -->
     <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" data-country-filter-target="accountsGrid">
       <% filtered_accounts.each do |account| %>
         <%= render Accounts::InvestmentCardComponent.new(account: account) %>
       <% end %>
     </div>

     <!-- Empty State -->
     <% if filtered_accounts.empty? %>
       <div class="text-center py-12">
         <%= icon "line-chart", class: "mx-auto h-12 w-12 text-gray-400 mb-4" %>
         <h3 class="text-lg font-medium text-gray-900 mb-2">No investment accounts found</h3>
         <p class="text-gray-500 mb-4">
           <% if current_filter.present? %>
             No investment accounts found for <%= country_with_flag(current_filter) %>.
           <% else %>
             Get started by adding your first investment account.
           <% end %>
         </p>
         <%= link_to "Add Investment Account", new_account_path(account_type: "Investment"), 
                     class: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700" %>
       </div>
     <% end %>
   </div>
   ```

3. **Create the associated Stimulus controller:**
   ```javascript
   // Create app/javascript/controllers/country_filter_controller.js
   import { Controller } from "@hotwired/stimulus"

   export default class extends Controller {
     static targets = ["accountsGrid"]

     filterAccounts(event) {
       // This handles the navigation - the server handles the actual filtering
       // You could add client-side filtering here if needed for better UX
     }
   }
   ```

---

## Phase 7: Update Existing Views

### Task 7.1: Update Investment Account Views
**Estimated Time:** 2-3 hours  
**Difficulty:** Medium  
**Files to modify:** Investment-related view files

**Objective:** Integrate the new components into existing account management views.

**Steps:**

1. **Find and update the accounts index view:**
   ```bash
   # Look for these potential files:
   find app/views -name "*account*" -type f | grep -E "(index|show)"
   ```

2. **Update the investments index view (if it exists):**
   ```erb
   <!-- Look for app/views/investments/index.html.erb or similar -->
   <!-- Replace the existing account list with: -->
   <%= render Accounts::CountryFilteredListComponent.new(
         accounts: @investments,
         current_filter: params[:country_filter]
       ) %>
   ```

3. **Update account show views to use the new card component:**
   ```erb
   <!-- In account detail views, replace existing investment account display with: -->
   <% if @account.is_a?(Investment) %>
     <%= render Accounts::InvestmentCardComponent.new(account: @account) %>
   <% end %>
   ```

### Task 7.2: Update Navigation and Account Management
**Estimated Time:** 1-2 hours  
**Difficulty:** Easy  
**Files to modify:** Navigation and account management views

**Objective:** Ensure users can easily access the enhanced investment account features.

**Steps:**

1. **Add country filter to account listing pages:**
   ```erb
   <!-- In account index views, add this filter section: -->
   <div class="mb-6">
     <%= form_with url: request.path, method: :get, class: "flex items-center space-x-4" do |form| %>
       <%= form.select :country_filter, 
                       investment_country_filter_options(@accounts.investment),
                       { include_blank: "All Countries" },
                       { 
                         class: "rounded-md border border-secondary",
                         onchange: "this.form.submit();"
                       } %>
       <%= form.submit "Filter", class: "btn btn-primary" %>
     <% end %>
   </div>
   ```

---

## Phase 8: Testing

### Task 8.1: Write Model Tests
**Estimated Time:** 3-4 hours  
**Difficulty:** Medium  
**Files to create/modify:** `test/models/investment_test.rb`

**Objective:** Ensure all new model methods work correctly with comprehensive test coverage.

**Steps:**

1. **Create or update the investment model test:**
   ```ruby
   # Update test/models/investment_test.rb
   require "test_helper"

   class InvestmentTest < ActiveSupport::TestCase
     test "returns correct country for US accounts" do
       investment = Investment.new(subtype: "401k")
       assert_equal "US", investment.country
     end

     test "returns correct country for Canadian accounts" do
       investment = Investment.new(subtype: "rrsp")
       assert_equal "CA", investment.country
     end

     test "returns correct country for UK accounts" do
       investment = Investment.new(subtype: "isa")
       assert_equal "UK", investment.country
     end

     test "returns International for universal account types" do
       investment = Investment.new(subtype: "brokerage")
       assert_equal "International", investment.country
     end

     test "returns Unknown for unrecognized subtypes" do
       investment = Investment.new(subtype: "unknown_type")
       assert_equal "Unknown", investment.country
     end

     test "returns correct tax treatment for tax-deferred accounts" do
       investment = Investment.new(subtype: "401k")
       assert_equal "tax_deferred", investment.tax_treatment
     end

     test "returns correct tax treatment for tax-free accounts" do
       investment = Investment.new(subtype: "roth_ira")
       assert_equal "tax_free", investment.tax_treatment
     end

     test "returns correct tax treatment for taxable accounts" do
       investment = Investment.new(subtype: "brokerage")
       assert_equal "taxable", investment.tax_treatment
     end

     test "returns correct country flags" do
       us_investment = Investment.new(subtype: "401k")
       assert_equal "🇺🇸", us_investment.country_flag

       ca_investment = Investment.new(subtype: "rrsp")
       assert_equal "🇨🇦", ca_investment.country_flag

       uk_investment = Investment.new(subtype: "isa")
       assert_equal "🇬🇧", uk_investment.country_flag

       intl_investment = Investment.new(subtype: "brokerage")
       assert_equal "🌍", intl_investment.country_flag
     end

     test "returns tax treatment badge with correct styling" do
       tax_deferred = Investment.new(subtype: "401k")
       badge = tax_deferred.tax_treatment_badge
       assert_equal "Tax-Deferred", badge[:text]
       assert_includes badge[:class], "bg-yellow-100"

       tax_free = Investment.new(subtype: "roth_ira")
       badge = tax_free.tax_treatment_badge
       assert_equal "Tax-Free", badge[:text]
       assert_includes badge[:class], "bg-green-100"

       taxable = Investment.new(subtype: "brokerage")
       badge = taxable.tax_treatment_badge
       assert_equal "Taxable", badge[:text]
       assert_includes badge[:class], "bg-gray-100"
     end

     test "groups subtypes by country correctly" do
       grouped = Investment.grouped_by_country
       
       assert_includes grouped["US"].keys, "401k"
       assert_includes grouped["CA"].keys, "rrsp"
       assert_includes grouped["UK"].keys, "isa"
       assert_includes grouped["International"].keys, "brokerage"
     end

     test "returns subtypes for specific country" do
       us_subtypes = Investment.subtypes_for_country("US")
       assert_includes us_subtypes.keys, "401k"
       assert_includes us_subtypes.keys, "ira"
       refute_includes us_subtypes.keys, "rrsp"

       ca_subtypes = Investment.subtypes_for_country("CA")
       assert_includes ca_subtypes.keys, "rrsp"
       assert_includes ca_subtypes.keys, "tfsa"
       refute_includes ca_subtypes.keys, "401k"
     end

     test "counts countries with user accounts" do
       # This test assumes you have some fixtures or factories set up
       # You may need to create test investments for this to work
       accounts = [
         Investment.new(subtype: "401k"),
         Investment.new(subtype: "rrsp"),
         Investment.new(subtype: "401k")
       ]
       
       counts = Investment.countries_with_counts(accounts)
       
       us_count = counts.find { |c| c[:country] == "US" }
       ca_count = counts.find { |c| c[:country] == "CA" }
       
       assert_equal 2, us_count[:count]
       assert_equal 1, ca_count[:count]
     end

     test "validates subtype inclusion" do
       valid_investment = Investment.new(subtype: "401k")
       assert valid_investment.valid?

       invalid_investment = Investment.new(subtype: "invalid_type")
       refute invalid_investment.valid?
       assert_includes invalid_investment.errors[:subtype], "is not a valid investment account subtype"
     end
   end
   ```

2. **Run the tests:**
   ```bash
   bin/rails test test/models/investment_test.rb
   ```

### Task 8.2: Write Component Tests
**Estimated Time:** 2-3 hours  
**Difficulty:** Medium  
**Files to create:** Component test files

**Objective:** Test the ViewComponents work correctly with various account configurations.

**Steps:**

1. **Create component test directory:**
   ```bash
   mkdir -p test/components/accounts
   mkdir -p test/components/forms
   ```

2. **Create investment card component test:**
   ```ruby
   # Create test/components/accounts/investment_card_component_test.rb
   require "test_helper"

   class Accounts::InvestmentCardComponentTest < ViewComponent::TestCase
     test "renders account information correctly" do
       account = Investment.new(
         name: "My 401k",
         subtype: "401k"
       )
       # Mock the balance method since we don't have a full account setup
       account.define_singleton_method(:balance) do
         Money.new(50000, "USD")
       end
       
       render_inline(Accounts::InvestmentCardComponent.new(account: account))
       
       assert_text "My 401k"
       assert_text "401(k)"
       assert_text "🇺🇸"
       assert_text "US"
     end

     test "shows tax treatment badge when enabled" do
       account = Investment.new(subtype: "roth_ira")
       account.define_singleton_method(:balance) do
         Money.new(25000, "USD")
       end
       
       render_inline(Accounts::InvestmentCardComponent.new(account: account, show_tax_treatment: true))
       
       assert_text "Tax-Free"
     end

     test "hides country indicator when disabled" do
       account = Investment.new(subtype: "401k")
       account.define_singleton_method(:balance) do
         Money.new(50000, "USD")
       end
       
       render_inline(Accounts::InvestmentCardComponent.new(account: account, show_country: false))
       
       refute_text "🇺🇸"
     end

     test "handles accounts without subtype gracefully" do
       account = Investment.new(name: "Generic Investment")
       account.define_singleton_method(:balance) do
         Money.new(10000, "USD")
       end
       
       render_inline(Accounts::InvestmentCardComponent.new(account: account))
       
       assert_text "Generic Investment"
       assert_text "Investment Account"
     end
   end
   ```

3. **Create grouped select component test:**
   ```ruby
   # Create test/components/forms/grouped_select_component_test.rb
   require "test_helper"

   class Forms::GroupedSelectComponentTest < ViewComponent::TestCase
     test "renders grouped select with options" do
       # Mock form object
       form = OpenStruct.new
       form.define_singleton_method(:label) { |field, options| "<label>#{field}</label>".html_safe }
       form.define_singleton_method(:grouped_select) do |field, grouped_options, select_options, html_options|
         "<select>#{grouped_options.map { |group, options| "<optgroup label='#{group}'>#{options.map { |text, value| "<option value='#{value}'>#{text}</option>" }.join}</optgroup>" }.join}</select>".html_safe
       end

       grouped_options = [
         ["🇺🇸 United States", [["401(k)", "401k"], ["IRA", "ira"]]],
         ["🇨🇦 Canada", [["RRSP", "rrsp"], ["TFSA", "tfsa"]]]
       ]
       
       render_inline(Forms::GroupedSelectComponent.new(
         form: form,
         field: :subtype,
         grouped_options: grouped_options,
         prompt: "Select account type"
       ))
       
       assert_text "subtype"
       assert_selector "optgroup[label*='United States']"
       assert_selector "optgroup[label*='Canada']"
     end
   end
   ```

4. **Run component tests:**
   ```bash
   bin/rails test test/components/
   ```

### Task 8.3: Write Controller Tests
**Estimated Time:** 1-2 hours  
**Difficulty:** Medium  
**Files to create:** `test/controllers/api/v1/investments_controller_test.rb`

**Objective:** Test the API endpoints return correct data.

**Steps:**

1. **Create API controller test:**
   ```ruby
   # Create test/controllers/api/v1/investments_controller_test.rb
   require "test_helper"

   class Api::V1::InvestmentsControllerTest < ActionDispatch::IntegrationTest
     test "subtype_data returns valid JSON structure" do
       get api_v1_investments_subtype_data_path, as: :json
       
       assert_response :success
       
       json_response = JSON.parse(response.body)
       
       # Test a few key subtypes
       assert_includes json_response.keys, "401k"
       assert_includes json_response.keys, "rrsp"
       
       # Test structure of a subtype entry
       subtype_data = json_response["401k"]
       assert_includes subtype_data.keys, "short_name"
       assert_includes subtype_data.keys, "long_name"
       assert_includes subtype_data.keys, "country"
       assert_includes subtype_data.keys, "flag"
       assert_includes subtype_data.keys, "tax_treatment"
       
       # Test specific values
       assert_equal "401(k)", subtype_data["short_name"]
       assert_equal "US", subtype_data["country"]
       assert_equal "🇺🇸", subtype_data["flag"]
     end

     test "subtype_data includes Canadian account types" do
       get api_v1_investments_subtype_data_path, as: :json
       
       json_response = JSON.parse(response.body)
       
       # Test Canadian accounts are included
       assert_includes json_response.keys, "rrsp"
       assert_includes json_response.keys, "tfsa"
       
       rrsp_data = json_response["rrsp"]
       assert_equal "CA", rrsp_data["country"]
       assert_equal "🇨🇦", rrsp_data["flag"]
     end
   end
   ```

2. **Run controller tests:**
   ```bash
   bin/rails test test/controllers/api/
   ```

### Task 8.4: Write Integration Tests
**Estimated Time:** 2-3 hours  
**Difficulty:** Medium-Hard  
**Files to create:** Integration test files

**Objective:** Test the complete user workflow for creating and managing investment accounts.

**Steps:**

1. **Create investment workflow test:**
   ```ruby
   # Create test/integration/investment_workflow_test.rb
   require "test_helper"

   class InvestmentWorkflowTest < ActionDispatch::IntegrationTest
     # You'll need to adapt these tests based on your authentication system
     # and existing test patterns

     test "user can create investment account with Canadian subtype" do
       # Login user (adapt to your auth system)
       # visit new_investment_path or similar
       
       # Select Canadian account type
       # fill_in "Name", with: "My RRSP"
       # select "🇨🇦 Canada", from: "country_filter"
       # select "RRSP (Registered Retirement Savings Plan)", from: "investment_subtype"
       
       # assert_difference "Investment.count", 1 do
       #   click_button "Create Investment"
       # end
       
       # new_investment = Investment.last
       # assert_equal "rrsp", new_investment.subtype
       # assert_equal "CA", new_investment.country
     end

     test "country filter works on investment index page" do
       # Create test investments with different countries
       # us_investment = create_investment(subtype: "401k")
       # ca_investment = create_investment(subtype: "rrsp")
       
       # visit investments_path
       
       # Test all investments visible by default
       # assert_text us_investment.name
       # assert_text ca_investment.name
       
       # Filter by Canada
       # click_link "🇨🇦 Canada"
       
       # assert_text ca_investment.name
       # refute_text us_investment.name
     end

     private

     def create_investment(attributes = {})
       # Helper method to create test investments
       # Adapt based on your test setup (fixtures, factories, etc.)
     end
   end
   ```

---

## Phase 9: Documentation and Deployment

### Task 9.1: Update Documentation
**Estimated Time:** 2 hours  
**Difficulty:** Easy  
**Files to create/modify:** README.md, docs/, etc.

**Objective:** Document the new features and how to use them.

**Steps:**

1. **Create feature documentation:**
   ```markdown
   # Create docs/features/multi_country_investments.md
   
   # Multi-Country Investment Account Support

   ## Overview
   The investment account system now supports comprehensive account types across multiple countries, with enhanced UI features for better user experience.

   ## Supported Countries
   - **United States**: 401k, 403b, IRA, Roth IRA, HSA, 529 plans, and more
   - **Canada**: RRSP, RRIF, TFSA, LIRA, GIC, and more
   - **United Kingdom**: ISA, SIPP
   - **International**: Brokerage, mutual funds, crypto, trust accounts

   ## Features
   - Country-based filtering in account creation forms
   - Visual country indicators with flags
   - Tax treatment badges (tax-deferred, tax-free, taxable)
   - Grouped account type selection
   - Real-time account information display

   ## Usage
   ### Creating Investment Accounts
   1. Navigate to account creation
   2. Select "Investment" as account type
   3. Use country filter to narrow options
   4. Select specific account subtype
   5. View real-time account information and tax implications

   ### Managing Investment Accounts
   - Use country filter tabs on account listing pages
   - View enhanced account cards with country and tax treatment indicators
   - Filter and sort accounts by jurisdiction

   ## Technical Implementation
   - Country mapping via `Investment::SUBTYPE_COUNTRIES` constant
   - Tax treatment via `Investment::TAX_TREATMENTS` constant
   - Interactive Stimulus controllers for filtering
   - ViewComponents for reusable UI elements
   - API endpoints for dynamic data loading
   ```

2. **Update main README if needed:**
   ```markdown
   # Add to README.md in features section:
   
   ## Investment Account Management
   - Support for 40+ investment account types across US, Canada, UK, and international markets
   - Country-based filtering and visual indicators
   - Tax treatment categorization (tax-deferred, tax-free, taxable)
   - Enhanced UI with real-time account information
   ```

### Task 9.2: Create Migration for Existing Data
**Estimated Time:** 1 hour  
**Difficulty:** Easy  
**Files to create:** Database migration

**Objective:** Ensure existing investment accounts continue to work with the new system.

**Steps:**

1. **Generate migration:**
   ```bash
   bin/rails generate migration UpdateExistingInvestmentSubtypes
   ```

2. **Write migration:**
   ```ruby
   # Edit the generated migration file
   class UpdateExistingInvestmentSubtypes < ActiveRecord::Migration[7.2]
     def up
       # Update any existing accounts that might need subtype corrections
       # This ensures backward compatibility
       
       # Example: Update any "529_plan" to "529" for consistency
       Investment.where(subtype: "529_plan").update_all(subtype: "529")
       
       # Log the changes
       Rails.logger.info "Updated investment subtypes for consistency"
     end

     def down
       # Rollback changes if needed
       Investment.where(subtype: "529").update_all(subtype: "529_plan")
       
       Rails.logger.info "Rolled back investment subtype changes"
     end
   end
   ```

3. **Run migration:**
   ```bash
   bin/rails db:migrate
   ```

### Task 9.3: Performance Testing and Optimization
**Estimated Time:** 2-3 hours  
**Difficulty:** Medium  
**Files to review:** All created files

**Objective:** Ensure the new features don't negatively impact application performance.

**Steps:**

1. **Test with large datasets:**
   ```ruby
   # In Rails console, test with many accounts
   bin/rails console
   
   # Create test data (be careful not to do this in production!)
   100.times do |i|
     Investment.create!(
       name: "Test Account #{i}",
       subtype: Investment::SUBTYPES.keys.sample,
       # Add other required fields
     )
   end
   
   # Test grouping performance
   Benchmark.time { Investment.grouped_by_country }
   
   # Test filtering performance
   accounts = Investment.all
   Benchmark.time { Investment.countries_with_counts(accounts) }
   ```

2. **Review and optimize queries:**
   - Check for N+1 queries in account listing pages
   - Ensure proper indexing on subtype column
   - Consider caching for expensive operations

3. **Test JavaScript performance:**
   - Use browser dev tools to test Stimulus controller performance
   - Ensure smooth filtering interactions
   - Test with large option lists

---

## Phase 10: Final Testing and QA

### Task 10.1: Manual QA Testing
**Estimated Time:** 3-4 hours  
**Difficulty:** Easy-Medium  
**Objective:** Comprehensive manual testing of all new features.

**Testing Checklist:**

1. **Account Creation Flow:**
   - [ ] Can create US investment accounts (401k, IRA, etc.)
   - [ ] Can create Canadian investment accounts (RRSP, TFSA, etc.)
   - [ ] Can create UK investment accounts (ISA, SIPP)
   - [ ] Can create international accounts (brokerage, crypto, etc.)
   - [ ] Country filter works in account creation form
   - [ ] Real-time account info panel displays correctly
   - [ ] Tax treatment badges show correct information

2. **Account Management:**
   - [ ] Investment accounts display with country flags
   - [ ] Tax treatment badges appear correctly
   - [ ] Country filtering works on account listing pages
   - [ ] Account cards show all relevant information
   - [ ] Empty states display correctly when no accounts match filter

3. **Data Integrity:**
   - [ ] Existing investment accounts still work
   - [ ] Subtype validation prevents invalid entries
   - [ ] API endpoints return correct data structure
   - [ ] Country and tax treatment mappings are accurate

4. **User Experience:**
   - [ ] Form interactions feel smooth and responsive
   - [ ] Visual indicators are clear and helpful
   - [ ] Navigation between filtered views works well
   - [ ] Mobile responsiveness is maintained

### Task 10.2: Automated Test Suite
**Estimated Time:** 1 hour  
**Difficulty:** Easy  
**Objective:** Ensure all tests pass and provide good coverage.

**Steps:**

1. **Run full test suite:**
   ```bash
   bin/rails test
   ```

2. **Run specific test groups:**
   ```bash
   # Model tests
   bin/rails test test/models/investment_test.rb
   
   # Component tests  
   bin/rails test test/components/
   
   # Controller tests
   bin/rails test test/controllers/api/
   
   # Integration tests
   bin/rails test test/integration/
   ```

3. **Check test coverage (if using SimpleCov):**
   ```bash
   open coverage/index.html
   # Ensure good coverage of new code
   ```

### Task 10.3: Code Review Checklist
**Estimated Time:** 1-2 hours  
**Difficulty:** Medium  
**Objective:** Final code review before deployment.

**Review Points:**

1. **Code Quality:**
   - [ ] Follows Rails conventions and project coding standards
   - [ ] Proper use of ViewComponents vs partials
   - [ ] Stimulus controllers are lightweight and focused
   - [ ] Helper methods are in appropriate modules
   - [ ] Constants are properly organized and documented

2. **Security:**
   - [ ] API endpoints have proper authentication
   - [ ] Form inputs are properly sanitized
   - [ ] No sensitive data exposed in client-side code
   - [ ] CSRF protection maintained

3. **Performance:**
   - [ ] No N+1 queries introduced
   - [ ] Efficient use of database queries
   - [ ] Minimal JavaScript bundle size impact
   - [ ] Reasonable response times for new endpoints

4. **Accessibility:**
   - [ ] Proper labels on form elements
   - [ ] Color indicators have text alternatives
   - [ ] Keyboard navigation works properly
   - [ ] Screen reader compatibility maintained

---

## Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Migration tested on staging environment

### Deployment Steps
1. [ ] Deploy to staging environment
2. [ ] Run migration: `bin/rails db:migrate`
3. [ ] Test key workflows on staging
4. [ ] Deploy to production
5. [ ] Monitor for errors and performance issues

### Post-Deployment
- [ ] Verify new features work in production
- [ ] Monitor application logs for errors
- [ ] Check performance metrics
- [ ] Gather user feedback

---

## Common Issues and Troubleshooting

### JavaScript Issues
- **Stimulus controllers not loading:** Check `app/javascript/controllers/index.js` for proper registration
- **Country filtering not working:** Verify data attributes match controller targets
- **API endpoint errors:** Check network tab for 404s or authentication issues

### CSS/Styling Issues
- **Badges not styled correctly:** Verify Tailwind classes are available and not purged
- **Responsive layout problems:** Test on various screen sizes
- **Icon not displaying:** Check `icon` helper is available and working

### Data Issues
- **Invalid subtype errors:** Check `Investment::SUBTYPES` includes all used values
- **Country mapping missing:** Verify `SUBTYPE_COUNTRIES` has entry for subtype
- **Tax treatment wrong:** Check `TAX_TREATMENTS` mapping

### Performance Issues
- **Slow page loads:** Check for N+1 queries, optimize database queries
- **Large JavaScript bundles:** Consider lazy loading for complex interactions
- **Slow API responses:** Add caching where appropriate

---

## Future Enhancements

### Potential Improvements
1. **Search Functionality:** Add text search within account type dropdowns
2. **Additional Countries:** Support for more international account types (Australia, Germany, etc.)
3. **Account Type Recommendations:** Suggest account types based on user location
4. **Bulk Operations:** Allow bulk categorization of accounts by country
5. **Advanced Filtering:** Multiple filter criteria (country + tax treatment)
6. **Analytics Dashboard:** Country-specific financial analytics and reporting

### Technical Debt
- Consider extracting country/tax logic into separate service objects as system grows
- Evaluate caching strategies for frequently accessed subtype data
- Consider internationalization (i18n) for multi-language support
- Review and optimize database indexes as data volume grows

---

## Success Metrics

### User Experience Metrics
- Time to create new investment account (should decrease)
- User completion rate for account setup (should increase)
- Support tickets related to account type confusion (should decrease)

### Technical Metrics
- Page load times remain under acceptable thresholds
- JavaScript bundle size increase is minimal
- Test coverage maintains high levels
- No increase in error rates

### Business Metrics
- Increased adoption among Canadian users
- Higher accuracy in account categorization
- Reduced user friction in account management workflows

This comprehensive task list provides a junior developer with detailed, step-by-step instructions to implement the multi-country investment account enhancement while maintaining code quality and following Rails best practices.