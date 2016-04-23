{   Following is some code I've thrown together <!>, which has to find a
sequence of 4 Characters in a large buffer - non-Text data.  The buffer
is 4096 Characters, and the sequence(s) I'm searching For could be
anywhere in it, and may be found numerous times. I suspect this code is
pretty inefficient, but I can't think of anything better. (Yep, this is
to work With the ZIP directory at the end of the File...)
   So, I'm looking For a better way to code this process.  I know that
Pos won't work, so this brute-Force is what I came up with.  Anything
better?  Thanks...
}
Const CFHS : String[4] = 'PK'#01#02;  { CENTRAL_File_HEADER_SIGNATURE }
      ECDS : String[4] = 'PK'#05#06; { end_CENTRAL_DIRECtoRY_SIGNATURE }
Var S4     : String[4];
    FOUND  : Boolean;
    QUIT   : Boolean;      { "end" sentinel encountered }
begin
  FETCH_NAME; Assign (F,F1); Reset (F,1); C := 1; HSize := 0;
  FSize := FileSize(F);
  I := FSize-BSize;                   { Compute point to start read }
  Seek (F,I); BlockRead (F,BUFF,BSize,RES); { ZIP central directory }
  S4[0] := #4; C := 0;
  Repeat
    FOUND := False; { search For CENTRAL_File_HEADER_SIGNATURE }
    Repeat
      Inc (C); Move (BUFF[C],S4[1],4); FOUND := S4 = CFHS;
      QUIT := S4 = ECDS;
    Until FOUND or QUIT;
end.