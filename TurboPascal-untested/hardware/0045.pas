{
> Could someone please post what each of the 64 bytes of the CMOS are. I
> know how to read/write to the CMOS but do not know whitch byte is what.

I don't think this one is complete, but here you go:

Offset Hex   Size (bytes)   Description
==========   ============   ===========
00h          1              Current second in BCD
01h          1              Alarm second (BCD)
02h          1              Current minute (BCD)
03h          1              Alarm minute (BCD)
04h          1              Current hour (BCD)
05h          1              Alarm hour (BCD)
06h          1              Current day of week (BCD)
07h          1              Current day (BCD)
08h          1              Current month (BCD)
09h          1              Current year (BCD)
0Ah          1              Status register A
             Bit 7   = Update in progress
                            0   = date & time can be read
                            1   = time update busy
             Bit 6-4 = Time frequency divider
                            010 = 32.768 KHz
             Bit 3-0 = Rate selection frequency
                            0110 = 1.024 KHz sq. wve. freq.
0Bh          1              Status register B
             Bit 7   = Clock update cycle
                            0 = Update normally
                            1 = Abort update in progress
             Bit 6   = Periodic interrupt
                            0 = disable (default), 1 = enable
             Bit 5   = Alarm interrupt
                            0 = disable (default), 1 = enable
             Bit 4   = Update-ended interrupt
                            0 = disable (default), 1 = enable
             Bit 3   = Status register A sq. wve. freq.
                            0 = disable (default), 1 = enable
             Bit 2   = Date format
                            0 = Calender in BCD format (default)
                            1 = Calender in binary format
             Bit 1   = 24-hour clock 
                            0 = 24-hour, 1 = 12-hour
             Bit 0   = Daylight Savings Time
                            0 = disable (default), 1 = enable
0Ch          1              Status register C
             Bit 7   = IRQF flag
             Bit 6   = PF Flag
             Bit 5   = AF Flag
             Bit 4   = UF Flag
             Other bits reserved
0Dh          1              Status register D
             Bit 7   = Valid CMOS RAM bit
                            0 = battery dead, 1 = battery OK
             Other bits reserved
0Eh          1              Diagnostic status
             Bit 7   = Real-time clock power status
                            0 = OK, 1 = not OK
             Bit 6   = CMOS checksum status
                            0 = good, 1 = bad
             Bit 5   = POST config. status
                            0 = valid, 1 = not valid
             Bit 4   = POST Memory size check
                            0 = OK, 1 = !OK
             Bit 3   = Fixd disk/adapter init.
                            0 = init OK, 1 = init bad
             Bit 2   = CMOS time status
                            0 = OK, 1 = !OK
             Other bits reserved
0Fh          1              Shutdown code
             00h     = Power on or soft reset
             04h     = POST end; boot system
             05h     = JMP dword ptr with EOI
             06h     = Prot. mode tests OK
             07h     = Prot. mode tests FAILED
             08h     = Memory size FAILED
             09h     = int 15h block move
             0Ah     = JMP dword ptr with EOI
             0Bh     = Used by 80386
10h          1              Floppy drive types
             Bits 7-4= Drive 0 type              
             Bits 3-0= Drive 1 type
             (0000 = none, 0001 = 360K, 0010 = 1.2M, 0011 = 720K,
              0100 = 1.44M, 0101 = 2.88K?)
11h          1              Reserved
12h          1              HD types
             Bits 7-4= Drive 0 type (0-15)
             Bits 3-0= Drive 1 type (0-15)
13h          1              Reserved
14h          1              Installed equipment
             Bits 7-6= Number of floppy drives
             Bits 5-4= Primary display
                            00= Adapter BIOS
                            01= CGA 40 cols
                            10= CGA 80 cols
                            11= MDA
             Bits 3-2= Reserved
             Bit 1   = Math copro. present
             Bit 0   = Floppy drive present
15h          1              Base memory low-order byte
16h          1              Base memory high-order byte
17h          1              Ext. mem. low-order byte
18h          1              Ext. mem. high-order byte
19h          1              Hard disk 0 extended type (0-255)
1Ah          1              Hard disk 1 ext. type (0-255)
1Bh          9              Reserved
2Eh          1              CMOS checksum high order byte
2Fh          1              CMOS checksum low order byte
30h          1              Actual extended memory low-order byte
31h          1              Actual extended memory high-order byte
32h          1              Date century in BCD
33h          1              POST information flag
             Bit 7 = Top 128K base memory status
                            0 = not installed
                            1 = installed
             Bit 6 = Setup program flag
                            0 = Normal (default)
                            1 = Output user message
             Other bits reserved
34h          2              Reserved
