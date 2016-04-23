{ ----------------------------------- 1 -------------------------------- }
{
> Does anyone know of an easy way to remember the current screen and
> then put back when a Program is finished?  What I mean is before the
> Program clears the screen or Writes to it or whatever, to store the
> current screen so that it can be restored to how it was before a Program
> is run?

 Well you could try directly reading from memory and saving it into some kind
of buffer like this...
}

Var Buffer : Array[1..4000] of Byte;

Procedure Save_Screen;
begin
  Move(Mem[$B800:0000],Buffer,4000);
end;

Procedure Restore_Screen;
begin
  Move(Buffer,Mem[$B800:0000],4000);
end;

{
You must save the screen in a 4K Array and then put it back when
the Program is done.
}



{ ----------------------------------- 2 -------------------------------- }
Type
   AScreen = Array[1..4000] of Byte;
Var
   P : ^AScreen;    {Pointer to the Array}
   Scr : AScreen;

Procedure SaveScreen;
begin
  P := Ptr($B800,$0); {Point to video memory}
  Move(P^,Scr,4000);  {Move the screen into the Array}
end;  {Run this proc at the beginning of the Program}

Procedure RestoreScreen;
begin
  Move(Scr,MEm[$B800 : 0], 4000); {Move the saved screen to video mem}
end; {Call this at the end of your Program}

{
This should do the job of saving the original screen and then restoring it when
your Program is done
}
