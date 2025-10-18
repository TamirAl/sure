require "test_helper"

class Api::V1::InvestmentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @family = families(:dylan_family)
    @user = @family.users.first
    @api_key = @user.api_keys.create!(
      name: "Test API Key",
      scopes: ["read"],
      raw_key: "test_key_12345"
    )
  end

  # Test authentication
  test "requires authentication for all endpoints" do
    get api_v1_investments_subtype_data_path
    assert_response :unauthorized

    get api_v1_investments_countries_path
    assert_response :unauthorized

    get api_v1_investments_subtypes_by_country_path
    assert_response :unauthorized
  end

  test "accepts valid API key authentication" do
    get api_v1_investments_subtype_data_path, 
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }
    assert_response :success
  end

  test "rejects invalid API key" do
    get api_v1_investments_subtype_data_path,
        headers: { "Authorization" => "Bearer invalid_key" }
    assert_response :unauthorized
  end

  test "requires read scope for endpoints" do
    limited_key = @user.api_keys.create!(
      name: "Write Only Key", 
      scopes: ["write"],
      raw_key: "write_only_key"
    )

    get api_v1_investments_subtype_data_path,
        headers: { "Authorization" => "Bearer #{limited_key.raw_key}" }
    assert_response :forbidden
  end

  # Test subtype_data endpoint
  test "subtype_data returns comprehensive investment data" do
    get api_v1_investments_subtype_data_path,
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }

    assert_response :success
    
    json_response = JSON.parse(response.body)
    
    # Should have subtypes data
    assert json_response.key?("subtypes")
    subtypes = json_response["subtypes"]
    
    # Should include US account types
    brokerage = subtypes.find { |s| s["key"] == "brokerage" }
    assert_not_nil brokerage
    assert_equal "US", brokerage["country"]
    assert_equal "taxable", brokerage["tax_treatment"]
    assert_equal "🇺🇸", brokerage["country_flag"]
    
    # Should include Canadian account types
    rrsp = subtypes.find { |s| s["key"] == "rrsp" }
    assert_not_nil rrsp
    assert_equal "CA", rrsp["country"]
    assert_equal "tax_deferred", rrsp["tax_treatment"]
    assert_equal "🇨🇦", rrsp["country_flag"]
  end

  test "subtype_data includes tax treatment badge information" do
    get api_v1_investments_subtype_data_path,
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }

    json_response = JSON.parse(response.body)
    roth_ira = json_response["subtypes"].find { |s| s["key"] == "roth_ira" }
    
    assert_not_nil roth_ira["tax_treatment_badge"]
    badge = roth_ira["tax_treatment_badge"]
    assert_equal "Tax Free", badge["text"]
    assert badge["class"].include?("bg-green-100")
  end

  # Test countries endpoint  
  test "countries returns user's investment account countries with counts" do
    # Create investment accounts for the family
    @family.accounts.create!(
      name: "US Brokerage",
      accountable: Investment.new(subtype: "brokerage"),
      balance: 10000,
      currency: "USD"
    )
    
    @family.accounts.create!(
      name: "RRSP Account",
      accountable: Investment.new(subtype: "rrsp"),
      balance: 15000,
      currency: "CAD"  
    )

    get api_v1_investments_countries_path,
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }

    assert_response :success
    
    json_response = JSON.parse(response.body)
    
    assert json_response.key?("countries")
    countries = json_response["countries"]
    
    assert_equal 1, countries["US"]
    assert_equal 1, countries["CA"]
    assert_nil countries["UK"]
  end

  test "countries returns empty hash when no investment accounts" do
    # Ensure family has no investment accounts
    @family.accounts.joins(:accountable).where(accountable_type: "Investment").destroy_all

    get api_v1_investments_countries_path,
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }

    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal({}, json_response["countries"])
  end

  # Test subtypes_by_country endpoint
  test "subtypes_by_country filters by country parameter" do
    get api_v1_investments_subtypes_by_country_path(country: "US"),
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }

    assert_response :success
    
    json_response = JSON.parse(response.body)
    
    assert json_response.key?("subtypes")
    subtypes = json_response["subtypes"]
    
    # All subtypes should be US
    subtypes.each do |subtype|
      assert_equal "US", subtype["country"]
    end
    
    # Should include US-specific accounts
    subtype_keys = subtypes.map { |s| s["key"] }
    assert_includes subtype_keys, "brokerage"
    assert_includes subtype_keys, "401k"
    assert_not_includes subtype_keys, "rrsp"
  end

  test "subtypes_by_country handles invalid country gracefully" do
    get api_v1_investments_subtypes_by_country_path(country: "INVALID"),
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }

    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal [], json_response["subtypes"]
  end

  test "subtypes_by_country requires country parameter" do
    get api_v1_investments_subtypes_by_country_path,
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }

    assert_response :bad_request
    
    json_response = JSON.parse(response.body)
    assert json_response["error"].include?("country parameter is required")
  end

  # Test error handling
  test "handles internal server errors gracefully" do
    # Mock an error in the Investment model
    Investment.stubs(:grouped_by_country).raises(StandardError.new("Database error"))

    get api_v1_investments_subtype_data_path,
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }

    assert_response :internal_server_error
    
    json_response = JSON.parse(response.body)
    assert json_response.key?("error")
  end

  # Test rate limiting (if implemented)
  test "respects rate limits" do
    # This would depend on your Rack::Attack configuration
    # For now, just verify the endpoint is accessible
    get api_v1_investments_subtype_data_path,
        headers: { "Authorization" => "Bearer #{@api_key.raw_key}" }
    
    assert_response :success
  end

  # Test JSON format
  test "returns properly formatted JSON" do
    get api_v1_investments_subtype_data_path,
        headers: { 
          "Authorization" => "Bearer #{@api_key.raw_key}",
          "Accept" => "application/json"
        }

    assert_response :success
    assert_equal "application/json", response.media_type
    
    # Should be valid JSON
    assert_nothing_raised do
      JSON.parse(response.body)
    end
  end
end