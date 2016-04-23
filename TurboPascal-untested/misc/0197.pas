Program GifCommR;
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██         GIF Comments Remover         ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██    (C) 1997. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}
  Uses Crt;

  Var I, Pos    : word;
      B         : byte;
      NumCol    : word;
      St        : string;
      Terminate : Boolean;
      Src, Dest : file;
      Buff      : array [1..10000] of byte;

    Begin
      ClrScr;
      Writeln ('GIFCommR - Removes comments from GIF files');
      Writeln ('Copyrights (C) Aleksandar Dlabac, 1997.');
      Writeln;
      If ParamCount<>2 then
        Begin
          Writeln ('  USAGE:  GIFKom  In_file  Out_file');
          Halt;
        End;
      Assign (Src,ParamStr (1));
      Assign (Dest,ParamStr (2));
{$I-}
      Reset (Src,1);
{$I+}
      If IOResult<>0 then
        Begin
          Writeln ('Error reading file ',ParamStr (1));
          Halt;
        End;
      St [0]:=#4;
      BlockRead (Src,St [1],4);
      If St<>'GIF8' then
        Begin
          Writeln ('Invalid GIF header.'#7);
          Halt
        End;
      Seek (Src,10);
      BlockRead (Src,B,1);
      If B<$80 then
        Begin
          Writeln ('Onlu for global palette.'#7);
          Halt
        End;
      NumCol:=1 shl (B and 7+1); { Number of colors in palette }
{$I-}
      Rewrite (Dest,1);
{$I+}
      If IOResult<>0 then
        Begin
          Writeln ('Error opening file ',ParamStr (2));
          Halt;
        End;
      Seek (Src,0);
      BlockRead (Src,Buff [1],13+NumCol*3);   { Save header and palette }
      BlockWrite (Dest,Buff [1],13+NumCol*3); { in new file.            }
      Terminate:=False;
        Repeat
          BlockRead (Src,B,1);
          If not (B in [$21,$2C,$3B]) then    { Known block separators }
            Begin
              Close (Dest);
              Erase (Dest);
              Writeln ('Illegal separator.'#7);
              Halt
            End;
            Case B of
              $21 : Begin                     { Extension block }
                      BlockRead (Src,B,1);
                      If B=$FE then           { Is it Comment? }
                        Begin
                          Buff [1]:=$21;
                          Buff [2]:=$FE;
                          Pos:=3;
                          St:='';
                            Repeat
                              BlockRead (Src,B,1);
                              Buff [Pos]:=B;
                              Inc (Pos);
                              If B>0 then
                                Begin
                                  BlockRead (Src,Buff [Pos],B);
                                  If Length (St)<255 then
                                    For I:=Pos to Pos+B-1 do
                                      St:=St+Chr (Buff [I]);
                                  Inc (Pos,B)
                                End
                            Until B=0;
                          I:=1;
{ While loop below converts 0Dh or 0Ah characters into 0Dh 0Ah pair. GWS, for
  example uses only 0Dh. Program works the same without this loop, but
  comment text on screen could be scrambled. }
                            While I<=Length (St) do
                              Begin
                                While (I<=Length (St)) and not (St [I] in [#$0D,#$0A]) do
                                  Inc (I);
                                If I<=Length (St) then
                                  If I=Length (St) then
                                    If St [I]=#$0D then
                                      St:=St+#$0A
                                                   else
                                      St:=St+#$0D
                                                   else
                                    Begin
                                      If not ((St [I]=#$0D) and (St [I+1]=#$0A)) and
                                         not ((St [I]=#$0A) and (St [I+1]=#$0D)) then
                                        St:=Copy (St,1,I-1)+#$0D#$0A+Copy (St,I+1,Length (St)-I);
                                      Inc (I)
                                    End;
                                Inc (I)
                            End;
                          ClrScr;
                          Writeln ('Comment:');
                          Writeln ('---------');
                          Writeln (St);
                          Writeln ('---------');
                          Write ('Remove (Y/N): ');
                            Repeat
                              B:=Ord (UpCase (ReadKey))
                            Until B in [27,Ord ('Y'),Ord ('N')];
                          Writeln (Chr (B));
                          If B=27 then
                            Begin
                              Close (Dest);
                              Erase (Dest);
                              Halt
                            End;
                          If B=Ord ('N') then
                            BlockWrite (Dest,Buff [1],Pos-1)
                        End
                               else
                        Begin                 { Block is not comment }
                          Buff [1]:=$21;
                          Buff [2]:=B;
                          BlockWrite (Dest,Buff [1],2);
                            Repeat
                              BlockRead (Src,B,1);
                              Buff [1]:=B;
                              If B>0 then
                                BlockRead (Src,Buff [2],B);
                              BlockWrite (Dest,Buff [1],B+1)
                            Until B=0
                        End
                    End;
              $2C : Begin                     { Graphics }
                      Buff [1]:=$2C;
                      BlockRead (Src,Buff [2],10);
                      BlockWrite (Dest,Buff [1],11);
                        Repeat
                          BlockRead (Src,B,1);
                          BlockWrite (Dest,B,1);
                          If B>0 then
                            Begin
                              BlockRead (Src,Buff [1],B);
                              BlockWrite (Dest,Buff [1],B)
                            End
                        Until B=0
                    End;
              $3B  : Begin                    { GIF Terminator }
                       BlockWrite (Dest,B,1);
                       Terminate:=True
                     End
            End
        Until Eof (Src) or Terminate;
      Close (Src);
      Close (Dest)
    End.