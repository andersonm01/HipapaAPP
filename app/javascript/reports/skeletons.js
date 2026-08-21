// skeletons.js — marcado reutilizable de estados de carga (shimmer), en vez
// de spinners genéricos.

export function kpiSkeletonHTML() {
  return Array.from({ length: 4 }).map(() => `
    <div class="col-6 col-xl-3">
      <div class="rp-card d-flex align-items-center gap-3 p-3 h-100">
        <div class="kpi-icon skel"></div>
        <div class="min-w-0 flex-grow-1">
          <div class="skel mb-2" style="height:9px;width:70%;"></div>
          <div class="skel" style="height:22px;width:90%;"></div>
        </div>
      </div>
    </div>`).join('');
}

export function rowsSkeletonHTML(cols, rows = 4) {
  const cells = Array.from({ length: cols }).map(() => `<td><div class="skel" style="height:12px;width:80%;"></div></td>`).join('');
  return Array.from({ length: rows }).map(() => `<tr>${cells}</tr>`).join('');
}
