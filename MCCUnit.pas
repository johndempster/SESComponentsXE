unit MCCUnit;
// =================================
// Measurement Computer Corp Library
// =================================
// 13.11.17

interface

uses WinTypes,Dialogs, SysUtils, WinProcs, math, mmsystem, strutils, classes ;

const
    MaxDACChannels = 16 ;
    DefaultTimeOut = 2.0 ;

// Current Revision Number */
    CURRENTREVNUM =     6.5 ;

// System error code */
    NOERRORS =         0    ; // No error occurred */
    BADBOARD =         1    ; // Invalid board number specified */
    DEADDIGITALDEV =   2    ; // Digital I/O device is not responding  */
    DEADCOUNTERDEV =   3    ; // Counter I/O device is not responding */
    DEADDADEV =        4    ; // D/A is not responding */
    DEADADDEV =        5    ; // A/D is not responding */
    NOTDIGITALCONF =   6    ; // Specified board does not have digital I/O */
    NOTCOUNTERCONF =   7    ; // Specified board does not have a counter */
    NOTDACONF =        8    ; // Specified board is does not have D/A */
    NOTADCONF =        9    ; // Specified board does not have A/D */
    NOTMUXCONF       = 10   ; // Specified board does not have thermocouple inputs */
    BADPORTNUM       = 11   ; // Invalid port number specified */
    BADCOUNTERDEVNUM = 12   ; // Invalid counter device */
    BADDADEVNUM      = 13   ; // Invalid D/A device */
    BADSAMPLEMODE    = 14   ; // Invalid sampling mode option specified */
    BADINT           = 15   ; // Board configured for invalid interrupt level */
    BADADCHAN        = 16   ; // Invalid A/D channel Specified */
    BADCOUNT         = 17   ; // Invalid count specified */
    BADCNTRCONFIG    = 18   ; // invalid counter configuration specified */
    BADDAVAL         = 19   ; // Invalid D/A output value specified */
    BADDACHAN        = 20   ; // Invalid D/A channel specified */
    ALREADYACTIVE    = 22   ; // A background process is already in progress */
    PAGEOVERRUN		   = 23   ; // DMA transfer crossed page boundary, may have gaps in data */
    BADRATE          = 24   ; // Inavlid sampling rate specified */
    COMPATMODE       = 25   ; // Board switches set for "compatible" mode */
    TRIGSTATE        = 26   ; // Incorrect intial trigger state D0 must=TTL low) */
    ADSTATUSHUNG     = 27   ; // A/D is not responding */
    TOOFEW           = 28   ; // Too few samples before trigger occurred */
    OVERRUN          = 29   ; // Data lost due to overrun, rate too high */
    BADRANGE         = 30   ; // Invalid range specified */
    NOPROGGAIN       = 31   ; // Board does not have programmable gain */
    BADFILENAME      = 32   ; // Not a legal DOS filename */
    DISKISFULL       = 33   ; // Couldn't complete, disk is full */
    COMPATWARN       = 34   ; // Board is in compatible mode, so DMA will be used */
    BADPOINTER       = 35   ; // Invalid pointer (NULL) */
    TOOMANYGAINS     = 36   ; // Too many gains */
    RATEWARNING      = 37   ; // Rate may be too high for interrupt I/O */
    CONVERTDMA       = 38   ; // CONVERTDATA cannot be used with DMA I/O */
    DTCONNECTERR     = 39   ; // Board doesn't have DT Connect */
    FORECONTINUOUS   = 40   ; // CONTINUOUS can only be used with BACKGROUND */
    BADBOARDTYPE     = 41   ; // This function can not be used with this board */
    WRONGDIGCONFIG   = 42   ; // Digital I/O is configured incorrectly */
    NOTCONFIGURABLE  = 43   ; // Digital port is not configurable */
    BADPORTCONFIG    = 44   ; // Invalid port configuration specified */
    BADFIRSTPOINT    = 45   ; // First point argument is not valid */
    ENDOFFILE        = 46   ; // Attempted to read past end of file */
    NOT8254CTR       = 47   ; // This board does not have an 8254 counter */
    NOT9513CTR       = 48   ; // This board does not have a 9513 counter */
    BADTRIGTYPE      = 49   ; // Invalid trigger type */
    BADTRIGVALUE     = 50   ; // Invalid trigger value */
    BADOPTION        = 52   ; // Invalid option specified for this function */
    BADPRETRIGCOUNT  = 53   ; // Invalid pre-trigger count sepcified */
    BADDIVIDER       = 55   ; // Invalid fout divider value */
    BADSOURCE        = 56   ; // Invalid source value  */
    BADCOMPARE       = 57   ; // Invalid compare value */
    BADTIMEOFDAY     = 58   ; // Invalid time of day value */
    BADGATEINTERVAL  = 59   ; // Invalid gate interval value */
    BADGATECNTRL     = 60   ; // Invalid gate control value */
    BADCOUNTEREDGE   = 61   ; // Invalid counter edge value */
    BADSPCLGATE      = 62   ; // Invalid special gate value */
    BADRELOAD        = 63   ; // Invalid reload value */
    BADRECYCLEFLAG   = 64   ; // Invalid recycle flag value */
    BADBCDFLAG       = 65   ; // Invalid BCD flag value */
    BADDIRECTION     = 66   ; // Invalid count direction value */
    BADOUTCONTROL    = 67   ; // Invalid output control value */
    BADBITNUMBER     = 68   ; // Invalid bit number */
    NONEENABLED      = 69   ; // None of the counter channels are enabled */
    BADCTRCONTROL    = 70   ; // Element of control array not ENABLED/DISABLED */
    BADEXPCHAN       = 71   ; // Invalid EXP channel */
    WRONGADRANGE     = 72   ; // Wrong A/D range selected for cbtherm */
    OUTOFRANGE       = 73   ; // Temperature input is out of range */
    BADTEMPSCALE     = 74   ; // Invalid temperate scale */
    BADERRCODE       = 75   ; // Invalid error code specified */
    NOQUEUE          = 76   ; // Specified board does not have chan/gain queue */
    CONTINUOUSCOUNT  = 77   ; // CONTINUOUS can not be used with this count value */
    UNDERRUN         = 78   ; // D/A FIFO hit empty while doing output */
    BADMEMMODE       = 79   ; // Invalid memory mode specified */
    FREQOVERRUN      = 80   ; // Measured frequency too high for gating interval */
    NOCJCCHAN        = 81   ; // Board does not have CJC chan configured */
    BADCHIPNUM       = 82   ; // Invalid chip number used with cbC9513Init */
    DIGNOTENABLED    = 83   ; // Digital I/O not enabled */
    CONVERT16BITS    = 84   ; // CONVERT option not allowed with 16 bit A/D */
    NOMEMBOARD       = 85   ; // EXTMEMORY option requires memory board */
    DTACTIVE         = 86   ; // Memory I/O while DT Active */
    NOTMEMCONF       = 87   ; // Specified board is not a memory board */
    ODDCHAN          = 88   ; // First chan in queue can not be odd */
    CTRNOINIT        = 89   ; // Counter was not initialized */
    NOT8536CTR       = 90   ; // Specified counter is not an 8536 */
    FREERUNNING      = 91   ; // A/D sampling is not timed */
    INTERRUPTED      = 92   ; // Operation interrupted with CTRL-C */
    NOSELECTORS      = 93   ; // Selector could not be allocated */
    NOBURSTMODE      = 94   ; // Burst mode is not supported on this board */
    NOTWINDOWSFUNC   = 95   ; // This function not available in Windows lib */
    NOTSIMULCONF     = 96   ; // Not configured for simultaneous update */
    EVENODDMISMATCH  = 97   ; // Even channel in odd slot in the queue */
    M1RATEWARNING    = 98   ; // DAS16/M1 sample rate too fast */
    NOTRS485         = 99   ; // Board is not an RS-485 board */
    NOTDOSFUNC      = 100   ; // This function not avaliable in DOS */
    RANGEMISMATCH   = 101   ; // Unipolar and Bipolar can not be used together in A/D que */
    CLOCKTOOSLOW    = 102   ; // Sample rate too fast for clock jumper setting */
    BADCALFACTORS   = 103   ; // Cal factors were out of expected range of values */
    BADCONFIGTYPE   = 104   ; // Invalid configuration type information requested */
    BADCONFIGITEM   = 105   ; // Invalid configuration item specified */
    NOPCMCIABOARD   = 106   ; // Can't acces PCMCIA board */
    NOBACKGROUND    = 107   ; // Board does not support background I/O */
    STRINGTOOSHORT  = 108   ; // String passed to cbGetBoardName is to short */
    CONVERTEXTMEM   = 109   ; // Convert data option not allowed with external memory */
    BADEUADD              = 110   ; // e_ToEngUnits addition error */
    DAS16JRRATEWARNING    = 111   ; // use 10 MHz clock for rates > 125KHz */
    DAS08TOOLOWRATE       = 112   ; // DAS08 rate set too low for AInScan warning */
    AMBIGSENSORONGP       = 114   ; // more than one sensor type defined for EXP-GP */
    NOSENSORTYPEONGP      = 115   ; // no sensor type defined for EXP-GP */
    NOCONVERSIONNEEDED    = 116   ; // 12 bit board without chan tags - converted in ISR */
    NOEXTCONTINUOUS       = 117   ; // External memory cannot be used in CONTINUOUS mode */
    INVALIDPRETRIGCONVERT = 118   ; // cbAConvertPretrigData was called after failure in cbAPretrig */
    BADCTRREG             = 119   ; // bad arg to CLoad for 9513 */
    BADTRIGTHRESHOLD      = 120   ; // Invalid trigger threshold specified in cbSetTrigger */
    BADPCMSLOTREF         = 121   ; // No PCM card in specified slot */
    AMBIGPCMSLOTREF       = 122   ; // More than one MCC PCM card in slot */
    BADSENSORTYPE         = 123   ; // Bad sensor type selected in Instacal */
    DELBOARDNOTEXIST      = 124   ; // tried to delete board number which doesn't exist */
    NOBOARDNAMEFILE       = 125   ; // board name file not found */
    CFGFILENOTFOUND       = 126   ; // configuration file not found */
    NOVDDINSTALLED        = 127   ; // CBUL.386 device driver not installed */
    NOWINDOWSMEMORY       = 128   ; // No Windows memory available */
    OUTOFDOSMEMORY        = 129   ; // ISR data struct alloc failure */
    OBSOLETEOPTION        = 130   ; // Obsolete option for cbGetConfig/cbSetConfig */
    NOPCMREGKEY           = 131	  ; // No registry entry for this PCMCIA board */
    NOCBUL32SYS           = 132	  ; // CBUL32.SYS device driver is not loaded */
    NODMAMEMORY           = 133   ; // No DMA buffer available to device driver */
    IRQNOTAVAILABLE       = 134	  ; // IRQ in being used by another device */
    NOT7266CTR            = 135   ; // This board does not have an LS7266 counter */
    BADQUADRATURE         = 136   ; // Invalid quadrature specified */
    BADCOUNTMODE          = 137   ; // Invalid counting mode specified */
    BADENCODING           = 138   ; // Invalid data encoding specified */
    BADINDEXMODE          = 139   ; // Invalid index mode specified */
    BADINVERTINDEX        = 140   ; // Invalid invert index specified */
    BADFLAGPINS           = 141   ; // Invalid flag pins specified */
    NOCTRSTATUS           = 142	  ; // This board does not support cbCStatus() */
    NOGATEALLOWED         = 143	  ; // Gating and indexing not allowed simultaneously */
    NOINDEXALLOWED        = 144   ; // Indexing not allowed in non-quadratue mode */
    OPENCONNECTION        = 145   ; // Temperature input has open connection */
    BMCONTINUOUSCOUNT     = 146   ; // Count must be integer multiple of packetsize for recycle mode. */
    BADCALLBACKFUNC       = 147   ; // Invalid pointer to callback function passed as arg */
    MBUSINUSE             = 148   ; // MetraBus in use */
    MBUSNOCTLR            = 149   ; // MetraBus I/O card has no configured controller card */
    BADEVENTTYPE          = 150   ; // Invalid event type specified for this board. */
    ALREADYENABLED        = 151	  ; // An event handler has already been enabled for this event type */
    BADEVENTSIZE          = 152   ; // Invalid event count specified. */
    CANTINSTALLEVENT      = 153	  ; // Unable to install event handler */
    BADBUFFERSIZE         = 154   ; // Buffer is too small for operation */
    BADAIMODE             = 155   ; // Invalid analog input mode(RSE, NRSE, or DIFF) */
    BADSIGNAL             = 156   ; // Invalid signal type specified. */
    BADCONNECTION         = 157   ; // Invalid connection specified. */
    BADINDEX              = 158   ; // Invalid index specified, or reached end of internal connection list. */
    NOCONNECTION          = 159   ; // No connection is assigned to specified signal. */
    BADBURSTIOCOUNT       = 160   ; // Count cannot be greater than the FIFO size for BURSTIO mode. */
    DEADDEV               = 161   ; // Device has stopped responding. Please check connections. */

    INVALIDACCESS         = 163    ; // Invalid access or privilege for specified operation */
    UNAVAILABLE           = 164    ; // Device unavailable at time of request. Please repeat operation. */
    NOTREADY              = 165   ; // Device is not ready to send data. Please repeat operation. */
    BITUSEDFORALARM       = 169    ; // The specified bit is used for alarm. */
    PORTUSEDFORALARM      = 170    ; // One or more bits on the specified port are used for alarm. */
    PACEROVERRUN          = 171    ; // Pacer overrun, external clock rate too fast. */
    BADCHANTYPE           = 172    ; // Invalid channel type specified. */
    BADTRIGSENSE          = 173    ; // Invalid trigger sensitivity specified. */
    BADTRIGCHAN           = 174    ; // Invalid trigger channel specified. */
    BADTRIGLEVEL          = 175    ; // Invalid trigger level specified. */
    NOPRETRIGMODE         = 176    ; // Pre-trigger mode is not supported for the specified trigger type. */
    BADDEBOUNCETIME	      = 177    ; // Invalid debounce time specified. */
    BADDEBOUNCETRIGMODE   = 178    ; // Invalid debounce trigger mode specified. */
    BADMAPPEDCOUNTER      = 179    ; // Invalid mapped counter specified. */
    BADCOUNTERMODE        = 180    ; // This function can not be used with the current mode of the specified counter. */
    BADTCCHANMODE         = 181    ; // Single-Ended mode can not be used for temperature input. */
    BADFREQUENCY          = 182    ; // Invalid frequency specified. */
    BADEVENTPARAM         = 183    ; // Invalid event parameter specified. */
    NONETIFC              = 184		; // No interface devices were found with required PAN ID and/or RF Channel. */
    DEADNETIFC            = 185		; // The interface device(s) with required PAN ID and RF Channel has failed. Please check connection. */
    NOREMOTEACK           = 186		; // The remote device is not responding to commands and queries. Please check device. */
    INPUTTIMEOUT          = 187		; // The device acknowledged the operation, but has not completed before the timeout. */
    MISMATCHSETPOINTCOUNT	=188		; // Number of Setpoints not equal to number of channels with setpoint flag set */
    INVALIDSETPOINTLEVEL	 =189		; // Setpoint Level is outside channel range */
    INVALIDSETPOINTOUTPUTTYPE	= 190		; // Setpoint Output Type is invalid*/
    INVALIDSETPOINTOUTPUTVALUE  =191		; // Setpoint Output Value is outside channel range */
    INVALIDSETPOINTLIMITS	=192		; // Setpoint Comparison limit B greater than Limit A */
    STRINGTOOLONG			 =193	; // The string entered is too long for the operation and/or device. */
    INVALIDLOGIN				=194   ; // The account name and/or password entered is incorrect. */
    SESSIONINUSE				=	195	; // The device session is already in use. */
    NOEXTPOWER				=	196	; // External power is not connected. */
    BADDUTYCYCLE			=	197 ; // Invalid duty cycle specified. */
    BADINITIALDELAY			 = 199 ; // Invalid initial delay specified */
    NOTEDSSENSOR			=1000  ; // No TEDS sensor was detected on the specified channel. */
    INVALIDTEDSSENSOR		=	1001  ; // Connected TEDS sensor to the specified channel is not supported */
    CALIBRATIONFAILED		=	1002  ; // Calibration failed */
    BITUSEDFORTERMINALCOUNTSTATUS =  1003   ; // The specified bit is used for terminal count stauts. */
    PORTUSEDFORTERMINALCOUNTSTATUS  = 1004    ; // One or more bits on the specified port are used for terminal count stauts. */
    BADEXCITATION		 =		1005    ; // Invalid excitation specified */
    BADBRIDGETYPE		 =		1006    ; // Invalid bridge type specified */
    BADLOADVAL			 =		1007    ; // Invalid load value specified */
    BADTICKSIZE			 =		1008    ; // Invalid tick size specified */
    BTHCONNECTIONFAILED			=1013	; // Bluetooth connection failed */
    INVALIDBTHFRAME				=1014	; // Invalid Bluetooth frame */
   	BADTRIGEVENT				=1015	; // Invalid trigger event specified */
    NETCONNECTIONFAILED	 =		1016	; // Network connection failed */
    DATASOCKETCONNECTIONFAILED =	1017	; // Data socket connection failed */
    INVALIDNETFRAME	=			1018	; // Invalid Network frame */
    NETTIMEOUT					=1019	; // Network device did not respond within expected time */
    NETDEVNOTFOUND				=1020	; // Network device not found */
    INVALIDCONNECTIONCODE		=1021	; // Invalid connection code */
    CONNECTIONCODEIGNORED		=1022	; // Connection code ignored */
    NETDEVINUSE				 =	1023	; // Network device already in use */
    NETDEVINUSEBYANOTHERPROC =	1024	; // Network device already in use by another process */
    SOCKETDISCONNECTED =			1025	; // Socket Disconnected */
    BOARDNUMINUSE			 =    1026	; // Board Number already in use */
    DEVALREADYCREATED	 =		1027	; // Specified DAQ device already created */
    BOARDNOTEXIST			 =	1028    ; // Tried to release a board which doesn't exist */
    INVALIDNETHOST		 =		1029    ; // Invalid host specified */
    INVALIDNETPORT		 =		1030    ; // Invalid port specified */
    INVALIDIFC				 =	1031	; // Invalid interface specified */
    INVALIDAIINPUTMODE	=		1032	; // Invalid input mode specified */
    AIINPUTMODENOTCONFIGURABLE =	1033    ; // Input mode not configurable */
    INVALIDEXTPACEREDGE	=		1034	; // Invalid external pacer edge */
    CMREXCEEDED	=				1035	; // Common-mode voltage range exceeded */


    AIFUNCTION  =   1    ; // Analog Input Function    */
    AOFUNCTION  =   2    ; // Analog Output Function   */
    DIFUNCTION  =   3    ; // Digital Input Function   */
    DOFUNCTION  =   4    ; // Digital Output Function  */
    CTRFUNCTION  =  5    ; // Counter Function         */
    DAQIFUNCTION =  6    ; // Daq Input Function       */
    DAQOFUNCTION = 7    ; // Daq Output Function      */

// Calibration coefficient types */
    COARSE_GAIN  =   $01 ;
    COARSE_OFFSET =  $02 ;
    FINE_GAIN   =    $04 ;
    FINE_OFFSET =    $08 ;
    GAIN  =          COARSE_GAIN ;
    OFFSET =         COARSE_OFFSET ;

//*****************************************************************
//
//               **** ATTENTION ALL DEVELOPERS ****
//
// When adding error codes, first determine if these are errors
// that can be caused by the user or if they will never happen
// in normal operation unless there is a bug.
//
// Only if they are user error should you put them in the list
// above.  In that case be sure to give them a name that means
// something from the user's point of view - rather than from the
// programmer.  For example NO_VDD_INSTALLED rather than
// DEVICE_CALL_FAILED.
//
// Do not add any errors to the section above without getting
// agreement by the dept. so that all user header files and header
// files for other versions of the library can be updates together.
//
// If it's an internal error, then be sure to add it to the
// correct section below.
//
//*******************************************************************/

