{From: cs93djn@brunel.ac.uk (Daniel John Nye)}
{
Novell NetWare 2.11 API

        Novell no longer recommends the int 21h method for invoking the
        Netware functions. Int 21h will be supported indefinitely, but the
        net API calls for addressing the software through the Multiplex
        Interrupt (2Fh). You may address the API through int 2Fh in the same
        manner as int 21h; only the interrupt number is different.


Function  0B6h  Novell NetWare SFT Level II - Extended File Attributes
entry   AH      0B6h
        AL      00h     Get Extended File Attributes)
                01h     Set Extended File Attributes)
        CL      attributes
            bit 0-3     unknown
                4       transaction tracking file
                5       indexing file (to be implemented)
                6       read audit    (to be implemented)
                7       write audit   (to be implemented)
        DS:DX   pointer to ASCIIZ pathname
return  CF      set on error
        AL      error code
                0FFh    file not found
                8Ch     caller lacks privileges
        CL      current extended file attributes


Function  0B7h  unknown or not used. Novell?


Function  0B8h  Novell Advanced NetWare 2.0+ - Printer Functions
entry   AH      0B8h
        AL      00h     Get Default Print Job Flags)
                01h     Set Default Capture Flags)
                02h     Get Specific Capture Flags)
                03h     Set Specific Print Job Flags)
                04h     Get Default Local Printer)
                05h     Set Default Local Printer)
                06h     Set Capture Print Queue)
                07h     Set Capture Print Job)
                08h     Get Banner User Name)
                09h     Set Banner User Name)
        CX      buffer size
        DL      queuing server
        ES:BX   pointer to buffer
return  none
note    In NetWare 2.1, subfunction 06h, the Queuing Server specified by DL
        does not get set. Instead, the default server is used in subsequent
        printing function calls. The workaround is to use the Get and Set
        Preferred Server calls (function 0F0h). Set the Preferred server to
        the one you want, then set the Preferred server back to the original
        when you are finished.


Function  0BBh  Novell NetWare 4.0 - Set End Of Job Statush
entry   AH      0BBh
        AL      new EOJ flag
                00h     disable EOJs
                other   enable EOJs
return  AL      old EOJ flag


Function  0BCh  Novell NetWare 4.6 - Log Physical Recordh
entry   AH      0BCh
        AL      flags byte
           bits 0       lock as well as log record
                1       non-exclusive lock
                2-7     unknown
        BP      timeout in timer ticks (1/18 sec)
        BX      file handle
        CX:DX   offset
        SI:DI   length
return  AL      error code


Function  0BDh  Novell NetWare 4.6 - Release Physical Recordh
entry   AH      0BDh
        BX      file handle
        CX:DX   offset
return  AL      error code


Function  0BEh  Novell NetWare 4.6 - Clear Physical Recordh
entry   AH      0BEh
        BX      file handle
        CX:DX   offset
return  AL      error code


Function  0BFh  Novell NetWare 4.6 - Log Record (FCB)
entry   AH      0BFh
        AL      flags byte
           bits 0       lock as well as log record
                1       non-exclusive lock
                2-7     unknown
        BP      timeout in timer ticks (1/18 sec)
        BX:CX   offset
        DS:DX   pointer to FCB
        SI:DI   length
return  AL      error code


Function  0C0h  Novell NetWare 4.6 - Release Record (FCB)
entry   AH      0C0h
        BX:CX   offset
        DS:DX   pointer to FCB
return  AL      error code


Function  0C1h  Novell NetWare 4.6 - Clear Record (FCB)
entry   AH      0C1h
        BX:CX   offset
        DS:DX   pointer to FCB
return  AL      error code


Function  0C2h  Novell NetWare 4.6 - Lock Physical Record Seth
entry   AH      0C2h
        AL      flags
           bits 0       unknown
                1       non-exclusive lock
                2-7     unknown
        BP      timeout in timer ticks (1/18 sec)
return  AL      error code


Function  0C3h  Novell NetWare 4.6 - Release Physical Record Seth
entry   0C3h
return  AL      error code


Function  0C4h  Novell NetWare 4.6 - Clear Physical Record Seth
entry   AH      0C4h
return  AL      error code


