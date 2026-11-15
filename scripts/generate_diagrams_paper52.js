const fs = require('fs');
const path = require('path');

const jsonPath = path.join(__dirname, '..', 'flutter_app', 'assets', 'paper52.json');
const jsPath = path.join(__dirname, '..', 'paper52.js');

const raw = fs.readFileSync(jsonPath, 'utf8');
const paperData = JSON.parse(raw);
const qs = paperData.questions;

// Helper to create clean SVGs with neutral styling
function svgWrapper(content, width = 340, height = 180) {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="100%" height="100%" style="background:#f8fafc; border-radius:12px; font-family:sans-serif;">
    ${content}
  </svg>`;
}

// 1. Q6 (Number triangles: 54->20,9 | 38->24,11 | 94->?,13)
const svgQ6 = svgWrapper(`
  <g transform="translate(15, 20)">
    <!-- Shape 1 -->
    <g transform="translate(0, 0)">
      <polygon points="45,10 5,90 85,90" fill="#f1f5f9" stroke="#475569" stroke-width="2" />
      <circle cx="45" cy="38" r="16" fill="#ffffff" stroke="#475569" stroke-width="1.5" />
      <text x="45" y="43" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">54</text>
      <circle cx="20" cy="85" r="14" fill="#ffffff" stroke="#475569" stroke-width="1.5" />
      <text x="20" y="89" text-anchor="middle" font-size="12" font-weight="bold" fill="#0f172a">20</text>
      <circle cx="70" cy="85" r="14" fill="#ffffff" stroke="#475569" stroke-width="1.5" />
      <text x="70" y="89" text-anchor="middle" font-size="12" font-weight="bold" fill="#0f172a">9</text>
      <text x="45" y="120" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(1)</text>
    </g>
    <!-- Shape 2 -->
    <g transform="translate(110, 0)">
      <polygon points="45,10 5,90 85,90" fill="#f1f5f9" stroke="#475569" stroke-width="2" />
      <circle cx="45" cy="38" r="16" fill="#ffffff" stroke="#475569" stroke-width="1.5" />
      <text x="45" y="43" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">38</text>
      <circle cx="20" cy="85" r="14" fill="#ffffff" stroke="#475569" stroke-width="1.5" />
      <text x="20" y="89" text-anchor="middle" font-size="12" font-weight="bold" fill="#0f172a">24</text>
      <circle cx="70" cy="85" r="14" fill="#ffffff" stroke="#475569" stroke-width="1.5" />
      <text x="70" y="89" text-anchor="middle" font-size="12" font-weight="bold" fill="#0f172a">11</text>
      <text x="45" y="120" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(2)</text>
    </g>
    <!-- Shape 3 -->
    <g transform="translate(220, 0)">
      <polygon points="45,10 5,90 85,90" fill="#f1f5f9" stroke="#475569" stroke-width="2" />
      <circle cx="45" cy="38" r="16" fill="#ffffff" stroke="#475569" stroke-width="1.5" />
      <text x="45" y="43" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">94</text>
      <circle cx="20" cy="85" r="14" fill="#ffffff" stroke="#475569" stroke-width="1.5" />
      <text x="20" y="89" text-anchor="middle" font-size="13" font-weight="bold" fill="#2563eb">?</text>
      <circle cx="70" cy="85" r="14" fill="#ffffff" stroke="#475569" stroke-width="1.5" />
      <text x="70" y="89" text-anchor="middle" font-size="12" font-weight="bold" fill="#0f172a">13</text>
      <text x="45" y="120" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(3)</text>
    </g>
  </g>
`, 340, 150);

// 2. Q7 (3, 10, 4 | 5, ?, 7 | 5, 9, 6)
const svgQ7 = svgWrapper(`
  <g transform="translate(15, 15)">
    <!-- Circle 1 -->
    <g transform="translate(0, 0)">
      <circle cx="45" cy="45" r="38" fill="#f8fafc" stroke="#475569" stroke-width="2" />
      <line x1="45" y1="7" x2="45" y2="83" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="3,3" />
      <line x1="7" y1="45" x2="83" y2="45" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="3,3" />
      <text x="25" y="38" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">3</text>
      <text x="65" y="38" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">4</text>
      <rect x="25" y="52" width="40" height="22" rx="4" fill="#475569" />
      <text x="45" y="68" text-anchor="middle" font-size="13" font-weight="bold" fill="#ffffff">10</text>
    </g>
    <!-- Circle 2 -->
    <g transform="translate(110, 0)">
      <circle cx="45" cy="45" r="38" fill="#f8fafc" stroke="#475569" stroke-width="2" />
      <line x1="45" y1="7" x2="45" y2="83" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="3,3" />
      <line x1="7" y1="45" x2="83" y2="45" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="3,3" />
      <text x="25" y="38" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">5</text>
      <text x="65" y="38" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">7</text>
      <rect x="25" y="52" width="40" height="22" rx="4" fill="#475569" />
      <text x="45" y="68" text-anchor="middle" font-size="14" font-weight="bold" fill="#ffffff">?</text>
    </g>
    <!-- Circle 3 -->
    <g transform="translate(220, 0)">
      <circle cx="45" cy="45" r="38" fill="#f8fafc" stroke="#475569" stroke-width="2" />
      <line x1="45" y1="7" x2="45" y2="83" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="3,3" />
      <line x1="7" y1="45" x2="83" y2="45" stroke="#94a3b8" stroke-width="1.2" stroke-dasharray="3,3" />
      <text x="25" y="38" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">5</text>
      <text x="65" y="38" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">6</text>
      <rect x="25" y="52" width="40" height="22" rx="4" fill="#475569" />
      <text x="45" y="68" text-anchor="middle" font-size="13" font-weight="bold" fill="#ffffff">9</text>
    </g>
  </g>
`, 340, 125);

// 3. Q8 (Letter-boxes)
const svgQ8 = svgWrapper(`
  <g transform="translate(15, 15)">
    <!-- Box 1 -->
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="70" height="75" rx="6" fill="#f8fafc" stroke="#475569" stroke-width="1.5"/>
      <text x="20" y="30" font-size="14" font-weight="bold" fill="#1e293b">C</text>
      <text x="50" y="30" font-size="14" font-weight="bold" fill="#1e293b">E</text>
      <line x1="5" y1="42" x2="65" y2="42" stroke="#cbd5e1" stroke-width="1"/>
      <text x="35" y="62" text-anchor="middle" font-size="13" font-weight="bold" fill="#334155">576</text>
    </g>
    <!-- Box 2 -->
    <g transform="translate(80, 0)">
      <rect x="0" y="0" width="70" height="75" rx="6" fill="#f8fafc" stroke="#475569" stroke-width="1.5"/>
      <text x="18" y="30" font-size="14" font-weight="bold" fill="#1e293b">M</text>
      <text x="50" y="30" font-size="14" font-weight="bold" fill="#1e293b">A</text>
      <line x1="5" y1="42" x2="65" y2="42" stroke="#cbd5e1" stroke-width="1"/>
      <text x="35" y="62" text-anchor="middle" font-size="13" font-weight="bold" fill="#334155">196</text>
    </g>
    <!-- Box 3 -->
    <g transform="translate(160, 0)">
      <rect x="0" y="0" width="70" height="75" rx="6" fill="#f8fafc" stroke="#475569" stroke-width="1.5"/>
      <text x="20" y="30" font-size="14" font-weight="bold" fill="#1e293b">E</text>
      <text x="48" y="30" font-size="14" font-weight="bold" fill="#1e293b">Q</text>
      <line x1="5" y1="42" x2="65" y2="42" stroke="#cbd5e1" stroke-width="1"/>
      <text x="35" y="62" text-anchor="middle" font-size="13" font-weight="bold" fill="#334155">484</text>
    </g>
    <!-- Box 4 -->
    <g transform="translate(240, 0)">
      <rect x="0" y="0" width="70" height="75" rx="6" fill="#f8fafc" stroke="#475569" stroke-width="1.5"/>
      <text x="20" y="30" font-size="14" font-weight="bold" fill="#1e293b">A</text>
      <text x="48" y="30" font-size="14" font-weight="bold" fill="#1e293b">W</text>
      <line x1="5" y1="42" x2="65" y2="42" stroke="#cbd5e1" stroke-width="1"/>
      <text x="35" y="63" text-anchor="middle" font-size="15" font-weight="bold" fill="#2563eb">?</text>
    </g>
  </g>
`, 340, 105);

// 4. Q9 (Wheel 4 segments)
const svgQ9 = svgWrapper(`
  <g transform="translate(115, 15)">
    <circle cx="55" cy="55" r="50" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
    <line x1="5" y1="55" x2="105" y2="55" stroke="#475569" stroke-width="1.5"/>
    <line x1="55" y1="5" x2="55" y2="105" stroke="#475569" stroke-width="1.5"/>
    <circle cx="55" cy="55" r="16" fill="#f1f5f9" stroke="#475569" stroke-width="1.2"/>
    <text x="32" y="38" font-size="14" font-weight="bold" fill="#1e293b">4</text>
    <text x="78" y="38" font-size="14" font-weight="bold" fill="#1e293b">9</text>
    <text x="78" y="82" font-size="14" font-weight="bold" fill="#1e293b">19</text>
    <text x="32" y="82" font-size="14" font-weight="bold" fill="#2563eb">?</text>
  </g>
`, 340, 140);

// 5. Q10
const svgQ10 = svgWrapper(`
  <g transform="translate(40, 15)">
    <!-- Wheel 1 -->
    <g transform="translate(0, 0)">
      <circle cx="55" cy="55" r="45" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
      <circle cx="55" cy="55" r="20" fill="#ffffff" stroke="#475569" stroke-width="1.2"/>
      <text x="55" y="60" text-anchor="middle" font-size="13" font-weight="bold" fill="#1e293b">32</text>
      <text x="55" y="24" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">5</text>
      <text x="88" y="59" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">21</text>
      <text x="55" y="93" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">7</text>
      <text x="22" y="59" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">-</text>
    </g>
    <!-- Wheel 2 -->
    <g transform="translate(150, 0)">
      <circle cx="55" cy="55" r="45" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
      <circle cx="55" cy="55" r="20" fill="#ffffff" stroke="#475569" stroke-width="1.2"/>
      <text x="55" y="60" text-anchor="middle" font-size="15" font-weight="bold" fill="#2563eb">?</text>
      <text x="55" y="24" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">13</text>
      <text x="88" y="59" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">5</text>
      <text x="55" y="93" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">11</text>
      <text x="22" y="59" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">-</text>
    </g>
  </g>
`, 340, 140);

// 6. Q11 (Triangles: 24)
const svgQ11 = svgWrapper(`
  <g transform="translate(70, 15)">
    <polygon points="100,10 10,140 190,140" fill="#f8fafc" stroke="#2563eb" stroke-width="2.2"/>
    <line x1="77.5" y1="42.5" x2="122.5" y2="42.5" stroke="#2563eb" stroke-width="1.6"/>
    <line x1="55" y1="75" x2="145" y2="75" stroke="#2563eb" stroke-width="1.6"/>
    <line x1="32.5" y1="107.5" x2="167.5" y2="107.5" stroke="#2563eb" stroke-width="1.6"/>
    <line x1="100" y1="10" x2="70" y2="140" stroke="#2563eb" stroke-width="1.6"/>
    <line x1="100" y1="10" x2="130" y2="140" stroke="#2563eb" stroke-width="1.6"/>
    <text x="100" y="160" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-11: કુલ ત્રિકોણ ગણો</text>
  </g>
`, 340, 180);

// 7. Q12 (Triangles: 44)
const svgQ12 = svgWrapper(`
  <g transform="translate(95, 15)">
    <rect x="0" y="0" width="150" height="150" fill="#f8fafc" stroke="#2563eb" stroke-width="2.2"/>
    <line x1="75" y1="0" x2="75" y2="150" stroke="#2563eb" stroke-width="1.8"/>
    <line x1="0" y1="75" x2="150" y2="75" stroke="#2563eb" stroke-width="1.8"/>
    <line x1="0" y1="0" x2="75" y2="75" stroke="#2563eb" stroke-width="1.4"/>
    <line x1="75" y1="0" x2="0" y2="75" stroke="#2563eb" stroke-width="1.4"/>
    <line x1="75" y1="0" x2="150" y2="75" stroke="#2563eb" stroke-width="1.4"/>
    <line x1="150" y1="0" x2="75" y2="75" stroke="#2563eb" stroke-width="1.4"/>
    <line x1="0" y1="75" x2="75" y2="150" stroke="#2563eb" stroke-width="1.4"/>
    <line x1="75" y1="75" x2="0" y2="150" stroke="#2563eb" stroke-width="1.4"/>
    <line x1="75" y1="75" x2="150" y2="150" stroke="#2563eb" stroke-width="1.4"/>
    <line x1="150" y1="75" x2="75" y2="150" stroke="#2563eb" stroke-width="1.4"/>
    <text x="75" y="172" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-12 (2×2 ચોરસ ગ્રીડ)</text>
  </g>
`, 340, 190);

// 8. Q13 (Triangles: 60)
const svgQ13 = svgWrapper(`
  <g transform="translate(60, 15)">
    <polygon points="110,10 10,140 210,140" fill="#f8fafc" stroke="#2563eb" stroke-width="2.2"/>
    <line x1="85" y1="42.5" x2="135" y2="42.5" stroke="#2563eb" stroke-width="1.5"/>
    <line x1="60" y1="75" x2="160" y2="75" stroke="#2563eb" stroke-width="1.5"/>
    <line x1="35" y1="107.5" x2="185" y2="107.5" stroke="#2563eb" stroke-width="1.5"/>
    <line x1="110" y1="10" x2="50" y2="140" stroke="#2563eb" stroke-width="1.5"/>
    <line x1="110" y1="10" x2="90" y2="140" stroke="#2563eb" stroke-width="1.5"/>
    <line x1="110" y1="10" x2="130" y2="140" stroke="#2563eb" stroke-width="1.5"/>
    <line x1="110" y1="10" x2="170" y2="140" stroke="#2563eb" stroke-width="1.5"/>
    <text x="110" y="165" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-13: કુલ ત્રિકોણ ગણો</text>
  </g>
`, 340, 185);

// 9. Q14 (Triangles: 16)
const svgQ14 = svgWrapper(`
  <g transform="translate(105, 15)">
    <rect x="0" y="0" width="130" height="130" fill="#f8fafc" stroke="#2563eb" stroke-width="2.2"/>
    <line x1="0" y1="0" x2="130" y2="130" stroke="#2563eb" stroke-width="1.8"/>
    <line x1="130" y1="0" x2="0" y2="130" stroke="#2563eb" stroke-width="1.8"/>
    <line x1="65" y1="0" x2="65" y2="130" stroke="#2563eb" stroke-width="1.8"/>
    <line x1="0" y1="65" x2="130" y2="65" stroke="#2563eb" stroke-width="1.8"/>
    <text x="65" y="155" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-14: કુલ ત્રિકોણ ગણો</text>
  </g>
`, 340, 175);

// 10. Q15 (Squares: Fig 1 vs Fig 2)
const svgQ15 = svgWrapper(`
  <g transform="translate(30, 20)">
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="105" height="105" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
      <line x1="35" y1="0" x2="35" y2="105" stroke="#475569" stroke-width="1.5"/>
      <line x1="70" y1="0" x2="70" y2="105" stroke="#475569" stroke-width="1.5"/>
      <line x1="0" y1="35" x2="105" y2="35" stroke="#475569" stroke-width="1.5"/>
      <line x1="0" y1="70" x2="105" y2="70" stroke="#475569" stroke-width="1.5"/>
      <text x="52.5" y="125" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-1 (3×3)</text>
    </g>
    <g transform="translate(160, 0)">
      <rect x="0" y="17.5" width="105" height="70" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
      <line x1="35" y1="17.5" x2="35" y2="87.5" stroke="#475569" stroke-width="1.5"/>
      <line x1="70" y1="17.5" x2="70" y2="87.5" stroke="#475569" stroke-width="1.5"/>
      <line x1="0" y1="52.5" x2="105" y2="52.5" stroke="#475569" stroke-width="1.5"/>
      <text x="52.5" y="125" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-2 (2×3)</text>
    </g>
  </g>
`, 340, 160);

// 11. Q16
const svgQ16 = svgWrapper(`
  <g transform="translate(100, 15)">
    <rect x="40" y="0" width="40" height="120" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
    <rect x="0" y="40" width="120" height="40" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
    <line x1="40" y1="40" x2="40" y2="80" stroke="#475569" stroke-width="1.5"/>
    <line x1="80" y1="40" x2="80" y2="80" stroke="#475569" stroke-width="1.5"/>
    <line x1="40" y1="40" x2="80" y2="40" stroke="#475569" stroke-width="1.5"/>
    <line x1="40" y1="80" x2="80" y2="80" stroke="#475569" stroke-width="1.5"/>
    <text x="60" y="145" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-16: ચોરસની સંખ્યા ગણો</text>
  </g>
`, 340, 170);

// 12. Q17
const svgQ17 = svgWrapper(`
  <g transform="translate(95, 15)">
    <rect x="0" y="0" width="140" height="90" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
    <line x1="45" y1="0" x2="45" y2="90" stroke="#475569" stroke-width="1.5"/>
    <line x1="95" y1="0" x2="95" y2="90" stroke="#475569" stroke-width="1.5"/>
    <line x1="0" y1="45" x2="140" y2="45" stroke="#475569" stroke-width="1.5"/>
    <rect x="25" y="20" width="50" height="50" fill="#f1f5f9" stroke="#475569" stroke-width="1.8"/>
    <text x="70" y="125" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-17: કુલ ચોરસ ગણો</text>
  </g>
`, 340, 150);

// 13. Q18
const svgQ18 = svgWrapper(`
  <g transform="translate(90, 15)">
    <rect x="0" y="0" width="160" height="90" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
    <line x1="50" y1="0" x2="50" y2="90" stroke="#475569" stroke-width="1.5"/>
    <line x1="110" y1="0" x2="110" y2="90" stroke="#475569" stroke-width="1.5"/>
    <line x1="0" y1="45" x2="160" y2="45" stroke="#475569" stroke-width="1.5"/>
    <text x="80" y="125" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-18: લંબચોરસની સંખ્યા ગણો</text>
  </g>
`, 340, 150);

// 14. Q19
const svgQ19 = svgWrapper(`
  <g transform="translate(80, 15)">
    <rect x="0" y="0" width="180" height="90" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
    <line x1="45" y1="0" x2="45" y2="90" stroke="#475569" stroke-width="1.5"/>
    <line x1="90" y1="0" x2="90" y2="90" stroke="#475569" stroke-width="1.5"/>
    <line x1="135" y1="0" x2="135" y2="90" stroke="#475569" stroke-width="1.5"/>
    <line x1="0" y1="45" x2="180" y2="45" stroke="#475569" stroke-width="1.5"/>
    <text x="90" y="125" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-19: લંબચોરસની સંખ્યા ગણો</text>
  </g>
`, 340, 150);

// 15. Q20
const svgQ20 = svgWrapper(`
  <g transform="translate(85, 15)">
    <rect x="0" y="0" width="170" height="110" fill="#f8fafc" stroke="#475569" stroke-width="2"/>
    <line x1="56.6" y1="0" x2="56.6" y2="110" stroke="#475569" stroke-width="1.5"/>
    <line x1="113.3" y1="0" x2="113.3" y2="110" stroke="#475569" stroke-width="1.5"/>
    <line x1="0" y1="55" x2="170" y2="55" stroke="#475569" stroke-width="1.5"/>
    <text x="85" y="140" text-anchor="middle" font-size="12" font-weight="bold" fill="#334155">આકૃતિ-20 (2×3 ગ્રીડ: ચોરસ સિવાયના લંબચોરસ)</text>
  </g>
`, 340, 165);

// 16. Q31 (Odd figure out: NEUTRAL STYLING FOR ALL OPTIONS)
const svgQ31 = svgWrapper(`
  <g transform="translate(15, 20)">
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <polygon points="32.5,15 12,50 53,50" fill="none" stroke="#2563eb" stroke-width="1.8"/>
      <circle cx="32.5" cy="30" r="2.5" fill="#334155"/>
      <circle cx="24" cy="45" r="2.5" fill="#334155"/>
      <circle cx="41" cy="45" r="2.5" fill="#334155"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(A)</text>
    </g>
    <g transform="translate(75, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <rect x="15" y="15" width="35" height="35" fill="none" stroke="#2563eb" stroke-width="1.8"/>
      <circle cx="23" cy="23" r="2.5" fill="#334155"/>
      <circle cx="42" cy="23" r="2.5" fill="#334155"/>
      <circle cx="23" cy="42" r="2.5" fill="#334155"/>
      <circle cx="42" cy="42" r="2.5" fill="#334155"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(B)</text>
    </g>
    <g transform="translate(150, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <polygon points="32.5,12 52,26 44,50 21,50 13,26" fill="none" stroke="#2563eb" stroke-width="1.8"/>
      <circle cx="32.5" cy="24" r="2.5" fill="#334155"/>
      <circle cx="23" cy="33" r="2.5" fill="#334155"/>
      <circle cx="42" cy="33" r="2.5" fill="#334155"/>
      <circle cx="26" cy="44" r="2.5" fill="#334155"/>
      <circle cx="39" cy="44" r="2.5" fill="#334155"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(C)</text>
    </g>
    <g transform="translate(225, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <polygon points="32.5,12 52,23 52,43 32.5,54 13,43 13,23" fill="none" stroke="#2563eb" stroke-width="1.8"/>
      <circle cx="25" cy="28" r="2.5" fill="#334155"/>
      <circle cx="40" cy="28" r="2.5" fill="#334155"/>
      <circle cx="25" cy="39" r="2.5" fill="#334155"/>
      <circle cx="40" cy="39" r="2.5" fill="#334155"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(D)</text>
    </g>
  </g>
`, 320, 115);

// 17. Q32
const svgQ32 = svgWrapper(`
  <g transform="translate(15, 20)">
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <circle cx="32.5" cy="32.5" r="20" fill="none" stroke="#2563eb" stroke-width="1.8"/>
      <line x1="32.5" y1="12.5" x2="32.5" y2="52.5" stroke="#2563eb" stroke-width="1.4"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(A)</text>
    </g>
    <g transform="translate(75, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <rect x="15" y="15" width="35" height="35" fill="none" stroke="#2563eb" stroke-width="1.8"/>
      <line x1="32.5" y1="15" x2="32.5" y2="50" stroke="#2563eb" stroke-width="1.4"/>
      <line x1="15" y1="32.5" x2="50" y2="32.5" stroke="#2563eb" stroke-width="1.4"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(B)</text>
    </g>
    <g transform="translate(150, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <polygon points="32.5,12 12,50 53,50" fill="none" stroke="#2563eb" stroke-width="1.8"/>
      <line x1="20" y1="25" x2="45" y2="50" stroke="#2563eb" stroke-width="1.5"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(C)</text>
    </g>
    <g transform="translate(225, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <circle cx="32.5" cy="32.5" r="20" fill="none" stroke="#2563eb" stroke-width="1.8"/>
      <line x1="32.5" y1="12.5" x2="32.5" y2="52.5" stroke="#2563eb" stroke-width="1.2"/>
      <line x1="12.5" y1="32.5" x2="52.5" y2="32.5" stroke="#2563eb" stroke-width="1.2"/>
      <line x1="18.3" y1="18.3" x2="46.7" y2="46.7" stroke="#2563eb" stroke-width="1.2"/>
      <line x1="46.7" y1="18.3" x2="18.3" y2="46.7" stroke="#2563eb" stroke-width="1.2"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(D)</text>
    </g>
  </g>
`, 320, 115);

// 18. Q33
const svgQ33 = svgWrapper(`
  <g transform="translate(15, 20)">
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 22 18 L 22 45 L 45 45" fill="none" stroke="#2563eb" stroke-width="3.5" stroke-linecap="round"/>
      <circle cx="45" cy="45" r="3.5" fill="#2563eb"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(A)</text>
    </g>
    <g transform="translate(75, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 43 18 L 43 45 L 20 45" fill="none" stroke="#2563eb" stroke-width="3.5" stroke-linecap="round"/>
      <circle cx="20" cy="45" r="3.5" fill="#2563eb"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(B)</text>
    </g>
    <g transform="translate(150, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 45 22 L 18 22 L 18 45" fill="none" stroke="#2563eb" stroke-width="3.5" stroke-linecap="round"/>
      <circle cx="18" cy="45" r="3.5" fill="#2563eb"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(C)</text>
    </g>
    <g transform="translate(225, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 43 45 L 43 18 L 20 18" fill="none" stroke="#2563eb" stroke-width="3.5" stroke-linecap="round"/>
      <circle cx="20" cy="18" r="3.5" fill="#2563eb"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(D)</text>
    </g>
  </g>
`, 320, 115);

// 19. Q34
const svgQ34 = svgWrapper(`
  <g transform="translate(15, 20)">
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 20 20 L 20 45 L 45 45 L 45 20" fill="none" stroke="#2563eb" stroke-width="2.5" stroke-linecap="round"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(A)</text>
    </g>
    <g transform="translate(75, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 45 20 L 20 20 L 20 33 L 45 33 L 45 45 L 20 45" fill="none" stroke="#2563eb" stroke-width="2.5" stroke-linecap="round"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(B)</text>
    </g>
    <g transform="translate(150, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 20 20 L 32.5 45 L 45 20" fill="none" stroke="#2563eb" stroke-width="2.5" stroke-linecap="round"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(C)</text>
    </g>
    <g transform="translate(225, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <circle cx="32.5" cy="32.5" r="16" fill="none" stroke="#2563eb" stroke-width="2.5"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(D)</text>
    </g>
  </g>
`, 320, 115);

// 20. Q35
const svgQ35 = svgWrapper(`
  <g transform="translate(15, 20)">
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 20 32.5 A 14 14 0 1 1 45 32.5" fill="none" stroke="#2563eb" stroke-width="2.2"/>
      <polygon points="45,28 49,36 41,36" fill="#2563eb"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(A)</text>
    </g>
    <g transform="translate(75, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 32.5 18 A 14 14 0 1 1 32.5 47" fill="none" stroke="#2563eb" stroke-width="2.2"/>
      <polygon points="36,47 28,47 32,52" fill="#2563eb"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(B)</text>
    </g>
    <g transform="translate(150, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 45 32.5 A 14 14 0 1 0 20 32.5" fill="none" stroke="#2563eb" stroke-width="2.2"/>
      <polygon points="20,28 16,36 24,36" fill="#2563eb"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(C)</text>
    </g>
    <g transform="translate(225, 0)">
      <rect x="0" y="0" width="65" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
      <path d="M 32.5 47 A 14 14 0 1 1 32.5 18" fill="none" stroke="#2563eb" stroke-width="2.2"/>
      <polygon points="29,18 37,18 33,13" fill="#2563eb"/>
      <text x="32.5" y="70" text-anchor="middle" font-size="11" font-weight="bold" fill="#475569">(D)</text>
    </g>
  </g>
`, 320, 115);

// 21. Q46 (Mirror: ALL 4 OPTIONS IDENTICALLY STYLED)
const svgQ46 = svgWrapper(`
  <g transform="translate(15, 15)">
    <!-- Problem Figure -->
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="60" height="75" rx="6" fill="#eff6ff" stroke="#3b82f6" stroke-width="2"/>
      <line x1="15" y1="37" x2="45" y2="37" stroke="#1d4ed8" stroke-width="2.5"/>
      <polygon points="45,30 45,44 53,37" fill="#1d4ed8"/>
      <circle cx="15" cy="37" r="4" fill="#1d4ed8"/>
      <circle cx="30" cy="23" r="3" fill="#64748b"/>
      <text x="30" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#1e3a8a">પ્રશ્ન</text>
    </g>
    <!-- Mirror line -->
    <line x1="72" y1="5" x2="72" y2="80" stroke="#94a3b8" stroke-width="2" stroke-dasharray="3,3"/>
    <text x="72" y="93" text-anchor="middle" font-size="9" fill="#64748b">દર્પણ</text>
    <!-- Options A, B, C, D (100% identical styling) -->
    <g transform="translate(85, 0)">
      <!-- A -->
      <g transform="translate(0, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <line x1="10" y1="37" x2="38" y2="37" stroke="#475569" stroke-width="2"/>
        <polygon points="38,32 38,42 44,37" fill="#475569"/>
        <circle cx="10" cy="37" r="3" fill="#475569"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(A)</text>
      </g>
      <!-- B -->
      <g transform="translate(56, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <line x1="38" y1="37" x2="12" y2="37" stroke="#475569" stroke-width="2"/>
        <polygon points="12,30 12,44 5,37" fill="#475569"/>
        <circle cx="38" cy="37" r="3" fill="#475569"/>
        <circle cx="23" cy="23" r="3" fill="#64748b"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(B)</text>
      </g>
      <!-- C -->
      <g transform="translate(112, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <line x1="38" y1="37" x2="12" y2="37" stroke="#475569" stroke-width="2"/>
        <polygon points="12,32 12,42 6,37" fill="#475569"/>
        <circle cx="38" cy="37" r="3" fill="#475569"/>
        <circle cx="23" cy="51" r="3" fill="#64748b"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(C)</text>
      </g>
      <!-- D -->
      <g transform="translate(168, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <line x1="25" y1="15" x2="25" y2="45" stroke="#475569" stroke-width="2"/>
        <polygon points="20,15 30,15 25,9" fill="#475569"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(D)</text>
      </g>
    </g>
  </g>
`, 320, 115);

// 22. Q47 (Mirror: ALL 4 OPTIONS IDENTICALLY STYLED)
const svgQ47 = svgWrapper(`
  <g transform="translate(15, 15)">
    <!-- Problem Figure -->
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="60" height="75" rx="6" fill="#eff6ff" stroke="#3b82f6" stroke-width="2"/>
      <line x1="20" y1="15" x2="20" y2="55" stroke="#1d4ed8" stroke-width="2.5"/>
      <polygon points="20,15 48,27 20,39" fill="#3b82f6"/>
      <text x="30" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#1e3a8a">પ્રશ્ન</text>
    </g>
    <!-- Mirror line -->
    <line x1="72" y1="5" x2="72" y2="80" stroke="#94a3b8" stroke-width="2" stroke-dasharray="3,3"/>
    <text x="72" y="93" text-anchor="middle" font-size="9" fill="#64748b">દર્પણ</text>
    <!-- Options (All neutral) -->
    <g transform="translate(85, 0)">
      <g transform="translate(0, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <line x1="15" y1="15" x2="15" y2="55" stroke="#475569" stroke-width="2"/>
        <polygon points="15,15 38,27 15,39" fill="#64748b"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(A)</text>
      </g>
      <g transform="translate(56, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <line x1="25" y1="55" x2="25" y2="15" stroke="#475569" stroke-width="2"/>
        <polygon points="25,55 45,43 25,31" fill="#64748b"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(B)</text>
      </g>
      <g transform="translate(112, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <line x1="38" y1="15" x2="38" y2="55" stroke="#475569" stroke-width="2"/>
        <polygon points="38,15 10,27 38,39" fill="#64748b"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(C)</text>
      </g>
      <g transform="translate(168, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <circle cx="25" cy="35" r="14" fill="none" stroke="#475569" stroke-width="1.8"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(D)</text>
      </g>
    </g>
  </g>
`, 320, 115);

// 23. Q48 (Mirror: ALL 4 OPTIONS IDENTICALLY STYLED)
const svgQ48 = svgWrapper(`
  <g transform="translate(15, 15)">
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="60" height="75" rx="6" fill="#eff6ff" stroke="#3b82f6" stroke-width="2"/>
      <circle cx="30" cy="35" r="18" fill="none" stroke="#1d4ed8" stroke-width="2"/>
      <line x1="30" y1="35" x2="44" y2="35" stroke="#1d4ed8" stroke-width="2"/>
      <line x1="30" y1="35" x2="30" y2="20" stroke="#1d4ed8" stroke-width="2"/>
      <text x="30" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#1e3a8a">પ્રશ્ન (3:00)</text>
    </g>
    <line x1="72" y1="5" x2="72" y2="80" stroke="#94a3b8" stroke-width="2" stroke-dasharray="3,3"/>
    <g transform="translate(85, 0)">
      <!-- A -->
      <g transform="translate(0, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <circle cx="25" cy="35" r="16" fill="none" stroke="#475569" stroke-width="1.8"/>
        <line x1="25" y1="35" x2="11" y2="35" stroke="#475569" stroke-width="1.8"/>
        <line x1="25" y1="35" x2="25" y2="21" stroke="#475569" stroke-width="1.8"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(A)</text>
      </g>
      <!-- B -->
      <g transform="translate(56, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <circle cx="25" cy="35" r="16" fill="none" stroke="#475569" stroke-width="1.8"/>
        <line x1="25" y1="35" x2="39" y2="35" stroke="#475569" stroke-width="1.8"/>
        <line x1="25" y1="35" x2="25" y2="21" stroke="#475569" stroke-width="1.8"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(B)</text>
      </g>
      <!-- C -->
      <g transform="translate(112, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <circle cx="25" cy="35" r="16" fill="none" stroke="#475569" stroke-width="1.8"/>
        <line x1="25" y1="35" x2="25" y2="49" stroke="#475569" stroke-width="1.8"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(C)</text>
      </g>
      <!-- D -->
      <g transform="translate(168, 0)">
        <rect x="0" y="0" width="50" height="75" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <circle cx="25" cy="35" r="16" fill="none" stroke="#475569" stroke-width="1.8"/>
        <line x1="13" y1="35" x2="37" y2="35" stroke="#475569" stroke-width="1.8"/>
        <text x="25" y="68" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(D)</text>
      </g>
    </g>
  </g>
`, 320, 115);

// 24. Q53 (Pattern completion: ALL OPTIONS NEUTRAL)
const svgQ53 = svgWrapper(`
  <g transform="translate(15, 15)">
    <!-- 2x2 Grid -->
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="80" height="80" fill="#ffffff" stroke="#2563eb" stroke-width="2"/>
      <line x1="40" y1="0" x2="40" y2="80" stroke="#2563eb" stroke-width="1.5"/>
      <line x1="0" y1="40" x2="80" y2="40" stroke="#2563eb" stroke-width="1.5"/>
      <circle cx="20" cy="20" r="10" fill="#2563eb"/>
      <circle cx="60" cy="20" r="10" fill="#2563eb"/>
      <circle cx="20" cy="60" r="10" fill="#2563eb"/>
      <text x="60" y="67" text-anchor="middle" font-size="18" font-weight="bold" fill="#475569">?</text>
      <text x="40" y="96" text-anchor="middle" font-size="11" font-weight="bold" fill="#334155">પેટર્ન પૂર્ણ કરો</text>
    </g>
    <!-- Options (Neutral) -->
    <g transform="translate(100, 5)">
      <g transform="translate(0, 0)">
        <rect x="0" y="0" width="45" height="45" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <rect x="12" y="12" width="20" height="20" fill="#475569"/>
        <text x="22.5" y="60" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(A)</text>
      </g>
      <g transform="translate(55, 0)">
        <rect x="0" y="0" width="45" height="45" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <circle cx="22.5" cy="22.5" r="10" fill="#2563eb"/>
        <text x="22.5" y="60" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(B)</text>
      </g>
      <g transform="translate(110, 0)">
        <rect x="0" y="0" width="45" height="45" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <polygon points="22.5,10 12,32 33,32" fill="#475569"/>
        <text x="22.5" y="60" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(C)</text>
      </g>
      <g transform="translate(165, 0)">
        <rect x="0" y="0" width="45" height="45" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <line x1="10" y1="10" x2="35" y2="35" stroke="#475569" stroke-width="2.5"/>
        <text x="22.5" y="60" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(D)</text>
      </g>
    </g>
  </g>
`, 330, 120);

// 25. Q54 (Concentric arcs: ALL OPTIONS NEUTRAL)
const svgQ54 = svgWrapper(`
  <g transform="translate(20, 15)">
    <g transform="translate(0, 0)">
      <rect x="0" y="0" width="80" height="80" fill="#ffffff" stroke="#2563eb" stroke-width="2"/>
      <line x1="40" y1="0" x2="40" y2="80" stroke="#2563eb" stroke-width="1.5"/>
      <line x1="0" y1="40" x2="80" y2="40" stroke="#2563eb" stroke-width="1.5"/>
      <path d="M 40 10 A 30 30 0 0 0 10 40" fill="none" stroke="#2563eb" stroke-width="2.5"/>
      <path d="M 40 10 A 30 30 0 0 1 70 40" fill="none" stroke="#2563eb" stroke-width="2.5"/>
      <path d="M 10 40 A 30 30 0 0 0 40 70" fill="none" stroke="#2563eb" stroke-width="2.5"/>
      <text x="60" y="65" text-anchor="middle" font-size="18" font-weight="bold" fill="#475569">?</text>
      <text x="40" y="96" text-anchor="middle" font-size="11" font-weight="bold" fill="#334155">પેટર્ન પૂર્ણ કરો</text>
    </g>
    <!-- Options (Neutral) -->
    <g transform="translate(95, 5)">
      <g transform="translate(0, 0)">
        <rect x="0" y="0" width="45" height="45" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <line x1="10" y1="10" x2="35" y2="35" stroke="#475569" stroke-width="2"/>
        <text x="22.5" y="60" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(A)</text>
      </g>
      <g transform="translate(55, 0)">
        <rect x="0" y="0" width="45" height="45" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <path d="M 35 10 A 25 25 0 0 1 10 35" fill="none" stroke="#2563eb" stroke-width="2.5"/>
        <text x="22.5" y="60" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(B)</text>
      </g>
      <g transform="translate(110, 0)">
        <rect x="0" y="0" width="45" height="45" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <circle cx="22.5" cy="22.5" r="10" fill="none" stroke="#475569" stroke-width="2"/>
        <text x="22.5" y="60" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(C)</text>
      </g>
      <g transform="translate(165, 0)">
        <rect x="0" y="0" width="45" height="45" rx="6" fill="#ffffff" stroke="#94a3b8" stroke-width="1.2"/>
        <rect x="10" y="10" width="25" height="25" fill="none" stroke="#475569" stroke-width="2"/>
        <text x="22.5" y="60" text-anchor="middle" font-size="10" font-weight="bold" fill="#475569">(D)</text>
      </g>
    </g>
  </g>
`, 330, 120);

// 26. Q55 (Polygon star vertices)
const svgQ55 = svgWrapper(`
  <g transform="translate(15, 15)">
    <g transform="translate(0, 0)">
      <polygon points="25,10 10,40 40,40" fill="#f8fafc" stroke="#475569" stroke-width="1.8"/>
      <text x="25" y="55" text-anchor="middle" font-size="10" font-weight="bold" fill="#334155">3 ખૂણા</text>
    </g>
    <text x="60" y="32" font-size="16" font-weight="bold" fill="#94a3b8">→</text>
    <g transform="translate(75, 0)">
      <rect x="10" y="10" width="30" height="30" fill="#f8fafc" stroke="#475569" stroke-width="1.8"/>
      <text x="25" y="55" text-anchor="middle" font-size="10" font-weight="bold" fill="#334155">4 ખૂણા</text>
    </g>
    <text x="135" y="32" font-size="16" font-weight="bold" fill="#94a3b8">→</text>
    <g transform="translate(150, 0)">
      <polygon points="25,8 42,20 35,40 15,40 8,20" fill="#f8fafc" stroke="#475569" stroke-width="1.8"/>
      <text x="25" y="55" text-anchor="middle" font-size="10" font-weight="bold" fill="#334155">5 ખૂણા</text>
    </g>
    <text x="210" y="32" font-size="16" font-weight="bold" fill="#94a3b8">→</text>
    <g transform="translate(225, 0)">
      <rect x="5" y="5" width="40" height="40" rx="6" fill="#f8fafc" stroke="#475569" stroke-width="1.8"/>
      <text x="25" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#2563eb">?</text>
      <text x="25" y="55" text-anchor="middle" font-size="10" font-weight="bold" fill="#334155">(?)</text>
    </g>
  </g>
`, 320, 85);

// 27. Q56 & Q57 (Overlapping Shapes Venn: Circle, Rectangle, Triangle - ALL NUMBERS NEUTRAL)
const svgQ56_57 = svgWrapper(`
  <g transform="translate(45, 10)">
    <!-- Rectangle (Blue) -->
    <rect x="40" y="40" width="160" height="70" rx="4" fill="none" stroke="#2563eb" stroke-width="2.2"/>
    <text x="195" y="35" font-size="10" font-weight="bold" fill="#2563eb">લંબચોરસ</text>
    <!-- Circle (Green) -->
    <circle cx="95" cy="75" r="45" fill="none" stroke="#16a34a" stroke-width="2.2"/>
    <text x="35" y="25" font-size="10" font-weight="bold" fill="#16a34a">વર્તુળ</text>
    <!-- Triangle (Purple) -->
    <polygon points="135,15 75,120 195,120" fill="none" stroke="#9333ea" stroke-width="2.2"/>
    <text x="145" y="10" font-size="10" font-weight="bold" fill="#9333ea">ત્રિકોણ</text>
    <!-- All numbers neutrally rendered -->
    <text x="65" y="70" font-size="13" font-weight="bold" fill="#0f172a">1</text>
    <text x="180" y="75" font-size="13" font-weight="bold" fill="#0f172a">3</text>
    <text x="136" y="34" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">5</text>
    <text x="75" y="58" font-size="12" font-weight="bold" fill="#0f172a">12</text>
    <text x="95" y="105" font-size="12" font-weight="bold" fill="#0f172a">13</text>
    <text x="160" y="75" font-size="12" font-weight="bold" fill="#0f172a">17</text>
    <text x="118" y="77" text-anchor="middle" font-size="13" font-weight="bold" fill="#0f172a">8</text>
  </g>
`, 340, 150);

// 28. Q58 (Figure analogy: ALL OPTIONS NEUTRAL)
const svgQ58 = svgWrapper(`
  <g transform="translate(15, 15)">
    <!-- Pair 1 -->
    <g transform="translate(0, 0)">
      <rect x="10" y="10" width="40" height="40" fill="none" stroke="#475569" stroke-width="1.8"/>
    </g>
    <text x="65" y="35" font-size="16" font-weight="bold" fill="#64748b">:</text>
    <g transform="translate(80, 0)">
      <rect x="10" y="10" width="40" height="40" fill="none" stroke="#475569" stroke-width="1.8"/>
      <circle cx="30" cy="30" r="14" fill="none" stroke="#475569" stroke-width="1.5"/>
    </g>
    <text x="135" y="35" font-size="16" font-weight="bold" fill="#64748b">::</text>
    <!-- Pair 2 -->
    <g transform="translate(150, 0)">
      <polygon points="30,10 10,48 50,48" fill="none" stroke="#475569" stroke-width="1.8"/>
    </g>
    <text x="215" y="35" font-size="16" font-weight="bold" fill="#64748b">:</text>
    <!-- Box with ? -->
    <g transform="translate(230, 0)">
      <rect x="5" y="5" width="48" height="48" rx="6" fill="#f8fafc" stroke="#475569" stroke-width="1.8"/>
      <text x="29" y="36" text-anchor="middle" font-size="20" font-weight="bold" fill="#2563eb">?</text>
    </g>
  </g>
`, 320, 80);

// 29. Q59 (Analogy: Concentric shapes: ALL NEUTRAL)
const svgQ59 = svgWrapper(`
  <g transform="translate(15, 15)">
    <g transform="translate(0, 0)">
      <circle cx="30" cy="30" r="18" fill="none" stroke="#475569" stroke-width="1.8"/>
    </g>
    <text x="65" y="35" font-size="16" font-weight="bold" fill="#64748b">:</text>
    <g transform="translate(80, 0)">
      <circle cx="30" cy="30" r="18" fill="none" stroke="#475569" stroke-width="1.8"/>
      <circle cx="30" cy="30" r="9" fill="none" stroke="#475569" stroke-width="1.8"/>
    </g>
    <text x="135" y="35" font-size="16" font-weight="bold" fill="#64748b">::</text>
    <g transform="translate(150, 0)">
      <rect x="12" y="12" width="36" height="36" fill="none" stroke="#475569" stroke-width="1.8"/>
    </g>
    <text x="215" y="35" font-size="16" font-weight="bold" fill="#64748b">:</text>
    <g transform="translate(230, 0)">
      <rect x="5" y="5" width="48" height="48" rx="6" fill="#f8fafc" stroke="#475569" stroke-width="1.8"/>
      <text x="29" y="36" text-anchor="middle" font-size="20" font-weight="bold" fill="#2563eb">?</text>
    </g>
  </g>
`, 320, 80);

// 30. Q60 (Analogy: +1 side: ALL NEUTRAL)
const svgQ60 = svgWrapper(`
  <g transform="translate(15, 15)">
    <g transform="translate(0, 0)">
      <polygon points="30,12 12,45 48,45" fill="none" stroke="#475569" stroke-width="1.8"/>
    </g>
    <text x="65" y="35" font-size="16" font-weight="bold" fill="#64748b">:</text>
    <g transform="translate(80, 0)">
      <rect x="12" y="12" width="36" height="36" fill="none" stroke="#475569" stroke-width="1.8"/>
    </g>
    <text x="135" y="35" font-size="16" font-weight="bold" fill="#64748b">::</text>
    <g transform="translate(150, 0)">
      <polygon points="30,12 48,25 41,45 19,45 12,25" fill="none" stroke="#475569" stroke-width="1.8"/>
    </g>
    <text x="215" y="35" font-size="16" font-weight="bold" fill="#64748b">:</text>
    <g transform="translate(230, 0)">
      <rect x="5" y="5" width="48" height="48" rx="6" fill="#f8fafc" stroke="#475569" stroke-width="1.8"/>
      <text x="29" y="36" text-anchor="middle" font-size="20" font-weight="bold" fill="#2563eb">?</text>
    </g>
  </g>
`, 320, 80);

// Mapping question IDs to their diagrams
const diagramMap = {
  6: svgQ6,
  7: svgQ7,
  8: svgQ8,
  9: svgQ9,
  10: svgQ10,
  11: svgQ11,
  12: svgQ12,
  13: svgQ13,
  14: svgQ14,
  15: svgQ15,
  16: svgQ16,
  17: svgQ17,
  18: svgQ18,
  19: svgQ19,
  20: svgQ20,
  31: svgQ31,
  32: svgQ32,
  33: svgQ33,
  34: svgQ34,
  35: svgQ35,
  46: svgQ46,
  47: svgQ47,
  48: svgQ48,
  53: svgQ53,
  54: svgQ54,
  55: svgQ55,
  56: svgQ56_57,
  57: svgQ56_57,
  58: svgQ58,
  59: svgQ59,
  60: svgQ60,
};

// Now update all 180 questions
for (let i = 0; i < qs.length; i++) {
  const q = qs[i];
  const qId = q.id || (i + 1);

  // Set BOTH answer and correct_index
  const correctIdx = (q.correct_index !== undefined) ? q.correct_index : (q.answer !== undefined ? q.answer : 0);
  q.answer = correctIdx;
  q.correct_index = correctIdx;
  if (q.options && q.options[correctIdx]) {
    q.correct_answer = q.options[correctIdx];
  }

  // Attach diagram if applicable
  if (diagramMap[qId]) {
    q.hasDiagram = true;
    q.diagramSvg = diagramMap[qId];
  } else {
    q.hasDiagram = false;
  }
}

// Write back to flutter_app/assets/paper52.json
fs.writeFileSync(jsonPath, JSON.stringify(paperData, null, 2), 'utf8');
console.log(`Updated ${jsonPath} successfully! Total questions: ${qs.length}`);

// Write back to paper52.js
const jsContent = `if (typeof window === 'undefined') { var window = (typeof globalThis !== 'undefined' ? globalThis : global); }
window.PAPER_52_DATA = ${JSON.stringify(paperData, null, 2)};
if (typeof module !== 'undefined' && module.exports) {
  module.exports = window.PAPER_52_DATA;
}
`;
fs.writeFileSync(jsPath, jsContent, 'utf8');
console.log(`Updated ${jsPath} successfully!`);
