(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0001.PAS
  Description: Simple Field Input
  Author: GAYLE DAVIS
  Date: 05-31-93  08:59
*)

uses
  crt;
type
  input_data = record
                 st               : string;  { The string to be input }
                 col,row,                         { position of input }
                 attr,                              { color of input  }
                 flen             : byte;   { maximum length of input }
                 prompt           : string[40];
               end;
const
  NumberOfFields = 3;
  BackSpace  = $08;
  Enter      = $0d;
  Escape     = $1b;
  space      = $20;

var
  InputField : array[1..NumberOfFields] of input_data;
  x          : byte;
  Done       : boolean;
  field      : byte;


Procedure SetInputField(VAR inpRec   : Input_data;
                            S        : STRING;
                            C,R      : Byte;
                            A,L      : Byte;
                            P        : String);

BEGIN
With inpRec DO
     BEGIN
     St  := S;
     Col := C;
     Row := R;
     Attr := A;
     fLen := L;
     Prompt := P;
     END;
END;


procedure GetStr(var inprec: input_data; var f: byte; var finished: boolean);
  var
    spstr  : string; { just a string of spaces }
    x,y,
    oldattr: byte;
    ch     : char;
    chval  : byte absolute ch;
    len    : byte absolute inprec;
  begin
    with inprec do begin
      FillChar(spstr,sizeof(spstr),32); spstr[0] := chr(flen);
      y := row; x := col + length(prompt);
      oldattr := TextAttr; finished := false;
      gotoXY(col,row); write(prompt);
      TextAttr := attr;
      repeat
        gotoXY(x,y); write(st,copy(spstr,1,flen-len)); gotoXY(x+len,y);
        ch := ReadKey;
        case chval of
          0         : ch := ReadKey;
          Enter     : begin
                        inc(f);
                        if f > NumberOfFields then f := 1;
                        TextAttr := oldattr;
                        exit;
                      end;
          BackSpace : if len > 0 then
                        dec(len);
          Escape    : begin  { the escape key is the only way to halt }
                        finished := true;
                        TextAttr := oldattr;
                        exit;
                      end;
          32..255   : if len <> flen then begin
                        inc(len);
                        st[len] := ch;
                      end;
        end; { case }
      until false;  { procedure only exits via exit statements }
    end; { with }
  end; { GetStr }

begin
  Clrscr;
  SetInputField(InputField[1],'',12,10,31,20,'Your Name    : ');
  SetInputField(InputField[2],'',12,11,31,20,'Your Address : ');
  SetInputField(InputField[3],'',12,12,31,20,'City,State   : ');
  field := 1;
  repeat
    GetStr(InputField[field],field,Done);
  until Done;
end.

