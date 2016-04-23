UNIT CRC_Calc;

{
 ****************************************************************************
 * Name .......... CRC_Calc
 * Version ....... 1.01
 * Description ... To calculate a file's 32 bit CRC and compare it at each
 *                 runtime to prevent virus infection or hacking.
 * Programmer .... F. Martin Richardson, Jr.
 * Date Created .. October 3, 1992
 ****************************************************************************
 * Credits:
 *
 * CRC_Calc v1.01 - October 7, 1992
 *     Martin Richardson
 *
 * CRC_Calc v1.00 - October 3, 1992
 *     Martin Richardson
 *     415 Duvall Lane
 *     Annapolis, MD  21403
 *     (410) 626-0893
 *
 * Routines for calculations derived with the help of Doctor Dobb's Journal
 * #188, MAY 1992.
 ****************************************************************************
 * How to use it:
 *
 * This unit is real simple to use.  Simply include it in your USES clause
 * (eg: USES DOS, CRT, CRC_Calc) and compile the program.  Then run the
 * program for the first time.  This will generate the original CRC and
 * burn it into the program.  Then, each time the program is run after that,
 * the CRC is calculated again and compared to this value.  If they differ,
 * then the program was probably altered.  An appropriate message will be
 * printed, and the program will halt.
 *
 * A pointer CRC_Calc_Value is initialized with the current CRC value
 * at the onset and is global to your program.  A hacker might try to get
 * around your CRC check by patching your program to bypass the check
 * alltogether.  In this case, you may wish to scatter checks all through
 * your code to make sure the CRC was generated.  Compare CRC32_Value to the
 * pointer CRC_Calc_Value and, if they don't match, then something funny
 * is going on!
 *
 * ex: IF ( CRC32_Value <> LONGINT(CRC_Calc_Value^) ) THEN HALT( 1 );
 *
 * Be aware that, once CRC_Calc is used in your program, the .EXE file
 * cannot be changed!  Self-modifying .EXE's will bomb the first time they
 * are modified.  Compression programs (such as PKLITE) which shrink the .EXE
 * will also cause it to bomb (make sure you indicate this in your
 * documentation!).
 *
 * This program uses the public domain file WRITEXEC.PAS by David Doty to
 * write it's information to the .EXE.  This source says that WRITEXEC was
 * developed in TP v4.0 but I have found it to work all the way up to 6.0.
 ****************************************************************************
 * Notes:
 *
 * This file is hereby commited to the public domain.  Feel free to use it in
 * your development.  All I ask is a little recognition if you use it in your
 * software.  Also, if this file is modified in any way and re-distributed,
 * please retain the credits to the people who wrote the routines.
 *
 * Comments, suggestions, and gifts of LOTS of money may be addressed to:
 *
 *      Martin Richardson
 *      415 Duvall Lane
 *      Annapolis, MD  21403
 *      (410) 626-0893 (voice)
 ****************************************************************************
 * Update History:
 *
 * v1.01 - October 7, 1992 - Ooops! release.
 *
 *       : Fixed so it would compile under TP 5.0.  In TP 6.0 you can 
 *         increment a pointer directly (as INC( p )), but TP 5.0 will not 
 *         allow you this luxury!  As I originally coded this in 6.0, that 
 *         didn't even occur to me until I tried to compile it in 5.5.
 *
 *       : Included correct version of WRITEXEC.PAS.  Version in v1.00 
 *         contained an extraneous include to include the file HEX.PAS that 
 *         wasn't needed.  I just had it there for debugging and forgot to
 *         take it out!
 *
 *       : Included credits to DDJ for help with the CRC calculation 
 *          routines.
 *
 * v1.00 - October 3, 1992 
 *
 *       : Initial Release
 ****************************************************************************
}

INTERFACE

USES DOS, CRT, WritExec;

CONST
     CRC_Polynomial = $EDB88320;

     CRC32_Offs   : LONGINT = $FFFFFFFF;   { Pointer to CRC32_Value }
     CRC32_Value  : LONGINT = $FFFFFFFF;   { Original CRC32 Value }

