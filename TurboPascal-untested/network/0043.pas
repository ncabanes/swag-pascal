
{
            ╔══════════════════════════════════════════════════╗
            ║     ┌╦═══╦┐┌╦═══╦┐┌╦═══╦┐┌╦═╗ ╦┐┌╦═══╦┐┌╔═╦═╗┐   ║
            ║     │╠═══╩┘├╬═══╬┤└╩═══╦┐│║ ║ ║│├╬══      ║      ║
            ║     └╩     └╩   ╩┘└╩═══╩┘└╩ ╚═╩┘└╩═══╩┘   ╩      ║
            ║                                                  ║
            ║     NetWare 3.11 API Library for Turbo Pascal    ║
            ║                      by                          ║
            ║                 S.Perevoznik                     ║
            ║                     1996                         ║
            ╚══════════════════════════════════════════════════╝
}

Unit NetStat;

Interface

Uses NetConv;

Type PhysDiskStats = record
      SystemElapsedTime : LongInt;
      DiskChanell,
      Diskremovable,
      DriveType,
      ControllerDriveNumber,
      ControllerNumber,
      ControllerType    : byte;
      DriveSize         : longInt; { in 4096 byte blocks}
      DriveCylinders    : word;
      DriveHeads,
      SectorsPerTrack   : byte;
      DriveDefinition   : array [1..63] of char;
      IOErrorCount      : word;
      HotFixStart       : LongInt;
      HotFixSize ,
      HotFixBlockAvailable : word;
      HotFixDisabled    : byte;
     end;

     FileStats = record
      SystemElapsedTime      : LongInt;
      MaxOpenFiles           : Word;
      MaxFilesOpened         : Word;
      CurrOpenFiles          : Word;
      TotalFilesOpened       : LongInt;
      TotalReadRequests      : LongInt;
      TotalWriteRequests     : LongInt;
      CurrChangedFATSectors  : Word;
      TotalChangedFATSectors : LongInt;
      FATWriteErrors         : Word;
      FatalFATWriteErrors    : Word;
      FATScanErrors          : Word;
      MaxIndexFilesOpened    : Word;
      CurrOpenIndexedFiles   : Word;
      AttachedIndexFiles     : Word;
      AvailableIndexFiles    : Word;
    end;


      CacheStats = record
            systemElapsedTime        : LongInt ;
            cacheBufferCount         : Word ;
            cacheBufferSize          : Word ;
            dirtyCacheBuffers        : Word ;
            cacheReadRequests        : LongInt ;
            cacheWriteRequests       : LongInt ;
            cacheHits                : LongInt ;
            cacheMisses              : LongInt ;
            physicalReadRequests     : LongInt ;
            physicalWriteRequests    : LongInt ;
            physicalReadErrors       : WORD ;
            physicalWriteErrors      : WORD ;
            cacheGetRequests         : LongInt ;
            cacheFullWriteRequests   : LongInt ;
            cachePartialWriteRequests: LongInt ;
            backgroundDirtyWrites    : LongInt ;
            backgroundAgedWrites     : LongInt ;
            totalCacheWrites         : LongInt ;
            cacheAllocations         : LongInt ;
            thrashingCount           : WORD ;
            LRUBlockWasDirtyCount    : WORD ;
            readBeyondWriteCount     : WORD ;
            fragmentedWriteCount     : WORD ;
            cacheHitOnUnavailCount   : WORD ;
            cacheBlockScrappedCount  : WORD ;
           end;

    ServerLANIO = record
             systemElapsedTime              : LongInt ;
             maxRoutingBuffersAvail         : Word    ;
             maxRoutingBuffersUsed          : Word    ;
             routingBuffersInUse            : Word    ;
             totalFileServicePackets        : LongInt ;
             fileServicePacketsBuffered     : Word    ;
             invalidConnPacketCount         : Word    ;
             badLogicalConnCount            : Word    ;
             packetsRcvdDuringProcCount     : Word    ;
             reprocessedRequestCount        : Word    ;
             badSequenceNumberPacketCount   : Word    ;
             duplicateReplyCount            : Word    ;
             acknowledgementsSent           : Word    ;
             badRequestTypeCount            : Word    ;
             attachDuringProcCount          : Word    ;
             attachWhileAttachingCount      : Word    ;
             forgedDetachRequestCount       : Word    ;
             badConnNumberOnDetachCount     : Word    ;
             detachDuringProcCount          : Word    ;
             repliesCanceledCount           : Word    ;
             hopCountDiscardCount           : Word    ;
             unknownNetDiscardCount         : Word    ;
             noDGroupBufferDiscardCount     : Word    ;
             outPacketNoBufferDiscardCount  : Word    ;
             IPXNotMyNetworkCount           : Word    ;
             NetBIOSPropagationCount        : LongInt ;
             totalOtherPackets              : LongInt ;
             totalRoutedPackets             : LongInt ;
          end;

       ServerMiscInfo = record
             systemElapsedTime        : LongInt;
             processorType            : BYTE;
             reserved                 : BYTE;
             serviceProcessCount      : BYTE;
             serverUtilizationPercent : BYTE;
             maxBinderyObjectsAvail   : WORD;
             maxBinderyObjectsUsed    : WORD;
             binderyObjectsInUse      : WORD;
             serverMemoryInK          : Word ;
             serverWastedMemoryInK    : Word ;
             dynamicAreaCount         : Word ;
             dynamicSpace1            : LongInt;
             maxUsedDynamicSpace1     : LongInt;
             dynamicSpaceInUse1       : LongInt;
             dynamicSpace2            : LongInt;
             maxUsedDynamicSpace2     : LongInt;
             dynamicSpaceInUse2       : LongInt;
             dynamicSpace3            : LongInt;
             maxUsedDynamicSpace3     : LongInt;
             dynamicSpaceInUse3       : LongInt;
          end;




