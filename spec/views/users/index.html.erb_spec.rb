require 'rails_helper'

RSpec.describe "users/index", type: :view do
  before(:each) do
    assign(:users, [
      create(:user, email: "user1@example.com", role: :admin),
      create(:user, email: "user2@example.com", role: :teacher)
    ])
  end

  it "renders a list of users" do
    render
    expect(rendered).to match(/user1@example.com/)
    expect(rendered).to match(/user2@example.com/)
  end
end
