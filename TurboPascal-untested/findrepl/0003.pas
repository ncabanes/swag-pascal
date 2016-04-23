{$A+,B-,D-,E+,F-,I-,L-,N-,O-,R-,S-,V-}
Unit BMSrch;

Interface

Type
  Btable = Array[0..255] of Byte;

Procedure BMMakeTable(Var s; Var t : Btable);
Function BMSearch(Var buff; size : Word; Bt: Btable; Var st): Word;
Function BMSearchUC(Var buff; size : Word; Bt: Btable; Var st): Word;

Implementation

Procedure BMMakeTable(Var s; Var t : Btable);
  { Makes a Boyer-Moore search table. s = the search String t = the table }
  Var
    st  : Btable Absolute s;
    slen: Byte Absolute s;
    x   : Byte;
  begin
    FillChar(t,sizeof(t),slen);
    For x := slen downto 1 do
      if (t[st[x]] = slen) then
        t[st[x]] := slen - x
  end;

Function BMSearch(Var buff; size : Word; Bt: Btable; Var st): Word;
  { Not quite a standard Boyer-Moore algorithm search routine }
  { To use:  pass buff as a dereferenced Pointer to the buffer}
  {          st is the String being searched For              }
  {          size is the size of the buffer                   }
  { If st is not found, returns $ffff                         }
  Var
    buffer : Array[0..65519] of Byte Absolute buff;
    s      : Array[0..255] of Byte Absolute st;
    len    : Byte Absolute st;
    s1     : String Absolute st;
    s2     : String;
    numb,
    x      : Word;
    found  : Boolean;
  begin
    s2[0] := chr(len);       { sets the length to that of the search String }
    found := False;           
    numb := pred(len);
    While (not found) and (numb < (size - len)) do begin
      if buffer[numb] = ord(s1[len]) then { partial match } begin
        if buffer[numb-pred(len)] = ord(s1[1]) then { less partial! } begin
          move(buffer[numb-pred(len)],s2[1],len);
          found := s1 = s2;                   { if = it is a complete match }
          BMSearch := numb - pred(len);       { will stick unless not found }
        end;
        inc(numb);                 { bump by one Char - match is irrelevant }
      end
      else
        inc(numb,Bt[buffer[numb]]);
    end;
    if not found then
      BMSearch := $ffff;
  end;  { BMSearch }

 
Function BMSearchUC(Var buff; size : Word; Bt: Btable; Var st): Word;
  { Not quite a standard Boyer-Moore algorithm search routine }
  { To use:  pass buff as a dereferenced Pointer to the buffer}
  {          st is the String being searched For              }
  {          size is the size of the buffer                   }
  { If st is not found, returns $ffff                         }
  Var
    buffer : Array[0..65519] of Byte Absolute buff;
    chbuff : Array[0..65519] of Char Absolute buff;
    s      : Array[0..255] of Byte Absolute st;
    len    : Byte Absolute st;
    s1     : String Absolute st;
    s2     : String;
    numb,
    x      : Word;
    found  : Boolean;
  begin
    s2[0] := chr(len);       { sets the length to that of the search String }
    found := False;           
    numb := pred(len);
    While (not found) and (numb < (size - len)) do begin
      if UpCase(chbuff[numb]) = s1[len] then { partial match } begin
        if UpCase(chbuff[numb-pred(len)]) = s1[1] then { less partial! } begin
          move(buffer[numb-pred(len)],s2[1],len);
          For x := 1 to length(s2) do
            s2[x] := UpCase(s2[x]);
          found := s1 = s2;                   { if = it is a complete match }
          BMSearchUC := numb - pred(len);     { will stick unless not found }
        end;
        inc(numb);                 { bump by one Char - match is irrelevant }
      end
      else
        inc(numb,Bt[ord(UpCase(chbuff[numb]))]);
    end;
    if not found then
      BMSearchUC := $ffff;
  end;  { BMSearchUC }

end.
