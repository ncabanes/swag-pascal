{
> Otherwise, how could I tell the difference between the local users input
> and the remote users input??? If I knew that I guess I could Write my
> own chat Procedure.

Well, I definately agree With you there.. Here's some ugly code
I put into my doors, it's a chat Procedure, not With all the features I'd like,
but it works, anyway..  (BTW, I'm working on a split screen version now, but
that'll take some time as I'm very busy these days..)  This is a dump from part
of my SYSKEY.INC include File..
}

{$F+}

(* This include File is where you will take actions you define when trapped
   keys such as ALT-keys, Function-keys, etc., are pressed.

   You will need to setup your Procedures here which in turn may call other
   Procedures within your code or you may do all you need to do right here.

   For example, if you wanted to trap For ALT-C being pressed on the local
   keyboard and then call the Procedure CHAT:

   Your main block of code might look like this:

   begin  {main}
      ASSIGN(Output,'') ;
      REWrite(Output) ;
      SysopKey[1] := #0 + #46 ;   {define ALT-C as one of twenty keys }
                                  {to trap                            }
      SysopProc[1] := ALT_C ;     {define Procedure as defined here   }
      SysopKey ;                  {setup For Far call to this File    }
   end ;

   Now, whenever ALT-C is pressed, the following Procedure will be called:

   Procedure ALT_C ;
   begin
      CHAT ;                      {call Procedure CHAT which is located }
   end ;                          {within your Program's code           }

   *)

(*
   The following Procedures are called when up/down arrows are pressed
   provided they are defined using SysopKey[] and SysopProc[] within
   the main Program code
*)

Procedure end_Chat;

begin
  Chatended := True;
  { Do some other stuff here if you'd like }
end;

Procedure Chat;

Const
  FKeyCode          = #0;
  Space             = ' ';
  Hyphen            = '-';
  BackSpace         = ^H;
  CarriageReturn    = ^M;
  MaxWordLineLength = 80;

Var
  WordLine  : String[MaxWordLineLength];
  Index1    : Byte;
  Index2    : Byte;
  InputChar : Char;
  F         : Text;

Label Get_Char;

begin {WordWrap}
  If LocalKey Then
    SetColor(0,14,0)
  Else
    SetColor(0,3,0);
  UserKeysOn := False;
  WordLine  := '';
  Index1    := 0;
  Index2    := 0;
  InputChar := Space;
  ClearScreen;
  Display(0,3,0,'');
  Display(0,12,0,'Sysop Entering Chat Mode: ');
  InputChar := GetChar;
  If LocalKey Then
    SetColor(0,14,0)
  Else
    SetColor(0,3,0);
  InactiveVal := 0;

  While  (NOT Chatended)
  do begin
    If LocalKey Then
      SetColor(0,14,0)
    Else
      SetColor(0,3,0);
    Case InputChar OF
      BackSpace: {Write destructive backspace & remove Char from WordLine}
        begin
          If LocalKey Then
            SetColor(0,14,0)
          Else
            SetColor(0,3,0);
          sDisplay(0,7,0,BackSpace+Space+BackSpace);
          DELETE(WordLine,(LENGTH(WordLine) - 1),1)
        end
      else {InputChar contains a valid Char, so deal With it}
      begin
        If ( InPutChar = Chr(13) ) Then
        begin
          If LocalKey Then
            Display(0,14,0,InputChar)
          Else
            Display(0,3,0,InputChar);
        end
        Else
        begin
          If LocalKey Then
            sDisplay(0,14,0,InputChar)
          Else
            sDisplay(0,3,0,InputChar);
        end;
        If InputChar <> Chr(13) Then
          WordLine := (WordLine + InputChar)
        Else
          WordLine := '';
        if (LENGTH(WordLine) >= (MaxWordLineLength - 1)) then {we have to do a Word-wrap}
        begin
          Index1 := (MaxWordLineLength - 1);
          While ((WordLine[Index1] <> Space) and (WordLine[Index1] <> Hyphen) and (Index1 <> 0)) DO
            Index1 := (Index1 - 1);
          if (Index1 = 0) {whoah, no space was found to split line!} then
            Index1 := (MaxWordLineLength - 1); {forces split}
          DELETE(WordLine, 1, Index1);
          For Index2 := 1 to LENGTH(WordLine) DO
            sDisplay(0, 7, 0, BackSpace + Space + BackSpace);
          Display(0,3,0,'');
          If InPutChar = Chr(13) then
          begin
            If LocalKey Then
              Display(0,14,0,WordLine)
            Else
              Display(0,3,0,WordLine);
          end
          Else
          begin
            If LocalKey Then
              sDisplay(0,14,0,WordLine)
            Else
              sDisplay(0,3,0,WordLine);
          end;
        end
      end
    end; {CASE InputChar}
    {Get next key from user.}
    Get_Char:
    begin
     InputChar := GetChar;
     If ( WordLine = '' ) and ( InputChar = Chr(13) ) Then
      begin
       Display(0,3,0,'');
       Goto Get_Char;
      end;
    end;
  end; {WHILE ( not (Chatended) )}
  Display(0, 12, 0, 'Sysop Left Chat Mode.');
  If (NOT Registered) Then
  DisplayLoc(0, 7, 0, '■ If you find this Program of value, please register.');
  Delay(2500);
  Display(0, 15, 0, 'Press ( '+#17+'──┘ ) to Continue . . .');
  ClearScreen;
  Chatended := False;
  InactiveVal := 30;
  UserKeysOn := True;
end;
{
There.. let me know if you need any clarification..  (BTW, you need global
Variables Chatended and Registered as Booleans in the main program..
}