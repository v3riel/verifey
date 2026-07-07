// =============================================================
//  Interactive Flashcard System — Typst card templates
//  Templates: academic (3a) · clean (2c) · terminal (1c)
//  Each template renders a two-sided 6x4in index card
//  (front page, then back page).
//
//  Requires Typst 0.11+ and these fonts installed:
//    Noto Serif, Noto Serif KR, Noto Sans KR,
//    JetBrains Mono, Nanum Gothic Coding
//  Compile:  typst compile cards-demo.typ cards.pdf
// =============================================================

// ---------- card geometry ----------
#let CARD = (width: 6in, height: 4in)

// ---------- palette (paper / light) ----------
#let c-cream   = rgb("#FBFAF4")
#let c-ink     = rgb("#2B2620")
#let c-rule    = rgb("#E5DFCE")
#let c-label   = rgb("#A99E83")
#let c-muted   = rgb("#8A8069")
#let c-faint   = rgb("#C3BBA6")
#let c-green   = rgb("#2E9E5B")
#let c-amber   = rgb("#C6971F")
#let c-red     = rgb("#BE4A3A")
#let c-green-bg = rgb("#E7F3EC")
#let c-amber-bg = rgb("#F6EFD9")
#let c-strike  = rgb("#A89F8E")

// ---------- palette (terminal / dark) ----------
#let d-bg      = rgb("#12141A")
#let d-bar     = rgb("#0F1116")
#let d-border  = rgb("#2C2F3A")
#let d-text    = rgb("#E6E7EA")
#let d-dim     = rgb("#8A8F9C")
#let d-green   = rgb("#57C083")
#let d-amber   = rgb("#D9B45A")
#let d-red     = rgb("#E07A6E")
#let del-bg     = rgb("#3A1E20")
#let del-gutter = rgb("#4A2225")
#let del-word   = rgb("#6B2E2E")
#let add-bg     = rgb("#16301F")
#let add-gutter = rgb("#1C3A24")
#let add-word   = rgb("#245C34")

// ---------- fonts ----------
// Korean fallbacks appended to every family so KR glyphs always resolve
// regardless of which Noto variant is installed on the build machine.
#let kr-fallback = ("Noto Serif KR", "Noto Sans KR", "Apple SD Gothic Neo", "Malgun Gothic", "AppleGothic")
#let f-serif = ("Noto Serif",) + kr-fallback
#let f-sans  = ("Helvetica Neue", "Arial") + kr-fallback
#let f-mono  = ("JetBrains Mono", "Nanum Gothic Coding") + kr-fallback

// ---------- small helpers ----------
#let tlabel(txt, fill: c-label, size: 7.5pt) = text(
  font: f-sans, size: size, weight: 700, fill: fill, tracking: 1.4pt,
)[#upper(txt)]

#let dot(col) = box(width: 9pt, height: 9pt, radius: 4.5pt, fill: col)

#let legend-dot(col, lbl) = box(baseline: 1pt)[
  #box(width: 8pt, height: 8pt, radius: 2pt, fill: col) #h(3pt) #text(size: 10pt, fill: c-muted)[#lbl]
]

// side(): begin a fresh card face with its own page fill + margin
#let side(fill, margin, body) = {
  pagebreak(weak: true)
  set page(..CARD, fill: fill, margin: margin)
  body
}

// ---------- inline marking (used by 3a proofread + 2c highlight) ----------
//  segment kinds: keep | del | ins | correct | vague | wrong
#let mark(s) = {
  let k = s.kind
  if k == "keep" { s.text }
  else if k == "del" { strike(stroke: 0.6pt + c-red, text(fill: c-strike, s.text)) }
  else if k == "ins" { text(fill: c-red, style: "italic", s.text) }
  else if k == "correct" {
    underline(stroke: 1.4pt + c-green, offset: 2pt,
      highlight(fill: c-green-bg, extent: 1.5pt, s.text))
  }
  else if k == "vague" { highlight(fill: c-amber-bg, extent: 1.5pt, s.text) }
  else if k == "wrong" { strike(stroke: 0.9pt + c-red, text(fill: c-strike, s.text)) }
  else { s.text }
}
#let render-inline(segs) = segs.map(mark).join()

