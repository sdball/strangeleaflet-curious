<!-- #intro -->

Divide 0 by 0 in JavaScript and you get back NaN, short for not a number. It looks like it's a weird special value. But it's really a whole region of bit patterns that are all represented simply as NaN. In this curio we'll map every NaN in a 16-bit float, see how JavaScript compares NaNs in different ways, take one apart, find out how to store an arbitrary payload in NaN, see some real world uses for different NaN values, and build one in JavaScript. {.lede}

Every map and row of switches works from the keyboard: Tab to it and use the arrow keys (<kbd>Shift</kbd> moves further). Letter keys shown on a button go to the station you're using. {.howto}

<!-- #station-1 -->

A 16-bit float has 65,536 possible bit patterns, and this map has a cell for every one. They're sorted into 64 tiles of 1,024. Every cell in a tile shares the same sign and exponent, the part of a float that says how big it is. **Two whole tiles are NaN**, apart from one corner cell each, which is infinity. Pick any cell to see what it holds.

<!-- #station-1-note -->

That's 2,046 different NaNs among 65,536 patterns: **1,024 quiet and 1,022 signaling**, half of each with the sign bit set. Station 3 explains the difference. A 32-bit float has 16,777,214 NaNs and a 64-bit float, the kind JavaScript uses for every number, has 9,007,199,254,740,990. {.note}

<!-- #station-2 -->

Here are four NaNs at 64 bits, the size JavaScript uses for every number, and one ordinary number to compare them with. Every one of the NaNs prints as `NaN`. Now compare them three ways. **The bits say these are four different values. JavaScript's comparisons can't tell them apart.**

<!-- #station-3 -->

These are the 64 bits of one JavaScript number, sorted into their four fields. **A float is NaN when all 11 exponent bits are on and the bits after them aren't all off.** Turn off any exponent bit and it's an ordinary number again. The first bit after the exponent is the quiet bit. The other 51 are the payload. With the quiet bit on, the payload can be anything, even all zeros. With it off, the NaN is signaling (Station 4), and the payload needs at least one bit on, since all ones followed by all zeros is infinity. That's why Station 1 counts one fewer signaling NaN than quiet for each sign. Past that one rule, nothing about NaN reads the payload, so a program can keep whatever it likes there.

<!-- #station-4 -->

Arithmetic on a NaN gives back a NaN, and the floating-point standard asks that it keep the payload. A **signaling** NaN, with its quiet bit off, is meant to raise an alarm when used, and comes out **quiet**, with the quiet bit on. Pick a NaN and an operation. Your browser does the sum with its own floating point, and every bit that changed is ringed.

<!-- #station-5 -->