Function  0C5h  Novell NetWare 4.6 - Semaphores
entry   AH      0C5h
        AL      00h     Open Semaphore)
                DS:DX   pointer semaphore name
                CL      initial value
                return  CX:DX   semaphore handle
                        BL      open count
                01h     Examine Semaphore)
                return  CX      semaphore value (sign extended)
                        DL      open count
                02h     Wait On Semaphore)
                        BP      timeout in timer ticks (1/18 sec)
                03h     Signal Semaphore)
                04h     Close Semaphore)
        CX:DX   semaphore handle (except function 00h)
return  AL      error code


Function  0C6h  Novell NetWare 4.6 - Get or Set Lock Mode
entry   AH      0C6h
        AL      00h     set old "compatibility" mode
                01h     set new extended locks mode
                02h     get lock mode
return  AL      current lock mode


Function  0C7h  Novell NetWare 4.0 - TTS
entry   AH      0C7h
        AL      00h     TTS Begin Transaction (NetWare SFT level II)
                01h     TTS End Transaction   (NetWare SFT level II)
                02h     TTS Is Available      (NetWare SFT level II)
                03h     TTS Abort Transaction (NetWare SFT level II)
                04h     TTS Transaction Status)
                05h     TTS Get Application Thresholds)
                06h     TTS Set Application Thresholds)
                07h     TTS Get Workstation Thresholds)
                08h     TTS Set Workstation Thresholds)
return  AL      varies according to function called
                (00h)   error code
                        CX:DX   transaction reference number
                (01h)   error code
                (02h)   completion code
                        00h     TTS not available
                        01h     TTS available
                        0FDh    TTS available but disabled
                (03h)   error code
                (04h-08h) unknown


Function  0C8h  Novell NetWare 4.0 - Begin Logical File Locking
entry   AH      0C8h
                if function 0C6h lock mode 00h:
                DL      mode
                        00h     no wait
                        01h     wait
                if function 0C6h lock mode 01h:
                BP      timeout in timer ticks (1/18 sec)
return  AL      error code


Function  0C9h  Novell NetWare 4.0 - End Logical File Locking
entry   AH      0C9h
return  AL      error code


Function  0CAh  Novell NetWare 4.0  Log Personal File (FCB)
entry   AH      0CAh
        DS:DX   pointer to FCB
                if function 0C6h lock mode 01h:
                AL      log and lock flag
                        00h     log file only
                        01h     lock as well as log file
                BP      timeout in timer ticks (1/18 sec)
return  AL      error code


Function  0CBh  Novell NetWare 4.0 - Lock File Set
entry   AH      0CBh
                if function 0C6h lock mode 00h:
                DL      mode
                        00h     no wait
                        01h     wait
                if function 0C6h lock mode 01h:
                BP      timeout in timer ticks (1/18 sec)
return  AL      error code


Function  0CCh  Novell NetWare 4.0 - Release File (FCB)
entry   AH      0CCh
        DS:DX   pointer to FCB
return  none


Function  0CDh  Novell NetWare 4.0 - Release File Set
entry   AH      0CDhh
return  none


Function  0CEh  Novell NetWare 4.0 - Clear File (FCB)
entry   AH      0CEh
        DS:DX   pointer to FCB
return  AL      error code


Function  0CFh  Novell NetWare 4.0 - Clear File Set
entry   AH      0CFhh
return  AL      00h


Function  0D0h  Novell NetWare 4.6 - Log Logical Record
entry   AH      0D0h
        DS:DX   pointer record string
                if function 0C6h lock mode 01h:
                AL      flags
                   bits 0       lock as well as log the record
                        1       non-exclusive lock
                        2-7     unknown
                BP      timeout in timer ticks (1/18 sec)
return  AL      error code


Function  0D1h  Novell NetWare 4.6 - Lock Logical Record Seth
entry   AH      0D1h
                if function 0C6h lock mode 00h:
        BP      timeout in timer ticks (1/18 sec)
        DL      mode
                00h     no wait
                01h     wait
                if function 0C6h lock mode 01h:
return  AL      error code


Function  0D2h  Novell NetWare 4.0 - Release Logical Recordh
entry   AH      0D2h
        DS:DX   pointer to record string
return  AL      error code


Function  0D3h  Novell NetWare 4.0 - Release Logical Record Seth
entry   AH      0D3h
return  AL      error code


