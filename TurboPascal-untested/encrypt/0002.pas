{ COPYINC.PAS    Author: Trevor J Carlsen
                         PO Box 568
                         Port Hedland  6721
                         Western Australia


SYNTAX:    copyinc Filename

where Filename is the name of a Text File you wish to create that will be used
as an include File in a Turbo Pascal Program.

This Program creates a Text File in the format

      Const
        RegStr  ='This Program is an unregistered copy';
        CodeStr =
        #125#34#139#139#74#71#94#61#44#78#65#155#158#132#62#136#141#140#84+
        #34#155#63#38#46#89#84#93#57#153#51#83#112#72#36#138#93;
        keyval  = 1234567890;

The Text File that was used by COPYINC to create the above include File would
have looked like this

p:\prog\freeload.inc
This Program is an unregistered copy
RegStr  =
CodeStr =
1234567890

Here is another example.  This was the include File -

      Const
        ChkStr     : String ='This Program is registered to';
        CodeChkStr : String =
        #32#153#90#34#133#140#42#129#150#50#81#36#83#36#133#154#52#76#75+
        #129#45#93#77#44#83#149#157#71#95#225;
        keyval  = 1234567890;

and the Text File used by COPYINC -

p:\prog\registed.inc
This Program is registered to 
ChkStr     : String =
CodeChkStr : String =
1234567890


The Text File must always consist of five lines that are
 1.  The name of the include File to be created.
 2.  The plain Text.
 3.  The name of the plain Text Constant along With its syntax.
 4.  The name and syntax of the coded Text Constant.
 5.  A key value.  Any number in the LongInt range is valid.


}

Uses
  endecode;  { my encryption Unit }

Const
  hash   = '#';
Var
  f      : Text;
  params : Text;
  keyval : LongInt;
  notice,
  fname,
  CodeStr,
  CodeVar,
  PlainVar: String;
  x      : Word;

begin
  assign(params,ParamStr(1));
  reset(params);
  readln(params,fname);
  readln(params,notice);
  readln(params,PlainVar);
  readln(params,CodeVar);
  readln(params,keyval);
  CodeStr := EncryptStr(keyval,notice);
  notice := '  '+ PlainVar + #39 + notice + #39#59;
  assign(f,fname);
  reWrite(f);
  Writeln(f,'Const');
  Writeln(f,notice);
  Writeln(f,'  ',CodeVar);
  Write(f,'  ');
  For x := 1 to length(CodeStr) do begin
    if x mod 20 = 0 then begin
      Writeln(f,'+');
      Write(f,'  ');
    end;
    Write(f,'#',ord(CodeStr[x]));
  end;
  Writeln(f,';');
  Writeln(f,'  keyval  = ',keyval,#59);
  Writeln(f);
  close(f);
end.

