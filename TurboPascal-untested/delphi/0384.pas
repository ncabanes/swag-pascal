
Hey Gary,
I got this from Loyd's Help files...
--------------------------------------------------
unit Rotate;
{***********************************************************
PROGRAM
  UNIT ROTATE.PAS

PURPOSE
  To contain the text rotation routines. All documentation
  for the routines are within the routines.

HISTORY
  6/18/1995 First created by Curtis Keisler

COPYRIGHT & DISCLAIMER
  See ANGLE.DPR for copyright and disclaimer notice.
***********************************************************}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    procedure PaintBox1Paint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{**********************************************************}
procedure CanvasSetTextAngle(c: TCanvas; d: Word);

{-----------------------------------------------------------
  PURPOSE
    To change the current text output rotation angle. All
    subsequent output will be at the angle provided.

  INPUT PARAMETERS
    c - The canvas on which to output the text. The font for
      the canvas must be a scaleable font.
    d - The angle in tenths of degrees. For example 10 would
      be 1 degree. 450 would be 45 degrees. 1 would be
      1/10 of a degree. To reset the text back to normal,

      make d = 0.

  HISTORY
    6/18/1995 First version written by Curtis Keisler.
-----------------------------------------------------------}
var
  LogRec: TLOGFONT;     {* Storage area for font information *}

begin
  {* Get the current font information. We only want to modify the angle *}
  GetObject(c.Font.Handle,SizeOf(LogRec),Addr(LogRec));

  {* Modify the angle. "The angle, in tenths of a degrees, between the base
     line of a character and the x-axis." (Windows API Help file.)*}

  LogRec.lfEscapement := d;

  {* Delphi will handle the deallocation of the old font handle and *}
  c.Font.Handle := CreateFontIndirect(LogRec);
end; {* CanvasSetTextAngle *}

{**********************************************************}
procedure CanvasTextOutAngle(c: TCanvas; x,y: Integer; d: Word; s: string);
{-----------------------------------------------------------
  PURPOSE
    To output rotated text in the same font as the font on
    the supplied canvas. The font must also be a scaleable

    font.

  INPUT PARAMETERS
    c - The canvas on which to output the text. The font for
      the canvas must be a scaleable font.
    x,y - The x,y screen coordinates you would normally
      supply the TextOut procedure.
    d - The angle in tenths of degrees. For example 10 would
      be 1 degree. 450 would be 45 degrees. 1 would be
      1/10 of a degree.
    s - The text to be output to the canvas.
  HISTORY
    6/18/1995 First version written by Curtis Keisler.

-----------------------------------------------------------}
var
  LogRec: TLOGFONT;     {* Storage area for font information *}
  OldFontHandle,        {* The old font handle *}
  NewFontHandle: HFONT; {* Temporary font handle *}

begin
  {* Get the current font information. We only want to modify the angle *}
  GetObject(c.Font.Handle, SizeOf(LogRec), Addr(LogRec));

  {* Modify the angle. "The angle, in tenths of a degrees, between the base
     line of a character and the x-axis." (Windows API Help file.)*}

  LogRec.lfEscapement := d;

  {* Create a new font handle using the modified old font handle *}
  NewFontHandle := CreateFontIndirect(LogRec);

  {* Save the old font handle! We have to put it back when we are done! *}
  OldFontHandle := SelectObject(c.Handle,NewFontHandle);

  {* Finally. Output the text! *}
  c.TextOut(x,y,s);

  {* Put the font back the way we found it! *}
  NewFontHandle := SelectObject(c.Handle,OldFontHandle);

  {* Delete the temporary (NewFontHandle) that we created *}

  DeleteObject(NewFontHandle);

end; {* CanvasTextOutAngle *}

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  degree,i,           {* Iteration variables *}
  midX,midY: integer; {* The middle of the form *}
  deg2Rad: Real;      {* Used to convert the degrees to radians *}

begin
  {* Used to convert the degrees to radians *}
  deg2Rad := PI / 180;

  {* Choose a scalable font! *}
  PaintBox1.Font.Name := 'Arial';
  PaintBox1.Font.Size := 12;

  {* Compute the center of the screen *}

  midX := PaintBox1.Width div 2;
  midY := PaintBox1.Height div 2;

  {* Draw 16 different angles *}
  for i := 0 to 15 do begin
    {* Compute each angle. i * (360 / 16) *}
    degree := round(i * 22.5);

    {*
       Draw the from the edges of a circle with radius of 50 pixels.
       I use -y because y is the opposite direction of the normal
       cartesian coordinate system that the sin() function is based
       upon.
       Multiply degree by 10 because the function wants 10ths of a

       degree.
    *}
    CanvasTextOutAngle(PaintBox1.Canvas,
                              round(midX + 50 * cos(degree * deg2Rad)),
                              round(midY - 50 * sin(degree * deg2Rad)),
                              degree*10,
                              'abcd');
  end; {* Next angel (i) *}

  {* Set the subsequent angle to 45 degrees (or 45 * 10 tenths = 450 *}
  CanvasSetTextAngle(PaintBox1.Canvas,450); {* 45 degrees *}

  {* Output text *}

  PaintBox1.Canvas.TextOut(10,100,'45 degrees');
  PaintBox1.Canvas.TextOut(40,100,'To the right 30 pixels');

  {* Set it back *}
  CanvasSetTextAngle(PaintBox1.Canvas,0);

end;

end.

{ This code came from Lloyd's help file! }
