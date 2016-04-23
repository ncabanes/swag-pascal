{ Have NO IDEA what the message say ..  they are in Russian ! GDAVIS}
{$IFDEF VIRTUALPASCAL}
èá¬¿Ñ ó OS/2 ó««íΘÑ ¼«ú
Γ íδΓ∞ «óÑp½Ñ¿ ? éδ ó ßó«Ñ¼
¼Ñ ? :)
{$ENDIF}
{$IFDEF DPMI}
èá¬¿Ñ ó DPMI ó««íΘÑ ¼«ú
Γ íδΓ∞ «óÑp½Ñ¿ ? éδ ó ßó«Ñ¼
¼Ñ ? :)
{$ENDIF}
{$IFDEF OS2}
èá¬¿Ñ ó OS/2 ó««íΘÑ ¼«ú
Γ íδΓ∞ «óÑp½Ñ¿ ? éδ ó ßó«Ñ¼
¼Ñ ? :)
{$ENDIF}

Unit MainOvr;
Interface

Uses Overlay,Dos;

Implementation

{.$DEFINE BUILDEXE}

Var
   Ovr_Name : PathStr;
          D : DirStr;
          N : NameStr;
          E : ExtStr;

Begin
  FSplit(ParamStr(0),D,N,E);
{$IFDEF BUILDEXE}
  Ovr_Name:=D+N+'.EXE';
{$ELSE}
  Ovr_Name:=D+N+'.OVR';
{$ENDIF}
  Repeat
    OvrInit(ovr_name);
    If OvrResult=OvrNotFound
      Then
        Begin
          WriteLn('ÄóÑα½Ñ⌐¡δ⌐ Σá⌐½ ¡Ñ ¡á⌐ñÑ¡ : ',ovr_name);
          Write  ('éóÑñ¿ΓÑ »αáó¿½∞¡«Ñ ¿¼∩ :');
          ReadLn(Ovr_Name);
        End;
  Until OvrResult<>OvrNotFound;
  If OvrResult<>OvrOk
    Then
      Begin
        WriteLn('ÄΦ¿í¬á áñ¼¿¡¿ßΓαáΓ«αá «óeα½ÑÑó ',OvrResult);
{$IFDEF STONYBROOK}
        Halt(1);
{$ELSE}
        RunError;
{$ENDIF}
      End;
  OvrInitEMS;
  If OvrResult<>OvrOk
    Then
      Begin
        Case OvrResult Of
          OvrNoEMSDriver : Write('äαá⌐óÑα EMS ¡ÑßΓá¡«ó½Ñ¡');
          OvrNoEMSMemory : Write('îá½« ßó«í«ñ¡«⌐ EMS »á¼∩Γ¿');
          OvrIOError     : Write('ÄΦ¿í¬á τΓÑ¡¿∩ Σá⌐½á');
        End;
        Write(' - EMS »á¼∩Γ∞ ¡Ñ ¿ß»«½∞ºÑΓß∩.');
      End;
  OvrSetRetry(OvrGetBuf div 3);
end.
