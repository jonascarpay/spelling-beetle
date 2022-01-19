# Spelling Beetle

A [Spelling Bee](https://www.nytimes.com/puzzles/spelling-bee) tool.
Spelling Beetle will show you your hints, updated for the words you have already found.

### Usage

1. Copy-paste your word list into a file, e.g. `words-2022-01-19.txt`.
   The words should be whitespace-separated
   The file contents are not case-sensitive.

2. Copy-paste the daily hints into a file, e.g. `hints-2022-01-19.txt`.
   This should just be the raw text from the hint page, it should _at least_ include everything starting at "WORDS:" up until "Further Reading"

3. Run `spelling-beetle <hints-file> <words-file>`.

### Example

#### `hints.txt`

```
Spelling Bee Grid

Center letter is in bold.

L A D I P T U

WORDS: 47, POINTS: 165, PANGRAMS: 1 (1 Perfect)

         4	  5	  6	  7	  8	  Σ
A:	  1	  2	  1	  1	  -	  5
D:	  4	  -	  -	  -	  -	  4
L:	  6	  1	  -	  -	  -	  7
P:	  8	  5	  3	  3	  1	20
T:	  5	  2	  1	  1	  -	  9
U:	  -	  1	  1	  -	  -	  2
Σ:	24	11	  6	  5	  1	47

Two letter list:

AD-1 AL-1 AP-2 AT-1
DI-2 DU-2
LA-2 LI-2 LU-3
PA-9 PI-1 PL-4 PU-6
TA-4 TI-4 TU-1
UP-2
```

#### `words.txt`

Note that due to a copy-paste artifact there is a space before each word; this is not a problem.

```
    adult
    appall
    applaud
    dial
    dill
    dual
    dull
    laid
    laud
    lilt
    lipid
    luau
    lull
    lulu
    pail
    pall
    palp
    papal
    pill
    plaid
    plait
    pull
    pupal
    pupil
    tail
    tall
    tidal
    tilapia
    till
    tilt
    tulip
```

#### Console

```
$ spelling-beetle hints.txt words.txt

Remaining words:    16
Remaining pangrams: 1

  4 5 6 7 8 Σ
A 1 1 - - - 2
P 3 - 3 3 1 10
T 1 - 1 - - 2
U - 1 1 - - 2
Σ 5 2 5 3 1 16

AL-1 AT-1
PA-5 PL-2 PU-3
TA-2
UP-2

```
