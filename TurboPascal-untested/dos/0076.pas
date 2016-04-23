Unit ExtError;
 
{ Information lifted from 'Disk Operating System 3.30 Technical Reference'.
  An IBM publication.  USE this unit with DOS 3.0 or higher.               
}
 
Interface
 
Implementation
uses Dos;
 
{$F+,R-,S-,I- }
 
Var
  ExitSave     : Pointer;
 
Procedure GetExtendedError;
 
Var
  Regs         : Registers;
  s            : String;
 
Begin
  ExitProc := ExitSave;
  Regs.AH := $59;
  Regs.BX := $0000;
  Intr($21, Regs);
  Write('Error #');
  Case Regs.AX of
    1 : s := 'Invalid function number';
    2 : s := 'File not found';
    3 : s := 'Path not found';
    4 : s := 'Too many open files (no handles left)';
    5 : s := 'Access denied (file was opened Read Only)';
    6 : s := 'Invalid handle';
    7 : s := 'Memory control blocks destroyed';
    8 : s := 'Insufficient memory';
    9 : s := 'Invalid memory block address';
   10 : s := 'Invalid environment';
   11 : s := 'Invalid format';
   12 : s := 'Invalid access code';
   13 : s := 'Invalid data';
   15 : s := 'Invalid drive was specified';
   16 : s := 'Attempt to remove current directory';
   17 : s := 'Not same device';
   18 : s := 'No more files';
   19 : s := 'Attempt to write on write-protected diskette';
   20 : s := 'Unknown unit';
   21 : s := 'Drive not ready';
   22 : s := 'Unknown command';
   23 : s := 'Data error (CRC)';
   24 : s := 'Bad request structure length';
   25 : s := 'Seek error';
   26 : s := 'Unknown media type';
   27 : s := 'Sector not found';
   28 : s := 'Printer out of paper';
   29 : s := 'Write fault';
   30 : s := 'Read fault';
   31 : s := 'General failure';
   32 : s := 'Sharing violation';
   33 : s := 'Lock violation';
   34 : s := 'Invalid disk change';
   35 : s := 'FCB unavailable';
   36 : s := 'Sharing buffer overflow';
   50 : s := 'Network request not supported';
   51 : s := 'Remote computer not listening';
   52 : s := 'Duplicate name on network';
   53 : s := 'Network name not found';
   54 : s := 'Network busy';
   55 : s := 'Network device no longer exists';
   56 : s := 'Net BIOS command limit exceeded';
   57 : s := 'Network adapter hardware error';
   58 : s := 'Incorrect response from network';
   59 : s := 'Unexpected network error';
   60 : s := 'Incompatible remote adapter';
   61 : s := 'Print queue full';
   62 : s := 'Not enough space for print file';
   63 : s := 'Print file was deleted';
   65 : s := 'Access denied';
   66 : s := 'Network device type incorrect';
   67 : s := 'Network name not found';
   68 : s := 'Network name limit exceeded';
   69 : s := 'Net BIOS session limit exceeded';
   70 : s := 'Temporarily paused';
   71 : s := 'Network request not accepted';
   72 : s := 'Print or disk redirection is paused';
   80 : s := 'File exists';
   82 : s := 'Cannot make directory entry';
   83 : s := 'Fail on INT 24';
   84 : s := 'Too many redirections';
   85 : s := 'Duplicate redirection';
   86 : s := 'Invalid password';
   87 : s := 'Invalid parameter';
   88 : s := 'Network device fault';
  end;
  WriteLn(Regs.AX, ': ', s);
  Write('Error class: ');
  Case Regs.BH of
    1 : s := 'Out of resource';
    2 : s := 'Temporary situation';
    3 : s := 'Permission problem';
    4 : s := 'Internal error in system software';
    5 : s := 'Hardware failure';
    6 : s := 'Serious failure of system software';
    7 : s := 'Application program error';
    8 : s := 'File/item not found';
    9 : s := 'File/item of invalid format or type';
   10 : s := 'File/item interlocked';
   11 : s := 'Media failure: wrong disk, CRC error...';
   12 : s := 'Collision with existing item';
   13 : s := 'Classification doesn''t exist or is inappropriate';
  end;
  WriteLn(s);
  Write('Suggested action: ');
  Case Regs.BL of
    1 : s := 'Retry';
    2 : s := 'Retry after pause';
    3 : s := 'Ask user to re-enter input';
    4 : s := 'Abort program with cleanup';
    5 : s := 'Abort immediately, skip cleanup';
    6 : s := 'Ignore';
    7 : s := 'Retry after user intervention';
  end;
  WriteLn(s);
  Write('Error locus: ');
  Case Regs.CH of
    1 : s := 'Unknown or inappropriate';
    2 : s := 'Related to disk storage';
    3 : s := 'Related to the network';
    4 : s := 'Serial device';
    5 : s := 'Memory';
  end;
  WriteLn(s);
  Halt;
end;  { GetExtendedError }

Begin
  ExitSave := ExitProc;
  ExitProc := @GetExtendedError;
end.  { ExtError }