// Internal errors returned by 16 bit library */
    INTERNALERR         =    200   ; // 200-299 Internal library error  */
    CANT_LOCK_DMA_BUF   =    201   ; // DMA buffer could not be locked */
    DMA_IN_USE          =    202   ; // DMA already controlled by another VxD */
    BAD_MEM_HANDLE      =    203   ; // Invalid Windows memory handle */
    NO_ENHANCED_MODE    =    204   ; // Windows Enhance mode is not running */
    MEMBOARDPROGERROR   =    211   ; // Program error getting memory board source */

// Internal errors returned by 32 bit library */
    INTERNAL32_ERR       =   300   ; // 300-399 32 bit library internal errors */
    NO_MEMORY_FOR_BUFFER =   301   ; // 32 bit - default buffer allocation when no user buffer used with file */
    WIN95_CANNOT_SETUP_ISR_DATA =  302 ; // 32 bit - failure on INIT_ISR_DATA IOCTL call */
    WIN31_CANNOT_SETUP_ISR_DATA =  303 ; // 32 bit - failure on INIT_ISR_DATA IOCTL call */
    CFG_FILE_READ_FAILURE =  304   ; // 32 bit - error reading board configuration file */
    CFG_FILE_WRITE_FAILURE = 305   ; // 32 bit - error writing board configuration file */
    CREATE_BOARD_FAILURE =   306   ; // 32 bit - failed to create board */
    DEVELOPMENT_OPTION   =   307   ; // 32 bit - Config Option item used in development only */
    CFGFILE_CANT_OPEN    =   308   ; // 32 bit - cannot open configuration file. */
    CFGFILE_BAD_ID       =   309   ; // 32 bit - incorrect file id. */
    CFGFILE_BAD_REV      =   310   ; // 32 bit - incorrect file version. */
    CFGFILE_NOINSERT     =   311  ; //; */
    CFGFILE_NOREPLACE    =   312  ; //; */
    BIT_NOT_ZERO         =   313  ; //; */
    BIT_NOT_ONE          =   314  ; //; */
    BAD_CTRL_REG         =   315     ; // No control register at this location. */
    BAD_OUTP_REG         =   316     ; // No output register at this location. */
    BAD_RDBK_REG         =   317     ; // No read back register at this location. */
    NO_CTRL_REG          =   318     ; // No control register on this board. */
    NO_OUTP_REG          =   319     ; // No control register on this board. */
    NO_RDBK_REG          =   320     ; // No control register on this board. */
    CTRL_REG_FAIL        =   321     ; // internal ctrl reg test failed. */
    OUTP_REG_FAIL        =   322     ; // internal output reg test failed. */
    RDBK_REG_FAIL        =   323     ; // internal read back reg test failed. */
    FUNCTION_NOT_IMPLEMENTED = 324 ;
    BAD_RTD_CONVERSION    =  325     ; // Overflow in RTD calculation */
    NO_PCI_BIOS           =  326     ; // PCI BIOS not present in the PC */
    BAD_PCI_INDEX         =  327     ; // Invalid PCI board index passed to PCI BIOS */
    NO_PCI_BOARD		=	328		; // Specified PCI board not detected*/
    PCI_ASSIGN_FAILED	=	329		; // PCI resource assignment failed */
    PCI_NO_ADDRESS		=	330     ; // No PCI address returned */
    PCI_NO_IRQ			=	331		; // No PCI IRQ returned */
    CANT_INIT_ISR_INFO	=	332		; // IOCTL call failed on VDD_API_INIT_ISR_INFO */
    CANT_PASS_USER_BUFFER	= 333		; // IOCTL call failed on VDD_API_PASS_USER_BUFFER */
    CANT_INSTALL_INT	=	334		; // IOCTL call failed on VDD_API_INSTALL_INT */
    CANT_UNINSTALL_INT	=	335		; // IOCTL call failed on VDD_API_UNINSTALL_INT */
    CANT_START_DMA	    =    336		; // IOCTL call failed on VDD_API_START_DMA */
    CANT_GET_STATUS     =    337		; // IOCTL call failed on VDD_API_GET_STATUS */
    CANT_GET_PRINT_PORT	 =	338		; // IOCTL call failed on VDD_API_GET_PRINT_PORT */
    CANT_MAP_PCM_CIS	=	339		; // IOCTL call failed on VDD_API_MAP_PCM_CIS */
    CANT_GET_PCM_CFG   =     340     ; // IOCTL call failed on VDD_API_GET_PCM_CFG */
    CANT_GET_PCM_CCSR	 =	341		; // IOCTL call failed on VDD_API_GET_PCM_CCSR */
    CANT_GET_PCI_INFO	 =	342		; // IOCTL call failed on VDD_API_GET_PCI_INFO */
    NO_USB_BOARD			= 343		; // Specified USB board not detected*/
    NOMOREFILES		 =		344		; // No more files in the directory */
    BADFILENUMBER		=	345		; // Invalid file number */
    INVALIDSTRUCTSIZE	=	346		; // Invalid structure size */
    LOSSOFDATA			=	347		; // EOF marker not found, possible loss of data */
    INVALIDBINARYFILE	 =	348		; // File is not a valid MCC binary file */
    INVALIDDELIMITER	 =	349		; // Invlid delimiter specified for CSV file */
    NO_BTH_BOARD		=	350		; // Specified Bluetooth board not detected*/
    NO_NET_BOARD		=	351		; // Specified Network board not detected*/

// DOS errors are remapped by adding DOS_ERR_OFFSET to them */
    DOS_ERR_OFFSET   =   		500 ;

// These are the commonly occurring remapped DOS error codes */
    DOSBADFUNC       =  501 ;
    DOSFILENOTFOUND  =  502 ;
    DOSPATHNOTFOUND  =  503 ;
    DOSNOHANDLES     =  504 ;
    DOSACCESSDENIED  =  505 ;
    DOSINVALIDHANDLE =  506 ;
    DOSNOMEMORY      =  507 ;
    DOSBADDRIVE      =  515 ;
    DOSTOOMANYFILES  =  518 ;
    DOSWRITEPROTECT  =  519 ;
    DOSDRIVENOTREADY =  521 ;
    DOSSEEKERROR     =  525 ;
    DOSWRITEFAULT    =  529  ;
    DOSREADFAULT     =  530 ;
    DOSGENERALFAULT  =  531 ;

// Windows internal error codes */
    WIN_CANNOT_ENABLE_INT	=603 ;
    WIN_CANNOT_DISABLE_INT	=605 ;
   	WIN_CANT_PAGE_LOCK_BUFFER	=606 ;
    NO_PCM_CARD	 =		630 ;

// Maximum length of error string */
    ERRSTRLEN     =     256 ;

// Maximum length of board name */
    BOARDNAMELEN   =    64 ;

// Status values */
    IDLE          =   0 ;
    RUNNING       =   1 ;


// Option Flags */
    FOREGROUND     =  $0000    ; // Run in foreground, don't return till done */
    BACKGROUND     =  $0001    ; // Run in background, return immediately */

    SINGLEEXEC     =  $0000    ; // One execution */
    CONTINUOUS     =  $0002    ; // Run continuously until cbstop() called */

    TIMED          =  $0000    ; // Time conversions with internal clock */
    EXTCLOCK       =  $0004    ; // Time conversions with external clock */

    NOCONVERTDATA  =  $0000    ; // Return raw data */
    CONVERTDATA    =  $0008    ; // Return converted A/D data */

    NODTCONNECT    =  $0000    ; // Disable DT Connect */
    DTCONNECT      =  $0010    ; // Enable DT Connect */
    SCALEDATA      =  $0010    ; // Scale scan data to engineering units */

    DEFAULTIO      =  $0000    ; // Use whatever makes sense for board */
    SINGLEIO       =  $0020    ; // Interrupt per A/D conversion */
    DMAIO          =  $0040    ; // DMA transfer */
    BLOCKIO        =  $0060    ; // Interrupt per block of conversions */
    BURSTIO        =  $10000    ; // Transfer upon scan completion */
    RETRIGMODE     =  $20000    ; // Re-arm trigger upon acquiring trigger count samples */
    NONSTREAMEDIO  =  $040000    ; // Non-streamed D/A output */
    ADCCLOCKTRIG   =  $080000    ; // Output operation is triggered on ADC clock */
    ADCCLOCK       =  $100000    ; // Output operation is paced by ADC clock */
    HIGHRESRATE	   =  $200000	   ; // Use high resolution rate */
    SHUNTCAL	     =  $400000	   ; // Enable Shunt Calibration */

    BYTEXFER       =  $0000    ; // Digital IN/OUT a byte at a time */
    WORDXFER       =  $0100    ; // Digital IN/OUT a word at a time */
    DWORDXFER      =  $0200    ; // Digital IN/OUT a double word at a time */

    INDIVIDUAL     =  $0000    ; // Individual D/A output */
    SIMULTANEOUS   =  $0200    ; // Simultaneous D/A output */

    FILTER         =  $0000    ; // Filter thermocouple inputs */
    NOFILTER       =  $0400    ; // Disable filtering for thermocouple */

    NORMMEMORY     =  $0000    ; // Return data to data array */
    EXTMEMORY      =  $0800    ; // Send data to memory board ia DT-Connect */

    BURSTMODE      =  $1000    ; // Enable burst mode */

    NOTODINTS      =  $2000    ; // Disbale time-of-day interrupts */
    WAITFORNEWDATA  = $2000    ; // Wait for new data to become available */

    EXTTRIGGER     =  $4000     ; // A/D is triggered externally */

    NOCALIBRATEDATA  =$8000    ; // Return uncalibrated PCM data */
    CALIBRATEDATA    =$0000    ; // Return calibrated PCM A/D data */

    CTR16BIT	=	 $0000	   ; // Return 16-bit counter data */
    CTR32BIT	=	 $0100	   ; // Return 32-bit counter data */
    CTR48BIT	=	 $0200	   ; // Return 48-bit counter data */
    CTR64BIT	 =	 $0400	   ; // Return 64-bit counter data */
    NOCLEAR		=	 $0800	   ; // Disables clearing counters when scan starts */


    ENABLED    =      1 ;
    DISABLED   =      0 ;

    UPDATEIMMEDIATE  =0 ;
    UPDATEONCOMMAND  =1 ;

// Arguments that are used in a particular function call should be set
//   to NOTUSED */
    NOTUSED       =   -1 ;


// types of error reporting */
    DONTPRINT      =  0 ;
    PRINTWARNINGS  =  1 ;
    PRINTFATAL     =  2 ;
    PRINTALL       =  3 ;

// types of error handling */
    DONTSTOP       =  0 ;
    STOPFATAL      =  1 ;
    STOPALL        =  2 ;

// channel types           */
    ANALOG		 =	 0 ;     // Analog channel
    DIGITAL8	 =	 1 ;		// 8-bit digital port
    DIGITAL16	 =	 2 ;     // 16-bit digital port
    CTR16		 =	 3 ;     // 16-bit counter
    CTR32LOW	 =	 4 ;		// Lower 16-bits of 32-bit counter
    CTR32HIGH	 =	 5 ;		// Upper 16-bits of 32-bit counter
    CJC		 =	 6 ;     // CJC channel
    TC		 =	 7 ;     // Thermocouple channel
    ANALOG_SE	 =	 8 ;     // Analog channel, singel-ended mode
    ANALOG_DIFF	 =	 9 ;     // Analog channel, Differential mode
    SETPOINTSTATUS  = 	 10 ;    // Setpoint status channel
    CTRBANK0	 =	 11	;	// Bank 0 of counter
    CTRBANK1	 =	 12	;	// Bank 1 of counter
    CTRBANK2	 =	 13	;	// Bank 2 of counter
    CTRBANK3	 =	 14	;	// Bank 3 of counter
    PADZERO		 =	 15	;	// Dummy channel. Fills the corresponding data elements with zero
    DIGITAL		 =	 16 ;
    CTR			 =	 17 ;

// channel type flags*/
    SETPOINT_ENABLE = 	$100 ; // Enable setpoint detection

// setpoint flags*/
    SF_EQUAL_LIMITA			 =		$00 ;// Channel = LimitA value
   	SF_LESSTHAN_LIMITA	 =			$01 ;// Channel < LimitA value
    SF_INSIDE_LIMITS		 =		$02 ;// Channel Inside LimitA and LimitB (LimitA < Channel < LimitB)
    SF_GREATERTHAN_LIMITB	=		$03 ;// Channel > LimitB
    SF_OUTSIDE_LIMITS			=	$04 ;// Channel Outside LimitA and LimitB (LimitA < Channel or Channel > LimitB)
    SF_HYSTERESIS				=	$05 ;// Use As Hysteresis
   	SF_UPDATEON_TRUEONLY =			$00 ;// Latch output condition (output = output1 for duration of acquisition)
   	SF_UPDATEON_TRUEANDFALSE	=	$08 ;// Do not latch output condition (output = output1 when criteria met else output = output2)

// Setpoint output channels */
    SO_NONE	 =		0 ;// No Output
    SO_DIGITALPORT =	1; // Output to digital Port
    SO_FIRSTPORTC	=1; // Output to first PortC
   	SO_DAC0		=	2; // Output to DAC0
   	SO_DAC1		=	3; // Output to DAC1
    SO_DAC2		=	4; // Output to DAC2
    SO_DAC3		=	5; // Output to DAC3
    SO_TMR0		=	6; // Output to TMR0
    SO_TMR1		=	7; // Output to TMR1

// cbDaqSetTrigger trigger sources */
    TRIG_IMMEDIATE  =     0 ;
    TRIG_EXTTTL			= 1 ;
    TRIG_ANALOG_HW	=	 2 ;
    TRIG_ANALOG_SW	=	 3 ;
    TRIG_DIGPATTERN	=	 4 ;
    TRIG_COUNTER	 =	 5 ;
    TRIG_SCANCOUNT	=	 6 ;

// cbDaqSetTrigger trigger sensitivities */
    RISING_EDGE	=	0 ;
    FALLING_EDGE =   1 ;
    ABOVE_LEVEL	=	2 ;
    BELOW_LEVEL	 =	3 ;
    EQ_LEVEL	 =	4 ;
    NE_LEVEL	 =	5 ;
    HIGH_LEVEL =		6 ;
    LOW_LEVEL	 =	7 ;

// trigger events */
    START_EVENT	=	0 ;
    STOP_EVENT	=	1 ;

// settling time settings */
    SETTLE_DEFAULT =		0 ;
    SETTLE_1us	=	1 ;
    SETTLE_5us	=	2 ;
    SETTLE_10us	=	3 ;
    SETTLE_1ms	=	4 ;

// Types of digital input ports */
    DIGITALOUT   =    1 ;
    DIGITALIN    =    2 ;

// DT Modes for cbMemSetDTMode() */
    DTIN         =    0 ;
    DTOUT        =    2 ;

    FROMHERE     =   -1       ; // read/write from current position */
    GETFIRST     =   -2      ; // Get first item in list */
    GETNEXT      =   -3      ; // Get next item in list */

// Temperature scales */
    CELSIUS       =   0 ;
    FAHRENHEIT    =   1 ;
    KELVIN        =   2 ;
    VOLTS		 =	 4		; // special scale for DAS-TC boards */
    NOSCALE	 =		 5 ;

// Default option */
    DEFAULTOPTION	= $0000 ;


// Types of digital I/O Ports */
    AUXPORT       =   1 ;
    AUXPORT0      =   1 ;
    AUXPORT1      =   2 ;
    AUXPORT2      =   3 ;
    FIRSTPORTA    =   10;
    FIRSTPORTB    =   11 ;
    FIRSTPORTCL   =   12 ;
    FIRSTPORTC		= 12   ;
    FIRSTPORTCH   =   13 ;
    SECONDPORTA   =   14 ;
    SECONDPORTB   =   15 ;
    SECONDPORTCL  =   16 ;
    SECONDPORTCH  =   17 ;
    THIRDPORTA    =   18 ;
    THIRDPORTB    =   19 ;
    THIRDPORTCL   =   20 ;
    THIRDPORTCH   =   21 ;
    FOURTHPORTA   =   22 ;
    FOURTHPORTB   =   23 ;
    FOURTHPORTCL  =   24 ;
    FOURTHPORTCH  =   25 ;
    FIFTHPORTA    =   26 ;
    FIFTHPORTB    =   27 ;
    FIFTHPORTCL   =   28 ;
    FIFTHPORTCH   =   29 ;
    SIXTHPORTA    =   30 ;
    SIXTHPORTB    =   31 ;
    SIXTHPORTCL   =   32 ;
    SIXTHPORTCH   =   33 ;
    SEVENTHPORTA  =   34 ;
    SEVENTHPORTB  =    35;
    SEVENTHPORTCL  =  36 ;
    SEVENTHPORTCH  =  37 ;
    EIGHTHPORTA    =  38 ;
    EIGHTHPORTB    =  39 ;
    EIGHTHPORTCL   =  40 ;
    EIGHTHPORTCH   =  41 ;


// Analog input modes */
    DIFFERENTIAL    =    0 ;
    SINGLE_ENDED    =    1 ;
    GROUNDED	  =  16 ;


// Selectable analog input modes (PCI-6000 series) */
    RSE         =    $1000      ; // Referenced Single-Ended */
    NRSE        =    $2000      ; // Non-Referenced Single-Ended */
    DIFF        =    $4000      ; // Differential */


// Selectable A/D Ranges codes */
    BIP60VOLTS   =    20              ; // -60 to 60 Volts */
    BIP30VOLTS	 =	 23 ;
    BIP20VOLTS   =    15              ; // -20 to +20 Volts */
    BIP15VOLTS   =    21              ; // -15 to +15 Volts */
    BIP10VOLTS   =    1              ; // -10 to +10 Volts */
    BIP5VOLTS    =    0              ; // -5 to +5 Volts */
    BIP4VOLTS    =    16             ; // -4 to + 4 Volts */
    BIP2PT5VOLTS  =   2              ; // -2.5 to +2.5 Volts */
    BIP2VOLTS     =   14             ; // -2.0 to +2.0 Volts */
    BIP1PT25VOLTS =   3              ; // -1.25 to +1.25 Volts */
    BIP1VOLTS      =  4              ; // -1 to +1 Volts */
    BIPPT625VOLTS  =  5              ; // -.625 to +.625 Volts */
    BIPPT5VOLTS    =  6              ; // -.5 to +.5 Volts */
    BIPPT25VOLTS   =  12              ; // -0.25 to +0.25 Volts */
    BIPPT2VOLTS    =  13              ; // -0.2 to +0.2 Volts */
    BIPPT1VOLTS    =  7              ; // -.1 to +.1 Volts */
    BIPPT05VOLTS   =  8              ; // -.05 to +.05 Volts */
    BIPPT01VOLTS   =  9              ; // -.01 to +.01 Volts */
    BIPPT005VOLTS  =  10             ; // -.005 to +.005 Volts */
    BIP1PT67VOLTS  =  11             ; // -1.67 to +1.67 Volts */
    BIPPT312VOLTS  =  17				 ; // -0.312 to +0.312 Volts */
    BIPPT156VOLTS  =  18				 ; // -0.156 to +0.156 Volts */
    BIPPT125VOLTS  =  22				 ; // -0.125 to +0.125 Volts */
    BIPPT078VOLTS  =  19				 ; // -0.078 to +0.078 Volts */

    UNI10VOLTS     =  100            ; // 0 to 10 Volts*/
    UNI5VOLTS      =  101            ; // 0 to 5 Volts */
    UNI4VOLTS      =  114            ; // 0 to 4 Volts */
    UNI2PT5VOLTS   =  102            ; // 0 to 2.5 Volts */
    UNI2VOLTS      =  103            ; // 0 to 2 Volts */
    UNI1PT67VOLTS  =  109            ; // 0 to 1.67 Volts */
    UNI1PT25VOLTS  =  104            ; // 0 to 1.25 Volts */
    UNI1VOLTS      =  105            ; // 0 to 1 Volt */
    UNIPT5VOLTS    =  110            ; // 0 to .5 Volt */
    UNIPT25VOLTS   =  111            ; // 0 to 0.25 Volt */
    UNIPT2VOLTS    =  112            ; // 0 to .2 Volt */
    UNIPT1VOLTS    =  106            ; // 0 to .1 Volt */
    UNIPT05VOLTS   =  113            ; // 0 to .05 Volt */
    UNIPT02VOLTS   =  108            ; // 0 to .02 Volt*/
    UNIPT01VOLTS   =  107            ; // 0 to .01 Volt*/

    MA4TO20        =  200            ; // 4 to 20 ma */
    MA2TO10        =  201            ; // 2 to 10 ma */
    MA1TO5         =  202            ; // 1 to 5 ma */
    MAPT5TO2PT5    =  203            ; // .5 to 2.5 ma */
    MA0TO20        =  204            ; // 0 to 20 ma */
    BIPPT025AMPS   =  205            ; // -0.025 to 0.025 ma */

    UNIPOLAR	 =	 300 ;
    BIPOLAR		 =	 301 ;

    BIPPT025VOLTSPERVOLT =	400    ; // -0.025 to +0.025 V/V */

