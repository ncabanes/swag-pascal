Program Bezier;
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██         Bezier curve example         ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██    (C) 1992. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}
  Uses Crt, Graph;

  Const Quality = 100; { Greater number - greater quality, slower program }
        Points : array [1..4,'X'..'Y'] of integer =       { Control points   }
                 ((43,123),(345,10),(530,423),(245,345)); { for Bezier curve }

  Var Gd, Gm, I : integer;

  Function Power (Base:real;Pow:integer) : real;
    Var Temp : real;
        I    : integer;
      Begin
        Temp:=1;
        For I:=1 to Pow do Temp:=Temp*Base;
        Power:=Temp
      End;

  Begin
    Gd:=Detect;
    InitGraph (Gd,Gm,'');
    SetColor (LightRed);                      {< This part of code     }
    MoveTo (Points [1,'X'],Points [1,'Y']);   {< draws control polygon }
    For I:=2 to 4 do                          {< using control points  }
      LineTo (Points [I,'X'],Points [I,'Y']); {< in light red color.   }
    SetColor (Yellow);                        { Following code draws curve }
    MoveTo (Points [1,'X'],Points [1,'Y']);
    For I:=0 to Quality do
      LineTo (Round (Power (1-I/Quality,3)*Points [1,'X']+3*I/Quality*Power (1-I/Quality,2)*Points [2,'X']+
                     3*Power (I/Quality,2)*(1-I/Quality)*Points [3,'X']+Power (I/Quality,3)*Points [4,'X']),
              Round (Power (1-I/Quality,3)*Points [1,'Y']+3*I/Quality*Power (1-I/Quality,2)*Points [2,'Y']+
                     3*Power (I/Quality,2)*(1-I/Quality)*Points [3,'Y']+Power (I/Quality,3)*Points [4,'Y']));
    Repeat Until ReadKey<>#0;
    CloseGraph
  End.