require "test_helper"

class Api::V1::ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(name: "Admin Test", email: "admin_reports_test@example.com",
                           password: "clave123", role: "admin", active: true)
    post "/login", params: { email: @admin.email, password: "clave123" }

    product = Product.create!(nombre: "Producto Test", precio: 10_000, categoria: "Test")
    order = Order.create!(cliente: "Cliente Test", mesero: "Mesero Test", status: Order::STATUS_CLOSED,
                           monto_pagado: 10_000, tipo_pago: "efectivo", tipo_servicio: "mesa")
    OrderItem.create!(order: order, product: product, cantidad: 1, precio_unitario: 10_000)
  end

  test "summary devuelve kpis, tablas y gráficas" do
    get summary_api_v1_reports_url, params: { period: "year" }
    assert_response :success

    body = JSON.parse(response.body)
    assert body.key?("kpis")
    assert body.key?("top_products")
    assert body.key?("sellers")
    assert body.key?("heatmap")
    assert body.key?("insights")
    assert_operator body["kpis"]["revenue"]["value"], :>=, 10_000.0
  end

  test "trend acepta las tres granularidades" do
    %w[day week month].each do |granularity|
      get trend_api_v1_reports_url, params: { period: "year", granularity: granularity }
      assert_response :success, "granularity=#{granularity} debería responder 200"

      body = JSON.parse(response.body)
      assert_equal granularity, body["granularity"]
      assert body["data"].is_a?(Array)
    end
  end

  test "orders pagina el detalle" do
    get orders_api_v1_reports_url, params: { period: "year", per_page: 5 }
    assert_response :success

    body = JSON.parse(response.body)
    assert body["data"].is_a?(Array)
    assert body["meta"].key?("total")
  end

  test "orders_csv descarga un CSV" do
    get orders_csv_api_v1_reports_url, params: { period: "year" }
    assert_response :success
    assert_match "text/csv", response.content_type
    assert_match "Cliente Test", response.body
  end

  test "rechaza a usuarios sin rol admin/supervisor" do
    user = User.create!(name: "Mesero Test", email: "mesero_reports_test@example.com",
                         password: "clave123", role: "user", active: true)
    post "/login", params: { email: user.email, password: "clave123" }

    get summary_api_v1_reports_url, params: { period: "year" }
    assert_response :forbidden
  end
end
