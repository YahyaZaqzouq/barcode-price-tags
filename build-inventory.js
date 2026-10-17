/*
  build-inventory.js
  -------------------
  يبني ملف inventory.js من ملف الأصناف (Excel) اللي فيه الأسعار كاملة.
  الأداة (بطاقات_تسعير.html) بتحمّل inventory.js تلقائيًا أول ما تفتح،
  فتقدر تمسح الباركود ويطلع الاستيكر جاهز للطباعة من غير ما ترفع أي ملف.

  التشغيل:
      node build-inventory.js "moaz-6ac41bba2154d8a94790b4ef.xlsx"
  أو من غير وسيط (بيختار أول ملف xlsx فيه أعمدة أصناف وأسعار).
*/
const fs = require('fs');
const path = require('path');

const HERE = __dirname;
const XLSX = require(path.join(HERE, 'assets', 'lib', 'xlsx.full.min.js'));

// ---------- قراءة وسيطات سطر الأوامر ----------
let inputArg = process.argv[2];

// ---------- نفس منطق الأداة في مطابقة العناوين ----------
function normalize(h) {
  return String(h == null ? '' : h).toLowerCase().replace(/\s+/g, '').replace(/[ًٌٍَُِّْـ]/g, '').trim();
}
const HEADER_MAP = {
  code: ['صنف', 'كودالصنف', 'كود', 'مرجعداخلي', 'مرجع', 'productref', 'referencecode'],
  barcode: ['productbarcode', 'باركود', 'الباركود'],
  name: ['أسمالصنف', 'اسمالصنف', 'اسمالمنتج', 'أسمالمنتج', 'الاسم', 'productname', 'arabicname', 'product'],
  price: ['س.بيع', 'سعربيع', 'سعرالبيع', 'سعر', 'salesprice', 'saleprice'],
  supplier: ['supplier', 'المورد', 'الوردية'],
  category: ['category', 'الفئة', 'القسم']
};
function matchHeaders(row) {
  const headers = (row || []).map(normalize);
  const found = {};
  const taken = new Set();
  for (const key in HEADER_MAP) {
    const cands = HEADER_MAP[key].map(normalize);
    const i = headers.findIndex(h => cands.includes(h));
    if (i !== -1) { found[key] = i; taken.add(i); }
  }
  for (const key in HEADER_MAP) {
    if (found[key] !== undefined) continue;
    const cands = HEADER_MAP[key].map(normalize);
    const i = headers.findIndex((h, idx) => !taken.has(idx) && h && cands.some(c => h.includes(c) || c.includes(h)));
    if (i !== -1) { found[key] = i; taken.add(i); }
  }
  return found;
}
function findHeaderRow(aoa) {
  const limit = Math.min(aoa.length, 40);
  let best = { idx: -1, score: 0, map: {} };
  for (let i = 0; i < limit; i++) {
    const map = matchHeaders(aoa[i]);
    const score = Object.keys(map).length;
    if (score > best.score) best = { idx: i, score, map };
  }
  return best;
}
function fixRef(c) {
  const s = String(c == null ? '' : c).trim();
  if (!s) return '';
  return s.startsWith('000') ? s : '000' + s;
}

