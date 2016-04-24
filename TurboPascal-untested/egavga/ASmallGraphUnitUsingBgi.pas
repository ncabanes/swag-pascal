(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0287.PAS
  Description: A small graph unit using BGI
  Author: EUGENEWA@MS8HNET.NET
  Date: 08-30-97  10:08
*)

UNIT GI;

INTERFACE
{---------------------------------------------------------------------------}
  USES CRT,GRAPH;
{---------------------------------------------------------------------------}
  CONST
    XMax=640;
    YMax=480;
{---------------------------------------------------------------------------}
  TYPE
    Location = OBJECT
      X:1..XMax;
      Y:1..YMax;
    END;{Location}
    GUI=OBJECT(Location)
      Coor:Location;
      PROCEDURE SetupScreen(Path:STRING);
        {initialize the screen to graphic mode
         Parameter: in: path
                    Out: none
         precondtion: none
         postconditon: screen initialize in graphic mode
                       or print error msg}
      PROCEDURE WriteInt( Num:LongInt;
                          Field:Integer);
        {write integer data in graphic mode at x,y and with field
         parameter: IN: num,field
                    OUT: none
         pre: in graphic mode
         Post: num displayed with field }
      PROCEDURE WriteReal( Num:Real;
                           DecField:Integer);
        {write integer data in graphic mode at x,y and with Integer field
         and decimal field
         parameter: IN: num,Intfield,Decfield
                    OUT: none
         pre: in graphic mode
         Post: num displayed with integer field and decimal field }
      PROCEDURE Init( NewX,NewY:Integer;
                      Path:STRING);
        {initialize the parameters
         Parameter: IN: NewX,NewY
                    OUT: None
         Pre: none
         Post: NewX=> X NewY=> Y}
      PROCEDURE GWrite( Prompt: STRING);
        {write a text string on the screen
         Parameter: IN: Prompt
                    OUT: none
         Pre: 0<Coor.X<640, 0<Coor.Y<480
         Post: Prompt outputed on screen}
      PROCEDURE NxtLn;
        {put the cursor at the beginning of the next line
         Parameter: IN: none
                    OUT: none
         Pre: None
         Post: Coor.Y incremented }
      PROCEDURE ChkPos( Prompt:STRING);
        {put the cursor at the end of the msg
         Parameter: IN: Prompt
                    OUT: none
         Pre: none
         Post: Coor.X incremented }
    END;
{---------------------------------------------------------------------------}
IMPLEMENTATION
{---------------------------------------------------------------------------}
  PROCEDURE GUI.SetupScreen;
    {initialize the screen to graphic mode
     Parameter: in: path
                Out: none
     precondtion: none
     postconditon: screen initialize in graphic mode
                   or print error msg}
    VAR
     GDriver,GMes,GError:Integer;
    BEGIN{SetupScreen}
      REPEAT
        GDriver:=Detect;
        InitGraph(GDriver,GMes, Path);
        GError:=GraphResult;
        IF GError <>GrOK THEN
          BEGIN
            Writeln ('Graphics error: ',GraphErrorMsg(GError));
            Readln;
          END;
      UNTIL GError=grOK;
    END;{SetupScreen}
{---------------------------------------------------------------------------}
  PROCEDURE GUI.Init;
    {initialize the parameters
     Parameter: IN: NewX,NewY,Patn
                OUT: None
     Pre: none
     Post: NewX=> X NewY=> Y screen in graphic mode}
    BEGIN{Init}
      X:=NewX;
      Y:=NewY;
      Coor.X:=NewX;
      Coor.Y:=NewY;
      SetupScreen('C:\TP\BGI');
    END;
{---------------------------------------------------------------------------}
  PROCEDURE GUI.ChkPos;
    {put the cursor at the end of the msg
     Parameter: IN: none
                OUT: none
     Pre: none
     Post: Coor.X incremented or Coor.X:=X }
    BEGIN{NxtPos}
      IF Coor.X<(640-TextWidth(Prompt+'x')) THEN
        INC(Coor.X,TextWidth(Prompt))
      ELSE
        NxtLn;
    END;{NxtPos}
{---------------------------------------------------------------------------}
  PROCEDURE GUI.GWrite;
    {write a text string on the screen
     Parameter: IN: Prompt
                OUT: none
     Pre: 0<Coor.X<640, 0<Coor.Y<480
     Post: Prompt outputed on screen}
    VAR
      K:Integer;
    BEGIN{GWrite}
      FOR K:= 1 TO Length(Prompt) DO
        BEGIN{K}
          OutTextXY(Coor.X,Coor.Y,Prompt[K]);
          ChkPos(Prompt[K]);
        END;{K}
    END;{GWrite}
{---------------------------------------------------------------------------}
  PROCEDURE GUI.NxtLn;
    {put the cursor at the beginning of the next line
     Parameter: IN: none
                OUT: none
     Pre: None
     Post: Coor.Y incremented }
    BEGIN{NxtLn}
      Coor.X:=X;
      IF Coor.Y<(480-3*TextHeight('X')) THEN
        INC(Coor.Y,TextHeight('X'))
      ELSE
        BEGIN{ELSE}
          INC(Coor.Y,TextHeight('X'));
          Write(#7);
          OutTextXY(Coor.X,Coor.Y,'Press Enter to continue...');
          Readln;
          ClearDevice;
          Coor.Y:=Y;
        END;{ELSE}
    END;{NxtLn}
{---------------------------------------------------------------------------}
  PROCEDURE GUI.WriteInt;
    {write integer data in graphic mode at x,y and with field
     parameter: IN: x,y,num,field
                OUT: none
     pre: in graphic mode
     Post: num displayed with field at x,y}
    VAR
      Temp:STRING;
    BEGIN{WriteInt}
      Str(Num:Field,Temp);
      GWrite(Temp);
    END;{WriteInt}
{---------------------------------------------------------------------------}
  PROCEDURE GUI.WriteReal;
    {write integer data in graphic mode at x,y and with Integer field
     and decimal field
     parameter: IN: x,y,num,Decfield
                OUT: none
     pre: in graphic mode,DecField<9
     Post: num displayed with decimal field at x,y}
    VAR
      K,TempNum1:Integer;
      TempNum2:Real;
      TempInt,TempDec:STRING;
    BEGIN{WriteReal}
      TempNum1:=Abs(Trunc(Num));
      Str(TempNum1,TempInt);
      TempNum2:=Abs(Num)-TempNum1;
      FOR K:= 1 TO DecField DO
        BEGIN
          TempNum2:=TempNum2*10;
          Str(Trunc(TempNum2),TempDec);
        END;
      IF Num<0 THEN
        GWrite('-'+TempInt+'.'+TempDec)
      ELSE
        GWrite(TempInt+'.'+TempDec);
    END;{WriteReal}
{---------------------------------------------------------------------------}
BEGIN
END.


