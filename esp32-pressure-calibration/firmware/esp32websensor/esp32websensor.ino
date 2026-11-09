#include <WiFi.h>
#include <WebServer.h>
#include "HX710AB.h"

// ============================================================
// 1. WI-FI
// ============================================================

#include "config.h"  // Copy config.example.h and enter local Wi-Fi credentials.

// ============================================================
// 2. HX710B PINS
// ============================================================

const uint8_t HX_DATA_PIN = 5;
const uint8_t HX_CLOCK_PIN = 6;

HX710B pressureSensor(HX_DATA_PIN, HX_CLOCK_PIN);

// ============================================================
// 3. WEB SERVER
// ============================================================

WebServer server(80);

// ============================================================
// 4. SAMPLING
// ============================================================

const uint32_t SAMPLE_INTERVAL_MS = 250;

// Latest live values
int32_t latestRaw = 0;
uint32_t latestEsp32Ms = 0;
float latestPressureKPa = 0.0f;
bool latestInRange = false;

// ============================================================
// 5. CALIBRATION CONSTANTS
// ============================================================

// From your R analysis
const float CAL_INTERCEPT = -3.568469f;
const float CAL_SLOPE     = 0.000001181831f;

// Experimentally calibrated interval
const float CAL_RANGE_MIN_KPA = -0.02942f;
const float CAL_RANGE_MAX_KPA =  0.44130f;

// Experimental performance summary
const float CAL_R2              = 0.9951f;
const float CAL_RMSE_KPA        = 0.0114f;
const float VALIDATION_RMSE_KPA = 0.0090f;
const float ZERO_SPREAD_KPA     = 0.0706f;

// ============================================================
// 6. RECORDING STATE
// ============================================================

bool recording = false;
uint32_t experimentStartMs = 0;
uint32_t nextSampleID = 0;

// ============================================================
// 7. SAMPLE STRUCTURE
// ============================================================

struct Sample {
  uint32_t id;
  uint32_t experiment_ms;
  uint32_t esp32_ms;
  int32_t raw_pressure;
  float pressure_kPa;
};

// ============================================================
// 8. STORAGE
// ============================================================

const size_t MAX_SAMPLES = 5000;
Sample samples[MAX_SAMPLES];
size_t sampleCount = 0;

// ============================================================
// 9. HELPER FUNCTIONS
// ============================================================

float convertRawToPressureKPa(int32_t raw) {
  return CAL_INTERCEPT + CAL_SLOPE * (float)raw;
}

bool isWithinCalibratedRange(float p) {
  return (p >= CAL_RANGE_MIN_KPA && p <= CAL_RANGE_MAX_KPA);
}

// ============================================================
// 10. WEB PAGE
// ============================================================

