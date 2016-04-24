(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0006.PAS
  Description: LOCKREC.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:52
*)

{
The following Program is a slight modification of one posted by Zach
Linnet.  The problem is it doesn't lock the use of the File and allows
multiple PC's to access the File at the same time.  Also, it seems to
take input from the keyboard when it isn't supposed to and I am unable
to locate why.  How could I improve this to actually lock the File?
What if I just wanted to lock one or two Records?
}

Program Sample_File_Locking_Program;
Uses
  Crt;
Type
  Fi = File of Integer;
Var
  FileName : String;
  f : Fi;
  x, n : Integer;
  Choice : Char;

begin
  {$I-}
  FileName := 'e:\test\test.dat';
  Assign(f,FileName);
  Repeat
    Write('Option [rwq] ? '); choice := ReadKey;
    Writeln(choice);
    Case choice of
      'r' : begin
              Writeln('Attempting to read : ');
              Reset(f);
              While Ioresult <> 0 do
                begin
                  Writeln('Busy waiting...');
                  Reset(f);
                end;
              Write('Reading now...');
              For x := 1 to 1000 do
                Read(f,n);
              Writeln('done!');
              Close(f);
            end;
      'w' : begin
              Writeln('Attempting to Write : ');
              Reset(f);
              if Ioresult = 2 then
                ReWrite(f);
              While Ioresult <> 0 do
                begin
                  Writeln('Busy waiting...');
                  Reset(f);
                end;
              Write('Writing now...');
              For x := 1 to 1000 do
                Write(f,x);
              Writeln('done!');
              Close(f);
            end;
     end; { Case }
  Until Choice = 'q';
  {$I+}
end.

