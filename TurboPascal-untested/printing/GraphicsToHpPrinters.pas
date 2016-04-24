(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0046.PAS
  Description: Graphics To HP Printers
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:51
*)



{ The  following example routines are public domain programs }
{ that have  been uploaded to our Forum on CompuServe.  As a }

{ courtesy to our users that  do not have  immediate  access }
{ to  CompuServe,  Technical   Support   distributes   these }
{ routines free of charge.                                   }
{                                                            }
{ However, because these routines are public domain programs,}
{ not developed  by Borland International,  we are unable to }
{ provide any  Technical  Support or  assistance using these }
{ routines. If you need assistance  using  these   routines, }

{ or   are   experiencing difficulties,  we  recommend  that }
{ you log onto CompuServe  and request  assistance  from the }
{ Forum members that developed  the routines.                }

Unit HpCopy;
{ This unit  is designed  to dump  graphics  images produced }
{ by  Turbo  Pascal  4.0's  Graph  Unit to a Hewlett-Packard }
{ LaserJet printer.                                          }
{                                                            }
{ You  MUST set the  Aspect Ratio to 4950  before  drawing a }

{ circular object on the screen. The procedure to accomplish }
{ this is also contained in this handout.                    }
{                                                            }
{ If the Aspect Ratio is NOT set, the image produced by this }
{ routine will appear ellipsoid.                             }

Interface

Uses Crt, Dos, Graph;

Var
   LST : Text;      { MUST Redefine because Turbo's Printer }
                    { Unit does not open  LST with the File }

                    { Mode as BINARY.                       }

Procedure HPHardCopy;
{ Procedure to be  called when  the desired image is on the }
{ screen.                                                   }

Procedure SetAspectRatio( NewAspect : Word );
{ Procedure to be called to set the aspect  ratio such that }
{ circular  objects will  appear correctly on the  printout }
{ generated  by  HpHardCopy.  NOTE that  the  image on  the }
{ screen WILL appear ellipsoid.  This is NORMAL!            }


Function GetAspectX : Word;
{ This Function will return the  currently set aspect ratio }
{ to allow the user  to save  the default ratio,  set it to }
{ the ratio  required by HpHardCopy (4950) and then restore }
{ it to the default value.                                  }

Implementation

Var
   Width, Height : Word; { Variables used to store settings }
   Vport : ViewPortType; { Used in the call GetViewSettings }

{$F+}
Function LSTNoFunction ( Var F : TextRec ) : Integer;

{ This  function performs a NUL  operation  for a  Reset or }
{ Rewrite on LST.                                           }

Begin
   LSTNoFunction := 0;
End;

Function LSTOutPutToPrinter( Var F : TextRec ) : Integer;
{ LSTOutPutToPrinter  sends the output to the Printer port }
{ number stored in the first byte of the  UserData area of }
{ the Text Record.                                         }

Var
   Regs : Registers;
   P : Word;

Begin
   With F Do

   Begin
      P := 0;
      Regs.AH := 16;
      While( P < BufPos ) and ( ( Regs.AH And 16 ) = 16 ) Do
      Begin
         Regs.AL := Ord( BufPtr^[P] );
         Regs.AH := 0;
         Regs.DX := UserData[1];
         Intr( $17, Regs );
         Inc( P );
      End;
      BufPos := 0;
   End;
   If( ( Regs.AH And 16 ) = 16 ) Then
      LstOutPutToPrinter := 0         { No Error           }
   Else
      If( ( Regs.AH And 32 ) = 32 ) Then
         LSTOutPutToPrinter := 159    { Out of Paper       }

      Else
         LSTOutPutToPrinter := 160;   { Device Write Fault }
End;
{$F-}

Procedure AssignLST( Port : Byte );
{ AssignLST both sets up the LST text file record as would }
{ ASSIGN, and initializes it as would a RESET.             }
{                                                          }
{ The parameter  passed to this  procedure  corresponds to }
{ DOS's  LPT  number.  It is set  to 1 by default, but can }
{ easily be  changed to any  LPT  number by  changing  the }

{ parameter  passed  to  this  procedure  in  this  unit's }
{ initialization code.                                     }

Begin
   With TextRec( Lst ) Do
   Begin
      Handle := $FFF0;
      Mode := fmOutput;
      BufSize := SizeOf( Buffer );
      BufPtr := @Buffer;
      BufPos := 0;
      OpenFunc := @LSTNoFunction;
      InOutFunc := @LSTOutPutToPrinter;
      FlushFunc := @LSTOutPutToPrinter;
      CloseFunc := @LSTOutPutToPrinter;
      UserData[1] := Port - 1;

   End;
End;

Function GetAspectX : Word;

Begin
   GetAspectX := Word( Ptr( Seg( GraphFreeMemPtr ),
                       Ofs( GraphFreeMemPtr ) + 277 ) ^ );
End;

Procedure SetAspectRatio{ NewAspect : Word };

Begin
   Word( Ptr( Seg( GraphFreeMemPtr ),
         Ofs( GraphFreeMemPtr ) + 277 ) ^ ) := NewAspect;
End;

Procedure HPHardCopy;
{ Produces hard copy of a graph on Hewlett-Packard Laserjet }
{ printer By Joseph J. Hansen 9-15-87                       }

{ Modified Extensively for compatibility with Version 4.0's }
{ Graph Unit By Gary Stoker                                 }
{                                                           }
{ Unlike Graphix Toolbox procedure HardCopy, this procedure }
{ has no parameters, though it could easily be rewritten to }
{ include  resolution in dots  per inch,  starting  column, }
{ inverse image, etc.                                       }
{                                                           }


Const DotsPerInch  = '100';
                    { 100 dots per inch  gives  full-screen }
                    { width of 7.2 inches for Hercules card }
                    { graphs, 6.4 inches for IBM color card }
                    { and 6.4  inches  for EGA card.  Other }
                    { allowable values are 75, 150, and 300.}
                    { 75  dots  per  inch  will  produce  a }
                    { larger full-screen graph which may be }
                    { too  large to  fit  on an  8 1/2 inch }

                    { page; 150 and 300  dots per inch will }
                    { produce smaller graphs                }

      CursorPosition = '5';
                    { Column position of left side of graph }
      Esc            = #27;
                    { Escape character                      }

Var LineHeader     : String[6];
                    { Line  Header used for each  line sent }
                    { to the LaserJet printer.              }
    LineLength     : String[2];

                    { Length  in  bytes of  the  line to be }
                    { sent to the LaserJet.                 }
    Y              : Integer;
                    { Temporary loop Varible.               }

Procedure DrawLine ( Y : Integer );
{ Draws a single line of dots.  No of Bytes sent to printer }
{ is Width + 1.  Argument of the procedure is the row no, Y }

Var GraphStr       : String[255]; { String  used for OutPut }
    Base           : Word;        { Starting   position  of }

                                  { output byte.            }
    BitNo,                        { Bit Number worked on    }
    ByteNo,                       { Byte number worked on   }
    DataByte       : Byte;        { Data Byte being built   }

Begin
  FillChar( GraphStr, SizeOf( GraphStr ), #0 );
  GraphStr := LineHeader;
  For ByteNo := 0 to Width  Do
  Begin
    DataByte := 0;
    Base := 8 * ByteNo;
    For BitNo := 0 to 7 Do
    Begin
      If GetPixel( BitNo+Base, Y ) > 0

         Then
           Begin
              DataByte := DataByte + 128 Shr BitNo;
           End;
    End;
    GraphStr := GraphStr + Chr (DataByte)
  End;

  Write (Lst, GraphStr)

End; {Of Drawline}

Begin {Main procedure HPCopy}
  FillChar( LineLength, SizeOf( LineLength ), #0 );
  FillChar( LineHeader, SizeOf( LineHeader ), #0 );

  GetViewSettings( Vport );
  Width := ( Vport.X2 + 1 ) - Vport.X1;
  Width := ( ( Width - 7 ) Div 8 );
  Height := Vport.Y2 - Vport.Y1;


  Write (Lst, Esc + 'E');                 { Reset Printer   }
  Write (Lst, Esc+'*t'+DotsPerInch+'R');  { Set density in  }
                                          { dots per inch   }
  Write (Lst, Esc+'&a'+CursorPosition+'C');{ Move cursor to }
                                          { starting col    }
  Write (Lst, Esc + '*r1A');        { Begin raster graphics }

  Str (Width + 1, LineLength);
  LineHeader := Esc + '*b' + LineLength + 'W';


  For Y := 0 To Height + 1 Do

  Begin
    DrawLine ( Y );
    DrawLine ( Y );
  End;

  Write (Lst, Esc + '*rB');           { End Raster graphics }
  Write (Lst, Esc + 'E');             { Reset  printer  and }
                                      { eject page          }
End;

Begin
   AssignLST( 1 );        { This is the parameter to change }
                          { if you  want  the output  to be }
                             { directed  to  a  different  LST }
                          { device.                         }

End.




Unit HpCopy;
{ This unit  is designed  to dump  graphics  images produced }
{ by  Turbo  Pascal  4.0's  Graph  Unit to a Hewlett-Packard }
{ LaserJet printer.                                          }
{                                                            }
{ You  MUST set the  Aspect Ratio to 4950  before  drawing a }

{ circular object on the screen. The procedure to accomplish }
{ this is also contained in this handout.                    }
{                                                            }
{ If the Aspect Ratio is NOT set, the image produced by this }
{ routine will appear ellipsoid.                             }

Interface

Uses Crt, Dos, Graph;

Var
   LST : Text;      { MUST Redefine because Turbo's Printer }
                    { Unit does not open  LST with the File }

                    { Mode as BINARY.                       }

Procedure HPHardCopy;
{ Procedure to be  called when  the desired image is on the }
{ screen.                                                   }

Procedure SetAspectRatio( NewAspect : Word );
{ Procedure to be called to set the aspect  ratio such that }
{ circular  objects will  appear correctly on the  printout }
{ generated  by  HpHardCopy.  NOTE that  the  image on  the }
{ screen WILL appear ellipsoid.  This is NORMAL!            }


Function GetAspectX : Word;
{ This Function will return the  currently set aspect ratio }
{ to allow the user  to save  the default ratio,  set it to }
{ the ratio  required by HpHardCopy (4950) and then restore }
{ it to the default value.                                  }

Implementation

Var
   Width, Height : Word; { Variables used to store settings }
   Vport : ViewPortType; { Used in the call GetViewSettings }

{$F+}
Function LSTNoFunction ( Var F : TextRec ) : Integer;

{ This  function performs a NUL  operation  for a  Reset or }
{ Rewrite on LST.                                           }

Begin
   LSTNoFunction := 0;
End;

Function LSTOutPutToPrinter( Var F : TextRec ) : Integer;
{ LSTOutPutToPrinter  sends the output to the Printer port }
{ number stored in the first byte of the  UserData area of }
{ the Text Record.                                         }

Var
   Regs : Registers;
   P : Word;

Begin
   With F Do

   Begin
      P := 0;
      Regs.AH := 16;
      While( P < BufPos ) and ( ( Regs.AH And 16 ) = 16 ) Do
      Begin
         Regs.AL := Ord( BufPtr^[P] );
         Regs.AH := 0;
         Regs.DX := UserData[1];
         Intr( $17, Regs );
         Inc( P );
      End;
      BufPos := 0;
   End;
   If( ( Regs.AH And 16 ) = 16 ) Then
      LstOutPutToPrinter := 0         { No Error           }
   Else
      If( ( Regs.AH And 32 ) = 32 ) Then
         LSTOutPutToPrinter := 159    { Out of Paper       }

      Else
         LSTOutPutToPrinter := 160;   { Device Write Fault }
End;
{$F-}

Procedure AssignLST( Port : Byte );
{ AssignLST both sets up the LST text file record as would }
{ ASSIGN, and initializes it as would a RESET.             }
{                                                          }
{ The parameter  passed to this  procedure  corresponds to }
{ DOS's  LPT  number.  It is set  to 1 by default, but can }
{ easily be  changed to any  LPT  number by  changing  the }

{ parameter  passed  to  this  procedure  in  this  unit's }
{ initialization code.                                     }

Begin
   With TextRec( Lst ) Do
   Begin
      Handle := $FFF0;
      Mode := fmOutput;
      BufSize := SizeOf( Buffer );
      BufPtr := @Buffer;
      BufPos := 0;
      OpenFunc := @LSTNoFunction;
      InOutFunc := @LSTOutPutToPrinter;
      FlushFunc := @LSTOutPutToPrinter;
      CloseFunc := @LSTOutPutToPrinter;
      UserData[1] := Port - 1;

   End;
End;

Function GetAspectX : Word;

Begin
   GetAspectX := Word( Ptr( Seg( GraphFreeMemPtr ),
                       Ofs( GraphFreeMemPtr ) + 277 ) ^ );
End;

Procedure SetAspectRatio{ NewAspect : Word };

Begin
   Word( Ptr( Seg( GraphFreeMemPtr ),
         Ofs( GraphFreeMemPtr ) + 277 ) ^ ) := NewAspect;
End;

Procedure HPHardCopy;
{ Produces hard copy of a graph on Hewlett-Packard Laserjet }
{ printer By Joseph J. Hansen 9-15-87                       }

{ Modified Extensively for compatibility with Version 4.0's }
{ Graph Unit By Gary Stoker                                 }
{                                                           }
{ Unlike Graphix Toolbox procedure HardCopy, this procedure }
{ has no parameters, though it could easily be rewritten to }
{ include  resolution in dots  per inch,  starting  column, }
{ inverse image, etc.                                       }
{                                                           }


Const DotsPerInch  = '100';
                    { 100 dots per inch  gives  full-screen }
                    { width of 7.2 inches for Hercules card }
                    { graphs, 6.4 inches for IBM color card }
                    { and 6.4  inches  for EGA card.  Other }
                    { allowable values are 75, 150, and 300.}
                    { 75  dots  per  inch  will  produce  a }
                    { larger full-screen graph which may be }
                    { too  large to  fit  on an  8 1/2 inch }

                    { page; 150 and 300  dots per inch will }
                    { produce smaller graphs                }

      CursorPosition = '5';
                    { Column position of left side of graph }
      Esc            = #27;
                    { Escape character                      }

Var LineHeader     : String[6];
                    { Line  Header used for each  line sent }
                    { to the LaserJet printer.              }
    LineLength     : String[2];

                    { Length  in  bytes of  the  line to be }
                    { sent to the LaserJet.                 }
    Y              : Integer;
                    { Temporary loop Varible.               }

Procedure DrawLine ( Y : Integer );
{ Draws a single line of dots.  No of Bytes sent to printer }
{ is Width + 1.  Argument of the procedure is the row no, Y }

Var GraphStr       : String[255]; { String  used for OutPut }
    Base           : Word;        { Starting   position  of }

                                  { output byte.            }
    BitNo,                        { Bit Number worked on    }
    ByteNo,                       { Byte number worked on   }
    DataByte       : Byte;        { Data Byte being built   }

Begin
  FillChar( GraphStr, SizeOf( GraphStr ), #0 );
  GraphStr := LineHeader;
  For ByteNo := 0 to Width  Do
  Begin
    DataByte := 0;
    Base := 8 * ByteNo;
    For BitNo := 0 to 7 Do
    Begin
      If GetPixel( BitNo+Base, Y ) > 0

         Then
           Begin
              DataByte := DataByte + 128 Shr BitNo;
           End;
    End;
    GraphStr := GraphStr + Chr (DataByte)
  End;

  Write (Lst, GraphStr)

End; {Of Drawline}

Begin {Main procedure HPCopy}
  FillChar( LineLength, SizeOf( LineLength ), #0 );
  FillChar( LineHeader, SizeOf( LineHeader ), #0 );

  GetViewSettings( Vport );
  Width := ( Vport.X2 + 1 ) - Vport.X1;
  Width := ( ( Width - 7 ) Div 8 );
  Height := Vport.Y2 - Vport.Y1;


  Write (Lst, Esc + 'E');                 { Reset Printer   }
  Write (Lst, Esc+'*t'+DotsPerInch+'R');  { Set density in  }
                                          { dots per inch   }
  Write (Lst, Esc+'&a'+CursorPosition+'C');{ Move cursor to }
                                          { starting col    }
  Write (Lst, Esc + '*r1A');        { Begin raster graphics }

  Str (Width + 1, LineLength);
  LineHeader := Esc + '*b' + LineLength + 'W';


  For Y := 0 To Height + 1 Do

  Begin
    DrawLine ( Y );
    DrawLine ( Y );
  End;

  Write (Lst, Esc + '*rB');           { End Raster graphics }
  Write (Lst, Esc + 'E');             { Reset  printer  and }
                                      { eject page          }
End;

Begin
   AssignLST( 1 );        { This is the parameter to change }
                          { if you  want  the output  to be }
                             { directed  to  a  different  LST }
                          { device.                         }

End.