Function GetPhysicalDiskStats(PhysicalDiskNumber : byte;
                              Var PhysicalDiskStats : PhysDiskStats) : byte;


Function GetFileSystemStats(Var FileSystemStats : FileStats ) : byte;

Function GetDiskCacheStats(Var DiskCacheStats : CacheStats ) : byte;


Function GetServerLANIOStats( Var ServerLANIOStats : ServerLANIO ) : byte;

Function GetServerMiscInformation( Var ServerMiscInformation : ServerMiscInfo) : byte;


{________________________ GetDiskUtilization _____________________________
|
| Output:   0		       --  SUCCESSFUL
|	    network error code --  UNSUCCESSFUL
|
| Comments:
|   This function returns the disk usage of a bindery object on a volume.
|   To determine the total disk space used, this call should be made
|   repetitively for all mounted volumes.  To determine the number of bytes
|   of disk space used, the usedBlocks should be multiplied by the number of
|   sectors and the bytes per sector. Currently network implementations
|   allocate the disk in 8 512-byte sectors per block, which is 4K per block.
|__________________________________________________________________________}


Function GetDiskUtilization( VolumeNumber : byte;
                             ObjectID     : LongInt;
                             Var UsedDirectories : Word;
                             Var UsedFiles       : Word;
                             Var UsedBlocks      : Word) : byte;



Implementation

Uses Dos;

Function GetPhysicalDiskStats(PhysicalDiskNumber : byte;
                              Var PhysicalDiskStats : PhysDiskStats) : byte;

Var
  r : registers;
  SendPacket  :  array [0..004] of byte;
  ReplyPacket :  array [0..096] of byte;
  WordPtr     : ^Word;
