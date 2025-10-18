class Api::V1::InvestmentsController < Api::V1::BaseController
  # GET /api/v1/investments/subtype_data.json
  # Returns comprehensive subtype data for investment accounts including country and tax treatment info
  def subtype_data
    authorize_scope!(:read)

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

    render_json({ subtypes: data })
  rescue => e
    Rails.logger.error "API Error in subtype_data: #{e.message}"
    render_json({ 
      error: "internal_error", 
      message: "Unable to retrieve subtype data" 
    }, status: :internal_server_error)
  end

  # GET /api/v1/investments/countries.json
  # Returns available countries with their investment account counts for the current user
  def countries
    authorize_scope!(:read)

    user_investments = current_resource_owner.family.accounts.investment
    countries_data = Investment.countries_with_counts(user_investments)
    
    render_json({ countries: countries_data })
  rescue => e
    Rails.logger.error "API Error in countries: #{e.message}"
    render_json({ 
      error: "internal_error", 
      message: "Unable to retrieve countries data" 
    }, status: :internal_server_error)
  end

  # GET /api/v1/investments/subtypes_by_country.json?country=US
  # Returns investment subtypes filtered by country
  def subtypes_by_country
    authorize_scope!(:read)

    country = params[:country]
    
    if country.blank?
      render_json({ 
        error: "bad_request", 
        message: "Country parameter is required" 
      }, status: :bad_request)
      return
    end

    subtypes = Investment.subtypes_for_country(country)
    
    render_json({ 
      country: country,
      subtypes: subtypes 
    })
  rescue => e
    Rails.logger.error "API Error in subtypes_by_country: #{e.message}"
    render_json({ 
      error: "internal_error", 
      message: "Unable to retrieve subtypes for country" 
    }, status: :internal_server_error)
  end
end