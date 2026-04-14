#set page(
  width: 13in,
  height: 12.75in,
  margin: 0.75in,
)

#set text(
  size: 10pt,
)

#set table(
  inset: 6pt,
  stroke: 0.5pt + gray
)

$if(highlighting-definitions)$
$highlighting-definitions$
$endif$

#let horizontalrule = line(start: (0%,0%), end: (100%,0%), stroke: 0.5pt + gray)

$body$