(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0057.PAS
  Description: Fossil Identification
  Author: PATRICK BERNIER
  Date: 08-25-94  09:08
*)

{
From: Patrick.Bernier@f209.n167.z1.fidonet.org

>I now realize that $1954 will be returned for either BNU/X00, but I would
>still like to be able to list to screen "which" fossil has been detected,
>and I cannot seem to figure it out.

 > try to call to the fossile with ah=1bh and you'll get
 > an info record,
 > containing pointer for fossil ID string ..

True. Here is an excerpt from 'myfos', my fossil interface unit; F_GetDrvID()
will return a string containing the current fossil driver's identification.
Sorry for the sloppy coding, I programmed this thing quite a while ago and
since it worked I never updated it to my current programming skills...

<incomplete code - won't compile>
}
  type
    F_IdentPtr = ^F_IdentStr;
    F_IdentStr = array[1..255] of byte;
    F_InfoBlock = record { len = 69 }
                    size:     word;        { Size of the infoblock }
                    majver:   byte;        { Version (high byte) }
                    minver:   byte;        { ...     (low byte) }
                    ident:    F_identptr;  { Pointer to asciiz ID of driver }
                    ibufr:    word;        { Input buffer size }
                    ifree:    word;        { Input buffer free }
                    obufr:    word;        { Output buffer size }
                    ofree:    word;        { Output buffer free }
                    swidth:   byte;        { Width of screen (in chars) }
                    sheight:  byte;        { Height of screen }
                    baud:     byte;        { Actual baud rate (computer-modem)
}
                  end;

  procedure F_GetDrvInfo;
  begin
    regs.ah := $1b;
    regs.cx := sizeof(F_InfoBlock);
    regs.dx := F_PORT;
    regs.es := Seg(F_Info);
    regs.di := Ofs(F_Info);
    intr($14,regs);
  end;

  function F_GetDrvID: string;
  var
    InfoRec: F_IdentStr;
    X: integer;
    s: string;
  begin
    F_GetDrvInfo;
    InfoRec := F_Info.ident^;
    X := 1;
    s := '';
    while InfoRec[X] <> 0 do begin
      s := s + chr(InfoRec[X]);
      inc(X);
    end;
    F_GetDrvID := s;
  end;


