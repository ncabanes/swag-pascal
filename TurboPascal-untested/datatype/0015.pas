{
> I'm trying to read a record from a file of byte. One of the variables in
> read is the record is a 4 byte unsigned integer (DWORD). Since the
> filetype doesn't allow me to read a dword at once I have to construct it
> myself.
> Could somebody please tell me how to construct my dword?

Type
  DWORD = record
    case byte of
      0 : (Full : longint);
      1 : (HiWord, LoWord : word);
      2 : (Hw_HiByte, Hw_LoByte, Lw_HiByte, Lw_LoByte : byte);
      3 : (FourBytes : array[0..3] of byte);
    end;

Here is an example:
}

{$A+,B-,D+,E-,F+,G+,I+,L+,N+,O+,P+,Q+,R+,S+,T+,V-,X+,Y+}
{$M 1024,0,655360}
uses
  crt;

Type
  DWord = record
    case byte of
      0 : (Full : longint);
      1 : (HiWord, LoWord : word);
      2 : (Hw_HiByte, Hw_LoByte, Lw_HiByte, Lw_LoByte : byte);
      3 : (FourBytes : array[0..3] of byte);
      4 : (TwoWords : array[0..1] of word);
    end;

var
        F       : file of longint;
  B       : file of byte;
  MyDword : Dword;
  MyLong  : longint;
  MyWord  : word;
  MyByte,
  Index   : byte;

begin
        clrscr;
        assign(F, 'MyLong.dat');
  rewrite(F);
  MyLong := $12345678;
  write(F, MyLong);
  MyLong := 0;
  Close(F);
  assign(B, 'MyLong.dat');
  reset(B);
  Seek(B, 0);  { Go back to first record in file}
  for Index := 0 to 3 do
                read(B, MyDword.Fourbytes[Index]);
  writeln($12345678);
        writeln(MyDword.Full);
  writeln;
  writeln(MyDword.HiWord);
  writeln(MyDword.LoWord);
        writeln;
  writeln(MyDword.Hw_HiByte);
  writeln(MyDword.Hw_LoByte);
  writeln(MyDword.Lw_HiByte);
  writeln(MyDword.Lw_LoByte);
        writeln;
  for Index := 0 to 3 do
          writeln(MyDword.FourBytes[Index]);
  writeln;
  for Index := 0 to 1 do
          writeln(MyDword.TwoWords[Index]);

  Close(B);
  reset(F);
  while keypressed do readkey;
        readkey;
  Seek(F, 0);  { Go back to first record in file}
        read(F, MyDword.Full);
  ClrScr;
  writeln($12345678);
        writeln(MyDword.Full);
  writeln;
  writeln(MyDword.HiWord);
  writeln(MyDword.LoWord);
        writeln;
  writeln(MyDword.Hw_HiByte);
  writeln(MyDword.Hw_LoByte);
  writeln(MyDword.Lw_HiByte);
  writeln(MyDword.Lw_LoByte);
        writeln;
  for Index := 0 to 3 do
          writeln(MyDword.FourBytes[Index]);
  writeln;
  for Index := 0 to 1 do
          writeln(MyDword.TwoWords[Index]);
  close(F);
  while keypressed do readkey;
        readkey;
end.

{
Compiled and Tested with BP 7.x

It will, write a file of Longint, write 12345678 Hex to it, read it as a
file of byte, display most representation of it, then close it and
reopen it as a file of LongInt again read one longint and again display
the representations of it.

PS. There is a pause after the first display (Read as a file of bytes),
any key presents the second display (Read as a file of bytes), and
another pause to allow you to see that it does display the same thing.
Any key then terminates the program.
}