// ---------- diff line rendering (used by 1c) ----------
//  word segments: (text: "...", mark: true|false)
#let diff-line(segs, wordbg) = segs.map(w => {
  if w.mark { box(fill: wordbg, inset: (x: 2pt), outset: (y: 1.5pt), radius: 2pt, w.text) }
  else { w.text }
}).join()

#let diff-row(sign, gcol, lbg, scol, wordbg, segs) = grid(
  columns: (24pt, 1fr),
  block(fill: gcol, width: 24pt, height: 100%, inset: (y: 7pt))[
    #align(center)[#text(fill: scol, weight: 700)[#sign]]
  ],
  block(fill: lbg, width: 100%, inset: (x: 10pt, y: 7pt))[#diff-line(segs, wordbg)],
)

// =============================================================
//  TEMPLATE 3a — ACADEMIC (serif, red-pen proofread, no score)
// =============================================================
#let academic-front(d) = side(c-cream, (x: 40pt, y: 30pt))[
  #set text(font: f-serif, fill: c-ink, size: 12pt)
  #grid(rows: (auto, 1fr, auto), row-gutter: 0pt,
    [
      #grid(columns: (1fr, auto),
        tlabel("Concept · 개념"),
        align(right)[#tlabel(d.topic)])
      #v(9pt)
      #line(length: 100%, stroke: 0.5pt + c-rule)
    ],
    align(center + horizon)[
      #text(size: 42pt, weight: 600)[#d.concept]
      #v(4pt)
      #text(size: 18pt, fill: c-muted)[#d.korean]
      #v(10pt)
      #text(font: f-sans, size: 9pt, fill: c-label, tracking: 0.5pt)[#d.pron]
    ],
    [
      #line(length: 100%, stroke: 0.5pt + c-rule)
      #v(8pt)
      #align(center)[
        #text(style: "italic", size: 13pt, fill: rgb("#4A4335"))[#d.prompt] \
        #text(size: 10pt, fill: c-muted)[#d.prompt-kr]
      ]
      #v(9pt)
      #grid(columns: (1fr, auto),
        tlabel(d.deck, fill: c-faint, size: 7pt),
        align(right)[#tlabel("No. " + d.index, fill: c-faint, size: 7pt)])
    ])
]

#let academic-back(d) = side(c-cream, (x: 40pt, top: 30pt, bottom: 30pt))[
  #set text(font: f-serif, fill: c-ink, size: 12pt)
  #grid(columns: (1fr, auto), align: (bottom, bottom),
    text(size: 22pt, weight: 600)[#d.concept #text(fill: c-muted, weight: 400)[#d.korean]],
    tlabel("Marked · " + d.date, fill: c-faint, size: 8pt))
  #v(8pt)
  #line(length: 100%, stroke: 0.5pt + c-rule)
  #v(10pt)
  #grid(columns: (1fr, 165pt),
    [
      #tlabel("Your response, corrected · 첨삭")
      #v(8pt)
      #par(leading: 8pt)[#text(size: 13pt)[#render-inline(d.corrections)]]
    ],
    block(inset: (left: 18pt), stroke: (left: 0.5pt + c-rule))[
      #tlabel("In the margin")
      #v(10pt)
      #for n in d.notes [
        #grid(columns: (12pt, 1fr), column-gutter: 4pt,
          text(fill: n.color, weight: 700)[#n.sign],
          text(size: 11pt, style: "italic", fill: rgb("#4A4335"))[#n.text])
        #v(9pt)
      ]
    ])
]

