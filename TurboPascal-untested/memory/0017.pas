
{===========================================================================
 BBS: Canada Remote Systems
Date: 05-30-93 (02:30)             Number: 25203
From: GUY MCLOUGHLIN               Refer#: NONE
  To: ALL                           Recvd: NO
Subj: BP7 DPMI SWAP-FILE #1          Conf: (552) R-TP
---------------------------------------------------------------------------

  Hi to All:

  ...I saw this source-code posted by one of the support people in
  the Borland Pascal conference on Compuserve. For those of you
  who are writing DPMI apps, this could come in quite handy as
  a means of obtaining "virtual" DPMI HEAP space.

  *** NOTE: This unit is ONLY for BORLAND PASCAL 7, and cannot be
            compiled with any version of Turbo Pascal. <sorry>
------------------------------------------------------------------------}

 {.$DEFINE DebugMode}

 {$IFDEF DebugMode}
   {$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P+,Q+,R+,S+,T+,V+,X+,Y+}
 {$ELSE}
   {$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
 {$ENDIF}

 {$IFNDEF DPMI}
   ERROR!!! UNIT MUST BE COMPILED FOR PROTECTED MODE TARGET!!!
 {$ENDIF}

unit RTMswap;

interface

const
  rtmOK          = $0;
  rtmNoMemory    = $1;
  rtmFileIOError = $22;

  (***** Opens a swapfile of the specified size. If a swapfile        *)
  (*     already exists, and the new size is larger, the swapfile     *)
  (*     will grow, otherwise the previous swap file parameters       *)
  (*     are used.                                                    *)
  (*                                                                  *)
  (*    Returns:   rtmOK           - Successful                       *)
  (*               rtmNoMemory     - Not enough disk space            *)
  (*               rtmFileIOError  - Could not open/grow file         *)
  (*                                                                  *)
  function MemInitSwapFile({input } FileName : pchar;
                                    FileSize : longint) :
                           {output} integer;

  (***** Closes the swapfile if it was created by the current task.   *)
  (*     If the value returned in "Delete" is non-zero, the swapfile  *)
  (*     was deleted.                                                 *)
  (*                                                                  *)
  (*    Returns:   rtmOK           - Successful                       *)
  (*               rtmNoMemory     - Not enough physical memory to    *)
  (*                                 run without the swap file.       *)
  (*               rtmFileIOError  - Could not close/delete the file. *)
  (*                                                                  *)
  function MemCloseSwapFile({update} var Delete : integer) :
                            {output} integer;

 implementation

   function MemInitSwapFile; external 'RTM' index 35;

   function MemCloseSwapFile; external 'RTM' index 36;

 END.


{------------------------------------------------------------------------

  ...I still can't figure out what to do with the value returned in
  the "Delete" parameter passed to "MemCloseSwapFile", as it doesn't
  seem to return any specific value for me??? (Maybe it has to fail
  to return a value???)

  ...The next message is a demo program using this "RTMswap" unit.


                               - Guy                                }

 {.$DEFINE DebugMode}

 {$IFDEF DebugMode}
   {$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P+,Q+,R+,S+,T+,V+,X+,Y+}
 {$ELSE}
   {$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
 {$ENDIF}

 {$IFNDEF DPMI}
   ERROR!!! PROGRAM MUST BE COMPILED FOR PROTECTED MODE TARGET!!!
 {$ENDIF}

              (* Program to demonstrate how to create/delete DPMI     *)
              (* HEAP swap-file.                                      *)
program RTMswap_Demo;
uses
  RTMswap;

const         (* Maximum size for DPMI HEAP in bytes.                 *)
   DPMI_HeapMax = 16000 * 1024;

var
  SwapError,
  DeleteStatus : integer;
  SwapSize     : longint;
  SwapFilename : pchar;

BEGIN
              (* Calculate required DPMI HEAP swap-file size.         *)
  SwapSize := (DPMI_HeapMax - memavail);

              (* Display current DPMI HEAP size.                      *)
  writeln;
  writeln('Current DPMI HEAP size = ', (memavail div 1024), ' K');
  writeln;
  writeln('Increasing DPMI HEAP to 16,000 K via swap-file');
  writeln;

              (* Assign DPMI HEAP swap-file name.                     *)
  SwapFilename := 'SWAPDEMO.$$$';

              (* Attempt to create DPMI HEAP swap-file.               *)
  SwapError := MemInitSwapFile(SwapFilename, SwapSize);

              (* Check for errors in creating DPMI HEAP swap-file.    *)
  case SwapError of
    rtmOK          : begin
                       writeln((SwapSize div 1024), ' K DPMI HEAP ' +
                               'swap file created');
                       writeln;
                       writeln('Total DPMI HEAP size now = ',
                               (memavail div 1024), ' K');
                       writeln
                     end;
    rtmNoMemory    : writeln('ERROR!!! Not enough disk space to ' +
                             'create DPMI HEAP swap-file');
    rtmFileIOerror : writeln('ERROR!!! Could not open/grow DPMI ' +
                             'HEAP swapfile')
  else
    writeln('UNKNOWN RTM ERROR!!!')
  end;

              (* If DPMI HEAP swap-file was created, then close it.   *)
  if (SwapError = rtmOK) then
    begin
      writeln('Closing DPMI HEAP swap-file'); writeln;

              (* Attempt to close DPMI HEAP swap-file.                *)
      SwapError := MemCloseSwapFile(DeleteStatus);

              (* Check for errors in closing DPMI HEAP swap-file.     *)
      case SwapError of
        rtmOK          : begin
                           writeln('DPMI HEAP swap-file is closed');
                           writeln;
                           writeln('Current DPMI HEAP size now = ',
                                   (memavail div 1024), ' K')
                         end;
        rtmNoMemory    : writeln('ERROR!!! Not enough RAM to run ' +
                                 'without swap-file');
        rtmFileIOerror : writeln('ERROR!!! Could not close/delete ' +
                                 'swapfile')
      else
        writeln('UNKNOWN RTM ERROR!!!')
      end
    end
END.
