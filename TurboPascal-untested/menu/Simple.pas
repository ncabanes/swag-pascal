(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0019.PAS
  Description: Simple
  Author: LAAT
  Date: 01-02-98  07:35
*)


Program MyMenu;

(*     Copyright(c) : 1997 JERMiC Sw
 *         Coded by : Laat (Laat@4u.net)
 *
 *        Hi, All!
 *
 *    Some time ago in my mind grew up one idea which found its
 *  implementation in following peace of code. The main idea is
 *  simple as 2by2is4 - processing menu.
 *    After looking at this source you maight find yourself
 *  wondering - what's up with this Laat, why's he doing all the
 *  things so complicated? Well, my answer is - you can
 *  cut/change/combinate this prog till you feel good and
 *  statisfied. Anyway, i made this version of program for
 *  myself, not even for use, just for seeing how these things
 *  look like meanwhile writing program.
 *    So, it is slightly possible that i will post some new (well,
 *  that depends on how to look at this topic) source with simplified
 *  version of menu rocessing.
 *
 *              As Yours as you want me to be,
 *                                        Laat
 *
 *                                              15/11/97
 *)
Uses
  Crt;

Type
  tItem = record
    x, y                : Word;
    HotKey              : Char;
    Data                : String;
  End;

(* The same as UpCase applied to string-type *)
Function UpCaseS ( S : String ): String;
Var   i            : Integer;
      Swaps        : String;
Begin
  Swaps:='';
  If S<>'' then
    For i:=1 to Length(S) do Swaps:=Swaps+UpCase(S[i]);
  UpCaseS:=Swaps;
End;

Procedure CursorOff;assembler; (* Hides cursor *)
Asm
  mov AH,$01
  mov CH,$20
  mov CL,$0
  int $10
End;

Procedure CursorOn; assembler; (* Shows cursor *)
Asm
  mov AH,$01
  mov CH,$3
  mov CL,$4
  int $10
End;

(*   Procedure used to make this program shorter (tired of writing TextColor
 * and TextBackGround together all the time).
 *)
Procedure Col ( _Fc, _Bc: Byte );
Begin
  TextColor(_Fc); TextBackGround(_Bc);
End;

(*   Function which executes given menu.
 *   Requires:
 *     _Arr       - Array of TItem type (see Type section);
 *     _Fg, _Bg   - Text and background colors of unselected items;
 *     _Fg1, _Bg1 - Text and background colors of selected items;
 *     Pos        - Start position of cursor in the menu by default;
 *     _N         - How much items there are in you menu.
 *   Returns:
 *     Number of chosen menu or value '0' if Esc has been pressed.
 *
 *)
Function ExecuteMenu ( _Arr: Array of tItem; _Fg, _Bg, _Fg1, _Bg1: Byte; _Pos: Byte; _N: Byte ): Byte;
Var
(*  _N,*) _J, _J1                       : Integer;
  _TheEnd, _Ext, _Esc, _Found           : Boolean;
  _Ch                                   : Char;
Procedure Draw; (* Draws Menu _Arr *)
Var
  _i                                    : Integer;
Begin
  For _i:=0 to _N-1 do Begin
    If _Arr[_I].Y+_i>50-_Arr[_I].Y then Break;
    GotoXY(_Arr[_I].X, _Arr[_I].Y);
    If _i+1<>_Pos then Begin
      Col(_Fg, _Bg); Write(' '+_Arr[_i].Data+' '); Col(4, _Bg);
    End Else Begin
      Col(_Fg1, _Bg1); Write(' '+_Arr[_i].Data+' '); Col( 4, _Bg1);
    End;
    GotoXY(_Arr[_i].x+Pos(UpCase(_Arr[_i].HotKey), UpCaseS(_Arr[_i].Data)),_Arr[_i].y);
    If Pos(UpCase(_Arr[_i].HotKey), UpCaseS(_Arr[_i].Data))<>0 then
      Write(_Arr[_i].Data[Pos(UpCase(_Arr[_i].HotKey),UpCaseS(_Arr[_i].Data))]);
  End;
End;
Begin
(*  _N:=SizeOf(_Arr) div 255; - this was useful till we got menu items
 *                              defined in Const section (such arrays
 *                              have fixed size, as you already know of
 *                              course).
 *)
  _Esc:=False; _TheEnd:=False; _Found:=False;
  Repeat
    Draw; _Ch:=UpCase(ReadKey);
    Case _Ch of
      #000    : Begin (* Extended keystroke is got *)
                  _Ext:=True; _Ch:=ReadKey;
                  Case _Ch of
     (* UpArr *)    #72, #75  : If _Pos>1 then Dec(_Pos) Else _Pos:=_N;
     (* DnArr *)    #80, #77  : If _Pos<_N then Inc(_Pos) Else _Pos:=1;
     (*   End *)    #79       : _Pos:=_N;
     (*  Home *)    #71       : _Pos:=1;
                  End;
                End;
(*Esc*)#027   : Begin _TheEnd:=True; _Esc:=True; End;
(*Ent*)#013   : _TheEnd:=True;
(*Other*)  Else Begin
                  _J:=_Pos-1; _J1:=_J; Inc(_J);
                  Repeat
                   If _J>=_N then _J:=0;
                   If _J=_J1 then Break;
                   If UpCase(_Arr[_J].HotKey)=_Ch then Begin _Pos:=_J+1; Break; End
                                                  else Inc(_J);
                   Until _Found;

        End;
      End
  Until _TheEnd;
  If _Esc then ExecuteMenu:=0 Else ExecuteMenu:=_Pos;
End;

Const
  (*   Menu to execute
   *   Thought it is hard to define in const, you could use your
   * brain and write your own procedure which adds given menu item
   * to a given array, for example, header of such a procedure maight
   * look like :
   *    Procedure AddItem ( var ArrayToAddIn: Array of TItem;
   *                        ItemToAdd: TItem;
   *                        ToWhichPosition: Byte );
   *)
  Arr : Array[1..10]of tItem=((X:10; Y: 5; HotKey:'F'; Data:'First  '),
                              (X:10; Y: 6; HotKey:'S'; Data:'Second '),
                              (X:10; Y: 7; HotKey:'T'; Data:'Third  '),
                              (X:10; Y: 8; HotKey:'F'; Data:'Fourth '),
                              (X:10; Y: 9; HotKey:'I'; Data:'Fifth  '),
                              (X:10; Y:10; HotKey:'S'; Data:'Sixth  '),
                              (X:10; Y:11; HotKey:'H'; Data:'Seventh'),
                              (X:10; Y:12; HotKey:'E'; Data:'Eighth '),
                              (X:10; Y:13; HotKey:'N'; Data:'Ninth  '),
                              (X:10; Y:14; HotKey:'T'; Data:'Tenth  '));
Var
  n                             : Integer;

Begin
  Col(07, 00); ClrScr; CursorOff;
  GotoXY(01, 25); WriteLn(#24','#25','#27','#26',Home,End,Esc');

  n:=ExecuteMenu(Arr ,00, 07, 15, 01, 02, 10);

  Col(07, 00); ClrScr; CursorOn;
  If n<>0 then WriteLn('Your choice was: ', Arr[n].Data)
          else WriteLn('Where is your choice?');
End.
