<!-- #intro -->

A logarithm counts multiplications. Start at 1, multiply by 2 three times, and you reach 8, so the logarithm of 8 in base 2 is 3. That one idea turns multiplying into adding, tells you how many digits a number has, and filled the books of tables that people calculated with for three hundred years. {.lede}

Drag the points on the boards, or Tab to them and use the arrow keys (<kbd>Shift</kbd> moves further). Letter keys shown on a button go to the station you're using. {.howto}

<!-- #station-1 -->

Stand on 1 and hop. Each hop multiplies where you are by 2: 1, 2, 4, 8. **The number of hops it takes to reach a number is its logarithm**, written log<sub>2</sub>, with the 2 saying what each hop multiplies by. That 2 is the **base**. log<sub>2</sub> 8 = 3, because three hops get you there. Most numbers fall between landing spots, so the last hop is only part of one: 10 is 3.32 hops, three whole hops to 8 and a third of a hop more. Hop backward to divide, and numbers below 1 have negative logarithms. Drag the target, or pick a base.

<!-- #station-2 -->

Hops of ×10 count digits. 10 is one hop, 100 is two, 1,000 is three, and every number with four digits lies between 1,000 and 10,000, so its log<sub>10</sub> is between 3 and 4. **A whole number's log<sub>10</sub> is one less than its digit count, plus a fraction.** That makes the log a quick way to say how big a number is, even one too long to read. In base 2 the same count gives the bits a computer needs to store it. Type a number, a power like `2^100`, or a factorial like `100!`.

<!-- #station-3 -->

In 1544 Michael Stifel lined up two rows: hops along the top, and where each one lands in base 2 underneath. Pick two numbers in the bottom row and add their hops. The total lands on their product, because **hops add when numbers multiply**: 8 is 3 hops and 32 is 5, and 3 + 5 = 8 hops lands on 256. Dividing subtracts hops, squaring doubles them, and a square root halves them. Pick an operation, then pick numbers.

<!-- #station-4 -->

The rows only cover whole hops. To fill in the gaps, take square roots. √10 is half a hop of ×10, so log<sub>10</sub> √10 = ½. Its square root is a quarter of a hop, the next is an eighth, and each new root is a smaller step. **Any number can be built by multiplying some of these roots together, and its logarithm is the sum of their fractions.** Take more roots and watch the sum close in on the real logarithm. Henry Briggs started his base-10 tables this way, taking the square root of 10 fifty-four times in a row, by hand.

<!-- #station-4-note -->

Each row divides out a root if it fits, and the leftover shrinks toward 1. A number just above 1 has a logarithm of about 0.4343 × its distance above 1, which is how the last digits can be finished without taking roots forever. {.note}

<!-- #station-5 -->

Every base draws the same curve. A bigger base needs fewer hops to reach anything, so its curve is lower, but only stretched: base 2's curve is base 10's made 3.32 times taller, because log<sub>2</sub> 10 = 3.32. **So log<sub>b</sub> <span class="v">x</span> = log <span class="v">x</span> ÷ log <span class="v">b</span>, in any base you like**, which is how a calculator with one log button finds the rest. Every curve passes through 1 at height 0, since no hops reach 1, and through its own base at height 1. Drag the base, or pick one. The base <span class="v">e</span> ≈ 2.718 gives the **natural logarithm**, written ln.

<!-- #station-6 -->

Growth by the same percentage each step is multiplying by the same number each step: hops. On an ordinary axis it hugs the floor, then shoots off the top. Put the axis on a log scale, where each power of 10 is the same height, and **steady percentage growth becomes a straight line**, its slope the log of the growth factor. A straight line on an ordinary axis bends over on a log one. Both series below start at 1 and end at the same height.

<!-- #station-7 -->

Before calculators, and beside every slide rule, sat a book of logarithm tables. To multiply, you looked up each number's logarithm, added the two, and looked the sum up backwards. The table gives only the fraction, called the **mantissa**. The whole-number part, the **characteristic**, is the digit count less one from Station 2, and that's where the decimal point goes. Type a problem, or pick one, then step through it.

<!-- #notes -->

