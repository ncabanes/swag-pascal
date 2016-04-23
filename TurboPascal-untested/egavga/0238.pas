{
From: doylep@ecf.toronto.edu (DOYLE  PATRICK)

  I'm having some trouble with a VESA SVGA interface I'm writing.
  As if you had nothing better to do :), I have included my source below.
It is supposed to make use if the VESA save/restore state function of
int $10, function $4F04.  The idea is that I have written one "layer" of
procedures which are simple BIOS interfaces, and they begin with "B".
Then there is the more advanced layer, which doesn't.  Most of the functions
work OK, but this one I can't figure out.  If you can see the problem, great.
If you want more details, mail me at doylep@ecf.utoronto.ca.

  Thanks for any help.  Here's the source:
}

type
    SaveWhatEnumType = (Hardware, BIOS,  DAC,   SVGA,
                        Res4,     Res5,  Res6,  Res7,
                        Res8,     Res9,  Res10, Res11,
                        Res12,    Res13, Res14, Res15 );
    SaveWhatType = set of SaveWhatEnumType;
    StateType = record
                      SaveWhat : SaveWhatType;
                      MemSize  : word;
                      SavePtr  : pointer;
                end;
 
const
     SaveAll = [Hardware..SVGA];
 

var
   VESAError       : byte;
   ModeSupportList : array [0..1] of set of byte;


procedure BState (DoWhat  : byte;
                SaveWhat  : word;
            var    State {: word }  ); assembler; 
 asm
    mov AX, $4F04
    mov DL, [DoWhat]
    mov CX, [SaveWhat]
    int $10
    cmp [DoWhat], $00
    jne @NeverMind
    mov word ptr State, BX
   @NeverMind:
 end;
 
procedure SaveState (SaveWhat : SaveWhatType; var State : StateType);
 begin
      BState (0, word (SaveWhat), State.MemSize);
      if VESAError <> 0 then
         exit;
      State.SaveWhat := SaveWhat;
      with State do
       begin
            if MemSize <= MaxAvail then
             begin
                  getmem (SavePtr, MemSize);
                  BState (1, word (SaveWhat), SavePtr^);
             end
            else
                VESAError := 3;
       end;
 end;
 
procedure SetState  (State : StateType);
 begin
      with State do
           BState (2, word (SaveWhat), SavePtr^);
 end;
