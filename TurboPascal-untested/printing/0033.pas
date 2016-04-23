{$I-}

unit Printout;

{ This unit replaces the Printer unit for output via the write(lst).  Error
  checking is done and a message is printed asking for operator intervention.
  Printing can be terminated by pressing the Escape key.  A flag, Esc_Lst is
  set true if Escape is pressed, and can be used by the program to test for
  that condition.  The program must reset Esc_Lst to false (Esc_Lst := false)
  before trying to print anything else, or the write command will be ignored.

  Richard F. Griffin,  Omaha, NE                          14 Jan 1988
  CIS 75206.231
                                                                            }

interface

uses Crt, Dos;

var
  Esc_Lst : boolean;
  Lst: Text;

implementation

var
   Inch, Fnch : char;
   SecNum : boolean;
   KeyNum : integer;

function GetKey : boolean;
begin
   Esc_Lst := false;
   if KeyPressed then begin
      GetKey := true;
      Inch := ReadKey;
      KeyNum := ord(Inch);
      Secnum := KeyNum = 0;
      if Secnum then
      begin
         Fnch := ReadKey;
         Keynum := ord(Fnch);
      end
      else if ord(Inch) <= 27 then Secnum := true else Secnum := false;
   end
   else begin
      Getkey := false;
      secnum := false;
   end;
end;

procedure Lst_Err;
var
  AsczStr : string[84];
begin
   gotoxy(2,14);
   AsczStr := concat (#7,'Please Check Printer! ',
                     ' Use [ESC] to Exit, ',
                     'Any Other Key to Continue.');
   write(AsczStr);
   repeat until GetKey;
   if (Secnum) and (Keynum = 27) then Esc_Lst := true;
   gotoxy(2,14);
   write('':length(AsczStr));
end;

procedure WriteLst (TheStr : char);
Label Skip;
VAR
  rgstr : Registers;
  goodio : boolean;
  i : integer;
begin
   goodio := false;
   i := 0;
   repeat
      If Esc_Lst then goto Skip;
      with rgstr do
      begin
         dx := $0000;
         ax := $0200;
         intr($17,rgstr);
         while (ax and $8000) = 0 do
         begin
            dx := $0000;
            ax := $0200;
            intr($17,rgstr);
            i := i + 1;
            if i = 20000 then
            begin
               Lst_Err;
               If Esc_Lst then goto Skip;
               i := 0;
            end;
            if GetKey then
               if (Secnum) and (Keynum = 27) then Esc_Lst := true;
            If Esc_Lst then goto Skip;
         end;
         dx := $0000;
         ax := ord(TheStr);
         intr($17,rgstr);
         if (ax and $2900) <> 0 then Lst_Err
             else goodio := true;
         If Esc_Lst then goto Skip;
         if GetKey then
            if (Secnum) and (Keynum = 27) then Esc_Lst := true;
      end;
   until goodio or Esc_Lst;
Skip:
end;

{$F+}

function LstInOut(var F : TextRec) : integer;
var i : word;
begin
   with F do
   begin
      i := 0;
      while i < BufPos do
      begin
         WriteLst(BufPtr^[i]);
         inc(i);
      end;
      BufPos := 0;
   end;
   LstInOut := 0;
end;

function LstClose(var F : TextRec) : integer;
var i : word;
begin
   with F do
   begin
      i := 0;
      while i < BufPos do
      begin
         WriteLst(BufPtr^[i]);
         inc(i);
      end;
      WriteLst(#10);
      WriteLst(#13);
      BufPos := 0;
   end;
   LstClose := 0;
end;


function LstOpen(var F : TextRec) : integer;
begin
   with F do
   begin
      Mode := fmOutPut;
      InOutFunc := @LstInOut;
      FlushFunc := @LstInOut;
      CloseFunc := @LstClose;
      BufPos := 0;
      LstOpen := 0;
   end;
   Esc_Lst := false;
end;

{$F-}

begin
   with TextRec(Lst) do
   begin
      Handle := $FFFF;
      Mode := fmClosed;
      BufSize := Sizeof(Buffer);
      BufPtr := @Buffer;
      OpenFunc := @LstOpen;
      Name[0] := #0;
      Rewrite(Lst);
   end;
end.
