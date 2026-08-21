// skeletons.js — marcado reutilizable de estados de carga (shimmer), en vez
// de spinners genéricos.

export function kpiSkeletonHTML() {
  return Array.from({ length: 4 }).map(() => `
    <div class="rp-kpi-card rp-card d-flex align-items-center gap-2 p-2">
      <div class="kpi-icon skel"></div>
      <div class="min-w-0">
        <div class="skel mb-1" style="height:7px;width:60px;"></div>
        <div class="skel" style="height:16px;width:70px;"></div>
      </div>
    </div>`).join('');
}

export function rowsSkeletonHTML(cols, rows = 4) {
  const cells = Array.from({ length: cols }).map(() => `<td><div class="skel" style="height:12px;width:80%;"></div></td>`).join('');
  return Array.from({ length: rows }).map(() => `<tr>${cells}</tr>`).join('');
};
