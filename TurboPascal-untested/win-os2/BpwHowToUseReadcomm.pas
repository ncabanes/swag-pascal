(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0075.PAS
  Description: BPW: how to use ReadComm
  Author: TIMUR KAZIMIROV
  Date: 09-04-95  10:56
*)

{
 CB> I'm trying to write a simple terminal for Windows with Borland Pascal
7.0. CB> But I don't get it to work. Does someone have a small example/source?
 CB> I know how to send chars to the serial port, that's not the problem. But
 CB> how to display the modem receiving queue? I guess I'll have to use
 CB> ReadComm.. but how?

 CB> Here's how to send characters:

 CB> uses
 CB>   WinProcs, WinTypes, WinCrt;
 CB> var
 CB>   cid: Integer;
 CB>   ch: Char;
 CB> begin
 CB>   cid:=OpenComm('COM2:',1024,1024);
 CB>   if cid>=0 then
 CB>   begin
 CB>     repeat
 CB>       if keypressed then
 CB>        begin
 CB>          Ch:=Readkey;
 CB>          TransmitCommChar(cid,ch);
 CB>        end;

 CB>        { readComm ??? }

 CB>      until ch=#27;
 CB>      CloseComm(cid);
 CB>   end;
 CB> end.


 CB> Cornelis

These are samples from Borland's ObjectVision that demonstrate work with COM
ports under Windows.

=== Cut ===
function Dial(Comport, Dialtype, Number:PChar): integer; export;
var
  P, Config, Num: PChar;
  Struc: string;
  i: integer;
begin
  Struc := #0;
  GetMem(Config, 20);
  GetMem(P, 255);
  Strcopy(@Struc[1], Number);
  Struc[0] := Char(StrLen(Number));
  Struc := Struc+#0;
  { Strip Routine }
  i := 1;
  while i <= length(Struc) do
  begin
    if (((Struc[i] < #48) or (Struc[i] > #57)) and ((Struc[i] <> ','))) then
    begin
      Delete(Struc, i, 1);
      Dec(i);
    end;
    i := i+1;
  end;
  StrCopy(Config, Comport);
  Config := StrCat(Config, ':12,n,8,1');
  StrLCopy(P, Dialtype, 20);
  P := StrCat(P, @Struc[1]);
  P := StrCat(P, #13#10);
  BuildCommDCB(Config, DCB);
  if CID <= 0 then
  begin
    Cid := OpenComm(Comport, 1024, 1024);
    if not(CID<0) then
    begin
      DCB.ID := CID;
      SetCommState(DCB);
      if WriteComm(CID, p, StrLen(P)) <= 0 then
      begin
        MessageBox(getfocus, 'Dial Error', 'Error', Mb_Ok);
        Dial := 1; {return error}
      end
      else
        Dial := 0; {return no error}
    end;
  end;
  FreeMem(P, 255);
  FreeMem(Config, 20);
end;

function Hangup : bool; export;
begin
  if not(CID < 0) then
  begin
    WriteComm(CID, 'ATH'#13#10, 5);
    If CloseComm(Cid) < 0 then
    begin
      MessageBox(GetFocus, 'Hangup Error', 'Error', Mb_Ok);
      Hangup := bool(0);
    end
    else
    begin
      Cid := 0;
      Hangup := bool(1);
    end;
  end;
end;

