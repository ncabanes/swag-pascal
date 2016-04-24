(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0072.PAS
  Description: VIDEO MODE
  Author: SWAG SUPPORT TEAM
  Date: 11-26-93  17:48
*)

{
How can I save and restore the text screen mode (e.g. 132*28 characters)
when using BGI calls in a Turbo Pascal program ?
Unfortunately I always have 80*25 after program exit.
}

function get_video_mode : byte;
{ Returns the current video mode (from interrupt $10,$f).
  Byte [$40:$49] also contains this information, but might not always
  have the correct value.
}
 
var
  check_b : byte; {video mode byte : absolute $40:$49}
 
begin {get_video_mode}
  asm
    mov ah, 0fh
    int 10h
    mov check_b, al
  end;
  if check_b > 127
    then get_video_mode:=check_b-128  {last mode change was done without
                                       screen clearing, mode is given by the
                                       low 7 bits}
    else get_video_mode:=check_b;
end; {get_video_mode}
 
 
procedure set_video_mode(m : byte);
{ Sets the given video mode (via interrupt $10,0).
  If high bit is on screen is not cleared (works only for text modes?).
}
 
begin {set_video_mode}
  asm
    mov ah, 00h
    mov al, m
    int 10h
  end;
end; {set_video_mode}

