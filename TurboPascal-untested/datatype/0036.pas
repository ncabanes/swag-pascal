{
>Does anybody have the byte by byte break down of SAUCE?

Sure do, got it off of the June 6th ACid Pack, 1994.  Check it out for
more Info on Sauce.  Here goes:


****************************
* What is SAUCE?           *
****************************


   Recipe for SAUCE

   Chef cuisinier : Tasmaniac / ACiD
   Maitre d'h*tel : Rad Man / ACiD

   PLATES
   ------

        Let us begin with a description  of  the record layouts used.
   The record layouts and code  examples  are  in  a  varieted pascal
   pseudo code, and should  be  transferrable  enough to implement in
   most  other  programming  languages.  For  ease  of  reading,  the
   examples assume  that  the  file  is  correct  and  that no error-
   checking need be included.  How  rigorous  you check for errors is
   completely up to you, and will most likely depend on the file type
   you are describing.


   SAUCE RECORD
   ------------

        This portion of the documentation  is about the SAUCE record.
   The SAUCE record describes the  file  in short, and provides other
   information not included in the SAUCE record itself.

   A sauce record is _EXACTLY_ 128 bytes in size.

   Fieldname   : Name of the field.
   Size        : Size of the field in BYTES
   Type        : Type of data. This can be :
     BYTE      : One byte unsigned numeric value (0 to 255)
     WORD      : Two byte unsigned numeric value (0 to 65535)
     INTEGER   : Two byte signed numeric value (-32768 to 32767)
     LONG      : Four byte signed numeric value (-2147483648 to 2147483647)
     CHARACTER : One byte ASCII value.  Longer character fields are
                 padded with spaces.  It is _NOT_ a PASCAL string (with a
                 leading length byte), and it's _NOT_ a C-Style string
                 (with a trailing nul-byte).  A 10 byte character field
                 holding the text 'ANSI' would look like this.
                 'ANSI      '.

        Numeric fields should be zero when not used, character fields
   should be all spaces when not used.

    V#          : SAUCE Version number.  This indicates the version of
                  SAUCE when the field was implemented.

    Description : Complete description of the field.


    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    No fields are REQUIRED to be filled in except for ID, Version, FileSize,
    DataType and FileType.
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    FieldName Size Type      V# Description
    --------- ---- --------- -- -----------
    ID          5  Character 00 SAUCE Identification. This should be equal to
                                'SAUCE' or the record is not a valid SAUCE
                                record.
    Version     2  Character 00 Version number of SAUCE. Current version is
                                '00'.  As new features are added to the
                                specifications of SAUCE, this version number
                                will change.  Future versions SHOULD remain
                                compatible with version 00 only ADDING on
                                the specifications, it is however not unlikely
                                that this compatibility is impossible to
                                maintain, but this is of no concern now.
    Title      35  Character 00 Title of the file.
    Author     20  Character 00 Name or handle of the creator of the file.
    Group      20  Character 00 Name of the group the creator is employed by.
    Date        8  Character 00 Date the file was created. This date is in
                                the format CCYYMMDD (Century, year, month,
                                day).  There is a good reason why the date
                                is in this format, but it's not used in
                                version '00' of SAUCE.  It will be used in
                                a future version of SAUCE.
    FileSize    4  Long      00 Original filesize NOT including any
                                information of SAUCE.
    DataType    1  Byte      00 Type of Data. (See DATATYPES further on)

    FileType    1  Byte      00 Type of File. (See DATATYPES further on)
    TInfo1      2  Word      00 Numeric information field 1 (See DATATYPES)
                                When used, this field holds informative
                                values.  Any program using SAUCE should not
                                rely on these values being correct or filled
                                in.
    TInfo2      2  Word      00 Numeric information field 2 (See DATATYPES)
    TInfo3      2  Word      00 Numeric information field 3 (See DATATYPES)
    TInfo4      2  Word      00 Numeric information field 4 (See DATATYPES)
    Comments    1  Byte      00 Number of Comment lines (See COMMENTS)
    Filler     23  Byte         Reserved bytes.


    An Example PASCAL record looks like this:

      TYPE SAUCERec = RECORD
                        ID       : Array[1..5] of Char;
                        Version  : Array[1..2] of Char;
                        Title    : Array[1..35] of Char;
                        Author   : Array[1..20] of Char;
                        Group    : Array[1..20] of Char;
                        Date     : Array[1..8] of Char;
                        FileSize : Longint;
                        DataType : Byte;
                        FileType : Byte;
                        TInfo1   : Word;
                        TInfo2   : Word;
                        TInfo3   : Word;
                        TInfo4   : Word;
                        Comments : Byte;
                        Filler   : Array[1..23] of Char;
                      END;

    DATATYPES
    ---------
        DataType and FileType hold the information needed to deter-
    mine what type of file it is.

    There are 5 DataTypes, these are (with their respective numeric values) :
      0) None      : Undefined filetype, you could use this to add SAUCE
                     information to personal datafiles needed by programs,
                     but not having any other meaning.
      1) Character : Any character based file.  Examples are ASCII, ANSi and
                     RIP.
      2) Graphics  : Any bitmap graphic file.  Examples are GIF, LBM, and
                     PCX.
      3) Vector    : Any vector based graphic file.  Examples are DXF and
                     CAD files.
      4) Sound     : Any sound related file.  Examples are samples, MOD
                     files and MIDI.

     None
     ----
     When using the 'None' datatype, you should have FileType set to
     zero also.  This is a compatibility issue as it's not unlikely,
     the 'None' datatype will have filetypes in the future.

     Character
     ---------
     When using the 'Character' datatype, you have following filetypes
     available :

      0) ASCII     : Plain text file with no formatting codes or color codes.
                     TInfo1 is used for the width of the file.
                     TInfo2 is used to hold the number of lines in the file.
      1) ANSi      : ANSi file.  With ANSi color codes and cursor
                     positioning.
                     TInfo1 is used for the width of the file.
                     TInfo2 is used to hold the number of ANSi screen lines
                     in the file.
      2) ANSiMation: ANSi Animation.  With ANSi color codes and cursor
                     positioning.  While an ANSi file can also have animated
                     sequences, there is a clear distinction.  While an ANSi
                     may or may not have a beginning animated sequence
                     introducing the group or artist the rest is just a
                     sequence of colored characters.  An ANSiMation on the
                     other hand is a more like a text mode cartoon.
                     TInfo1 is used for the width of the file.
                     TInfo2 is used to hold the number of ANSi screen lines
                     the ANSiMation was created for.
                     A program using SAUCE may use these two values to
                     switch to the appropriate video mode.
      3) RIP       : Remote Imaging Protocol (RIP) graphics file.
                     TInfo1 holds the width (should be 640)
                     TInfo2 holds the height (should be 350)
                     TInfo3 holds the number of colors (should be 16)
      4) PCBoard   : File with PCBoard style @X color codes and @ macro's
                     and ANSi codes.
                     TInfo1 is used for the width of the file.
                     TInfo2 is used to hold the number of ANSi screen lines
                     in the file.
      5) AVATAR    : A file with AVATAR and ANSi color codes and cursor
                     positioning.


     Graphics
     --------
     For all graphics types, TInfo1 holds width of the image, TInfo2
     holds the Height of the image and TInfo3 holds the number of bits
     per pixel (a 256 colour image would have 8 bits per pixel, a
     TrueColor image would have 24);

     Following Graphics filetypes are available :

     0) GIF     (CompuServ Graphics Interchange format).
     1) PCX     (ZSoft Paintbrush PCX format).
     2) LBM/IFF (DeluxePaint LBM/IFF format).
     3) TGA     (Targa Truecolor)
     4) FLI     (Autodesk FLI animation file).
     5) FLC     (Autodesk FLC animation file).
     6) BMP     (Windows Bitmap)
     7) GL      (Grasp GL Animation)
     8) DL      (DL Animation).
     9) WPG     (Wordperfect Bitmap)


     Vector
     ------
     Following Vector filetypes are available :
     0) DXF     (CAD Data eXchange File)
     1) DWG     (AutoCAD Drawing file)
     2) WPG     (WordPerfect/DrawPerfect vector graphics)


     Sound
     -----
     Following sound filetypes are available :
     0)  MOD    (4, 6 or 8 channel MOD/NST file)
     1)  669    (Renaissance 8 channel 669 format)
     2)  STM    (Future Crew 4 channel ScreamTracker format)
     3)  S3M    (Future Crew variable channel ScreamTracker3 format)
     4)  MTM    (Renaissance variable channel MultiTracker Module)
     5)  FAR    (Farandole composer module)
     6)  ULT    (UltraTracker module)
     7)  AMF    (DMP/DSMI Advanced Module Format)
     8)  DMF    (Delusion Digital Music Format (XTracker))
     9)  OKT    (Oktalyser module)
     10) ROL    (AdLib ROL file (FM))
     11) CMF    (Creative Labs FM)
     12) MIDI   (MIDI file)
     13) SADT   (SAdT composer FM Module)
     14) VOC    (Creative Labs Sample)
     15) WAV    (Windows Wave file)
     16) SMP8   (8 Bit Sample, TInfo1 holds sampling rate)
     17) SMP8S  (8 Bit sample stereo, TInfo1 holds sampling rate)
     18) SMP16  (16 Bit sample, TInfo1 holds sampling rate)
     19) SMP16S (16 Bit sample stereo, TInfo1 holds sampling rate)


    COMMENTS
    --------
        The  comment  block  is an addition to the SAUCE  record.  It
    holds up to  255  lines of additional information.  Each  line 64
    characters wide.

        When the Comments field is not  zero,  it holds the number of
    additional comment lines are available.  A single comment line is
    64 characters  long.  Like  the character  fields  in  the  SAUCE
    record, it is padded with spaces,  and has no leading length byte
    or trailing null-byte.

        The comment block is  preceded  with  a 5 character identifi-
    cation mark.  This identification mark is 'COMNT'.


    SAUCE IN FILES
    --------------
        A file with SAUCE added to it.  Will look like this:

     *****************
     *               *
     *   FILE DATA   *  Actual file data.  As if it would be without SAUCE.
     *               *
     *****************
     *               *
     *  EOF MARKER   *  EOF marker.  This will assure character files can
     *               *  easily determine the end of file.
     *****************
     *               *
     * COMMENT BLOCK *  Optional Comment block.
     *               *
     *****************
     *               *
     * SAUCE RECORD  *  SAUCE record.
     *               *
     *****************



    The Comment block

     *****************
     *               *
     *   'COMNT'     *  Comment block ID bytes
     *               *
     *****************
     *               *
     * COMMENTLINE 1 *  First comment line
     *               *
     *****************
     *               *
     * COMMENTLINE 2 *  Second comment line
     *               *
     *****************
     ...
     *****************
     *               *
     * COMMENTLINE N *  n-th comment line, n equals the Comments field
     *               *  in SAUCE record.
     *****************



    EXAMPLE CODE TO READ SAUCE
    --------------------------
    Variables:
      Byte : Count;
      Long : FileSize;
      file : F;

    Code:
      Open_File(F);                         | Open the file for read access
      FileSize = Size_of_file(F);           | Determine filesize
      Seek_file (F, FileSize-128);          | Seek to start of SAUCE (Eof-128)
      Read_File (F, SAUCE);                 | Read the SAUCE record
      IF SAUCE.ID="SAUCE" THEN              | ID bytes match "SAUCE" ?
         IF SAUCE.Comments>0 THEN           | Is there a comment block ?
            Seek_File(F, FileSize-128-(SAUCE.Comments*64)-5);
                                            | Seek to start of Comment block.
            Read_File(F, CommentID);        | Read Comment ID.
            IF CommentID="COMNT" THEN       | Comment ID matches "COMNT" ?
               For Count=1 to SAUCE.Comments| \ Read all comment lines.
                  Read_File(F, CommentLine) | /
               ENDFOR
            ELSE
               Invalid_Comment;             | Non fatal, No comment present.
            ENDIF
         ENDIF
      ELSE
         Invalid_SAUCE;                     | No valid SAUCE record was found.
      ENDIF



    SAUCE DATAFILE
    --------------
        The full specifications of the SAUCE datafile are not ready
    yet.


    INFORMATION OR UPGRADES
    -----------------------
        If you have a need for additional information on SAUCE, or
    need modifications, you can contact me at these places...

    Leave a message to TASMANIAC on any of these boards :

    FUN-derbird BBS +32-50-620112   USR 16800 Dual
                    +32-50-625717   ZyXEL 19200
    The End of TiME +1-803-855-0783 USR 21600 Dual
    Channel Zer0    +1-714-532-5950 Practical 14400
                    +1-714-532-5968 USR 16800 Dual


Ok, there you go.  I chopped off the introduction which was just the
names and such they invented for sauce.  And I removed the C code.
there's also a Pascal TPU in the 6/94 ACiD Pack, and a program called
SPOON so you can add sauce (though you can program your own now).

JUST REMEBER.  SAUCE IS NOT TP SPECIFIC.  ALL CHAR FIELDS ARE ARRAYS OF
CHARS, NOT STRINGS!!!!!