- **Logarithms turn powers into multiplying.** <span class="v">x</span><sup>3</sup> is three copies of <span class="v">x</span> multiplied, so its log is 3 × log <span class="v">x</span>. That's how log tables took cube roots: divide the log by 3 and look it up backwards.
- **No number of hops reaches 0.** Each backward hop halves what's left, and halving never gets to nothing, so log 0 doesn't exist. Negative numbers have no logarithm either: multiplying positive numbers keeps them positive.
- **Many measuring scales are logarithms.** A sound 10 decibels louder carries 10 times the power. A pH lower by 1 means 10 times as acidic. A star 5 magnitudes brighter gives off 100 times the light. Each is a count of hops, so huge ranges fit on a short scale.
- **The rule of 72.** Growth of <span class="v">r</span> percent a step doubles in about 72 ÷ <span class="v">r</span> steps. The exact count is log 2 ÷ log(1 + <span class="v">r</span>/100), and 72 is a round number that comes close for everyday rates. Station 6 shows both.
- **Leading 1s are common.** In many collections of real numbers, like populations or prices, about 30% start with the digit 1 and under 5% start with 9. On a log scale the stretch from 1 to 2 is 30% of the way from 1 to 10, the same log<sub>10</sub> 2 = 0.301 as Station 4. Simon Newcomb noticed it in 1881 from library log tables, whose first pages were the most worn. Frank Benford stated it again in 1938, and it's called Benford's law.
- **Floats keep their logarithm in plain view.** A computer stores a floating-point number's whole-number log<sub>2</sub> in its exponent field, which is why the gaps between floats double at every power of 2. The [Minifloat Ruler](../minifloat-ruler/) and the [Bitfield Explorer](../bitfield-explorer/) show the field.
- **A slide rule is Station 3 made of wood.** Space numbers by their logs along a ruler and sliding adds lengths, so it multiplies. [Slide Rules](../slide-rules/) builds one from two plain rulers.
- **The natural log is about growth.** ln <span class="v">x</span> is how long something growing continuously at 100% takes to reach <span class="v">x</span>. [Exploring <span class="v">e</span>](../exploring-e/) builds <span class="v">e</span> from that kind of growth.

<!-- #history -->

- **Two rows.** Michael Stifel's *Arithmetica integra* of 1544 set 1, 2, 3, 4, 5 against 2, 4, 8, 16, 32, and carried the rows backward so that 0 goes with 1, −1 with ½, and −2 with ¼. Those are Station 3's rows.
- **Napier.** John Napier published *Mirifici logarithmorum canonis descriptio* in 1614, to spare people the long multiplying and dividing that his preface calls the most troublesome part of mathematical practice. His logarithms weren't in base 10.
- **Bürgi, separately.** The Swiss clockmaker Jost Bürgi made tables of his own, probably around 1588, though they weren't printed until 1620. His method differs from Napier's and was invented independently. Kepler, who worked with him in Prague, wrote that Bürgi reached logarithms many years before Napier's appeared.
- **Base 10.** Henry Briggs suggested base 10 to Napier, and when they met in 1615 Napier proposed that the log of 1 should be 0. Briggs's *Arithmetica logarithmica* of 1624 gave the logarithms of 1 to 20,000 and of 90,000 to 100,000, to 14 decimal places. Adriaan Vlacq filled in the gap from 20,000 to 90,000 in an edition printed at Gouda in 1628.
- **Fifty-four square roots.** Briggs began by taking the square root of 10 over and over, fifty-four times, carrying more than thirty decimal places, and built logarithms from the roots as Station 4 does.
- **Worn pages.** In 1881 Simon Newcomb noticed that the first pages of log tables, the numbers starting with 1, were more worn than the rest. Frank Benford stated the pattern again in 1938, and it took his name.

<!-- #sources -->

- J. J. O'Connor and E. F. Robertson, ["Michael Stifel"](https://mathshistory.st-andrews.ac.uk/Biographies/Stifel/), MacTutor History of Mathematics.
- J. J. O'Connor and E. F. Robertson, ["John Napier"](https://mathshistory.st-andrews.ac.uk/Biographies/Napier/), MacTutor History of Mathematics.
- J. J. O'Connor and E. F. Robertson, ["Jost Bürgi"](https://mathshistory.st-andrews.ac.uk/Biographies/Burgi/), MacTutor History of Mathematics.
- J. J. O'Connor and E. F. Robertson, ["Henry Briggs"](https://mathshistory.st-andrews.ac.uk/Biographies/Briggs/), MacTutor History of Mathematics.
- Denis Roegel, ["A reconstruction of the tables of Briggs' *Arithmetica logarithmica* (1624)"](https://locomat.loria.fr/briggs1624/briggs1624doc.pdf), LOCOMAT project, for Briggs's fifty-four square roots of 10.
- Simon Newcomb, "Note on the frequency of use of the different digits in natural numbers", *American Journal of Mathematics* 4 (1881), 39–40.
- Frank Benford, "The law of anomalous numbers", *Proceedings of the American Philosophical Society* 78 (1938), 551–572.
- ["Benford's law"](https://en.wikipedia.org/wiki/Benford%27s_law), Wikipedia, for the leading-digit shares.
