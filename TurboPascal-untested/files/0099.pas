{

   The purpose  of this  program is to  convert an ICON  into an  INC file.




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

FUNCTION No_Extension (st : String) : String;

VAR
   wExtension : Word;

BEGIN

   wExtension := Pos('.', st);
   Delete (St, wExtension, Length(st));
   No_Extension := st;

END;

CONST

   IcoSize  = 766;
   FileName = 'TEST.ICO';

TYPE
   Buffer = ARRAY[1..IcoSize] OF Byte;

VAR
   fIco    : File of Buffer;
   fSource : Text;
   Buf     : ^Buffer;
   I       : Word;


BEGIN

   IF PARAMCOUNT=0 THEN
      BEGIN
         Writeln ('');
         Writeln ('AVC Software (c) AVONTURE Christophe');
         Writeln ('');
         Writeln ('');
         Writeln ('Convert an ICO file to a pascal source file.');
         Writeln ('Type ICO2PAS followed by the name of the ICO (extension must be there).');
         Writeln ('');
         Writeln ('  Example  ICO2PAS WINWORD.ICO will create a WINWORD.INC file');
         Writeln ('');
         Halt;
      END;

   GetMem (Buf, IcoSize);

   Assign (fIco, ParamStr(1));
   FileMode := 0;
   Reset (fIco);

   Read (fIco, Buf^);

   Close (fIco);


   Assign (fSource, No_Extension (FileName)+'.INC');
   FIleMode := 1;
   Rewrite (fSource);

   Writeln (fSource, 'Const '+No_Extension (FileName)+'_ICO : Array[1..766] of Byte =');

   FOR I := 1 TO IcoSize-1 DO
      IF I = 1 THEN
         Write (fSource, '           (', Buf^[I],',')
      ELSE IF I Mod 20 = 19 THEN
         BEGIN
            Writeln (fSource, Buf^[I],',');
            Write (fSource, '            ');
         END
      ELSE
         Write (fSource, Buf^[I],',');

   Write (fSource, Buf^[IcoSize],');');

   Close (fSource);

END.