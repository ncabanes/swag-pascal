{$M 4000,0,0}
PROGRAM MemMap;

{
  (C) Copyright 1995, Jose Antonio Noda, Spain.
  All Rights Reserved.

  I can be reached at the places
  listed below:

  Jose Antonio Noda
  Urb: 80 Viviendas, B-5º, 1º Izq.
  35620 - Gran Tarajal
  Fuerteventura - (Islas Canarias)
  Spain

  Compuserve ID  100667,2523
}

USES DOS;

CONST
  EnvironmentBlock:  STRING[12] = 'Environment ';
  ProgramBlock    :  STRING[12] = 'Program     ';

TYPE
  MemoryControlBlock =                    {MCB -- only needed fields are shown}
    RECORD
      Blocktag   :  BYTE;                 {tag is M ($4D) except last is Z ($5A)}
      BlockOwner :  WORD;                 {if nonzero, process identifier, usually PID}
      BlockSize  :  WORD;                 {size in 16-byte paragraphs (excludes MCB)}
      misc       :  ARRAY[1..3] OF BYTE;  {placeholder}
      ProgramName:  ARRAY[1..8] OF CHAR   {only used by DOS 4.0; ASCIIZ}
    END;                                  {PID normally taken from PSP}
  ProgramSegmentPrefix =                  {PSP -- only needed fields are shown}
    RECORD                                { offset }
      PSPtag     :  WORD;  { $20CD or $27CD if PSP}  { 00 $00 }
      misc       :  ARRAY[1..21] OF WORD;            { 02 $02 }
      Environment:  WORD                             { 44 $2C }
    END;
VAR
  DOSVerNum:  BYTE;                       {major version number, e.g., 3 for 3.X}
  LastSize :  WORD;                       {used to detect multiple null MCBs}
  MCB      :  ^MemoryControlBlock;
  NullMCB  :  WORD;                       {counter of MCBs pointing to 0-length blocks}
  r        :  Registers;                  {TYPE defined in DOS unit}
  segment  :  WORD;

FUNCTION W2X(w:  WORD):  STRING;          {binary word to hex character string}
CONST HexDigit:  ARRAY[0..15] OF CHAR = '0123456789ABCDEF';
BEGIN
  W2X :=  HexDigit[Hi(w) SHR 4] + HexDigit[Hi(w) AND $0F] +
          HexDigit[Lo(w) SHR 4] + HexDigit[Lo(w) AND $0F];
END;

PROCEDURE ProcessMCB;                     {Each Memory Control Block}
VAR                                       {is processed by this PROCEDURE.}
  b        :  CHAR;
  Blocktype:  STRING[12];
  bytes    :  LongInt;
  EnvSize  :  WORD;
  i        :  WORD;
  last     :  CHAR;
  MCBenv   :  ^MemoryControlBlock;
  MCBowner :  ^MemoryControlBlock;
  psp      :  ^ProgramSegmentPrefix;
