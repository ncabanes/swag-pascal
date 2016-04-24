(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0021.PAS
  Description: Data Encription
  Author: TREVOR CARLSEN
  Date: 11-22-95  13:25
*)


{   AUTHOR:  Trevor J Carlsen  Copyright 1992. All rights reserved.
             PO Box 568
             Port Hedland WA 6721
             Telephone (091) 73-2026

    This program has been written to demonstrate the coding and decoding
    of a file.

    SYNTAX:   codechal password1 password2 infile outfile

    All four parameters are required.
    The passwords are case sensitive.

    Whilst this program was written purely for the purposes of a challenge
    issued in the Oz Pascal echo, it would not be difficult to upgrade it to
    a commercial grade encryption/decryption utility - there several very
    simple changes to enhance the security of the cypher output. As written it
    will only encrypt or decrypt the first 4096 bytes of a file.  If you wish
    to use the code here as a basis for a commercial product, contact the
    author for details.

    Some may scoff at its simplicity; I say; solve the challenge, then you
    will have the right to call it simple.  You have the tools, this source
    code gives the full details of the encrypting/decrypting algorithm used.

}


const
  TextSize  = 4096;

type
  buff_type = array[1..TextSize] of byte;


var
  encrypt   : boolean;
  InFile,
  OutFile   : file;
  c,
  BytesRead : word;
  b         : byte;
  key       : array[1..2] of buff_type;
  FileBuff  : buff_type;
  password  : array[1..2] of string;

procedure Hash(p : pointer; numb : byte; var result: longint);
  { When originally called numb must be equal to sizeof    }
  { whatever p is pointing at.  If that is a string numb   }
  { should be equal to length(the_string) and p should be  }
  { ptr(seg(the_string),ofs(the_string)+1)                 }
  var
    temp,
    w    : longint;
    x    : byte;

  begin
    temp := longint(p^);  RandSeed := temp;
    for x := 0 to (numb - 4) do begin
      w := random(maxint) * random(maxint) * random(maxint);
      temp := ((temp shr random(16)) shl random(16)) +
                w + MemL[seg(p^):ofs(p^)+x];
    end;
    result := result xor temp;
  end;  { Hash }

procedure CreateKey;
  { Creates the "keys" that are used to xor with the data being encrypted }
  { decrypted.                                                            }
  var
    StrPtr    : pointer;
    count,x   : word;
  begin
    FillChar(key,sizeof(key),0);
    for x := 1 to 2 do begin
      StrPtr := ptr(Seg(password[x]),Ofs(password[x])+1);
      Hash(StrPtr,length(password[x]),RandSeed);
      for count := 1 to TextSize do
        key[x,count] := key[x,count] xor random(256);
    end;
  end;

procedure Initialise;
  var st1,st2 : string[18];
  begin
    writeln('CODECHAL - copyright 1992, Trevor Carlsen. All rights
reserved.');    if ParamCount <> 4 then begin
      writeln('This program has been written to demonstrate the coding and
deco      writeln('of a file.');
      writeln;
      writeln('SYNTAX:   codechal password1 password2 infile outfile');
      writeln;
      writeln('All four parameters are required.');
      writeln('The passwords are case sensitive.');
      writeln;
      halt;
    end;
    password[1] := ParamStr(1);
    password[2] := ParamStr(2);
    if (length(password[1]) < 8)  or (length(password[2]) < 8) then begin
      writeln('Passwords must be at least 8 characters...aborting');
      halt;
    end;
    {$I-}
    assign(InFile,Paramstr(3));
    reset(InFile,1);
    assign(OutFile,Paramstr(4));
    rewrite(OutFile,1);
    if IOResult <> 0 then begin
      writeln('I/O error opening files');
      halt;
    end;
    BlockRead(InFile,FileBuff,TextSize,BytesRead);
    if IOResult <> 0 then begin
      writeln('I/O error reading file');
      halt;
    end;
  end;

procedure CodeDeCodeBuffer(var buffer: buff_type; c: word);
  var x: word;
  begin
    for x := 1 to BytesRead do
      buffer[x] := buffer[x] xor key[c,x];
  end;

begin
  Initialise;
  CreateKey;
  writeln('Working...wait');
  for c := 1 to 2 do
    CodeDecodeBuffer(FileBuff,c);
  BlockWrite(OutFile,FileBuff,BytesRead);
  close(InFile);
  close(OutFile);
end.

