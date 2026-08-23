---
name: responsive-review
description: Audita y corrige el responsive de las vistas de HipapaAPP contra los 3 tamaños de referencia del proyecto (1024x768, iPhone 14 Pro Max, 1920x1080). Usar cuando el usuario pida revisar/arreglar el responsive, mobile o layout de una vista, de un módulo, o de toda la app.
---

# Responsive review — HipapaAPP

Audita el código de las vistas (ERB + `app/assets/tailwind/application.css`)
contra los 3 anchos de referencia del proyecto y corrige lo que esté
realmente roto. No es un rediseño — es cirugía puntual sobre lo que no
se adapta.

## Los 3 tamaños de referencia

- **1024x768** — tablet / laptop pequeño, landscape, altura corta. Es
  justo el borde entre el modo "tablet" y "desktop" del sidebar (ver
  abajo), y la altura corta (768px) es la que más expone modales o
  paneles con `max-height` mal calculado.
- **iPhone 14 Pro Max — 430x932 CSS px** — el mobile de referencia
  (portrait). Es el ancho que expone tablas con demasiadas columnas,
  grids con `minmax()` muy grande, y texto/decoración que no escala.
- **1920x1080** — desktop full HD. Suele estar resuelto por defecto en
  layouts fluidos, pero confirmá que nada se vea "perdido" en un
  contenedor `max-w-*` centrado ni que un grid se vuelva excesivo.

Si el usuario pide un tamaño distinto, usalo en vez de estos — esta
lista es el default cuando no especifica.

## Stack (leer antes de tocar nada)

- Tailwind v4, un solo archivo fuente: `app/assets/tailwind/application.css`
  (`@theme` con tokens de marca + `@layer components` con las clases
  custom: `.btn-*`, `.form-*`, `.card*`, `.badge-*`, `.alert-*`,
  `.table`/`.table-compact`, `.page-header`/`.page-title`,
  `.product-btn`, `.service-card`, `.kitchen-*`, `.sel-*`, y una capa
  de compatibilidad `.modal*` para los modales de Bootstrap JS).
- Bootstrap 5.3 solo se carga por su JS (modales, dropdowns) vía CDN en
  `layouts/application.html.erb` — el CSS real de la app es Tailwind.
- El sidebar (`.app-sidebar`/`.app-body` en el mismo CSS) **ya tiene
  resueltos** los 3 modos: mobile `<768px` (off-canvas + `.mobile-topbar`),
  tablet `768–1023.98px` (rail de íconos colapsado), desktop `>=1024px`
  (expandido). No lo rediseñes — solo tocalo si encontrás un bug real.
- Landing pública (`app/views/public/landing/*` + `.landing-*` en el
  mismo CSS) ya tiene bastantes media queries pensadas (navbar hamburguesa
  `<900px`, info-band `<640px`, nosotros-grid `<860px`, footer `<768px`,
  hero `<480px`). Revisala con ojo crítico en los 3 anchos, pero no
  asumas que está rota — el código de esa sección suele estar bien pulido.
- **No toques layouts de impresión** (`layouts/print.html.erb`,
  `invoices/print.html.erb`) — son para ticket térmico 80mm, no para
  pantalla, y "responsive" no aplica ahí.

## Antes de empezar

1. `git status` — el usuario suele tener trabajo propio sin commitear
   en paralelo (features nuevas, no relacionadas). Nunca lo toques ni
   lo incluyas en tu commit. Si algo cambia en el working tree mientras
   trabajás (otro proceso commiteando), no lo interpretes como tuyo ni
   lo reviertas sin verificar `git log` primero.
2. Chequeá si hay un navegador headless disponible (`chromium-cli`,
   Playwright con browsers ya instalados) antes de asumir que hay que
   hacer auditoría solo de código — si lo hay, usalo para capturas
   reales en los 3 anchos, es muy superior a leer CSS. Si no hay nada
   instalado y traerlo implica una descarga pesada, preguntale al
   usuario si prefiere invertir ese tiempo o ir directo al análisis de
   código (ver conversación de referencia: la última vez se optó por
   código sin capturas).

## Checklist de problemas típicos

- **Tablas** (`index.html.erb` de cualquier recurso): ¿tienen wrapper
  `<div class="overflow-x-auto">`? ¿Cuántas columnas hay? Con más de
  ~4-5 columnas de datos reales, ocultá las secundarias en mobile con
  `hidden sm:table-cell` / `hidden md:table-cell` en `<th>` y `<td>`
  (no elimines info crítica, solo la secundaria). Si la tabla usa
  `table-layout:fixed` con anchos en `%`, ocultar columnas deja espacio
  vacío — agregá un `@media (max-width: ...) { th, td { width: auto !important; } }`
  scoped a esa tabla (ver `.pos-orders-table` en el CSS como ejemplo).
- **Formularios con grid fijo**: `grid-cols-2`/`grid-cols-3` sin
  variante responsive → `grid-cols-1 sm:grid-cols-2` (o el breakpoint
  que corresponda) para que colapsen en mobile.
