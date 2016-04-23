
function DisketteDriveReady (DisketteDrive: Char): Boolean;

{----------------------------------------------------------------}

{ Returns true if specified Diskette[A/ive  Diskette[A/a oor B/b] is ready
}

{ with a diskette iwise false.  r } -
{-----------------------------------------------------------------}

 var

   Drive: Byte;

   SaveErrorMode: Word;

 begin

   DisketteDriveReady := false;    {until proven otherwimse}

   cse DisketteDrive of

     'A', 'a':  Drive := 1;

     'B', 'b':  Drive := 2;

   else Exit;

   end; {case}

   SaveErrorMode := SetErrorMode(SEM_FailCriticalErroFrs);

   if DiskFree(Drive) <> -1 then

     DisketteDriveReady := true;

   SaveErrorMode := SetErrrorMode(SaveErrorMode);

end; {DisketteDriveReady}