// =============================================================
//  TEMPLATE 2c — CLEAN (sans, marked-up answer + fixes + ref)
// =============================================================
#let clean-front(d) = side(white, (x: 34pt, y: 28pt))[
  #set text(font: f-sans, fill: rgb("#1A1A1A"), size: 12pt)
  #grid(rows: (auto, 1fr, auto), row-gutter: 0pt,
    grid(columns: (1fr, auto),
      tlabel("Concept · 개념", fill: rgb("#A3A099")),
      align(right)[#tlabel(d.index, fill: rgb("#A3A099"))]),
    align(horizon)[
      #text(size: 40pt, weight: 700)[#d.concept]
      #v(4pt)
      #text(size: 20pt, fill: rgb("#787468"))[#d.korean]
      #v(10pt)
      #tlabel("Noun · Physics", fill: rgb("#B5B1A6"))
    ],
    [
      #line(length: 100%, stroke: 0.5pt + rgb("#ECECEA"))
      #v(10pt)
      #grid(columns: (1fr, auto),
        text(size: 13pt, fill: rgb("#4A4740"))[#d.prompt],
        align(right)[#text(size: 11pt, fill: rgb("#B5B1A6"))[소리내어 설명]])
    ])
]

#let clean-back(d) = side(white, (x: 30pt, y: 26pt))[
  #set text(font: f-sans, fill: rgb("#1A1A1A"), size: 12pt)
  #grid(columns: (1fr, auto), align: (horizon, horizon),
    text(size: 19pt, weight: 700)[#d.concept #text(fill: rgb("#A3A099"), weight: 500)[#d.korean]],
    box[#legend-dot(c-green, "correct") #h(8pt) #legend-dot(c-amber, "vague") #h(8pt) #legend-dot(c-red, "wrong")])
  #v(4pt)
  #tlabel("Your answer, marked up · 음성 기록", fill: rgb("#A3A099"))
  #v(5pt)
  #par(leading: 5pt)[#text(size: 12pt)[#render-inline(d.marked)]]
  #v(6pt)
  #for f in d.fixes [
    #grid(columns: (54pt, 1fr), column-gutter: 10pt,
      text(size: 11pt, weight: 700, fill: f.color)[#f.tag],
      text(size: 11pt, style: "italic", fill: rgb("#4A4335"))[#f.text])
    #v(4pt)
  ]
  #v(2pt)
  #line(length: 100%, stroke: 0.5pt + rgb("#ECECEA"))
  #v(4pt)
  #text(size: 11pt, fill: rgb("#6B6860"))[
    #text(font: f-sans, weight: 700, size: 9pt, fill: rgb("#A3A099"), tracking: 0.8pt)[REF · ]#d.reference
  ]
]

// =============================================================
//  TEMPLATE 1c — TERMINAL (mono, GitHub-style diff hunk)
// =============================================================
#let term-front(d) = side(d-bg, 0pt)[
  #set text(font: f-mono, fill: d-text, size: 11pt)
  #grid(rows: (auto, 1fr, auto), row-gutter: 0pt,
    block(width: 100%, fill: d-bar, inset: (x: 14pt, y: 10pt), stroke: (bottom: 0.5pt + d-border))[
      #grid(columns: (auto, auto, auto, 1fr), column-gutter: 6pt, align: horizon,
        dot(d-red), dot(d-amber), dot(d-green),
        text(size: 10pt, fill: d-dim)[#h(2pt)#("card_" + d.index + ".typ") · concept · 개념])
    ],
    block(inset: (x: 26pt), height: 100%)[
      #align(horizon)[
        #text(size: 10pt, fill: rgb("#5CB0C9"))[\/\/ recall prompt · thermodynamics]
        #v(12pt)
        #text(size: 42pt, weight: 700, fill: white)[#d.concept]
        #v(4pt)
        #text(size: 18pt, fill: d-dim)[#d.korean]
        #v(16pt)
        #text(size: 12pt)[#text(fill: d-green)[\$] #text(fill: rgb("#D6D8DC"))[explain --aloud --your-own-words]]
        #v(6pt)
        #text(size: 11pt, fill: d-dim)[→ 당신의 말로 설명해 보세요]
      ]
    ],
    block(width: 100%, inset: (x: 14pt, y: 10pt), stroke: (top: 0.5pt + d-border))[
      #grid(columns: (1fr, auto),
        text(size: 10pt, fill: d-dim)[deck: thermodynamics],
        align(right)[#text(size: 10pt, fill: d-dim)[#d.index]])
    ])
]

#let term-back(d) = side(d-bg, 0pt)[
  #set text(font: f-mono, fill: d-text, size: 11pt)
  #grid(rows: (auto, 1fr, auto), row-gutter: 0pt,
    block(width: 100%, fill: d-bar, inset: (x: 14pt, y: 10pt), stroke: (bottom: 0.5pt + d-border))[
      #grid(columns: (1fr, auto), align: horizon,
        text(size: 11pt, fill: d-dim)[#d.concept · #d.korean #text(fill: rgb("#5B5F6B"))[— eval.typ]],
        align(right)[#text(size: 10pt, fill: rgb("#5B5F6B"))[eval.typ]])
    ],
    block(inset: (x: 18pt, top: 16pt), height: 100%)[
      #text(size: 9pt, fill: d-dim, tracking: 1pt)[#upper("your answer, corrected · 음성 기록")]
      #v(9pt)
      #block(width: 100%, radius: 6pt, clip: true, stroke: 0.5pt + d-border)[
        #diff-row("-", del-gutter, del-bg, d-red, del-word, d.del)
        #diff-row("+", add-gutter, add-bg, d-green, add-word, d.add)
      ]
    ],
    block(width: 100%, inset: (x: 18pt, y: 10pt))[
      #grid(columns: (1fr, auto),
        text(size: 10pt, fill: rgb("#5B5F6B"))[reviewed #d.date],
        align(right)[#text(size: 10pt, fill: rgb("#5B5F6B"))[next +3d]])
    ])
]

// convenience: render one card, both faces, in a chosen template
#let card(template, d) = {
  if template == "academic" { academic-front(d); academic-back(d) }
  else if template == "clean" { clean-front(d); clean-back(d) }
  else if template == "terminal" { term-front(d); term-back(d) }
}

// =============================================================
//  SAMPLE DATA (the "Entropy / 엔트로피" card)
//  This is the data shape your Go generator should emit.
// =============================================================
#let sample = (
  concept: "Entropy",
  korean: "엔트로피",
  pron: [/ˈɛntrəpi/ · noun · physics],
  topic: "Thermodynamics",
  deck: "Thermodynamics deck",
  index: "04 / 24",
  date: "2026·07·06",
  prompt: "Explain it aloud, in your own words.",
  prompt-kr: "당신의 말로 설명해 보세요.",

  // 3a — proofread inline (keep | del | ins)
  corrections: (
    (kind: "keep", text: "Entropy is basically how "),
    (kind: "del",  text: "messy"),
    (kind: "ins",  text: " the number of microstates in"),
    (kind: "keep", text: " a system is — and it only ever goes up"),
    (kind: "ins",  text: " in an isolated system"),
    (kind: "keep", text: ", "),
    (kind: "del",  text: "never down"),
    (kind: "keep", text: "."),
  ),
  notes: (
    (sign: "✓", color: c-green, text: [Right direction — disorder increases.]),
    (sign: "✗", color: c-red,   text: [“Messy” struck — name the *microstates*.]),
    (sign: "✗", color: c-red,   text: [Added the *isolated-system* condition.]),
  ),

  // 2c — marked-up (keep | correct | vague | wrong)
  marked: (
    (kind: "keep",    text: "Entropy is basically how "),
    (kind: "vague",   text: "messy"),
    (kind: "keep",    text: " a system is — and it "),
    (kind: "correct", text: "goes up over time"),
    (kind: "keep",    text: ", "),
    (kind: "wrong",   text: "never down"),
    (kind: "keep",    text: "."),
  ),
  fixes: (
    (tag: "△ vague", color: c-amber, text: [“Messy” → say the *number of microstates* / energy dispersal.]),
    (tag: "+ add",   color: c-red,   text: [Only increases *in an isolated system* — the missing condition.]),
  ),
  reference: "Number of microstates available to a system; increases in an isolated system (2nd law).",

  // 1c — diff rows (word segments: text + mark)
  del: (
    (text: "Entropy is basically how ", mark: false),
    (text: "messy", mark: true),
    (text: " a system is — and it only ever goes up, ", mark: false),
    (text: "never down", mark: true),
    (text: ".", mark: false),
  ),
  add: (
    (text: "Entropy is basically ", mark: false),
    (text: "the number of microstates in", mark: true),
    (text: " a system — and it only ever goes up ", mark: false),
    (text: "in an isolated system", mark: true),
    (text: ".", mark: false),
  ),
)
