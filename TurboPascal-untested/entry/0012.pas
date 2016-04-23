unit GS_KeyI;

{      Written by  Richard F Griffin

       1 December 1988, (Released to the public domain)

       1110 Magnolia Circle
       Papillion, Nebraska  68128

       CIS 75206.231

   This unit allows you to set data entry routines quickly and simply.
   It also gives the programmer the capability to override the entry
   routine and use another procedure to handle function keys.

}


interface

uses crt, dos;

type
   GS_KeyI_str80 = string[80];

var
   GS_KeyI_Chr : char;
   GS_KeyI_Fuc,
   GS_KeyI_Esc : boolean;
   GS_KeyI_Hlp : pointer;
   GS_KeyI_Psn : integer;

Function GS_KeyI_Get : char;

procedure GS_KeyI_Key(wait : boolean;Fldcnt,x,y : integer);

function GS_KeyI_T(waitcr: boolean;Fl,X,Y,B:integer;CTitl,
                 CVal:GS_KeyI_str80) : GS_KeyI_str80;

function GS_KeyI_I(waitcr:boolean;Fl,x,y,B:integer;
                CTitl:GS_KeyI_str80;XVal,l,h:integer) : integer;

function GS_KeyI_R(waitcr:boolean;Fl,x,y,B:integer;CTitl:GS_KeyI_str80;
                          XVal,l,h:real;d:integer) : real;

implementation

var
   Big_String : GS_KeyI_str80;

