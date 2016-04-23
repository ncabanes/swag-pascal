{
>Well, I have a procedure to return the VGA palette registers in BYTE
>vars called like

>GetColor(Color,Red,Green,Blue:BYTE);

This will not return anything as they will be removed from the Stack.  You
can pass like this, but you can no receive.  You must use Var R,G,B:Byte;

>I want to do thgis, but in assembler:

>││   PORT[$3C8] := Color;
>││   Red        := PORT[$3C9];
>││   Green      := PORT[$3C9];
>││   Blue       := PORT[$3C9];

>but in assembler....argh, any ideas?
}

Procedure VGAReadDAC(Reg:Byte; Var R,G,B:Byte); Assembler;
ASM
  MOV   DX,3C7h                     {; |Send Starting DAC Register    }
  MOV   AL,[Reg]                    {; |                              }
  OUT   DX,AL                       {;/                               }
  INC   DX                          {; |DX:=DAC Data Address          }
  INC   DX                          {;/                               }
  IN    AL,DX                       {; |Read Red Byte                 }
  LES   DI,[R]                      {; |                              }
  MOV   [ES:DI],AL                  {;/                               }
  IN    AL,DX                       {; |Read Green Byte               }
  LES   DI,[G]                      {; |                              }
  MOV   [ES:DI],AL                  {;/                               }
  IN    AL,DX                       {; |Read Blue Byte                }
  LES   DI,[B]                      {; |                              }
  MOV   [ES:DI],AL                  {;/                               }
End;

