<!-- #intro -->

Before pocket calculators, engineers multiplied with a ruler that slides. Line up two numbers on two scales and the answer sits under a hairline, ready to read to about three figures. Start with two plain rulers that add, then space the numbers differently and watch the same slide multiply. {.lede}

Drag the slide, or the cursor (the clear window with a line down its middle), or tap the rule to send the cursor there. With the keyboard, Tab to the slide or the cursor and use the arrow keys: <kbd>Shift</kbd> moves further. {.howto}

<!-- #station-1 -->

Lay one ruler along another. Slide the top one until its 0 sits over 3 on the bottom one. Now every number on the top ruler sits over itself plus 3: the cursor on 4 above finds 7 below. **Sliding adds lengths, and on these rulers the lengths are the numbers.** The bars under the rulers show the two lengths laid end to end.

<!-- #station-1-note -->

Run it backwards to subtract. Put the cursor on 9 on the bottom ruler, slide the top ruler until its 4 is under the hairline, and its 0 points at 9 − 4 = 5. Station 2 keeps the slide and changes where the numbers go. {.note}

<!-- #station-2 -->

Now space the numbers differently. Put 1 at the left end and 10 at the right end of the top ruler, and every number in between at its **logarithm**: the power you raise 10 to to get it. [Logarithms](../logarithms/) builds the idea up from counting hops. 10<sup>0.301</sup> = 2, so log 2 = 0.301, and 2 sits 0.301 of the way along. log 3 = 0.477 puts 3 a little short of halfway. The bottom ruler carries on past 10 to 100, spaced the same way.

Slide exactly as before. The top ruler's 1 over 2, the cursor on 3, and below it you read 6. The lengths still add: 0.301 + 0.477 = 0.778, and 6 sits at 0.778. **Adding the logs of two numbers gives the log of their product**, so the slide that added in Station 1 multiplies here.

<!-- #station-2-note -->

Look at where 2, 4, and 8 fall on the bottom ruler: equal steps apart, and so are 25, 50, and 100. Doubling is the same length wherever you start, so the numbers crowd together toward the right. {.note}

<!-- #station-3 -->

Look again at Station 2's bottom ruler. The stretch from 10 to 100 is an exact copy of the stretch from 1 to 10: 20 sits where 2 does, and 35 where 3.5 does, one copy further along. Multiplying by 10 is always the same length, so **every power of 10 starts the same pattern over**. This ruler runs from 0.1 to 100, three copies end to end, and the slide is one copy long. Slide it along: it fits each copy exactly, and the cursor shows the same digits in each one.

<!-- #station-3-note -->

So a slide rule only needs one copy, 1 to 10, and that's all it carries. The price is that **it only shows the digits**. A reading of 1.2 could mean 0.12, 1.2, 12, or 120, and you choose with a rough sum in your head: round each number to one figure and multiply. For 3 × 4 that's just 3 × 4 = 12, nowhere near 0.12 or 120. Try it: the rule's reading is given, and you place the point. {.note}

<!-- #station-4 -->

A real slide rule carries one copy on the slide and one on the body. The slide's scale is called **C**, and the one under it on the fixed body, the **stock**, is called **D**. Both run from 1 to 10, and the 1 at each end of C is called an **index**. To multiply, put C's left index over the first number on D, move the cursor to the second number on C, and read the answer on D under the hairline.

With one copy, 3 × 4 falls off the end of D. So use the other index: put C's **right** index over 3, and the cursor on 4 finds 1.2 on D. Those are the digits of 12, and Station 3's rough sum puts the point back. To divide, run it backwards: put the cursor on the first number on D, slide the second number on C under the hairline, and read the answer on D under C's index. Type a problem, or pick one, then step through it.

<!-- #station-5 -->

Every other scale is a way of relabeling D, read through the cursor. **A** squeezes two copies of C's spacing into the same length, so 3 on D sits under 9 on A, its square. **K** squeezes in three copies, for cubes. **CI** is C running backwards, so it reads 1 ÷ C. **L** is evenly spaced and reads the logarithm of D: the distance Station 2 measured. **S** and **T** mark angles where 10 × their sine and 10 × their tangent fall on D. Move the cursor and every scale gives its reading at once. Turn scales off to see fewer.

<!-- #station-5-note -->

Reading backwards works too. Put the cursor on a number on A and read its square root on D, or on K for a cube root. A has two halves, 1 to 10 and 10 to 100: count the digits in front of the decimal point and use the left half when there's an odd number of them, so √2 comes from the left half and √20 from the right. {.note}

<!-- #station-6 -->

