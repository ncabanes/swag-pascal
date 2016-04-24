(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0001.PAS
  Description: Unix Like time in ASM
  Author: INBAR RAZ
  Date: 05-28-93  13:37
*)

I saw a thread going on here, about the subject.

I just happen to have programmed such a thing, for a certain program. It's not
perfect, in the essence that It will produce good results only from 1970 to
2099, because I didn't feel like starting to investigate which are leap years
and which are not. All the leap years between 1970 and 2099 ARE included,
though.

---------------------------------= cut here =---------------------------------
{ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ }

  { This procedure returns a LongInt UNIX-like timestamp. TimeRec will be  }
  { overwritten by the resulted UNSIGNED DWORD.                            }

  Procedure SecondSince1970(Year, Month, Day, Hour, Minute:Word; Var TimeRec);

  Var       T_Lo,
            T_Hi       : Word;

  Begin
    Asm

      Call @Table

  @Table:

      Pop Si
      Add Si,6            { Point Si to data table }
      Jmp @Compute

      { This table contains the number of days in all months UNTIL this one }

      dw  0               { Within January }
      dw  31              { January }
      dw  59              { February }
      dw  90              { Mars }
      dw  120             { April }
      dw  151             { May }
      dw  181             { June }
      dw  212             { July }
      dw  243             { August }
      dw  273             { September }
      dw  304             { October }
      dw  334             { November }

      { This i a routine to multiply a DWORD by a WORD }
      { Input: DX:AX word to multilpy, CX multiplier }

  @Calc:

      Push Si
      Push Di

      Mov Di,Dx
      Mov Si,Ax

      Dec Cx              { We already have it multiplied by 1 }

  @Addit:

      Add Ax,Si
      Adc Dx,Di

      Loop @Addit

      Pop Di
      Pop Si

      Ret

  @Compute:

      Xor Di,Di           { Variable for leap year }

      { Seconds of round years }

      Mov Bx,Year
      Sub Bx,1970
      Mov Ax,365*24       { Hours per year }
      Mov Cx,60*60        { Seconds per hour }
      Xor Dx,Dx

      Call @Calc          { Multiply dword response by CX }
      Mov Cx,Bx
      Call @Calc

      Push Ax
      Push Dx

      { Seconds of leap years }

      Mov Ax,Year
      Sub Ax,1972         { First leap year after 1972 }
      Mov Bx,4
      Xor Dx,Dx
      Div Bx

      { DX now holds number of days to add becaues of leap years. }
      { If DX is 0, this is a leap year, and we need to take it into
conideration }

      Mov Di,Dx          { If DI is 0, this is a leap year }

      Inc Ax             { We must count 1972 as well }
      Xor Dx,Dx
      Mov Bx,60*60
      Mov Cx,24

      Mul Bx
      Call @Calc

      Mov Cx,Dx
      Mov Bx,Ax

      { Now add what we had before }

      Pop Dx
      Pop Ax

      Add Ax,Bx
      Adc Dx,Cx

      Push Ax
      Push Dx

      { DX:AX holds the number of seconds since 1970 till the beginning of year
}

      { Add days within this year }

      Mov Bx,Month
      Dec Bx
      Shl Bx,1
      Add Bx,Si
      Mov Bx,cs:[Bx]      { Lookup Table, sum of months EXCEPT this one }
      Add Bx,Day          { Add days within this one }
      Dec Bx              { Today hasn't ended yet }

      Mov Ax,60*60
      Mov Cx,24
      Xor Dx,Dx
      Mul Bx
      Call @Calc

      Mov Cx,Dx
      Mov Bx,Ax

      { Now add what we had before - days until beginning of the year }

      Pop Dx
      Pop Ax

      Add Ax,Bx
      Adc Dx,Cx

      { DX:AX now holds the number of secondss since 1970 till beginning of
day. }

      Push Ax
      Push Dx

      { DX:AX holds the number of seconds until the beginning of this day }

      Mov Bx,Hour
      Mov Ax,60*60   { Seconds per hour }
      Xor Dx,Dx
      Mul Bx

      Push Ax
      Push Dx

      Mov Bx,Minute
      Mov Ax,60      { Seconds per minute }
      Xor Dx,Dx
      Mul Bx

      Mov Cx,Dx
      Mov Bx,Ax

      Pop Dx
      Pop Ax

      Add Bx,Ax
      Adc Cx,Dx

      { And add the seconds until beginning of year }

      Pop Dx
      Pop Ax

      Add Ax,Bx
      Adc Dx,Cx

      { DX:AX now holds number of second since 1970 }

      Mov T_Hi,Dx
      Mov T_Lo,Ax

    End;

      Move(Mem[Seg(T_Lo):Ofs(T_Lo)],
           Mem[Seg(TimeRec):Ofs(TimeRec)],2);

      Move(Mem[Seg(T_Hi):Ofs(T_Hi)],
           Mem[Seg(TimeRec):Ofs(TimeRec)+2],2);

  End;

{ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ }

---------------------------------= cut here =---------------------------------

Hope this helps.

Inbar Raz

--- FMail 0.94
 * Origin: Castration takes balls. (2:403/100.42)
                                                                                                                       