// Types of D/A    */
    ADDA1 =    0 ;
    ADDA2 =    1 ;

// 8536 counter output 1 control */
    NOTLINKED  =         0 ;
    GATECTR2   =         1 ;
    TRIGCTR2   =         2 ;
    INCTR2     =         3 ;

// 8536 trigger types */
     HW_START_TRIG =	0 ;
     HW_RETRIG     = 1 ;
   	 SW_START_TRIG =	2 ;

// Types of 8254 counter configurations */
    HIGHONLASTCOUNT =    0 ;
    ONESHOT         =    1 ;
    RATEGENERATOR   =    2 ;
    SQUAREWAVE      =    3 ;
    SOFTWARESTROBE  =    4 ;
    HARDWARESTROBE  =    5 ;

// Where to reload from for 9513 counters */
    LOADREG       =  0 ;
    LOADANDHOLDREG = 1 ;

// Counter recycle modes for 9513 and 8536 */
    ONETIME       =  0 ;
    RECYCLE       =  1 ;

// Direction of counting for 9513 counters */
    COUNTDOWN     =  0 ;
    COUNTUP       =  1 ;

// Types of count detection for 9513 counters */
    POSITIVEEDGE  =  0 ;
    NEGATIVEEDGE  =  1 ;

// Counter output control */
    ALWAYSLOW     =  0 ;       // 9513 */
    HIGHPULSEONTC =  1 ;       // 9513 and 8536 */
    TOGGLEONTC    =  2 ;       // 9513 and 8536 */
    DISCONNECTED  =  4 ;       // 9513 */
    LOWPULSEONTC  =  5 ;       // 9513 */
    HIGHUNTILTC   =  6 ;       // 8536 */

// 9513 Counter input sources */
    TCPREVCTR     =  0 ;
    CTRINPUT1     =  1 ;
    CTRINPUT2     =  2 ;
    CTRINPUT3     =  3 ;
    CTRINPUT4     =  4 ;
    CTRINPUT5     =  5 ;
    GATE1         =  6 ;
    GATE2         =  7 ;
    GATE3         =  8 ;
    GATE4         =  9 ;
    GATE5         =  10 ;
    FREQ1         =  11 ;
    FREQ2         =  12 ;
    FREQ3         =  13 ;
    FREQ4         =  14 ;
    FREQ5         =  15 ;
    CTRINPUT6     =  101 ;
    CTRINPUT7     =  102 ;
    CTRINPUT8     =  103 ;
    CTRINPUT9     =  104 ;
    CTRINPUT10    =  105 ;
    GATE6         =  106 ;
    GATE7         =  107 ;
    GATE8         =  108 ;
    GATE9         =  109 ;
    GATE10        =  110 ;
    FREQ6         =  111 ;
    FREQ7         =  112 ;
    FREQ8         =  113 ;
    FREQ9         =  114 ;
    FREQ10        =  115 ;
    CTRINPUT11    =   201;
    CTRINPUT12    =  202 ;
    CTRINPUT13    =  203 ;
    CTRINPUT14    =  204 ;
    CTRINPUT15    =  205 ;
    GATE11        =  206 ;
    GATE12        =  207 ;
    GATE13        =  208 ;
    GATE14        =  209 ;
    GATE15        =  210 ;
    FREQ11        =  211 ;
    FREQ12        =  212 ;
    FREQ13        =  213 ;
    FREQ14        =  214 ;
    FREQ15        =  215 ;
    CTRINPUT16    =  301 ;
    CTRINPUT17    =  302 ;
    CTRINPUT18    =  303 ;
    CTRINPUT19    =  304 ;
    CTRINPUT20    =  305 ;
    GATE16        =  306 ;
    GATE17        =  307 ;
    GATE18        =  308 ;
    GATE19        =  309 ;
    GATE20        =  310 ;
    FREQ16        =  311 ;
    FREQ17        =  312 ;
    FREQ18        =  313 ;
    FREQ19        =  314 ;
    FREQ20        =  315 ;

// Counter load registers */
    LOADREG0      =  0 ;
    LOADREG1      =  1 ;
    LOADREG2      =  2 ;
    LOADREG3      =  3 ;
    LOADREG4      =  4 ;
    LOADREG5      =  5 ;
    LOADREG6      =  6 ;
    LOADREG7      =  7 ;
    LOADREG8      =  8 ;
    LOADREG9      =  9 ;
    LOADREG10     =  10 ;
    LOADREG11     =  11 ;
    LOADREG12     =  12 ;
    LOADREG13     =  13 ;
    LOADREG14     =  14 ;
    LOADREG15     =  15 ;
    LOADREG16     =  16 ;
    LOADREG17     =  17 ;
    LOADREG18     =  18 ;
    LOADREG19     =  19 ;
    LOADREG20     =  20 ;

// 9513 Counter registers */
    HOLDREG1      =  101 ;
    HOLDREG2      =  102 ;
    HOLDREG3      =  103 ;
    HOLDREG4      =  104 ;
    HOLDREG5      =  105 ;
    HOLDREG6      =  106 ;
    HOLDREG7      =  107 ;
    HOLDREG8      =  108 ;
    HOLDREG9      =  109 ;
    HOLDREG10     =  110 ;
    HOLDREG11     =  111 ;
    HOLDREG12     =  112 ;
    HOLDREG13     =  113 ;
    HOLDREG14     =  114 ;
    HOLDREG15     =  115 ;
    HOLDREG16     =  116 ;
    HOLDREG17     =  117 ;
    HOLDREG18     =  118 ;
    HOLDREG19     =  119 ;
    HOLDREG20     =  120 ;

    ALARM1CHIP1   =  201 ;
    ALARM2CHIP1   =  202 ;
    ALARM1CHIP2   =  301 ;
    ALARM2CHIP2   =  302 ;
    ALARM1CHIP3   =  401 ;
    ALARM2CHIP3   =  402 ;
    ALARM1CHIP4   =  501 ;
    ALARM2CHIP4   =  502 ;


// LS7266 Counter registers */
    COUNT1       =   601 ;
    COUNT2       =   602 ;
    COUNT3       =   603 ;
    COUNT4       =   604 ;

    PRESET1      =   701 ;
    PRESET2      =   702 ;
    PRESET3      =   703 ;
    PRESET4      =   704 ;

    PRESCALER1   =   801 ;
    PRESCALER2   =   802 ;
    PRESCALER3   =   803 ;
    PRESCALER4   =   804 ;

    MINLIMITREG0  =      900 ;
    MINLIMITREG1  =      901 ;
    MINLIMITREG2  =      902 ;
    MINLIMITREG3  =      903 ;
    MINLIMITREG4  =      904 ;
    MINLIMITREG5  =      905 ;
    MINLIMITREG6  =      906 ;
    MINLIMITREG7  =      907 ;

    MAXLIMITREG0  =      1000 ;
    MAXLIMITREG1  =      1001 ;
    MAXLIMITREG2  =      1002 ;
    MAXLIMITREG3  =      1003 ;
    MAXLIMITREG4  =      1004 ;
    MAXLIMITREG5  =      1005 ;
    MAXLIMITREG6  =      1006 ;
    MAXLIMITREG7  =      1007 ;

    OUTPUTVAL0REG0 =		1100 ;
    OUTPUTVAL0REG1 =		1101 ;
    OUTPUTVAL0REG2 =		1102 ;
    OUTPUTVAL0REG3 =		1103 ;
    OUTPUTVAL0REG4 =		1104 ;
    OUTPUTVAL0REG5 =		1105 ;
    OUTPUTVAL0REG6 =		1106 ;
    OUTPUTVAL0REG7 =		1107 ;

    OUTPUTVAL1REG0 =		1200 ;
    OUTPUTVAL1REG1 =		1201 ;
    OUTPUTVAL1REG2 =		1202 ;
    OUTPUTVAL1REG3 =		1203 ;
    OUTPUTVAL1REG4 =		1204 ;
    OUTPUTVAL1REG5 =		1205 ;
    OUTPUTVAL1REG6 =		1206 ;
    OUTPUTVAL1REG7 =		1207 ;

// Counter Gate Control */
    NOGATE        =  0 ;
    AHLTCPREVCTR  =  1 ;
    AHLNEXTGATE   =  2 ;
    AHLPREVGATE   =  3 ;
    AHLGATE       =  4 ;
    ALLGATE       =  5 ;
    AHEGATE       =  6 ;
    ALEGATE       =  7 ;

// 7266 Counter Quadrature values */
    NO_QUAD      =   0 ;
    X1_QUAD      =   1 ;
    X2_QUAD      =   2 ;
    X4_QUAD      =   4 ;

// 7266 Counter Counting Modes */
    NORMAL_MODE   =  0 ;
    RANGE_LIMIT   =  1 ;
    NO_RECYCLE    =  2 ;
    MODULO_N      =  3 ;

// 7266 Counter encodings */
    BCD_ENCODING	=1 ;
    BINARY_ENCODING	=2 ;

// 7266 Counter Index Modes */
    INDEX_DISABLED  =0 ;
    LOAD_CTR        =1 ;
    LOAD_OUT_LATCH  =2 ;
    RESET_CTR       =3 ;

// 7266 Counter Flag Pins */
    CARRY_BORROW       =   1 ;
    COMPARE_BORROW     =   2 ;
    CARRYBORROW_UPDOWN  =  3 ;
    INDEX_ERROR         =  4 ;

// Counter status bits */
    C_UNDERFLOW =    $0001 ;
    C_OVERFLOW  =    $0002 ;
    C_COMPARE   =    $0004 ;
    C_SIGN      =    $0008 ;
    C_ERROR     =    $0010 ;
    C_UP_DOWN   =    $0020 ;
    C_INDEX     =    $0040 ;

// Scan counter mode constants */
    TOTALIZE	=$0000 ;
    CLEAR_ON_READ	=$0001 ;
    ROLLOVER	=$0000 ;
    STOP_AT_MAX	=$0002 ;
    DECREMENT_OFF	=$0000 ;
    DECREMENT_ON	=$0020 ;
    BIT_16		=$0000   ;
    BIT_32		=$0004   ;
    BIT_48		=$10000  ;
    GATING_OFF	=$0000 ;
    GATING_ON	=$0010   ;
    LATCH_ON_SOS	=$0000 ;
    LATCH_ON_MAP	=$0008 ;
    UPDOWN_OFF		=$0000 ;
    UPDOWN_ON		=$1000   ;
    RANGE_LIMIT_OFF =$0000 ;
    RANGE_LIMIT_ON  =$2000 ;
    NO_RECYCLE_OFF	=$0000 ;
    NO_RECYCLE_ON	=$4000   ;
    MODULO_N_OFF	=$0000   ;
    MODULO_N_ON		=$8000   ;
    COUNT_DOWN_OFF				=$00000 ;
    COUNT_DOWN_ON				=$10000   ;
    INVERT_GATE					=$20000   ;
    GATE_CONTROLS_DIR		=	$40000  ;
    GATE_CLEARS_CTR			=	$80000  ;
    GATE_TRIG_SRC			=	$100000   ;
    OUTPUT_ON				=	$200000     ;
    OUTPUT_INITIAL_STATE_LOW	=$000000 ;
    OUTPUT_INITIAL_STATE_HIGH	=$400000 ;

    PERIOD					=	$0200            ;
    PERIOD_MODE_X1			=	$0000        ;
    PERIOD_MODE_X10			=	$0001        ;
    PERIOD_MODE_X100		=	$0002        ;
    PERIOD_MODE_X1000		=	$0003        ;
    PERIOD_MODE_BIT_16	=		$0000      ;
    PERIOD_MODE_BIT_32	=		$0004      ;
    PERIOD_MODE_BIT_48	=		$10000     ;
    PERIOD_MODE_GATING_ON =		$0010    ;
    PERIOD_MODE_INVERT_GATE	=	$20000   ;

    PULSEWIDTH					=	$0300             ;
    PULSEWIDTH_MODE_BIT_16		=	$0000       ;
    PULSEWIDTH_MODE_BIT_32		=	$0004       ;
    PULSEWIDTH_MODE_BIT_48		=	$10000      ;
    PULSEWIDTH_MODE_GATING_ON	 =	$0010     ;
    PULSEWIDTH_MODE_INVERT_GATE	 =	$20000  ;

    TIMING					=	$0400                 ;
    TIMING_MODE_BIT_16		=	$0000           ;
    TIMING_MODE_BIT_32		=	$0004           ;
    TIMING_MODE_BIT_48		=	$10000          ;
    TIMING_MODE_INVERT_GATE	 =	$20000      ;

    ENCODER						=	$0500               ;
    ENCODER_MODE_X1			 =		$0000         ;
    ENCODER_MODE_X2			 =		$0001         ;
    ENCODER_MODE_X4			 =		$0002         ;
    ENCODER_MODE_BIT_16	 =			$0000       ;
    ENCODER_MODE_BIT_32	 =			$0004       ;
    ENCODER_MODE_BIT_48	 =			$10000      ;
    ENCODER_MODE_LATCH_ON_Z	 =		$0008     ;
    ENCODER_MODE_CLEAR_ON_Z_OFF	 =	$0000   ;
    ENCODER_MODE_CLEAR_ON_Z_ON	 =	$0020   ;
    ENCODER_MODE_RANGE_LIMIT_OFF	=$0000    ;
    ENCODER_MODE_RANGE_LIMIT_ON	 =	$2000   ;
    ENCODER_MODE_NO_RECYCLE_OFF		=$0000     ;
    ENCODER_MODE_NO_RECYCLE_ON		=$4000    ;
    ENCODER_MODE_MODULO_N_OFF		=$0000      ;
    ENCODER_MODE_MODULO_N_ON		=$8000      ;

// deprecated encoder mode constants, use preferred constants above.
    LATCH_ON_Z	=	$0008     ;
    CLEAR_ON_Z_OFF =	$0000 ;
    CLEAR_ON_Z_ON	=$0020    ;


// 25xx series counter debounce time constants */
    CTR_DEBOUNCE500ns   =   0 ;
    CTR_DEBOUNCE1500ns  =   1 ;
    CTR_DEBOUNCE3500ns  =   2 ;
    CTR_DEBOUNCE7500ns  =   3 ;
    CTR_DEBOUNCE15500ns  =  4 ;
    CTR_DEBOUNCE31500ns  =  5 ;
    CTR_DEBOUNCE63500ns  =  6 ;
    CTR_DEBOUNCE127500ns =  7 ;
    CTR_DEBOUNCE100us    =  8 ;
    CTR_DEBOUNCE300us    =  9 ;
    CTR_DEBOUNCE700us    =  10 ;
    CTR_DEBOUNCE1500us   =  11 ;
    CTR_DEBOUNCE3100us   =  12 ;
    CTR_DEBOUNCE6300us   =  13 ;
    CTR_DEBOUNCE12700us  =  14 ;
    CTR_DEBOUNCE25500us  =  15 ;
    CTR_DEBOUNCE_NONE    =  16 ;

// 25xx series counter debounce trigger constants */
    CTR_TRIGGER_AFTER_STABLE  =  0 ;
    CTR_TRIGGER_BEFORE_STABLE =  1 ;

// 25xx series counter edge detection constants */
    CTR_RISING_EDGE       =  0 ;
    CTR_FALLING_EDGE      =  1 ;

// 25xx series counter tick size constants */
    CTR_TICK20PT83ns      =  0 ;
    CTR_TICK208PT3ns      =  1 ;
    CTR_TICK2083PT3ns     =  2 ;
    CTR_TICK20833PT3ns    =  3 ;

    CTR_TICK20ns      =  10 ;
    CTR_TICK200ns     =  11 ;
    CTR_TICK2000ns    =  12 ;
    CTR_TICK20000ns   =  13 ;

// Types of triggers */
    TRIGABOVE         =  0    ;
    TRIGBELOW         =  1    ;
    GATE_NEG_HYS      =  2    ;
    GATE_POS_HYS      =  3    ;
    GATE_ABOVE        =  4    ;
    GATE_BELOW        =  5    ;
    GATE_IN_WINDOW    =  6    ;
    GATE_OUT_WINDOW   =  7    ;
    GATE_HIGH         =  8    ;
    GATE_LOW          =  9    ;
    TRIG_HIGH         =  10   ;
    TRIG_LOW          =  11   ;
    TRIG_POS_EDGE     =  12   ;
    TRIG_NEG_EDGE     =  13   ;
    TRIG_RISING		=	14        ;
    TRIG_FALLING	=	15        ;
    TRIG_PATTERN_EQ	 = 	16    ;
    TRIG_PATTERN_NE	 =	 17   ;
    TRIG_PATTERN_ABOVE	= 18  ;
    TRIG_PATTERN_BELOW	= 19  ;

// External Pacer Edge */
    EXT_PACER_EDGE_RISING	=1     ;
    EXT_PACER_EDGE_FALLING	=2   ;

// Timer idle state */
    IDLE_LOW			=0  ;
    IDLE_HIGH			=1  ;

// Signal I/O Configuration Parameters */
// --Connections */
    AUXIN0      =    $01     ;
    AUXIN1      =    $02     ;
    AUXIN2      =    $04     ;
    AUXIN3      =    $08     ;
    AUXIN4      =    $10     ;
    AUXIN5      =    $20     ;
    AUXOUT0     =    $0100   ;
    AUXOUT1     =    $0200   ;
    AUXOUT2     =    $0400   ;

    DS_CONNECTOR =   $01000  ;

    MAX_CONNECTIONS =4     ; // maximum number connections per output signal type */


// --Signal Types */
    ADC_CONVERT   =  $0001  ;
    ADC_GATE      =  $0002  ;
    ADC_START_TRIG = $0004  ;
    ADC_STOP_TRIG =  $0008  ;
    ADC_TB_SRC    =  $0010  ;
    ADC_SCANCLK   =  $0020  ;
    ADC_SSH       =  $0040  ;
    ADC_STARTSCAN  = $0080  ;
    ADC_SCAN_STOP  = $0100  ;

    DAC_UPDATE     = $0200  ;
    DAC_TB_SRC     = $0400  ;
    DAC_START_TRIG = $0800  ;

    SYNC_CLK       = $1000  ;

    CTR1_CLK       = $2000  ;
    CTR2_CLK       = $4000  ;

    DGND         = $8000 ;

// -- Signal Direction */
    SIGNAL_IN     =  2    ;
    SIGNAL_OUT    =  4    ;

// -- Signal Polarity */
    INVERTED      =  1     ;
    NONINVERTED   =  0     ;