Begin
  SendPacket[2] := $D8;
  SendPacket[3] := PhysicalDiskNumber;
  WordPtr := addr(SendPacket);
  WordPtr^ := 2;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 94;

  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  GetPhysicaldiskStats := r.AL;
  if r.AL = 0 then
    begin
      move(ReplyPacket[2],PhysicalDiskStats,94);
      with PhysicalDiskStats do
        begin
          SystemElapsedTime := GetLong(Addr(SystemElapsedTime));
          DriveSize := GetLong(Addr(DriveSize));
          DriveCylinders := GetWord(Addr(DriveCylinders));
          IOErrorCount   := GetWord(Addr(IOErrorCount));
          HotFixStart    := GetLong(Addr(HotFixStart));
          HotFixSize     := GetWord(Addr(HotFixSize));
          HotFixBlockAvailable := GetWord(Addr(HotFixBlockAvailable));
        end;
    end;
end;

Function GetFileSystemStats(Var FileSystemStats : FileStats ) : byte;
Var
  r : registers;
  SendPacket  :  array [0..003] of byte;
  ReplyPacket :  array [0..030] of byte;
  WordPtr     : ^Word;
Begin
  SendPacket[2] := $D4;
  WordPtr := addr(SendPacket);
  WordPtr^ := 1;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 28;

  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  GetFileSystemStats := r.AL;
  if r.AL = 0 then
    begin
      move(ReplyPacket[2],FileSystemStats,28);
      with FileSystemStats do
        begin
          SystemElapsedTime := GetLong(Addr(SystemElapsedTime));

          MaxOpenFiles      := GetWord(Addr(MaxOpenFiles));
          MaxFilesOpened    := GetWord(Addr(MaxFilesOpened));
          CurrOpenFiles     := GetWord(Addr(CurrOpenFiles));

          TotalFilesOpened  := GetLong(Addr(TotalFilesOpened));
          TotalReadRequests := GetLong(Addr(TotalReadRequests));
          TotalWriteRequests:= GetLong(Addr(TotalWriteRequests));

          CurrChangedFATSectors  := GetWord(Addr(CurrChangedFATSectors));
          TotalChangedFATSectors := GetLong(Addr(TotalChangedFATSectors));
          FATWriteErrors         := GetWord(Addr(FATWriteErrors));
          FatalFATWriteErrors    := GetWord(Addr(FatalFATWriteErrors));
          FATScanErrors          := GetWord(Addr(FATScanErrors));
          MaxIndexFilesOpened    := GetWord(Addr(MaxIndexFilesOpened));
          CurrOpenIndexedFiles   := GetWord(Addr(CurrOpenIndexedFiles));
          AttachedIndexFiles     := GetWord(Addr(AttachedIndexFiles));
          AvailableIndexFiles    := GetWord(Addr(AvailableIndexFiles));
         end;
       end;

end;

Function GetDiskCacheStats(Var DiskCacheStats : CacheStats ) : byte;
Var
  r : registers;
  SendPacket  :  array [0..003] of byte;
  ReplyPacket :  array [0..080] of byte;
  WordPtr     : ^Word;
