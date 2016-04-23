{
                  =======================================

                       ANI2ICO V1.0 (c) AVC Software
                                Cardware

                   ANI2ICO extract all pictures from an
                   ANI file (animated cursor).

                   This is a DOS based program and help
                   can be obtain when you launch the
                   program without argument.

                           AVONTURE Christophe
                      Boulevard Edmond Macthens 157
                               Boite 53
                           B-1080 Bruxelles
                               BELGIQUE

                  =======================================


   The purpose of this program is to extract all CURSOR in a Windows 95 (c)
   Animated Cursor file (ANI  extension) and save these  cursors for  later
   use in Delphi, or all other Windows program that accept Cursor.

   I have use an Hexadecimal viewer program to find the layout of the file:
   don't ask  me about  the  signification of some  block or why  there are
   always 8 bytes between each cursors; and so on.

   This program works on  almost file: there are a few  Ani file where this
   program should not work -only for the last cursor-.




               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

}

Uses Crt;

TYPE
   TAniHeader = Record
      sRiff        : Array [1..4] of Char;
      wFileSize    : LongInt;
      sAconList    : Array [1..8] of Char;
      wTextSize    : LongInt;
      sInfoInam    : Array [1..8] of Char;
      wTitleLength : LongInt;
   End;

VAR
   fAni        : FILE;
   Header      : TAniHeader;
   sTitre      : String;
   sIART       : Array[1..4] of Char;
   wCopyLength : LongInt;
   sCopywrigth : String;
   sAnih       : Array[1..4] of Char;
   wSizeAnih   : LongInt;
   sRate       : Array[1..4] of Char;
   wSizeRate   : LongInt;
   sList       : Array[1..4] of Char;
   wSizeList   : LongInt;
   sFramIcon   : Array[1..8] of Char;
   wIconSize   : LongInt;
   sSeq        : Array[1..4] of Char;
   wSizeSeq    : LongInt;
   wHeaderSize : Word;

   pTemp       : Pointer;
   pBuf        : Pointer;
   pRate        : Pointer;
   pSeq        : Pointer;

   fIco        : File;
   pIco        : Pointer;
   wIco        : Word;
   sIcoName    : String;

   I           : Word;
   wTemp       : LongInt;

   sTemp       : String;

Procedure ClrScrWin (FirstCol, FirstLine, LastCol, LastLine : Byte);
Var I, J : byte;
    S    : String;
Begin
     J := (LastCol - FirstCol) + 1;

     FillChar(S[1], J, ' ');
     S[0] := Chr(J);

     For i:= FirstLine to LastLine Do
       Begin
          GotoXy (FirstCol, I);
          WriteLn (S);
       End;
End;

procedure Process;

begin

    GetMem (pTemp, 1000);
    GetMem (pBuf,  1000);
    GetMem (pRate, 1000);
    GetMem (pSeq,  1000);
    sSeq := '    ';

    Assign (fAni, ParamStr(1));
    filemode := 0;
    reset (fAni,1);

    BlockRead (fAni, Header,      SizeOf(Header));
    BlockRead (fAni, pTemp^,      Header.wTitleLength);

    FillChar (sTitre, 1, Header.wTitleLength);
    Move (pTemp^, sTitre[1], Header.wTitleLength);

    BlockRead (fAni, sIART,       SizeOf(sIart));
    IF sIart = chr(0)+'IAR' THEN
       BEGIN
         BlockRead (fAni, sIart, 1);
         sIart := 'IART';
       END;
	
    BlockRead (fAni, wCopyLength, SizeOf(wCopyLength));

    WITH Header DO
       wHeaderSize := SizeOf(sRiff) + SizeOf(wFileSize) + SizeOf(sAconList) +
                      SizeOf(wTextSize) + wTextSize;

    BlockRead (fAni, pTemp^,      wHeaderSize-FilePos(fAni));

    FillChar (sCopywrigth, 1, wCopyLength);
    Move (pTemp^, sCopywrigth[1], wCopyLength);

    BlockRead (fAni, sAnih,       SizeOf(sAnih));

    BlockRead (fAni, wSizeAnih,  SizeOf(wSizeAnih));


    BlockRead (fAni, pBuf^,       wSizeAnih);
    BlockRead (fAni, sRate,       SizeOf(sRate));

    IF (sRate = 'LIST') THEN
       BEGIN
          Move (sRate, sList, SizeOf(sList));
          sRate := '    ';
       END
    ELSE
       IF (sRate = 'seq ') THEN
          BEGIN
             Move (sRate, sSeq, SizeOf(sSeq));
             BlockRead (fAni, wSizeSeq,  SizeOf(wSizeSeq));
             BlockRead (fAni, pSeq^,     wSizeSeq);
             BlockRead (fAni, sList,     SizeOf(sList));
             sRate := '    ';
          END
       ELSE
          BEGIN
             BlockRead (fAni, wSizeRate, SizeOf(wSizeRate));

             BlockRead (fAni, pRate^,  wSizeRate);
             BlockRead (fAni, sList,       SizeOf(sList));
          END;

    IF NOT (sList = 'LIST') THEN
       BEGIN
          Move (sList, sSeq, SizeOf(sSeq));
          BlockRead (fAni, wSizeSeq,  SizeOf(wSizeSeq));
          BlockRead (fAni, pSeq^,     wSizeSeq);
          BlockRead (fAni, sList,     SizeOf(sList));
       END;

    BlockRead (fAni, wSizeList,   SizeOf(wSizeList));
    BlockRead (fAni, sFramIcon,   SizeOf(sFramIcon));
    BlockRead (fAni, wIconSize,   SizeOf(wIconSize));

    TextAttr := 14;

    WriteLn ('');
    WriteLn ('');
    WriteLn ('');
    WriteLn ('■ File : '+ParamStr(1));
    TextAttr := 11;
    WriteLn ('');
    WriteLn ('');
    WriteLn ('  Copywright message     : '+sCopywrigth);
    WriteLn ('');
    WriteLn ('');
    TextAttr := 10;

    GetMem (pIco, wIconSize);

    WHILE NOT (Eof(fAni)) DO
       BEGIN

          sIcoName := '';
          Str (wIco,sIcoName);

          IF wIco < 10 THEN
             sIcoName := 'ANI_000' + sIcoName + '.CUR'
          ELSE IF wIco < 100 THEN
             sIcoName := 'ANI_00' + sIcoName + '.CUR'
          ELSE IF wIco < 1000 THEN
             sIcoName := 'ANI_0' + sIcoName + '.CUR'
          ELSE
             sIcoName := 'ANI_' + sIcoName + '.CUR';

          Assign (fIco, sIcoName);
          Rewrite(fIco,1);

          BlockRead (fAni, pIco^, wIconSize);
          BlockWrite(fIco, pIco^, wIconSize);

          Close (fIco);

          IF NOT Eof(fAni) THEN
             BlockRead (fAni, pIco^, 8);

          Inc (wIco);

       END;

    Close (fAni);

    GotoXy (2, 15);
    sTemp := sIcoName;
    sIcoName := 'ANI_0000.CUR';
    WriteLn ('');
    WriteLn ('');
    WriteLn ('File saved : '+sIcoName+' to '+sTemp+'.');
    WriteLn ('');
    WriteLn ('');
    TextAttr := 7;

