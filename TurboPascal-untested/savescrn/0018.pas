  {$B-,F-,I-,R-,S-}
  {$M 2048,2048,2048}
  Program CapText;
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██     Resident text screen capture     ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██     (C)1992. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}
    Uses Dos;
    Var OldKeyboard        : procedure;
        OldTimeClick       : procedure;
        OldIdle            : procedure;

    Procedure Keyboard; Interrupt; Forward;    {<                        }
    Procedure TimeClick; Interrupt; Forward;   {< New interrapt routines }
    Procedure Idle; Interrupt; Forward;        {<                        }

    Var FileName           : string;
        InDos              : ^Boolean;
        PSP                : word;
        Signature          : string [10];
        PoV                : byte;
        Call               : byte;
        I                  : byte;
        X1, X2, Y1, Y2     : byte;
        Ctrl, Shift, Alt   : Boolean;
        PasStack           : pointer;
        OldStack           : pointer;

    Procedure GetStack;
    { Gets current SP and SS values }
      Inline ($89/$26/>PasStack/$8C/$16/>PasStack+2);

    Procedure ToPasStack;
    { Changes current SP and SS values, to Pascal code ones }
      Inline ($89/$26/>OldStack/$8C/$16/>OldStack+2/
              $8B/$26/>PasStack/$8E/$16/>PasSTack+2/$FB);

    Procedure ToOldStack;
    { Changes current SP and SS values, to original ones }
      Inline ($8B/$26/>OldStack/$8E/$16/>OldStack+2);

    Function PasStackFree : Boolean;
    { Checks if Pascal stack is free }
      Inline ($8C/$D0/$2B/$06/>PasStack+2/$0A/$C4);

    Procedure PushF;
    { PUSHF assembler command must be executed before old interrupt   }
    { procedure call. This is because IRET pops flags, and RET don't. }
      Inline ($9C);

    Function IntVec (IntNo:byte) : pointer;
    { Returns pointer to requested interrupt routine }
      Var P : pointer;
        Begin
          GetIntVec (IntNo,P); IntVec:=P
        End;

    Procedure Swp (Var X,Y:byte);
    { Swaps two variables }
      Var Temp : byte;
        Begin
          Temp:=X;
          X:=Y;
          Y:=Temp
        End;

    Procedure SaveScreen;
    { Procedure for screen content saving to file }
      Function VideoAdr : word;
      { Address of video segment }
        Begin
          If Mem [$0000:$0449] = 7
            then VideoAdr:=$B000
            else VideoAdr:=$B800
        End;
      Var F    : text;
          St   : string [80];
          I, J : integer;
        Begin
          Assign (F,FileName);
          Append (F);
          For I:=Y1 to Y2 do
            Begin
              St:='';
              For J:=X1 to X2 do St:=St+Chr (Mem [VideoAdr:((I-1)*80+J-1)*2]);
              Writeln (F,St)
            End;
          Close (F)
        End;

    Procedure UnInstall;
    { Uninstalls program, if it is possible, i.e. if hooked vectors are not }
    { changed after installation. Beep if successfull.                      }
      Type MCB    = record
                      Tok      : byte;
                      PID      : word;
                      Siz      : word
                    End;
           MCBPtr = ^MCB;
           WrdPtr = ^word;
      Var Blk : MCBPtr;
          Adr : WrdPtr;
          R   : Registers;
        Begin
          If (IntVec ($08)=@TimeClick) and (IntVec ($09)=@Keyboard)
             and (IntVec ($28)=@Idle) and (IntVec (PoV)=@Signature) then
            Begin
              SetIntVec ($08,@OldTimeClick);
              SetIntVec ($09,@OldKeyboard);
              SetIntVec ($28,@OldIdle);
              SetIntVec (PoV,Nil);
              R.AH:=$52;
              MsDos (R);
              Adr:=Ptr (R.ES,R.BX-2);
              Blk:=Ptr (Adr^,0);
                Repeat
                  If (Blk^.PID=PSP) then
                    Begin
                      R.AH:=$49;
                      R.ES:=Seg (Blk^)+1;
                      MsDos (R)
                    End;
                  If (Blk^.Tok=$4D) then Blk:=Ptr (Blk^.Siz+Seg (Blk^)+1,0)
                                    else Blk:=Nil
                Until Blk=Nil;
              Write (#7);
            End
        End;

    Procedure Action;
      Begin
          Case Call of
            22 : Uninstall;
            38 : SaveScreen
          End;
        Call:=0
      End;

    Procedure Keyboard;
    { New Keyboard interrupt routine }
      Begin
          Case Port [$60] of
            29     : Ctrl:=True;
            157    : Ctrl:=False;
            42     : Shift:=True;
            170    : Shift:=False;
            56     : Alt:=True;
            184    : Alt:=False;
            22, 38 : If Shift and Ctrl and Alt and (Call=0)
                       then Call:=Port [$60]
          End;
        PushF;
        OldKeyboard
      End;

    Procedure TimeClick;
    { New timer interrupt routine }
      Begin
        PushF;
        OldTimeClick;
        If (Call<>0) and not (InDos^) and PasStackFree then
          Begin
            ToPasStack;
            Action;
            ToOldStack
          End
      End;

    Procedure Idle;
    { New DOS Idle interrupt routine }
      Begin
        PushF;
        OldIdle;
        If (Call<>0) and PasStackFree then
          Begin
            ToPasStack;
            Action;
            ToOldStack
          End
      End;

    Var R : Registers;
        F : Text;
      Begin
        Writeln;
        Writeln ('Text Capture  ver 1.0');
        Writeln ('Dlabac Bros Software  (C) 1992');
        Writeln ('Activation Ctrl-Alt-Shift L');
        Writeln ('Deactivation Ctrl-Alt-Shift U');
        Writeln;
        Signature:='TextCap1.0';
        PoV:=$60;
        While (PoV<$68) and (string (IntVec (PoV)^)<>Signature) do Inc (PoV);
        If (PoV<>$68) then
          Begin
            Writeln ('TextCap already installed.');
            Halt (1)
          End;
        PoV:=$60;
        While (PoV<$68) and (IntVec (PoV)<>Nil) do Inc (PoV);
        If PoV=$68 then
          Begin
            Writeln ('Instalation unsuccessful - no free vector : 60H-67H');
            Halt (2)
          End;
        Repeat
          Write ('Define window coordinates (X1 Y1 X2 Y2) : ');
          Readln (X1,Y1,X2,Y2);
          If X1>X2 then Swp (X1,X2);
          If Y1>Y2 then Swp (Y1,Y2)
        Until (X1>=1) and (X2<=80) and (Y1>=1) and (Y2<=25);
        Write ('File name : ');
        Readln (FileName);
        Assign (F,FileName);
        Rewrite (F);
        Close (F);
        R.AH:=$34;
        MsDos (R);
        InDos:=Ptr (R.ES,R.BX);
        R.AH:=$62;
        MsDos (R);
        PSP:=R.BX;
        Call:=0;
        Ctrl:=False;
        Shift:=False;
        Alt:=False;
        SwapVectors;
        GetIntVec ($08,@OldTimeClick);
        GetIntVec ($09,@OldKeyboard);
        GetIntVec ($28,@OldIdle);
        SetIntVec ($08,@TimeClick);
        SetIntVec ($09,@Keyboard);
        SetIntVec ($28,@Idle);
        SetIntVec (Pov,@Signature);
        GetStack;
        Keep (0)
      End.