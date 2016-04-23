Unit sCrt;

{

  by Trevor J Carlsen
     PO Box 568
     Port Hedland
     Western Australia 6721
     Phone -
       Voice: 61 91 732026
       Data : 61 91 732569

   This little Unit is intended to replace the Crt Unit in Programs that do
   not require many of that Units Functions.  As a result the resulting .exe
   code is much smaller.

   Released into the public domain 1989

}

Interface

Function KeyPressed: Boolean;
  { Returns True if there is a keystroke waiting in the key buffer           }

Procedure ClrScr;
  { Clears the screen and homes the cursor                                   }

Procedure ClrKey;
  { Flushes the keystroke buffer                                             }

Function KeyWord : Word;
    Inline  ($B4/$00/   {mov  ah,0}
             $CD/$16);  {int  16h}
  { Waits For a keypress and returns a Word containing the scancode and      }
  { ascii code For the KeyPressed                                            }

Function ExtKey(Var k : Char; Var s : Byte): Boolean;
  { Gets next keystroke from the keystroke buffer. if it was an Extended key }
  { (ie. Function key etc.) returns True and k contains the scan code. if a  }
  { normal key then returns False and k contains the Character and s the scan}
  { code                                                                     }

Function ReadKey: Char;
  { Gets next keystroke from the buffer. if Extended key returns #0          }

Function NextKey: Char;
  { Flushes the keystroke buffer and then returns the next key as ReadKey    }

Function PeekKey: Char;
  { Peeks at the next keypress in the buffer without removing it             }

Procedure Delay(s : Word);
  { Machine independent Delay loop For s seconds                             }

Procedure GotoXY(x,y : Byte);
  { Moves the cursor to X, y coordinates                                     }

{ -------------------------------------------------------------------------- }

Implementation

Uses Dos;

Var
  head : Word    Absolute $0040:$001A;
  tail : Word    Absolute $0040:$001C;
  time : LongInt Absolute $0040:$006C;
  regs : Registers;

Function KeyPressed: Boolean;
  begin
    KeyPressed := (tail <> head);
  end;

Procedure ClrScr;                                     { 25 line display only }
 begin
   Inline($B4/$06/$B0/$19/$B7/$07/$B5/$00/$B1/$00/$B6/$19/$B2/$4F/
          $CD/$10/$B4/$02/$B7/$00/$B2/$00/$B6/$00/$CD/$10);
 end;

Procedure ClrKey;
  begin
    head := tail;
  end;


Function ExtKey(Var k : Char; Var s : Byte): Boolean;

  Var
    keycode : Word;
    al      : Byte;
    ah      : Byte;

  begin
    ExtKey    := False;
    Repeat
      keycode := KeyWord;
      al      := lo(keycode);
      ah      := hi(keycode);
      if al = 0 then begin
        ExtKey := True;
        al     := ah;
      end;
  Until al <> 0;
  k := chr(al);
  s := al;
end;    {ExtKey}

Function ReadKey : Char;
  Var
    Key : Byte;
  begin
    Key := lo(KeyWord);
    ReadKey := Char(Key);
  end;

Function NextKey : Char;
  begin
    tail := head;
    NextKey := ReadKey;
  end;

Function PeekKey : Char;
  begin
    PeekKey := Char(Mem[$40:head]);
  end;

Procedure Delay(s : Word);
  Var
    start    : LongInt;
    finished : Boolean;
  begin
    start := time;
    Repeat
      if time < start then    { midnight rollover occurred during the period }
        dec(start,$1800B0);
      finished := (time > (start + s * 18.2));
    Until finished;
  end;

Procedure GotoXY(x,y : Byte);
  begin
    With regs do begin
      ah := $02;
      bh := 0;
      dh := pred(y);
      dl := pred(x);
      intr($10,regs);
    end; { With }
  end;   { GotoXY }

end.
 


