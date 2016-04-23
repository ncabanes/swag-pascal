
(*
{***********************************************************************
* WRITE_TIME:                                                          *
*                                                                      *
* Very fast, can it be done any faster, routine to plonk the current   *
* system time into a variable and to write it out as header for any    *
* data that might follow...                                            *
*                                                                      *
* Note: Requires {$G+} directive                                       *
*                                                                      *
* (C) Copyright Robert AH Prins, 1995. All rights reserved.            *
*                                                                      *
* May be copied, used and distributed freely for non-profit purposes,  *
* including the inclusion in shareware, provided credit is given.      *
***********************************************************************}
*)

procedure write_time;
const
  wt_time: string[14] = '00:00:00.00 - ';

begin
  asm
    mov   ax, $2c00
    int   $21
    mov   bx, "00"
    mov   al, ch                  {hours}
    aam
    rol   ax, 8
    or    ax, bx
    cmp   al, bl                  {<-  delete these four}
    jne   @1                      {<-  lines if you want}
    mov   al, " "                 {<-  leading zeroes in}
  @1:                             {<-  the hours        }
    mov   word ptr wt_time(1), ax
    mov   al, cl                  {minutes}
    aam
    rol   ax, 8
    or    ax, bx
    mov   word ptr wt_time[4], ax
    mov   al, dh                  {seconds}
    aam
    rol   ax, 8
    or    ax, bx
    mov   word ptr wt_time[7], ax
    mov   al, dl                  {hundreds of seconds}
    aam
    rol   ax, 8
    or    ax, bx
    mov   word ptr wt_time[10], ax
  end;

  write(wt_time);
end; {write_time}

Regards,

Robert AH Prins <nlklmpum@ibmmail.com>