Begin
  SendPacket[2] := $D6;
  WordPtr := addr(SendPacket);
  WordPtr^ := 1;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 78;

  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  GetDiskCacheStats := r.AL;
  if r.AL = 0 then
    begin
      move(ReplyPacket[2],DiskCacheStats,78);
      with DiskCacheStats do
        begin

            systemElapsedTime        := GetLong(Addr(systemElapsedTime        ));
            cacheBufferCount         := GetWord(Addr(cacheBufferCount         ));
            cacheBufferSize          := GetWord(Addr(cacheBufferSize          ));
            dirtyCacheBuffers        := GetWord(Addr(dirtyCacheBuffers        ));
            cacheReadRequests        := GetLong(Addr(cacheReadRequests        ));
            cacheWriteRequests       := GetLong(Addr(cacheWriteRequests       ));
            cacheHits                := GetLong(Addr(cacheHits                ));
            cacheMisses              := GetLong(Addr(cacheMisses              ));
            physicalReadRequests     := GetLong(Addr(physicalReadRequests     ));
            physicalWriteRequests    := GetLong(Addr(physicalWriteRequests    ));
            physicalReadErrors       := GetWORD(Addr(physicalReadErrors       ));
            physicalWriteErrors      := GetWORD(Addr(physicalWriteErrors      ));
            cacheGetRequests         := GetLong(Addr(cacheGetRequests         ));
            cacheFullWriteRequests   := GetLong(Addr(cacheFullWriteRequests   ));
            cachePartialWriteRequests:= GetLong(Addr(cachePartialWriteRequests));
            backgroundDirtyWrites    := GetLong(Addr(backgroundDirtyWrites    ));
            backgroundAgedWrites     := GetLong(Addr(backgroundAgedWrites     ));
            totalCacheWrites         := GetLong(Addr(totalCacheWrites         ));
            cacheAllocations         := GetLong(Addr(cacheAllocations         ));
            thrashingCount           := GetWORD(Addr(thrashingCount           ));
            LRUBlockWasDirtyCount    := GetWORD(Addr(LRUBlockWasDirtyCount    ));
            readBeyondWriteCount     := GetWORD(Addr(readBeyondWriteCount     ));
            fragmentedWriteCount     := GetWORD(Addr(fragmentedWriteCount     ));
            cacheHitOnUnavailCount   := GetWORD(Addr(cacheHitOnUnavailCount   ));
            cacheBlockScrappedCount  := GetWORD(Addr(cacheBlockScrappedCount  ));
         end;
 end;
end;

Function GetServerLANIOStats( Var ServerLANIOStats : ServerLANIO ) : byte;
Var
  r : registers;
  SendPacket  :  array [0..003] of byte;
  ReplyPacket :  array [0..068] of byte;
  WordPtr     : ^Word;
Begin
  SendPacket[2] := $E7;
  WordPtr := addr(SendPacket);
  WordPtr^ := 1;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 66;

  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  GetServerLANIOStats := r.AL;
  if r.AL = 0 then
    begin
      move(ReplyPacket[2],ServerLANIOStats,66);
      with ServerLANIOStats do
        begin
             systemElapsedTime              := GetLong(Addr(systemElapsedTime                ));
             maxRoutingBuffersAvail         := GetWord(Addr(maxRoutingBuffersAvail           ));
             maxRoutingBuffersUsed          := GetWord(Addr(maxRoutingBuffersUsed            ));
             routingBuffersInUse            := GetWord(Addr(routingBuffersInUse              ));
             totalFileServicePackets        := GetLong(Addr(totalFileServicePackets          ));
             fileServicePacketsBuffered     := GetWord(Addr(fileServicePacketsBuffered       ));
             invalidConnPacketCount         := GetWord(Addr(invalidConnPacketCount           ));
             badLogicalConnCount            := GetWord(Addr(badLogicalConnCount              ));
             packetsRcvdDuringProcCount     := GetWord(Addr(packetsRcvdDuringProcCount       ));
             reprocessedRequestCount        := GetWord(Addr(reprocessedRequestCount          ));
             badSequenceNumberPacketCount   := GetWord(Addr(badSequenceNumberPacketCount     ));
             duplicateReplyCount            := GetWord(Addr(duplicateReplyCount              ));
             acknowledgementsSent           := GetWord(Addr(acknowledgementsSent             ));
             badRequestTypeCount            := GetWord(Addr(badRequestTypeCount              ));
             attachDuringProcCount          := GetWord(Addr(attachDuringProcCount            ));
             attachWhileAttachingCount      := GetWord(Addr(attachWhileAttachingCount        ));
             forgedDetachRequestCount       := GetWord(Addr(forgedDetachRequestCount         ));
             badConnNumberOnDetachCount     := GetWord(Addr(badConnNumberOnDetachCount       ));
             detachDuringProcCount          := GetWord(Addr(detachDuringProcCount            ));
             repliesCanceledCount           := GetWord(Addr(repliesCanceledCount             ));
             hopCountDiscardCount           := GetWord(Addr(hopCountDiscardCount             ));
             unknownNetDiscardCount         := GetWord(Addr(unknownNetDiscardCount           ));
             noDGroupBufferDiscardCount     := GetWord(Addr(noDGroupBufferDiscardCount       ));
             outPacketNoBufferDiscardCount  := GetWord(Addr(outPacketNoBufferDiscardCount    ));
             IPXNotMyNetworkCount           := GetWord(Addr(IPXNotMyNetworkCount             ));
             NetBIOSPropagationCount        := GetLong(Addr(NetBIOSPropagationCount          ));
             totalOtherPackets              := GetLong(Addr(totalOtherPackets                ));
             totalRoutedPackets             := GetLong(Addr(totalRoutedPackets               ));
           end;
          end;
    end;

