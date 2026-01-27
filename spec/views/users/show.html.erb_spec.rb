require 'rails_helper'

RSpec.describe "users/show", type: :view do
  before(:each) do
    assign(:user, create(:user, email: "test@example.com", role: :admin))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/test@example.com/)
    expect(rendered).to match(/admin/)
  end
end
