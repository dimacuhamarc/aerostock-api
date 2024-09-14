require 'rails_helper'

RSpec.describe "ItemSearches", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/item_search/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /search" do
    it "returns http success" do
      get "/item_search/search"
      expect(response).to have_http_status(:success)
    end
  end

end
