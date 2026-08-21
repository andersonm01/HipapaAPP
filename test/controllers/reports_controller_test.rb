require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    admin = User.create!(name: "Admin Test", email: "admin_reports_view_test@example.com",
                          password: "clave123", role: "admin", active: true)
    post "/login", params: { email: admin.email, password: "clave123" }

    get reportes_url
    assert_response :success
    assert_select "#kpiCards"
    assert_select "#periodNav .pn-btn", count: 6
  end
end