Bend D into a ring and its two ends meet, with 10 landing on 1. On a **circular slide rule**, C is a disc that turns inside that ring, so nothing can run off the end. Turn the disc to put its 1 at 3 on D, swing the cursor arm to 4 on the disc, and the arm points at 1.2 on D, with no index to swap. The answer still comes out as digits, and the decimal point is still yours to place.

<!-- #notes -->

- **Three figures is the usual limit.** Between 1 and 2 on D the ticks run every 0.01, so you can read 1.23 and guess at 1.234. Past 4 they run every 0.05, and three figures is about all you get. That's close enough for most engineering, where the measurements going in rarely have more.
- **The error is a share, not an amount.** Misreading by the width of a hairline is the same fraction of the number anywhere on the rule, about a tenth of a percent on a 25 cm rule. A calculator's error works the other way: it's tiny everywhere.
- **Set a ratio once and read a whole table.** Put C's left index over 1.609 on D and each number on C sits over its value in kilometers: 5 miles over 8.05, 26.2 over 42.2, until C runs past the end of D and you swap to the right index. Dividing or converting a column of numbers by the same amount takes one setting.
- **A slide rule can't add.** It only multiplies and divides, because sliding adds logs. Engineers did their adding on paper.
- **The trig scales borrow D's digits.** sin 30° is 0.5, but S puts 30° over 5 on D, so you place the decimal point there too. Angles under about 5.7° have sines under 0.1 and fall off the left end. For small angles the sine is nearly the angle in radians, as [Circles and Triangles](../circles-and-triangles/) shows.
- **Floats space themselves the same way.** A computer's floating-point numbers sit closer together near 0 and farther apart as they grow, the gaps doubling with each power of 2, much like the crowding toward the right of C and D. The [Minifloat Ruler](../minifloat-ruler/) lays every value of an 8-bit float along one line.
- **Tables came first.** Before and beside slide rules, people multiplied with books of logarithm tables: look up two logs, add them, and look the sum up backwards, to four figures or more. [Logarithms](../logarithms/) works a problem that way in its last station.
- **Base 10 is a choice.** Logs in any base turn multiplying into adding. Base 10 makes the scale repeat for each power of 10, which is why the rule only shows digits. The natural log uses <span class="v">e</span> instead, the number [Exploring <span class="v">e</span>](../exploring-e/) builds.

<!-- #history -->

- **Logarithms.** John Napier published *Mirifici logarithmorum canonis descriptio* in 1614. Its preface says nothing is "so troublesome to mathematical practice" as multiplying and dividing large numbers, and logarithms turn those into adding and subtracting. Napier's logarithms weren't in base 10.
- **Base 10.** Henry Briggs suggested base 10 to Napier, and when the two met in 1615 Napier proposed that the log of 1 should be 0. Briggs published a table of base-10 logarithms, *Logarithmorum chilias prima*, in 1617.
- **One scale and a pair of dividers.** Edmund Gunter marked a logarithmic scale along a single ruler about two feet long. To multiply, you opened a pair of dividers to one length and stepped it off from the other, adding the lengths as Station 2 does. Gunter described it in print in 1623, and sailors called the ruler "the gunter."
- **Two scales and no dividers.** William Oughtred put two of Gunter's scales against each other and slid one along the other, so the dividers were no longer needed. He invented a circular version in 1630, described in *The Circles of Proportion*, which his pupil William Forster translated from Oughtred's Latin and published in 1632. Richard Delamain published his own circular rule in *Grammelogia* in 1630, and the two quarreled bitterly over who was first. They may have arrived at it separately.
- **The modern layout.** The straight slide rule's familiar form was designed in 1850 by Amédée Mannheim, a French army officer.

<!-- #sources -->

- J. J. O'Connor and E. F. Robertson, ["John Napier"](https://mathshistory.st-andrews.ac.uk/Biographies/Napier/), MacTutor History of Mathematics.
- J. J. O'Connor and E. F. Robertson, ["Henry Briggs"](https://mathshistory.st-andrews.ac.uk/Biographies/Briggs/), MacTutor History of Mathematics.
- J. J. O'Connor and E. F. Robertson, ["Edmund Gunter"](https://mathshistory.st-andrews.ac.uk/Biographies/Gunter/), MacTutor History of Mathematics.
- J. J. O'Connor and E. F. Robertson, ["William Oughtred"](https://mathshistory.st-andrews.ac.uk/Biographies/Oughtred/), MacTutor History of Mathematics, for Oughtred's straight and circular rules, Delamain, Forster, and Mannheim.