Function  0D4h  Novell NetWare 4.0 - Clear Logical Recordh
entry   AH      0D4h
        DS:DX   pointer to record string
return  AL      error code


Function  0D5h  Novell NetWare 4.0 - Clear Logical Record Seth
entry   AH      0D5h
return  AL      error code


Function  0D6h  Novell NetWare 4.0 - End Of Jobh
entry   AH      0D6h
return  AL      error code


Function  0D7h  Novell NetWare 4.0 - System Logouth
entry   AH      0D7h
return  AL      error code


Functions 0D8h, 0D9h unknown - Novell NetWare?


Function  0DAh  Novell NetWare 4.0 - Get Volume Statistics
entry   AH      0DAh
        DL      volume number
        ES:DI   pointer to reply buffer
return  AL      00h
note 1) reply buffer (struc)
        word    sectors/block
        word    total blocks
        word    unused blocks
        word    total directory entries
        word    unused directory entries
     16 bytes   volume name, null padded
        word    removable flag, 0 = not removable


Function  0DBh  Novell NetWare 4.0 - Get Number Of Local Drivesh
entry   AH      0DBh
return  AL      number of local disks


Function  0DCh  Novell NetWare 4.0 - Get Station Number (Logical ID)
entry   AH      0DCh
return  AL      station number
                00h     if NetWare not loaded or this machine is a non-
                        dedicated server
        CX      station number in ASCII


Function  0DDh  Novell NetWare 4.0 - Set Error Modeh
entry   AH      0DDh
        DL      error mode
                00h     display critical I/O errors
                01h     extended errors for all I/O in AL
                02h     extended errors for critical I/O in AL
return  AL      previous error mode


Function  0DEh  Novell NetWare 4.0 - Get/Set Broadcast Mode
entry   AH      0DEh
        AL      broadcast mode
                00h     receive console and workstation broadcasts
                01h     receive console broadcasts only
                02h     receive no broadcasts
                03h     store all broadcasts for retrieval
                04h     get broadcast mode
                05h     disable shell timer interrupt checks
                06h     enable shell timer interrupt checks
return  AL      old broadcast mode


Function  0DFh  Novell NetWare 4.0 - Capture
entry   AH      0DFh
        AL      00h     Start LPT Capture)
                01h     End LPT Capture)
                02h     Cancel LPT Capture)
                03h     Flush LPT Capture)
                04h     Start Specific Capture)
                05h     End Specific Capture)
                06h     Cancel Specific Capture)
                07h     Flush Specific Capture)
return  AL      error code


Function  0E0h  Novell NetWare - Print Spooling
entry   AH      0E0h
        DS:SI   pointer to request buffer
                subfunction in third byte of request buffer:
                00h     spool data to a capture file
                01h     close and queue capture file
                02h     set spool flags
                03h     spool existing file
                04h     get spool queue entry
                05h     remove entry from spool queue
                06h     get printer status
                09h     create a disk capture file
        ES:DI   pointer to reply buffer
return  AL      error code


Function  0E1h  Novell NetWare 4.0 - Broadcast Messages
entry   AH      0E1h
        DS:SI   pointer to request buffer
                subfunction in third byte of request buffer:
                00h     send broadcast message
                01h     get broadcase message
                02h     disable station broadcasts
                03h     enable station broadcasts
                04h     send personal message
                05h     get personal message
                06h     open message pipe
                07h     close message pipe
                08h     check pipe status
                09h     broadcast to console
        ES:DI   pointer to reply buffer
return  AL      error code


Function  0E2h  Novell NetWare 4.0 - Directory Functions
entry   AH      0E2h
        DS:SI   pointer to request buffer
        ES:DI   pointer to reply buffer
                subfunction in third byte of request buffer:
                00h     Set Directory Handle)
                01h     Get Directory Path)
                02h     Scan Directory Information)
                03h     Get Effective Directory Rights)
                04h     Modify Maximum Rights Mask)
                05h     unknown
                06h     Get Volume Name)
                07h     Get Volume Number)
                08h     unknown
                09h     unknown
                0Ah     Create Directory)
                0Bh     Delete Directory)
                0Ch     Scan Directory For Trustees)
                0Dh     Add Trustee To Directory)
                0Eh     Delete Trustee From Directory)
                0Fh     Rename Directory)
                10h     Purge Erased Files)
                11h     Restore Erased File)
                12h     Allocate Permanent Directory Handle)
                13h     Allocate Temporary Directory Handle)
                14h     Deallocate Directory Handle)
                15h     Get Volume Info With Handle)
                16h     Allocate Special Temporary Directory Handle)
                17h     retrieve a short base handle (Advanced NetWare 2.0)
                18h     restore a short base handle (Advanced NetWare 2.0)
                19h     Set Directory Information)
