(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0008.PAS
  Description: MAKEDATA.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

{> I need about 10 megs of raw data and am looking For info-pascal archives.
> Do they exist? ...and if so could someone please direct me to where I can
I wish everyone made such easy requests to fulfil. Try the following
Program. With minor changes, it will supply you With almost any amount
of data For which you could ask.
}
Program GenerateData;
Uses
  Crt;
Const
  DataWanted = 3.0E5;
Var
  Data    : File of Byte;
  Count   : LongInt;
  Garbage : Byte;
begin
  Assign(Data, 'Data.1MB');
  ReWrite(Data);
  Count   := 0;
  Garbage := 1;
  For Count := 1 to Round(DataWanted) do
  begin
    Write(Data, garbage); (* smile *)
    GotoXY(1,1);
    Write(Count);
    Inc(Count);
  end;
  Close(Data)
end.

