{MR> How can I change say char 255 (A blank) into anything I want?

I don't know exactly how to do it, but here's a little program that'll
help you get started with this.}


PROGRAM CHANGE_CHARACTER_SET;
USES CRT;

TYPE
  CharSet = Array[0..255] of Array[1..8] of Byte;
            {255 characters} {8 bytes per character  }
            {of which each } {each bit in each byte  }
            {uses 8 bytes  } {specifies if something }
                             {must be outputted to   }
                             {screen, eg. a 255 is   }
                             {********, a dot in each}
                             {position, a 253 is     }
                             {****** *, a dot in each}
                             {position, except the   }
                             {second last.           }
                       


VAR
  It  : CharSet ABSOLUTE $C396:$0; {set up an array of the character}
                                   {set, $C396:$0, being the position}
                                   {in memory for this}
  It2 : CharSet;  {set up a second array of the character set so that}
                  {you can restore them on exiting of your program}
  LP, Lp2, Lp3 : BYTE;   {Some variables for looping}


BEGIN
CLRSCR;
IT2:=IT;  {Store the set into a backup array}

{This is where you would do your character manipulation}
{I've tried it out, by changing the memory, but it doesn't}
{seem to work, I think you have to run it on an interrupt}
{bases, ie. Play around with your interrupt vectors, if you}
{manage to figure it out, please tell me how you did it}
{The programming that follows is just a simple example to}
{show you how the character set information is stored, what}
{it does, is it outputs on screen what the character looks like}
{kind of like 64*64 instead of 8*8 text mode}


FOR LP3:=0 TO 255 DO                               {This part of the}
  BEGIN                                            {program outputs the}
    FOR LP:=1 TO 8 DO                              {characters onto the}
      BEGIN                                        {screen, eg, a 1 }
        FOR LP2:=7 DOWNTO 0 DO                     {would look something}
          IF (IT[LP3][LP] SHR LP2) AND $1=1 THEN   {like this:}
             MEM[$B800:(LP-1)*160+(7-LP2)*2]:=219  {  ***   Not exactly,}
                                            ELSE   { * **   But close}
             MEM[$B800:(LP-1)*160+(7-LP2)*2]:=0;   {   **   enough.}
        WRITELN;                                   {   **   }
      END;                                         {   **   }
    READLN;                                        {   **   }
    CLRSCR;                                        {   **   }
  END;                                             {********}

{Once you're finished with the program, or when people wish to exit, I 
suggest that you reset the character set to the original set, that's why
I made IT2 equal IT, so that you have a backup of the old set, just use 
the following to restore it}

IT:=IT2;
END.