{$F+}
procedure GS_KeyI_Dum;
begin
   write(#7);
end;
{$F-}

{
   This procedure is an Inline far call.  The address is inserted by
   GS_KeyI_Call based on the address in GS_KeyI_Hlp.  This address is
   initially to GS_KeyI_Dum, but may be changed by the using program.

   ex:  GS_KeyI_Hlp := @MyProcedure

   The procedure will be called when a special function key (F1, F2,
   Home, RtArrow, etc.) is pressed during data entry.  The using procedure
   may then use GS_KeyI_Chr to find which key was pressed.  It is up to the
   using program to ensure the screen and window sizes are properly restored.
   The programmer must ensure that the $F+ option is used in the procedure
   to force a Far Return.

        -----------      DO NOT MODIFY THIS ROUTINE        ------------
}

procedure GS_KeyI_Jmp;
begin
   InLine ($9A/$00/$00/$00/$00);       {CALLF [GS_KeyI_Hlp]}
end;

{
   Inserts a Far Call address for GS_KeyI_Jmp.
   Works in TP 4 and 5.
}

procedure GS_KeyI_Call;
begin
   MemW[seg(GS_KeyI_Jmp):ofs(GS_KeyI_Jmp)+11] := ofs(GS_KeyI_Hlp^);
   MemW[seg(GS_KeyI_Jmp):ofs(GS_KeyI_Jmp)+13] := seg(GS_KeyI_Hlp^);
   GS_KeyI_Jmp;
end;

Function GS_KeyI_Get : char;
var ch: char;
begin
  Ch := ReadKey;
  If (Ch = #0) then  { it must be a function key }
  begin
    Ch := ReadKey;
    GS_KeyI_Fuc := true;
  end
  else GS_KeyI_Fuc := false;
  GS_KeyI_Get := Ch;
end;

procedure GS_KeyI_Key(wait : boolean;Fldcnt,x,y : integer);
Var
   Big_S : GS_KeyI_str80;
   i : integer;
begin
   Big_s := '';
   GS_KeyI_Psn := 0;
   gotoxy(x,y);
   Repeat
      GS_KeyI_Chr := GS_KeyI_Get;
      GS_KeyI_Esc := false;
      if not GS_KeyI_Fuc then
      begin
         case GS_KeyI_Chr of
            #08        : begin
                            If GS_KeyI_Psn > 0 then
                            begin
                               GS_KeyI_Psn := GS_KeyI_Psn - 1;
                               gotoxy(x+GS_KeyI_Psn,y);
                               write('_');
                               gotoxy(x+GS_KeyI_Psn,y);
                               delete(Big_S,length(Big_S),1);
                            end else
                            begin
                               write('_');
                               gotoxy(x+GS_KeyI_Psn,y);
                            end;
                         end;
            ' '..'}'   : begin
                            if (GS_KeyI_Psn = Fldcnt) and (wait) then
                                write(#7)
                            else begin
                               if GS_KeyI_Psn = 0 then
                               begin
                                  for i := 1 to Fldcnt do write('_');
                                  gotoxy(x,y);
                               end;
                               GS_KeyI_Psn := GS_KeyI_Psn + 1;
                               write(GS_KeyI_Chr);
                               Big_S := Big_S + GS_KeyI_Chr;
                            end;
                         end;
            #27        : begin
                            Big_S := ' ';
                            GS_KeyI_Esc := true;
                         end;
         end;
      end else
      begin
         GS_KeyI_Call;
         gotoxy(x+GS_KeyI_Psn,y);
      end;
   until (GS_KeyI_Chr in [#13,#27]) or ((GS_KeyI_Psn = Fldcnt) and (not wait));
   Big_String := Big_S;
end;

{ The GS_KeyI_T function will process an input from the keyboard and display
  it on the screen in a specified location.  The length of the input field is
  given, as well as a default entry.  The default entry is optionally shown
  on the screen.

  Parameter descriptions are:

        1  Boolean flag to determine whether to wait for a carriage return
           once the field is full.

        2  Length of input field.

        3  Horizontal location to start.

        4  Vertical position to start.

        5  Vertical line to place default value.  Should be 0 to inhibit
           display of default.  Will usually be the same as (4).

        6  The prompt to place on the screen prior to the data entry field.
           Should be '' if no prompt.

        7  Default value.

}


function GS_KeyI_T(waitcr: boolean;Fl,X,Y,B:integer;CTitl,
                   CVal:GS_KeyI_str80) : GS_KeyI_str80;
var
   i : integer;
begin
  GS_KeyI_T := '';
  gotoxy(x,y);
  write(CTitl);
  for i := 1 to Fl do write('_');
  if B <> 0 then
  begin
     gotoxy(x+length(CTitl),B);
     write(CVal);
  end;
  GS_KeyI_Key(waitcr,FL,x+length(CTitl),y);
  if Big_String = '' then Big_String := CVal;
  if GS_KeyI_Esc then Big_String := ' ';
  gotoxy(x+length(CTitl),y);
  write(Big_String,'':Fl-length(Big_String));
  if (B <> 0) and (B <> Y) then
  begin
     gotoxy(x+length(CTitl),B);
     write('':length(CVal));
  end;
  GS_KeyI_T := Big_String;
end;

{ The GS_KeyI_I function will accept an integer from the keyboard and display
  it on the screen in a specified location.  The length of the input field is
  given, as well as a default entry.  The default entry is optionally shown
  on the screen.  A range of acceptable values is also specified.

  Parameter descriptions are:

        1  Boolean flag to determine whether to wait for a carriage return
           once the field is full.

        2  Length of input field.

        3  Horizontal location to start.

        4  Vertical position to start.

        5  Vertical line to place default value.  Should be 0 to inhibit
           display of default.  Will usually be the same as (4).

        6  The prompt to place on the screen prior to the data entry field.
           Should be '' if no prompt.

        7  Default value.

        8  Lowest value acceptable.

        9  Highest value acceptable.

}


function GS_KeyI_I(waitcr:boolean;Fl,x,y,B:integer;
                CTitl:GS_KeyI_str80;XVal,l,h:integer) : integer;
Var
   Cod, q, i : integer;
   CVal : GS_KeyI_str80;

begin
   str(XVal:Fl,CVal);
   Cod := 1;
   while Cod <> 0 do
   begin
      Big_String := GS_KeyI_T(waitcr,Fl,X,Y,B,CTitl,CVal);
      if GS_KeyI_Esc then
      begin
         GS_KeyI_I := XVal;
         Exit;
      end;
      if Big_String[length(Big_String)] = ' ' then
         Big_String := 'z';
      for i := 1 to length(Big_String) do
         if Big_String[i] = ' ' then Big_String[i] := '0';
      val(Big_String,q,Cod);
      if Cod <> 0 then
      begin
         write(chr(7));
      end else
      begin
         if (q < l) or (q > h) then
         begin
            Cod := 1;
            write(chr(7));
         end;
      end;
   end;
   GS_KeyI_I := q;
end;


{ The GS_KeyI_R function will accept a real number from the keyboard and
  display it on the screen in a specified location.  The length of the
  input field is given, as well as a default entry.  The default entry
  is optionally shown on the screen.  A range of acceptable values is
  also specified.

  Parameter descriptions are:

        1  Boolean flag to determine whether to wait for a carriage return
           once the field is full.

        2  Length of input field.

        3  Horizontal location to start.

        4  Vertical position to start.

        5  Vertical line to place default value.  Should be 0 to inhibit
           display of default.  Will usually be the same as (4).

        6  The prompt to place on the screen prior to the data entry field.
           Should be '' if no prompt.

        7  Default value.

        8  Lowest value acceptable.

        9  Highest value acceptable.

       10  Number of decimal places.

}


function GS_KeyI_R(waitcr:boolean;Fl,x,y,B:integer;CTitl:GS_KeyI_str80;
                          XVal,l,h:real;d:integer) : real;
Var
   Cod, i : integer;
   CVal : GS_KeyI_str80;
   r : real;

begin
   str(XVal:Fl:d,CVal);
   Cod := 1;
   while Cod <> 0 do
   begin
      Big_String := GS_KeyI_T(waitcr,Fl,X,Y,B,CTitl,CVal);
      if GS_KeyI_Esc then
      begin
         GS_KeyI_R := XVal;
         Exit;
      end;
      if Big_String[length(Big_String)] = ' ' then
         Big_String := 'z';
      for i := 1 to length(Big_String) do
         if Big_String[i] = ' ' then Big_String[i] := '0';
      val(Big_String,r,Cod);
      if Cod <> 0 then
      begin
         write(chr(7));
      end else
      begin
         if (r < l) or (r > h) then
         begin
            Cod := 1;
            write(chr(7));
         end;
      end;
   end;
   gotoxy(x+length(CTitl),y);
   str(r:Fl:d,Big_String);
   write(Big_String,'':Fl-length(Big_String));
   GS_KeyI_R := r;
end;

begin
   GS_KeyI_Hlp := @GS_KeyI_Dum;
end.

{----------------   DEMO PROGRAM ------------------------ }

program KeyIDemo;

uses crt, dos, GS_KeyI;

var
   lin  : string[80];
   numi : integer;
   numr : real;

{$F+}
procedure tst;
begin
   window(1,20,80,24);
   ClrScr;
   gotoxy(20,1);
   case GS_KeyI_Chr of
      #59 : write('Function Key F1 Pressed');
      #60 : write('Function Key F2 Pressed');
      #61 : write('Function Key F3 Pressed');
      #62 : write('Function Key F4 Pressed');
      #71 : write('The Home Key was Pressed');
      #79 : write('The End Key was Pressed');
   else
      write(#7);
   end;
   window(1,1,80,25);
end;
{$F-}

begin
   clrscr;
   GS_KeyI_Hlp := @tst;
   lin := GS_KeyI_T(true, 8,10,1,1,'Enter Text Field: ','empty');
   numi := GS_KeyI_I(true, 2,10,2,2,'Enter Integer Field (0-50): ',0,0,50);
   numr:= GS_KeyI_R(true, 6,10,3,3,'Enter Real Field (0-99.99): ',0,0,99.99,2);
end.