// Types of configuration information */
    GLOBALINFO     =    1   ;
    BOARDINFO      =    2   ;
    DIGITALINFO    =    3   ;
    COUNTERINFO    =    4   ;
    EXPANSIONINFO  =    5   ;
    MISCINFO       =    6   ;
    EXPINFOARRAY	 =  7     ;
    MEMINFO         =  8    ;

// Types of global configuration information */
    GIVERSION        =  36      ; // Config file format version number */
    GINUMBOARDS      =  38      ; // Maximum number of boards */
    GINUMEXPBOARDS   =  40      ; // Maximum number of expansion boards */

// Types of board configuration information */
    BIBASEADR         =  0       ; // Base Address */
    BIBOARDTYPE       =  1       ; // Board Type ($101 - $7FFF) */
    BIINTLEVEL        =  2       ; // Interrupt level */
    BIDMACHAN         =  3       ; // DMA channel */
    BIINITIALIZED     =  4       ; // TRUE or FALSE */
    BICLOCK           =  5       ; // Clock freq (1, 10 or bus) */
    BIRANGE           =  6       ; // Switch selectable range */
    BINUMADCHANS      =  7       ; // Number of A/D channels */
    BIUSESEXPS        =  8       ; // Supports expansion boards TRUE/FALSE */
    BIDINUMDEVS       =  9       ; // Number of digital devices */
    BIDIDEVNUM        =  10      ; // Index into digital information */
    BICINUMDEVS       =  11      ; // Number of counter devices */
    BICIDEVNUM        =  12      ; // Index into counter information */
    BINUMDACHANS      =  13      ; // Number of D/A channels */
    BIWAITSTATE       =  14      ; // Wait state enabled TRUE/FALSE */
    BINUMIOPORTS      =  15      ; // I/O address space used by board */
    BIPARENTBOARD     =  16      ; // Board number of parent board */
    BIDTBOARD         =  17      ; // Board number of connected DT board */
    BINUMEXPS         =  18      ; // Number of EXP boards installed */

// NEW CONFIG ITEMS for 32 bit library */
    BINOITEM           =  99      ; // NO-OP return no data and returns DEVELOPMENT_OPTION error code */
    BIDACSAMPLEHOLD    =  100     ; // DAC sample and hold jumper state */
    BIDIOENABLE        =  101     ; // DIO enable */
    BI330OPMODE        =  102     ; // DAS16-330 operation mode (ENHANCED/COMPATIBLE) */
    BI9513CHIPNSRC     =  103     ; // 9513 HD CTR source (DevNo = ctr no.)*/
    BICTR0SRC          =  104     ; // CTR 0 source */
    BICTR1SRC          =  105     ; // CTR 1 source */
    BICTR2SRC          =  106     ; // CTR 2 source */
    BIPACERCTR0SRC     =  107     ; // Pacer CTR 0 source */
    BIDAC0VREF         =  108     ; // DAC 0 voltage reference */
    BIDAC1VREF         =  109     ; // DAC 1 voltage reference */
    BIINTP2LEVEL       =  110     ; // P2 interrupt for CTR10 and CTR20HD */
    BIWAITSTATEP2      =  111     ; // Wait state 2 */
    BIADPOLARITY       =  112     ; // DAS1600 Polarity state(UNI/BI) */
    BITRIGEDGE         =  113     ; // DAS1600 trigger edge(RISING/FALLING) */
    BIDACRANGE         =  114     ; // DAC Range (DevNo is channel) */
    BIDACUPDATE        =  115     ; // DAC Update (INDIVIDUAL/SIMULTANEOUS) (DevNo) */
    BIDACINSTALLED     =  116     ; // DAC Installed */
    BIADCFG            =  117     ; // AD Config (SE/DIFF) (DevNo) */
    BIADINPUTMODE      =  118     ; // AD Input Mode (Voltage/Current) */
    BIDACPOLARITY      =  119     ; // DAC Startup state (UNI/BI) */
    BITEMPMODE         =  120     ; // DAS-TEMP Mode (NORMAL/CALIBRATE) */
    BITEMPREJFREQ      =  121     ; // DAS-TEMP reject frequency */
    BIDISOFILTER       =  122     ; // DISO48 line filter (EN/DIS) (DevNo) */
    BIINT32SRC         =  123     ; // INT32 Intr Src */
    BIINT32PRIORITY    =  124     ; // INT32 Intr Priority */
    BIMEMSIZE          =  125     ; // MEGA-FIFO module size */
    BIMEMCOUNT         =  126     ; // MEGA-FIFO # of modules */
    BIPRNPORT          =  127     ; // PPIO series printer port */
    BIPRNDELAY         =  128     ; // PPIO series printer port delay */
    BIPPIODIO           = 129     ; // PPIO digital line I/O state */
    BICTR3SRC           = 130     ; // CTR 3 source */
    BICTR4SRC           = 131     ; // CTR 4 source */
    BICTR5SRC           = 132     ; // CTR 5 source */
    BICTRINTSRC         = 133     ; // PCM-D24/CTR3 interrupt source */
    BICTRLINKING        = 134     ; // PCM-D24/CTR3 ctr linking */
    BISBX0BOARDNUM      = 135     ; // SBX #0 board number */
    BISBX0ADDRESS       = 136     ; // SBX #0 address */
    BISBX0DMACHAN       = 137     ; // SBX #0 DMA channel */
    BISBX0INTLEVEL0     = 138     ; // SBX #0 Int Level 0 */
    BISBX0INTLEVEL1     = 139     ; // SBX #0 Int Level 1 */
    BISBX1BOARDNUM      = 140     ; // SBX #0 board number */
    BISBX1ADDRESS       = 141     ; // SBX #0 address */
    BISBX1DMACHAN       = 142     ; // SBX #0 DMA channel */
    BISBX1INTLEVEL0     = 143     ; // SBX #0 Int Level 0 */
    BISBX1INTLEVEL1     = 144     ; // SBX #0 Int Level 1 */
    BISBXBUSWIDTH       = 145     ; // SBX Bus width */
    BICALFACTOR1        = 146     ; // DAS08/Jr Cal factor */
    BICALFACTOR2        = 147     ; // DAS08/Jr Cal factor */
    BIDACTRIG           = 148     ; // PCI-DAS1602 Dac trig edge */
    BICHANCFG           = 149     ; // 801/802 chan config (devno =ch) */
    BIPROTOCOL          = 150     ; // 422 protocol */
    BICOMADDR2          = 151     ; // dual 422 2nd address */
    BICTSRTS1           = 152     ; // dual 422 cts/rts1 */
    BICTSRTS2           = 153     ; // dual 422 cts/rts2 */
    BICTRLLINES         = 154     ; // pcm com 422 ctrl lines */
    BIWAITSTATEP1       = 155     ; // Wait state P1 */
    BIINTP1LEVEL        = 156     ; // P1 interrupt for CTR10 and CTR20HD */
    BICTR6SRC           = 157     ; // CTR 6 source */
    BICTR7SRC           = 158     ; // CTR 7 source */
    BICTR8SRC           = 159     ; // CTR 8 source */
    BICTR9SRC           = 160     ; // CTR 9 source */
    BICTR10SRC          = 161     ; // CTR 10 source */
    BICTR11SRC          = 162     ; // CTR 11 source */
    BICTR12SRC          = 163     ; // CTR 12 source */
    BICTR13SRC          = 164     ; // CTR 13 source */
    BICTR14SRC          = 165     ; // CTR 14 source */
    BITCGLOBALAVG		=  166	 ; // DASTC global average */
    BITCCJCSTATE		=     167	 ; // DASTC CJC State(=ON or OFF) */
    BITCCHANRANGE		=  168	 ; // DASTC Channel Gain */
    BITCCHANTYPE	 =	     169	 ; // DASTC Channel thermocouple type */
    BITCFWVERSION		=  170	 ; // DASTC Firmware Version */
    BIFWVERSION     =     BITCFWVERSION ; // Firmware Version */
    BIPHACFG        =     180     ; // Quad PhaseA config (devNo =ch) */
    BIPHBCFG        =     190     ; // Quad PhaseB config (devNo =ch) */
    BIINDEXCFG      =     200     ; // Quad Index Ref config (devNo =ch) */
    BISLOTNUM       =     201     ; // PCI/PCM card slot number */
    BIAIWAVETYPE    =     202     ; // analog input wave type (for demo board) */
    BIPWRUPSTATE    =     203     ; // DDA06 pwr up state jumper */
    BIIRQCONNECT    =     204     ; // DAS08 pin6 to 24 jumper */
    BITRIGPOLARITY	=	  205 	 ; // PCM DAS16xx Trig Polarity */
    BICTLRNUM       =     206     ; // MetraBus controller board number */
    BIPWRJMPR       =     207     ; // MetraBus controller board Pwr jumper */
    BINUMTEMPCHANS  =     208     ; // Number of Temperature channels */
    BIADTRIGSRC     =     209     ; // A/D trigger source */
    BIBNCSRC        =     210     ; // BNC source */
    BIBNCTHRESHOLD  =     211     ; // BNC Threshold 2.5V or 0.0V */
    BIBURSTMODE     =     212     ; // Board supports BURSTMODE */
    BIDITHERON      =     213     ; // A/D Dithering enabled */
    BISERIALNUM     =     214    ; // Serial Number for USB boards */
    BIDACUPDATEMODE  =    215    ; // Update immediately or upon AOUPDATE command */
    BIDACUPDATECMD   =    216    ; // Issue D/A UPDATE command */
    BIDACSTARTUP     =    217    ; // Store last value written for startup */
    BIADTRIGCOUNT    =    219    ; // Number of samples to acquire per trigger in retrigger mode */
    BIADFIFOSIZE     =    220    ; // Set FIFO override size for retrigger mode */
    BIADSOURCE       =    221    ; // Set source to internal reference or external connector(-1) */
    BICALOUTPUT      =    222    ; // CAL output pin setting */
    BISRCADPACER     =    223    ; // Source A/D Pacer output */
    BIMFGSERIALNUM   =    224    ; // Manufacturers 8-byte serial number */
    BIPCIREVID       =    225    ; // Revision Number stored in PCI header */
    BIEXTCLKTYPE      =   227  ;
    BIDIALARMMASK     =   230  ;

    BINETIOTIMEOUT    =   247  ;
    BIADCHANAIMODE		= 249    ;
    BIDACFORCESENSE		= 250    ;

    BISYNCMODE        =   251    ; // Sync mode */

    BICALTABLETYPE     =  254    ;
    BIDIDEBOUNCESTATE  =  255    ; // Digital inputs reset state */
    BIDIDEBOUNCETIME   =  256      ; // Digital inputs debounce Time */

    BIPANID             =  258    ;
    BIRFCHANNEL         =  259    ;

    BIRSS               =  261    ;
    BINODEID            =  262    ;
    BIDEVNOTES          = 263     ;
    BIINTEDGE			      = 265     ;

    BIADCSETTLETIME	 =	  270     ;

    BIFACTORYID      =     272    ;
    BIHTTPPORT			 = 273        ;
    BIHIDELOGINDLG	 =	  274     ;
    BITEMPSCALE      =     280    ;
    BIDACTRIGCOUNT	 =	  284	; // Number of samples to generate per trigger in retrigger mode */
    BIADTIMINGMODE	 =	  285      ;
    BIRTDCHANTYPE		 = 286        ;

    BIADRES				=  291          ;
    BIDACRES			=  292          ;

    BIADXFERMODE		=  306        ;
    BICTRTRIGCOUNT	 =	  307     ;
    BIDAQITRIGCOUNT	 =	  308     ;
    BINETCONNECTCODE =	  341     ;
    BIDITRIGCOUNT     =    343    ; // Number of digital input samples to acquire per trigger */
    BIDOTRIGCOUNT     =    344    ; // Number of digital output samples to generate per trigger */
    BIPATTERNTRIGPORT	 = 345      ;
    BICHANTCTYPE		 = 347	   ; // Channel thermocouple type */
    BIEXTINPACEREDGE	=  348      ;
    BIEXTOUTPACEREDGE	 = 349      ;
    BIINPUTPACEROUT	    =  350		; // Enable/Disable input Pacer output */
    BIOUTPUTPACEROUT	=  351		; // Enable/Disable output Pacer output */
    BITEMPAVG			=  352          ;
    BIEXCITATION	     = 353      ;
    BICHANBRIDGETYPE	 = 354      ;
    BIADCHANTYPE		=  355        ;
    BICHANRTDTYPE		=  356        ;
    BIDEVUNIQUEID		=  357		; // Unique identifier of DAQ device */
    BIUSERDEVID			=  358        ;
    BIDEVVERSION		=  359        ;
    BITERMCOUNTSTATBIT	=  360    ;
    BIDETECTOPENTC		=  361      ;
    BIADDATARATE		 = 362        ;
    BIDEVSERIALNUM		=  363      ;
    BIDEVMACADDR		 = 364        ;
    BIUSERDEVIDNUM		 = 365      ;
    BIADAIMODE			 = 373        ;


// Type of digital device information */
    DIBASEADR        =   0       ; // Base address */
    DIINITIALIZED    =   1       ; // TRUE or FALSE */
    DIDEVTYPE        =   2       ; // AUXPORT or xPORTA - CH */
    DIMASK           =   3       ; // Bit mask for this port */
    DIREADWRITE      =   4       ; // Read required before write */
    DICONFIG         =   5      ; // Current configuration */
    DINUMBITS        =   6      ; // Number of bits in port */
    DICURVAL         =   7      ; // Current value of outputs */
    DIINMASK         =   8      ; // Input bit mask for port */
    DIOUTMASK        =   9      ; // Output bit mask for port */
    DIDISABLEDIRCHECK	= 13	   ; // Disables checking port/bit direction in cbDOut and cbDBitOut functions */

// Types of counter device information */
     CIBASEADR       =    0       ; // Base address */
    CIINITIALIZED   =    1       ; // TRUE or FALSE */
    CICTRTYPE       =    2       ; // Counter type 8254, 9513 or 8536 */
    CICTRNUM        =    3       ; // Which counter on chip */
    CICONFIGBYTE    =    4       ; // Configuration byte */

// Types of expansion board information */
    XIBOARDTYPE       =  0       ; // Board type */
    XIMUX_AD_CHAN1    =  1       ; // 0 - 7 */
    XIMUX_AD_CHAN2    =  2       ; // 0 - 7 or NOTUSED */
    XIRANGE1          =  3       ; // Range (gain) of low 16 chans */
    XIRANGE2          =  4       ; // Range (gain) of high 16 chans */
    XICJCCHAN         =  5       ; // TYPE_8254_CTR or TYPE_9513_CTR */
    XITHERMTYPE       =  6       ; // TYPEJ, TYPEK, TYPET, TYPEE, TYPER, or TYPES*/
    XINUMEXPCHANS     =  7       ; // Number of expansion channels on board*/
    XIPARENTBOARD     =  8       ; // Board number of parent A/D board*/
    XISPARE0          =  9       ; // 16 words of misc options */

    XI5VOLTSOURCE     =  100     ; // ICAL DATA - 5 volt source */
    XICHANCONFIG      =  101     ; // exp Data - chan config 2/4 or 3-wire devNo=chan */
    XIVSOURCE         =  102     ; // ICAL DATA - voltage source*/
    XIVSELECT         =  103     ; // ICAL Data - voltage select*/
    XICHGAIN          =  104     ; // exp Data - individual ch gain */
    XIGND             =  105     ; // ICAL DATA - exp grounding */
    XIVADCHAN         =  106     ; // ICAL DATA - Vexe A/D chan */
    XIRESISTANCE      =  107     ; // exp Data - resistance @0 (devNo =ch) */
    XIFACGAIN         =  108	    ; // ICAL DATA - RTD factory gain */
    XICUSTOMGAIN      =  109 	; // ICAL DATA - RTD custom gain */
    XICHCUSTOM        =  110		; // ICAL DATA - RTD custom gain setting*/
    XIIEXE            =  111 	; // ICAL DATA - RTD Iexe */

// Types of memory board information */
    MIBASEADR        =   100 	; // mem data - base address */
    MIINTLEVEL       =   101 	; // mem data - intr level */
    MIMEMSIZE		  =  102		; // MEGA-FIFO module size */
    MIMEMCOUNT		  =  103		; // MEGA-FIFO # of modules */

// AI channel Types */
    AI_CHAN_TYPE_VOLTAGE		 =		0            ;
    AI_CHAN_TYPE_CURRENT		 =		100          ;
    AI_CHAN_TYPE_RESISTANCE_10K4W	=	201        ;
    AI_CHAN_TYPE_RESISTANCE_1K4W	=	202        ;
    AI_CHAN_TYPE_RESISTANCE_10K2W	=	203        ;
    AI_CHAN_TYPE_RESISTANCE_1K2W	=	204        ;
    AI_CHAN_TYPE_TC					=	300              ;
    AI_CHAN_TYPE_RTD_1000OHM_4W	=		401        ;
    AI_CHAN_TYPE_RTD_100OHM_4W =			402      ;
    AI_CHAN_TYPE_RTD_1000OHM_3W	=		403        ;
    AI_CHAN_TYPE_RTD_100OHM_3W =			404      ;
    AI_CHAN_TYPE_QUART_BRIDGE_350OHM =	501    ;
    AI_CHAN_TYPE_QUART_BRIDGE_120OHM =	502    ;
    AI_CHAN_TYPE_HALF_BRIDGE		=	503          ;
    AI_CHAN_TYPE_FULL_BRIDGE_62PT5mVV	= 504    ;
    AI_CHAN_TYPE_FULL_BRIDGE_7PT8mVV =	505    ;


// Thermocouple Types */
    TC_TYPE_J	=	1 ;
    TC_TYPE_K	=	2 ;
    TC_TYPE_T	=	3 ;
    TC_TYPE_E	=	4 ;
    TC_TYPE_R	=	5 ;
    TC_TYPE_S	=	6 ;
    TC_TYPE_B	=	7 ;
    TC_TYPE_N	=	8 ;

// Bridge Types */
    BRIDGE_FULL	=	 1 ;
    BRIDGE_HALF	=	 2 ;
    BRIDGE_QUARTER =	 3 ;

// Platinum RTD Types */
    RTD_CUSTOM	=	$00 ;
    RTD_PT_3750	=	$01 ;
    RTD_PT_3851	=	$02 ;
    RTD_PT_3911	=	$03 ;
    RTD_PT_3916	=	$04 ;
    RTD_PT_3920	=	$05 ;
    RTD_PT_3928	=	$06 ;
    RTD_PT_3850	=	$07 ;

// Version types */

    VER_FW_MAIN	 =			0 ;
    VER_FW_MEASUREMENT =		1 ;
    VER_FW_RADIO		=	2       ;
    VER_FPGA			=	3         ;
    VER_FW_MEASUREMENT_EXP =	4 ;


// Types of events */
   	ON_SCAN_ERROR			=	$0001 ;
    ON_EXTERNAL_INTERRUPT	 =	$0002;
    ON_PRETRIGGER			=	$0004 ;
    ON_DATA_AVAILABLE	 =		$0008 ;
    ON_END_OF_AI_SCAN	 =		$0010	;// deprecated, use ON_END_OF_INPUT_SCAN
    ON_END_OF_AO_SCAN	 =		$0020	;// deprecated, use ON_END_OF_OUTPUT_SCAN
    ON_END_OF_INPUT_SCAN =		$0010 ;
    ON_END_OF_OUTPUT_SCAN	=	$0020 ;
    ON_CHANGE_DI          =   $0040 ;
    ALL_EVENT_TYPES       =   $ffff ;

    NUM_EVENT_TYPES	 =	6 ;
    MAX_NUM_EVENT_TYPES =32 ;

    SCAN_ERROR_IDX			=	0 ;
    EXTERNAL_INTERRUPT_IDX	=1 ;
    PRETRIGGER_IDX				=2 ;
    DATA_AVAILABLE_IDX		 =	3 ;
    END_OF_AI_IDX			 =	4 ;
    END_OF_AO_IDX			 =	5 ;

// ON_EXTERNAL_INTERRUPT event parameters*/
    LATCH_DI	 =		1 ;
    LATCH_DO	 =		2 ;


