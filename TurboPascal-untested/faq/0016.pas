{
Robert Rothenburg

Ok, since a few people have requested info about compression routines I
thought some actual descriptions of the algorithm(s) involved would be a
good idea.  Rather than dig out someone else's text file or mail (which
might be copyrighted or arcane) I'll try my hand at explaining a few
methods.

It seems better that programmers have at least a rudimentary understanding
of the algortihms if they plan on using (or not using :) them.

DISCLAIMER: Please pardon any innacuracies: What I know is based on other
  people's mail, text files or from what I've gleaned from spending a few
  hours at the library (adivce: your local college research-library is a
  wonderful resource of algorithms and source-code. Old magazines as well
  as academic papers like the IEEE Transactions are worth examining).


In this insanely long post:

I.   "Garbage Collection"
II.  "Keywords"
III. Run-Length Encoding (RLE)
IV.  Static and Dynamic Huffmann Codes  <--(BTW, is it one or two n's?)
V.   Lampev-Ziv (LZ)
VI.  Lampev-Ziv-Welch (LZW) et al.


I.  "Garbage Collection"

  The simplest methods of compression in weeding out unnecessary data,
  especially from text files.  Spaces at the end of a line, or extra
  carriage returns at the end of a file. (Especially with MS-DOS text
  files, which use a Carriage Return *and* Line Feed--many editors and
  file-browsers do not need both. Eliminating one of them can cut a large
  text file's size by a few percent!)

  I've also seen some utilities that "clean up" the headers of EXE
  files (such as UNP) by eliminating `unnecessary' info.  Other
  utilities will clean up graphics files so that they'll compress
  better.

  In fact, removing excess "garbage" from any file will probably
  improve its compressability.

II. "Keywords"

  Another way to compress text files is to use a "keyword" for each word.

  I.E. we can assume most text files will have less than 65,536 different
  words (16 bits=two bytes), and thus we can assign a different value for
  each word: since most words are longer than three letters (more than two
  bytes), we will save space in the file. However, we'll need some form of
  look-up table for each keyword--one way around this might be to use a
  reference to a standard dictionary file that is included with an operating
  system or word processor.

  (This has other advantages as well. Many BASIC interpreters will store
  commands like PRINT or INPUT as a character code rather than the entire
  name in ASCII text.  Not only does this save memory but improves the
  run-speed of the program.)

  This method can be adapted to other (non-text) files, of course.

III. Run-Length Encoding (RLE)

  With RLE, repeated characters (such as leading spaces in text, or large
  areas of one color in graphics) are expressed with a code noting which
  byte is repeated and how many times it's repeated.

IV.  Static and Dynamic Huffmann Codes

  The logic behind this method is that certain characters occur more often
  than others, and thus the more common characters can be expressed with
  fewer bits. For example, take a text file: 'e' might be the most common
  character, then 'a', then 's', then 'i', etc....

  We can express these characters in a bit-stream like so:

                'e' = 1
                'a' = 01         <--These are Static Huffmann Codes.
                's' = 001
                'i' = 0001
                    etc...

  Since these characters normally take up 8-bits, the first (most common)
  seven will save space when expressed this way, if they occur often enough
  in relation to the other 249 characters.

  This is often represented as a (Static) Huffmann Tree:

                        /\              Note that a compression routine
                 'e' = 1  0             will have to first scan the data
                         / \            and count which characters are
                  'a' = 1   0           more common and assign the codes
                           /  \         appropriately.
                   etc... 1    0
                              /  \
                                etc...

  Notice that if we use the full 256 ASCII characters we'll run into
  a problem with long strings of 0's.  We can get around that by using
  RLE (Which is what the compressor SQUEEZE uses).

  Again, since most files use a large range of the character set, and
  their occurences are much more "even", we can use use Dynamic Huffmann
  Codes as an alternative.  They are like their static cousins, only after
  the string of n zeros they are followed by n (binary) digits:

                1        = 1                             1 character
               01x       = 010, 011                      2 chars
              001xx      = 00100, 00101, 00110, 0011     4 chars
             0001xxx     = 0001000, 0001001 ... 0001111  8 chars
                    etc...

  As you can guess, the Huffmann Tree would look something like:

                      /\            It's a bit too complicated to
                     1  0           express with ASCII <g>
                       / \
                      1    0
                     / \   /\
                    1   0    etc...

  Huffmann Coding is based on how often an item (such as an ASCII
  character) occurs, and not where or in relation to other items.
  It's not the msot efficient mothod, but it is one of the simplest.
  One only needs to make an initial pass to count the characters and
  then re-pass translating them into the appropriate codes. No
  pattern-matching or search routines are required.

V.  Lampev-Ziv (LZ) Encoding.

  This method _does_ require some fast pattern-matching/search routines.
  It takes advantage of the fact that in most files (especially text)
  whole strings of characters repeat themselves.

  Take this sample line of text:

      "THAT WHICH IS, IS. THAT WHICH IS NOT, IS NOT. IS IT? IT IS!"

  (Ok, so "Flowers for Algernon" was on TV the other night... :)
  With LZ, we read in from the beginning of the file and keep adding
  groups ("Windows") of characters that have not already occurred.
  So we add the first sentence, then get to the second "IS"...instead
  of repeating it we note that it's a duplicate, with a reference
  to where the original occurred and how long the string is. (I.E. we note
  that the "IS" occurred 4 characters previously, and is two characters
  long.)

  This method can be tweaked by using a "Sliding Window" approach where the
  largest matches are found...we can compress the second "IS" with the first,
  but when don't gain much.  However the two "IS NOT"s, when matched against
  each other, would compress better.

  Our compressed file will have two types of data: the raw characters and
  the LZ-references (containing the pointer and length) to the raw
  characters, or even to other LZ-references.

  One way to tweak this further is to compress the LZ-References using
  Huffmann codes. (I think this is what's done with the ZIP algorithm.)

VI.  Lampev-Ziv-Welch (LZW) -- Not to be confused with LZ compression.

  This is the method used by Unix COMPRESS, as well as the GIF-graphics
  file format.

  Like LZ, LZW compression can compress a stream of data on one-pass
  relatively quickly (assuming you've got the fast search routines!).
  However, LZW uses a hash table (essentially it's an array of strings,
  also known as a string table), and a "match" is expressed as its index
  in the hash table rather than a reference to where and how long the
  match is.

  The input stream is read in, strings are assembled and sent out when
  they are already in the hash table, or they are added to the hash table
  and sent out in such a way that a decoder can still re-assemble the
  file.

  Needless to say, this method is a memory hog.  Most compressors that
  use this method are usually limited to a certain number of entries
  in the hash-table (12- or 16-bits, or 4096 and 65536 respectively).

  Here's an outline of the LZW Compression Algorithm:

         0. a. Initialize the hash table. (That means for each possible
               character there is one "root" entry in the table. Some
               flavors of LZW may actually have a "null" non-character
               at the base of the table.)
            b. Initialize the "current" string (S) to null.

         1. Read a character (K) from the input stream.
            (If there are none left, then we're done, of course.)

         2. Is the string S+K in the string-table?

         3. If yes, then a. S := S+K
                         b. Go to Step 1.

            If no, then  a. add S+K to the string table.
                         b. output the code for S
                         c. S := K
                         d. Go to Step 1.

  Decompression is very similar.

         0. a. Initialize the string table (the same as with compression).
            b. Read the first code from the compressed file into C
            c. Then output the equivalent string for code C
            d. Let code O := code C (The code, not the string!)

         1. Read the next code from the input stream into C

         2. Does code C exist in the string/hash table?

         3. If yes, then a. output the string for code C
                         b. S := equivalent string for code O
                         c. K := first character of the string for code C
                         d. add S+K to the string table

            If no, then  a. S := equivalent string for code O
                         b. K := first character of S
                         c. output S+K
                         d. add S+K to the table

         4. code O := code C

         5. Go to Step 1.

  It may seem psychotic at first, but it works.  Just keep reading it and
  thinking about it.  The best way is with a pencil and pad experimenting
  with a character set of four characters (A, B, C, and D) and a "word"
  like "ABACADABA" and following through the steps.

  (An actual walk-through is not included here, since it will take up
  *way* too much space.  I recommend getting further, more detailed
  descriptions of LZW if you plan on writing an implementation.)

  One important thing is to *not* confuse between the `code' for a string
  (it's index in the hash table) and the string itself.

  Two points about LZW implementations:

      1. The code stream (i.e. the compressed output) is not usually
         a set number of bits, but reflects how many entries are in
         the string table.  This is another way to further compress
         the data.

         Usually, LZW schemes will output the code in the number of bits
         exactly reflecting the string table.  Thus for the first 512
         codes the output is 9-bits.  Once the 513th string is added to
         the table, it's 10-bits and so on.

         Some implementations will use a constant output until a threshold
         is reached.  For example, the code output will always be 12-bits
         until the 4097th string is added, then the code output is in
         16-bit segments etc...

         If these scenarios are used, the decompression routine *must*
         "think ahead" so as to read in the proper number of bits from
         the encoded data.

      2. Because full string tables are incredible memory hogs, many
         flavors of LZW will use a "hash" table (see, string and hash
         table aren't quite the same).

         Instead of a string of characters like "ABC", there'll be
         a table containing the last character of the string, and a
         reference to the previous character(s).  Thus we'll have
         "A", "[A]B" and "[[A]B]C" where [x] is the reference (or the
         actual "code") for that character/string.  Using this method
         may be slower, but it saves memory and makes the implement-
         ation a little easier.
  There are many variations on LZW using other sets of strings to
  compare with the string table--this is based on the assumption that
  the more entries there are in the table, the more efficient the
  compression will be.

  One variation (Lampev-Ziv-Yakoo) would add the ButFirst(S+K) every
  time S+K was added. "ButFirst" means all characters but the first
  one. So ButFirst("ABCD") = "BCD".


Anyhow, those are the compression algorithms that I know about which I
can even remotely attempt to explain.
I apologize for any (glaring?) mistakes. It's late...what started as a
meaningless reply to somebody asking something about SQUEEZE exploded
into this post.  I hope it's useful to anybody interested.
}
