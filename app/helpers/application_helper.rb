module ApplicationHelper
  # ---------------------------------------------------------------
  # Sidebar navigation structure. Single source of truth for every
  # link shown in app/views/layouts/_sidebar.html.erb. Role gating
  # here mirrors each controller's own before_action restrictions —
  # it does not invent new permissions.
  # ---------------------------------------------------------------
  def sidebar_sections
    [
      {
        items: [
          { key: :inicio,    label: "Inicio",    path: root_path,           icon: :home,
            badge: logged_in? ? Order.open.count : nil },
          { key: :cocina,    label: "Cocina",    path: cocina_path,         icon: :kitchen,
            badge: logged_in? ? Order.for_kitchen.count : nil },
          { key: :productos, label: "Productos", path: products_path,       icon: :package },
          { key: :clientes,  label: "Clientes",  path: customers_path,      icon: :users },
          { key: :impresora, label: "Impresora", path: printer_config_path, icon: :printer },
        ]
      },
      {
        title: "Ventas",
        icon: :wallet,
        items: [
          { key: :caja,     label: "Caja",     path: cash_registers_path, icon: :wallet },
          { key: :facturas, label: "Facturas", path: invoices_path,       icon: :receipt },
        ]
      },
      {
        title: "Gestión",
        icon: :chart,
        visible: current_user&.admin? || current_user&.supervisor?,
        items: [
          { key: :reportes, label: "Reportes", path: reportes_path,    icon: :chart },
          { key: :stock,    label: "Stock",    path: ingredients_path, icon: :box_stack,
            badge: Ingredient.stock_bajo.count },
        ]
      },
      {
        title: "Administración",
        icon: :settings,
        visible: current_user&.admin?,
        items: [
          { key: :usuarios, label: "Usuarios", path: admin_users_path,       icon: :user_cog },
          { key: :negocio,  label: "Negocio",  path: business_settings_path, icon: :settings },
        ]
      },
    ]
  end

  # Is this specific nav item the one matching the current request?
  def sidebar_item_active?(key)
    case key
    when :inicio    then controller_name == "home" && action_name == "index"
    when :impresora then controller_name == "home" && action_name.start_with?("printer")
    when :cocina     then controller_name == "cocina"
    when :productos  then controller_name == "products" || controller_name == "recipes"
    when :clientes   then controller_name == "customers"
    when :caja       then controller_name == "cash_registers"
    when :facturas   then controller_name == "invoices"
    when :reportes   then controller_name == "reports"
    when :stock      then controller_name == "ingredients"
    when :usuarios   then controller_path == "admin/users"
    when :negocio    then controller_name == "business_settings"
    else false
    end
  end

  # Does this group (submenu) contain the currently active item?
  def sidebar_group_active?(section)
    section[:items].any? { |item| sidebar_item_active?(item[:key]) }
  end

  ICONS = {
    home:      "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6",
    kitchen:   "M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.657 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z M9.879 16.121A3 3 0 1012.015 11L11 14H9c0 .768.293 1.536.879 2.121z",
    package:   "M20 7L12 3 4 7m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4",
    users:     "M17 20h5v-2a4 4 0 00-3-3.87M9 20H4v-2a4 4 0 013-3.87m5-3.13a4 4 0 100-8 4 4 0 000 8zm6 0a4 4 0 10-3.24-6.34",
    printer:   "M6 9V2h12v7M6 18H4a2 2 0 01-2-2v-5a2 2 0 012-2h16a2 2 0 012 2v5a2 2 0 01-2 2h-2M6 14h12v8H6v-8z",
    wallet:    "M3 10h18M7 15h1m4 0h1m-7 4h12a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z",
    receipt:   "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z",
    chart:     "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z",
    box_stack: "M5 8h14M5 8a2 2 0 01-2-2V4a2 2 0 012-2h14a2 2 0 012 2v2a2 2 0 01-2 2M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4",
    user_cog:  "M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z",
    settings:  "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z",
    chevron:   "M6 9l6 6 6-6",
    menu:      "M4 6h16M4 12h16M4 18h16",
    close:     "M6 18L18 6M6 6l12 12",
    logout:    "M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4m7 14l5-5-5-5m5 5H9",
  }.freeze

  # Reusable inline SVG icon (24x24 stroke line icon). Centralized so every
  # nav icon shares the same markup/attributes instead of duplicating <svg> tags.
  def icon(name, css_class: "w-5 h-5")
    path = ICONS.fetch(name) { ICONS[:package] }
    content_tag(:svg, class: css_class, fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", "aria-hidden": "true") do
      content_tag(:path, nil, "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "1.8", d: path)
    end
  end
end