// time zone constants
    TIMEZONE_LOCAL =		0 ;
    TIMEZONE_GMT	 =	1 ;


// time format constants
    TIMEFORMAT_12HOUR	=0 ;
    TIMEFORMAT_24HOUR	=1 ;


// delimiter constants
    DELIMITER_COMMA	=	0  ;
    DELIMITER_SEMICOLON	=1 ;
    DELIMITER_SPACE	=	2 ;
    DELIMITER_TAB	=	3 ;


// AI channel units in binary file
    UNITS_TEMPERATURE	=0 ;
    UNITS_RAW			=1 ;

// Transfer Mode
    XFER_KERNEL		 =	0 ;
    XFER_USER		=	1 ;

// Clock type
    CONTINUOUS_CLK =		1 ;
    GATED_CLK		=	2       ;

// Calibration Table types
    CAL_TABLE_FACTORY	=0   ;
    CAL_TABLE_FIELD	 =	1  ;

CIO_COM422 = 20481 ;
CIO_COM485 = 20482 ;
CIO_CTR05 = 2049   ;
CIO_CTR10 = 2050   ;
CIO_CTR10_HD = 2051 ;
CIO_CTR20_HD = 2052 ;
CIO_DAC02 = 1537 ;
CIO_DAC02_16 = 1796 ;
CIO_DAC04_12_HS = 2564 ;
CIO_DAC04_16_HS = 19 ;
CIO_DAC08 = 1538 ;
CIO_DAC08_16 = 1797      ;
CIO_DAC08I = 1541        ;
CIO_DAC16 = 1539         ;
CIO_DAC16_16 = 1798      ;
CIO_DAC16I = 1540        ;
CIO_DAS08 = 3073         ;
CIO_DAS08_AOH = 3077     ;
CIO_DAS08_AOL = 3076     ;
CIO_DAS08_AOM = 3079     ;
CIO_DAS08_Jr = 3080      ;
CIO_DAS08Jr_16 = 3082    ;
CIO_DAS08PGH = 3075      ;
CIO_DAS08PGL = 3074      ;
CIO_DAS08_PGM = 3078     ;
CIO_DAS1401_12 = 3588    ;
CIO_DAS1402_12 = 3589    ;
CIO_DAS1402_16 = 3590    ;
CIO_DAS16 = 257           ;
CIO_DAS16_330 = 260      ;
CIO_DAS16_330i = 261     ;
CIO_DAS16_F = 258        ;
CIO_DAS16_Jr = 259       ;
CIO_DAS16_Jr16 = 265     ;
CIO_DAS16_M1 = 262       ;
CIO_DAS16_M1_16 = 9      ;
CIO_DAS1601_12 = 3585    ;
CIO_DAS1602_12 = 3586    ;
CIO_DAS1602_16 = 3587    ;
CIO_DAS48PGA = 3329      ;
CIO_DAS6402_12 = 8       ;
CIO_DAS6402_16 = 10      ;
CIO_DAS800 = 24577       ;
CIO_DAS801 = 24578       ;
CIO_DAS802 = 24579       ;
CIO_DAS802_16 = 24580    ;
CIO_DAS_TC = 46          ;
CIO_DAS_TEMP = 4353      ;
CIO_DDA06_12 = 1793      ;
CIO_DDA06_16 = 1794      ;
CIO_DDA06_Jr = 1795      ;
CIO_DDA06Jr_16 = 1799    ;
CIO_DI192 = 1037         ;
CIO_DI48 = 1033          ;
CIO_DI96 = 1035          ;
CIO_DIO192 = 1029        ;
CIO_DIO24 = 1025         ;
CIO_DIO24_CTR3 = 1030    ;
CIO_DIO24H = 1026        ;
CIO_DIO48 = 1027         ;
CIO_DIO48H = 1031        ;
CIO_DIO96 = 1028         ;
CIO_DISO48 = 8193        ;
CIO_DO192H = 1038        ;
CIO_DO24DD = 1039        ;
CIO_DO48DD = 1040        ;
CIO_DO48H = 1034         ;
CIO_DO96H = 1036         ;
CIO_DUAL422 = 20483      ;
CIO_DUAL_AC5 = 1032      ;
CIO_EXP16 = 769          ;
CIO_EXP32 = 770          ;
CIO_EXP_BRIDGE = 773     ;
CIO_EXP_GP = 771         ;
CIO_EXP_RTD = 772        ;
CIO_INT32 = 12289        ;
CIO_PDISO16 = 2306       ;
CIO_PDISO8 = 2305        ;
CIO_PDMA16 = 1281        ;
CIO_PDMA32 = 18          ;
CIO_QUAD02 = 47          ;
CIO_QUAD04 = 48          ;
CIO_RELAY08 = 4098       ;
CIO_RELAY16 = 4097        ;
CIO_RELAY16_M = 4099     ;
CIO_RELAY16M = 17        ;
CIO_RELAY24 = 42         ;
CIO_RELAY32 = 43         ;
CIO_SSH16 = 513          ;

CPCI_DIO24H = 85         ;
CPCI_DIO48H = 91         ;
CPCI_DIO96H = 90         ;
CPCI_GPIB = 14           ;

DEMO_BOARD = 45          ;

E_1608 = 303             ;
E_DIO24 = 311            ;
E_PDISO16 = 137          ;
E_TC = 312               ;

ISA_MDB64 = 70           ;

MAI_16 = 80              ;
MEGA_FIFO = 3841         ;
MEM_8 = 73               ;
MEM_32 = 74               ;
MII_32 = 71               ;
miniLAB = 1008 = 117     ;
MIO_32 = 72              ;
MSSR_24 = 78             ;

PC104_AC5 = 88           ;
PC104_CTR10_HD = 2053    ;
PC104_DAC06 = 1543       ;
PC104_DAS08 = 3081       ;
PC104_DAS16Jr_12 = 263    ;
PC104_DAS16Jr_16 = 264    ;
PC104_DI48 = 1042        ;
PC104_DIO48 = 1041       ;
PC104_DO48H = 1043       ;
PC104_MDB64 = 79         ;
PC104_PDISO8 = 2307      ;

PC_CARD_D24_CTR3 = 61      ;
PC_CARD_DAC08 = 92         ;
PC_CARD_DAS16_12 = 58      ;
PC_CARD_DAS16_12_AO = 59   ;
PC_CARD_DAS16_16 = 56      ;
PC_CARD_DAS16_16_AO = 57   ;
PC_CARD_DAS16_330 = 60      ;
PC_CARD_DIO48 = 62         ;

PCI_2511 = 165             ;
PCI_2513 = 166             ;
PCI_2515 = 167             ;
PCI_2517 = 168             ;
PCI_COM232 = 63            ;
PCI_COM232_2 = 64          ;
PCI_COM232_4 = 65          ;
PCI_COM422 = 66            ;
PCI_COM422_2 = 67          ;
PCI_COM485 = 68            ;
PCI_COM485_2 = 69          ;
PCI_CTR05 = 24             ;
PCI_CTR10 = 110            ;
PCI_CTR20HD = 116          ;
PCI_DAC04_12HS = 38        ;
PCI_DAC04_16HS = 39        ;
PCI_DAC6702 = 112          ;
PCI_DAC6703 = 113          ;
PCI_DAS08 = 41             ;
PCI_DAS1000 = 76           ;
PCI_DAS1001 = 26           ;
PCI_DAS1002 = 27           ;
PCI_DAS1200 = 15           ;
PCI_DAS1200Jr = 25         ;
PCI_DAS16_M1 = 31          ;
PCI_DAS1602_12 = 16        ;
PCI_DAS1602_16 = 1         ;
PCI_DAS1602JR_16 = 28      ;
PCI_DAS3202_16 = 87        ;
PCI_DAS4020_12 = 82        ;
PCI_DAS6013 = 120          ;
PCI_DAS6014 = 121           ;
PCI_DAS6023 = 93           ;
PCI_DAS6025 = 94           ;
PCI_DAS6030 = 95           ;
PCI_DAS6031 = 96            ;
PCI_DAS6032 = 97           ;
PCI_DAS6033 = 98           ;
PCI_DAS6034 = 99           ;
PCI_DAS6035 = 100          ;
PCI_DAS6036 = 111          ;
PCI_DAS6040 = 101          ;
PCI_DAS6052 = 102          ;
PCI_DAS6070 = 103          ;
PCI_DAS6071 = 104          ;
PCI_DAS64 = 50             ;
PCI_DAS64_M1_16 = 53       ;
PCI_DAS64_M2_16 = 54       ;
PCI_DAS64_M3_16 = 55       ;
PCI_DAS6402_12 = 30        ;
PCI_DAS6402_16 = 29        ;
PCI_DAS_TC = 52            ;
PCI_DDA02_12 = 32          ;
PCI_DDA02_16 = 35          ;
PCI_DDA04_12 = 33          ;
PCI_DDA04_16 = 36          ;
PCI_DDA08_12 = 34          ;
PCI_DDA08_16 = 37           ;
PCI_DIO24 = 40             ;
PCI_DIO24_LP = 119         ;
PCI_DIO24_S = 126          ;
PCI_DIO24H = 20            ;
PCI_DIO24H_CTR3 = 21       ;
PCI_DIO48H = 11            ;
PCI_DIO48H_CTR15 = 22      ;
PCI_DIO96 = 84             ;
PCI_DIO96H = 23            ;
PCI_DUAL_AC5 = 51          ;
PCI_INT32 = 44             ;
PCI_MDB64 = 75             ;
PCI_PDISO16 = 13           ;
PCI_PDISO8 = 12            ;
PCI_QUAD04 = 77            ;
PCI_QUAD_AC5 = 89          ;

PCIe_DAS1602_16 = 277      ;
PCIe_DIO24 = 219           ;
PCIe_DIO96H = 218          ;

PCIM_DAS1602_16 = 86       ;
PCIM_DAS16JR_16 = 123      ;
PCIM_DDA06_16 = 83         ;

PCM_COM422 = 16388         ;
PCM_COM485 = 16389         ;
PCM_D24_CTR3 = 16386       ;
PCM_DAC02 = 16387          ;
PCM_DAC08 = 16401          ;
PCM_DAS08 = 16385          ;
PCM_DAS16D_12 = 16390      ;
PCM_DAS16D_12AO = 16395    ;
PCM_DAS16D_16 = 16392      ;
PCM_DAS16S_12 = 16391      ;
PCM_DAS16S_16 = 16393      ;
PCM_DAS16S_330 = 16394     ;
PCM_QUAD02 = 49            ;
PMD_1024LS = 118 ;
USB_1024LS = 118 ;

PPIO_AI08 = 2818                ;
PPIO_CTR06 = 2819               ;
PPIO_DIO24H = 2817              ;

USB_201 = 275                       ;
USB_202 = 299                       ;
USB_204 = 276                       ;
USB_205 = 300                       ;
USB_231 = 297                       ;
USB_234 = 298                       ;
USB_1024HLS = 127 ;
PMD_1024HLS = 127 ;
USB_1096HFS = 131 ;
USB_1208FS = 130 ;
PMD_1208FS = 130 ;
USB_1208FS_Plus = 232 ;
USB_1208LS = 122 ;
PMD_1208LS = 122   ;
USB_1208HS = 196                 ;
USB_1208HS_2AO = 197             ;
USB_1208HS_4AO = 198             ;
USB_1408FS = 161                 ;
USB_1408FS_Plus = 233            ;
USB_1602HS = 213                 ;
USB_1602HS_2AO = 214             ;
USB_1604HS = 215                 ;
USB_1604HS_2AO = 216             ;
USB_1608FS = 125 ;
PMD_1608FS = 125 ;
USB_1608FS_Plus = 234 ;
USB_1608G = 272 ;
USB_1608G_202 = 308 ;
USB_1608GX = 273 ;
USB_1608GX_202 =309 ;
USB_1608GX_2AO = 274 ;
USB_1608GX_2AO_202 = 310 ;
USB_1608HS = 189          ;
USB_1608HS_2AO = 153      ;
USB_1616FS = 129          ;
USB_1616FS_Plus = 321     ;
USB_1616HS = 203          ;
USB_1616HS_2 = 204        ;
USB_1616HS_4 = 205        ;
USB_1616HS_BNC = 217      ;
USB_1808 = 317            ;
USB_1808X = 318           ;
USB_2001_TC = 249         ;
USB_2020 = 284            ;
USB_2404_10 = 222         ;
USB_2404_60 = 223         ;
USB_2404_UI = 225         ;
USB_2408 = 253            ;
USB_2408_2AO = 254        ;
USB_2416 = 208            ;
USB_2416_4AO = 209        ;
USB_2523 = 177            ;
USB_2527 = 178            ;
USB_2533 = 179            ;
USB_2537 = 180            ;
USB_2623 = 288            ;
USB_2627 = 289            ;
USB_2633 = 280            ;
USB_2637 = 281            ;
USB_3101 = 154            ;
USB_3101FS = 224          ;
USB_3102 = 155            ;
USB_3103 = 156            ;
USB_3104 = 157            ;
USB_3105 = 158            ;
USB_3106 = 159            ;
USB_3110 = 162            ;
USB_3112 = 163            ;
USB_3114 = 164            ;
USB_4301 = 174            ;
USB_4302 = 184            ;
USB_4303 = 185            ;
USB_4304 = 186            ;
USB_5201 = 152 ;
USB_5201_rev = 175 ;
USB_5203 = 151 ;
USB_5203_rev = 176 ;
USB_7202 = 242         ;
USB_7204 = 240            ;
USB_CTR04 = 302           ;
USB_CTR08 = 295           ;
USB_DIO24_37 = 147        ;
USB_DIO24H_37 = 148       ;
USB_DIO32HS = 307         ;
USB_DIO96H = 146          ;
USB_DIO96H_50 = 149       ;
USB_ERB08 = 139           ;
USB_ERB24 = 138           ;
USB_PDISO8 = 140          ;
USB_PDISO8_50 = 150       ;
USB_QUAD08 = 202          ;
USB_SSR08 = 134           ;
USB_SSR24 = 133           ;
USB_TC = 144              ;
USB_TC_AI = 187           ;
USB_TEMP = 141            ;
USB_TEMP_AI = 188         ;




function MCC_IsLabInterfaceAvailable : boolean ;
function MCC_InitialiseBoard : Boolean ;
function MCC_DeviceExists( DevName : ANSIString ) : Boolean ;

procedure MCC_LoadLibrary  ;

function MCC_LoadProcedure(
         Hnd : THandle ;       { Library DLL handle }
         Name : string         { Procedure name within DLL }
         ) : Pointer ;         { Return pointer to procedure }

procedure MCC_DisableFPUExceptions ;

procedure MCC_EnableFPUExceptions ;

procedure MCC_GetDeviceList(
          var DeviceList : TStringList
          ) ;

function  MCC_GetLabInterfaceInfo(
          var DeviceList : TStringList ;
          var DeviceNumber : Integer ;  // Device #
          var ADCInputMode : Integer ;  // Analog input mode
          var BoardModel : string ; { Laboratory interface model name/number }
          var ADCMaxChannels : Integer ; // No. of A/D channels
          var ADCMinSamplingInterval : Double ; { Smallest sampling interval }
          var ADCMaxSamplingInterval : Double ; { Largest sampling interval }
          var ADCMinValue : Integer ; { Negative limit of binary ADC values }
          var ADCMaxValue : Integer ; { Positive limit of binary ADC values }
          var DACMaxChannels : Integer ; // No. of D/A channels
          var DACMinValue : Integer ; { Negative limit of binary DAC values }
          var DACMaxValue : Integer ; { Positive limit of binary DAC values }
          var ADCVoltageRanges : Array of single ; { A/D voltage range option list }
          var NumADCVoltageRanges : Integer ; { No. of options in above list }
          var DACMaxVolts : Single ;{ Positive limit of bipolar D/A voltage range }
          var DACMinUpdateInterval : Double ; {Min. D/A update interval }
          var DigMinUpdateInterval : Double ; {Min. digital update interval }
          var DigMaxUpdateInterval : Double ; {Min. digital update interval }
          var DigUpdateStep : Integer ; // Digital output step interval
          var ADCBufferLimit : Integer  // Max. no. of A/D samples/buffer
          ) : Boolean ;

procedure MCC_GetChannelOffsets(
          ADCInputMode : Integer ;
          var Offsets : Array of Integer ;
          var NumChannels : Integer
          ) ;

procedure  MCC_CheckError( Err : Integer ) ;

procedure MCC_CheckADCSamplingInterval(
               var SamplingInterval : double ;
               NumADCChannels : Integer ;
               ADCInputMode : Integer ) ;

procedure MCC_CheckDACSamplingInterval(
               var SamplingInterval : double ;
               NumDACChannels : Integer
               ) ;


function MCC_ADCToMemory(
          var ADCBuf : Array of SmallInt  ;  { A/D sample buffer (OUT) }
          nChannels : Integer ;              { Number of A/D channels (IN) }
          nSamples : Integer ;               { Number of A/D samples ( per channel) (IN) }
          var SamplingInterval : Double ;    { Sampling interval (s) (IN) }
          ADCVoltageRanges : Array of Single ;{ A/D input voltage range for each channel (V) (IN) }
          TriggerMode : Integer ;             // Sweep trigger mode
          ADCExternalTriggerActiveHigh : Boolean ;
          CircularBuffer : Boolean ;          { Repeated sampling into buffer (IN) }
          ADCInputMode : Integer ;
          ADCChannelInputNumber : Array of Integer // Input channel number
          ) : Boolean ;                      { Returns TRUE indicating A/D started }

function MCC_ADRangeCode( VRange : single ) : Integer ;

procedure MCC_GetADCSamples(
          var ADCBuf : Array of SmallInt  ;
          var OutPointer : Integer ;
          var ADCChannelVoltageRanges : Array of Single
          ) ;

function MCC_StopADC : Boolean ;

function MCC_MemoryToDAC(
            var DACBuf : Array of SmallInt  ;
            nChannels : Integer ;
            nPoints : Integer ;
            UpdateInterval : Double ;
            ExternalTrigger : Boolean ;
            RepeatWaveform : Boolean
            ) : Boolean ;

function MCC_StopDAC : Boolean ;

function MCC_MemoryToDIG(
            var DIGBuf : Array of SmallInt  ;
            nPoints : Integer ;
            UpdateInterval : Double ;
            RepeatWaveform : Boolean
            ) : Boolean ;

function MCC_StopDIG : Boolean ;

procedure MCC_WriteDACs(
               DACVolts : array of Single ;
               nChannels : Integer
               ) ;

function MCC_ReadADC(
              Channel : Integer ;
              ADCVoltageRange : Single ;
              ADCInputMode : Integer
              ) : Integer ;

procedure MCC_WriteToDigitalOutPutPort(
          Pattern : Integer
          ) ;

function MCC_ReadDigitalInputPort : Integer ;

function MCC_GetValidExternalTriggerPolarity(
         Value : Boolean
         ) : Boolean ;

procedure MCC_CloseLaboratoryInterface ;

function MCC_GetADCInputModeCode( ADCInputMode : Integer ) : Integer ;



type

//typedef enum
//{
//	USB_IFC = 1 << 0,
//	BLUETOOTH_IFC = 1 << 1,
//	ETHERNET_IFC = 1 << 2,
//	ANY_IFC  = USB_IFC | BLUETOOTH_IFC | ETHERNET_IFC
//} DaqDeviceInterface;