Function GetServerMiscInformation( Var ServerMiscInformation : ServerMiscInfo) : byte;
Var
  r : registers;
  SendPacket  :  array [0..003] of byte;
  ReplyPacket :  array [0..058] of byte;
  WordPtr     : ^Word;
Begin
  SendPacket[2] := $E8;
  WordPtr := addr(SendPacket);
  WordPtr^ := 1;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 56;

  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  GetServerMiscInformation := r.AL;
  r.DS := r.BX;
  if r.AL = 0 then
    begin
      move(ReplyPacket[2],ServerMiscInformation,56);
      with ServerMiscInformation do
        begin
             systemElapsedTime        := GetLong(Addr(systemElapsedTime      ));
             maxBinderyObjectsAvail   := GetWORD(Addr(maxBinderyObjectsAvail ));
             maxBinderyObjectsUsed    := GetWORD(Addr(maxBinderyObjectsUsed  ));
             binderyObjectsInUse      := GetWORD(Addr(binderyObjectsInUse    ));
             serverMemoryInK          := GetWord(Addr(serverMemoryInK        ));
             serverWastedMemoryInK    := GetWord(Addr(serverWastedMemoryInK  ));
             dynamicAreaCount         := GetWord(Addr(dynamicAreaCount       ));
             dynamicSpace1            := GetLong(Addr(dynamicSpace1          ));
             maxUsedDynamicSpace1     := GetLong(Addr(maxUsedDynamicSpace1   ));
             dynamicSpaceInUse1       := GetLong(Addr(dynamicSpaceInUse1     ));
             dynamicSpace2            := GetLong(Addr(dynamicSpace2          ));
             maxUsedDynamicSpace2     := GetLong(Addr(maxUsedDynamicSpace2   ));
             dynamicSpaceInUse2       := GetLong(Addr(dynamicSpaceInUse2     ));
             dynamicSpace3            := GetLong(Addr(dynamicSpace3          ));
             maxUsedDynamicSpace3     := GetLong(Addr(maxUsedDynamicSpace3   ));
             dynamicSpaceInUse3       := GetLong(Addr(dynamicSpaceInUse3     ));
           end;
          end;
        end;

Function GetDiskUtilization( VolumeNumber : byte;
                             ObjectID     : LongInt;
                             Var UsedDirectories : Word;
                             Var UsedFiles       : Word;
                             Var UsedBlocks      : Word) : byte;

{ äáΓ∞ ¿¡Σ«α¼áµ¿ε «í ¿ß»«½∞º«óá¡¿¿ ñ¿ß¬á}
Var
  r : registers;
  SendPacket  :  array [0..08] of byte;
  ReplyPacket :  array [0..13] of byte;
  WordPtr     : ^Word;
Begin
  SendPacket[2] := 14;
  SendPacket[3] := VolumeNumber;
  ObjectID := GetLong(Addr(ObjectID));
  move(ObjectID,SendPacket[4],4);

  WordPtr := addr(SendPacket);
  WordPtr^ := 6;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 11;

  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  GetDiskUtilization := r.AL;
  r.DS := r.BX;
  if r.AL = 0 then
    begin
      UsedDirectories := GetWord(Addr(ReplyPacket[7]));
      UsedFiles       := GetWord(Addr(ReplyPacket[9]));
      UsedBlocks      := GetWord(Addr(ReplyPacket[11]));
     end;
end;

end.












