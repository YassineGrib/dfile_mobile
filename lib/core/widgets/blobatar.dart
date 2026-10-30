// Dart port of the static path of the "blobatar" npm package v2.7.0 (MIT),
// the generator behind the avatars of the Dfile web app (MIT, see
// docs/licenses/blobatar-LICENSE.txt). Given the same name it
// produces the same SVG string as `blobatar(name, { size, background: 'circle',
// title })`, so a client looks identical on the web and on the phone.
//
// Only the static rendering is ported (no animation, gaze or expressions). The
// number formatting mirrors JavaScript, and `test/blobatar_test.dart` compares
// the output with strings produced by the real library.
library;

import 'dart:convert';
import 'dart:math' as math;

// ---------------------------------------------------------------------------
// JavaScript number helpers

/// `Math.round`: halves go toward +infinity.
double _jsRound(double v) => (v + 0.5).floorToDouble();

/// `String(number)` for the values this generator prints.
String _num(double v) {
  if (v.isFinite && v == v.truncateToDouble()) return v.toInt().toString();
  return v.toString();
}

/// `r2` of shape.ts: two decimals, no negative zero.
String _r2(double v) => _num(_jsRound(v * 100) / 100);

double _round2(double v) => _jsRound(v * 100) / 100;

// ---------------------------------------------------------------------------
// hash.ts

const int _mask = 0xFFFFFFFF;

int _feed(int h, List<int> bytes) {
  for (final int b in bytes) {
    h = ((h ^ b) & _mask) * 3432918353 & _mask;
    h = ((h << 13) | (h >> 19)) & _mask;
  }
  return h;
}

int _finalize(int h) {
  h = ((h ^ (h >> 16)) & _mask) * 2246822507 & _mask;
  h = ((h ^ (h >> 13)) & _mask) * 3266489909 & _mask;
  return (h ^ (h >> 16)) & _mask;
}

int _seedState(String seed) {
  final String s = seed.trim().toLowerCase();
  return _feed((1779033703 ^ s.length) & _mask, utf8.encode(s));
}

double _stream(int state, String key) {
  final int h = _finalize(
    _feed(_feed(state, const <int>[0xff]), utf8.encode(key)),
  );
  return h / 4294967296;
}

// ---------------------------------------------------------------------------
// traits.ts

class _Traits {
  _Traits(String seed) : _state = _seedState(seed);

  final int _state;

  double call(String key) => _stream(_state, key);

  double num(String key, double min, double max) =>
      min + call(key) * (max - min);

  int int_(String key, int min, int max) =>
      min + (call(key) * (max - min + 1)).floor();

  double jitter(String key, double amount) => (call(key) * 2 - 1) * amount;
}

// ---------------------------------------------------------------------------
// color.ts (OKLCH ramp and contrast)

class _Oklch {
  _Oklch(this.l, this.c, this.h);
  double l;
  double c;
  double h;

  _Oklch copy() => _Oklch(l, c, h);
}

List<double> _toLinear(_Oklch k) {
  final double r = (k.h * math.pi) / 180;
  final double a = k.c * math.cos(r);
  final double b = k.c * math.sin(r);
  final double l_ = k.l + 0.3963377774 * a + 0.2158037573 * b;
  final double m_ = k.l - 0.1055613458 * a - 0.0638541728 * b;
  final double s_ = k.l - 0.0894841775 * a - 1.291485548 * b;
  final double lc = l_ * l_ * l_;
  final double mc = m_ * m_ * m_;
  final double sc = s_ * s_ * s_;
  return <double>[
    4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc,
    -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc,
    -0.0041960863 * lc - 0.7034186147 * mc + 1.707614701 * sc,
  ];
}

bool _inGamut(List<double> rgb) =>
    rgb.every((double v) => v >= -1e-4 && v <= 1 + 1e-4);