return  AL      error code


Function  0E3h  Novell NetWare 4.0 - Connection Control
entry   AH      E3h
        DS:SI   pointer to request buffer
        ES:DI   pointer to reply buffer
                subfunction in third byte of request buffer
                00h     login
                01h     change password
                02h     map user to station set
                03h     map object to number
                04h     map number to object
                05h     get station's logged information
                06h     get station's root mask (obsolete)
                07h     map group name to number
                08h     map number to group name
                09h     get memberset M of group G
                0Ah     Enter Login Area)
                0Bh     unknown
                0Ch     unknown
                0Dh     Log Network Message)
                0Eh     get disk utilization (Advanced NetWare 1.0)
                0Fh     scan file information (Advanced NetWare 1.0)
                10h     set file information (Advanced NetWare 1.0)
                11h     get file server information (Advanced NetWare 1.0)
                12h     unknown
                13h     get internet address (Advanced NetWare 1.02)
                14h     login to file server (Advanced NetWare 2.0)
                15h     get object connection numbers (Advanced NetWare 2.0)
                16h     get connection information (Advanced NetWare 1.0)
                17h-31h unknown
                32h     create object (Advanced NetWare 1.0)
                33h     delete object (Advanced NetWare 1.0)
                34h     rename object (Advanced NetWare 1.0)
                35h     get object ID (Advanced NetWare 1.0)
                36h     get object name (Advanced NetWare 1.0)
                37h     scan object (Advanced NetWare 1.0)
                38h     change object security (Advanced NetWare 1.0)
                39h     create propery (Advanced NetWare 1.0)
                3Ah     delete property (Advanced NetWare 1.0)
                3Bh     change property security (Advanced NetWare 1.0)
                3Ch     scan property (Advanced NetWare 1.0)
                3Dh     read property value (Advanced NetWare 1.0)
                3Eh     write property value (Advanced NetWare 1.0)
                3Fh     verify object password (Advanced NetWare 1.0)
                40h     change object password (Advanced NetWare 1.0)
                41h     add object to set (Advanced NetWare 1.0)
                42h     delete object from set (Advanced NetWare 1.0)
                43h     is object in set? (Advanced NetWare 1.0)
                44h     close bindery (Advanced NetWare 1.0)
                45h     open bindery (Advanced NetWare 1.0)
                46h     get bindery access level (Advanced NetWare 1.0)
                47h     scan object trustee paths (Advanced NetWare 1.0)
                48h-0C7h unknown
                0C8h    Check Console Privileges)
                0C9h    Get File Server Description Strings)
                0CAh    Set File Server Date And Time)
                0CBh    Disable File Server Login)
                0CCh    Enable File Server Login)
                0CDh    Get File Server Login Status)
                0CEh    Purge All Erased Files)
                0CFh    Disable Transaction Tracking)
                0D0h    Enable Transaction Tracking)
                0D1h    Send Console Broadcast)
                0D2h    Clear Connection Number)
                0D3h    Down File Server)
                0D4h    Get File System Statistics)
                0D5h    Get Transaction Tracking Statistics)
                0D6h    Read Disk Cache Statistics)
                0D7h    Get Drive Mapping Table)
                0D8h    Read Physical Disk Statistics)
                0D9h    Get Disk Channel Statistics)
                0DAh    Get Connection's Task Information)
                0DBh    Get List Of Connection's Open Files)
                0DCh    Get List Of Connections Using A File)
                0DDh    Get Physical Record Locks By Connection and File)
                0DEh    Get Physical Record Locks By File)
                0DFh    Get Logical Records By Connection)
                0E0h    Get Logical Record Information)
                0E1h    Get Connection's Semaphores)
                0E2h    Get Semaphore Information)
                0E3h    Get LAN Driver's Configuration Information)
                0E4h    unknown
                0E5h    Get Connection's Usage Statistics)
                0E6h    Get Object's Remaining Disk Space)
                0E7h    Get Server LAN I/O Statistics)
                0E8h    Get Server Miscellaneous Information)
                0E9h    Get Volume Information)