VAR
   CRC_Calc_Value: ^LONGINT;

IMPLEMENTATION

TYPE
    CRC_Buffer_Type = ARRAY[1..512] OF BYTE;

VAR
   CRC_Table: ARRAY[0..255] OF LONGINT;

{*****************************************************************************
 * Function ...... GetFName()
 * Purpose ....... To extract a file name (minus .EXE) from a path string
 * Parameters .... Path       Path string to extract name from
 * Returns ....... A 1-8 character file name
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 3, 1992
 *****************************************************************************}
FUNCTION GetFName( Path : STRING ): NameStr;
VAR dir  : DirStr;
    name : NameStr;
    ext  : ExtStr;
BEGIN
     FSPLIT( path, dir, name, ext );
     GetFName := name;
END;

{*****************************************************************************
 * Function ...... ErrorMsg()
 * Purpose ....... To return the message associated with a passed error code
 * Parameters .... e        Error code for the message to print
 * Returns ....... The message associated with the passed error code
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 3, 1992
 *****************************************************************************}
FUNCTION ErrorMsg( e: INTEGER ): STRING;
VAR s: STRING;
BEGIN
     CASE e OF
          0: ErrorMsg := 'No Error';
          2: ErrorMsg := 'File Not Found';
          3: ErrorMsg := 'Path Not Found';
          4: ErrorMsg := 'Too Many Open Files';
          5: ErrorMsg := 'File Access Denied';
          6: ErrorMsg := 'Invalid File Handle';
         12: ErrorMsg := 'Invalid File Access Code';
         15: ErrorMsg := 'Invalid Drive Number';
         16: ErrorMsg := 'Cannot Remove Current Directory';
         17: ErrorMsg := 'Cannot Rename Across Drives';
         18: ErrorMsg := 'File access error';
        100: ErrorMsg := 'Disk Read Error';
        101: ErrorMsg := 'Disk Write Error';
        102: ErrorMsg := 'File Not Assigned';
        103: ErrorMsg := 'File Not Open';
        104: ErrorMsg := 'File Not Open For Input';
        105: ErrorMsg := 'File Not Open For Output';
        106: ErrorMsg := 'Invalid Numeric Format';
        150: ErrorMsg := 'Disk Is Write-Protected';
        151: ErrorMsg := 'Unknown Unit';
        152: ErrorMsg := 'Drive Not Ready';
        153: ErrorMsg := 'Unknown Command';
        154: ErrorMsg := 'CRC Error In Data';
        155: ErrorMsg := 'Bad Drive Request Structure Length';
        156: ErrorMsg := 'Disk Seek Error';
        157: ErrorMsg := 'Unknown Media Type';
        158: ErrorMsg := 'Sector Not Found';
        159: ErrorMsg := 'Printer Out Of Paper';
        160: ErrorMsg := 'Device Write Fault';
        161: ErrorMsg := 'Device Read Fault';
        162: ErrorMsg := 'Hardware Failure';
        ELSE BEGIN
                  STR( e:0, s );
                  ErrorMsg := 'Unknown Error Number: ' + s;
             END;
    END; { CASE }
END;

{*****************************************************************************
 * Procedure ..... Store_CRC_Offset
 * Purpose ....... To calculate where the CRC32_Value is in the .EXE file and
 *                 store the offset to CRC32_Offs.
 * Parameters .... None
 * Returns ....... Nothing
 * Notes ......... This will write the position of CRC32_Value into the .EXE
 *                 file.  This routine was partly taken from WRITEXEC.PAS.
 * Authors ....... David Doty and Martin Richardson
 * Date .......... October 3, 1992
 ****************************************************************************}
PROCEDURE Store_CRC_Offset;
CONST
   PrefixSize = 256; { number of bytes in the Program Segment Prefix }
VAR
   f : FILE;
   HeaderSize : WORD;
   nErrorCode : INTEGER;