Real programs put those spare bits to work. A monitoring system marks the end of a data series with one, a statistics language marks missing data with another, and language runtimes hide whole values inside them, a trick called NaN-boxing. Firefox's and Safari's JavaScript engines [have done it too](https://wingolog.org/archives/2011/05/18/value-representation-in-javascript-implementations). **Pick a specimen and see how each program reads the same 64 bits.**

<!-- #station-6 -->

Type `0x7FF0000000000002` into a JavaScript console hoping for Prometheus's marker and you get back `9218868437227405000`. A hex literal is a whole number, not a bit pattern, and that one is too big to keep exactly. **To get the NaN, write the 64 bits into a buffer and read them back out as a float.** Then see which everyday steps keep those bits in Node. These answers were recorded in Node v25.9.0 on an Apple arm64 Mac. Another version, another JavaScript engine, or another kind of chip may give different answers.

<!-- #station-6-note -->

So treat a marker as bits for as long as you can. Coming in, check the raw bytes before they become a number, with `view.getBigUint64(0) === 0x7FF0000000000002n`. Going out, write the bits with `setBigUint64`, rather than passing a NaN around and writing it at the end. {.note}

<!-- #notes -->

- **NaN is a region, not a value.** Any pattern with the exponent all ones and the rest of the fraction not all zeros is NaN. In Station 1 that's two whole tiles. The same is true at every size, so a 64-bit float has about nine quadrillion NaNs.
- **Printing and comparing can't tell NaNs apart.** `==` says a NaN equals nothing, itself included, and `Object.is` says every NaN is the same as every other. Only the bits show the difference, which is why code that cares, like the [Prometheus](https://github.com/prometheus/prometheus/blob/main/model/value/value.go) monitoring system marking the end of a time series with one particular NaN, compares bits.
- **The sign of a NaN means nothing.** Half of all NaNs have the sign bit set, and they behave exactly like the other half.
- **Two NaNs in, one out.** When both sides of a sum are NaN, the standard says the answer's payload should come from one of them, but not which. Most chips return the first, so `a + b` and `b + a` can come out different. Try `x + y` and `y + x` in Station 4.
- **Not every chip keeps the payload.** Keeping it is a recommendation, not a rule. RISC-V chips give back one standard NaN from most operations whatever went in, and ARM chips have a mode that does the same.
- **Your browser may swap NaNs too.** The JavaScript spec lets an engine store any NaN it likes when it writes a NaN number out as bytes. This page keeps each NaN's bits as a whole number and only turns them into a float to do the sums. Station 6 shows which everyday steps keep a NaN's bits in Node.
- **Which way round the quiet bit goes was once up for grabs.** The 1985 standard that introduced NaNs didn't say which bit pattern means quiet. Most chips, x86 and ARM among them, made a 1 in the top fraction bit mean quiet, but PA-RISC and early MIPS chips used it the other way round. The 2008 revision settled on the first choice.
- **The same 64 bits mean different things to different programs.** In Station 5, `7FFC000000000003` is `true` to clox and the number NaN to everything else, and `FFFFFFFFFFFFFFFF` is `nil` to LuaJIT. Bits only mean something once a program decides how to read them.
- **A marker is only as safe as its check.** Prometheus compares all 64 bits, so one sum that quiets its marker turns it into an ordinary NaN. R checks only the low 32 bits, so its `NA` survives being quieted, though R still doesn't promise which of `NA` and `NaN` a sum mixing them gives back.
- **A marker can earn its own shorthand.** Prometheus's [xor2 storage format](https://github.com/prometheus/prometheus/blob/main/tsdb/chunkenc/xor2.go), added in 2026, squeezes each sample into as few bits as it can. It spots a stale marker by comparing all 64 bits, then stores the marker's value as the three-bit code `111` in place of 64 bits. When the gap since the last sample also matches the gap before it, the five-bit code `11111` stands for the timestamp and the marker together.
- **More to try.** The [bitfield explorer](../bitfield-explorer/) has a NaN tab for trying patterns of your own, and the [minifloat ruler](../minifloat-ruler/) shows where NaN sits among an 8-bit float's other values.

<!-- #sources -->

- IEEE Computer Society, *IEEE Standard for Binary Floating-Point Arithmetic*, IEEE Std 754-1985.
- IEEE Computer Society, *IEEE Standard for Floating-Point Arithmetic*, IEEE Std 754-2008 and IEEE Std 754-2019, section 6.2 on NaN operands and payloads.
- ["NaN"](https://en.wikipedia.org/wiki/NaN), Wikipedia, for the quiet bit's history, payload propagation, and RISC-V's and ARM's default NaNs.
- Agner Fog, ["Parallel floating point exception tracking and NaN propagation"](https://www.agner.org/optimize/nan_propagation.pdf) (2019, updated 2026), for most processors returning the first of two NaNs.
- Ecma International, [*ECMAScript Language Specification*, NumericToRawBytes](https://tc39.es/ecma262/multipage/structured-data.html#sec-numerictorawbytes), for an engine's freedom to choose any NaN encoding when storing a NaN.
- Prometheus, [`model/value/value.go`](https://github.com/prometheus/prometheus/blob/main/model/value/value.go), for `StaleNaN` and `NormalNaN` and the comment explaining the marker's payload; [`model/textparse/promparse.go`](https://github.com/prometheus/prometheus/blob/main/model/textparse/promparse.go) and [`openmetricsparse.go`](https://github.com/prometheus/prometheus/blob/main/model/textparse/openmetricsparse.go), for scraped NaNs becoming `NormalNaN`; and [`tsdb/chunkenc/xor2.go`](https://github.com/prometheus/prometheus/blob/main/tsdb/chunkenc/xor2.go), for the xor2 format's stale codes.
- Robert Nystrom, [*Crafting Interpreters*, section 30.3, "NaN Boxing"](https://craftinginterpreters.com/optimization.html#nan-boxing) (Genever Benning, 2021), for clox's value layout.
- Go, [`src/math/bits.go`](https://github.com/golang/go/blob/master/src/math/bits.go), for the bits of `math.NaN()`.
- The R Project, [`src/main/arithmetic.c`](https://github.com/wch/r-source/blob/trunk/src/main/arithmetic.c), for how `NA` is built and recognized, and the R documentation for [`NA`](https://github.com/wch/r-source/blob/trunk/src/library/base/man/NA.Rd) and [`is.nan`](https://github.com/wch/r-source/blob/trunk/src/library/base/man/is.finite.Rd).
- Mike Pall, LuaJIT 2.1, [`src/lj_obj.h`](https://github.com/LuaJIT/LuaJIT/blob/v2.1/src/lj_obj.h), for its tagged NaNs in the 64-bit (GC64) layout and the one NaN its floating-point unit makes.
- Andy Wingo, ["value representation in javascript implementations"](https://wingolog.org/archives/2011/05/18/value-representation-in-javascript-implementations) (2011), for NaN-boxing in JavaScriptCore and Mozilla's engine.
