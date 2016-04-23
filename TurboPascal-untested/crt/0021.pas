Unit CrtSeg;
{
  CRTSEG.TPU - Written by Tom Donnelly and placed into the public domain.

               Allow the video segment address in CRT.TPU
               to be overridden with a different address.
               Particularly useful under DesqView, to make
               Turbo Pascal programs more DesqView compliant.

  Example:     SetCrtSeg(Desqview_video_buffer);

  This unit has only been tested under Turbo Pascal 6.  It may or may not
  work under different TP versions.  It is distributed "as is" without any
  claims or warranties expressed or implied.  Use at your own risk.

  If anyone finds a problem with this code, I'd appreciate hearing about it.
  Tom Donnelly - 73200,1323

  07/23/92 - Version 1.0 - Initial public-domain release.
}

Interface

Uses
   CRT;

Procedure SetCrtSeg(iSeg: Word);

Implementation

Const
   CRTSEGOFFSET         = $5D3;  {Offset in CRT.TPU to CRT buff seg value}
   OldCrtSeg            : Word
                        = $B800;

Procedure SetCrtSeg;
Var
   CrtSegAddr           : ^Word;       {Pointer to CRT buffer segment literal}
   CrtNoOps             : ^Byte;       {Pointer to area to no-op}
Begin
   CrtSegAddr := Ptr(Seg(AssignCrt),CRTSEGOFFSET);
   CrtNoOps   := Ptr(Seg(AssignCrt),CRTSEGOFFSET+2);
   If CrtSegAddr^<>OldCrtSeg Then
   Begin
      Writeln('CRTSEG.TPU: Could not find CRT segment address hook');
      If ReadKey<>#0 Then;
   End
   Else
   Begin
      OldCrtSeg  :=CrtSegAddr^;
      CrtSegAddr^:=iSeg;                   {Plug in new CRT buffer segment}
      FillChar(CrtNoOps^,9,$90);           {No-op the remainder of the code}
   End;
End;
End.
