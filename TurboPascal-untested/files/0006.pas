{$B-,D-,F-,I-,L-,N-,O-,R-,S-,V-}

Unit Filestr;

Interface

Uses Dos;

Function GetFstr(Var f: Text): String;
Procedure OpenFStr(Var f: Text);

Implementation

Var
  FStrBuff     : String;

Function GetFStr(Var f: Text): String;
  begin
    GetFStr     := FStrBuff;
    FStrBuff[0] := #0;
    TextRec(f).BufPos := 0;
  end; { GetFStr }
  
{$F+}
Function FStrOpen(Var f: TextRec):Word;
  { This does nothing except return zero to indicate success }
  begin
    FStrOpen := 0;
  end; { FStrOpen }
  
Function FStrInOut(Var f: TextRec):Word;
  begin
    FStrBuff[0] := chr(F.BufPos);  
    FStrInOut   := 0;
  end; { FStrInOut }  
{$F-}

Procedure OpenFStr(Var f: Text);
  begin
    With TextRec(f) do begin
      mode      := fmClosed;
      BufSize   := Sizeof(buffer);
      OpenFunc  := @FStrOpen;
      InOutFunc := @FStrInOut;
      FlushFunc := @FStrInOut;
      CloseFunc := @FStrOpen;
      BufPos    := 0;
      Bufend    := 0;
      BufPtr    := @FStrBuff[1];
      Name[0]   := #0;
    end; { With }
    FStrBuff[0] := #0;
    reWrite(f);
  end;  { AssignFStr }   


end.  
