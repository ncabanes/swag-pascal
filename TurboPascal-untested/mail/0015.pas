{
For all who work with the MkMsg toolbox and it's JAM unit, I share my
experience with the deleting of messages.

Despite a bugfix on this very subject from 1.02 to 1.03, I still cannot
delete messages properly. I found out that the basis of the problem is the
handling of the IDX file. First of all, the number of bytes written to the
IDX file was invalid and, secondly, a real bug was in the handling of the
"sub text" where an array is declared as "array [1..xx]" and used as "array
[0..xx], causing a field in a record to be overriden to an invalid value.

These are the changes I made to my MKMSGJAM.PAS file.

Line 150:
Change
  TxtSubBuf: Array[1..TxtSubBufSize] of Char; {temp storage ... }
Into
  TxtSubBuf: Array[0..TxtSubBufSize-1] of Char; {temp storage ... }

Line 831:
Change
    If JM^.TxtSubChars <= TxtSubBufSize Then
Into
    If JM^.TxtSubChars <= TxtSubBufSize-1 Then

Line 838:
Change
    If JM^.TxtSubChars <= TxtSubBufSize Then
Into
    If JM^.TxtSubChars <= TxtSubBufSize-1 Then

Line 1490:
Change
  BlockWrite(JM^.IdxFile, JamIdx^, JamIdxBufSize);
Into
  BlockWrite(JM^.IdxFile, JamIdx^, JM^.IdxRead);

Keep on jammin' !