TDaqDeviceDescriptor = packed record
	ProductName: Array[0..63] of ANSIChar ;
	ProductID : Cardinal ;
	DaqDeviceInterface : Cardinal ;
	DevString: Array[0..63] of ANSIChar ;
	UniqueID: Array[0..63] of ANSIChar ;	     // unique identifier for device. Serial number for USB deivces and MAC address for  bth and net devices
  NUID : UInt64 ;                           // numeric representation of uniqueID
	Reserved : Array[0..511] of ANSICHar ;		// reserved for the future.
  end ;

    TcbACalibrateData  = function(
                         BoardNum : Integer ;
                         NumPoints: Cardinal ;
                         Gain : Integer ;
                         ADData : Pointer ) : Integer ; stdcall  ;

    TcbGetRevision  = function(
                      var RevNum : single ;
                      var VxDRevNum  : single ) : Integer ; stdcall  ;

    TcbLoadConfig = function(CfgFileName : PANSIChar ) : Integer ; stdcall  ;

    TcbSaveConfig = function(CfgFileName : PANSIChar) : Integer ; stdcall  ;

    TcbAConvertData  = function(
                       BoardNum : Integer ;
                       NumPoints: Cardinal ;
                       ADData : Pointer ;
                       ChanTags : Pointer ) : Integer ; stdcall  ;

    TcbAConvertPretrigData  = function(
                              BoardNum : Integer ;
                              PreTrigCount: Cardinal ;
                              TotalCount: Cardinal ;
                              ADData : Pointer ;
                              ChanTags : Pointer) : Integer ; stdcall  ;

    TcbAIn  = function(
              BoardNum : Integer ;
              Chan : Integer ;
              Gain : Integer ;
              var DataValue : Word ) : Integer ; stdcall  ;

    TcbVIn  = function(
              BoardNum : Integer ;
              Chan : Integer ;
              Gain : Integer ;
              var DataValue : single ;
              Options : Integer ) : Integer ; stdcall  ;

    TcbAIn32  = function(
                BoardNum : Integer ;
                Chan : Integer ;
                Gain : Integer ;
                var DataValue : Cardinal ;
                Options : Integer ) : Integer ; stdcall  ;

    TcbAInScan  = function(
                  BoardNum : Integer ;
                  LowChan : Integer ;
                  HighChan : Integer ;
                  Count : Cardinal ;
                  var Rate : Cardinal ;
                  Gain : Integer ;
                  MemHandle : THandle ;
							    Options : Integer ) : Integer ; stdcall  ;

    TcbALoadQueue  = function(
                     BoardNum : Integer ;
                     ChanArray : PWord ;
                     GainArray : PWord ;
                     NumChans : Integer ) : Integer ; stdcall  ;

    TcbAOut  = function(
               BoardNum : Integer ;
               Chan : Integer ;
               Gain : Integer ;
               DataValue : Word ) : Integer ; stdcall  ;

    TcbVOut  = function(
               BoardNum : Integer ;
               Chan : Integer ;
               Gain : Integer ;
               DataValue : single ) : Integer ; stdcall  ;


    TcbAOutScan  = function(
                  BoardNum : Integer ;
                  LowChan : Integer ;
                  HighChan : Integer ;
                  Count : Cardinal ;
                  var Rate : Cardinal ;
                  Gain : Integer ;
                  MemHandle : THandle ;
							    Options : Integer ) : Integer ; stdcall  ;

    TcbAPretrig  = function(
                   BoardNum : Integer ;
                   LowChan : Integer ;
                   HighChan : Integer ;
                   var PreTrigCount : Cardinal ;
                   var TotalCount : Cardinal ;
                   var Rate : Cardinal ;
							     Gain : Integer ;
                   MemHandle : THandle ;
							     Options : Integer ) : Integer ; stdcall  ;

    TcbATrig  = function(
                BoardNum : Integer ;
                Chan : Integer ;
                TrigType : Integer ;
                TrigValue : Word ;
                Gain : Integer ;
                var DataValue : Word ) : Integer ; stdcall  ;

  	TcbCInScan = function(
                 BoardNum : Integer ;
                 FirstCtr : Integer ;
                 LastCtr : Integer ;
                 Count : Cardinal ;
							   var Rate : Cardinal ;
                 MemHandle : THandle ;
                 Options : Integer) : Integer ; stdcall  ;

    TcbDBitIn  = function(
                 BoardNum : Integer ;
                 PortType : Integer ;
                 BitNum : Integer ;
                 var BitValue : Word ) : Integer ; stdcall  ;

    TcbDBitOut  = function(
                  BoardNum : Integer ;
                  PortType : Integer ;
                  BitNum : Integer ;
                  BitValue : Word) : Integer ; stdcall  ;

    TcbDConfigPort  = function(
                      BoardNum : Integer ;
                      PortType : Integer ;
                      Direction : Integer ) : Integer ; stdcall  ;

    TcbDConfigBit  = function(
                     BoardNum : Integer ;
                     PortType : Integer ;
                     BitNum : Integer ;
                     Direction : Integer ) : Integer ; stdcall  ;

    TcbDIn  = function(
              BoardNum : Integer ;
              PortType : Integer ;
              var DataValue : Word ) : Integer ; stdcall  ;

  	TcbDIn32  = function(
                BoardNum : Integer ;
                PortType : Integer ;
                var DataValue : Cardinal ) : Integer ; stdcall  ;

    TcbDInScan  = function(
                  BoardNum : Integer ;
                  PortType : Integer ;
                  Count : Cardinal ;
  							  var Rate : Cardinal ;
                  MemHandle : THandle ;
                  Options : Integer ) : Integer ; stdcall  ;

    TcbDOut = function(
              BoardNum : Integer ;
              PortType : Integer ;
              DataValue : Word ) : Integer ; stdcall  ;

  	TcbDOut32 = function(
                BoardNum : Integer ;
                PortType : Integer ;
                DataValue : Cardinal ) : Integer ; stdcall  ;

    TcbDOutScan  = function(
                   BoardNum : Integer ;
                   PortType : Integer ;
                   Count : Cardinal ;
  							   var Rate : Cardinal ;
                   MemHandle : THandle ;
                   Options : Integer ) : Integer ; stdcall  ;

  	TcbDInArray  = function(
                   BoardNum : Integer ;
                   LowPort : Integer ;
                   HighPort : Integer ;
                   pDataArray : Pointer
                   ) : Integer ; stdcall  ;

  	TcbDOutArray  = function(
                    BoardNum : Integer ;
                   LowPort : Integer ;
                   HighPort : Integer ;
                   pDataArray : Pointer
                   ) : Integer ; stdcall  ;

    TcbErrHandling  = function(
                      ErrReporting : Integer ;
                      ErrHandling  : Integer ) : Integer ; stdcall  ;

    TcbGetErrMsg  = function(
                    ErrCode : Integer ;
                    ErrMsg : PANSIChar ) : Integer ; stdcall  ;

    TcbGetIOStatus  = function(
                      BoardNum : Integer ;
                      var Status : Word ;
                      var CurCount : Cardinal ;
                      var CurIndex : Cardinal ;
                      FunctionType : Integer ) : Integer ; stdcall  ;

    TcbStopIOBackground  = function(
                           BoardNum : Integer ;
                           FunctionType : Integer ) : Integer ; stdcall  ;

    TcbMemSetDTMode  = function(
                       BoardNum : Integer ;
                       Mode : Integer ) : Integer ; stdcall  ;

    TcbMemReset  = function(BoardNum : Integer ) : Integer ; stdcall  ;

    TcbMemRead  = function(
                  BoardNum : Integer ;
                  DataBuffer : PWord ;
                  FirstPoint : Cardinal ;
                  Count : Cardinal ) : Integer ; stdcall  ;

    TcbMemWrite  = function(
                   BoardNum : Integer ;
                   DataBuffer : PWord ;
                   FirstPoint : Cardinal ;
                   Count : Cardinal) : Integer ; stdcall  ;

    TcbMemReadPretrig  = function(
                         BoardNum : Integer ;
                         DataBuffer : PWord ;
                         FirstPoint : Cardinal ;
                         Count : Cardinal) : Integer ; stdcall  ;

    TcbWinBufToArray  = function(
                        MemHandle : THandle ;
                        DataBuffer : PWord ;
                        FirstPoint : Cardinal ;
                        Count : Cardinal) : Integer ; stdcall  ;

  	TcbWinBufToArray32  = function(
                        MemHandle : THandle ;
                        DataBuffer : Pointer ;
                        FirstPoint : Cardinal ;
                        Count : Cardinal) : Integer ; stdcall  ;

  	TcbWinBufToArray64  = function(
                        MemHandle : THandle ;
                        DataBuffer : Pointer ;
                        FirstPoint : Cardinal ;
                        Count : Cardinal) : Integer ; stdcall  ;

  	TcbScaledWinBufAlloc  = function( NumPoints : Cardinal ) : THandle ; stdcall  ;

  	TcbScaledWinBufToArray  = function(
                        MemHandle : THandle ;
                        DataBuffer : Pointer ;
                        FirstPoint : Cardinal ;
                        Count : Cardinal) : Integer ; stdcall  ;

    TcbWinArrayToBuf  = function(
                        DataArray : PWord ;
                        MemHandle : THandle ;
                        FirstPoint : Cardinal ;
                        Count : Cardinal) : Integer ; stdcall  ;

  	TcbWinArrayToBuf32  = function(
                        DataArray : Pointer ;
                        MemHandle : THandle ;
                        FirstPoint : Cardinal ;
                        Count : Cardinal) : Integer ; stdcall  ;

  	TcbScaledWinArrayToBuf  = function(
                        DataArray : Pointer ;
                        MemHandle : THandle ;
                        FirstPoint : Cardinal ;
                        Count : Cardinal) : Integer ; stdcall  ;

    TcbWinBufAlloc  = function( NumPoints: Cardinal ) : THandle ; stdcall  ;
    TcbWinBufAlloc32  = function( NumPoints: Cardinal ) : THandle ; stdcall  ;
    TcbWinBufAlloc64  = function( NumPoints: Cardinal ) : THandle ; stdcall  ;
    TcbWinBufFree  = function( MemHandle : THandle ) : Integer ; stdcall  ;

    TcbInByte  = function(
                 BoardNum : Integer ;
                 PortNum : Integer
                 ) : Integer ; stdcall  ;

    TcbOutByte  = function(
                 BoardNum : Integer ;
                 PortNum : Integer ;
                 PortVal : Integer ) : Integer ; stdcall  ;

    TcbInWord  = function(
                 BoardNum : Integer ;
                 PortNum : Integer
                 ) : Integer ; stdcall  ;

    TcbOutWord  = function(
                 BoardNum : Integer ;
                 PortNum : Integer ;
                 PortVal : Integer ) : Integer ; stdcall  ;


    TcbGetConfig  = function(
                    InfoType : Integer ;
                    BoardNum : Integer ;
                    DevNum : Integer ;
                    ConfigItem : Integer ;
                    var ConfigVal : Integer ) : Integer ; stdcall  ;

    TcbGetConfigString  = function(
                    InfoType : Integer ;
                    BoardNum : Integer ;
                    DevNum : Integer ;
                    ConfigItem : Integer ;
                    ConfigVal : PChar ;
                    maxConfigLen : Integer ) : Integer ; stdcall  ;

    TcbSetConfig  = function(
                    InfoType : Integer ;
                    BoardNum : Integer ;
                    DevNum : Integer ;
                    ConfigItem : Integer ;
                    ConfigVal : Integer ) : Integer ; stdcall  ;

    TcbSetConfigString  = function(
                    InfoType : Integer ;
                    BoardNum : Integer ;
                    DevNum : Integer ;
                    ConfigItem : Integer ;
                    ConfigVal : PChar ;
                    var maxConfigLen : Integer ) : Integer ; stdcall  ;

    TcbGetBoardName  = function(
                       BoardNum : Integer ;
                       BoardName : PANSIChar ) : Integer ; stdcall  ;

    TcbDeclareRevision = function(var RevNum : Single ) : Integer ; stdcall  ;


  	TcbAInputMode = function(
                    BoardNum : Integer ;
                    InputMode : Integer ) : Integer ; stdcall  ;

  	TcbAChanInputMode = function(
                        BoardNum : Integer ;
                        Chan : Integer ;
                        InputMode : Integer ) : Integer ; stdcall  ;

	TcbGetDaqDeviceInventory = function(
                             DaqDeviceInterface : Integer ;
                             pDaqDeviceDescriptor : Pointer ;
                             var NumberOfDevices : Integer ) : Integer ; stdcall  ;

  TcbGetStatus = function(
                 BoardNum : Integer ;
                 var Status : Integer ;
                 var CurCount : Integer ;
                 var CurIndex : Integer ;
                 FunctionType : SmallInt ) : Integer ; stdcall  ;

  TcbStopBackground = function(
                      BoardNum : Integer ;
                      FunctionType : SmallInt ) : Integer ; stdcall  ;

var
    NIDAQMXLoaded : Boolean ;
    FDeviceNumber : Integer ;
    LibraryLoaded : Boolean ;
    ADCActive : Boolean ;     { A/D sampling inn progress flag }
    DACActive : Boolean ;     { D/A output in progress flag }
    DigActive : Boolean ;
    DACDigActive : Boolean ;          // TRUE = Combined DAC/digital output active
    ADCInputMode : Integer ;          // A/D (Differential/ SingleEnded) input mode
    ADCSamplingIntervalInUse : Double ; // Current A/D sampling interval in use
    DACUpdateIntervalInUse : Double ;   // Curent D/A update interval in use

    cbACalibrateData : TcbACalibrateData ;
    cbGetRevision : TcbGetRevision ;
    cbLoadConfig : TcbLoadConfig ;
    cbSaveConfig : TcbSaveConfig ;
    cbAConvertData : TcbAConvertData ;
    cbAConvertPretrigData : TcbAConvertPretrigData ;
    cbAIn : TcbAIn ;
    cbVIn : TcbVIn ;
    cbAIn32 : TcbAIn32 ;
    cbAInScan : TcbAInScan ;
    cbALoadQueue : TcbALoadQueue ;
    cbAOut : TcbAOut ;
    cbVOut : TcbVOut ;
    cbAOutScan : TcbAOutScan ;
    cbAPretrig : TcbAPretrig ;
    cbATrig : TcbATrig ;
  	cbCInScan : TcbCInScan ;
    cbDBitIn : TcbDBitIn ;
    cbDBitOut : TcbDBitOut ;
    cbDConfigPort : TcbDConfigPort ;
    cbDConfigBit : TcbDConfigBit ;
    cbDIn : TcbDIn ;
  	cbDIn32 : TcbDIn32 ;
    cbDInScan : TcbDInScan ;
    cbDOut : TcbDOut ;
  	cbDOut32 : TcbDOut32 ;
    cbDOutScan : TcbDOutScan ;
  	cbDInArray : TcbDInArray ;
  	cbDOutArray : TcbDOutArray ;
    cbErrHandling : TcbErrHandling ;
    cbGetErrMsg : TcbGetErrMsg ;
    cbGetIOStatus : TcbGetIOStatus ;
    cbStopIOBackground : TcbStopIOBackground ;
    cbMemSetDTMode : TcbMemSetDTMode ;
    cbMemReset : TcbMemReset ;
    cbMemRead : TcbMemRead ;
    cbMemWrite : TcbMemWrite ;
    cbMemReadPretrig : TcbMemReadPretrig ;
    cbWinBufToArray : TcbWinBufToArray ;
  	cbWinBufToArray32 : TcbWinBufToArray32 ;
  	cbWinBufToArray64 : TcbWinBufToArray64 ;
  	cbScaledWinBufAlloc : TcbScaledWinBufAlloc ;
  	cbScaledWinBufToArray : TcbScaledWinBufToArray ;
    cbWinArrayToBuf : TcbWinArrayToBuf ;
  	cbWinArrayToBuf32 : TcbWinArrayToBuf32 ;
  	cbScaledWinArrayToBuf : TcbScaledWinArrayToBuf ;
    cbWinBufAlloc : TcbWinBufAlloc ;
    cbWinBufAlloc32 : TcbWinBufAlloc32 ;
    cbWinBufAlloc64 : TcbWinBufAlloc64 ;
    cbWinBufFree : TcbWinBufFree ;
    cbInByte : TcbInByte ;
    cbOutByte : TcbOutByte ;
    cbInWord : TcbInWord ;
    cbOutWord : TcbOutWord ;
    cbGetConfig : TcbGetConfig ;
    cbGetConfigString : TcbGetConfigString ;
    cbSetConfig : TcbSetConfig ;
    cbSetConfigString : TcbSetConfigString ;
    cbGetBoardName : TcbGetBoardName ;
    cbDeclareRevision : TcbDeclareRevision ;
  	cbAInputMode : TcbAInputMode ;
  	cbAChanInputMode : TcbAChanInputMode ;
  	cbGetDaqDeviceInventory : TcbGetDaqDeviceInventory ;
    cbGetStatus : TcbGetStatus ;
    cbStopBackground : TcbStopBackground ;

implementation


uses seslabio ;

var
    LibraryHnd : THandle ;
    FBoardModel : String ;
    BoardNum : Integer ;

    // D/A Converter
    DACTaskHandle : Integer ;
    FDACResolution : Integer ;
    FDACClockSupported : LongBool ; // TRUE = DAC clock controlled
    FDACMaxVolts : Double ;   // Upper limit of analog O/P range
    FDACMinVolts : Double ;   // Lower limit of analog O/P range
    FDACMaxValue : Integer ;
    FDACMinValue : Integer ;
    FDACMinUpdateInterval : Double ;
    FDACNumChannels : Integer ;

    // A/D Converter
    ADCTaskHandle : Integer ;
    FADCResolution : Integer ;
    FADCMaxVolts : Double ;
    FADCMaxValue : Integer ;
    FADCMinValue : Integer ;
    FADCMinSamplingInterval : Double ;
    FADCMaxSamplingInterval : Double ;
    FADCPointer : Integer ;
    FADCNumSamples : Integer ;
    FADCNumChannels : Integer ;
    FADCScaleFactors : Array[0..10] of Double ;
    FADCCircularBuffer : Boolean ;
    FADCNumSamplesAcquired : Integer ;
    FValidADCInputMode : Integer ;

    BoardInitialised : Boolean ;

    DIGTaskHandle : Integer ;
    FDigClockSupported : LongBool ; // TRUE = Digital output clock controlled
    FNoTriggerOnSampleClock : LongBool ; // TRUE = Cannot trigger AI sampling from AO clock
    //InBuf : PIntArray ;
    DBuf : PDoubleArray ;

    FDigMinUpdateInterval : Double ;
    FDigMaxUpdateInterval : Double ;

    ADCBufHnd : THandle ;   // A/D input data buffer handle
    DACBufHnd : THandle ;   // D/A output data buffer handle
    DigBufHnd : THandle ;   // Digital output data buffer handle



function MCC_IsLabInterfaceAvailable : boolean ;
{ ------------------------------------------------------------
  Check to see if a lab. interface library is available
  ------------------------------------------------------------}
begin
     Result := MCC_InitialiseBoard ;
     end ;


function MCC_DeviceExists( DevName : ANSIString ) : Boolean ;
// -------------------------------
// Return TRUE if device available
// -------------------------------
var
    Err : Integer ;
begin

    Result := False ;
    if not LibraryLoaded then MCC_LoadLibrary ;
    if not LibraryLoaded then Exit ;

    if Err = 0 then Result := True

    end ;


procedure MCC_GetDeviceList(
          var DeviceList : TStringList
          ) ;
// ----------------------------
// Get list of available boards
// ----------------------------
var
    NumBoards,MaxBoards : Integer ;
    BoardName : Array[0..255] of ANSICHar ;