// ---------- اختيار الملف (لو مش محدد) ----------
if (!inputArg) {
  const candidates = fs.readdirSync(HERE).filter(f => f.toLowerCase().endsWith('.xlsx'));
  if (!candidates.length) {
    console.error('مفيش ملف xlsx في المجلد.');
    process.exit(1);
  }
  let best = null;
  for (const f of candidates) {
    try {
      const wb2 = XLSX.read(fs.readFileSync(path.join(HERE, f)), { type: 'buffer' });
      const aoa2 = XLSX.utils.sheet_to_json(wb2.Sheets[wb2.SheetNames[0]], { header: 1, raw: true, defval: '' });
      const h = findHeaderRow(aoa2);
      if (h.map.name === undefined || h.map.price === undefined) continue;
      const count = aoa2.slice(h.idx + 1).filter(r => String(r[h.map.name] || '').trim() !== '').length;
      if (!best || count > best.count) best = { f, count };
    } catch (e) { /* تجاهل الملفات غير المقروءة */ }
  }
  if (!best) {
    console.error('مفيش ملف فيه أعمدة الاسم والسعر. حدد الملف بنفسك: node build-inventory.js "your.xlsx"');
    process.exit(1);
  }
  inputArg = best.f;
  console.log('لم يتم تحديد ملف. هأستخدم: ' + inputArg);
}
const inputPath = path.isAbsolute(inputArg) ? inputArg : path.join(HERE, inputArg);
if (!fs.existsSync(inputPath)) {
  console.error('الملف غير موجود: ' + inputPath);
  process.exit(1);
}

// ---------- قراءة الملف ----------
const wb = XLSX.read(fs.readFileSync(inputPath), { type: 'buffer', cellDates: true });
const wsName = wb.SheetNames[0];
const aoa = XLSX.utils.sheet_to_json(wb.Sheets[wsName], { header: 1, raw: true, defval: '' });
const hdr = findHeaderRow(aoa);
if (hdr.idx === -1 || hdr.map.name === undefined || hdr.map.price === undefined) {
  console.error('لم ألاقي أعمدة الاسم والسعر في: ' + inputArg);
  process.exit(1);
}

const supplierIdx = new Map();
const suppliers = [];
const catIdx = new Map();
const categories = [];
const records = [];
const seenCodes = new Set();

for (let i = hdr.idx + 1; i < aoa.length; i++) {
  const raw = aoa[i];
  const name = String(hdr.map.name !== undefined ? raw[hdr.map.name] : '').trim();
  if (!name) continue;

  let price = hdr.map.price !== undefined ? raw[hdr.map.price] : '';
  price = (typeof price === 'number') ? price : parseFloat(String(price).replace(/[^\d.\-]/g, ''));
  if (isNaN(price)) price = 0;

  const code = fixRef(hdr.map.code !== undefined ? raw[hdr.map.code] : '');
  const barcode = String(hdr.map.barcode !== undefined ? raw[hdr.map.barcode] : '').trim();
  let supplier = String(hdr.map.supplier !== undefined ? raw[hdr.map.supplier] : '').trim();
  let category = String(hdr.map.category !== undefined ? raw[hdr.map.category] : '').trim();

  if (!supplierIdx.has(supplier)) { supplierIdx.set(supplier, suppliers.length); suppliers.push(supplier); }
  if (!catIdx.has(category)) { catIdx.set(category, categories.length); categories.push(category); }

  // تجاهل التكرار بنفس الكود (يحتفظ بالأسعار المختلفة كسطور منفصلة لو مفيش كود)
  if (code && seenCodes.has(code)) continue;
  if (code) seenCodes.add(code);

  records.push([code, name, Math.round(price * 100) / 100, supplierIdx.get(supplier), catIdx.get(category), barcode]);
}

const payload = {
  generated: new Date().toISOString(),
  source: path.basename(inputPath),
  suppliers,
  categories,
  rows: records
};

const out = 'window.PRICE_TAG_INVENTORY = ' + JSON.stringify(payload) + ';\n';
fs.writeFileSync(path.join(HERE, 'inventory.js'), out, 'utf8');

console.log('تم إنشاء inventory.js');
console.log('  المصدر        : ' + path.basename(inputPath));
console.log('  صف العناوين   : ' + (hdr.idx + 1));
console.log('  عدد الأصناف   : ' + records.length);
console.log('  عدد الموردين  : ' + suppliers.length);
console.log('  عدد الفئات    : ' + categories.length);
console.log('  حجم الملف     : ' + (Buffer.byteLength(out) / 1024).toFixed(0) + ' KB');
