(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0015.PAS
  Description: Initialize BGI Interface
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
The following Unit contains one Function.  This Function will initialize the
Borland BGI Interface in a Turbo Pascal Program.  I wrote this Unit in TP
5.5, but it should work For all versions of TP after 4.0.

The Function performs two actions which I think can help Graphics Programs
immensely.  The first is to obtain the path For the BGI (and CHR) drivers
from an environmental Variable BGIDIR.  The second action is to edit the
driver and mode passed to the initialization Unit against what is detected
by TP.  The Function returns a Boolean to say if it was able to successfully
initialize the driver.

I hope this helps someone.
}

Unit GrphInit;

Interface

Uses
        Dos,
        Graph;

Function Init_Graphics (Var GraphDriver, GraphMode : Integer) : Boolean;
{        This Function will initialize the Turbo Graphics For the requested
        Graphics mode if and only if the requested mode is valid For the
        machine the Function is run in.  Another feature of this Function is
        that it will look For an environmental Variable named 'BGIDIR'.  If
        this Variable is found, it will attempt to initialize the Graphics
        mode looking For the BGI driver using the String associated With BGIDIR
        as the path.  If the correct BGI driver is not available, or if there is
        not BGIDIR Variable in the environment, it will attempt to initialize
        using the current directory. }


Implementation

Function Init_Graphics (Var GraphDriver, GraphMode : Integer) : Boolean;
Const
        ENV_BGI_PATH = 'BGIDIR';
Var
        BGI_Path        : String;
begin
        { Default to not work }
        Init_Graphics := False;
  BGI_Path := GetEnv(ENV_BGI_PATH);
        InitGraph(GraphDriver,GraphMode,BGI_Path);
        if GraphResult = grOk then
                 Init_Graphics := True
        Else
  begin { Try current Directory }
                InitGraph(GraphDriver,GraphMode,'');
                if GraphResult = grOk then
                        Init_Graphics := True;
        end; { Try current Directory }
end; { Function Init_Graphics }

end.


{
 Example File :

Uses
  Graph, GrphInit;

Const
  Gd     : Integer = 0;
  Gm     : Integer = 0;
begin
  Init_Graphics(Gd, Gm);
  Line(10,10,40,40);
  Readln;
end.
}