- **Filas flex sin wrap**: stats + botones de acción en una sola fila
  (`flex justify-between` sin `flex-wrap`) se aplastan en 430px →
  `flex-col sm:flex-row` con `gap`, o `flex-wrap`.
- **Grids con `minmax()` grande** (`.kitchen-grid`, `.landing-menu-grid`,
  etc.): confirmá que el valor mínimo entra en 430px menos el padding
  del contenedor. Si no, bajalo en un media query mobile puntual.
- **KPI cards / stat rows** con `flex-shrink` permitido: en mobile se
  comprimen en vez de hacer scroll horizontal. Si el contenedor ya
  tiene `overflow-x:auto`, poné `flex-shrink:0` (o `flex: 0 0 <ancho>`)
  a las cards en un media query angosto para que conserven ancho
  legible y sea el contenedor el que scrollee.
- **Charts (Chart.js)**: el `<canvas>` necesita un contenedor con
  `position:relative` + altura controlada, y el chart con
  `responsive:true, maintainAspectRatio:false`. Sin esto crece sin
  límite o se aplasta.
- **Texto/decoración grande** (`font-size` en `rem` grandes, quotes
  decorativas con `position:absolute`): confirmá que no se desborden
  ni se superpongan en 430px ni en el borde 1024px.
- **Modales** (`.modal-dialog`) en 1024x768 (altura corta): confirmá
  que el body scrollea (`overflow-y:auto`) en vez de cortar contenido.
- **Botones/inputs táctiles**: en mobile, apuntá a ~40px de alto mínimo
  en controles interactivos primarios (no hace falta ser estricto en
  iconos secundarios ya establecidos como `btn-icon-sm`).

## Cómo dividir el trabajo

- **Una vista puntual o un módulo chico**: hacelo vos mismo, inline,
  sin forks. Leé el/los `.erb` + las secciones relevantes del CSS,
  corregí con `Edit`.
- **"Revisá toda la app"**: dividí en 3 forks paralelos (mismo patrón
  que la última auditoría completa), cada uno con Read + Edit directo
  (no solo reporte) y un tope de ~250 palabras de resumen final:
  1. **POS core + cocina**: `home/index.html.erb`, `cocina/index.html.erb`
     + `_order_card.html.erb`, `home/printer_config.html.erb`,
     `layouts/_sidebar.html.erb` (solo HTML, no el sistema de CSS ya
     resuelto), `layouts/application.html.erb`.
  2. **CRUD administrativo**: `products`, `customers`, `ingredients`,
     `recipes`, `cash_registers`, `invoices` (no `print.html.erb`),
     `admin/users`, `business_settings`.
  3. **Público + reportes + auth**: `layouts/landing.html.erb` + todos
     los partials de `public/landing/`, `layouts/public.html.erb`,
     `public/menu/index.html.erb`, `public/orders/status.html.erb`,
     `reports/index.html.erb`, `sessions/new.html.erb`.
- Dale a cada fork el contexto de stack de arriba (no asumas que lo
  tiene si es un agente fresco sin `subagent_type: fork`) y las reglas
  de scope: corregir con Edit, no reportar solo; no tocar impresión; no
  inventar features; no rediseñar lo que ya funciona.
- **Si un fork reporta algo raro** (un resumen que no encaja, un diff
  con una feature no pedida): antes de asumir que alucinó, revisá
  `git log` — puede que el usuario haya commiteado algo real en
  paralelo mientras el fork corría, y el fork se haya confundido al
  verlo aparecer. Si el diff no tiene nada que ver con responsive,
  revertí solo ese archivo (`git checkout -- <archivo>`) y hacé esa
  parte del audit vos mismo.

## Verificación (sin navegador)

No hay `chromium-cli` ni Playwright instalado en este entorno por
default. En su lugar, después de editar:

1. Arrancá el server: `bin/rails server -p 3099 -e development &`,
   esperá con un poll a `curl -sf http://localhost:3099/`.
2. Si las páginas requieren login, autenticá con curl (POST a
   `/login` con el `authenticity_token` de la página, cookie jar) —
   credenciales de seed en memoria del proyecto.
3. `curl` cada ruta tocada (o su índice) y confirmá `200`, no `500`.
   Rutas en inglés (`/products`, `/customers`, `/ingredients`,
   `/cash_registers`, `/invoices`, `/admin/users`,
   `/business_settings`), `/mostrador`, `/cocina`, `/reportes`,
   `/public`, `/login`.
4. Matá el server por el puerto (`netstat` + `taskkill //F //PID`, no
   `pkill -f` genérico) antes de terminar.

Esto no verifica el layout visualmente, pero sí que ninguna edición
rompió el render (error de ERB, helper inexistente, etc.).

## Al terminar

- No commitees ni pushees salvo que el usuario lo pida explícitamente.
- Si commiteás, dejá afuera `db/development.sqlite3`, `db/test.sqlite3`
  y `log/development.log` — no son parte del cambio.
- Reportá archivo por archivo qué se corrigió y por qué (el ancho/caso
  concreto que rompía), no solo "mejoré el responsive de X".