BEGIN
     {$I-}
     ASSIGN( f, PARAMSTR(0) );
     RESET( f, 1 );
     nErrorCode := IOResult;

     IF nErrorCode = 0 THEN BEGIN
        Seek( f, 8 );
        nErrorCode := IOResult
     END { IF };

     IF nErrorCode = 0 THEN BEGIN
        BlockRead( f, HeaderSize, SizeOf( HeaderSize ) );
        nErrorCode := IOResult
     END { IF };

{** This is here just to make sure the offset is correct by generating an
    error if it is not **}
   IF nErrorCode = 0 THEN BEGIN
      Seek( f, LONGINT(16) * ( HeaderSize + Seg(CRC32_Value) - PrefixSeg ) +
            Ofs( CRC32_Value ) - PrefixSize );
      nErrorCode := IOResult
   END { IF };

   IF nErrorCode <> 0 THEN BEGIN
      Writeln( 'Error calculating CRC offset: ', ErrorMsg( nErrorCode ) );
      HALT( 1 );
   END { IF };
   CRC32_Offs := FilePos( f );
   CLOSE( f );

   IF WriteToExecutable( CRC32_Offs, SIZEOF( CRC32_Offs ) ) <> 0 THEN BEGIN
      WRITELN( 'Error storing CRC offset...' );
      HALT( 1 );
   END { IF };
   {$I+}
END;

{*****************************************************************************
 * Procedure ..... Build_CRC_Table
 * Purpose ....... To build the 32 bit CRC table
 * Parameters .... None
 * Returns ....... Nothing
 * Notes ......... Fills an array called CRC_Table with the appropriate
 *                 values.
 * Author ........ Martin Richardson
 * Date .......... October 3, 1992
 ****************************************************************************}
PROCEDURE Build_CRC_Table;
VAR x, y: INTEGER;
    CRC_Value: LONGINT;
BEGIN
     FOR x := 0 TO 255 DO BEGIN
         CRC_Value := x;
         FOR y := 1 TO 8 DO
             IF (CRC_Value AND 1 = 1) THEN
                CRC_Value := (CRC_Value SHR 1) XOR CRC_Polynomial
             ELSE
                CRC_Value := CRC_Value SHR 1;
        CRC_Table[ x ] := CRC_Value;
     END { NEXT x }
END;

{*****************************************************************************
 * Function ...... Calculate_CRC_Buffer
 * Purpose ....... Calculates a CRC for the current buffer
 * Parameters .... nCount       Number of bytes in the buffer
 *                 CRC_Value    The current CRC value to this point
 *                 cBuffer      The buffer to calculate the CRC against
 * Returns ....... New CRC value which includes the passed buffer
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 3, 1992
 * Updates ....... October 7, 1992 - Fixed problem with incrementing the
 *                    pointer so it would not compile versions of TP before
 *                    version 6.0.
 ****************************************************************************}
FUNCTION Calculate_CRC_Buffer( nCount: INTEGER; CRC_Value: LONGINT;
                               cBuffer: CRC_Buffer_Type ): LONGINT;
VAR
   p: ^BYTE;
   nTemp1, nTemp2: LONGINT;
   i: INTEGER;
BEGIN
     p := @cBuffer;
     FOR i := 1 TO nCount DO BEGIN
           nTemp1 := (CRC_Value SHR 8) AND $00FFFFFF;
           nTemp2 := CRC_Table[ (CRC_Value XOR p^) AND $FF ];
           CRC_Value := nTemp1 XOR nTemp2;

{** This line will work under TP v6.0, but not 5.5 and below...
           INC( p );
 **}

{** This line works under both 5.0 and 6.0 ** }
           p := PTR( Seg(p^), Ofs(p^)+1 );

     END { NEXT i };
     Calculate_CRC_Buffer := CRC_Value;
END;

