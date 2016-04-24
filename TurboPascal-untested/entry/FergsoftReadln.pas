(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0010.PAS
  Description: FergSoft! ReadLn
  Author: JUSTIN FERGUSON
  Date: 05-25-94  08:13
*)

{
        Ok, y'all, here's a function I've been working on for a while, and
        I thought I'd post it for everybody.  It's a modified ReadLn
        routine, and while there's no guarantees, <What's new?>, I _think_
        it's bug free. <Crossing fingers>  If y'all want to use it, go
        ahead, but I would like some credit, 'cuz it took me a while.  Just
        credit FergSoft!, Artificial Reality, Whizard, or Justin Ferguson.
        It's fairly well commented, but just throw any questions you may
        have my way...

--- Cut Here ---
}

unit FSRead;

{------------------------------------------------------------------------}
{
      FergSoft! ReadLn Routine:

                By Justin Ferguson of FergSoft!,
                a. k. a. Whizard of Artificial Reality.

      FSReadLn reads a string of specified length, at specified
      location, in specified colors, terminated by TAB or Enter.

      Feel free to use this little unit anywhere y'all want, just give
      credit for it.


                                Thanx, Whizard

                                                                         }
{------------------------------------------------------------------------}

INTERFACE

uses Crt;

Function FSReadLn (X,                                         {X Location}
                   Y,                                         {Y Location}
                   FC,                                  {Foreground Color}
                   BC,                                  {Background Color}
                   StrLength : Byte;  {Length of string to input.  Will be
                                       padded with spaces (#32).         }

                   Default : String       {Default string, leave '' for no
                                           default                       }
                    ) : String;

{------------------------------------------------------------------------}

IMPLEMENTATION

Function FSReadLn (X, Y, FC, BC, StrLength : Byte; Default : String)
                                                                 : String;

var Temp : String;                      {Temporary string}
    Location : Byte;                    {Current location in string}
    QuitFlag, InsFlag : Boolean;        {Flags}
    Ch : Char;                          {Current Character}
    Z : Integer;                        {Temp variable}
    Cursor : Word absolute $0040:$0060; {Cursor format}

begin
     QuitFlag := False;
     InsFlag := True;

     For Z := 1 to 255 do               {Clear string to spaces}
         Temp[Z] := ' ';

     For Z := 1 to Length(Default) do   {Set to default string}
         Temp[Z] := Default[Z];

     Temp[0] := Chr(StrLength);         {Set length of string}
     Location := 1;
     Ch := #1;
     Temp[StrLength + 1] := #32;
     GotoXY(X, Y);
     Write(Temp);

     Repeat
           Case Ch of
                #32..#127 : begin                    {Regular ASCII}
                              If InsFlag = False then
                                begin
                                  If Location <= StrLength then
                                    begin
                                      Location := Location + 1;
                                      Temp[Location] := Ch;
                                    end;
                                  end
                                else
                                  begin
                                    If Location <= StrLength then
                                      begin
                                        For Z := StrLength - 1 downto
                                                           Location do
                                          Temp[Z + 1] := Temp[Z];

                                          Temp[Location] := Ch;
                                          Location := Location + 1;
                                      end;
                                  end;
                            end;
                #27       : begin                              {ESC}
                              For Z := 1 to StrLength do
                                Temp[Z] := ' ';
                              Location := 1;
                            end;
                #9, #13   : QuitFlag := True;           {Tab}{Enter}
                #8        : begin                        {Backspace}
                              If Location > 1 then
                                begin
                                  Location := Location - 1;
                                    For Z := Location to StrLength do
                                      begin
                                        Temp[Z] := Temp[Z + 1];
                                      end;
                                end;
                            end;

                #0        : begin     {Extended keys... }
                              Ch := ReadKey;
                              Case Ch of

                                #75 : begin             {Left arrow}
                                        If Location > 1 then
                                          Location := Location - 1;
                                      end;
                                #77 : begin            {Right arrow}
                                        If Location < (StrLength - 1) then
                                          Location := Location + 1;
                                      end;
                                #71 : Location := 1;          {Home}
                                #79 : Location := StrLength;   {End}
                                #82 : If InsFlag = True     {Insert}
                                        then
                                          begin
                                            InsFlag := False;
                                            asm
                                               MOV AH, $01
                                               MOV CX, $0F
                                               INT $10
                                            end;
                                          end
                                        else
                                          begin
                                            InsFlag := True;
                                            asm
                                               MOV AH, $01
                                               MOV CL, $07
                                               MOV CH, $06
                                               INT $10
                                            end;
                                          end;
                                                            {Delete}
                                #83 : For Z := Location to StrLength do
                                        Temp[Z] := Temp[Z + 1];
                              end;
                            end;
                end;

           Temp[StrLength + 1] := #32;
           GotoXY(X, Y);
           Write(Temp);

           TextColor(12);
           GotoXY(79, 25);
           If InsFlag = True then Write('I') else Write(' ');
              {Note:  Take out above 3 lines to not put an insert
               status 'I' at the bottom of the screen             }

           TextColor(FC);
           TextBackground(BC);
           GotoXY(X + Location - 1, Y);
           If QuitFlag <> True then Ch := ReadKey;

     until QuitFlag = True;

     Temp[0] := Chr(StrLength);
end;

{--------------------------------------------------------------------------}

begin
end.

