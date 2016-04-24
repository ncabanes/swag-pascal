(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0015.PAS
  Description: BP7 Help file format
  Author: DEREK POWLES
  Date: 11-02-93  05:04
*)

{
Derek Powles <derek.powles@eng.ox.ac.uk>

Subject: Re Help File format

Expanded information on Help File sources.
   In an earlier message I referred to four authors For the book in (1)
below - my mistake - there are three.
    Derek

(1) 'A Programmer's Guide to Turbo Vision' by Ertl, Machholz and Golgath,
authored by the Pascal product management team at Borland in Germany.
Pub. Addison-Wesley, ISBN 0-201-62401-X.
The book contains chapter 12 ( 18 pages ) describing how to add a
conText sensitive help Unit to your own TV Program.
The use of TVHC is described ( 2 pages ). TVHC generates helptxt.pas and
helptxt.hlp Files from a special helptxt.txt File. The .pas File is
included in your main routine as a Unit. The HelpFile Unit is also needed,
this Unit, TVHC and a working example are in the TVDEMO subdirectory.
This .hlp File is not compatible With the Borland supplied Dos help Files,
these have a name of the form *.t*h. I believe I am correct in stating that,
other than demohelp.hlp, all supplied *.hlp Files are For Windows use.

(2) The 'Borland Open Architecture Handbook For Pascal' describes and
supplies the Program HL.EXE. Chapter 8 tells you '...how to create, build,
and maintain Borland Dos Help Files'. I have attached information gleaned
from this book.
There are two sections, the first is information taken from the book and
the second is a Unit holding data structures.

look For the *****cut here*****.

******************cut here*********************
{  See `Borland Open Architecture Handbook For Pascal' pages 170-177 }
(***************************************************************
Binary help File format -

Records are grouped in four sections

 1 - File stamp
 2 - File signature
 3 - File version
 4 - Record Headers
   a - File header Record
   b - conText
   c - Text
   d - keyWord
   e - index
   f - compression Record
   g - indextags {= subheadings, = qualifiers}

   ***************************************************************

 1 - A File stamp is a null terminated String, note case,
      `TURBO PASCAL HelpFile.\0' or
      `TURBO C Help File.\0'  identifying the File in readable form.
      The null Character is followed by a Dos end-of-File Charcater $1A.
      This is defined as ;STAMP in the help source File.

 2 - The File signature For Borland products is a null terminated
      String `$*$* &&&&$*$' (no quotes in help Files).
      This is defined as ;SIGNATURE in the help source File.

 3 - The File version is a Record of two Bytes that define the version
      of help format and the help File Text respectively,

      Type
        TPVersionRec    = Record
          Formatversion : Byte;
          TextVersion   : Byte   {defined With ;VERSION}
          { this is For info only }
        end;
      FormatVersion For BP7     = $34
                        TP6     = $33
                        TP5     = $04
                        TP4     = $02
                        TC++3.0 = $04

 4 - Record Headers -
  All the remaining Records have a common format that includes a header
  identifying the Record's Type and length.

    Type
      TPrecHdr  = Record;
        RecType   : Byte;
        RecLength : Word;
      end;

  Field RecType is a code that identifies the Record Type.
    Type
      RecType =
        (RT_FileHeader,    {0}
         RT_ConText,       {1}
         RT_Text,          {2}
         RT_KeyWord,       {3}
         RT_Index,         {4}
         RT_Compression);  {5}
         RT_IndexTags,     {6 - only in FormatVersion $34}

  Field RecLength gives the length of the contents of the Record in
  Bytes, not including the Record header. The contents begin With the
  first Byte following the header.

  The field `RecType' Types are explained in the following Text.

  Although this structure allows an arbitrary order of Records, existing
  Borland products assume a fixed Record ordering as follows:-
        File header Record
        compression Record
        conText table
        index table
        indextags Record {introduced in BP7}
        Text Record
        keyWord Record

 4.a The File header Record defines Various parameters and options
  common to the help File.

  Type
    TPFileHdrRec     = Record
      Options        : Word;
      MainIndexScreen: Word;
      Maxscreen size : Word;
      Height         : Byte;
      Width          : Byte;
      LeftMargin     : Byte;
    end;

      Options - is a bitmapped field. Only one option currently
                supported.
                OF_CaseSense ($0004) (C only, not Pascal)
                  if set, index tokens are listed in mixed case
                  in the Index Record, and index searches will
                  be Case sensitive.
                  if cleared, index tokens are all uppercase in
                  the Index Record, and index searches will ignore
                  case.
                  Defined With ;CASESENSE.

      MainIndexScreen - this is the number assigned to the conText
                  designated by the ;MAININDEX command in the help
                  source File.
                  if ;MAININDEX is not used, MainIndexScreen is set
                  to zero.

      MaxScreenSize - this is the number of Bytes in the longest Text
                  Record in the File (not including the header). This
                  field is not currently in use.

      Height, Width - This is the default size in rows and columns,
                  respectively, of the display area of a help Window.
                  Defined With ;HEIGHT and ;WIDTH.

      LeftMargin - Specifies the number of columns to leave blank on
                  the left edge of all rows of help Text displayed.
                  Defined With ;LEFTMARGIN.

 4.b ConText table -
  This is a table of Absolute File offsets that relates Help conTexts to their
  associated Text. The first Word of the Record gives the number of conTexts
  in the table.
  The remainder of the Record is a table of n ( n given by first Word) 3-Byte
  Integers (LSByte first). The table is indexed by conText number (0 to n-1).
  The 3-Byte Integer at a given index is an Absolute Byte that is offset in
  the Help File where the Text of the associated conText begins.
  The 3-Byte Integer is signed (2's complement).
  Two special values are defined -
        -1 use Index Screen Text (defined in File Header Record).
        -2 no help available For this conText.
  ConText table entry 0 is not used.

 4.c Text descriptions -
  The Text Record defines the compressed Text of conText.
  Text Records and keyWords appear in pairs, With one pair For each
  conText in the File. The Text Record always precedes its associated
  keyWord. Text Records are addressed through the File offset values
  found in the conText table described above.

  The RecLength field of the Text Record header defines the number
  of Bytes of compressed Text in the Record.
  The Compression Record defines how the Text is compressed.
  if the Text is nibble encoded, and the last nibble of the last Byte
  is not used, it is set to 0.
  Lines of Text comprising the the Text Record are stored as null
  terminated Strings.

 4.d the keyWord Record defines keyWords embedded in the preceeding Text
  Record, and identifies related Text Records.
  The Record begins With the following fixed fields:
    UpConText   : Word;
    DownConText : Word;
    KeyWordCnt  : Word;

  UpConText and DownConText give the conText numbers of the previous
  and next sections of Text in a sequence, either may be zero,
  indicating the end of the conText chain.

  KeyWordCnt gives the number of keyWords encoded in the associated
  Text Record.
  Immediately following this field is an Array of KeyWord Descriptor
  Records of the following form:
    Type
      TPKwDesc = Record;
        KwConText: Word;
      end;

  The keyWords in a Text Record are numbered from 1 to KeyWordCnt in the
  order they appear in the Text (reading left to right, top to bottom).

  KwConText is a conText number (index into the conText table) indicating
  which conText to switch to if this keyWord is selected by the user.

 4.e Index table -
  This is a list of index descriptors.
  An index is a token (normally a Word or name) that has been explicitly
  associated With a conText using the ;INDEX command in the source Text File.
  More than one index may be associated With a conText, but any given index
  can not be associated With more than one conText.
  The list of index descriptors in the Index Record allows the Text of an
  index token to be mapped into its associated conText number.

  The first Word of the Record gives the number of indexes defined in the
  Record.
  The remaining Bytes of the Record are grouped into index descriptors.
  The descriptors are listed in ascending order based on the Text of the index
  token (normal ascii collating sequence). if the OF_CaseSense flag is not set
  in the option field of the File header Record, all indexes are in uppercase
  only.

  Each index descriptor Uses the following format:
    LengthCode    : Byte;
    UniqueChars   : Array of Byte;
    ConTextNumber : Word;

  The bits of LengthCode are divided into two bit fields.
  Bits(7..5) specify the number of Characters to carry over from the start of
  the previous index token String.
  Bits(4..0) specify the number of unique Characters to add to the end of the
  inherited Characters.

  Field UniqueChars gives the number of unique Characters to add.
  e.g. if the previous index token is `addition', and the next index token is
  `advanced', we inherit two Characters from the previous token (ad), and add
  six Characters (vanced); thus LengthCode would be $46.

  ConTextNumber gives the number of the conText associated With the index.
  This number is an index into the conText table described above.

 4.f A compression Record defines how the contents of Text Records are
  encoded.
     Type
       TPCompress = Record
         CompType : Byte;
         CharTable: Array[0..13] of Byte;
       end;

  CompType - nibble encoding is the only compression method currently
             in use.
                     Const CT_Nibble = 2;
  The Text is encoded as a stream of nibbles. The nibbles are stored
  sequentially; the low nibble preceeds the high nibble of a Byte.
  Nibble values ($0..$D) are direct indexes into the CharTable field of
  the compression Record. The indexed Record is the literal Character
  represented by the nibble. The Help Linker chooses the 14 (13?) most
  frequent Characters For inclusion in this table. One exception is that
  element 0 always maps to a Byte value of 0.

  The remaining two nibble values have special meanings:
          Const
            NC_RawChar = $F;
            NC_RepChar = $E;

  Nibble code NC_Char introduces two additional nibbles that define a
  literal Character; the least significant nibble first.

  Nibble code NC_RepChar defines a Repeated sequence of a single Character.
  The next nibble gives the Repeat count less two, (counts 2 to 17 are
  possible)
  The next nibble(s) define the Character to Repeat; it can be either a
  single nibble in the range ($0..$D) representing an index into
  CharTable, or it can be represented by a three nibble NC_RawChar
  sequence.


 4.g RT_IndexTags is in FormatVersion $34 only. This provides a means
  For including index sub headings in the help File.
  The Record header is followed by a list of Variable length tag Records
  Type
    IndRecType = Record;
      windexNumber: Word; {index into the RT_Index Record }
      StrLen: Byte;  {length of tag String(not including terminating 0)}
      szTag: Array[0..0] of Char; {disable range checking}{zero term tag
                                   String}
    end;
   The first structure in the Array is a special entry which has the
   windexnumber set to $FFFF, and contains the default ;DESCRIPTION
   in Case there are duplicate index entries and no tags were specified.
*)

Unit HelpGlobals;
{ This File contains only the structures which are found in the help Files }

Interface

Const
  Signature      = '$*$* &&&&*$';   {+ null terminator }
  NC_RawChar     = $F;
  NC_RepChar     = $E;

Type
  FileStamp      = Array [0..32] Of Char; {+ null terminator + $1A }
  FileSignature  = Array [0..12] Of Char; {+ null terminator }

  TPVersion      = Record
    FormatVersion : Byte;
    TextVersion   : Byte;
  end;

  TPRecHdr       = Record
    RecType   : Byte; {TPRecType}
    RecLength : Word;
  end;

Const   {RecType}
  RT_FileHeader  = Byte ($0);
  RT_ConText     = Byte ($1);
  RT_Text        = Byte ($2);
  RT_KeyWord     = Byte ($3);
  RT_Index       = Byte ($4);
  RT_Compression = Byte ($5);
  RT_IndexTags   = Byte ($6);


Type
  TPIndRecType = Record
    windexNumber : Word;
    StrLen       : Byte;
    szTag        : Array [0..0] Of Char;
    { disable range checking}
  end;

  TPFileHdrRec = Record
    Options         : Word;
    MainIndexScreen : Word;
    Maxscreensize   : Word;
    Height          : Byte;
    Width           : Byte;
    LeftMargin      : Byte;
  end;


  TP4FileHdrRec = Record                  {derived from sample File}
    Options    : Word;
    Height     : Byte;
    Width      : Byte;
    LeftMargin : Byte;
  end;

  TPCompress = Record
    CompType  : Byte;
    CharTable : Array [0..13] Of Byte;
  end;

  TPIndexDescriptor = Record
    LengthCode    : Byte;
    UniqueChars   : Array [0..0] Of Byte;
    ConTextNumber : Word;
  end;

  TPKeyWord = Record
    UpConText   : Word;
    DownConText : Word;
    KeyWordCnt  : Word;
  end;

  TPKwDesc = Record
    KwConText : Word;
  end;


  TmyStream = Object(TBufStream) end;

  PListRecHdr = ^RListRecHdr;

  RListRecHdr = Record
    PNextHdr : PListRecHdr; {Pointer to next list element}
    RRecType : TPRecHdr;    {RecType, RecLength}
    PRecPtr  : Pointer;     {Pointer to copy of Record}
  end;

  ConTextRecHd = Record
    NoConTexts  : Word;
    PConTextRec : Pointer;
  end;


Implementation
end.