return  AL      error code


Function  0E4h  Novell NetWare 4.0 - Set File Attributes (FCB)
entry   AH      0E4h
        CL      file attributes byte
           bits 0       read only
                1       hidden
                2       system
                3-6     undocumented - unknown
                7       shareable
        DX:DX   pointer to FCB
return  AL      error code


Function  0E5h  Novell NetWare 4.0 - Update File Size (FCB)
entry   AH      0E5h
        DS:DX   pointer to FCB
return  AL      error code


Function  0E6h  Novell NetWare 4.0 - Copy File To File (FCB)
entry   AH      0E6h
        CX:DX   number of bytes to copy
        DS:SI   pointer to source FCB
        ES:DI   pointer to destination FCB
return  AL      error code


Function  0E7h  Novell NetWare 4.0 - Get File Server Date and Timeh
entry   AH      0E7h
        DS:DX   pointer to 7-byte reply buffer
                byte    year - 1900
                byte    month
                byte    day
                byte    hours
                byte    minutes
                byte    seconds
                byte    day of week (0 = Sunday)
return  unknown


Function  0E7h  Novell NetWare 4.6 - Set FCB Re-open Mode
entry   AH      0E8h
        DL      mode
                00h     no automatic re-open
                01h     automatic re-open
return  AL      error code


Function  0E9h  Novell NetWare 4.6 - Shell's "Get Base Status"
entry   AH      0E9h
        AL      00h     Get Directory Handle
        DX      drive number to check (0 = A:)
return  AL      network pathbase
        AH      base flags:
                00h     drive not currently mapped to a base
                01h     drive is mapped to a permanent base
                02h     drive is mapped to a temporary base
                03h     drive exists locally


Function  0EAh  Novell NetWare 4.6 - Return Shell Version
entry   AH      0EAh
        AL      00h     get specialized hardware information
                return  AL      hardware type
                                00h     IBM PC
                                01h     Victor 9000
                01h     Get Workstation Environment Information)
                ES:DI   pointer to 40-byte buffer
               return  AH      00h     if MSDOS system
                       buffer  filled with three null-terminated entries:
                               major operating system
                               version
                               hardware type


Function  0EBh  Novell NetWare 4.6 - Log File
entry   0EBh    Log File
        DS:DX   pointer to ASCIIZ filename
                if function 0C6h lock mode 01h:
                AL      flags
                        00h     log file only
                        01h     lock as well as log file
                BP      timeout in timer ticks (1/18 second)
return  AL      error code


Function  0ECh  Novell NetWare 4.6 - Release Fileh
entry   AH      0ECh
        DS:DX   pointer to ASCIIZ filename
return  none


Function  0EDh  Novell NetWare - Clear Fileh
entry   AH      0EDh
        DS:DX   pointer to ASCIIZ filename
return  AL      error code


Function  0EEh  Novell NetWare - Get Node Address  (Physical ID)
entry   AH      0EEh
return  CX:BX:AX = six-byte address


Function  0EFh  Novell Advanced NetWare 1.0+ - Get Drive Info
entry   AH      0EFh
        buffer  00h     Get Drive Handle Table)
                01h     Get Drive Flag Table)
                02h     Get Drive Connection ID Table)
                03h     Get Connection ID Table)
                04h     Get File Server Name Table)
return  ES:DI   pointer to shell status table


Function  0F0h  Novell Advanced NetWare 1.0+ - Get/Set Preferred Server
entry   AH      0F0h
        AL      00h     Set Preferred Connection ID)
                01h     Get Preferred Connection ID)
                02h     Get Default Connection ID)
                03h     LPT Capture Active)
                04h     Set Primary Connection ID)
                05h     Get Primary Connection ID)
                06h     Get Printer Status)
        DL      preferred file server
return  AL      selected file server