BEGIN
  IF   (MCB^.BlockTag <> $4D) AND (MCB^.BlockTag <> $5A) AND
       (MCB^.BlockTag <> $00)
  THEN
  BEGIN
    IF   NullMCB > 0
    THEN WRITELN (NullMCB:6,' contiguous MCBs pointing to empty ','blocks not shown.');
    WRITELN ('Unknown Memory Control Block Tag ''',MCB^.BlockTag,'''.');
    WRITELN ('MemMap scan terminated.');
    HALT
  END;
  IF   (MCB^.BlockSize = 0) AND (LastSize = 0)
  THEN INC (NullMCB)  {Count but don't output multiple null MCBs}
  ELSE
  BEGIN
    LastSize := MCB^.BlockSize;
    IF   NullMCB > 0
    THEN BEGIN
    WRITELN (NullMCB:6,' contiguous MCBs pointing to empty ','blocks not shown.');
      NullMCB := 0
  END
  ELSE
  BEGIN
    bytes := LongInt(MCB^.BlockSize) SHL 4; {size of MCB in bytes}
    WRITE (W2X(segment):6,W2X(MCB^.BlockSize):8,'0',bytes:9,
    W2X(MCB^.BlockOwner):8,'   ');
    IF   MCB^.BlockOwner = 0
    THEN
      WRITELN ('Free Space    <unallocated>')
    ELSE
    BEGIN
      psp := Ptr(MCB^.BlockOwner,0);      {possible PSP}
                                          {Almost all programs have a tag of $20CD; DOS MODE is one
                                           that uses $27CD in some versions.}
      IF   (psp^.PSPtag <> $20CD) AND (psp^.PSPtag <> $27CD)
      THEN WRITELN ('System        ',   {not valid PSP}
                    '<DOS ',DosVerNum,'.',Hi(DOSVersion),'>')
      ELSE
      BEGIN                        {valid program segment prefix}
        MCBenv := Ptr(psp^.Environment-1,0);    {MCB of environment}
        BlockType := 'Data        ';            {assume}
        IF   MCB^.Blockowner = (segment + 1)
        THEN
          BlockType := ProgramBlock
        ELSE
        IF   psp^.Environment = (segment + 1)
        THEN
          BlockType := EnvironmentBlock;
          WRITE (BlockType:12,'  ');
        IF  MCB^.BlockOwner <> MCBenv^.BlockOwner
        THEN
        IF   DOSVerNum <> 4
        THEN WRITELN ('<unknown>')  {different owner; unknown in 3.X}
        ELSE
        BEGIN                  {in DOS 4.0 short name is in MCB}
          MCBowner := Ptr(MCB^.Blockowner-1,0);    {MCB of owner block}
          i := 1;
          WHILE (MCBowner^.ProgramName[i] <> #$00) AND (i < 9) DO BEGIN
          WRITE (MCBowner^.ProgramName[i]);
          INC (i)
        END;
        WRITELN
      END
      ELSE
      BEGIN     {environment must have same owner as MCB}
        IF   DOSVerNum < 3
        THEN
          WRITELN ('<unknown>')       {DOS 1.X or 2.X}
        ELSE
        BEGIN                       {DOS 3.X}
          EnvSize := MCBenv^.BlockSize SHL 4;      {multiply by 16}
          i := 0;
          b := CHAR( Mem[psp^.Environment:i] );
          REPEAT
            last := b;    {skip through ASCIIZ environment variables}
            INC (i);
            b := CHAR( Mem[psp^.Environment:i] );
          UNTIL (i > EnvSize) OR ( (b = #$00) AND (last = #$00));
          INC (i);        {end of environment block is $0000}
          b := CHAR( Mem[psp^.Environment:i] );
          IF   (i >= EnvSize) OR (b <> #$01)  {valid signature?}
          THEN
            WRITE ('<shell>')    {shell is probably COMMAND.COM}
          ELSE
          BEGIN
            INC (i,2);              {skip process signature $0001}
            b := CHAR( Mem[psp^.Environment:i] );
            REPEAT
              WRITE (b);         {output process name byte-by-byte}
              INC (i);
              b := CHAR( Mem[psp^.Environment:i] )
            UNTIL (i > EnvSize) OR (b = #$00);
          END;
          WRITELN
        END
      END;
    END;
   END;
  END;
 END;
END;

BEGIN
  DOSVerNum := Lo(DOSVersion);                  {major DOS version number}
  WRITELN ('Memory',' ':41,'MemMap (Version 1.0, Jul 95)');
  Writeln;
  WRITELN ('Control    Block Size');
  WRITELN (' Block       [Bytes]       Owner');
  WRITELN ('Segment    hex   decimal  Segment      Type      ',
           '          Name');
  WRITELN ('-------  ------- -------  -------  ------------  ',
           '------------------------');
  LastSize := $FFFF;
  NullMCB := 0;
  r.AH := $52;                       {undocumented DOS function that returns a pointer}
  Intr ($21,r);                      {to the DOS 'list of lists'                      }
  segment := MemW[r.ES:r.BX-2];      {segment address of first MCB found at}
                                     {offset -2 from List of List pointer  }
  REPEAT
    MCB := Ptr(segment,0);           {MCB^ points to first MCB}
    ProcessMCB;                      {Look at each MCB}
    segment := segment + MCB^.BlockSize + 1
  UNTIL (MCB^.Blocktag = $5A)        {last one is $5A; all others are $4D}
END.
