(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0037.PAS
  Description: Produce DOS Error Message
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:01
*)

{*****************************************************************************
 * Function ...... ErrorMsg()
 * Purpose ....... To produce a DOS error message based on the error code
 * Parameters .... ErrorCode       DOS error code
 * Returns ....... Error message assosiated with passed code
 * Notes ......... Uses function ITOS
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION ErrorMsg( ErrorCode: INTEGER ): STRING;
BEGIN
     CASE ErrorCode OF
          0: ErrorMsg := 'No Error';
          2: ErrorMsg := 'File Not Found';
          3: ErrorMsg := 'Path Not Found';
          4: ErrorMsg := 'Too Many Open Files';
          5: ErrorMsg := 'File Access Denied';
          6: ErrorMsg := 'Invalid File Handle';
         12: ErrorMsg := 'Invalid File Access Code';
         15: ErrorMsg := 'Invalid Drive Number';
         16: ErrorMsg := 'Cannot Remove Current Directory';
         17: ErrorMsg := 'Cannot Rename Across Drives';
         18: ErrorMsg := 'File access error';
        100: ErrorMsg := 'Disk Read Error';
        101: ErrorMsg := 'Disk Write Error';
        102: ErrorMsg := 'File Not Assigned';
        103: ErrorMsg := 'File Not Open';
        104: ErrorMsg := 'File Not Open For Input';
        105: ErrorMsg := 'File Not Open For Output';
        106: ErrorMsg := 'Invalid Numeric Format';
        150: ErrorMsg := 'Disk Is Write-Protected';
        151: ErrorMsg := 'Unknown Unit';
        152: ErrorMsg := 'Drive Not Ready';
        153: ErrorMsg := 'Unknown Command';
        154: ErrorMsg := 'CRC Error In Data';
        155: ErrorMsg := 'Bad Drive Request Structure Length';
        156: ErrorMsg := 'Disk Seek Error';
        157: ErrorMsg := 'Unknown Media Type';
        158: ErrorMsg := 'Sector Not Found';
        159: ErrorMsg := 'Printer Out Of Paper';
        160: ErrorMsg := 'Device Write Fault';
        161: ErrorMsg := 'Device Read Fault';
        162: ErrorMsg := 'Hardware Failure';
        ELSE ErrorMsg := 'Error Number: ' + ITOS( ErrorCode, 0 );
    END; { CASE }
END;


