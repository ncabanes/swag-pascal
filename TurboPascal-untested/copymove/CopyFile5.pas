(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0005.PAS
  Description: Copy File #5
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{ copy Files With certain extentions to a specific directory (Both
 parameters specified at the command line or in a Text File).. I cannot
 seem to find a command withing TP 6.0 to copy Files.. I have looked
 several times through the manuals but still no luck.. I even asked the
 teacher in Charge and he did not even know! Ok all you Programmers out
 there.. Show your stuff.. If you Really want to be kind, help me out
 on this..I am just starting in TP and this is all new to me!
}

{$R-,I+} {Set range checking off, IOChecking on}
{$M $400, $2000, $10000} {Make sure enough heap space}
{    1k Stack, 8k MinHeap, 64k MaxHeap }
Type
        Buf = Array[0..65527] of Byte;
Var
        FileFrom, FileTo : File;
        Buffer : ^Buf;
        BytesToRead, BytesRead : Word;
        MoreToCopy, IoStatus : Boolean;

begin
        {Determine largest possible buffer useable}
        If MaxAvail < 65528 then
                BytesToRead := MaxAvail
        else
                BytesToRead := 65528;
        Writeln('Program is using ', BytesToRead , ' Bytes of buffer');
        GetMem(Buffer, BytesToRead);    {Grab heap memory For buffer}
        Assign(FileFrom, 'File_1');
        Assign(FileTo, 'File_2');
        Reset(FileFrom, 1);     {Open File With 1Byte Record size}
        ReWrite(FileTo, 1);
        IoStatus := (IoResult = 0);
        MoreToCopy := True;
        While IoStatus and MoreToCopy do begin
        {$I-}
                blockread(FileFrom, Buffer^, BytesToRead, BytesRead);
                blockWrite(FileTo, Buffer^, BytesRead);
        {$I+}
                MoreToCopy := (BytesRead = BytesToRead);
                IoStatus := (IoResult=0);
        end;
        Close(FileTO);
        Close(FileFrom);
        FreeMem(Buffer, BytesToRead); {Release Heap memory}
        If (not IoStatus) then
            Writeln('Error copying File!!!');
end.

