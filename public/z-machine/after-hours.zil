"After Hours at the Cabinet: a tiny game for the Cabinet of Curios.

Built to be taken apart. Every room shows off one kind of exit, and the
custom verbs, the two keys, and the lantern give the story file analyzer
something to point at."

<VERSION ZIP>
<CONSTANT RELEASEID 1>

<CONSTANT GAME-BANNER
"After Hours at the Cabinet|
A small curio from the Cabinet of Curios, curious.strangeleaflet.com">

<SETG USE-SCORING? T>
<CONSTANT MAX-SCORE 5>

<ROUTINE GO ()
    <CRLF> <CRLF>
    <TELL "The last bus drops you at the corner just as the lights go out in
the Cabinet of Curios. Every curio on its long shelf wears a numbered paper
tag, starting at No. 1. The curator once told you there's a No. 0 somewhere
inside, the one that explains how all the others work. Tonight you mean to
find it." CR CR>
    <INIT-STATUS-LINE>
    <V-VERSION> <CRLF>
    <SETG HERE ,FRONT-STEPS>
    <MOVE ,PLAYER ,HERE>
    <V-LOOK>
    <MAIN-LOOP>>

<DELAY-DEFINITION PRINT-GAME-OVER>

;"The parser can't read Morse: a period even ends a command. So SEND lines,
  and TAP lines with dots and dashes in them, are taken from the input buffer
  before the parser sees them, and the parser sees a bare SEND."
<REPLACE-DEFINITION HOOK-AFTER-READLINE
    <DEFMAC HOOK-AFTER-READLINE (R-ATOM) '<MORSE-INTERCEPT>>>

<INSERT-FILE "parser">

<SCORING-ACHIEVEMENTS
    (GETTING-IN "for letting yourself in")
    (WINDING "for winding the odometer")
    (SIGNALLING "for calling the back room")
    (SHELVING "for putting No. 0 on the shelf")>

<REPLACE-DEFINITION PRINT-GAME-OVER
    <ROUTINE PRINT-GAME-OVER ()
        <TELL "    ****  You have won  ****" CR>>>

"New verbs"

<SYNTAX WIND OBJECT = V-WIND>
;"no HAVE: a crank already seated in the socket can still be the tool"
<SYNTAX WIND OBJECT WITH OBJECT (HELD CARRIED ON-GROUND IN-ROOM) = V-WIND>
<SYNTAX WIND UP OBJECT = V-WIND>

<SYNTAX TURN OBJECT (TOUCH) = V-TURN>

<SYNTAX FIT OBJECT (HELD CARRIED) IN OBJECT (TOUCH) = V-PUT-IN>

<SYNTAX TAP OBJECT (TOUCH) = V-TAP>
<SYNTAX TAP ON OBJECT (TOUCH) = V-TAP>

<SYNTAX SEND = V-SEND>

<SYNTAX LIGHT OBJECT (TOUCH) = V-LIGHT>
<SYNTAX LIGHT OBJECT (TOUCH) WITH OBJECT (HAVE HELD CARRIED) = V-LIGHT>
<VERB-SYNONYM LIGHT KINDLE IGNITE STRIKE>

<SYNTAX EXTINGUISH OBJECT (TOUCH) = V-EXTINGUISH>
<SYNTAX BLOW OUT OBJECT (TOUCH) = V-EXTINGUISH>
<VERB-SYNONYM EXTINGUISH DOUSE SNUFF>

<SYNTAX LIFT OBJECT (TOUCH) = V-LIFT>
<SYNTAX MOVE OBJECT (TOUCH) = V-LIFT>
<VERB-SYNONYM LIFT RAISE>

;"the telegraph key has a knob to press"
<VERB-SYNONYM PUSH PRESS DEPRESS>

<SYNTAX CLIMB UP OBJECT (TOUCH) = V-CLIMB>
<SYNTAX CLIMB DOWN OBJECT (TOUCH) = V-CLIMB-DOWN>

<SYNTAX XYZZY = V-XYZZY>
<VERB-SYNONYM XYZZY PLUGH>

<ROUTINE V-WIND ()
    <TELL "There's nothing to wind on " T ,PRSO "." CR>>

<ROUTINE V-TURN ()
    <TELL "Turning " T ,PRSO " gets you nowhere." CR>>

<ROUTINE V-TAP ()
    <TELL "Tap, tap. Nothing comes of it." CR>>