Function  0F1h  Novell Advanced NetWare 1.0+ - File Server Connection
entry   AH      0F1h
        AL      00h     Attach To File Server)
                        DL      preferred file server
                01h     Detach From File Server)
                02h     Logout From File Server)
return  AL      completion code


Function  0F1h  Novell NetWare - unknown
entry   AH      0F2h
return  unknown


Function  0F3h  Novell Advanced NetWare 2.0+ - File Server File Copy
entry   AH      0F3h
        ES:DI   pointer to request string
                word    source file handle
                word    destination file handle
                dword   starting offset in source
                dword   starting offset in destination
                dword   number of bytes to copy
return  AL      status/error code
        CX:DX   number of bytes copied


Function  0F3h  Novell NetWare
                File Server File Copyh
entry   AH      0F3h
return  unknown



Interrupt 5Ch   NETBIOS interface entry port, TOPS
entry   AH      5Ch
        ES:BX   pointer to network control block
                Subfunction in first NCB field (or with 80h for non-waiting
                call)
                10h     start session with NCB_NAME name (call)
                11h     listen for call
                12h     end session with NCB_NAME name (hangup)
                14h     send data via NCB_LSN
                15h     receive data from a session
                16h     receive data from any session
                17h     send multiple data buffers
                20h     send unACKed message (datagram)
                21h     receive datagram
                22h     send broadcast datagram
                23h     receive broadcast datagram
                30h     add name to name table
                31h     delete name from name table
                32h     reset adapter card and tables
                33h     get adapter status
                34h     status of all sessions for name
                35h     cancel
                36h     add group name to name table
                70h     unlink from IBM remote program (no F0h function)
                71h     send data without ACK
                72h     send multiple buffers without ACK
                78h     find name
                79h     token-ring protocol trace
return  AL      status
                00h     successful
                01h     bad buffer size
                03h     invalid NETBIOS command
                05h     timeout
                06h     receive buffer too small
                08h     bad session number
                09h     LAN card out of memory
                0Ah     session closed
                0Bh     command has been cancelled
                0Dh     name already exists
                0Eh     local name table full
                0Fh     name still in use, can't delete
                11h     local session table full
                12h     remote PC not listening
                13h     bad NCB_NUM field
                14h     no answer to CALL or no such remote
                15h     name not in local name table
                16h     duplicate name
                17h     bad delete
                18h     abnormal end
                19h     name error, multiple identical names in use
                1Ah     bad packet
                21h     network card busy
                22h     too many commands queued
                23h     bad LAN card number
                24h     command finished while cancelling
                26h     command can't be cancelled
                0FFh    NETBIOS busy
return  AL      error code (0 if none)
note 1) When the NETBIOS is installed ints 13h and 17h are interrupted by the
        NETBIOS. Int 18h is moved to int 86h and one of int 02h or 03h is
        used by NETBIOS. Also, NETBIOS extends the int 15h/fns 90h and 91h
        functions (scheduler functions).
     2) Normally not initialized.
     3) TOPS network card uses DMA 1, 3 or none.
     4) Sytek PCnet card uses DMA 3.
     5) Structure of Network Control Block:
        byte    ncb_command
        byte    ncb_retcode
        byte    ncb_lsn
        byte    ncb_num
        dword   pointer to ncb_buffer
        word    ncb_length
     16 bytes   ncb_callname
     16 bytes   ncb_name
        byte    ncb_rto
        byte    ncb_sto
        dword   pointer to ncb_post
        byte    ncb_lana_num
        byte    ncb_cmd_cplt
     14 bytes   ncb_reserve
     6) Structure name:
     16 bytes   nm_name
        byte    nm_num
        byte    nm_status
     7) Structure A-status:
      6 bytes   as_ID
        byte    as_jumpers
        byte    as_post
        byte    as_major
        byte    as_minor
        word    as_interval
        word    as_crcerr
        word    as_algerr
        word    as_colerr
        word    as_abterr
        dword   as_tcount
        dword   as_rcount
        word    as_retran
        word    as_xresrc
      8 bytes   as_res0
        word    as_ncbfree
        word    as_ncbmax
        word    as_ncbx
      4 bytes   as_res1
        word    as_sespend
        word    as_msp
        word    as_sesmax
        word    as_bufsize
        word    as_names
     16 name    structures  as_name
