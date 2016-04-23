Program MouseInt;
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██ Mouse interrupt subroutine handling  ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██     (C)1997. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}
  Uses Crt;

  Var ConditionMask : word; {  bits:   F-5   4   3   2   1   0
                            unused -----|    |   |   |   |   |
     call if right button released ----------|   |   |   |   |
      call if right button pressed --------------|   |   |   |
      call if left button released ------------------|   |   |
       call if left button pressed ----------------------|   |
               call if mouse moves --------------------------|

     Note: with this mask you define which action will cause your subroutine
           to execute. For example mask 0000000000001010 defines that
           subroutine will be executed every time the left or right mouse
           button is released. }
      ButtonState   : word; { 0 - none, 1 - left, 2 - right, 3 - both }
      CursorColumn  : word;
      CursorRow     : word;
      HorMickeyCnt  : word;
      VertMickeyCnt : word;
      OldES, OldDX  : word;
      BothButtons   : Boolean;

  Procedure DoSomething; Far;
    Begin
        Asm
          MOV  AX,0002H     { Hide cursor }
          INT  33H
        End;
      ClrScr;
      Write ('Press both mouse buttons to exit...');
      GotoXY (20,12);
      Write ('Buttons: ');
        Case ButtonState and $0003 of
          0 : Write ('None');
          1 : Write ('Left');
          2 : Write ('Right');
          3 : BothButtons:=True
        End;
      GotoXY (20,14);
      Write ('X: ',CursorColumn:4,'     Y: ',CursorRow:4);
        Asm
          MOV  AX,0001H     { Show cursor }
          INT  33H
        End
    End;

  Procedure MouseHandler; Far; Assembler;
    Asm
      PUSH DS
      PUSH AX
      MOV  AX,Seg @Data
      MOV  DS,AX
      POP  AX
      MOV  ConditionMask,AX
      MOV  ButtonState,BX
      MOV  CursorColumn,CX
      MOV  CursorRow,DX
      MOV  HorMickeyCnt,SI
      MOV  VertMickeyCnt,DI
      CALL DoSomething
      POP  DS
    End;

  Procedure Init;
    Var Status : word;
    Begin
      BothButtons:=False;
        Asm
          MOV  AX,0000H
          INT  33H
          MOV  Status,AX
        End;
      If Status=$0000 then
        Begin
          Writeln ('Mouse driver not installed!');
          Halt
        End;
        Asm
          MOV  AX,0014H
          MOV  CX,00011111B   { All actions. }
          MOV  DX,Seg MouseHandler
          MOV  ES,DX
          MOV  DX,Offset MouseHandler
          INT  33H
          MOV  OldES,ES
          MOV  OldDX,DX
          MOV  AX,0001H
          INT  33H            { Get previous subroutine }
        End;
      ClrScr;
      Write ('Your mouse is waiting...')
    End;

  Procedure Done;
    Begin
      Asm
        MOV  AX,0002H       { Hide cursor }
        INT  33H
        MOV  AX,0014H
        MOV  CX,00011111B
        MOV  ES,OldES
        MOV  DX,OldDX
        INT  33H           { Return previous subroutine }
      End;
      ClrScr
    End;

    Begin
      Init;
        Repeat
        Until BothButtons;
      Done
    End.