const char MAIN_PAGE[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>HX710B Pressure Dashboard</title>
<style>
  :root{
    --bg:#0b1220;
    --bg2:#101a2e;
    --panel:#111b31;
    --panel2:#16233d;
    --text:#e8eefc;
    --muted:#9bb0d1;
    --line:#243552;
    --accent:#59b8ff;
    --accent2:#7c8cff;
    --good:#22c55e;
    --warn:#f59e0b;
    --bad:#ef4444;
    --card-shadow:0 10px 30px rgba(0,0,0,.22);
  }

  *{box-sizing:border-box}
  html,body{margin:0;padding:0}
  body{
    font-family:Inter,system-ui,Arial,sans-serif;
    color:var(--text);
    background:
      radial-gradient(circle at top right, rgba(89,184,255,.12), transparent 24%),
      radial-gradient(circle at top left, rgba(124,140,255,.10), transparent 22%),
      linear-gradient(180deg,var(--bg),#0a1020 100%);
  }

  .container{
    width:min(1180px,calc(100% - 28px));
    margin:20px auto 36px;
  }

  .hero{
    background:linear-gradient(135deg, rgba(89,184,255,.12), rgba(124,140,255,.08));
    border:1px solid rgba(255,255,255,.08);
    border-radius:22px;
    padding:22px;
    box-shadow:var(--card-shadow);
    margin-bottom:18px;
  }

  .hero-top{
    display:flex;
    justify-content:space-between;
    align-items:flex-start;
    gap:14px;
    flex-wrap:wrap;
  }

  .eyebrow{
    color:#8ecfff;
    font-size:12px;
    font-weight:800;
    letter-spacing:1.8px;
    text-transform:uppercase;
    margin-bottom:8px;
  }

  h1{
    margin:0 0 6px;
    font-size:clamp(26px,4vw,38px);
    line-height:1.05;
  }

  .subtitle{
    color:var(--muted);
    font-size:14px;
  }

  .pill{
    display:inline-flex;
    align-items:center;
    gap:8px;
    padding:10px 14px;
    border-radius:999px;
    font-size:13px;
    font-weight:700;
    border:1px solid rgba(255,255,255,.08);
    background:rgba(255,255,255,.05);
  }

  .live{color:#b6f7c8;background:rgba(34,197,94,.14)}
  .stale{color:#ffd98f;background:rgba(245,158,11,.15)}
  .offline{color:#ffc1c1;background:rgba(239,68,68,.16)}

  .grid{
    display:grid;
    gap:16px;
  }

  .cards{
    grid-template-columns:repeat(4,minmax(0,1fr));
    margin-bottom:18px;
  }

  .metrics{
    grid-template-columns:repeat(6,minmax(0,1fr));
    margin-top:14px;
  }

  .two-col{
    grid-template-columns:1.55fr .95fr;
    margin-bottom:18px;
  }

  .three-col{
    grid-template-columns:repeat(3,minmax(0,1fr));
    margin-bottom:18px;
  }

  .card,.panel{
    background:linear-gradient(180deg,var(--panel),var(--panel2));
    border:1px solid rgba(255,255,255,.08);
    border-radius:20px;
    box-shadow:var(--card-shadow);
  }

  .card{
    padding:18px;
  }

  .panel{
    padding:20px;
  }

  .label{
    color:var(--muted);
    font-size:13px;
    margin-bottom:10px;
  }

  .value{
    font-size:clamp(22px,3vw,34px);
    font-weight:800;
    letter-spacing:.2px;
    line-height:1.1;
  }

  .subvalue{
    margin-top:8px;
    color:var(--muted);
    font-size:12px;
  }

  .range-badge{
    display:inline-flex;
    align-items:center;
    gap:8px;
    padding:8px 12px;
    border-radius:999px;
    font-size:13px;
    font-weight:800;
  }

  .range-good{background:rgba(34,197,94,.15); color:#baf7cf}
  .range-bad{background:rgba(239,68,68,.16); color:#ffc3c3}

  h2{
    margin:0 0 6px;
    font-size:20px;
  }

  .muted{
    color:var(--muted);
    font-size:13px;
    line-height:1.55;
  }

  .section-head{
    display:flex;
    justify-content:space-between;
    align-items:flex-start;
    gap:12px;
    flex-wrap:wrap;
    margin-bottom:12px;
  }

  .tag{
    color:#b6ddff;
    background:rgba(89,184,255,.12);
    border:1px solid rgba(89,184,255,.22);
    padding:7px 11px;
    border-radius:999px;
    font-size:12px;
    font-weight:700;
  }

  canvas{
    width:100%;
    height:300px;
    display:block;
    margin-top:10px;
  }

  .btns{
    display:flex;
    gap:10px;
    flex-wrap:wrap;
    margin-top:14px;
    margin-bottom:10px;
  }

  button{
    border:0;
    border-radius:12px;
    padding:12px 16px;
    font-weight:800;
    font-size:14px;
    cursor:pointer;
    transition:.2s transform ease,.2s opacity ease;
  }

  button:hover{transform:translateY(-1px)}
  .start{background:#1f9d67;color:white}
  .stop{background:#cc5050;color:white}
  .download{background:#dce9ff;color:#123d67}

  .record-state{
    font-weight:800;
    letter-spacing:.3px;
  }

  .row{
    display:flex;
    gap:10px;
    flex-wrap:wrap;
    margin-top:12px;
  }

  .mini{
    flex:1 1 120px;
    padding:14px;
    border-radius:16px;
    border:1px solid rgba(255,255,255,.08);
    background:rgba(255,255,255,.03);
  }

  .mini .k{
    color:var(--muted);
    font-size:11px;
    text-transform:uppercase;
    letter-spacing:1px;
    margin-bottom:6px;
  }

  .mini .v{
    font-size:18px;
    font-weight:800;
  }

  .equation{
    background:rgba(255,255,255,.04);
    border:1px solid rgba(255,255,255,.08);
    border-radius:16px;
    padding:14px 16px;
    margin-top:14px;
    font-family:ui-monospace, SFMono-Regular, Menlo, monospace;
    color:#d6e9ff;
    overflow-wrap:anywhere;
  }

  ul{
    margin:10px 0 0 18px;
    padding:0;
    color:var(--muted);
    line-height:1.6;
    font-size:13px;
  }

  table{
    width:100%;
    border-collapse:collapse;
    margin-top:12px;
    font-size:13px;
  }

  th,td{
    text-align:left;
    padding:10px 8px;
    border-bottom:1px solid rgba(255,255,255,.08);
  }

  th{
    color:#d9e8ff;
    font-size:12px;
    text-transform:uppercase;
    letter-spacing:1px;
  }

  .footnote{
    margin-top:12px;
    color:var(--muted);
    font-size:12px;
    line-height:1.5;
  }

  @media (max-width:1000px){
    .cards{grid-template-columns:repeat(2,minmax(0,1fr))}
    .metrics{grid-template-columns:repeat(3,minmax(0,1fr))}
    .two-col{grid-template-columns:1fr}
    .three-col{grid-template-columns:1fr}
  }

  @media (max-width:640px){
    .cards,.metrics{grid-template-columns:1fr}
    canvas{height:250px}
  }
</style>
</head>
<body>
<div class="container">

  <section class="hero">
    <div class="hero-top">
      <div>
        <div class="eyebrow">ESP32-S3 · HX710B · U-tube calibration · R analysis</div>
        <h1>Pressure Monitoring Dashboard</h1>
        <div class="subtitle">
          Experimental gauge-pressure platform with live monitoring, calibrated conversion, performance summary and CSV export.
        </div>
      </div>
      <div id="connection" class="pill stale">Connecting…</div>
    </div>

    <div class="grid metrics">
      <div class="mini">
        <div class="k">Calibration R²</div>
        <div class="v">0.9951</div>
      </div>
      <div class="mini">
        <div class="k">Calibration RMSE</div>
        <div class="v">0.0114 kPa</div>
      </div>
      <div class="mini">
        <div class="k">Validation RMSE</div>
        <div class="v">0.0090 kPa</div>
      </div>
      <div class="mini">
        <div class="k">Zero spread</div>
        <div class="v">0.0706 kPa</div>
      </div>
      <div class="mini">
        <div class="k">Range min</div>
        <div class="v">-0.0294 kPa</div>
      </div>
      <div class="mini">
        <div class="k">Range max</div>
        <div class="v">0.4413 kPa</div>
      </div>
    </div>
  </section>

  <section class="grid cards">
    <div class="card">
      <div class="label">Live pressure estimate</div>
      <div class="value" id="pressure">--</div>
      <div class="subvalue">Gauge pressure in kPa from calibration equation</div>
    </div>

    <div class="card">
      <div class="label">Latest raw reading</div>
      <div class="value" id="raw">--</div>
      <div class="subvalue">HX710B raw counts</div>
    </div>

    <div class="card">
      <div class="label">Calibrated range status</div>
      <div class="value" style="font-size:20px">
        <span id="rangeBadge" class="range-badge range-bad">Waiting…</span>
      </div>
      <div class="subvalue">Experimentally supported interval: -0.0294 to 0.4413 kPa</div>
    </div>

    <div class="card">
      <div class="label">Recording summary</div>
      <div class="value" id="count">0</div>
      <div class="subvalue">
        Sample ID: <span id="sampleid">0</span><br>
        State: <span id="status" class="record-state">STOPPED</span>
      </div>
    </div>
  </section>

  <section class="grid two-col">
    <div class="panel">
      <div class="section-head">
        <div>
          <h2>Real-time pressure graph</h2>
          <div class="muted">
            Browser display of the latest calibrated pressure estimate. The ESP32 still controls acquisition and recording.
          </div>
        </div>
        <div class="tag">Last ~60 seconds</div>
      </div>

      <canvas id="pressureChart"></canvas>

      <div class="row">
        <div class="mini">
          <div class="k">ESP32 timestamp</div>
          <div class="v" id="esp32time">--</div>
        </div>
        <div class="mini">
          <div class="k">Sampling interval</div>
          <div class="v">250 ms</div>
        </div>
        <div class="mini">
          <div class="k">Display update</div>
          <div class="v">500 ms</div>
        </div>
      </div>
    </div>

    <div class="panel">
      <h2>Experiment controls</h2>
      <div class="muted">
        Start begins a new trial and clears the current recording buffer. Stop before downloading the CSV.
      </div>

      <div class="btns">
        <button class="start" onclick="sendCommand('/start')">Start recording</button>
        <button class="stop" onclick="sendCommand('/stop')">Stop recording</button>
        <button class="download" onclick="downloadCSV()">Download CSV</button>
      </div>

      <div class="equation">
        Pressure (kPa) = -3.568469 + 0.000001181831 × raw_counts
      </div>

      <div class="footnote">
        This pressure estimate is valid primarily within the experimentally tested range and should be treated as an educational measurement, not a certified instrument reading.
      </div>
    </div>
  </section>

  <section class="grid three-col">
    <div class="panel">
      <h2>Performance interpretation</h2>
      <ul>
        <li><strong>Calibration R² = 0.9951</strong> indicates a strong linear relationship between raw counts and reference pressure.</li>
        <li><strong>Calibration RMSE = 0.0114 kPa</strong> summarizes fit error on the calibration points.</li>
        <li><strong>Validation RMSE = 0.0090 kPa</strong> summarizes error on independent validation trials.</li>
        <li>These are <strong>performance indicators</strong>, not a certified absolute accuracy claim.</li>
      </ul>
    </div>

    <div class="panel">
      <h2>Main limitations</h2>
      <ul>
        <li>Reference pressure came from a <strong>homemade U-tube water column</strong>.</li>
        <li><strong>Zero-pressure spread = 0.0706 kPa</strong>, so offset drift is a visible limitation.</li>
        <li>Pressure outside the calibrated interval is an <strong>extrapolation</strong>.</li>
        <li>This is appropriate for <strong>learning, prototyping and method development</strong>.</li>
      </ul>
    </div>

    <div class="panel">
      <h2>CSV output</h2>
      <div class="muted">
        Every downloaded CSV now contains:
      </div>
      <table>
        <tr><th>Column</th><th>Description</th></tr>
        <tr><td>sample_id</td><td>Unique sample number</td></tr>
        <tr><td>experiment_ms</td><td>Time since recording start</td></tr>
        <tr><td>esp32_ms</td><td>ESP32 time since startup</td></tr>
        <tr><td>raw_pressure</td><td>Uncalibrated HX710B reading</td></tr>
        <tr><td>pressure_kPa</td><td>Calibrated pressure estimate</td></tr>
      </table>
    </div>
  </section>
</div>

<script>
const history = [];
const MAX_POINTS = 180;
const WINDOW_MS = 60000;

let lastSensorMs = -1;
let lastFreshTime = 0;
let requestBusy = false;

const $ = id => document.getElementById(id);

function addMeasurement(timestamp, pressureKPa) {
  timestamp = Number(timestamp);
  pressureKPa = Number(pressureKPa);

  if (!Number.isFinite(timestamp) || !Number.isFinite(pressureKPa) || timestamp <= 0) {
    return;
  }

  if (lastSensorMs >= 0 && timestamp < lastSensorMs) {
    history.length = 0;
  }

  if (timestamp === lastSensorMs) {
    return;
  }

  lastSensorMs = timestamp;
  lastFreshTime = Date.now();

  history.push({ t: timestamp, y: pressureKPa });

  while (history.length > 0 && (timestamp - history[0].t > WINDOW_MS)) {
    history.shift();
  }

  while (history.length > MAX_POINTS) {
    history.shift();
  }

  drawChart();
}

function drawChart() {
  const canvas = $("pressureChart");
  const w = Math.max(260, canvas.clientWidth);
  const h = Math.max(220, canvas.clientHeight);
  const ratio = Math.min(window.devicePixelRatio || 1, 2);

  canvas.width = Math.round(w * ratio);
  canvas.height = Math.round(h * ratio);

  const ctx = canvas.getContext("2d");
  ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
  ctx.clearRect(0, 0, w, h);

  const left = 64;
  const right = 18;
  const top = 18;
  const bottom = 40;
  const pw = w - left - right;
  const ph = h - top - bottom;

  if (history.length === 0) {
    ctx.fillStyle = "#9bb0d1";
    ctx.font = "14px Arial";
    ctx.fillText("Waiting for pressure data...", 18, h / 2);
    return;
  }

  const values = history.map(p => p.y);
  let low = Math.min(...values);
  let high = Math.max(...values);

  let padding = Math.max(0.01, (high - low) * 0.18);
  if (Math.abs(high - low) < 0.02) padding = 0.02;

  const yMin = low - padding;
  const yMax = high + padding;

  const endTime = history[history.length - 1].t;
  const startTime = Math.max(history[0].t, endTime - WINDOW_MS);
  const span = Math.max(5000, endTime - startTime);

  const xPos = p => left + ((p.t - startTime) / span) * pw;
  const yPos = p => top + ph - ((p.y - yMin) / (yMax - yMin)) * ph;

  // Grid
  ctx.font = "11px Arial";
  ctx.strokeStyle = "rgba(255,255,255,.08)";
  ctx.lineWidth = 1;

  for (let i = 0; i <= 4; i++) {
    const yy = top + (ph * i / 4);
    const value = yMax - (yMax - yMin) * i / 4;

    ctx.beginPath();
    ctx.moveTo(left, yy);
    ctx.lineTo(w - right, yy);
    ctx.stroke();

    ctx.fillStyle = "#9bb0d1";
    ctx.fillText(value.toFixed(3), 4, yy + 4);
  }

  ctx.fillText("0 s", left, h - 10);
  ctx.textAlign = "right";
  ctx.fillText(((endTime - startTime) / 1000).toFixed(0) + " s", w - right, h - 10);
  ctx.textAlign = "left";

  // Area
  const gradient = ctx.createLinearGradient(0, top, 0, h - bottom);
  gradient.addColorStop(0, "rgba(89,184,255,.35)");
  gradient.addColorStop(1, "rgba(89,184,255,.02)");

  ctx.beginPath();
  ctx.moveTo(xPos(history[0]), h - bottom);
  history.forEach(p => ctx.lineTo(xPos(p), yPos(p)));
  ctx.lineTo(xPos(history[history.length - 1]), h - bottom);
  ctx.closePath();
  ctx.fillStyle = gradient;
  ctx.fill();

  // Line
  ctx.beginPath();
  history.forEach((p, i) => {
    if (i === 0) ctx.moveTo(xPos(p), yPos(p));
    else ctx.lineTo(xPos(p), yPos(p));
  });
  ctx.strokeStyle = "#59b8ff";
  ctx.lineWidth = 2.6;
  ctx.lineJoin = "round";
  ctx.stroke();

  // Latest point
  const last = history[history.length - 1];
  ctx.beginPath();
  ctx.arc(xPos(last), yPos(last), 4, 0, Math.PI * 2);
  ctx.fillStyle = "#d8f0ff";
  ctx.fill();

  // Axis label
  ctx.save();
  ctx.translate(14, top + ph / 2);
  ctx.rotate(-Math.PI / 2);
  ctx.fillStyle = "#9bb0d1";
  ctx.font = "12px Arial";
  ctx.fillText("Pressure (kPa)", 0, 0);
  ctx.restore();
}

function updateConnection(isConnected) {
  const el = $("connection");
  const age = Date.now() - lastFreshTime;

  if (!isConnected) {
    el.textContent = "Connection problem";
    el.className = "pill offline";
    return;
  }

  if (lastFreshTime === 0) {
    el.textContent = "Waiting for measurement";
    el.className = "pill stale";
    return;
  }

  if (age > 3000) {
    el.textContent = "Sensor data delayed";
    el.className = "pill stale";
    return;
  }

  el.textContent = "Live";
  el.className = "pill live";
}

function updateRangeBadge(inRange) {
  const badge = $("rangeBadge");
  if (inRange) {
    badge.textContent = "Inside calibrated range";
    badge.className = "range-badge range-good";
  } else {
    badge.textContent = "Outside calibrated range";
    badge.className = "range-badge range-bad";
  }
}

async function updateDisplay() {
  if (requestBusy) return;
  requestBusy = true;

  try {
    const response = await fetch("/latest", { cache: "no-store" });
    if (!response.ok) throw new Error("HTTP " + response.status);

    const data = await response.json();

    $("pressure").textContent = Number(data.pressure_kPa).toFixed(4) + " kPa";
    $("raw").textContent = Number(data.raw_pressure).toLocaleString();
    $("esp32time").textContent = Number(data.esp32_ms).toLocaleString() + " ms";
    $("count").textContent = data.sample_count;
    $("sampleid").textContent = data.sample_id;
    $("status").textContent = data.recording ? "RECORDING" : "STOPPED";

    updateRangeBadge(Boolean(data.in_range));
    addMeasurement(data.esp32_ms, data.pressure_kPa);
    updateConnection(true);
  } catch (error) {
    console.log("Communication error:", error);
    updateConnection(false);
  } finally {
    requestBusy = false;
  }
}

async function sendCommand(path) {
  try {
    const response = await fetch(path, { cache: "no-store" });
    if (!response.ok) throw new Error("Command failed");
    await updateDisplay();
  } catch (error) {
    alert("Could not communicate with ESP32.");
  }
}

function downloadCSV() {
  window.location.href = "/csv";
}

setInterval(updateDisplay, 500);

setInterval(() => {
  if (lastFreshTime > 0 && Date.now() - lastFreshTime > 3000) {
    updateConnection(true);
  }
}, 1000);

window.addEventListener("resize", drawChart);

drawChart();
updateDisplay();
</script>
</body>
</html>
)rawliteral";

// ============================================================
// 11. WIFI CONNECTION
// ============================================================

void connectWiFi() {
  Serial.println();
  Serial.println("Connecting to cellphone hotspot...");

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_NAME, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println();
  Serial.println("Wi-Fi connected successfully.");

  Serial.print("ESP32 IP address: ");
  Serial.println(WiFi.localIP());

  Serial.println();
  Serial.println("Open this address in your browser:");
  Serial.print("http://");
  Serial.println(WiFi.localIP());
  Serial.println();
}

// ============================================================
// 12. NON-BLOCKING SENSOR ACQUISITION
// ============================================================

void sampleSensor() {
  static bool waitingForSample = false;
  static uint32_t requestStartedMs = 0;
  static uint32_t nextSampleDueMs = 0;

  uint32_t now = millis();

  if (!waitingForSample && (int32_t)(now - nextSampleDueMs) >= 0) {
    pressureSensor.request();
    requestStartedMs = now;
    waitingForSample = true;
  }

  if (!waitingForSample) {
    return;
  }

  if (!pressureSensor.is_ready()) {
    if (now - requestStartedMs > 300) {
      Serial.println("WARNING: HX710B measurement timeout");
      waitingForSample = false;
      nextSampleDueMs = now + SAMPLE_INTERVAL_MS;
    }
    return;
  }

  int32_t raw = pressureSensor.fetch(true);
  uint32_t actualReadTime = millis();

  waitingForSample = false;
  nextSampleDueMs = actualReadTime + SAMPLE_INTERVAL_MS;

  latestRaw = raw;
  latestEsp32Ms = actualReadTime;
  latestPressureKPa = convertRawToPressureKPa(raw);
  latestInRange = isWithinCalibratedRange(latestPressureKPa);

  if (!recording) {
    return;
  }

  if (sampleCount >= MAX_SAMPLES) {
    recording = false;
    Serial.println("Recording stopped: memory buffer full.");
    return;
  }

  nextSampleID++;

  samples[sampleCount].id = nextSampleID;
  samples[sampleCount].experiment_ms = actualReadTime - experimentStartMs;
  samples[sampleCount].esp32_ms = actualReadTime;
  samples[sampleCount].raw_pressure = raw;
  samples[sampleCount].pressure_kPa = latestPressureKPa;

  sampleCount++;
}

// ============================================================
// 13. WEB ROUTES
// ============================================================

void configureWebServer() {

  server.on("/", []() {
    server.send(200, "text/html", MAIN_PAGE);
  });

  server.on("/latest", []() {
    String json = "{";

    json += "\"raw_pressure\":";
    json += String(latestRaw);

    json += ",\"pressure_kPa\":";
    json += String(latestPressureKPa, 5);

    json += ",\"esp32_ms\":";
    json += String(latestEsp32Ms);

    json += ",\"recording\":";
    json += recording ? "true" : "false";

    json += ",\"sample_count\":";
    json += String(sampleCount);

    json += ",\"sample_id\":";
    json += String(nextSampleID);

    json += ",\"in_range\":";
    json += latestInRange ? "true" : "false";

    json += "}";

    server.send(200, "application/json", json);
  });

  server.on("/start", []() {
    sampleCount = 0;
    nextSampleID = 0;
    experimentStartMs = millis();
    recording = true;

    Serial.println();
    Serial.println("=================================");
    Serial.println("NEW EXPERIMENT STARTED");
    Serial.println("=================================");

    server.send(200, "text/plain", "Recording started");
  });

  server.on("/stop", []() {
    recording = false;

    Serial.println();
    Serial.println("Experiment stopped.");
    Serial.print("Samples recorded: ");
    Serial.println(sampleCount);

    server.send(200, "text/plain", "Recording stopped");
  });

  server.on("/csv", []() {
    server.sendHeader("Content-Disposition",
                      "attachment; filename=pressure_trial.csv");

    server.setContentLength(CONTENT_LENGTH_UNKNOWN);
    server.send(200, "text/csv", "");

    server.sendContent(
      "sample_id,experiment_ms,esp32_ms,raw_pressure,pressure_kPa\n"
    );

    for (size_t i = 0; i < sampleCount; i++) {
      String row = "";
      row += String(samples[i].id);
      row += ",";
      row += String(samples[i].experiment_ms);
      row += ",";
      row += String(samples[i].esp32_ms);
      row += ",";
      row += String(samples[i].raw_pressure);
      row += ",";
      row += String(samples[i].pressure_kPa, 5);
      row += "\n";

      server.sendContent(row);
    }

    server.sendContent("");
  });

  server.begin();
  Serial.println("Web server started.");
}

// ============================================================
// 14. SETUP
// ============================================================

void setup() {
  Serial.begin(115200);
  delay(2000);

  Serial.println();
  Serial.println("===============================");
  Serial.println("ESP32 PRESSURE PLATFORM V4");
  Serial.println("===============================");

  pressureSensor.begin();
  Serial.println("HX710B initialized.");

  connectWiFi();
  configureWebServer();

  Serial.println();
  Serial.println("System ready.");
}

// ============================================================
// 15. LOOP
// ============================================================

void loop() {
  server.handleClient();
  sampleSensor();
  delay(1);
}