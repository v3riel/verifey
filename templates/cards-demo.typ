// Demo: renders the Entropy sample card in all three templates.
//   typst compile cards-demo.typ cards.pdf
//
// Order of pages:
//   1–2  academic (3a)  front / back
//   3–4  clean    (2c)  front / back
//   5–6  terminal (1c)  front / back

#import "flashcards.typ": card, sample

#card("academic", sample)
#card("clean", sample)
#card("terminal", sample)