begin

   DeviceList.Clear ;

   if not LibraryLoaded then MCC_LoadLibrary ;
   if not LibraryLoaded then Exit ;

   MCC_CheckError(cbGetConfig(GLOBALINFO, 0, 0, GINUMBOARDS, MaxBoards)) ;

   NumBoards := 0 ;
   repeat
       MCC_CheckError(cbGetBoardName(NumBoards, @BoardName )) ;
       DeviceList.Add( format('Device%d',[NumBoards])) ;
       Inc(NumBoards) ;
   until (BoardName[0] = #0) or (NumBoards = MaxBoards) ;

   end ;


function MCC_InitialiseBoard : Boolean ;
{ --------------------------------------
  Initialise hardware and NI-DAQmx library
  -------------------------------------- }
const
    MaxRanges = 20 ;
var
    Task : Integer ;
    DValue : Double ;
    i : Integer ;
    Err : Integer ;
    CBuf : Array[0..255] of ANSIChar ;
    AORanges : Array[0..MaxRanges] of Double ;
    iBoardType, iValue : Integer ;
begin

    Result := False ;
    if BoardInitialised then Exit ;

    // Disable floating point exceptions
    MCC_DisableFPUExceptions ;

    { Clear A/D and D/A in progress flags }
    ADCActive := False ;
    DACActive := False ;
    DigActive := False ;
    DACDigActive := False ;
    Result := False ;

    if not LibraryLoaded then MCC_LoadLibrary ;
    if not LibraryLoaded then Exit ;

    ADCSamplingIntervalInUse := -1.0 ;
    DACUpdateIntervalInUse := -1.0 ;

    // Get interface card model
    MCC_CheckError(cbGetConfig( BOARDINFO, 0, 0, BIBOARDTYPE, iBoardType)) ;
    MCC_CheckError(cbGetBoardName( FDeviceNumber, @CBuf )) ;
    FBoardModel := '' ;
    i := 0 ;
    while CBuf[i] <> #0 do
       begin
       FBoardModel := FBoardModel + CBuf[i] ;
       Inc(i) ;
       end;
    FBoardModel := format('Board Type %d',[iBoardType]);

    // Get no. of A/D channels
    MCC_CheckError(cbGetConfig( BOARDINFO, 0, 0, BINUMADCHANS, FADCNumChannels )) ;
    FADCMaxValue := 32767 ;
    FADCMinValue := -FADCMaxValue - 1 ;

    // Get A/D resolution
    MCC_CheckError(cbGetConfig( BOARDINFO, 0, 0, BIADRES, FADCResolution )) ;

    // Get no. of D/A channels
    MCC_CheckError(cbGetConfig( BOARDINFO, 0, 0, BINUMDACHANS, FDACNumChannels )) ;

    case iBoardType of

         DEMO_BOARD : begin
         FADCMinSamplingInterval := 1.0/ 2E5 ;
         FDACMinUpdateInterval := FADCMinSamplingInterval ;
         FDACResolution := 16 ;
         FDACMaxValue := 32767 ;
         FADCResolution := 16 ;
         FADCMaxValue := 32767 ;
         FDACMaxVolts := 10.0 ;
         end;

         USB_1808 : Begin
         FADCMinSamplingInterval := 1.0/ 5E5 ;
         FDACMinUpdateInterval := FADCMinSamplingInterval ;
         FDACResolution := 16 ;
         FDACMaxValue := 32767 ;
         FADCResolution := 16 ;
         FADCMaxValue := 32767 ;
         FDACMaxVolts := 10.0 ;
         End;

         USB_1808X : Begin
         FADCMinSamplingInterval := 1.0/ 2E5 ;
         FDACMinUpdateInterval := FADCMinSamplingInterval ;
         FDACResolution := 16 ;
         FDACMaxValue := 32767 ;
         FADCResolution := 16 ;
         FADCMaxValue := 32767 ;
         FDACMaxVolts := 10.0 ;
         End;

    end;

    // Create input buffer
    GetMem(DBuf,MaxADCSamples*8) ;

    BoardInitialised := True ;
    Result := True ;

   end ;


procedure MCC_LoadLibrary  ;
{ --------------------------------------
  Load cbw32.dll functions into memory
  --------------------------------------}
var
     DLLName,ProgramDir,SYSDrive : String ; // DLL file paths
     Path : Array[0..255] of Char ;
begin

     ProgramDir := ExtractFilePath(ParamStr(0)) ;
     GetSystemDirectory( Path, High(Path) ) ;
     SYSDrive := ExtractFileDrive(String(Path)) ;

     DLLName := SYSDrive + '\Program Files (x86)\Measurement Computing\DAQ\cbw32.dll' ;
     if not FileExists( DLLName ) then DLLName := 'cbw32.dll' ;

     LibraryHnd := LoadLibrary( PChar(DLLName) ) ;
     if Integer(LibraryHnd) < 0 then
        begin
        ShowMessage('Unable to load library: ' + DLLName ) ;
        LibraryLoaded := False ;
        Exit ;
        end ;

     @cbGetDaqDeviceInventory := MCC_LoadProcedure( LibraryHnd, 'cbGetDaqDeviceInventory' ) ;
     @cbAChanInputMode := MCC_LoadProcedure( LibraryHnd, 'cbAChanInputMode' ) ;
     @cbAInputMode := MCC_LoadProcedure( LibraryHnd, 'cbAInputMode' ) ;
     @cbDeclareRevision := MCC_LoadProcedure( LibraryHnd, 'cbDeclareRevision' ) ;
     @cbGetBoardName := MCC_LoadProcedure( LibraryHnd, 'cbGetBoardName' ) ;
     @cbSetConfigString := MCC_LoadProcedure( LibraryHnd, 'cbSetConfigString' ) ;
     @cbSetConfig := MCC_LoadProcedure( LibraryHnd, 'cbSetConfig' ) ;
     @cbGetConfigString := MCC_LoadProcedure( LibraryHnd, 'cbGetConfigString' ) ;
     @cbGetConfig := MCC_LoadProcedure( LibraryHnd, 'cbGetConfig' ) ;
     @cbOutWord := MCC_LoadProcedure( LibraryHnd, 'cbOutWord' ) ;
     @cbInWord := MCC_LoadProcedure( LibraryHnd, 'cbInWord' ) ;
     @cbOutByte := MCC_LoadProcedure( LibraryHnd, 'cbOutByte' ) ;
     @cbInByte := MCC_LoadProcedure( LibraryHnd, 'cbInByte' ) ;
     @cbWinBufFree := MCC_LoadProcedure( LibraryHnd, 'cbWinBufFree' ) ;
     @cbWinBufAlloc64 := MCC_LoadProcedure( LibraryHnd, 'cbWinBufAlloc64' ) ;
     @cbWinBufAlloc32 := MCC_LoadProcedure( LibraryHnd, 'cbWinBufAlloc32' ) ;
     @cbWinBufAlloc := MCC_LoadProcedure( LibraryHnd, 'cbWinBufAlloc' ) ;
     @cbScaledWinArrayToBuf := MCC_LoadProcedure( LibraryHnd, 'cbScaledWinArrayToBuf' ) ;
     @cbWinArrayToBuf32 := MCC_LoadProcedure( LibraryHnd, 'cbWinArrayToBuf32' ) ;
     @cbWinArrayToBuf := MCC_LoadProcedure( LibraryHnd, 'cbWinArrayToBuf' ) ;
     @cbScaledWinBufToArray := MCC_LoadProcedure( LibraryHnd, 'cbScaledWinBufToArray' ) ;
     @cbScaledWinBufAlloc := MCC_LoadProcedure( LibraryHnd, 'cbScaledWinBufAlloc' ) ;
     @cbWinBufToArray64 := MCC_LoadProcedure( LibraryHnd, 'cbWinBufToArray64' ) ;
     @cbWinBufToArray32 := MCC_LoadProcedure( LibraryHnd, 'cbWinBufToArray32' ) ;
     @cbWinBufToArray := MCC_LoadProcedure( LibraryHnd, 'cbWinBufToArray' ) ;
     @cbMemReadPretrig := MCC_LoadProcedure( LibraryHnd, 'cbMemReadPretrig' ) ;
     @cbMemSetDTMode := MCC_LoadProcedure( LibraryHnd, 'cbMemSetDTMode' ) ;
     @cbStopIOBackground := MCC_LoadProcedure( LibraryHnd, 'cbStopIOBackground' ) ;
     cbGetErrMsg  := MCC_LoadProcedure( LibraryHnd, 'TcbGetErrMsg');
     @cbErrHandling := MCC_LoadProcedure( LibraryHnd, 'cbErrHandling' ) ;
     @cbDOutArray  := MCC_LoadProcedure( LibraryHnd, 'cbDOutArray ' ) ;
     @cbDOutScan := MCC_LoadProcedure( LibraryHnd, 'cbDOutScan' ) ;
     @cbDInArray := MCC_LoadProcedure( LibraryHnd, 'cbDInArray' ) ;
     @cbDOut32 := MCC_LoadProcedure( LibraryHnd, 'cbDOut32' ) ;
     @cbDConfigBit := MCC_LoadProcedure( LibraryHnd, 'cbDConfigBit' ) ;
     @cbDConfigPort := MCC_LoadProcedure( LibraryHnd, 'cbDConfigPort' ) ;
     @cbDOut := MCC_LoadProcedure( LibraryHnd, 'cbDOut' ) ;
     @cbDInScan := MCC_LoadProcedure( LibraryHnd, 'cbDInScan' ) ;
     @cbDBitOut := MCC_LoadProcedure( LibraryHnd, 'cbDBitOut' ) ;
     @cbDIn := MCC_LoadProcedure( LibraryHnd, 'cbDIn' ) ;
     @cbMemWrite := MCC_LoadProcedure( LibraryHnd, 'cbMemWrite' ) ;
     @cbMemRead := MCC_LoadProcedure( LibraryHnd, 'cbMemRead' ) ;
     @cbMemReset := MCC_LoadProcedure( LibraryHnd, 'cbMemReset' ) ;
     @cbDBitIn := MCC_LoadProcedure( LibraryHnd, 'cbDBitIn' ) ;
     @cbCInScan := MCC_LoadProcedure( LibraryHnd, 'cbCInScan' ) ;
     @cbATrig := MCC_LoadProcedure( LibraryHnd, 'cbATrig' ) ;
     @cbAPretrig := MCC_LoadProcedure( LibraryHnd, 'cbAPretrig' ) ;
     @cbAOutScan := MCC_LoadProcedure( LibraryHnd, 'cbAOutScan' ) ;
     @cbAOut := MCC_LoadProcedure( LibraryHnd, 'cbAOut' ) ;
     @cbVOut := MCC_LoadProcedure( LibraryHnd, 'cbVOut' ) ;
     @cbAIn := MCC_LoadProcedure( LibraryHnd, 'cbAIn' ) ;
     @cbVIn := MCC_LoadProcedure( LibraryHnd, 'cbVIn' ) ;
     @cbALoadQueue := MCC_LoadProcedure( LibraryHnd, 'cbALoadQueue' ) ;
     @cbAConvertPretrigData := MCC_LoadProcedure( LibraryHnd, 'cbAConvertPretrigData' ) ;
     @cbAConvertData := MCC_LoadProcedure( LibraryHnd, 'cbAConvertData' ) ;
     @cbSaveConfig := MCC_LoadProcedure( LibraryHnd, 'cbSaveConfig' ) ;
     @cbLoadConfig := MCC_LoadProcedure( LibraryHnd, 'cbLoadConfig' ) ;
     @cbGetRevision := MCC_LoadProcedure( LibraryHnd, 'cbGetRevision' ) ;
     @cbACalibrateData := MCC_LoadProcedure( LibraryHnd, 'cbACalibrateData' ) ;
     @cbGetStatus := MCC_LoadProcedure( LibraryHnd, 'cbGetStatus' ) ;
     @cbStopBackground := MCC_LoadProcedure( LibraryHnd, 'cbStopBackground' ) ;
//     @ := MCC_LoadProcedure( LibraryHnd, '' ) ;

     LibraryLoaded := True ;

     end ;


function  MCC_LoadProcedure(
         Hnd : THandle ;       { Library DLL handle }
         Name : string         { Procedure name within DLL }
         ) : Pointer ;         { Return pointer to procedure }
{ ----------------------------
  Get address of DLL procedure
  ----------------------------}
var
   P : Pointer ;
begin
     P := GetProcAddress(Hnd,PChar(Name)) ;
     if P = Nil then begin
        //ShowMessage(format('nimcaiu.dll- %s not found',[Name])) ;
        end ;
     Result := P ;
     end ;

procedure  MCC_CheckError( Err : Integer ) ;
var
   ErrString : Array[0..255] of ANSIChar ;
begin
     if Err = 0 then Exit ;
     cbGetErrMsg( Err, ErrString ) ;
     ShowMessage( String(ErrString) ) ;
     end ;


procedure MCC_DisableFPUExceptions ;
// ----------------------
// Disable FPU exceptions
// ----------------------
var
    FPUNoExceptions : Set of TFPUException ;
begin
     exit ;
  {   FPUExceptionMask := GetExceptionMask ;
     Include(FPUNoExceptions, exInvalidOp );
     Include(FPUNoExceptions, exDenormalized );
     Include(FPUNoExceptions, exZeroDivide );
     Include(FPUNoExceptions, exOverflow );
     Include(FPUNoExceptions, exUnderflow );
     Include(FPUNoExceptions, exPrecision );
     SetExceptionMask( FPUNoExceptions ) ;}

     end ;


procedure MCC_EnableFPUExceptions ;
// ----------------------
// Disable FPU exceptions
// ----------------------
begin
     exit ;
{     SetExceptionMask( FPUExceptionMask ) ;}
     end ;


function  MCC_GetLabInterfaceInfo(
          Var DeviceList : TStringList ;
          var DeviceNumber : Integer ;  // Device #
          var ADCInputMode : Integer ;  // Analog input mode
          var BoardModel : string ; { Laboratory interface model name/number }
          var ADCMaxChannels : Integer ; // No. of A/D channels
          var ADCMinSamplingInterval : Double ; { Smallest sampling interval }
          var ADCMaxSamplingInterval : Double ; { Largest sampling interval }
          var ADCMinValue : Integer ; { Negative limit of binary ADC values }
          var ADCMaxValue : Integer ; { Positive limit of binary ADC values }
          var DACMaxChannels : Integer ; // No. of D/A channels
          var DACMinValue : Integer ; { Negative limit of binary DAC values }
          var DACMaxValue : Integer ; { Positive limit of binary DAC values }
          var ADCVoltageRanges : Array of single ; { A/D voltage range option list }
          var NumADCVoltageRanges : Integer ; { No. of options in above list }
          var DACMaxVolts : Single ;{ Positive limit of bipolar D/A voltage range }
          var DACMinUpdateInterval : Double ; {Min. D/A update interval }
          var DigMinUpdateInterval : Double ; {Min. digital update interval }
          var DigMaxUpdateInterval : Double ; {Min. digital update interval }
          var DigUpdateStep : Integer ; // Digital output step interval
          var ADCBufferLimit : Integer  // Max. no. of A/D samples/buffer
          ) : Boolean ;
const
    NumVRanges = 10 ;
    iMaxDev = 5 ;
    DefaultTimeOut = 1.0 ;
var
    VRanges : Array[0..NumVRanges-1] of Double ;

    ADCTask : Integer ;
    ChannelName : ANSIString ;
    DValue : Double ;
    i,ADCModeCode : Integer ;
    Err : Integer ;
    ADCInputModes : Array[0..2] of Integer ;
begin

    Result := False ;

    // Find list of an available devices
    MCC_GetDeviceList( DeviceList ) ;
    if DeviceList.Count < 1 then begin
       ShowMessage('No Measurment Computing interface cards detected!') ;
       exit ;
       end ;

    // Check selected device
    DeviceNumber := Min(Max(0,DeviceNumber),DeviceList.Count-1) ;
    FDeviceNumber := DeviceNumber ;
//    if not MCC_DeviceExists(DeviceName) then begin
//       ShowMessage(format('Unable to detect device %s',[DeviceName])) ;
//       exit ;
//       end ;

    if not BoardInitialised then MCC_InitialiseBoard ;
    if not BoardInitialised then Exit ;

    // set A/D input mode and determine no. channels
    ADCModeCode := MCC_GetADCInputModeCode( ADCInputMode ) ;
 //   ADCMaxChannels := MCC_CheckMaxADCChannels( ADCModeCode ) ;

    // If mode not supported, select another
    if ADCMaxChannels <= 0 then begin
       ADCInputModes[0] := imDifferential ;
       ADCInputModes[1] := imSingleEnded ;
       ADCInputModes[2] := imSingleEndedRSE ;
       i := 0 ;
       while (ADCMaxChannels <= 0) and (i <= High(ADCInputModes)) do begin
          ADCInputMode := ADCInputModes[i] ;
          ADCModeCode := MCC_GetADCInputModeCode( ADCInputMode ) ;
  //        ADCMaxChannels := MCC_CheckMaxADCChannels( ADCModeCode ) ;
          Inc(i) ;
          end ;
       //ShowMessage('WARNING! A/D input mode not supported by this device.') ;
       end ;

    FADCNumChannels := ADCMaxChannels ;

    ADCMinSamplingInterval := FADCMinSamplingInterval ;
    ADCMaxSamplingInterval := FADCMaxSamplingInterval ;

    DACMinUpdateInterval := FDACMinUpdateInterval ;
    DigMinUpdateInterval := FDigMinUpdateInterval ;
    DigMaxUpdateInterval := FDigMaxUpdateInterval ;

    DigUpdateStep := 1 ;
    ADCBufferLimit := MaxADCSamples ; //128000 ;

    ADCMaxValue := FADCMaxValue ;
    ADCMinValue := -FADCMaxValue -1 ;
    DACMaxValue := FDACMaxValue ;
    DACMinValue := -FDACMaxValue -1 ;
    DACMaxVolts := FDACMaxVolts ;

    // Possible A/D voltage ranges
    VRanges[0] := 10.0 ;
    VRanges[1] := 5.0 ;
    VRanges[2] := 2.5 ;
    VRanges[3] := 1.25 ;
    VRanges[4] := 1.0 ;
    VRanges[5] := 0.5 ;
    VRanges[6] := 0.25 ;
    VRanges[7] := 0.2 ;
    VRanges[8] := 0.1 ;
    VRanges[9] := 0.05 ;

    ADCVoltageRanges[0] := 10.0 ;
    NumADCVoltageRanges := 1 ;

    FADCMaxVolts := ADCVoltageRanges[0] ;

    MCC_EnableFPUExceptions ;

    if FADCNumChannels > 0 then begin
       BoardModel := FBoardModel + format(' (%d ch. %d bit +-%.3gV ADC, ',
                                  [FADCNumChannels,FADCResolution,FADCMaxVolts]) ;
       end
    else begin
       BoardModel := FBoardModel + '(No ADC, ' ;
       end ;

    DACMaxChannels := FDACNumChannels ;
    if FDACNumChannels > 0 then begin
       BoardModel := BoardModel + format('%d ch. %d bit +-%.3gV DAC)',
                                  [FDACNumChannels,FDACResolution,FDACMaxVolts]) ;
       end
    else begin
       BoardModel := BoardModel + 'No DAC)' ;
       end ;

    Result := True ;

    end ;


procedure MCC_GetChannelOffsets(
          ADCInputMode : Integer ;
          var Offsets : Array of Integer ;
          var NumChannels : Integer
          ) ;
// -------------------------------
// Get channel interleave sequence
// -------------------------------
var
    i : Integer ;
begin

    for i := 0 to High(Offsets) do Offsets[i] := i ;

    end ;


procedure MCC_CheckADCSamplingInterval(
               var SamplingInterval : double ;
               NumADCChannels : Integer ;
               ADCInputMode : Integer
               ) ;
// ------------------------------------------------
// Set sampling interval to nearest supported value
// ------------------------------------------------
var
    ChannelList : ANSIString ;
    SamplingRate : Double ;
    ActualSamplingRate : Double ;
    Err : Integer ;
    ADCModeCode : Integer ;
begin

     if not BoardInitialised then MCC_InitialiseBoard ;
     if not BoardInitialised then Exit ;

     if ADCActive then begin
        SamplingInterval := ADCSamplingIntervalInUse ;
        Exit ;
        end ;

     // Create A/D task
 {    MCC_CheckError( DAQmxCreateTask( '', ADCTaskHandle ) ) ;

     // Select A/D input channels
     ChannelList := format( DeviceName + '/AI0:%d', [NumADCChannels-1] ) ;

     ADCModeCode := MCC_GetADCInputModeCode( ADCInputMode ) ;

     MCC_CheckError( DAQmxCreateAIVoltageChan( ADCTaskHandle,
                                                PANSIChar(ChannelList),
                                                nil ,
                                                ADCModeCode,
                                                -FADCMaxVolts,
                                                FADCMaxVolts,
                                                DAQmx_Val_Volts,
                                                nil));

     // Set sampling rate (ensuring that it can be supported by board)

     SamplingRate := 1.0 / Min(Max( SamplingInterval,
                                    FADCMinSamplingInterval),
                                    FADCMaxSamplingInterval) ;
     ActualSamplingRate := 1.0 ;
     Repeat

     SamplingRate := 1.0 / SamplingInterval ;

        // Set sampling rate
        Err := DAQmxCfgSampClkTiming( ADCTaskHandle,
                               nil,
                               SamplingRate,
                               DAQmx_Val_Rising,
                               DAQmx_Val_FiniteSamps,
                               2);
        MCC_CheckError(Err);
        if Err <> 0 then break ;

        // Read rate back from board
        Err := DAQmxGetSampClkRate( ADCTaskHandle, ActualSamplingRate ) ;
        if Err <> 0 then SamplingRate := SamplingRate*0.75 ;
        Until Err = 0 ;

     // Return actual sampling interval
     SamplingInterval := 1.0 / ActualSamplingRate ;

     // Clear task
     MCC_CheckError( DAQmxClearTask(ADCTaskHandle)) ;

     MCC_EnableFPUExceptions ; }

     end ;


function MCC_ADCToMemory(
          var ADCBuf : Array of SmallInt  ;  { A/D sample buffer (OUT) }
          nChannels : Integer ;              { Number of A/D channels (IN) }
          nSamples : Integer ;               { Number of A/D samples ( per channel) (IN) }
          var SamplingInterval : Double ;    { Sampling interval (s) (IN) }
          ADCVoltageRanges : Array of Single ;{ A/D input voltage range for each channel (V) (IN) }
          TriggerMode : Integer ;             // Sweep trigger mode
          ADCExternalTriggerActiveHigh : Boolean ;
          CircularBuffer : Boolean ;          { Repeated sampling into buffer (IN) }
          ADCInputMode : Integer ;             // A/D input mode (differential/single ended_
          ADCChannelInputNumber : Array of Integer
          ) : Boolean ;                      { Returns TRUE indicating A/D started }
// ------------------------------------------
// Sample A/D channels and transfer to buffer
// ------------------------------------------
var
    SampleMode : Integer ;
    ChannelList,Channel : ANSIString ;
    ADCVoltageRange : Double ;
    SamplingRate : Double ;
    TriggerSource : ANSIString ;    // Trigger source terminal for A/D clock
    TriggerPolarity : Integer ; // Trigger TTL polarity
    ch : Integer ;
    ADCModeCode : Integer ;
    Options : Cardinal ;
    Rate : Cardinal ;
    InputMode : Integer ;
begin
     Result := False ;
     if not BoardInitialised then MCC_InitialiseBoard ;
     if not BoardInitialised then Exit ;
     if FADCNumChannels <= 0 then Exit ;

     // Stop any running A/D task
     MCC_StopADC ;

     Options := BACKGROUND or BLOCKIO or SCALEDATA ;
     // Circular buffer mode
     if CircularBuffer then Options := Options or CONTINUOUS ;
     // External trigger mode
     if TriggerMode = tmExtTrigger then Options := Options or EXTTRIGGER ;

     // Free buffer (if allocated)
     if ADCBufHnd <> 0 then MCC_CheckError(cbWinBufFree(ADCBufHnd)) ;
     ADCBufHnd := 0 ;

     ADCBufHnd := cbScaledWinBufAlloc(nChannels*nSamples);
     if ADCBufHnd = 0 then
        begin
        ShowMessage('MCC_ADCToMemory: Unable to allocate windows buffer!');
        exit ;
        end;

     // Set channel input mode
     if ADCInputMode = imDifferential then InputMode := DIFFERENTIAL
                                      else InputMode := SINGLE_ENDED ;
     MCC_CheckError( cbAInputMode( BoardNum, InputMode ));

     Rate := Round( 1.0 / SamplingInterval ) ;
     // Select update rate
     if Rate <= 1000.0 then
        begin
        Rate := Round( 1000.0 / SamplingInterval ) ;
        Options := Options or HIGHRESRATE ;
        end
     else Rate := Round( 1.0 / SamplingInterval ) ;

     // Set A/D input scan
     MCC_CheckError(cbAInScan( BoardNum,
                               0, nChannels-1, nSamples, Rate,
                               MCC_ADRangeCode(ADCVoltageRanges[0]),
                               ADCBufHnd,
                               Options ));

    ADCActive := True ;
    FADCPointer := 0 ;
    FADCNumChannels := nChannels ;
    FADCNumSamples := nSamples ;
    FADCNumSamplesAcquired := 0 ;

    end ;

function MCC_GetADCInputModeCode( ADCInputMode : Integer ) : Integer ;
// ---------------------------------------------
// Get NI A/D input mode code from SESLABIO mode
// ---------------------------------------------
begin
  {   case ADCInputMode of
        imDifferential,imBNC2110 : begin
           if ANSIContainsText(FBoardModel,'611') then Result := DAQmx_Val_PseudoDiff
                                                  else Result := DAQmx_Val_Diff ;
            end ;
        imSingleEndedRSE : Result := DAQmx_Val_RSE ;
        else Result := DAQmx_Val_NRSE ;
        end ;}
     end ;

function MCC_ADRangeCode( VRange : single ) : Integer ;
// ------------------------------------------------
// Return A/D voltage range code for selected range
// ------------------------------------------------
begin

    VRange := VRange - 1E-4 ;
    if Vrange >= 60.0 then Result := BIP60VOLTS
    else if Vrange >= 30.0 then Result := BIP30VOLTS
    else if Vrange >= 15.0 then Result := BIP15VOLTS
    else if Vrange >= 10.0 then Result := BIP10VOLTS
    else if Vrange >= 5.0 then Result := BIP5VOLTS
    else if Vrange >= 4.0 then Result := BIP4VOLTS
    else if Vrange >= 2.5 then Result := BIP2PT5VOLTS
    else if Vrange >= 2.0 then Result := BIP2VOLTS
    else if Vrange >= 1.67 then Result := BIP1PT67VOLTS
    else if Vrange >= 1.25 then Result := BIP1PT25VOLTS
    else if Vrange >= 1.0 then Result := BIP1VOLTS
    else if Vrange >= 0.625 then Result := BIPPT625VOLTS
    else if Vrange >= 0.5 then Result := BIPPT5VOLTS
    else if Vrange >= 0.25 then Result := BIPPT25VOLTS
    else if Vrange >= 0.2 then Result := BIPPT2VOLTS
    else if Vrange >= 0.125 then Result := BIPPT125VOLTS
    else if Vrange >= 0.1 then Result := BIPPT1VOLTS
    else if Vrange >= 0.078 then Result := BIPPT078VOLTS
    else if Vrange >= 0.05 then Result := BIPPT05VOLTS
    else if Vrange >= 0.01 then Result := BIPPT01VOLTS
    else Result := BIPPT005VOLTS

    end ;


procedure MCC_GetADCSamples(
          var ADCBuf : Array of SmallInt  ;
          var OutPointer : Integer ;
          var ADCChannelVoltageRanges : Array of Single
          ) ;
// -------------------------------------------------------------
// Get latest A/D samples acquired and transfer to memory buffer
// -------------------------------------------------------------
var
    i,j,ch : Integer ;
    ADCBufNumSamples : Integer ;
    ADCBufEnd : Integer ;
    ScaledValue,MaxVal,MinVal : Integer ;
    VScale : Array[0..MaxADCChannels-1] of Single ;
    Status : Integer ;
    CurrentCount,NewADCPointer,nPoints : Integer ;
begin

    if not ADCActive then Exit ;

    ADCBufNumSamples := FADCNumSamples*FADCNumChannels ;
    ADCBufEnd := FADCNumSamples*FADCNuMChannels - 1 ;

    if (not FADCCircularBuffer) and (FADCNumSamplesAcquired >= ADCBufNumSamples) then Exit ;

    // Get current bufffer pointer
    MCC_CheckError(cbGetStatus( BoardNum, Status, CurrentCount, NewADCPointer, AIFUNCTION)) ;

    if (NewADCPointer < 0) or (NewADCPointer = FADCPointer) then Exit ;

    if NewADCPointer > FADCPointer then
       begin
       nPoints := NewADCPointer - FADCPointer + FADCNumChannels - 1 ;
       MCC_CheckError(cbScaledWinBufToArray( ADCBufHnd, DBuf, FADCPointer, nPoints)) ;
       end
    else begin
       nPoints := ADCBufNumSamples - FADCPointer ;
       MCC_CheckError(cbScaledWinBufToArray( ADCBufHnd, DBuf, FADCPointer, nPoints)) ;
       end ;

    MaxVal := FADCMaxValue - 1 ;
    MinVal := FADCMinValue + 1 ;

    for ch := 0 to FADCNumChannels-1 do VScale[ch] := FADCMaxValue/ADCChannelVoltageRanges[ch] ;
    j := 0 ;
    for i := 0 to nPoints-1 do begin
      for ch := 0 to FADCNumChannels-1 do begin
        ScaledValue := Round(DBuf[j]*VScale[ch]) ;
        if ScaledValue < MinVal then ScaledValue := MinVal ;
        if ScaledValue > MaxVal then ScaledValue := MaxVal ;
        ADCBuf[FADCPointer] := ScaledValue ;
        Inc(FADCPointer) ;
        inc(j) ;
        end;
      FADCNumSamplesAcquired := FADCPointer ;
      if FADCPointer > ADCBufEnd then FADCPointer := 0 ;
      end ;

    OutPointer := FADCPointer ;

    end ;


function MCC_StopADC : Boolean ;
// ----------------------------------
// Stop a running A/D conversion task
// ----------------------------------
begin
    Result := False ;
    if not BoardInitialised then Exit ;
    if not ADCActive then Exit ;
    if FADCNumChannels <= 0 then Exit ;

     // Stop running A/D background task
     MCC_CheckError( cbStopBackground( BoardNum, AIFUNCTION )) ;
     ADCActive := False ;

     end ;


procedure MCC_CheckDACSamplingInterval(
               var SamplingInterval : double ;
               NumDACChannels : Integer
               ) ;
// ------------------------------------------------
// Set DAC sampling interval to nearest supported value
// ------------------------------------------------
var
    ChannelList : ANSIString ;
    SamplingRate : Double ;
    ActualSamplingRate : Double ;
    Err : Integer ;
    TaskHandle : Integer ;
begin

     if not BoardInitialised then MCC_InitialiseBoard ;
     if not BoardInitialised then Exit ;

     if DACActive then begin
        SamplingInterval := DACUpdateIntervalInUse ;
        Exit ;
        end ;

     if not FDACClockSupported then begin ;
        SamplingInterval := FDACMinUpdateInterval ;
        Exit ;
        end ;

     end ;


function MCC_MemoryToDAC(
            var DACBuf : Array of SmallInt  ;
            nChannels : Integer ;
            nPoints : Integer ;
            UpdateInterval : Double ;
            ExternalTrigger : Boolean ;
            RepeatWaveform : Boolean
            ) : Boolean ;
// ------------------------------------------
// Generate waveform output to D/A converters
// ------------------------------------------
var
    i,Err : Integer ;
    VScale : Double ;
    UpdateRate : Double ;
    VDACS : Array[0..31] of Single ;
    Rate,Options : Cardinal ;
begin

    Result := False ;
    if not BoardInitialised then MCC_InitialiseBoard ;
    if not BoardInitialised then Exit ;
    if FDACNumChannels <= 0 then Exit ;

    // Stop any running D/A task
     MCC_StopDAC ;

    // If clocked D/A not supported, write initial D/A values
    if not FDACClockSupported then begin ;
       VScale := FDACMaxVolts / (FDACMaxValue) ;
       for i := 0 to nChannels-1 do VDACS[i] := DACBuf[i]*VScale ;
       MCC_WriteDACS( VDACS, nChannels ) ;
       Exit ;
       end ;

     // Free buffer (if allocated)
     if DACBufHnd <> 0 then MCC_CheckError(cbWinBufFree(DACBufHnd)) ;
     DACBufHnd := 0 ;
     // Allocate windows data buffer
     DACBufHnd := cbScaledWinBufAlloc(nChannels*nPoints);
     if DACBufHnd = 0 then
        begin
        ShowMessage('MCC_DACToMemory: Unable to allocate windows buffer!');
        exit ;
        end;

     // Copy voltage waveform to windows buffer
     VScale := FDACMaxVolts / (FDACMaxValue) ;
     for i := 0 to (nChannels*nPoints)-1 do DBuf^[i] := DACBuf[i]*VScale ;
     MCC_CheckError(cbScaledWinBufToArray( DACBufHnd, DBuf, 0, nChannels*nPoints)) ;

     // D/A ouput options
     Options := BACKGROUND or SCALEDATA or ADCCLOCKTRIG;
     // Circular buffer mode
     if RepeatWaveform then Options := Options or CONTINUOUS ;
     // External trigger mode
     if ExternalTrigger then Options := Options or EXTTRIGGER ;

     // Select update rate
     if Rate <= 1000.0 then
        begin
        Rate := Round( 1000.0 / UpdateRate ) ;
        Options := Options or HIGHRESRATE ;
        end
     else Rate := Round( 1.0 / UpdateRate ) ;

     // Set D/A output scan
     MCC_CheckError(cbAOutScan( BoardNum,
                               0, nChannels-1, nPoints, Rate,
                               BIP10VOLTS,
                               DACBufHnd,
                               Options ));

     DACActive := True ;

     end ;


function MCC_StopDAC : Boolean ;
// ----------------------------------
// Stop a running A/D conversion task
// ----------------------------------
begin
    Result := False ;
    if not BoardInitialised then Exit ;
    if not DACActive then Exit ;
    if FDACNumChannels <= 0 then Exit ;
    if not FDACClockSupported then Exit ;

     // Stop running D/A background task
     MCC_CheckError( cbStopBackground( BoardNum, AOFUNCTION )) ;

     DACActive := False ;

     end ;


function MCC_MemoryToDIG(
            var DIGBuf : Array of SmallInt  ;
            nPoints : Integer ;
            UpdateInterval : Double ;
            RepeatWaveform : Boolean
            ) : Boolean ;
// ------------------------------------------
// Generate timed pulse pattern to digital outputs
// ------------------------------------------
var
    i : Integer ;
    Rate : Cardinal ;
    Options : Cardinal ;
begin

    Result := False ;
    if not BoardInitialised then MCC_InitialiseBoard ;
    if not BoardInitialised then Exit ;
    if not FDigClockSupported then Exit ;

    // Stop any running digital output task
     MCC_StopDIG ;

     // Free buffer (if allocated)
     if DIGBufHnd <> 0 then MCC_CheckError(cbWinBufFree(DIGBufHnd)) ;
     DIGBufHnd := 0 ;
     // Allocate windows data buffer
     DIGBufHnd := cbScaledWinBufAlloc(nPoints);
     if DIGBufHnd = 0 then
        begin
        ShowMessage('MCC_DIGToMemory: Unable to allocate windows buffer!');
        exit ;
        end;

     // Copy digital output bytes to windows buffer
     for i := 0 to nPoints-1 do PByteArray(DIGBufHnd)^[i] := DIGBuf[i] ;

     // D/A ouput options
     Options := BACKGROUND ;
     // Circular buffer mode
     if RepeatWaveform then Options := Options or CONTINUOUS ;

     // Select update rate
     Rate := Round( 1.0 / UpdateInterval ) ;

     // Set D/A output scan
     MCC_CheckError(cbDOutScan( BoardNum,
                                FIRSTPORTA, nPoints, Rate,
                                DIGBufHnd,
                                Options ));

     DigActive := True ;

     end ;


function MCC_StopDIG : Boolean ;
// --------------------------------
// Stop a running digital I/O  task
// --------------------------------
begin

    Result := False ;
    if not BoardInitialised then Exit ;
    if not DIGActive then Exit ;
    if not FDigClockSupported then Exit ;

     // Stop running digital out background task
     MCC_CheckError( cbStopBackground( BoardNum, DOFUNCTION )) ;

     DIGActive := False ;
     Result := DIGActive ;

     end ;



procedure MCC_WriteDACs(
               DACVolts : array of Single ;
               nChannels : Integer
               ) ;
// -----------------------------------
// Update D/A output channels voltages
// -----------------------------------
var
  ch: Integer;
begin

     if not BoardInitialised then MCC_InitialiseBoard ;
     if not BoardInitialised then Exit ;
     if FDACNumChannels <= 0 then Exit ;

     // Stop any running D/A task
     MCC_StopDAC ;

     for ch := 0 to nChannels-1 do
         begin
         MCC_CheckError(cbVOut( BoardNum,ch,BIP10VOLTS,DACVolts[ch])) ;
         end;

     end ;


function MCC_ReadADC(
              Channel : Integer ;        // A/D channel to be read
              ADCVoltageRange : Single ; // A/D input voltage range
              ADCInputMode : Integer
              ) : Integer ;              // Returns raw A/D reading
// ----------------
// Read A/D channel
// ----------------
var
    fVolts : Single ;
    InputMode : Integer ;
begin
     Result := 0 ;
     if not BoardInitialised then MCC_InitialiseBoard ;
     if not BoardInitialised then Exit ;
     if FADCNumChannels <= 0 then Exit ;

     // Stop any running A/D task
     MCC_StopADC ;

     // Set channel input mode
     if ADCInputMode = imDifferential then InputMode := DIFFERENTIAL
                                      else InputMode := SINGLE_ENDED ;
     MCC_CheckError( cbAInputMode( BoardNum, InputMode ));

     // Read channel
     MCC_CheckError(cbVIn(BoardNum,Channel, MCC_ADRangeCode(ADCVoltageRange), fVolts, 0));

     Result := Round((fVolts/ADCVoltageRange)*FADCMaxValue) ;

     end ;


procedure MCC_WriteToDigitalOutPutPort(
          Pattern : Integer
          ) ;
// ------------------------------
// Write bits to digital O/P port
// ------------------------------
var
    DataValue : Word ;
begin

     if not BoardInitialised then MCC_InitialiseBoard ;
     if not BoardInitialised then Exit ;

     DataValue := Pattern ;
     MCC_CheckError(cbDOut( BoardNum, FIRSTPORTA, DataValue));

     end ;


function MCC_ReadDigitalInputPort : Integer ;
// ------------------------------
// Read bits from digital I/P port
// ------------------------------
var
    Pattern : Integer ;
    Err : Integer ;
begin
     Result := 0 ;
     if not BoardInitialised then MCC_InitialiseBoard ;
     if not BoardInitialised then Exit ;

     MCC_StopDIG ;

     Result := Pattern ;

     end ;


function MCC_GetValidExternalTriggerPolarity(
         Value : Boolean // TRUE=Active High, False=Active Low
         ) : Boolean ;
// -----------------------------------------------------------------------
// Check that the selected External Trigger polarity is supported by board
// -----------------------------------------------------------------------
begin
    // Both active high and low supported
    Result := Value ;
    end ;


procedure MCC_CloseLaboratoryInterface ;
// -------------------------------
// Close down laboratory interface
// -------------------------------
begin

    if not BoardInitialised then Exit ;

    // Stop any running A/D task
    MCC_StopADC ;
    // stop any running D/A task
    MCC_StopDAC ;
    // stop any running digital task
    MCC_StopDIG ;

    //FreeMem(InBuf) ;
    FreeMem( DBuf ) ;

    // Free DLL library
    if LibraryLoaded then FreeLibrary( LibraryHnd ) ;
    LibraryLoaded := False ;
    BoardInitialised := False ;

    end ;


end.
