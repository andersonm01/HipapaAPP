# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

- **Ruby 3.2.2** / **Rails 7.0.10**
- **SQLite3** (development/test/production)
- **Bootstrap 5.3** for UI
- **Dart Sass** (`dartsass-rails`) for CSS
- **Importmap** for JS (no Node/bundler)
- **Hotwire** (Turbo + Stimulus)
- **ActionCable** for real-time order updates (async adapter in dev, Redis in production)

## Commands

```bash
# Start server
bin/rails server

# Database
bin/rails db:migrate
bin/rails db:seed

# Console
bin/rails console

# Tests
bin/rails test                          # all tests
bin/rails test test/controllers/orders_controller_test.rb  # single file

# Assets
bin/rails assets:precompile             # compile Sass/JS for production
```

## Architecture

This is a restaurant POS (point-of-sale) counter application called "Mostrador" (front counter).

### Core Flow

1. Waiter creates an **Order** (`cliente`, `mesero`, `tipo_servicio`: mesa/llevar/domicilio)
2. Products are added via `confirm_items` — they become **OrderItems** linked to the order
3. When confirming products, a **comanda** (kitchen ticket) is printed via a JS popup window targeting 80mm POS printers
4. Order is **closed** with payment info (`monto_pagado`, `tipo_pago`, `vuelto`); status changes from `0` (open) to `1` (closed)

### Single-Page UI Pattern

The entire app lives on `HomeController#index` (root path). Order state is passed via URL:
- `/?order_id=:id` — viewing an existing open order (redirected here after create)
- `/pedido/:id` — same view, different URL format (used for navigation)

The view switches between "new order form" and "order detail panel" based on `@new_order_id` presence.

### Real-Time Updates (ActionCable)

`OrdersChannel` streams on `"orders_channel"`. After any order mutation (create/update/close), the controller broadcasts a typed event. `home.js` receives these and calls `location.reload()` to refresh the tables. The consumer is exposed as `window.App.cable` via `cable.js`.

### Models

- `Order` — `cliente`, `mesero`, `comentario`, `tipo_servicio`, `status` (0=open, 1=closed), `monto_pagado`, `tipo_pago`, `vuelto`
- `OrderItem` — `order_id`, `product_id`, `cantidad`, `precio_unitario`, `comentario`; `subtotal` = `cantidad * precio_unitario`
- `Product` — `nombre`, `descripcion`, `precio`, `categoria`, `activo` (boolean); only `activo: true` products shown on order screen

### Routes

```
GET  /                     home#index (root)
GET  /pedido/:id           home#index (alias, named :pedido)
POST /orders               orders#create
POST /orders/:id/confirm_items
POST /orders/:id/close_order
PATCH /orders/:id/update_servicio
resources :products        (full CRUD)
mount ActionCable          /cable
```

### JavaScript

All JS is loaded via importmap. `home.js` is imported as a module directly in the view (`import "home"`). It handles:
- Product search/selection (client-side temp list)
- POS comanda print (opens popup, renders 80mm-formatted HTML, triggers `window.print()`, then submits the form)
- Vuelto (change) calculation in the close-order modal
- ActionCable subscription and page reload on events

### Turbo

Most forms use `data: { turbo: false }` to disable Turbo Drive on form submissions, relying on full page reloads instead.