List<double> _resolve(_Oklch color) {
  List<double> rgb = _toLinear(color);
  if (!_inGamut(rgb)) {
    double lo = 0;
    double hi = color.c;
    for (int i = 0; i < 12; i++) {
      final double mid = (lo + hi) / 2;
      if (_inGamut(_toLinear(_Oklch(color.l, mid, color.h)))) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    rgb = _toLinear(_Oklch(color.l, lo, color.h));
  }
  return rgb.map((double v) => math.min(1.0, math.max(0.0, v))).toList();
}

double _luminance(_Oklch color) {
  final List<double> rgb = _resolve(color);
  return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2];
}

double _contrast(_Oklch a, _Oklch b) {
  final double x = _luminance(a);
  final double y = _luminance(b);
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

_Oklch _ensureContrast(_Oklch fg, _Oklch bg, double min) {
  if (_contrast(fg, bg) >= min) return fg;
  final double lean = fg.l >= bg.l ? 1 : -1;
  for (final double dir in <double>[lean, -lean]) {
    final _Oklch probe = fg.copy();
    for (int i = 0; i < 60; i++) {
      probe.l = math.min(1.0, math.max(0.0, probe.l + dir * 0.02));
      if (_contrast(probe, bg) >= min) return probe;
      if (probe.l == 0 || probe.l == 1) break;
    }
  }
  final _Oklch black = _Oklch(0, 0, fg.h);
  final _Oklch white = _Oklch(1, 0, fg.h);
  return _contrast(black, bg) >= _contrast(white, bg) ? black : white;
}

String _toHex(_Oklch color) {
  final StringBuffer out = StringBuffer('#');
  for (final double v in _resolve(color)) {
    final double s = v <= 0.0031308
        ? 12.92 * v
        : 1.055 * math.pow(v, 1 / 2.4) - 0.055;
    out.write(_jsRound(s * 255).toInt().toRadixString(16).padLeft(2, '0'));
  }
  return out.toString();
}

const List<List<double>> _tones = <List<double>>[
  <double>[0.2, 0.86, 0.085],
  <double>[0.36, 0.9, 0.028],
  <double>[0.62, 0.73, 0.135],
  <double>[0.8, 0.62, 0.165],
  <double>[0.93, 0.87, 0.16],
  <double>[1.0, 0.34, 0.035],
];

List<double> _toneAt(double v) {
  for (final List<double> t in _tones) {
    if (v < t[0]) return t;
  }
  return _tones.first;
}

class _Palette {
  _Palette(this.bg, this.head, this.eye);
  final String bg;
  final String head;
  final String eye;
}

_Palette _palette(double hue, double tone) {
  final _Oklch darkSurface = _Oklch(0.145, 0, 0);
  final List<double> t = _toneAt(tone);
  final _Oklch head0 = _ensureContrast(
    _Oklch(t[1], t[2], hue),
    darkSurface,
    1.5,
  );
  _Oklch bg = _Oklch(0.965, 0.01, hue);
  _Oklch head = head0;
  _Oklch eye = head.l >= 0.5
      ? _Oklch(0.17, 0.02, hue)
      : _Oklch(0.97, 0.012, hue);
  head = _ensureContrast(head, bg, 1.25);
  eye = _ensureContrast(eye, head, 4.5);
  bg = bg.copy();
  return _Palette(_toHex(bg), _toHex(head), _toHex(eye));
}

// ---------------------------------------------------------------------------
// shape.ts

String _superellipse({
  required double cx,
  required double cy,
  required double rx,
  required double ry,
  double n = 4,
  double rot = 0,
}) {
  final double k = math.min(1.0, (8 * math.pow(2, -1 / n) - 4) / 3);
  final double a = rx;
  final double b = ry;
  final double ak = a * k;
  final double bk = b * k;
  final List<List<double>> pts = <List<double>>[
    <double>[a, 0],
    <double>[a, bk],
    <double>[ak, b],
    <double>[0, b],
    <double>[-ak, b],
    <double>[-a, bk],
    <double>[-a, 0],
    <double>[-a, -bk],
    <double>[-ak, -b],
    <double>[0, -b],
    <double>[ak, -b],
    <double>[a, -bk],
    <double>[a, 0],
  ];
  final double t = (rot * math.pi) / 180;
  final double cosT = math.cos(t);
  final double sinT = math.sin(t);
  String at(int i) {
    final double x = pts[i][0];
    final double y = pts[i][1];
    return '${_r2(cx + x * cosT - y * sinT)} ${_r2(cy + x * sinT + y * cosT)}';
  }

  final StringBuffer d = StringBuffer('M${at(0)}');
  for (int i = 1; i < 13; i += 3) {
    d.write('C${at(i)} ${at(i + 1)} ${at(i + 2)}');
  }
  d.write('Z');
  return d.toString();
}

String _blobPath(
  double cx,
  double cy,
  double rx,
  double ry,
  List<double> radii,
  double rot,
) {
  final int n = radii.length;
  final double t0 = (rot * math.pi) / 180;
  final List<List<double>> p = <List<double>>[
    for (int i = 0; i < n; i++)
      <double>[
        cx + rx * radii[i] * math.cos(t0 + (2 * math.pi * i) / n),
        cy + ry * radii[i] * math.sin(t0 + (2 * math.pi * i) / n),
      ],
  ];
  List<double> at(int i) => p[((i % n) + n) % n];
  final StringBuffer d = StringBuffer('M${_r2(at(0)[0])} ${_r2(at(0)[1])}');
  for (int i = 0; i < n; i++) {
    final List<double> a = at(i - 1);
    final List<double> b = at(i);
    final List<double> c = at(i + 1);
    final List<double> e = at(i + 2);
    d.write(
      'C${_r2(b[0] + (c[0] - a[0]) / 6)} ${_r2(b[1] + (c[1] - a[1]) / 6)}'
      ' ${_r2(c[0] - (e[0] - b[0]) / 6)} ${_r2(c[1] - (e[1] - b[1]) / 6)}'
      ' ${_r2(c[0])} ${_r2(c[1])}',
    );
  }
  d.write('Z');
  return d.toString();
}

String _polygon({
  required double cx,
  required double cy,
  required double rx,
  required double ry,
  required int sides,
  required double round,
  required double rot,
}) {
  final double k = round > 0 ? (round < 1 ? round / 2 : 0.5) : 0;
  final double t0 = (rot * math.pi) / 180 - math.pi / 2;
  final List<List<double>> v = <List<double>>[
    for (int i = 0; i < sides; i++)
      <double>[
        cx + rx * math.cos(t0 + (2 * math.pi * i) / sides),
        cy + ry * math.sin(t0 + (2 * math.pi * i) / sides),
      ],
  ];
  List<double> at(int i) => v[((i % sides) + sides) % sides];
  String cut(int i, int j) {
    final List<double> a = at(i);
    final List<double> b = at(j);
    return '${_r2(a[0] + (b[0] - a[0]) * k)} ${_r2(a[1] + (b[1] - a[1]) * k)}';
  }

  final StringBuffer d = StringBuffer('M${cut(0, -1)}');
  for (int i = 0; i < sides; i++) {
    final List<double> p = at(i);
    d.write('Q${_r2(p[0])} ${_r2(p[1])} ${cut(i, i + 1)}');
    if (k < 0.5) d.write('L${cut(i + 1, i)}');
  }
  d.write('Z');
  return d.toString();
}

String _box(double cx, double cy, double rx, double ry) {
  final String l = _r2(cx - rx);
  final String r = _r2(cx + rx);
  return 'M$l ${_r2(cy - ry)}H${r}V${_r2(cy + ry)}H${l}Z';
}

String _taper(double cx, double cy, double rx, double ry, double tip) {
  final double t = math.max(1.05, tip);
  final double tx = rx * math.sqrt(1 - 1 / (t * t));
  final double ty = cy - ry / t;
  final double apex = cy - t * ry;
  final double px = tx * 0.14;
  final double py = ty + 0.86 * (apex - ty);
  return 'M${_r2(cx - tx)} ${_r2(ty)}'
      'L${_r2(cx - px)} ${_r2(py)}'
      'Q${_r2(cx)} ${_r2(apex)} ${_r2(cx + px)} ${_r2(py)}'
      'L${_r2(cx + tx)} ${_r2(ty)}Z';
}

// ---------------------------------------------------------------------------
// styles/shapes.ts and styles/compose.ts

class _Body {
  _Body({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required this.n,
    required this.radii,
  });
  double cx;
  double cy;
  double rx;
  double ry;
  double n;
  double rot = 0;
  List<double> radii;
  int sides = 0;
  double round = 0.3;
}

class _Face {
  const _Face(this.cx, this.cy, this.rx, this.ry);
  final double cx;
  final double cy;
  final double rx;
  final double ry;
}

class _Petal {
  const _Petal(this.cx, this.cy, this.r);
  final double cx;
  final double cy;
  final double r;
}

class _Deco {
  final List<_Petal> petals = <_Petal>[];
  final List<String> extra = <String>[];
}

class _Shape {
  const _Shape(
    this.name,
    this.core, {
    this.body,
    this.face,
    this.decorate,
    this.path,
  });
  final String name;
  final double core;
  final void Function(_Traits t, _Body b)? body;
  final _Face Function(_Body b)? face;
  final void Function(_Traits t, _Body b, _Deco out)? decorate;
  final String Function(_Body b)? path;
}

String _poly(_Body b) => _polygon(
  cx: b.cx,
  cy: b.cy,
  rx: b.rx,
  ry: b.ry,
  sides: b.sides,
  round: b.round,
  rot: b.rot,
);

String _spline(_Body b) => _blobPath(b.cx, b.cy, b.rx, b.ry, b.radii, b.rot);

_Face Function(_Body) _shrunk(double k) =>
    (_Body b) => _Face(b.cx, b.cy, b.rx * k, b.ry * k);

_Face _splineFace(_Body b) => _shrunk(b.radii.reduce(math.min) * 0.95)(b);

_Face _polyFace(_Body b) => _shrunk(0.84)(b);

final _Shape _round = const _Shape('round', 1);

final _Shape _organic = _Shape(
  'organic',
  0.98,
  path: _spline,
  face: _splineFace,
);

final _Shape _boxy = _Shape(
  'boxy',
  0.86,
  body: (_Traits t, _Body b) {
    b.n = t.num('body.n', 3.4, 6);
    b.rot = t.num('body.rot', -20, 20);
  },
);

final _Shape _capsule = _Shape(
  'capsule',
  1.02,
  body: (_Traits t, _Body b) {
    b.ry *= t.num('capsule.squat', 0.55, 0.68);
  },
  face: _shrunk(0.94),
  decorate: (_Traits t, _Body b, _Deco out) {
    for (final int s in <int>[-1, 1]) {
      out.petals.add(_Petal(b.cx + s * (b.rx - b.ry), b.cy, b.ry));
    }
  },
  path: (_Body b) => _box(b.cx, b.cy, b.rx - b.ry, b.ry),
);

final _Shape _nub = _Shape(
  'nub',
  0.88,
  decorate: (_Traits t, _Body b, _Deco out) {
    final int count = t.int_('nub.n', 1, 2);
    for (int i = 0; i < count; i++) {
      final double a = t.num('nub.a$i', 0, 2 * math.pi);
      out.petals.add(
        _Petal(
          b.cx + math.cos(a) * b.rx * 0.88,
          b.cy + math.sin(a) * b.rx * 0.88,
          b.rx * t.num('nub.r$i', 0.24, 0.4),
        ),
      );
    }
  },
);

final _Shape _cloud = _Shape(
  'cloud',
  0.78,
  face: _splineFace,
  path: _spline,
  decorate: (_Traits t, _Body b, _Deco out) {
    final int count = t.int_('cloud.n', 4, 6);
    for (int i = 0; i < count; i++) {
      final double a = math.pi + (math.pi * (i + 0.5)) / count;
      out.petals.add(
        _Petal(
          b.cx + math.cos(a) * b.rx * 0.8,
          b.cy + math.sin(a) * b.rx * 0.5,
          b.rx * t.num('cloud.r$i', 0.44, 0.62),
        ),
      );
    }
  },
);

final _Shape _droplet = _Shape(
  'droplet',
  0.78,
  body: (_Traits t, _Body b) {
    b.cy += 0.22 * b.ry;
    b.n = 2;
  },
  face: (_Body b) => _Face(b.cx, b.cy + b.ry * 0.05, b.rx * 0.88, b.ry * 0.88),
  decorate: (_Traits t, _Body b, _Deco out) {
    out.extra.add(
      _taper(b.cx, b.cy, b.rx, b.ry, t.num('droplet.tip', 1.4, 1.65)),
    );
  },
);

final _Shape _hexagon = _Shape(
  'hexagon',
  1.05,
  path: _poly,
  face: _polyFace,
  body: (_Traits t, _Body b) {
    b.sides = 6;
    b.rot = t.num('body.rot', -12, 12);
    b.round = t.num('poly.round', 0.24, 0.5);
  },
);

final _Shape _sun = _Shape(
  'sun',
  0.7,
  decorate: (_Traits t, _Body b, _Deco out) {
    final int count = t.int_('sun.n', 6, 9);
    final double dist = b.rx * t.num('sun.dist', 1.0, 1.08);
    final double pr = b.rx * t.num('sun.r', 0.2, 0.26);
    final double off = t.num('sun.rot', 0, 2 * math.pi);
    for (int i = 0; i < count; i++) {
      final double a = off + (2 * math.pi * i) / count;
      out.petals.add(
        _Petal(b.cx + math.cos(a) * dist, b.cy + math.sin(a) * dist, pr),
      );
    }
  },
);

final _Shape _triangle = _Shape(
  'triangle',
  1.15,
  path: _poly,
  body: (_Traits t, _Body b) {
    b.sides = 3;
    b.rot = t.num('body.rot', -5, 5);
    b.round = t.num('poly.round', 0.24, 0.5);
  },
  face: (_Body b) => _Face(b.cx, b.cy + b.ry * 0.1, b.rx * 0.54, b.ry * 0.36),
);

final List<(_Shape, double)> _bands = <(_Shape, double)>[
  (_round, 0.22),
  (_organic, 0.48),
  (_boxy, 0.6),
  (_capsule, 0.7),
  (_nub, 0.79),
  (_cloud, 0.86),
  (_droplet, 0.915),
  (_hexagon, 0.95),
  (_sun, 0.98),
  (_triangle, 1),
];

class _Eye {
  const _Eye(this.cx, this.cy, this.rx, this.ry, this.n, this.rot);
  final double cx;
  final double cy;
  final double rx;
  final double ry;
  final double n;
  final double rot;
}

double _hypot(double a, double b) => math.sqrt(a * a + b * b);

List<_Eye> _faceFit(_Traits t, _Body b, _Face face) {
  final double rx = b.rx;
  final double er0 = t.num('eye.rx', 0.075, 0.105) * rx;
  final double ratio = t.num('eye.ratio', 1.9, 3.2);
  final double scale = t.num('eye.scale', 0.78, 1.24);
  final double stretch = t.num('eye.stretch', 0.85, 1.18);
  final double clearance = t.num('eye.gap', 0.1, 0.24) * rx;
  final double wide = er0 * math.max(1.0, scale);
  final double tall = er0 * ratio * math.max(1.0, scale * stretch);
  final double gap0 = wide + rx * 0.03 + clearance;

  final double gx = t.jitter('gaze.x', 0.09) * face.rx;
  final double gy = t.num('gaze.y', -0.2, 0.08) * face.ry;
  final double dy = t.jitter('eye.dy', 0.04) * face.ry;
  final double reach = _hypot(wide, tall);
  final double need = _hypot(
    (gx.abs() + gap0 + reach) / face.rx,
    (gy.abs() + dy.abs() + reach) / face.ry,
  );
  final double fit = need > 0.9 ? 0.9 / need : 1;

  final double er = er0 * fit;
  final double eyeRy = er * ratio;
  final double gap = gap0 * fit;
  final double room = math.max(0.0, math.min(1.0, clearance / tall));
  final double bound = math.min(12.0, (math.asin(room) * 180) / math.pi);
  final double lean = t.num('eye.lean', -1, 1) * bound;
  final double lean2 = math.max(
    -12.0,
    math.min(12.0, lean + t.jitter('eye.lean2', 3.5)),
  );

  final double cx = face.cx + gx * fit;
  final double cy = face.cy + gy * fit;
  return <_Eye>[
    _Eye(cx - gap, cy, er, eyeRy, t.num('eye.n', 3.5, 6), lean),
    _Eye(
      cx + gap,
      cy + dy * fit,
      er * scale,
      eyeRy * scale * stretch,
      t.num('eye.n', 3.5, 6),
      lean2,
    ),
  ];
}

String _renderFigure(_Traits t, _Palette p) {
  double pickV = t('shape');
  _Shape shape = _bands.last.$1;
  for (final (_Shape s, double upTo) in _bands) {
    if (pickV < upTo) {
      shape = s;
      break;
    }
  }

  final double r = t.num('body.r', 31, 38) * shape.core;
  final int pts = t.int_('body.pts', 6, 8);
  final _Body body = _Body(
    cx: 50 + t.jitter('body.x', 1.5),
    cy: 50 + t.jitter('body.y', 1.5),
    rx: r,
    ry: r * t.num('body.ratio', 0.92, 1.08),
    n: t.num('body.n', 1.9, 2.5),
    radii: <double>[
      for (int i = 0; i < pts; i++) 1 + t.jitter('body.r$i', 0.16),
    ],
  );
  shape.body?.call(t, body);

  final _Face face =
      shape.face?.call(body) ?? _Face(body.cx, body.cy, body.rx, body.ry);
  final _Deco deco = _Deco();
  shape.decorate?.call(t, body, deco);
  final List<_Eye> eyes = _faceFit(t, body, face);

  final StringBuffer out = StringBuffer('<g fill="${p.head}">');
  for (final _Petal d in deco.petals) {
    out.write(
      '<circle cx="${_num(_round2(d.cx))}" cy="${_num(_round2(d.cy))}" r="${_num(_round2(d.r))}"/>',
    );
  }
  for (final String d in deco.extra) {
    out.write('<path d="$d"/>');
  }
  final String core = shape.path != null
      ? shape.path!(body)
      : _superellipse(
          cx: body.cx,
          cy: body.cy,
          rx: body.rx,
          ry: body.ry,
          n: body.n,
          rot: body.rot,
        );
  out.write('<path d="$core"/></g><g fill="${p.eye}">');
  for (final _Eye e in eyes) {
    out.write(
      '<path d="${_superellipse(cx: e.cx, cy: e.cy, rx: e.rx, ry: e.ry, n: e.n, rot: e.rot)}"/>',
    );
  }
  out.write('</g>');
  return out.toString();
}

// ---------------------------------------------------------------------------
// render.ts (static path)

String _escape(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// Returns the avatar SVG for [name], identical to the web app's generator.
///
/// [background] is `'circle'`, `'square'`, `'squircle'` or `null` for none.
String blobatarSvg(
  String name, {
  double? size,
  String? background = 'circle',
  String? title,
}) {
  final _Traits t = _Traits(name);
  final _Palette p = _palette(t.num('hue', 0, 360), t('tone'));

  final StringBuffer out = StringBuffer(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"',
  );
  if (size != null && size != 0) {
    out.write(' width="${_num(size)}" height="${_num(size)}"');
  }
  out.write('>');
  if (title != null && title.isNotEmpty) {
    out.write('<title>${_escape(title)}</title>');
  }
  if (background != null) {
    final String d = background == 'square'
        ? 'M0 0H100V100H0Z'
        : _superellipse(
            cx: 50,
            cy: 50,
            rx: 50,
            ry: 50,
            n: background == 'circle' ? 2 : 6,
          );
    out.write('<path d="$d" fill="${p.bg}"/>');
  }
  out.write(_renderFigure(t, p));
  out.write('</svg>');
  return out.toString();
}
