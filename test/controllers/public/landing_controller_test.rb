require "test_helper"

class Public::LandingControllerTest < ActionDispatch::IntegrationTest
  test "la landing renderiza sin login con sus secciones principales" do
    producto = Product.create!(nombre: "Papas de prueba", precio: 12_000,
                               categoria: "Papas", activo: true)

    get root_url

    assert_response :success
    assert_select "section.landing-hero#top"
    assert_select "h1.landing-title"
    assert_select "section#menu"
    assert_select "section#nosotros"
    assert_select "[data-menu-category=?]", "papas"
    assert_select ".landing-menu-item-name", text: producto.nombre
  end

  test "el producto de Domicilio no aparece en el menú de la landing" do
    Product.create!(nombre: "Domicilio zona sur", precio: 5_000,
                    categoria: "Domicilio", activo: true)

    get root_url

    assert_response :success
    assert_select ".landing-menu-item-name", text: "Domicilio zona sur", count: 0
  end
end
