(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0022.PAS
  Description: Trap PAUSE Key #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{GE> Does anyone know how to disable the pause key?

 Here's one way, done in Assembly, With example Turbo Pascal code ...
}
(*******************************************************************)
 Program TestTrapPause;             { demo disabling the Pause key  }
 Uses   Crt,                        { import CheakBreak, KeyPressed }
        Dos;                        { import GetIntVec, SetIntVec   }
 Var    old09Vector : Pointer;      { to hold original ISR          }
        loopc,                      { a loop count                  }
        ppress      : Word;         { counts Pause key presses      }
{-------------------------------------------------------------------}
{ the following Procedures|Functions mask & count Pause keystrokes  }
 Procedure InitTrapPause( oldVector : Pointer );    EXTERNAL;
 Procedure TrapPause; Interrupt;                    EXTERNAL;
 Function  PausePresses : Word;                     EXTERNAL;
 Procedure ForgetPaUses;                            EXTERNAL;
 {$L NOPAUSE.OBJ}                   { Assembly, Near calls          }
{-------------------------------------------------------------------}
 begin
    ClrScr;
    CheckBreak := False;            { don't allow Ctrl-Break        }

    GetIntVec( 9, old09Vector );    { get current keyboard ISR      }
    InitTrapPause( old09Vector );   { pass vector to TrapPause      }
    SetIntVec( 9, @TrapPause );     { enable TrapPause ISR          }
    ForgetPaUses;                   { zero the PausePresses counter }

    loopc := 0;                     { initialize                    }
    WriteLn; WriteLn( 'Press the PAUSE key... ');

    Repeat
        WriteLn;
        ppress := PausePresses;     { initial Pause press count     }
        While (ppress = PausePresses) and (not KeyPressed)
        do begin
            inC( loopc ); if (loopc = 65535) then loopc := 0;
            Write( loopc:5, ' you''ve pressed the Pause key ' );
            Write( ppress, ' times',#13 );
        end; {While}
    Until KeyPressed;

    SetIntVec( 9, old09Vector );    { restore Pause & release ISR   }

 end {TestTrapPause}.
(*******************************************************************)

{ The following TP Program will create NOPAUSE.ARC, which contains
 NOPAUSE.OBJ ...

 Program A; Var G:File; Const V:Array [ 1..279 ] of Byte =(
26,8,78,79,80,65,85,83,69,46,79,66,74,0,94,248,0,0,0,43,26,67,140,78,
194,29,1,0,0,12,128,26,0,88,224,230,13,156,48,117,230,148,113,17,100,
74,19,47,150,14,0,0,64,96,200,19,34,69,136,96,146,136,162,13,0,1,2,2,
28,131,4,32,200,196,0,12,140,60,145,114,164,8,21,40,65,170,76,41,50,165,
204,68,6,48,101,22,129,34,133,230,204,41,96,38,54,72,226,36,9,21,42,82,
130,64,201,57,115,34,128,4,72,149,50,45,226,99,34,9,68,4,38,138,10,16,
13,84,28,0,1,38,46,226,102,99,209,17,1,46,70,77,44,123,132,64,218,137,
46,142,25,112,10,64,88,214,33,6,243,200,73,115,6,13,29,16,49,114,228,
144,1,226,136,156,50,103,222,200,201,3,98,138,11,43,124,221,148,65,200,
134,14,167,125,80,200,129,225,81,132,206,1,44,157,92,252,115,1,247,223,
92,0,176,64,152,3,1,250,25,0,72,6,92,132,154,56,44,238,105,218,125,56,
201,0,64,12,1,216,0,90,120,67,248,205,133,119,133,223,94,120,51,249,29,
(96 min left), (H)elp, More? 156,88,20,228,188,197,64,39,134,6,58,43,69,2,38,210,1,26,0);
 begin Assign(G,'NOPAUSE.ARC'); ReWrite(G,Sizeof(V));
 BlockWrite(G,V,1); Close(G); end (*Gbug1.5*).
}

