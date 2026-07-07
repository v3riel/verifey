
#let data = json("../words.json")

#let title = datetime.today().display("[month repr:long] [day], [year]")

#set document(title: [#title Flashcard], author: "Verifey")
#set page(
  width: 5.5in,
  height: 3.5in,
  margin: (x: 1cm, y: 1cm),
  // header: context {
  //   if here().page() > 1 {
  //     align(right, text(size: 8pt, fill: luma(40%), [#title]))
  //   }
  // },
  // numbering: "1",
)
