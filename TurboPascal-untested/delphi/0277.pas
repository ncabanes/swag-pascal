
  N CAT SUB CODE  MESSAGE
System related (Fatal Error
  1 21  01  2101  Cannot open a system file. 
  2 21  02  2102  I/O error on a system file. 
  3 21  03  2103  Data structure corruption. 
  4 21  04  2104  Cannot find Engine configuration file. 
  5 21  05  2105  Cannot write to Engine configuration file. 
  6 21  06  2106  Cannot initialize with different configuration file. 
  7 21  07  2107  System has been illegally re-entered. 
  8 21  08  2108  Cannot locate IDAPI32  .DLL. 
  9 21  09  2109  Cannot load IDAPI32  .DLL. 
 10 21  0A  210A  Cannot load an IDAPI service library. 
 11 21  0B  210B  Cannot create or open temporary file. 
Object of interest Not Found
 12 22  01  2201  At beginning of table. 
 13 22  02  2202  At end of table. 
 14 22  03  2203  Record moved because key value changed. 
 15 22  04  2204  Record/Key deleted. 
 16 22  05  2205  No current record. 
 17 22  06  2206  Could not find record. 
 18 22  07  2207  End of BLOB. 
 19 22  08  2208  Could not find object. 
 20 22  09  2209  Could not find family member. 
 21 22  0A  220A  BLOB file is missing. 
 22 22  0B  220B  Could not find language driver. 
Physical Data Corruption
 23 23  01  2301  Corrupt table/index header. 
 24 23  02  2302  Corrupt file - other than header. 
 25 23  03  2303  Corrupt Memo/BLOB file. 
 26 23  05  2305  Corrupt index. 
 27 23  06  2306  Corrupt lock file. 
 28 23  07  2307  Corrupt family file. 
 29 23  08  2308  Corrupt or missing .VAL file. 
 30 23  09  2309  Foreign index file format. 
I/O related error
 31 24  01  2401  Read failure. 
 32 24  02  2402  Write failure. 
 33 24  03  2403  Cannot access directory. 
 34 24  04  2404  File Delete operation failed. 
 35 24  05  2405  Cannot access file. 
 36 24  06  2406  Access to table disabled because of previous error. 
Resource or Limit error
 37 25  01  2501  Insufficient memory for this operation. 
 38 25  02  2502  Not enough file handles. 
 39 25  03  2503  Insufficient disk space. 
 40 25  04  2504  Temporary table resource limit. 
 41 25  05  2505  Record size is too big for table. 
 42 25  06  2506  Too many open cursors. 
 43 25  07  2507  Table is full. 
 44 25  08  2508  Too many sessions from this workstation. 
 45 25  09  2509  Serial number limit (Paradox). 
 46 25  0A  250A  Some internal limit (see context). 
 47 25  0B  250B  Too many open tables. 
 48 25  0C  250C  Too many cursors per table. 
 49 25  0D  250D  Too many record locks on table. 
 50 25  0E  250E  Too many clients. 
 51 25  0F  250F  Too many indexes on table. 
 52 25  10  2510  Too many sessions. 
 53 25  11  2511  Too many open databases. 
 54 25  12  2512  Too many passwords. 
 55 25  13  2513  Too many active drivers. 
 56 25  14  2514  Too many fields in Table Create. 
 57 25  15  2515  Too many table locks. 
 58 25  16  2516  Too many open BLOBs. 
 59 25  17  2517  Lock file has grown too large. 
 60 25  18  2518  Too many open queries. 
 61 25  1A  251A  Too many BLOBs. 
 62 25  1B  251B  File name is too long for a Paradox version 5.0 table. 
 63 25  1C  251C  Row fetch limit exceeded. 
 64 25  1D  251D  Long name not allowed for this tablelevel. 
Integrity Violation
 65 26  01  2601  Key violation. 
 66 26  02  2602  Minimum validity check failed. 
 67 26  03  2603  Maximum validity check failed. 
 68 26  04  2604  Field value required. 
 69 26  05  2605  Master record missing. 
 70 26  06  2606  Master has detail records. Cannot delete or modify. 
 71 26  07  2607  Master table level is incorrect. 
 72 26  08  2608  Field value out of lookup table range. 
 73 26  09  2609  Lookup Table Open operation failed. 
 74 26  0A  260A  Detail Table Open operation failed. 
 75 26  0B  260B  Master Table Open operation failed. 
 76 26  0C  260C  Field is blank. 
 77 26  0D  260D  Link to master table already defined. 
 78 26  0E  260E  Master table is open. 
 79 26  0F  260F  Detail table(s) exist. 
 80 26  10  2610  Master has detail records. Cannot empty it. 
 81 26  11  2611  Self referencing referential integrity must be entered one at a time with no other changes to the table 
 82 26  12  2612  Detail table is open. 
 83 26  13  2613  Cannot make this master a detail of another table if its details are not empty. 
 84 26  14  2614  Referential integrity fields must be indexed. 
 85 26  15  2615  A table linked by referential integrity requires password to open. 
 86 26  16  2616  Field(s) linked to more than one master. 
Invalid Request
 87 27  01  2701  Number is out of range. 
 88 27  02  2702  Invalid parameter. 
 89 27  03  2703  Invalid file name. 
 90 27  04  2704  File does not exist. 
 91 27  05  2705  Invalid option. 
 92 27  06  2706  Invalid handle to the function. 
 93 27  07  2707  Unknown table type. 
 94 27  08  2708  Cannot open file. 
 95 27  09  2709  Cannot redefine primary key. 
 96 27  0A  270A  Cannot change this RINTDesc. 
 97 27  0B  270B  Foreign and primary key do not match. 
 98 27  0C  270C  Invalid modify request. 
 99 27  0D  270D  Index does not exist. 
100 27  0E  270E  Invalid offset into the BLOB. 
101 27  0F  270F  Invalid descriptor number. 
102 27  10  2710  Tipo di campo non valido 
103 27  11  2711  Invalid field descriptor. 
104 27  12  2712  Invalid field transformation. 
105 27  13  2713  Invalid record structure. 
106 27  14  2714  Invalid descriptor. 
107 27  15  2715  Invalid array of index descriptors. 
108 27  16  2716  Invalid array of validity check descriptors. 
109 27  17  2717  Invalid array of referential integrity descriptors. 
110 27  18  2718  Invalid ordering of tables during restructure. 
111 27  19  2719  Name not unique in this context. 
112 27  1A  271A  Index name required. 
113 27  1B  271B  Invalid session handle. 
114 27  1C  271C  invalid restructure operation. 
115 27  1D  271D  Driver not known to system. 
116 27  1E  271E  Unknown database. 
117 27  1F  271F  Invalid password given. 
118 27  20  2720  No callback function. 
119 27  21  2721  Invalid callback buffer length. 
120 27  22  2722  Invalid directory. 
121 27  23  2723  Translate Error. Value out of bounds. 
122 27  24  2724  Cannot set cursor of one table to another. 
123 27  25  2725  Bookmarks do not match table. 
124 27  26  2726  Invalid index/tag name. 
125 27  27  2727  Invalid index descriptor. 
126 27  28  2728  Table does not exist. 
127 27  29  2729  Table has too many users. 
128 27  2A  272A  Cannot evaluate Key or Key does not pass filter condition. 
129 27  2B  272B  Index already exists. 
130 27  2C  272C  Index is open. 
131 27  2D  272D  Invalid BLOB length. 
132 27  2E  272E  Invalid BLOB handle in record buffer. 
133 27  2F  272F  Table is open. 
134 27  30  2730  Need to do (hard) restructure. 
135 27  31  2731  Invalid mode. 
136 27  32  2732  Cannot close index. 
137 27  33  2733  Index is being used to order table. 
138 27  34  2734  Unknown user name or password. 
139 27  35  2735  Multi-level cascade is not supported. 
140 27  36  2736  Invalid field name. 
141 27  37  2737  Invalid table name. 
142 27  38  2738  Invalid linked cursor expression. 
143 27  39  2739  Name is reserved. 
144 27  3A  273A  Invalid file extension. 
145 27  3B  273B  Invalid language Driver. 
146 27  3C  273C  Alias is not currently opened. 
147 27  3D  273D  Incompatible record structures. 
148 27  3E  273E  Name is reserved by DOS. 
149 27  3F  273F  Destination must be indexed. 
150 27  40  2740  Invalid index type 
151 27  41  2741  Language Drivers of Table and Index do not match 
152 27  42  2742  Filter handle is invalid 
153 27  43  2743  Invalid Filter 
154 27  44  2744  Invalid table create request 
155 27  45  2745  Invalid table delete request 
156 27  46  2746  Invalid index create request 
157 27  47  2747  Invalid index delete request 
158 27  48  2748  Invalid table specified 
159 27  4A  274A  Invalid Time. 
160 27  4B  274B  Invalid Date. 
161 27  4C  274C  Invalid Datetime 
162 27  4D  274D  Tables in different directories 
163 27  4E  274E  Mismatch in the number of arguments 
164 27  4F  274F  Function not found in service library. 
165 27  50  2750  Must use baseorder for this operation. 
166 27  51  2751  Invalid procedure name 
167 27  52  2752  The field map is invalid. 
Locking/Contention related
168 28  01  2801  Record locked by another user. 
169 28  02  2802  Unlock failed. 
170 28  03  2803  Table is busy. 
171 28  04  2804  Directory is busy. 
172 28  052804 5  File is locked. 
173 28  062804 6  Directory is locked. 
174 28  072804 7  Record already locked by this session. 
175 28  08  2808  Object not locked. 
176 28  09  2809  Lock time out. 
177 28  0A  280A  Key group is locked. 
178 28  0B  280B  Table lock was lost. 
179 28  0C  280C  Exclusive access was lost. 
180 28  0D  280D  Table cannot be opened for exclusive use. 
181 28  0E  280E  Conflicting record lock in this session. 
182 28  0F  280F  A deadlock was detected. 
183 28  10  2810  A user transaction is already in progress. 
184 28  11  2811  No user transaction is currently in progress. 
185 28  12  2812  Record lock failed. 
186 28  13  2813  Couldn't perform the edit because another user changed the record. 
187 28  14  2814  Couldn't perform the edit because another user deleted or moved the record. 
Access Violation - Security related
188 29  01  2901  Insufficient field rights for operation. 
189 29  02  2902  Insufficient table rights for operation. Password required. 
190 29  03  2903  Insufficient family rights for operation. 
191 29  04  2904  This directory is read only. 
192 29  0528090528Database is read only. 
193 29  0628090628Trying to modify read-only field. 
194 29  0728090728Encrypted dBASE tables not supported. 
195 29  08  2908  Insufficient SQL rights for operation. 
Invalid context
196 2A  01  2A01  Field is not a BLOB. 
197 2A  02  2A02  BLOB already opened. 
198 2A  03  2A03  BLOB not opened. 
199 2A  04  2A04  Operation not applicable. 
200 2A  05280A0528Table is not indexed. 
201 2A  06280A06  Engine not initialized. 
202 2A  07280A0728Attempt to re-initialize Engine. 
203 2A  08280A0828Attempt to mix objects from different sessions. 
204 2A  09280A0928Paradox driver not active. 
205 2A  0A280A0A  Driver not loaded. 
206 2A  0B280A0B28Table is read only. 
207 2A  0C280A0C  No associated index. 
208 2A  0D280A0D  Table(s) open. Cannot perform this operation. 
209 2A  0E280A0E  Table does not support this operation. 
210 2A  0F280A0F  Index is read only. 
211 2A  10  2A10  Table does not support this operation because it is not uniquely indexed. 
212 2A  11  2A11  Operation must be performed on the current session. 
213 2A  12  2A12  Invalid use of keyword. 
214 2A  13  2A13  Connection is in use by another statement. 
215 2A  14  2A14  Passthrough SQL connection must be shared 
Os Error not handled by Idapi
216 2B  01  2B01  Invalid function number. 
217 2B  02  2B02  File or directory does not exist. 
218 2B  03  2B03  Path not found. 
219 2B  04  2B04  Too many open files. You may need to increase MAXFILEHANDLE limit in IDAPI configuration. 
220 2B  05280B0528Permission denied. 
221 2B  06280B0628Bad file number. 
222 2B  07280B07  Memory blocks destroyed. 
223 2B  08280B08  Not enough memory. 
224 2B  09280B09  Invalid memory block address. 
225 2B  0A280B0A  Invalid environment. 
226 2B  0B280B0B  Invalid format. 
227 2B  0C280B0C  Invalid access code. 
228 2B  0D280B0D  Invalid data. 
229 2B  0F280B0F  Device does not exist. 
230 2B  10  2B10  Attempt to remove current directory. 
231 2B  11  2B11  Not same device. 
232 2B  12  2B12  No more files. 
233 2B  13  2B13  Invalid argument. 
234 2B  14  2B14  Argument list is too long. 
235 2B  15  2B15  Execution format error. 
236 2B  16  2B16  Cross-device link. 
237 2B  21  2B21  Math argument. 
238 2B  22  2B22  Result is too large. 
239 2B  23  2B23  File already exists. 
240 2B  27  2B27  Unknown internal operating system error. 
241 2B  32  2B32  Share violation. 
242 2B  33  2B33  Lock violation. 
243 2B  34  2B34  Critical DOS Error. 
244 2B  35  2B35  Drive not ready. 
245 2B  64  2B64  Not exact read/write. 
246 2B  65  2B65  Operating system network error. 
247 2B  66  2B66  Error from NOVELL file server. 
248 2B  67  2B67  NOVELL server out of memory. 
249 2B  68280B6828Record already locked by this workstation. 
250 2B  69280B6928Record not locked. 
Network related
251 2C  01  2C01  Network initialization failed. 
252 2C  02  2C02  Network user limit exceeded. 
253 2C  03  2C03  Wrong .NET file version. 
254 2C  04  2C04  Cannot lock network file. 
255 2C  05280C0528Directory is not private. 
256 2C  06280C 6  Directory is controlled by other .NET file. 
257 2C  07280C 7  Unknown network error. 
258 2C  08280C08  Not initialized for accessing network files. 
259 2C  09280C09  SHARE not loaded. It is required to share local files. 
260 2C  0A280C0A28Not on a network.8Not logged in or wrong network driver. 
261 2C  0B280C0B  Lost communication with SQL server. 
262 2C  0D280C0D  Cannot locate or connect to SQL server. 
263 2C  0E280C0E  Cannot locate or connect to network server. 
Optional parameter related
264 2D  01  2D01  Optional parameter is required. 
265 2D  02  2D02  Invalid optional parameter. 
Query related
266 2E  01  2E01  obsolete 
267 2E  02  2E02  obsolete 
268 2E  03  2E03  Ambiguous use of ! (inclusion operator). 
269 2E  04  2E04  obsolete 
270 2E  05280E0528obsolete 
271 2E  06280E0628A SET operation cannot be included in its own grouping. 
272 2E  07280E0728Only numeric and date/time fields can be averaged. 
273 2E  08280E08  Invalid expression. 
274 2E  09280E09  Invalid OR expression. 
275 2E  0A280E0A28obsolete 
276 2E  0B280E0B28bitmap 
277 2E  0C280E0C28CALC expression cannot be used in INSERT, DELETE, CHANGETO and SET rows. 
278 2E  0D280E0D  Type error in CALC expression. 
279 2E  0E280E0E  CHANGETO can be used in only one query form at a time. 
280 2E  0F280E0F  Cannot modify CHANGED table. 
281 2E  10  2E10  A field can contain only one CHANGETO expression. 
282 2E  11  2E11  A field cannot contain more than one expression to be inserted. 
283 2E  12  2E12  obsolete 
284 2E  13  2E13  CHANGETO must be followed by the new value for the field. 
285 2E  14  2E14  Checkmark or CALC expressions cannot be used in FIND queries. 
286 2E  15  2E15  Cannot perform operation on CHANGED table together with a CHANGETO query. 
287 2E  16  2E16  chunk 
288 2E  17  2E17  More than 255 fields in ANSWER table. 
289 2E  18  2E18  AS must be followed by the name for the field in the ANSWER table. 
290 2E  19  2E19  DELETE can be used in only one query form at a time. 
291 2E  1A280E1A  Cannot perform operation on DELETED table together with a DELETE query. 
292 2E  1B280E1B  Cannot delete from the DELETED table. 
293 2E  1C280E1C28Example element is used in two fields with incompatible types or with a BLOB. 
294 2E  1D280E1D  Cannot use example elements in an OR expression. 
295 2E  1E280E1E28Expression in this field has the wrong type. 
296 2E  1F280E1F28Extra comma found. 
297 2E  20  2E20  Extra OR found. 
298 2E  21  2E21  One or more query rows do not contribute to the ANSWER. 
299 2E  22  2E22  FIND can be used in only one query form at a time. 
300 2E  23  2E23  FIND cannot be used with the ANSWER table. 
301 2E  24  2E24  A row with GROUPBY must contain SET operations. 
302 2E  25  2E25  GROUPBY can be used only in SET rows. 
303 2E  26  2E26  Use only INSERT, DELETE, SET or FIND in leftmost column. 
304 2E  27  2E27  Use only one INSERT, DELETE, SET or FIND per line. 
305 2E  28  2E28  Syntax error in expression. 
306 2E  29  2E29  INSERT can be used in only one query form at a time. 
307 2E  2A280E2A  Cannot perform operation on INSERTED table together with an INSERT query. 
308 2E  2B280E2B  INSERT, DELETE, CHANGETO and SET rows may not be checked. 
309 2E  2C280E2C  Field must contain an expression to insert (or be blank). 
310 2E  2D280E2D  Cannot insert into the INSERTED table. 
311 2E  2E  2E2E  Variable is an array and cannot be accessed. 
312 2E  2F280E2F28Label 
313 2E  30  2E30  Rows of example elements in CALC expression must be linked. 
314 2E  31  2E31  Variable name is too long. 
315 2E  32  2E32  Query may take a long time to process. 
316 2E  33  2E33  Reserved word or one that can't be used as a variable name. 
317 2E  34  2E34  Missing comma. 
318 2E  35  2E35  Missing ). 
319 2E  36  2E36  Missing right quote. 
320 2E  37  2E37  Cannot specify duplicate column names. 
321 2E  38  2E38  Query has no checked fields. 
322 2E  39  2E39  Example element has no defining occurrence. 
323 2E  3A280E3A28No grouping is defined for SET operation. 
324 2E  3B280E3B28Query makes no sense. 
325 2E  3C280E3C28Cannot use patterns in this context. 
326 2E  3D280E3D28Date does not exist. 
327 2E  3E  2E3E  Variable has not been assigned a value. 
328 2E  3F280E3F  Invalid use of example element in summary expression. 
329 2E  40  2E40  Incomplete query statement. Query only contains a SET definition. 
330 2E  41  2E41  Example element with ! makes no sense in expression. 
331 2E  42  2E42  Example element cannot be used more than twice with a ! query. 
332 2E  43  2E43  Row cannot contain expression. 
333 2E  44  2E44  obsolete 
334 2E  45  2E45  obsolete 
335 2E  46  2E46  No permission to insert or delete records. 
336 2E  47  2E47  No permission to modify field. 
337 2E  48  2E48  Field not found in table. 
338 2E  49  2E49  Expecting a column separator in table header. 
339 2E  4A280E4A28Expecting a column separator in table. 
340 2E  4B280E4B28Expecting column name in table. 
341 2E  4C280E4C28Expecting table name. 
342 2E  4D280E4D28Expecting consistent number of columns in all rows of table. 
343 2E  4E  2E4E  Cannot open table. 
344 2E  4F280E
Lockield appears more than once in table. 
345 2E  50  2E50  This DELETE, CHANGE or INSERT query has no ANSWER. 
346 2E  51  2E51  Query is not prepared. Properties unknown. 
347 2E  52  2E52  DELETE rows cannot contain quantifier expression. 
348 2E  53  2E53  Invalid expression in INSERT row. 
349 2E  54  2E54  Invalid expression in INSERT row. 
350 2E  55  2E55  Invalid expression in SET definition. 
351 2E  56  2E56  row use 
352 2E  57  2E57  SET keyword expected. 
353 2E  58  2E58  Ambiguous use of example element. 
354 2E  59  2E59  obsolete 
355 2E  5A280E5A  obsolete 
356 2E  5B280E5B28Only numeric fields can be summed. 
357 2E  5C280E5C28Table is write protected. 
358 2E  5D280E5D28Token not found. 
359 2E  5E  2E5E  Cannot use example element with ! more than once in a single row. 
360 2E  5F280E5F28Type mismatch in expression. 
361 2E  60  2E60  Query appears to ask two unrelated questions. 
362 2E  61  2E61  Unused SET row. 
363 2E  62  2E62  INSERT, DELETE, FIND, and SET can be used only in the leftmost column. 
364 2E  63  2E63  CHANGETO cannot be used with INSERT, DELETE, SET or FIND. 
365 2E  64  2E64  Expression must be followed by an example element defined in a SET. 
366 2E  65  2E65  Lock failure. 
367 2E  66  2E66  Expression is too long. 
368 2E  67  2E67  Refresh exception during query. 
369 2E  68280E68  Query canceled. 
370 2E  69280E6928Unexpected8Database Engine error. 
371 2E  6A280E6A  Not enough memory to finish operation. 
372 2E  6B280E6B28Unexpected8exception. 
373 2E  6C280E6C28Feature not implemented8yet in query. 
374 2E  6D280E6D28Query format is not supported. 
375 2E  6E  2E6E  Query string is empty. 
376 2E  6F280E6F28Attempted to prepare an empty query. 
377 2E  70  2E70  Buffer too small to contain query string. 
378 2E  71  2E71  Query was not previously parsed or prepared. 
379 2E  72  2E72  Function called with bad query handle. 
380 2E  73  2E73  QBE syntax error. 
381 2E  74  2E74  Query extended syntax field count error. 
382 2E  75  2E75  Field name in sort or field clause not found. 
383 2E  76  2E76  Table name in sort or field clause not found. 
384 2E  77  2E77  Operation is not supported on BLOB fields. 
385 2E  78280E7828General BLOB error. 
386 2E  79280E7928Query must be restarted. 
387 2E  7A280E7A28Unknown answer table type. 
388 2E  96  2E96  Blob cannot be used as grouping field. 
389 2E  97  2E97  Query properties have not been fetched. 
390 2E  98280E9828Answer table is of unsuitable type. 
391 2E  99280E9928Answer table is not yet supported under server alias. 
392 2E  9A280E9A  Non-null blob field required. Can't insert records 
393 2E  9B280E9B28Unique index required to perform changeto 
394 2E  9C280E9C28Unique index required to delete records 
395 2E  9D280E9D28Update of table on the server failed. 
396 2E  9E  2E9E  Can't process this query remotely. 
397 2E  9F280E9F28Unexpected8end of command. 
398 2E  A0  2EA0  Parameter not set in query string. 
399 2E  A1  2EA1  Query string is too long. 
400 2E  AA280EAA28No such table or correlation name. 
401 2E  AB280EAB  Expression has ambiguous data type. 
402 2E  AC280EAC  Field in order by must be in result set. 
403 2E  AD280EAD28General parsing error. 
404 2E  AE  2EAE  Record or field constraint failed. 
405 2E  AF280EAF  Field in group by must be in result set. 
406 2E  B0  2EB0  User defined function is not defined. 
407 2E  B1  2EB1  Unknown error from User defined function. 
408 2E  B2  2EB2  Single row subquery produced more than one row. 
409 2E  B3  2EB3  Expressions in group by are not supported. 
410 2E  B4  2EB4  Queries on text or ascii tables is not supported. 
411 2E  B5  2EB5  ANSI join keywords USING and NATURAL are not supported in this release. 
412 2E  B6  2EB6  SELECT DISTINCT may not be used with UNION unless UNION ALL is used. 
413 2E  B7  2EB7  GROUP BY is required when both aggregate and non-aggregate fields are used in result set. 
414 2E  B8280EB828INSERT and UPDATE operations are not supported on autoincrement field type. 
415 2E  B9280EB928UPDATE on Primary Key of a Master Table may modify more than one record. 
Version Mismatch Category
416 2F2801  2F01  Interface mismatch. Engine version different. 
417 2F2802  2F02  Index is out of date. 
418 2F  03  2F03  Older version (see context). 
419 2F  04  2F04  .VAL file is out of date. 
420 2F  05280F0528BLOB file version is too old. 
421 2F  06280F0628Query and Engine DLLs are mismatched. 
422 2F  07280F07  Server is incompatible version. 
423 2F  08280F0828Higher table level required 
Capability not supported
424 30  01  3001  Capability not supported. 
425 30  02  3002  Not implemented8yet. 
426 30  03  3003  SQL replicas not supported. 
427 30  04  3004  Non-blob column in table required to perform operation. 
428 30  05  3005  Multiple connections not supported. 
429 30  06  3006  Full dBASE expressions not supported. 
System configuration error
430 31  01  3101  Invalid database alias specification. 
431 31  02  3102  Unknown database type. 
432 31  03  3103  Corrupt system configuration file. 
433 31  04  3104  Network type unknown. 
434 31  05  310528Not on the network.8
435 31  06  3106  Invalid configuration parameter. 
Warning
436 32  01  3201  Object implicitly dropped. 
437 32  02  3202  Object may be truncated. 
438 32  03  3203  Object implicitly modified. 
439 32  04  3204  Should field constraints be checked? 
440 32  05  3205  Validity check field modified. 
441 32  06  3206  Table level changed. 
442 32  07  3207  Copy linked tables? 
443 32  09  3209  Object implicitly truncated. 
444 32  0A  320A  Validity check will not be enforced. 
445 32  0B  320B  Multiple records found, but only one was expected. 
446 32  0C  320C  Field will be trimmed, cannot put master records into PROBLEM table. 
Miscellaneous
447 33  01  3301  File already exists. 
448 33  02  3302  BLOB has been modified. 
449 33  03  330328General SQL error. 
450 33  04  3304  Table already exists. 
451 33  05  330528Paradox 1.0 tables are not supported. 
452 33  06  330628Update aborted. 
Compatibility related
453 34  01  3401  Different sort order. 
454 34  02  3402  Directory in use by earlier version of8Paradox. 
455 34  03  3403  Needs8Paradox 3.5-compatible language driver. 
Data Repository related
456 35  01  3501  Data Dictionary is corrupt 
457 35  02  3502  Data Dictionary Info Blob corrupted 
458 35  03  3503  Data Dictionary Schema is corrupt 
459 35  04  350428Attribute Type exists 
460 35  05  3505  Invalid Object Type 
461 35  06  3506  Invalid Relation Type 
462 35  07  3507  View already exists 
463 35  08  350828No such View exists 
464 35  09  3509  Invalid Record Constraint 
465 35  0A  350A  Object is in a Logical DB 
466 35  0B  350B  Dictionary already exists 
467 35  0C  350C  Dictionary does not exist 
468 35  0D  350D  Dictionary database does not exist 
469 35  0E  350E  Dictionary info is out of date - needs Refresh 
470 35  10  3510  Invalid Dictionary Name 
471 35  11  3511  Dependent Objects exist 
472 35  12  3512  Too many Relationships for this Object Type 
473 35  13  3513  Relationships to the Object exist 
474 35  14  3514  Dictionary Exchange File is corrupt 
475 35  15  3515  Dictionary Exchange File Version mismatch 
476 35  16  3516  Dictionary Object Type Mismatch 
477 35  17  3517  Object exists in Target Dictionary 
478 35  18  3518  Cannot access Data Dictionary 
479 35  19  3519  Cannot create Data Dictionary 
480 35  1A  351A  Cannot open Database 
Driver related
481 3E  01  3E01  Wrong driver name. 
482 3E  02  3E02  Wrong system version. 
483 3E  03  3E03  Wrong driver version. 
484 3E  04  3E04  Wrong driver type. 
485 3E  05  3E05  Cannot load driver. 
486 3E  06  3E06  Cannot load language driver. 
487 3E  07  3E07  Vendor initialization failed. 
488 3E  08  3E08  Your application is not enabled for use with this driver. 
