require "rails_helper"

RSpec.describe "UserAdInteractions", type: :request do
  describe "GET /user_ad_interactions" do
    it "works! (now write some real specs)" do
      get user_ad_interactions_path
      expect(response).to have_http_status(200)
    end
  end
end