{*****************************************************************************
 * Function ...... Calculate_CRC32
 * Purpose ....... Calculates a 32 bit CRC for the current .EXE file
 * Parameters .... None
 * Returns ....... CRC32 value for the current file
 * Notes ......... Since the original CRC32 value must be stored in the
 *                 file, we will always generate a different CRC32.  We
 *                 must therefore convert the CRC32_Value variable back to
 *                 what it was ($FFFFFFFF) when the originial CRC32 was
 *                 calculated.
 *               . Using the file size as the initial value for the CRC
 *                 helps guard against the program size changing, but
 *                 the CRC remaining the same. 
 * Author ........ Martin Richardson
 * Date .......... October 3, 1992
 ****************************************************************************}
FUNCTION Calculate_CRC32: LONGINT;
VAR
   ThisFile      : FILE;
   CRC_Value     : LONGINT;
   nCount        : INTEGER;
   cBuffer       : CRC_Buffer_Type;
   nBytes, nOffs : LONGINT;
BEGIN
     nBytes := 0;
     ASSIGN( ThisFile, PARAMSTR(0) );
     RESET( ThisFile, 1 );
     CRC_Value := FileSize( ThisFile );
     REPEAT
           BLOCKREAD( ThisFile, cBuffer, 512, nCount );
           IF CRC32_Value <> $FFFFFFFF THEN BEGIN

{** convert CRC32_Value back to what it was when it was calculated **}
              IF ((CRC32_Offs OR (CRC32_Offs+3)) >= nBytes) AND
                 ((CRC32_Offs OR (CRC32_Offs+3)) <= nBytes+nCount) THEN
                 BEGIN
                 FOR nOffs := 1 TO nCount DO
                  IF ((CRC32_Offs+1) <= (nBytes + nOffs)) AND
                     ((CRC32_Offs+4) >= (nBytes + nOffs)) THEN
                         cBuffer[nOffs] := $FF;
              END { IF };

              nBytes := nBytes + nCount;
           END { IF };

           IF nCount > 0 THEN
              CRC_Value := Calculate_CRC_Buffer(nCount, CRC_Value, cBuffer);
     UNTIL (nCount <= 0);
     Calculate_CRC32 := CRC_Value XOR FileSize( ThisFile );
     CLOSE( ThisFile );
END;

{*************************************************************************}
{* Main Routine
{*************************************************************************}
BEGIN
     NEW( CRC_Calc_Value );

{}
{** This is to prevent you from modifying your copy of TP by accident. **}
{** If your application is named TURBO, then you will have to remove   **}
{** these lines and be VERY careful not to run the program in the TP   **}
{** environment.                                                       **}
{}
     IF GetFName( PARAMSTR(0) ) = 'TURBO' THEN BEGIN
        CRC_Calc_Value^ := 0;
        CRC32_Value := 0;
        EXIT;
     END { IF };

(**
  This next step is for development purposes only.  While you are
  developing, you may not want to do the CRC check each time.  At the very
  top of this unit place the line {$DEFINE NOCRC} and the CRC routine will
  be bypassed.  CRC_Calc_Value WILL EQUAL CRC32_Value so your random checks
  in your code will be a-ok!
**)
{$IFDEF NOCRC}
        CRC_Calc_Value^ := 0;
        CRC32_Value := 0;
        EXIT;
{$ENDIF}

     Build_CRC_Table;

     IF CRC32_Value = $FFFFFFFF THEN BEGIN
        WRITE( 'Calculating CRC Value... ' );

        Store_CRC_Offset;
        WRITE( 'CRC Offset Stored... ' );

        CRC32_Value := Calculate_CRC32;

        IF WriteToExecutable(CRC32_Value, SIZEOF(CRC32_Value)) <> 0 THEN
        BEGIN
           WriteLn( 'Error writing to ' + PARAMSTR(0) );
           HALT( 1 );
        END { IF };

        WriteLn( 'CRC32 Value Initialized.' );
        HALT( 0 );
     END ELSE BEGIN
         CRC_Calc_Value^ := Calculate_CRC32;

         IF ( CRC32_Value <> LONGINT(CRC_Calc_Value^) ) THEN BEGIN
            WRITELN( 'ERROR!  Program has been altered!' );
            HALT( 1 );
         END { IF };
     END { IF };
END.

{* END OF FILE *}