end;

Var
   Ch : Char;

begin

     ClrScr;
     TextAttr := 30;
     WriteLn('');
     WriteLn('┌──────────────────────────────────────────────────────────────────────┐');
     WriteLn('│ Ani2Ico : Extraction utility from Christophe AVONTURE                │');
     WriteLn('└──────────────────────────────────────────────────────────────────────┘');
     WriteLn('');
     WriteLn('');
     TextAttr := 7;

     If Not (ParamCount = 1) then Begin
        TextAttr := 14;
        WriteLn('■ PURPOSE');
        TextAttr := 11;
        WriteLn('');
        WriteLn('  Ani2Ico program  will allowed you to  extract all cursors pictures  from');
        WriteLn('  an animated Windows 95 (c) cursor file.');
        WriteLn('');
        WriteLn('  This program will scan the enterly file and, each time  he encounters an');
        WriteLn('  picture, he will saved it into the current directory.');
        WriteLn('');
        WriteLn('');
        Ch := ReadKey; If Ch = #0 then Ch := ReadKey;
        ClrScrWin (1,6,79,24);
        GotoXy (1,6);
        TextAttr := 14;
        WriteLn('■ UTILISATION');
        TextAttr := 11;
        WriteLn('');
        WriteLn('');
        WriteLn('  Very easy!');
        WriteLn('');
        WriteLn('');
        WriteLn('  Just type  the file name  of your  animated  cursor file  (with path  if');
        WriteLn('  needed) as the first parameter.');
        WriteLn('');
        WriteLn('  For example, you can type "Ani2Ico.Exe Eyes.Ani".');
        WriteLn('');
        WriteLn('  You will receive several file name ANI_9999.ICO  or ANI_9999.CUR depends');
        WriteLn('  on the size in bytes of the picture. 9999 is a numerical value from 0001');
        WriteLn('  to the number of images in the animated cursor.');
        WriteLn('');
        Ch := ReadKey; If Ch = #0 then Ch := ReadKey;
        ClrScrWin (1,6,79,24);
        GotoXy (1,6);
        TextAttr := 14;
        WriteLn('■ IN THE FUTURE');
        TextAttr := 11;
        WriteLn('');
        WriteLn('  Actually, I''m developping a Delphi component for  Delphi 1.0  and Delphi');
        WriteLn('  2.0 component.  This component will allowed you to  increase the  design');
        WriteLn('  of your applications by some animations.');
        WriteLn('');
        WriteLn('  This component is in developpement -I''ve just started-!');
        WriteLn('');
        WriteLn('  I think that I will distribute it as Shareware.  Wait and see...');
        WriteLn('');
        WriteLn('');
        WriteLn('  People interested by this component should send me an email  and type in');
        WriteLn('  the mail subject "Component TAVCAnimated wanted".');
        WriteLn('');
        WriteLn('');
        GotoXy (0,6);
        Ch := ReadKey; If Ch = #0 then Ch := ReadKey;
        ClrScrWin (1,6,79,23);
        GotoXy (1,6);
        TextAttr := 14;
        WriteLn('■ REGISTRATION');
        TextAttr := 11;
        WriteLn('');
        WriteLn('  This program is free. ');
        WriteLn('');
        WriteLn('  No need to send me a lot of  US Dollar but you can if you want  (Hum, is');
        WriteLn('  there somebody here?).');
        WriteLn('');
        WriteLn('  My only requirement is: IF YOU USE  THIS PROGRAM AND  IF THIS PROGRAM IS');
        WriteLn('  USEFULL, PLEASE  SEND ME A POSTCARD (MY PREFERENCE) FROM  WHERE YOU LIVE');
        WriteLn('  OR AN ELECTRONIC E-MAIL THROUGH INTERNET.  I WILL REALLY APPRECIATE.');
        WriteLn('');
        TextAttr := 10;
        WriteLn('   AVONTURE Christophe');
        WriteLn('   AVC Software');
        WriteLn('   boulevard Edmond Machtens, 175 - Bte 53');
        WriteLn('   B-1080 Bruxelles');
        WriteLn('   BELGIQUE');
        WriteLn('');
        Ch := ReadKey; If Ch = #0 then Ch := ReadKey;

     End
   ELSE
      Process;

end.