<ROUTINE V-SEND ()
    <COND (<N==? ,HERE ,TELEGRAPH-OFFICE>
           <TELL "There's nothing here to send a message with." CR>)
          (,MORSE-WORDS?
           <TELL "The key only speaks Morse. Spell your message in dots and
dashes, with a space between letters. The chart on the wall shows how." CR>)
          (<0? ,MORSE-LEN>
           <TELL "Spell your message in dots and dashes after SEND, with a
space between letters. SEND ... --- ... would send SOS." CR>)
          (,BACK-DOOR-OPEN
           <TELL "You tap out your message. The sounder stays quiet. The back
room has already heard you." CR>)
          (<MORSE-UNLATCHES?>
           <OPEN-BACK-DOOR>
           <AWARD-POINTS 1 ,ACH?SIGNALLING>
           <TELL "You tap out your message, letter by letter. For a moment,
nothing. Then, from across the gallery, comes the scrape of a door sliding
open." CR>)
          (ELSE
           <TELL "You tap out your message. The sounder clicks it back the way
the far end heard it: ">
           <PRINT-MORSE>
           ;"the reply gets a line to itself: wrapping could split a letter,
             and a period after it would read as part of the code"
           <TELL ". Then it adds:" CR CR "   .-- .... .- -" CR CR
"The line goes quiet." CR>)>>

<ROUTINE V-LIGHT ()
    <TELL "You can't light " T ,PRSO "." CR>>

<ROUTINE V-EXTINGUISH ()
    <TELL CT ,PRSO " isn't burning." CR>>

<ROUTINE V-LIFT ()
    <TELL "You shift " T ,PRSO " a little. Nothing comes of it." CR>>

<ROUTINE V-CLIMB-DOWN ()
    <TELL "You can't climb down " T ,PRSO "." CR>>

<ROUTINE V-XYZZY ()
    <TELL "A hollow voice says, \"Wrong cabinet.\"" CR>>

"Morse code"

;"Each letter's code as a number: start at 1, then for each symbol double it,
  adding 1 for a dash. A is .- so 1, 10, 101: 5. Five symbols at most, so 63."
<SETG MORSE-ALPHABET
    '("A" ".-" "B" "-..." "C" "-.-." "D" "-.." "E" "." "F" "..-." "G" "--."
      "H" "...." "I" ".." "J" ".---" "K" "-.-" "L" ".-.." "M" "--" "N" "-."
      "O" "---" "P" ".--." "Q" "--.-" "R" ".-." "S" "..." "T" "-" "U" "..-"
      "V" "...-" "W" ".--" "X" "-..-" "Y" "-.--" "Z" "--..")>

<DEFINE MORSE-NUMBER (CODE "AUX" (N 1))
    <MAPF <> <FUNCTION (C) <SET N <+ <* .N 2> <COND (<==? .C !\-> 1) (ELSE 0)>>>>
          .CODE>
    .N>

<DEFINE MORSE-LOOKUP-TABLE ("AUX" (V <IVECTOR 64 0>) (L ,MORSE-ALPHABET))
    <REPEAT ()
        <COND (<EMPTY? .L> <RETURN>)>
        <PUT .V <+ <MORSE-NUMBER <2 .L>> 1> <ASCII <1 <1 .L>>>>
        <SET L <REST .L 2>>>
    <EVAL <FORM TABLE '(BYTE) !.V>>>

;"letter for each code number, 0 where no letter has that code"
<CONSTANT MORSE-LETTERS %<MORSE-LOOKUP-TABLE>>

;"Any of these opens the back room. It's a toy, so be generous: every verb
  with every ending (OPEN, UNLOCK ROOM, UNLATCH BACKDOOR...), plus a few
  extras. Spaces between words don't matter, since gaps are ignored."
<SETG UNLATCH-VERBS '("OPEN" "UNLOCK" "UNLATCH")>
<SETG UNLATCH-ENDINGS '("" "ROOM" "BACKROOM" "DOOR" "BACKDOOR" "UP" "SESAME")>
<SETG UNLATCH-EXTRAS '("LETMEIN")>

<DEFINE PHRASE-MORSE (P "AUX" (S ""))
    <MAPF <>
          <FUNCTION (C) <SET S <STRING .S <2 <MEMBER <STRING .C> ,MORSE-ALPHABET>> " ">>>
          .P>
    .S>

<DEFINE UNLATCH-TABLE ("AUX" (L ()))
    <MAPF <>
          <FUNCTION (V)
              <MAPF <>
                    <FUNCTION (E) <SET L (!.L <STRING .V .E>)>>
                    ,UNLATCH-ENDINGS>>
          ,UNLATCH-VERBS>
    <SET L (!.L !,UNLATCH-EXTRAS)>
    <EVAL <FORM LTABLE
                !<MAPF ,LIST
                       <FUNCTION (P) <EVAL <FORM LTABLE '(STRING) <PHRASE-MORSE .P>>>>
                       .L>>>>

;"one Morse string per accepted message"
<CONSTANT UNLATCH-MORSE %<UNLATCH-TABLE>>

<ROUTINE MORSE-UNLATCHES? ("AUX" (I 1) (N <GET ,UNLATCH-MORSE 0>))
    <REPEAT ()
        <COND (<G? .I .N> <RFALSE>)
              (<MORSE-MATCHES? <GET ,UNLATCH-MORSE .I>> <RTRUE>)>
        <SET I <+ .I 1>>>>

<DEFINE MORSE-CHART-TABLE ("AUX" (L ,MORSE-ALPHABET) (V ()))
    <REPEAT ()
        <COND (<EMPTY? .L> <RETURN>)>
        <SET V (!.V <MORSE-NUMBER <2 .L>>)>
        <SET L <REST .L 2>>>
    <EVAL <FORM TABLE '(BYTE) !.V>>>

;"code number for each letter, A to Z, for printing the chart"
<CONSTANT MORSE-CODES %<MORSE-CHART-TABLE>>

;"what was typed after SEND: dots, dashes, a space between letters, / between words"
<CONSTANT MORSE-MAX 90>
<CONSTANT MORSE-INPUT <ITABLE NONE 90 (BYTE)>>
<GLOBAL MORSE-LEN 0>
<GLOBAL MORSE-WORDS? <>>

<ROUTINE MORSE-INTERCEPT ("AUX" W I C SYMBOLS GAP)
    <SET W <GETWORD? 1>>
    <COND (<NOT <EQUAL? .W ,W?SEND ,W?TAP>> <RFALSE>)>
    <SETG MORSE-LEN 0>
    <SETG MORSE-WORDS? <>>
    <SET SYMBOLS 0>
    <SET GAP 0>
    ;"start just past the verb; the text sits at READBUF+1 and ends with a 0 on v3"
    <SET I <+ <LEXBUF-W-OFFSET ,LEXBUF 1> <LEXBUF-W-LENGTH ,LEXBUF 1>>>
    <REPEAT ()
        <COND (<OR <G=? .I ,READBUF-SIZE> <G=? ,MORSE-LEN <- ,MORSE-MAX 1>>>
               <RETURN>)>
        <SET C <GETB ,READBUF .I>>
        <COND (<0? .C> <RETURN>)
              (<EQUAL? .C !\. !\->
               <COND (<AND .GAP ,MORSE-LEN> <MORSE-PUT .GAP>)>
               <SET GAP 0>
               <MORSE-PUT .C>
               <SET SYMBOLS <+ .SYMBOLS 1>>)
              (<==? .C !\/> <SET GAP !\/>)
              (<==? .C !\ > <OR .GAP <SET GAP !\ >>)
              (ELSE <SETG MORSE-WORDS? T>)>
        <SET I <+ .I 1>>>
    ;"TAP KEY and the like go to the parser as usual"
    <COND (<AND <==? .W ,W?TAP> <0? .SYMBOLS>> <RFALSE>)>
    <COND (.SYMBOLS <SETG MORSE-WORDS? <>>)>
    <LEXBUF-W-WORD ,LEXBUF 1 ,W?SEND>
    <PUTB ,LEXBUF 1 1>
    <RTRUE>>

<ROUTINE MORSE-PUT (C)
    <PUTB ,MORSE-INPUT ,MORSE-LEN .C>
    <SETG MORSE-LEN <+ ,MORSE-LEN 1>>>

;"Compare dots and dashes alone, so letters run together still count."
<ROUTINE MORSE-MATCHES? (WANT "AUX" (I 0) (J 1) (WLEN <GETB .WANT 0>) C)
    <REPEAT ()
        <REPEAT ()
            <COND (<OR <G=? .I ,MORSE-LEN>
                       <EQUAL? <GETB ,MORSE-INPUT .I> !\. !\->>
                   <RETURN>)>
            <SET I <+ .I 1>>>
        <REPEAT ()
            <COND (<OR <G? .J .WLEN>
                       <EQUAL? <GETB .WANT .J> !\. !\->>
                   <RETURN>)>
            <SET J <+ .J 1>>>
        <COND (<AND <G=? .I ,MORSE-LEN> <G? .J .WLEN>> <RTRUE>)
              (<OR <G=? .I ,MORSE-LEN> <G? .J .WLEN>> <RFALSE>)>
        <SET C <GETB ,MORSE-INPUT .I>>
        <COND (<N==? .C <GETB .WANT .J>> <RFALSE>)>
        <SET I <+ .I 1>>
        <SET J <+ .J 1>>>>

;"Four letters to a row, each code padded to line up. Printed a character
  at a time because ZILF tidies runs of spaces inside strings."
<ROUTINE PRINT-MORSE-CHART ("AUX" (L 0) N B LEN)
    <REPEAT ()
        <COND (<G? .L 25> <RETURN>)>
        <PRINTC <+ !\A .L>>
        <PRINTC !\ >
        <SET N <GETB ,MORSE-CODES .L>>
        <SET B 32>
        <REPEAT () <COND (<L=? .B .N> <RETURN>)> <SET B </ .B 2>>>
        <SET B </ .B 2>>
        <SET LEN 0>
        <REPEAT ()
            <COND (<0? .B> <RETURN>)>
            <PRINTC <COND (<BAND .N .B> !\-) (ELSE !\.)>>
            <SET LEN <+ .LEN 1>>
            <SET B </ .B 2>>>
        <SET L <+ .L 1>>
        <COND (<OR <0? <MOD .L 4>> <G? .L 25>> <CRLF>)
              (ELSE
               <REPEAT ()
                   <COND (<G=? .LEN 8> <RETURN>)>
                   <PRINTC !\ >
                   <SET LEN <+ .LEN 1>>>)>>>

;"Print the input as letters, ? for anything that isn't one."
<ROUTINE PRINT-MORSE ("AUX" (I 0) (N 1) (LEN 0) C)
    <REPEAT ()
        <SET C <COND (<L? .I ,MORSE-LEN> <GETB ,MORSE-INPUT .I>) (ELSE 0)>>
        <COND (<EQUAL? .C !\. !\->
               <SET N <+ <* .N 2> <COND (<==? .C !\-> 1) (ELSE 0)>>>
               <SET LEN <+ .LEN 1>>)
              (ELSE
               <COND (<G? .LEN 0>
                      <COND (<AND <L=? .LEN 5> <GETB ,MORSE-LETTERS .N>>
                             <PRINTC <GETB ,MORSE-LETTERS .N>>)
                            (ELSE <PRINTC !\?>)>)>
               <COND (<==? .C !\/> <PRINTC !\ >)>
               <COND (<0? .C> <RETURN>)>
               <SET N 1>
               <SET LEN 0>)>
        <SET I <+ .I 1>>>>

"Front Steps: north is a door exit, south is a string exit"

<ROOM FRONT-STEPS
    (DESC "Front Steps")
    (IN ROOMS)
    (LDESC "You stand on the stone steps of the Cabinet of Curios. Its windows
are dark. The front door is to the north, and a worn doormat lies at your feet.
The street is behind you to the south.")
    (NORTH TO GALLERY IF FRONT-DOOR IS OPEN)
    (IN TO GALLERY IF FRONT-DOOR IS OPEN)
    (SOUTH SORRY "Your bus left an hour ago, and the street is empty.")
    (GLOBAL FRONT-DOOR)
    (FLAGS LIGHTBIT)>

<OBJECT FRONT-DOOR
    (DESC "front door")
    (IN LOCAL-GLOBALS)
    (SYNONYM DOOR)
    (ADJECTIVE FRONT HEAVY OAK)
    (FLAGS DOORBIT OPENABLEBIT LOCKEDBIT)
    (GENERIC DOOR-GENERIC)
    (ACTION FRONT-DOOR-R)>

;"In the gallery both doors answer to DOOR. The front door is the one you
  can work by hand, so OPEN, CLOSE and UNLOCK go to it while there's
  something to do to it; otherwise the parser asks."
<ROUTINE DOOR-GENERIC (TBL)
    <COND (<VERB? OPEN>
           <COND (<FSET? ,FRONT-DOOR ,OPENBIT> ,BACK-DOOR) (ELSE ,FRONT-DOOR)>)
          (<VERB? CLOSE>
           <COND (<FSET? ,FRONT-DOOR ,OPENBIT> ,FRONT-DOOR) (ELSE ,BACK-DOOR)>)
          (<VERB? UNLOCK>
           <COND (<FSET? ,FRONT-DOOR ,LOCKEDBIT> ,FRONT-DOOR) (ELSE ,BACK-DOOR)>)>>

<ROUTINE FRONT-DOOR-R ()
    <COND (<VERB? EXAMINE>
           <TELL "A heavy oak door with a brass letter slot. It's ">
           <COND (<FSET? ,FRONT-DOOR ,OPENBIT> <TELL "open">)
                 (<FSET? ,FRONT-DOOR ,LOCKEDBIT> <TELL "shut and locked">)
                 (ELSE <TELL "shut">)>
           <TELL "." CR>)
          (<VERB? UNLOCK>
           <COND (<NOT <FSET? ,FRONT-DOOR ,LOCKEDBIT>>
                  <TELL "It's already unlocked." CR>)
                 (<PRSI? ,IRON-KEY>
                  <FCLEAR ,FRONT-DOOR ,LOCKEDBIT>
                  <TELL "The iron key turns with a heavy clunk." CR>)
                 (ELSE
                  <TELL CT ,PRSI " doesn't fit the lock." CR>)>)
          (<VERB? LOCK>
           <TELL "You'd rather not lock yourself out, or in." CR>)
          (<AND <VERB? OPEN>
                <FSET? ,FRONT-DOOR ,LOCKEDBIT>
                <HELD? ,IRON-KEY>>
           <FCLEAR ,FRONT-DOOR ,LOCKEDBIT>
           <FSET ,FRONT-DOOR ,OPENBIT>
           <TELL "You unlock the door with the iron key and push it open." CR>)>>

<OBJECT DOORMAT
    (DESC "doormat")
    (IN FRONT-STEPS)
    (SYNONYM MAT DOORMAT)
    (ADJECTIVE WORN DOOR WELCOME)
    (FLAGS NDESCBIT SURFACEBIT)
    (ACTION DOORMAT-R)>

<GLOBAL KEY-FOUND <>>

<ROUTINE DOORMAT-R ()
    <COND (<VERB? EXAMINE>
           <TELL "A doormat worn thin by a great many visitors. One corner
curls up a little." CR>)
          (<VERB? LOOK-UNDER TAKE LIFT PULL PUSH SEARCH>
           <COND (,KEY-FOUND
                  <TELL "Nothing else is under the mat." CR>)
                 (ELSE
                  <SETG KEY-FOUND T>
                  <MOVE ,IRON-KEY ,HERE>
                  <THIS-IS-IT ,IRON-KEY>
                  <TELL "You lift a corner of the mat. Underneath lies a small
iron key." CR>)>)>>

<OBJECT IRON-KEY
    (DESC "iron key")
    (SYNONYM KEY)
    (ADJECTIVE SMALL IRON SPARE)
    (FLAGS TAKEBIT TOOLBIT VOWELBIT)
    (GENERIC KEY-GENERIC-F)>

;"Both keys answer to KEY. When it's ambiguous, pick by what you're doing."
<ROUTINE KEY-GENERIC-F (TBL)
    <COND (<VERB? TAP PUSH> ,TELEGRAPH-KEY)
          (<VERB? UNLOCK LOCK> ,IRON-KEY)>>

<OBJECT LEAFLET
    (DESC "leaflet")
    (IN FRONT-STEPS)
    (SYNONYM LEAFLET NOTICE PAPER)
    (FDESC "A leaflet is tacked beside the door.")
    (FLAGS TAKEBIT READBIT)
    (ACTION LEAFLET-R)>

<ROUTINE LEAFLET-R ()
    <COND (<VERB? READ EXAMINE>
           <TELL "\"CLOSED FOR THE EVENING. The Cabinet of Curios opens again
at ten. Staff: the spare key is where it always is. Please mind the
curios.\"" CR>)>>

"Gallery: plain exits, a conditional exit east, and a door exit south"

<ROOM GALLERY
    (DESC "Gallery")
    (IN ROOMS)
    (LDESC "A long gallery runs the length of the building. Curios sit along
a deep shelf, each with a paper tag on a little hook. The workshop is north,
the telegraph office is west, and east is a narrow door to the back room with
no handle or keyhole. The front door is south.")
    (NORTH TO WORKSHOP)
    (WEST TO TELEGRAPH-OFFICE)
    (EAST TO BACK-ROOM IF BACK-DOOR-OPEN ELSE "The narrow door to the back room
has no handle and no keyhole, and it won't budge.")
    (SOUTH TO FRONT-STEPS IF FRONT-DOOR IS OPEN)
    (OUT TO FRONT-STEPS IF FRONT-DOOR IS OPEN)
    (GLOBAL FRONT-DOOR BACK-DOOR)
    (FLAGS LIGHTBIT)
    (ACTION GALLERY-R)>

<GLOBAL BACK-DOOR-OPEN <>>

;"Shaped like a door, but sealed: no handle, no keyhole. Only the telegraph
  opens it, and once open it stays open."
<OBJECT BACK-DOOR
    (DESC "back room door")
    (IN LOCAL-GLOBALS)
    (SYNONYM DOOR PASSAGE PASSAGEWAY)
    (ADJECTIVE BACK BACKROOM NARROW ROOM SEALED)
    (GENERIC DOOR-GENERIC)
    (ACTION BACK-DOOR-R)>

<ROUTINE BACK-DOOR-R ()
    <COND (<VERB? EXAMINE>
           <COND (,BACK-DOOR-OPEN
                  <TELL "The narrow door has slid aside into the wall, leaving
the way open." CR>)
                 (ELSE
                  <TELL "It looks like a narrow door, but it has no handle and
no keyhole, and it sits flush with the wall, sealed tight. Whatever opens it,
it isn't here." CR>)>)
          (<VERB? OPEN UNLOCK PUSH PULL LIFT>
           <COND (,BACK-DOOR-OPEN <TELL "It's already open." CR>)
                 (ELSE
                  <TELL "There's no handle to pull and no keyhole to unlock,
and pushing does nothing. It must be opened from somewhere else." CR>)>)
          (<VERB? CLOSE LOCK>
           <COND (,BACK-DOOR-OPEN
                  <TELL "There's no handle to slide it shut with." CR>)
                 (ELSE <TELL "It's already sealed tight." CR>)>)>>

<ROUTINE OPEN-BACK-DOOR ()
    <SETG BACK-DOOR-OPEN T>
    <PUTP ,GALLERY ,P?LDESC "A long gallery runs the length of the building.
Curios sit along a deep shelf, each with a paper tag on a little hook. The
workshop is north, the telegraph office is west, and the narrow door to the
back room stands open to the east. The front door is south.">>

<ROUTINE GALLERY-R (RARG)
    <COND (<==? .RARG ,M-ENTER>
           <AWARD-POINTS 1 ,ACH?GETTING-IN>)
          ;"caught here, before PUT IN's own checks say the odometer isn't a container"
          (<AND <==? .RARG ,M-BEG>
                <VERB? PUT-IN PUT-ON>
                <PRSI? ,ODOMETER>>
           <COND (<NOT <PRSO? ,CRANK>>
                  <TELL CT ,PRSO " doesn't fit the winding socket." CR>)
                 (,CRANK-IN-SOCKET
                  <TELL "The crank is already in the socket." CR>)
                 (ELSE
                  <SEAT-CRANK>
                  <TELL "The square end of the crank slides snugly into the
winding socket." CR>)>)>>

<OBJECT GALLERY-SCENERY
    (DESC "gallery")
    (IN GALLERY)
    (SYNONYM GALLERY)
    (FLAGS NDESCBIT)
    (ACTION GALLERY-SCENERY-R)>

<ROUTINE GALLERY-SCENERY-R ()
    <COND (<VERB? EXAMINE SEARCH>
           <V-LOOK>
           <RTRUE>)>>

<OBJECT SHELF
    (DESC "shelf")
    (IN GALLERY)
    (SYNONYM SHELF CURIOS TAGS)
    (ADJECTIVE DEEP LONG PAPER)
    (FLAGS NDESCBIT)
    (ACTION SHELF-R)>

<ROUTINE SHELF-R ()
    <COND (<VERB? EXAMINE READ>
           <TELL "Paper tags hang in a long row down the shelf: No. 1,
Odometers. No. 2, Morse Code. No. 3, Lehmer Codes. And on down the gallery
into the dark. ">
           <COND (<IN? ,BRASS-BOX ,HOOK>
                  <TELL "At the head of the row, No. 0 hangs where it belongs." CR>)
                 (ELSE
                  <TELL "At the head of the row, before No. 1, one hook is
empty." CR>)>)>>

<OBJECT HOOK
    (DESC "empty hook")
    (IN GALLERY)
    (SYNONYM HOOK PEG)
    (ADJECTIVE EMPTY LITTLE FIRST)
    ;"listed like any object, so even the short description on a return visit
      points at it"
    (LDESC "At the head of the shelf, before No. 1, one little hook hangs
empty.")
    (FLAGS CONTBIT SURFACEBIT OPENBIT VOWELBIT)
    (ACTION HOOK-R)>

<ROUTINE HOOK-R ()
    <COND (<VERB? EXAMINE>
           <TELL "A little brass hook at the head of the shelf, before No. 1.
Every other hook has a tag on it. This one is waiting." CR>)
          (<AND <VERB? PUT-ON PUT-IN> <PRSI? ,HOOK>>
           <COND (<PRSO? ,BRASS-BOX> <WIN-GAME>)
                 (ELSE <TELL "Only a curio's tag belongs on that hook." CR>)>)>>

<OBJECT ODOMETER
    (DESC "brass odometer")
    (IN GALLERY)
    (SYNONYM ODOMETER WHEELS SOCKET PLINTH)
    (ADJECTIVE BRASS WINDING)
    (LDESC "A brass odometer sits on a wooden plinth, its wheels stuck at 0999.")
    (ACTION ODOMETER-R)>

<GLOBAL ODOMETER-WOUND <>>
<GLOBAL CRANK-IN-SOCKET <>>

<ROUTINE ODOMETER-R ()
    <COND (<VERB? EXAMINE READ>
           <TELL "Four brass wheels read ">
           <COND (,ODOMETER-WOUND <TELL "1000">)
                 (ELSE <TELL "0999, one turn short of a thousand">)>
           <TELL ". ">
           <COND (,CRANK-IN-SOCKET
                  <TELL "The winding crank sits in the square socket in its
side.">)
                 (ELSE <TELL "There's a square winding socket in its side.">)>
           <COND (,ODOMETER-WOUND
                  <TELL " The drawer in the plinth stands open." CR>)
                 (ELSE
                  <TELL " Below it is a drawer in the plinth, with no
handle." CR>)>)
          (<VERB? WIND TURN>
           <WIND-ODOMETER>)
          (<VERB? OPEN>
           <COND (,ODOMETER-WOUND <TELL "The drawer is already open." CR>)
                 (ELSE <TELL "The drawer has no handle, and it won't
budge." CR>)>)>>

<ROUTINE SET-ODOMETER-LDESC ()
    <PUTP ,ODOMETER ,P?LDESC
          <COND (<AND ,ODOMETER-WOUND ,CRANK-IN-SOCKET>
                 "A brass odometer sits on its plinth, reading 1000, with the
winding crank in its side and a drawer open in its base.")
                (,ODOMETER-WOUND
                 "A brass odometer sits on its plinth, reading 1000, with a
drawer open in its base.")
                (,CRANK-IN-SOCKET
                 "A brass odometer sits on a wooden plinth, its wheels stuck at
0999, with the winding crank fitted into its side.")
                (ELSE
                 "A brass odometer sits on a wooden plinth, its wheels stuck at
0999.")>>>

<ROUTINE SEAT-CRANK ()
    <SETG CRANK-IN-SOCKET T>
    <MOVE ,CRANK ,GALLERY>
    ;"not takeable while seated, so the parser's quiet implicit
      TAKE can't lift it out behind CRANK-R's back"
    <FSET ,CRANK ,NDESCBIT>
    <FCLEAR ,CRANK ,TAKEBIT>
    <SET-ODOMETER-LDESC>>

;"WIND ODOMETER WITH CRANK names the tool, so a held crank is fitted
  and turned in one go; plain WIND ODOMETER still asks for it first"
<ROUTINE WIND-ODOMETER ("AUX" (FITTED <>))
    <COND (<AND ,PRSI <NOT <PRSI? ,CRANK>>>
           <TELL CT ,PRSI " doesn't fit the winding socket." CR>
           <RTRUE>)
          (,ODOMETER-WOUND
           <TELL "The wheels read 1000 and won't go any further." CR>
           <RTRUE>)
          (<AND <PRSI? ,CRANK> <HELD? ,CRANK>>
           <SEAT-CRANK>
           <SET FITTED T>)
          (<HELD? ,CRANK>
           <TELL "The crank needs to go into the winding socket first." CR>
           <RTRUE>)
          (<NOT ,CRANK-IN-SOCKET>
           <TELL "You'll need something to fit the winding socket. A crank,
perhaps." CR>
           <RTRUE>)>
    <SETG ODOMETER-WOUND T>
    <SET-ODOMETER-LDESC>
    <MOVE ,MATCHBOOK ,HERE>
    <THIS-IS-IT ,MATCHBOOK>
    <AWARD-POINTS 1 ,ACH?WINDING>
    <COND (.FITTED
           <TELL "You fit the square end of the crank into the winding socket
and give it one firm turn.">)
          (ELSE <TELL "You give the crank one firm turn.">)>
    <TELL " The last wheel clicks from 9 to 0, and so does the next, and
the next, until the odometer reads 1000. With a soft thunk, a drawer slides
out of the plinth. In it is a book of matches." CR>>

<OBJECT MATCHBOOK
    (DESC "book of matches")
    (SYNONYM MATCHES MATCH MATCHBOOK BOOK)
    (ADJECTIVE BOOK)
    (FLAGS TAKEBIT)
    (ACTION MATCHBOOK-R)>

<ROUTINE MATCHBOOK-R ()
    <COND (<VERB? EXAMINE>
           <TELL "A book of matches with plenty left in it." CR>)
          (<VERB? LIGHT BURN>
           <COND (<NOT <HELD? ,MATCHBOOK>>
                  <TELL "You'll need to pick them up first." CR>)
                 (<AND <HELD? ,LANTERN> <NOT <FSET? ,LANTERN ,ONBIT>>>
                  <LIGHT-LANTERN>)
                 (ELSE
                  <TELL "You strike a match. It flares, burns down, and goes
out." CR>)>)>>

"Workshop: plain exits"

<ROOM WORKSHOP
    (DESC "Workshop")
    (IN ROOMS)
    (LDESC "A cluttered workshop that smells of oil and sawdust. Tools hang
above a long workbench. The gallery is back to the south.")
    (SOUTH TO GALLERY)
    (OUT TO GALLERY)
    (FLAGS LIGHTBIT)>

<OBJECT WORKBENCH
    (DESC "workbench")
    (IN WORKSHOP)
    (SYNONYM WORKBENCH BENCH TOOLS)
    (ADJECTIVE LONG)
    (FLAGS NDESCBIT SURFACEBIT CONTBIT OPENBIT)
    (ACTION WORKBENCH-R)>

<ROUTINE WORKBENCH-R ()
    <COND (<VERB? EXAMINE>
           <TELL "Scarred by years of repairs. Half-mended curios wait their
turn under a dust sheet." CR>)>>

<OBJECT LANTERN
    (DESC "oil lantern")
    (IN WORKSHOP)
    (SYNONYM LANTERN LAMP WICK)
    (ADJECTIVE OIL)
    (FDESC "An oil lantern stands at the end of the workbench.")
    (FLAGS TAKEBIT DEVICEBIT VOWELBIT)
    (ACTION LANTERN-R)>

<ROUTINE LANTERN-R ()
    <COND (<VERB? EXAMINE>
           <TELL "A tin oil lantern with a glass chimney. ">
           <COND (<FSET? ,LANTERN ,ONBIT> <TELL "Its flame burns steadily." CR>)
                 (ELSE <TELL "It's unlit, and full of oil." CR>)>)
          (<VERB? LIGHT TURN-ON BURN>
           <COND (<FSET? ,LANTERN ,ONBIT>
                  <TELL "It's already lit." CR>)
                 (<HELD? ,MATCHBOOK>
                  <LIGHT-LANTERN>)
                 (ELSE
                  <TELL "There's no switch. It's an oil lantern, and you'll
need a flame." CR>)>)
          (<VERB? EXTINGUISH TURN-OFF>
           <COND (<NOT <HELD? ,LANTERN>>
                  <TELL "Better pick it up first, in case you need it
again." CR>)
                 (<FSET? ,LANTERN ,ONBIT>
                  <FCLEAR ,LANTERN ,ONBIT>
                  <FCLEAR ,LANTERN ,LIGHTBIT>
                  <TELL "You turn down the wick and the flame goes out." CR>
                  <NOW-DARK?>
                  <RTRUE>)
                 (ELSE <TELL "It isn't lit." CR>)>)
          (<AND <VERB? DROP> <FSET? ,LANTERN ,ONBIT>>
           <MOVE ,LANTERN ,HERE>
           <COND (<==? ,HERE ,BACK-ROOM>
                  <TELL "You set the lantern on the floor, where it throws its
light up the ladder." CR>)
                 (ELSE
                  <TELL "You set the lantern down. It goes on burning." CR>)>)>>

<ROUTINE LIGHT-LANTERN ()
    <FSET ,LANTERN ,ONBIT>
    <FSET ,LANTERN ,LIGHTBIT>
    <TELL "You strike a match and touch it to the wick. The lantern catches
and burns with a steady yellow flame." CR>
    <NOW-LIT?>
    <RTRUE>>

<OBJECT CRANK
    (DESC "winding crank")
    (IN WORKSHOP)
    (SYNONYM CRANK HANDLE)
    (ADJECTIVE WINDING STEEL)
    (FDESC "A steel winding crank hangs on a nail above the bench.")
    (FLAGS TAKEBIT)
    (ACTION CRANK-R)>

<ROUTINE CRANK-R ()
    <COND (<VERB? EXAMINE>
           <TELL "An L-shaped steel crank with a square end, made to fit a
winding socket." CR>)
          (<AND <VERB? TURN WIND> <PRSO? ,CRANK>>
           <COND (,CRANK-IN-SOCKET <WIND-ODOMETER>)
                 (<==? ,HERE ,GALLERY>
                  <TELL "The crank turns freely in the air. The odometer's
winding socket looks about the right size for it." CR>)
                 (ELSE <TELL "The crank turns freely in the air. It needs a
socket to fit into." CR>)>)
          (<AND ,CRANK-IN-SOCKET <VERB? TAKE PULL TAKE-FROM>>
           <SETG CRANK-IN-SOCKET <>>
           <FCLEAR ,CRANK ,NDESCBIT>
           <FSET ,CRANK ,TAKEBIT>
           <MOVE ,CRANK ,WINNER>
           <SET-ODOMETER-LDESC>
           <TELL "You pull the crank out of the winding socket." CR>)>>

"Telegraph Office: plain exits"

<ROOM TELEGRAPH-OFFICE
    (DESC "Telegraph Office")
    (IN ROOMS)
    (LDESC "A narrow office with a high desk against one wall. A telegraph key
is screwed to the desk, wired to a sounder beside it. Above them a card is
pinned up next to a Morse chart. The gallery is east.")
    (EAST TO GALLERY)
    (OUT TO GALLERY)
    (FLAGS LIGHTBIT)>

<OBJECT TELEGRAPH-KEY
    (DESC "telegraph key")
    (IN TELEGRAPH-OFFICE)
    (SYNONYM KEY LEVER SOUNDER KNOB)
    (ADJECTIVE TELEGRAPH BRASS MORSE BLACK)
    (FLAGS NDESCBIT)
    (GENERIC KEY-GENERIC-F)
    (ACTION TELEGRAPH-KEY-R)>

<ROUTINE TELEGRAPH-KEY-R ()
    <COND (<VERB? EXAMINE>
           <TELL "A brass lever on a spring, with a black knob to press. Wires
run from it to the sounder, which clicks out whatever comes back down the
line." CR>)
          (<VERB? TAKE>
           <TELL "It's screwed firmly to the desk." CR>)
          (<VERB? TAP PUSH>
           <TELL "Click. The sounder clicks back, once. One tap won't say
much. To send a whole message, type SEND and then the dots and dashes." CR>)>>

<OBJECT CARD
    (DESC "card")
    (IN TELEGRAPH-OFFICE)
    (SYNONYM CARD MESSAGE)
    (ADJECTIVE PINNED)
    (FLAGS NDESCBIT READBIT)
    (ACTION CARD-R)>

<ROUTINE CARD-R ()
    <COND (<VERB? READ EXAMINE>
           <TELL "Hand-lettered: \"BACKROOM CONTROL CENTER\"" CR>)
          (<VERB? TAKE>
           <TELL "Better leave it pinned up where the staff can find it." CR>)>>

<OBJECT MORSE-CHART
    (DESC "Morse chart")
    (IN TELEGRAPH-OFFICE)
    (SYNONYM CHART CODE ALPHABET GUIDE)
    (ADJECTIVE MORSE)
    (FLAGS NDESCBIT READBIT)
    (ACTION MORSE-CHART-R)>

<ROUTINE MORSE-CHART-R ()
    <COND (<VERB? READ EXAMINE>
           <TELL "A printed chart, headed \"No. 2, Morse Code\":" CR CR>
           <PRINT-MORSE-CHART>
           <TELL CR "Leave a space between letters, and a / between words." CR>)
          (<VERB? TAKE>
           <TELL "It's pinned up for whoever works the key next." CR>)>>

"Back Room: dark until the hatch is opened, with a routine exit up the ladder"

<ROOM BACK-ROOM
    (DESC "Back Room")
    (IN ROOMS)
    (LDESC "A storeroom crowded with crates and dust sheets. A wooden ladder
climbs to a hatch in the ceiling. The gallery is west.")
    (WEST TO GALLERY)
    (OUT TO GALLERY)
    (UP PER LADDER-UP-F)
    (GLOBAL LADDER BACK-DOOR)
    (ACTION BACK-ROOM-R)>

<GLOBAL HATCH-OPEN <>>

<ROUTINE BACK-ROOM-R (RARG)
    <COND (<N==? .RARG ,M-BEG> <RFALSE>)
          (<AND <VERB? CLIMB> <NOT ,PRSO>>
           <DO-WALK ,P?UP>
           <RTRUE>)
          ;"anything let go of in the dark would be lost for good"
          (<AND <NOT ,HERE-LIT> <VERB? DROP PUT-ON PUT-IN THROW-AT GIVE>>
           <TELL "You'd never find it again in this dark. You keep hold of
it." CR>
           <RTRUE>)>>

;"A routine exit returns the room to move to, or false to stay put."
<ROUTINE LADDER-UP-F ()
    <COND (<NOT ,HERE-LIT>
           <TELL "You can't find the ladder, or much of anything else." CR>
           <RFALSE>)
          (<HOLDING-MORE-THAN-ONE?>
           <COND (<IN? ,BRASS-BOX ,WINNER>
                  <TELL "Climbing up is harder than climbing down. ">)>
           <TELL "The ladder is steep, and you'll need a hand for it. You
can carry one thing up, but no more, so put the rest down first." CR>
           <RFALSE>)
          (,HATCH-OPEN
           <TELL "You climb the ladder into the attic." CR CR>
           ,ATTIC)
          (ELSE
           ;"once open, the hatch lets moonlight down, so the way back is never dark"
           <SETG HATCH-OPEN T>
           <FSET ,BACK-ROOM ,LIGHTBIT>
           <PUTP ,BACK-ROOM ,P?LDESC "A storeroom crowded with crates and dust
sheets. A wooden ladder climbs to the open hatch, and moonlight spills down
it. The gallery is west.">
           <TELL "You climb the ladder and push the hatch open. Moonlight
spills down past you as you squeeze through." CR CR>
           ,ATTIC)>>

;"Up the ladder you may carry one thing, since the other hand is for the ladder."
<ROUTINE HOLDING-MORE-THAN-ONE? ("AUX" (N 0))
    <MAP-CONTENTS (I ,WINNER)
        <SET N <+ .N 1>>>
    <G? .N 1>>

;"Down is never refused, but the box plus anything else earns a nod to the
  rule going up."
<ROUTINE LADDER-DOWN-F ("AUX" (O <>))
    <COND (<IN? ,BRASS-BOX ,WINNER>
           <MAP-CONTENTS (I ,WINNER)
               <COND (<N==? .I ,BRASS-BOX> <SET O .I> <RETURN>)>>)>
    <COND (.O
           <TELL "Luckily, climbing down is easier than climbing up. You
tuck the box under one arm, keep " T .O " in the other hand, and ease your way
down the ladder." CR CR>)
          (ELSE
           <TELL "You climb down the ladder." CR CR>)>
    ,BACK-ROOM>

<OBJECT LADDER
    (DESC "ladder")
    (IN LOCAL-GLOBALS)
    (SYNONYM LADDER HATCH)
    (ADJECTIVE WOODEN)
    (ACTION LADDER-R)>

<ROUTINE LADDER-R ()
    <COND (<VERB? EXAMINE>
           <TELL "A sturdy wooden ladder between the back room and the attic
hatch." CR>)
          (<VERB? CLIMB ENTER>
           <COND (<==? ,HERE ,ATTIC> <DO-WALK ,P?DOWN>)
                 (ELSE <DO-WALK ,P?UP>)>)
          (<VERB? CLIMB-DOWN>
           <COND (<==? ,HERE ,ATTIC> <DO-WALK ,P?DOWN>)
                 (ELSE <TELL "You're already at the bottom." CR>)>)>>

<OBJECT CRATES
    (DESC "crates")
    (IN BACK-ROOM)
    (SYNONYM CRATES CRATE SHEETS SHEET)
    (ADJECTIVE DUST WOODEN)
    (FLAGS NDESCBIT PLURALBIT)
    (ACTION CRATES-R)>

<ROUTINE CRATES-R ()
    <COND (<VERB? EXAMINE LOOK-UNDER SEARCH OPEN>
           <TELL "Curios waiting for their turn on the shelf. They're packed
tight, and none of them is missing a tag." CR>)>>

"Attic: a routine exit down, so the ladder can comment on what you carry"

<ROOM ATTIC
    (DESC "Attic")
    (IN ROOMS)
    (LDESC "A low attic under the roof beams. Moonlight falls through a round
window onto bare boards. The hatch and ladder lead down.")
    (DOWN PER LADDER-DOWN-F)
    (OUT PER LADDER-DOWN-F)
    (GLOBAL LADDER)
    (FLAGS LIGHTBIT)>

<OBJECT ROUND-WINDOW
    (DESC "round window")
    (IN ATTIC)
    (SYNONYM WINDOW MOONLIGHT MOON)
    (ADJECTIVE ROUND)
    (FLAGS NDESCBIT)
    (ACTION ROUND-WINDOW-R)>

<ROUTINE ROUND-WINDOW-R ()
    <COND (<VERB? EXAMINE SEARCH>
           <TELL "Through the round window you can see the dark street, and
the bus stop where no bus is coming." CR>)
          (<VERB? OPEN>
           <TELL "It's painted shut." CR>)>>

<OBJECT BRASS-BOX
    (DESC "small brass box")
    (IN ATTIC)
    (SYNONYM BOX TAG LABEL STRING)
    (ADJECTIVE SMALL BRASS PAPER Z)
    (FDESC "On the boards, in a square of moonlight, sits a small brass box
with a paper tag tied to it.")
    (FLAGS TAKEBIT READBIT)
    (ACTION BRASS-BOX-R)>

<ROUTINE BRASS-BOX-R ()
    <COND (<VERB? EXAMINE>
           <TELL "A small brass box with a Z stamped into its lid. A paper tag
hangs from it on a loop of string. It reads: \"No. 0.\"" CR>)
          (<VERB? READ>
           <TELL "The tag reads: \"No. 0.\" Turn it over, and in smaller
letters: \"How every other story here gets told.\"" CR>)
          (<VERB? OPEN>
           <TELL "The lid is sealed. This curio explains itself without being
opened." CR>)>>

"The ending"

<ROUTINE WIN-GAME ()
    <MOVE ,BRASS-BOX ,HOOK>
    <AWARD-POINTS 2 ,ACH?SHELVING>
    <JIGS-UP "You hang the box from the empty hook at the head of the shelf.
The paper tag turns once and settles, facing out:|
|
    No. 0. The Z-Machine.|
|
An imaginary computer. Write a story once for it, teach any other computer
how to be a Z-Machine, and that same story can play anywhere.">>
