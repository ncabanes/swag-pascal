(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0046.PAS
  Description: Text File Paginator
  Author: DAVID DANIEL ANDERSON
  Date: 02-28-95  10:04
*)

PROGRAM PaginateTextFiles;
CONST
     ProgData = 'PAGINATE- Free DOS utility: text file paginator.';
     ProgDat2 = 'V1.00: July 14, 1993. (c) 1993 by David Daniel Anderson - Reign Ware.';
     Usage   = 'Usage:   PAGINATE /i<infile> /o<outfile> /l##[:##] (lines per odd/even page)';
     Example = 'Example: PAGINATE /iNOTPAGED.TXT /oPAGED.TXT /l55';
VAR
     IFL, OFL, LPP    : String[80];
     InFile, OutFile  : Text;
     OddL,EvenL       : Word;

PROCEDURE InValidParms( ErrCode : Word );
VAR
   Message : String[80];
BEGIN
     WriteLn(Usage);
     WriteLn(Example);
     CASE ErrCode OF
          1 : Message := 'Incorrect number of parameters on command line.';
          2 : Message := 'Invalid switch on command line.';
          3 : Message := 'Cannot open input file '+ IFL + '.';
          4 : Message := 'Cannot open NEW output file '+ OFL + '.';
          5 : Message := 'Non-numeric '+ LPP + ' specified for lines per page.';
     ELSE
          Message := 'Unknown error.';
     END;
     Writeln(Message);
     Halt;
END;

PROCEDURE ParseComLine;
CONST
     Bad = '';   {An invalid filename character & invalid integer.}
VAR
     SwStr            : String[1];
     SwChar           : Char;
     ic               : Byte;
     ArgText          : String[80];
BEGIN
     IF ParamCount <> 3 THEN
        InValidParms(1);

     IFL := Bad; OFL := Bad; LPP := Bad;

     FOR ic := 1 to 3 DO
     BEGIN
         SwStr  := Copy(ParamStr(ic),1,1);
         SwChar := UpCase(SwStr[1]);
         IF (SwChar <> '/') THEN
            InValidParms(2);
         SwStr := Copy(ParamStr(ic),2,1);
         SwChar := UpCase(SwStr[1]);
         ArgText := Copy(ParamStr(ic),3,(Length(ParamStr(ic))-2));
         CASE SwChar OF
              'I' : IFL := ArgText;
              'O' : OFL := ArgText;
              'L' : LPP := ArgText;
         END;
     END;
END;

PROCEDURE Open_I_O_Files;
BEGIN
     Assign(InFile,IFL);
{$I-} Reset(InFile); {$I+}
     IF IOResult <> 0 THEN
        InValidParms(3);

     Assign(OutFile,OFL);
{$I-} Rewrite(OutFile);  {$I+}
     IF IOResult <> 0 THEN
        InValidParms(4);
END;

PROCEDURE GetEvenOdd ( lpp_param : string; var oddnum, evennum : Word);
                       { determine page length for odd/ even pages }
VAR
   odds, evens,        { string of odd/ even lines per page }
   lstr  : string[5];  { entire string containing numbers needed }

   vlppo,vlppe,        { numeric of lines per page odd/even }
   lval  : byte;       { numeric of string containing numbers needed }

   pcode : integer; { error code, will be non-zero if strings are not numbers }

BEGIN
     lstr := lpp_param;

     IF ((pos(':',lstr)) <> 0) THEN
     BEGIN                                            { determine position of }
        odds  := copy(lstr,1,((pos(':',lstr))-1));    { any colon, and divide }
        evens := copy(lstr,((pos(':',lstr))+1),length(lstr)); { at that point }

        val(odds,vlppo,pcode);       { convert first part of string         }
        IF (pcode <> 0) THEN         { into numeric                         }
           InValidParms(5);          { show help if any errors              }

        val(evens,vlppe,pcode);      { convert first part of string         }
        IF (pcode <> 0) THEN         { into numeric                         }
           InValidParms(5);          { show help if any errors              }
     END

     ELSE BEGIN  { if colon not present, lines/pg should be entire parameter }
        val(lstr,lval,pcode);        { convert entire of string             }
        IF (pcode <> 0) THEN         { into numeric                         }
           InValidParms(5);          { show help if any errors              }
        vlppo := lval;
        vlppe := lval;
     END;
     oddnum  := vlppo;
     evennum := vlppe;
END;

PROCEDURE InsertFF( OddLines, EvenLines : Word);
CONST
     FF = '';
VAR
     LinesCopied,
     LinesPerPage,
     PageCopying   : Word;
     ALine         : String;
BEGIN
     LinesCopied := 0;
     LinesPerPage := OddLines;
     PageCopying := 1;
     WHILE (NOT Eof(InFile)) DO
     BEGIN
          ReadLn(InFile,ALine);
          IF (LinesCopied = LinesPerPage) THEN
          BEGIN
             ALine := FF + ALine;
             LinesCopied := 0;
             PageCopying := Succ(PageCopying);
             IF ((PageCopying MOD 2) = 0) THEN
                LinesPerPage := EvenLines
             ELSE
                LinesPerPage := OddLines;
          END;
          WriteLn(OutFile,ALine);
          LinesCopied := Succ(LinesCopied);
     END;
END;

BEGIN                                { main }
     Writeln(ProgData);
     Writeln(ProgDat2);
     Writeln;
     ParseComLine;
     Open_I_O_Files;
     GetEvenOdd(LPP,OddL,EvenL);
     Writeln('Input file: ',IFL,' - Output file: ',OFL,'.');
     Writeln('Lines per odd / even page: ',Oddl,' / ',EvenL,'.');
     InsertFF(OddL,EvenL);
     Close(InFile);
     Close(OutFile);
     Writeln('Done!');
END.

