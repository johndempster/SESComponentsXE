unit PCOUnit;
// -------------------------------
// PCO Camera Interface library
// -------------------------------
// 24.07.18

interface

uses WinTypes,sysutils, classes, dialogs, mmsystem, messages, controls, math, strutils ;
const
    PCOAPIMaxBufs = 10240 ;
    PCOAPINumBufs = 16 ;
    PCOAPIAOIHeightSteps = 2 ;

// ------------------------------------------------------------------------ //
// -- Defines for Get Camera Type Command: -------------------------------- //
// ------------------------------------------------------------------------ //

// pco.camera types
      CAMERATYPE_PCO1200HS     = $0100 ;
      CAMERATYPE_PCO1300       = $0200 ;
      CAMERATYPE_PCO1600       = $0220 ;
      CAMERATYPE_PCO2000       = $0240 ;
      CAMERATYPE_PCO4000       = $0260 ;

// pco.1300 types
      CAMERATYPE_ROCHEHTC      = $0800 ;// Roche OEM
      CAMERATYPE_284XS         = $0800 ;
      CAMERATYPE_KODAK1300OEM  = $0820 ;// Kodak OEM

// pco.1400 types
      CAMERATYPE_PCO1400       = $0830  ;
      CAMERATYPE_NEWGEN        = $0840 ;// Roche OEM
      CAMERATYPE_PROVEHR       = $0850 ;// Zeiss OEM

// pco.usb.pixelfly
      CAMERATYPE_PCO_USBPIXELFLY        = $0900 ;


// pco.dimax types
      CAMERATYPE_PCO_DIMAX_STD           = $1000 ;
      CAMERATYPE_PCO_DIMAX_TV            = $1010 ;

      CAMERATYPE_PCO_DIMAX_AUTOMOTIVE    = $1020 ;  // obsolete and not used for the pco.dimax, please remove from your sources!
      CAMERATYPE_PCO_DIMAX_CS            = $1020 ;  // code is now used for pco.dimax CS

      CAMERASUBTYPE_PCO_DIMAX_Weisscam   = $0064 ;  // 100 = Weisscam, all features
      CAMERASUBTYPE_PCO_DIMAX_HD         = $80FF ;  // pco.dimax HD
      CAMERASUBTYPE_PCO_DIMAX_HD_plus    = $C0FF ;  // pco.dimax HD+
      CAMERASUBTYPE_PCO_DIMAX_X35        = $00C8 ;  // 200 = Weisscam/P+S HD35

      CAMERASUBTYPE_PCO_DIMAX_HS1        = $207F  ;
      CAMERASUBTYPE_PCO_DIMAX_HS2        = $217F  ;
      CAMERASUBTYPE_PCO_DIMAX_HS4        = $237F  ;

      CAMERASUBTYPE_PCO_DIMAX_CS_AM_DEPRECATED      = $407F ;
      CAMERASUBTYPE_PCO_DIMAX_CS_1       = $417F ;
      CAMERASUBTYPE_PCO_DIMAX_CS_2       = $427F ;
      CAMERASUBTYPE_PCO_DIMAX_CS_3       = $437F ;
      CAMERASUBTYPE_PCO_DIMAX_CS_4       = $447F ;


// pco.sensicam types                   // tbd., all names are internal ids
      CAMERATYPE_SC3_SONYQE    = $1200 ;// SC3 based - Sony 285
      CAMERATYPE_SC3_EMTI      = $1210 ;// SC3 based - TI 285SPD
      CAMERATYPE_SC3_KODAK4800 = $1220 ;// SC3 based - Kodak KAI-16000



// pco.edge types
      CAMERATYPE_PCO_EDGE                  = $1300 ;// pco.edge 5.5 (Sensor CIS2521) Interface: CameraLink , rolling shutter
      CAMERATYPE_PCO_EDGE_42               = $1302 ;// pco.edge 4.2 (Sensor CIS2020) Interface: CameraLink , rolling shutter
      CAMERATYPE_PCO_EDGE_GL               = $1310 ;// pco.edge 5.5 (Sensor CIS2521) Interface: CameraLink , global  shutter
      CAMERATYPE_PCO_EDGE_USB3             = $1320 ;// pco.edge     (all sensors   ) Interface: USB 3.0    ,(all shutter modes)
      CAMERATYPE_PCO_EDGE_HS               = $1340 ;// pco.edge     (all sensors   ) Interface: high speed ,(all shutter modes)
      CAMERATYPE_PCO_EDGE_MT               = $1304 ;// pco.edge MT2 (all sensors   ) Interface: CameraLink Base, rolling shutter


      CAMERASUBTYPE_PCO_EDGE_SPRINGFIELD   = $0006 ;
      CAMERASUBTYPE_PCO_EDGE_31            = $0031 ;
      CAMERASUBTYPE_PCO_EDGE_42            = $0042 ;
      CAMERASUBTYPE_PCO_EDGE_55            = $0055 ;
      CAMERASUBTYPE_PCO_EDGE_DEVELOPMENT   = $0100 ;
      CAMERASUBTYPE_PCO_EDGE_X2            = $0200 ;
      CAMERASUBTYPE_PCO_EDGE_RESOLFT       = $0300 ;
      CAMERASUBTYPE_PCO_EDGE_GOLD          = $0FF0 ;
      CAMERASUBTYPE_PCO_EDGE_DUAL_CLOCK    = $000D ;
      CAMERASUBTYPE_PCO_EDGE_DICAM         = $DC00 ;
      CAMERASUBTYPE_PCO_EDGE_42_LT         = $8042 ;


// pco.flim types
      CAMERATYPE_PCO_FLIM      = $1400 ;// pco.flim

// pco.flow types
      CAMERATYPE_PCO_FLOW      = $1500 ;// pco.flow

// pco.panda types
      CAMERATYPE_PCO_PANDA     = $1600 ;// pco.panda

//      CAMERATYPE_PCOUPDATE     = $FFFF   // indicates Camera in update mode!

// ------------------------------------------------------------------------ //
// -- Defines for Interfaces ---------------------------------------------- //
// ------------------------------------------------------------------------ //
// These defines are camera internal defines and are not SDK related!
      INTERFACE_FIREWIRE       = $0001 ;
      INTERFACE_CAMERALINK     = $0002 ;
      INTERFACE_USB            = $0003 ;
      INTERFACE_ETHERNET       = $0004 ;
      INTERFACE_SERIAL         = $0005 ;
      INTERFACE_USB3           = $0006 ;
      INTERFACE_CAMERALINKHS   = $0007 ;
      INTERFACE_COAXPRESS      = $0008 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get Camera Health Status Command: ----------------------- //
// ------------------------------------------------------------------------ //

// mask bits: evaluate as follows: if (stat & ErrorSensorTemperature) ... //

      WARNING_POWERSUPPLYVOLTAGERANGE = $00000001 ;
      WARNING_POWERSUPPLYTEMPERATURE  = $00000002 ;
      WARNING_CAMERATEMPERATURE       = $00000004 ;
      WARNING_SENSORTEMPERATURE       = $00000008 ;
      WARNING_EXTERNAL_BATTERY_LOW    = $00000010 ;
      WARNING_OFFSET_REGULATION_RANGE = $00000020 ;

      WARNING_CAMERARAM               = $00020000 ;


      ERROR_POWERSUPPLYVOLTAGERANGE   = $00000001 ;
      ERROR_POWERSUPPLYTEMPERATURE    = $00000002 ;
      ERROR_CAMERATEMPERATURE         = $00000004 ;
      ERROR_SENSORTEMPERATURE         = $00000008 ;

      ERROR_EXTERNAL_BATTERY_LOW      = $00000010 ;
      ERROR_FIRMWARE_CORRUPTED        = $00000020 ;

      ERROR_CAMERAINTERFACE           = $00010000 ;
      ERROR_CAMERARAM                 = $00020000 ;
      ERROR_CAMERAMAINBOARD           = $00040000 ;
      ERROR_CAMERAHEADBOARD           = $00080000 ;


      STATUS_DEFAULT_STATE            = $00000001  ;
      STATUS_SETTINGS_VALID           = $00000002  ;
      STATUS_RECORDING_ON             = $00000004  ;
      STATUS_READ_IMAGE_ON            = $00000008  ;
      STATUS_FRAMERATE_VALID          = $00000010  ;
      STATUS_SEQ_STOP_TRIGGERED       = $00000020  ;
      STATUS_LOCKED_TO_EXTSYNC        = $00000040  ;
      STATUS_EXT_BATTERY_AVAILABLE    = $00000080  ;
      STATUS_IS_IN_POWERSAVE          = $00000100  ;
      STATUS_POWERSAVE_LEFT           = $00000200  ;
      STATUS_LOCKED_TO_IRIG           = $00000400  ;
      STATUS_IS_IN_BOOTLOADER         = $80000000  ;


// ------------------------------------------------------------------------ //
// -- Defines for Get Camera Description Command: ------------------------- //
// ------------------------------------------------------------------------ //

  // Description type

      DESCRIPTION_STANDARD   = $0000 ;        // Standard Descripton
      DESCRIPTION_2          = $0001 ;        // Descripton nr. 2

// ------------------------------------------------------------------------ //
// -- Sensor type definitions --------------------------------------------- //
// ------------------------------------------------------------------------ //
  // Sensor Type
  // ATTENTION: Lowest bit is reserved for COLOR CCDs
  // In case a new color CCD is added the lowest bit MUST be set!!!
      SENSOR_ICX285AL           = $0010 ;     // Sony
      SENSOR_ICX285AK           = $0011 ;     // Sony
      SENSOR_ICX263AL           = $0020 ;     // Sony
      SENSOR_ICX263AK           = $0021 ;     // Sony
      SENSOR_ICX274AL           = $0030 ;     // Sony
      SENSOR_ICX274AK           = $0031 ;     // Sony
      SENSOR_ICX407AL           = $0040 ;     // Sony
      SENSOR_ICX407AK           = $0041 ;     // Sony
      SENSOR_ICX414AL           = $0050 ;     // Sony
      SENSOR_ICX414AK           = $0051 ;     // Sony
      SENSOR_ICX407BLA          = $0060 ;     // Sony UV type

      SENSOR_KAI2000M           = $0110 ;    // Kodak
      SENSOR_KAI2000CM          = $0111 ;    // Kodak
      SENSOR_KAI2001M           = $0120 ;    // Kodak
      SENSOR_KAI2001CM          = $0121 ;    // Kodak
      SENSOR_KAI2002M           = $0122 ;    // Kodak slow roi
      SENSOR_KAI2002CM          = $0123 ;    // Kodak slow roi

      SENSOR_KAI4010M           = $0130 ;    // Kodak
      SENSOR_KAI4010CM          = $0131 ;    // Kodak
      SENSOR_KAI4011M           = $0132 ;    // Kodak slow roi
      SENSOR_KAI4011CM          = $0133 ;    // Kodak slow roi

      SENSOR_KAI4020M           = $0140 ;    // Kodak
      SENSOR_KAI4020CM          = $0141      ;   // Kodak
      SENSOR_KAI4021M           = $0142      ;   // Kodak slow roi
      SENSOR_KAI4021CM          = $0143      ;   // Kodak slow roi
      SENSOR_KAI4022M           = $0144      ;   // Kodak 4022 monochrom
      SENSOR_KAI4022CM          = $0145      ;   // Kodak 4022 color

      SENSOR_KAI11000M          = $0150      ;   // Kodak
      SENSOR_KAI11000CM         = $0151      ;   // Kodak
      SENSOR_KAI11002M          = $0152      ;   // Kodak slow roi
      SENSOR_KAI11002CM         = $0153      ;   // Kodak slow roi

      SENSOR_KAI16000AXA        = $0160      ;   // Kodak t:496= $3324, e:4904x3280, a:4872x3248
      SENSOR_KAI16000CXA        = $0161      ;   // Kodak

      SENSOR_MV13BW             = $1010      ;   // Micron
      SENSOR_MV13COL            = $1011      ;   // Micron

      SENSOR_CIS2051_V1_FI_BW   = $2000      ;   //Fairchild front illuminated
      SENSOR_CIS2051_V1_FI_COL  = $2001 ;
      SENSOR_CIS1042_V1_FI_BW   = $2002 ;
      SENSOR_CIS2051_V1_BI_BW   = $2010 ;    //Fairchild back illuminated

//obsolete       SENSOR_CCD87           = $2010         // E2V
//obsolete       SENSOR_TC253           = $2110         // TI
      SENSOR_TC285SPD           = $2120  ;   // TI 285SPD

      SENSOR_CYPRESS_RR_V1_BW   = $3000  ;   // CYPRESS RoadRunner V1 B/W
      SENSOR_CYPRESS_RR_V1_COL  = $3001  ;   // CYPRESS RoadRunner V1 Color

      SENSOR_CMOSIS_CMV12000_BW    = $3100 ; // CMOSIS CMV12000 4096x3072 b/w
      SENSOR_CMOSIS_CMV12000_COL   = $3101 ; // CMOSIS CMV12000 4096x3072 color

      SENSOR_QMFLIM_V2B_BW      = $4000 ;    // CSEM QMFLIM V2B B/W

      SENSOR_GPIXEL_X2_BW       = $5000 ;// GPixel 2k
      SENSOR_GPIXEL_X2_COL      = $5001 ;// GPixel 2k




  // these are defines for interpreting the dwGeneralCaps1 member of the
  // Camera Description structure.
  //
  // How to use the member:
  //
  // if (CameraDescription.dwGeneralCaps1 & GENERALCAPS1_NOISE_FILTER)
  // {
  //   noise filter can be used! ...
  //   ...

      GENERALCAPS1_NOISE_FILTER                      = $00000001 ;
      GENERALCAPS1_HOTPIX_FILTER                     = $00000002 ;
      GENERALCAPS1_HOTPIX_ONLY_WITH_NOISE_FILTER     = $00000004 ;
      GENERALCAPS1_TIMESTAMP_ASCII_ONLY              = $00000008 ;

      GENERALCAPS1_DATAFORMAT2X12                    = $00000010 ;
      GENERALCAPS1_RECORD_STOP                       = $00000020 ;// Record stop event mode
      GENERALCAPS1_HOT_PIXEL_CORRECTION              = $00000040 ;
      GENERALCAPS1_NO_EXTEXPCTRL                     = $00000080 ;// Ext. Exp. ctrl not possible

      GENERALCAPS1_NO_TIMESTAMP                      = $00000100 ;
      GENERALCAPS1_NO_ACQUIREMODE                    = $00000200 ;
      GENERALCAPS1_DATAFORMAT4X16                    = $00000400 ;
      GENERALCAPS1_DATAFORMAT5X16                    = $00000800 ;

      GENERALCAPS1_NO_RECORDER                       = $00001000 ;// Camera has no internal memory
      GENERALCAPS1_FAST_TIMING                       = $00002000 ;// Camera can be set to fast timing mode (PIV)
      GENERALCAPS1_METADATA                          = $00004000 ;// Camera can produce metadata
      GENERALCAPS1_SETFRAMERATE_ENABLED              = $00008000 ;// Camera allows Set/GetFrameRate cmd

      GENERALCAPS1_CDI_MODE                          = $00010000 ;// Camera has Correlated Double Image Mode
      GENERALCAPS1_CCM                               = $00020000 ;// Camera has CCM
      GENERALCAPS1_EXTERNAL_SYNC                     = $00040000 ;// Camera can be synced externally
      GENERALCAPS1_NO_GLOBAL_SHUTTER                 = $00080000 ;// Camera does not support global shutter
      GENERALCAPS1_GLOBAL_RESET_MODE                 = $00100000 ;// Camera supports global reset rolling readout
      GENERALCAPS1_EXT_ACQUIRE                       = $00200000 ;// Camera supports extended acquire command
      GENERALCAPS1_FAN_LED_CONTROL                   = $00400000 ;// Camera supports fan and LED control command

      GENERALCAPS1_ROI_VERT_SYMM_TO_HORZ_AXIS        = $00800000 ;// Camera vert.ROI must be symmetrical to horizontal axis
      GENERALCAPS1_ROI_HORZ_SYMM_TO_VERT_AXIS        = $01000000 ;// Camera horz.ROI must be symmetrical to vertical axis

      GENERALCAPS1_COOLING_SETPOINTS                 = $02000000 ;// Camera has cooling setpoints instead of cooling range
      GENERALCAPS1_USER_INTERFACE                    = $04000000 ;// Camera has user interface commands

//      GENERALCAPS_ENHANCE_DESCRIPTOR_x             = $10000000 // reserved for future desc.
//      GENERALCAPS_ENHANCE_DESCRIPTOR_x             = $20000000 // reserved for future desc.
      GENERALCAPS1_HW_IO_SIGNAL_DESCRIPTOR           = $40000000  ;
      GENERALCAPS1_ENHANCED_DESCRIPTOR_2             = $80000000  ;


// dwGeneralCaps2 is for internal use only
// defines for interpreting the dwGeneralCaps2 member are therefore in sc2_defs_intern.h


// dwGeneralCaps3:

      GENERALCAPS3_HDSDI_1G5                         = $00000001 ;// with HD/SDI interface, 1.5 GBit data rate
      GENERALCAPS3_HDSDI_3G                          = $00000002 ;// with HD/SDI interface, 3.0 GBit data rate
      GENERALCAPS3_IRIG_B_UNMODULATED                = $00000004 ;// can evaluate an IRIG B unmodulated signal
      GENERALCAPS3_IRIG_B_MODULATED                  = $00000008 ;// can evaluate an IRIG B modulated signal
      GENERALCAPS3_CAMERA_SYNC                       = $00000010 ;// has camera sync mode implemented
      GENERALCAPS3_RESERVED0                         = $00000020 ;// reserved
      GENERALCAPS3_HS_READOUT_MODE                   = $00000040 ;// special fast sensor readout mode
      GENERALCAPS3_EXT_SYNC_1HZ_MODE                 = $00000080 ;// in trigger mode external synchronized, multiples of
                                                                  //   1 F/s can be set (until now: 100 Hz)


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Camera Temperature Command: --------------------- //
// ------------------------------------------------------------------------ //

      TEMPERATURE_NOT_AVAILABLE = $8000 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get / Set Camera Setup: --------------------------------- //
// ------------------------------------------------------------------------ //
// Each bit sets a corresponding switch
  // Camera setup type

  // Camera setup parameter for pco.edge:
      PCO_EDGE_SETUP_ROLLING_SHUTTER = $00000001 ;        // rolling shutter
      PCO_EDGE_SETUP_GLOBAL_SHUTTER  = $00000002 ;        // global shutter
      PCO_EDGE_SETUP_GLOBAL_RESET    = $00000004 ;        // global reset rolling readout


      PCO_DIMAX_CS_CAMERA_SETUP_TYPE_RSRVD_0     = $1001  ;// pco.dimax CS CameraSetup
      PCO_DIMAX_CS_CAMERA_SETUP_TYPE_RSRVD_1     = $1002  ;//   definitions for type parameter
      PCO_DIMAX_CS_CAMERA_SETUP_TYPE_RSRVD_2     = $1004  ;//   used for calibration purposes
      PCO_DIMAX_CS_CAMERA_SETUP_TYPE_RSRVD_3     = $1008  ;
      PCO_DIMAX_CS_CAMERA_SETUP_TYPE_RSRVD_4     = $1010  ;
      PCO_DIMAX_CS_CAMERA_SETUP_TYPE_RSRVD_5     = $1020  ;
      PCO_DIMAX_CS_CAMERA_SETUP_TYPE_RSRVD_6     = $1040  ;
      PCO_DIMAX_CS_CAMERA_SETUP_TYPE_RSRVD_7     = $1080  ;


// ------------------------------------------------------------------------ //
// -- Defines for User Interface Commands: -------------------------------- //
// ------------------------------------------------------------------------ //

      USER_INTERFACE_TYPE_UART                       = $0001 ;
      USER_INTERFACE_TYPE_UART_UNIDIRECTIONAL        = $0002 ;
      USER_INTERFACE_TYPE_USART                      = $0003 ;
      USER_INTERFACE_TYPE_SPI                        = $0004 ;
      USER_INTERFACE_TYPE_I2C                        = $0005 ;

      USER_INTERFACE_OPTIONS_UART_PARITY_NONE        = $00000001 ;
      USER_INTERFACE_OPTIONS_UART_PARITY_EVEN        = $00000002 ;
      USER_INTERFACE_OPTIONS_UART_PARITY_ODD         = $00000004 ;

      USER_INTERFACE_EQUIPMENT_LENS_CONTROL_BIRGER   = $00000001 ;

      USER_INTERFACE_HANDSHAKE_TYPE_NONE             = $0001 ;
      USER_INTERFACE_HANDSHAKE_TYPE_RTS_CTS          = $0002 ;
      USER_INTERFACE_HANDSHAKE_TYPE_XON_XOFF         = $0004 ;


      USER_INTERFACE_DO_NOT_CLEAR_BUFFERS            = $00 ;
      USER_INTERFACE_CLEAR_RX_BUFFER                 = $01 ;
      USER_INTERFACE_CLEAR_TX_BUFFER                 = $02 ;
      USER_INTERFACE_CLEAR_RX_AND_TX_BUFFER          = $03 ;





// ------------------------------------------------------------------------ //
// -- Defines for Read/Write Mailbox & Get Mailbox Status Commands: ------- //
// ------------------------------------------------------------------------ //

      MAILBOX_READ_STATUS_NO_VALID_MESSAGE                = $0000 ;
      MAILBOX_READ_STATUS_MESSAGE_VALID                   = $0001 ;
      MAILBOX_READ_STATUS_MESSAGE_HAS_BEEN_READ           = $0003 ;

      MAILBOX_STATUS_NO_VALID_MESSAGE                     = $0000 ;
      MAILBOX_STATUS_MESSAGE_VALID                        = $0001 ;
      MAILBOX_STATUS_MESSAGE_HAS_BEEN_READ                = $0003 ;



// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Battery Status: --------------------------------- //
// ------------------------------------------------------------------------ //

  // the following are bit flags which can be combined:

      BATTERY_STATUS_MAINS_AVAILABLE                      = $0001 ;
      BATTERY_STATUS_CONNECTED                            = $0002 ;
      BATTERY_STATUS_CHARGING                             = $0004 ;



// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Powersave Mode: --------------------------------- //
// ------------------------------------------------------------------------ //

      POWERSAVE_MODE_OFF                                  = $0000 ;
      POWERSAVE_MODE_ON                                   = $0001 ;
      POWERSAVE_MODE_DO_NOT_USE_BATTERY                   = $0002 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Binning Command: -------------------------------- //
// ------------------------------------------------------------------------ //

      BINNING_STEPPING_BINARY = 0 ;
      BINNING_STEPPING_LINEAR = 1 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Sensor Format Command: -------------------------- //
// ------------------------------------------------------------------------ //

      SENSORFORMAT_STANDARD = 0 ;
      SENSORFORMAT_EXTENDED = 1 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set ADC Operation: ---------------------------------- //
// ------------------------------------------------------------------------ //

      ADC_MODE_SINGLE = 1 ;
      ADC_MODE_DUAL   = 2 ;

// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Pixelrate Operation: ---------------------------- //
// ------------------------------------------------------------------------ //

      PIXELRATE_10MHZ = 10000000 ;
      PIXELRATE_20MHZ = 20000000 ;
      PIXELRATE_40MHZ = 40000000 ;
      PIXELRATE_5MHZ  = 5000000 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set OffsetMode: ------------------------------------- //
// ------------------------------------------------------------------------ //

      OFFSET_MODE_AUTO = 0 ;
      OFFSET_MODE_OFF  = 1 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Double Image Mode Command: ---------------------- //
// ------------------------------------------------------------------------ //

      DOUBLE_IMAGE_MODE_OFF            = $0000 ;
      DOUBLE_IMAGE_MODE_ON             = $0001 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Noise Filter Mode: ------------------------------ //
// ------------------------------------------------------------------------ //

      NOISE_FILTER_MODE_OFF              = $0000 ;
      NOISE_FILTER_MODE_ON               = $0001 ;
      NOISE_FILTER_MODE_REMOVE_HOT_DARK  = $0100 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Hot Pixel Correction: --------------------------- //
// ------------------------------------------------------------------------ //

      HOT_PIXEL_CORRECTION_OFF           = $0000 ;
      HOT_PIXEL_CORRECTION_ON            = $0001 ;
      HOT_PIXEL_CORRECTION_TEST          = $0100 ; // for test purposes only!


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set DSNU Adjust Mode: ------------------------------- //
// ------------------------------------------------------------------------ //

      DSNU_ADJUST_MODE_OFF               = $0000 ;
      DSNU_ADJUST_MODE_AUTO              = $0001 ;
      DSNU_ADJUST_MODE_USER              = $0002 ;
  //only for internal use!
      DSNU_ADJUST_MODE_CONT              = $4000 ;
      DSNU_ADJUST_MODE_STOP              = $8000 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set CDI Mode: --------------------------------------- //
// ------------------------------------------------------------------------ //

      CDI_MODE_OFF                       = $0000 ;
      CDI_MODE_ON                        = $0001 ;


// ------------------------------------------------------------------------ //
// -- Defines for Init DSNU Adjustment: ----------------------------------- //
// ------------------------------------------------------------------------ //

      INIT_DSNU_ADJUSTMENT_OFF           = $0000 ;
      INIT_DSNU_ADJUSTMENT_ON            = $0001 ;
      INIT_DSNU_ADJUSTMENT_DARK_MODE     = $0002 ;
      INIT_DSNU_ADJUSTMENT_AUTO_MODE     = $0003 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Timebase Command: ------------------------------- //
// ------------------------------------------------------------------------ //

      TIMEBASE_NS = $0000 ;
      TIMEBASE_US = $0001 ;
      TIMEBASE_MS = $0002 ;



// ------------------------------------------------------------------------ //
// -- Defines for Get/Set FPS Exposure Mode: ------------------------------ //
// ------------------------------------------------------------------------ //

      FPS_EXPOSURE_MODE_OFF = $0000 ;
      FPS_EXPOSURE_MODE_ON  = $0001 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Framerate: -------------------------------------- //
// ------------------------------------------------------------------------ //

      SET_FRAMERATE_MODE_AUTO                            = $0000 ;
      SET_FRAMERATE_MODE_FRAMERATE_HAS_PRIORITY          = $0001 ;
      SET_FRAMERATE_MODE_EXPTIME_HAS_PRIORITY            = $0002 ;
      SET_FRAMERATE_MODE_STRICT                          = $0003 ;

      SET_FRAMERATE_STATUS_OK                            = $0000 ;
      SET_FRAMERATE_STATUS_FPS_LIMITED_BY_READOUT        = $0001 ;
      SET_FRAMERATE_STATUS_FPS_LIMITED_BY_EXPTIME        = $0002 ;
      SET_FRAMERATE_STATUS_EXPTIME_CUT_TO_FRAMETIME      = $0004 ;
      SET_FRAMERATE_STATUS_NOT_YET_VALIDATED             = $8000 ;
      SET_FRAMERATE_STATUS_ERROR_SETTINGS_INCONSISTENT   = $8001 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Delay Exposure Timetable Command: --------------- //
// ------------------------------------------------------------------------ //

      MAX_TIMEPAIRS  = 16 ;   // max size of time table for



// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Trigger Mode Command: --------------------------- //
// ------------------------------------------------------------------------ //

      TRIGGER_MODE_AUTOTRIGGER                      = $0000 ;
      TRIGGER_MODE_SOFTWARETRIGGER                  = $0001 ;
      TRIGGER_MODE_EXTERNALTRIGGER                  = $0002 ;
      TRIGGER_MODE_EXTERNALEXPOSURECONTROL          = $0003 ;
      TRIGGER_MODE_SOURCE_HDSDI                     = $0102 ;
      TRIGGER_MODE_EXTERNAL_SYNCHRONIZED            = $0004 ;
      TRIGGER_MODE_FAST_EXTERNALEXPOSURECONTROL     = $0005 ;
      TRIGGER_MODE_EXTERNAL_CDS                     = $0006 ;
      TRIGGER_MODE_SLOW_EXTERNALEXPOSURECONTROL     = $0007 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Camera Sync Mode Command: ----------------------- //
// ------------------------------------------------------------------------ //

      CAMERA_SYNC_MODE_STANDALONE               = $0000 ;
      CAMERA_SYNC_MODE_MASTER                   = $0001 ;
      CAMERA_SYNC_MODE_SLAVE                    = $0002 ;

// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Fan Control Command: ---------------------------- //
// ------------------------------------------------------------------------ //

      FAN_CONTROL_MODE_AUTO                     = $0000 ;
      FAN_CONTROL_MODE_USER                     = $0001 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Power Down Mode Command: ------------------------ //
// ------------------------------------------------------------------------ //

      POWERDOWN_MODE_AUTO   = 0 ;
      POWERDOWN_MODE_USER   = 1 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Storage Mode Command: --------------------------- //
// ------------------------------------------------------------------------ //

      STORAGE_MODE_RECORDER    =  0 ;
      STORAGE_MODE_FIFO_BUFFER =  1 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Recorder Submode Command: ----------------------- //
// ------------------------------------------------------------------------ //
      RECORDER_SUBMODE_SEQUENCE   =  0 ;
      RECORDER_SUBMODE_RINGBUFFER =  1 ;



// ------------------------------------------------------------------------ //
// -- Defines for Set Record Stop Mode: ----------------------------------- //
// ------------------------------------------------------------------------ //

      RECORD_STOP_EVENT_OFF            = $0000 ;   // no delayed stop poss.
      RECORD_STOP_EVENT_STOP_BY_SW     = $0001 ;   // stop only by sw command
      RECORD_STOP_EVENT_STOP_EXTERNAL  = $0002 ;   // stop by signat at Acq.

// the following filter modes can be added (just ored to the mode parameter)
// when using external record stop:

      RECORD_STOP_FILTER_OFF           = $0000 ;   // no additional filter
      RECORD_STOP_FILTER_1us           = $1000 ;   // pulse length filter   1 us
      RECORD_STOP_FILTER_10us          = $2000 ;   // pulse length filter  10 us
      RECORD_STOP_FILTER_100us         = $3000 ;   // pulse length filter 100 us
      RECORD_STOP_FILTER_1000us        = $4000 ;   // pulse length filter   1 ms

// ------------------------------------------------------------------------ //
// -- Defines for Set Event Monitor Configuration: ------------------------ //
// ------------------------------------------------------------------------ //

      EVENT_CONFIG_EXPTRIG_RISING            = $0001 ;
      EVENT_CONFIG_EXPTRIG_FALLING           = $0002 ;
      EVENT_CONFIG_ACQENBL_RISING            = $0004 ;
      EVENT_CONFIG_ACQENBL_FALLING           = $0008 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Acquire Mode Command: --------------------------- //
// ------------------------------------------------------------------------ //

      ACQUIRE_MODE_AUTO                    = $0000 ;  // normal auto mode
      ACQUIRE_MODE_EXTERNAL                = $0001 ;  // ext. as enable signal
      ACQUIRE_MODE_EXTERNAL_FRAME_TRIGGER  = $0002 ;  // ext. as frame trigger
      ACQUIRE_MODE_USE_FOR_LIVEVIEW        = $0003 ;  // use acq. for live view
      ACQUIRE_MODE_IMAGE_SEQUENCE          = $0004 ;  // use acq. for image sequence

// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Acquire Mode Command: --------------------------- //
// ------------------------------------------------------------------------ //

      ACQUIRE_CONTROL_OFF                  = $0000 ;    // use external signal
      ACQUIRE_CONTROL_FORCE_LOW            = $0001 ;    // force aquire  low
      ACQUIRE_CONTROL_FORCE_HIGH           = $0002 ;    // force acquire high



// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Timestamp Mode Command: ------------------------- //
// ------------------------------------------------------------------------ //

      TIMESTAMP_MODE_OFF              = 0 ;
      TIMESTAMP_MODE_BINARY           = 1 ;
      TIMESTAMP_MODE_BINARYANDASCII   = 2 ;
      TIMESTAMP_MODE_ASCII            = 3 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Metadata Mode: ---------------------------------- //
// ------------------------------------------------------------------------ //

      METADATA_MODE_OFF               = $0000 ;
      METADATA_MODE_ON                = $0001 ;
      METADATA_MODE_TEST              = $8000 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get/Set PIV Mode Command: ------------------------------- //
// ------------------------------------------------------------------------ //

      FAST_TIMING_MODE_OFF            = $0000 ;
      FAST_TIMING_MODE_ON             = $0001 ;



// ------------------------------------------------------------------------ //
// -- Defines for Get/Set Bit Alignment: ---------------------------------- //
// ------------------------------------------------------------------------ //

      BIT_ALIGNMENT_MSB               = 0 ;
      BIT_ALIGNMENT_LSB               = 1 ;
      BIT_ALIGNMENT_MID               = $1000  ;// for 3x8 bit CL (Hamamatsu)


// ------------------------------------------------------------------------ //
// -- Defines for GetSensorSignalStatus: ---------------------------------- //
// ------------------------------------------------------------------------ //

      SIGNAL_STATE_BUSY               = $00000001 ;
      SIGNAL_STATE_IDLE               = $00000002 ;
      SIGNAL_STATE_EXP                = $00000004 ;
      SIGNAL_STATE_READ               = $00000008 ;
      SIGNAL_STATE_FIFO_FULL          = $00000010 ;


// ------------------------------------------------------------------------ //
// -- Defines for Play Images from Segment Modes: ------------------------- //
// ------------------------------------------------------------------------ //

      PLAY_IMAGES_MODE_OFF                                  = $0000 ;
      PLAY_IMAGES_MODE_FAST_FORWARD                         = $0001 ;
      PLAY_IMAGES_MODE_FAST_REWIND                          = $0002 ;
      PLAY_IMAGES_MODE_SLOW_FORWARD                         = $0003 ;
      PLAY_IMAGES_MODE_SLOW_REWIND                          = $0004 ;
      PLAY_IMAGES_MODE_REPLAY_AT_END                        = $0100 ;
      PLAY_IMAGES_MODE_EXT_CONTROL                          = $4000 ;

      PLAY_IMAGES_MODE_IS_FORWARD                           = $0001 ;

      PLAY_POSITION_STATUS_NO_PLAY_ACTIVE                   = $0000 ;
      PLAY_POSITION_STATUS_VALID                            = $0001 ;


// ------------------------------------------------------------------------ //
// -- Defines for Color Chips    ------------------------------------------ //
// ------------------------------------------------------------------------ //

      COLOR_RED     = $01 ;
      COLOR_GREENA  = $02 ;
      COLOR_GREENBA = $03 ;
      COLOR_BLUE    = $04 ;

      COLOR_CYAN    = $05 ;
      COLOR_MAGENTA = $06 ;
      COLOR_YELLOWA = $07 ;

      PATTERN_BAYER = $01 ;

// ------------------------------------------------------------------------ //
// -- Defines for Modulate mode  ------------------------------------------ //
// ------------------------------------------------------------------------ //

      MODULATECAPS_MODULATE                 = $00000001 ;
      MODULATECAPS_MODULATE_EXT_TRIG        = $00000002 ;
      MODULATECAPS_MODULATE_EXT_EXP         = $00000004 ;
      MODULATECAPS_MODULATE_ACQ_EXT_FRAME   = $00000008 ;



// ------------------------------------------------------------------------ //
// -- Defines for Get White Balance Status: ------------------------------- //
// ------------------------------------------------------------------------ //

      WHITE_BALANCE_STATUS_DEFAULT                              = $0000 ;
      WHITE_BALANCE_STATUS_IN_PROGRESS                          = $0100 ;
      WHITE_BALANCE_STATUS_SUCCESS                              = $0001 ;
      WHITE_BALANCE_STATUS_TIMEOUT                              = $8001 ;
      WHITE_BALANCE_STATUS_FAILED                               = $8002 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get / Set Color Settings: ------------------------------- //
// ------------------------------------------------------------------------ //

      COLOR_PROC_OPTIONS_COLOR_REFINE                           = $0001 ;
//      COLOR_PROC_OPTIONS_USE_REC709                             = $0002
//      COLOR_PROC_OPTIONS_USE_LOG90                              = $0004

      COLOR_SETTINGS_LUT_NOT_USED                               = $0000 ;
      COLOR_SETTINGS_LUT_REC709                                 = $1001 ;
      COLOR_SETTINGS_LUT_LOG90                                  = $1002 ;


// ------------------------------------------------------------------------ //
// -- Defines for Get / Set Image Transfer Mode: -------------------------- //
// ------------------------------------------------------------------------ //

      IMAGE_TRANSFER_MODE_STANDARD           = $0000 ;
      IMAGE_TRANSFER_MODE_SCALED_XY_8BIT     = $0001 ;
      IMAGE_TRANSFER_MODE_CUTOUT_XY_8BIT     = $0002 ;
      IMAGE_TRANSFER_MODE_FULL_RGB_24BIT     = $0003 ;
      IMAGE_TRANSFER_MODE_BIN_SCALED_8BIT_BW = $0004 ;
      IMAGE_TRANSFER_MODE_BIN_SCALED_8BIT_COLOR = $0005 ;
      IMAGE_TRANSFER_MODE_TEST_ONLY          = $8000 ;



      SCCMOS_FORMAT_TOP_BOTTOM                                  = $0000 ; //Mode E
      SCCMOS_FORMAT_TOP_CENTER_BOTTOM_CENTER                    = $0100 ; //Mode A
      SCCMOS_FORMAT_CENTER_TOP_CENTER_BOTTOM                    = $0200 ; //Mode B
      SCCMOS_FORMAT_CENTER_TOP_BOTTOM_CENTER                    = $0300 ; //Mode C
      SCCMOS_FORMAT_TOP_CENTER_CENTER_BOTTOM                    = $0400 ; //Mode D

      USB_FORMAT_14BIT                                    = $0000 ;
      USB_FORMAT_12BIT                                    = $0001 ;

// ------------------------------------------------------------------------ //
// -- Defines for Get Image Timing: --------------------------------------- //
// ------------------------------------------------------------------------ //

      IMAGE_TIMING_NOT_APPLICABLE                           = $FFFFFFFF ;

// ------------------------------------------------------------------------ //
// -- Defines for Lookup Table: ------------------------------------------- //
// ------------------------------------------------------------------------ //

      LOOKUPTABLE_FORMAT_8BIT   = $0001 ;
      LOOKUPTABLE_FORMAT_12BIT  = $0002 ;
      LOOKUPTABLE_FORMAT_16BIT  = $0004 ;
      LOOKUPTABLE_FORMAT_24BIT  = $0008 ;
      LOOKUPTABLE_FORMAT_32BIT  = $0010 ;
      LOOKUPTABLE_FORMAT_AUTO   = $8000 ;


// ------------------------------------------------------------------------ //
// -- Defines for Cooling Setpoints---------------------------------------- //
// ------------------------------------------------------------------------ //

      COOLING_SETPOINTS_BLOCKSIZE = 10 ;

// ------------------------------------------------------------------------ //
// -- Defines for Linetiming   -------------------------------------------- //
// ------------------------------------------------------------------------ //

      CMOS_LINETIMING_PARAM_OFF  = $0000 ;
      CMOS_LINETIMING_PARAM_ON   = $0001 ;

      IMAGEPARAMETERS_READ_FROM_SEGMENTS = 1 ;
      IMAGEPARAMETERS_READ_WHILE_RECORDING = 2 ;



       PCO_NOERROR                        = 0 ;   // no error

// ====================================================================================================== //
// -- 1. Masks for evaluating error layer, error device and error code: --------------------------------- //
// ====================================================================================================== //

        PCO_ERROR_CODE_MASK                = $00000FFF    ; // in this bit range the error codes reside
        PCO_ERROR_LAYER_MASK               = $0000F000    ; // in this bit range the layer codes reside
        PCO_ERROR_DEVICE_MASK              = $00FF0000    ; // bit range for error devices / sources
        PCO_ERROR_RESERVED_MASK            = $1F000000    ; // reserved for future use
        PCO_ERROR_IS_COMMON                = $20000000    ; // indicates error message common to all layers
        PCO_ERROR_IS_WARNING               = $40000000    ; // indicates a warning
        PCO_ERROR_IS_ERROR                 = $80000000    ; // indicates an error condition



 // ====================================================================================================== ; //
 // -- 2. Layer definitions: ----------------------------------------------------------------------------- ; //
 // ====================================================================================================== ; //

        PCO_ERROR_FIRMWARE                 = $00001000    ; // error inside the firmware
        PCO_ERROR_DRIVER                   = $00002000    ; // error inside the driver
        PCO_ERROR_SDKDLL                   = $00003000    ; // error inside the SDK-dll
        PCO_ERROR_APPLICATION              = $00004000    ; // error inside the application

 // Common device codes (should start with PCO_)
 // Device codes in each layer group should be numbered in ascending order.
 // No device code in a layer group MUST be used twice!!
 // ====================================================================================================== ; //
 // -- 3.1 FIRMWARE error sources / devices: ------------------------------------------------------------- ; //
 // ====================================================================================================== ; //

 // SC2 device codes (should start with SC2_)
        SC2_ERROR_POWER_CPLD               = $00010000    ; // error at CPLD in pco.power unit
        SC2_ERROR_HEAD_UP                  = $00020000    ; // error at uP of head board in pco.camera
        SC2_ERROR_MAIN_UP                  = $00030000    ; // error at uP of main board in pco.camera
        SC2_ERROR_FWIRE_UP                 = $00040000    ; // error at uP of firewire board in pco.camera
        SC2_ERROR_MAIN_FPGA                = $00050000    ; // error at FPGA of main board in pco.camera
        SC2_ERROR_HEAD_FPGA                = $00060000    ; // error at FGPA of head board in pco.camera
        SC2_ERROR_MAIN_BOARD               = $00070000    ; // error at main board in pco.camera
        SC2_ERROR_HEAD_CPLD                = $00080000    ; // error at CPLD of head board in pco.camera
        SC2_ERROR_SENSOR                   = $00090000    ; // error at image sensor (CCD or CMOS)
        SC2_ERROR_POWER                    = $000D0000    ; // error within power unit
        SC2_ERROR_GIGE                     = $000E0000    ; // error at uP of GigE board GigE firmware
        SC2_ERROR_USB                      = $000F0000    ; // error at uP of GigE board USB firmware
        SC2_ERROR_BOOT_FPGA                = $00100000    ; // error at Boot FPGA in pco.camera
        SC2_ERROR_BOOT_UP                  = $00110000    ; // error at Boot FPGA in pco.camera


 // ====================================================================================================== ; //
 // -- 3.2 DRIVER devices -------------------------------------------------------------------------------- ; //
 // ====================================================================================================== ; //

        PCI540_ERROR_DRIVER                = $00200000    ; // error at pixelfly driver
 //specific error codes are in file pccddk_e.h

        PCI525_ERROR_DRIVER                = $00210000    ; // error at sensicam driver

        PCO_ERROR_DRIVER_FIREWIRE          = $00300000    ; // error inside the firewire driver
        PCO_ERROR_DRIVER_USB               = $00310000    ; // error inside the usb driver
        PCO_ERROR_DRIVER_GIGE              = $00320000    ; // error inside the GigE driver
        PCO_ERROR_DRIVER_CAMERALINK        = $00330000    ; // error inside the CameraLink driver
        PCO_ERROR_DRIVER_USB3              = $00340000    ; // error inside the usb 3.0 driver
        PCO_ERROR_DRIVER_WLAN              = $00350000    ; // error inside the usb 3.0 driver

 // ====================================================================================================== ; //
 // -- 3.3 SDKDLL devices -------------------------------------------------------------------------------- ; //
 // ====================================================================================================== ; //
        PCO_ERROR_PCO_SDKDLL               = $000A0000    ; // error inside the camera sdk dll
        PCO_ERROR_CONVERTDLL               = $00110000    ; // error inside the convert dll
        PCO_ERROR_FILEDLL                  = $00120000    ; // error inside the file dll
        PCO_ERROR_JAVANATIVEDLL            = $00130000    ; // error inside a java native dll

        PCO_ERROR_PROGLIB                  = $00140000    ; // error inside the programmer library


 // ====================================================================================================== ; //
 // -- 3.4 Application devices --------------------------------------------------------------------------- ; //
 // ====================================================================================================== ; //
        PCO_ERROR_CAMWARE                  = $00100000    ; // error in CamWare (also some kind of "device")

        PCO_ERROR_PROGRAMMER               = $00110000    ; // error in Programmer

        PCO_ERROR_SDKAPPLICATION           = $00120000    ; // error in SDK Applikation


        PCO_ERROR_WRONGVALUE                        = $A0000001 ; // Function-call with wrong parameter
        PCO_ERROR_INVALIDHANDLE                     = $A0000002 ; // Handle is invalid
        PCO_ERROR_NOMEMORY                          = $A0000003 ; // No memory available
        PCO_ERROR_NOFILE                            = $A0000004 ; // A file handle could not be opened.
        PCO_ERROR_TIMEOUT                           = $A0000005 ; // Timeout in function
        PCO_ERROR_BUFFERSIZE                        = $A0000006 ; // A buffer is to small
        PCO_ERROR_NOTINIT                           = $A0000007 ; // The called module is not initialized
        PCO_ERROR_DISKFULL                          = $A0000008 ; // Disk full.

        PCO_ERROR_VALIDATION                        = $A0000010 ; // Validation after programming camera failed
        PCO_ERROR_LIBRARYVERSION                    = $A0000011 ; // wrong library version
        PCO_ERROR_CAMERAVERSION                     = $A0000012 ; // wrong camera version
        PCO_ERROR_NOTAVAILABLE                      = $A0000013 ; // Option is not available

        PCO_ERROR_DRIVER_NOTINIT                    = $80002001 ; // Initialization failed; no camera connected
        PCO_ERROR_DRIVER_WRONGOS                    = $80002005 ; // Wrong driver for this OS
        PCO_ERROR_DRIVER_NODRIVER                   = $80002006 ; // Open driver or driver class failed
        PCO_ERROR_DRIVER_IOFAILURE                  = $80002007 ; // I/O operation failed
        PCO_ERROR_DRIVER_CHECKSUMERROR              = $80002008 ; // Error in telegram checksum
        PCO_ERROR_DRIVER_INVMODE                    = $80002009 ; // Invalid Camera mode
        PCO_ERROR_DRIVER_DEVICEBUSY                 = $8000200B ; // device is hold by an other process
        PCO_ERROR_DRIVER_DATAERROR                  = $8000200C ; // Error in reading or writing data to board
        PCO_ERROR_DRIVER_NOFUNCTION                 = $8000200D ; // No function specified
        PCO_ERROR_DRIVER_KERNELMEMALLOCFAILED       = $8000200E ; // Kernel Memory allocation in driver failed

        PCO_ERROR_DRIVER_BUFFER_CANCELLED           = $80002010 ; // buffer was cancelled
        PCO_ERROR_DRIVER_INBUFFER_SIZE              = $80002011 ; // iobuffer in too small for DeviceIO call
        PCO_ERROR_DRIVER_OUTBUFFER_SIZE             = $80002012 ; // iobuffer out too small for DeviceIO call
        PCO_ERROR_DRIVER_FUNCTION_NOT_SUPPORTED     = $80002013 ; // this DeviceIO is not supported
        PCO_ERROR_DRIVER_BUFFER_SYSTEMOFF           = $80002014 ; // buffer returned because system sleep
        PCO_ERROR_DRIVER_DEVICEOFF                  = $80002015 ; // device is disconnected
        PCO_ERROR_DRIVER_RESOURCE                   = $80002016 ; // required system resource not avaiable
        PCO_ERROR_DRIVER_BUSRESET                   = $80002017 ; // busreset occured during system call
        PCO_ERROR_DRIVER_BUFFER_LOSTIMAGE           = $80002018 ; // lost image status from grabber


        PCO_ERROR_DRIVER_SYSERR                     = $80002020 ; // a call to a windows-function fails
        PCO_ERROR_DRIVER_REGERR                     = $80002022 ; // error in reading/writing to registry
        PCO_ERROR_DRIVER_WRONGVERS                  = $80002023 ; // need newer called vxd or dll
        PCO_ERROR_DRIVER_FILE_READ_ERR              = $80002024 ; // error while reading from file
        PCO_ERROR_DRIVER_FILE_WRITE_ERR             = $80002025 ; // error while writing to file

        PCO_ERROR_DRIVER_LUT_MISMATCH               = $80002026 ; // camera and dll lut do not match
        PCO_ERROR_DRIVER_FORMAT_NOT_SUPPORTED       = $80002027 ; // grabber does not support the transfer format
        PCO_ERROR_DRIVER_BUFFER_DMASIZE             = $80002028 ; // dmaerror not enough data transferred

        PCO_ERROR_DRIVER_WRONG_ATMEL_FOUND          = $80002029 ; // version information verify failed wrong typ id
        PCO_ERROR_DRIVER_WRONG_ATMEL_SIZE           = $8000202A ; // version information verify failed wrong size
        PCO_ERROR_DRIVER_WRONG_ATMEL_DEVICE         = $8000202B ; // version information verify failed wrong device id
        PCO_ERROR_DRIVER_WRONG_BOARD                = $8000202C ; // board firmware not supported from this driver
        PCO_ERROR_DRIVER_READ_FLASH_FAILED          = $8000202D ; // board firmware verify failed
        PCO_ERROR_DRIVER_HEAD_VERIFY_FAILED         = $8000202E ; // camera head is not recognized correctly
        PCO_ERROR_DRIVER_HEAD_BOARD_MISMATCH        = $8000202F ; // firmware does not support connected camera head

        PCO_ERROR_DRIVER_HEAD_LOST                  = $80002030 ; // camera head is not connected
        PCO_ERROR_DRIVER_HEAD_POWER_DOWN            = $80002031 ; // camera head power down
        PCO_ERROR_DRIVER_CAMERA_BUSY                = $80002032 ; // camera busy

        PCO_ERROR_DRIVER_BUFFERS_PENDING            = $80002033 ; // camera busy

        PCO_ERROR_SDKDLL_NESTEDBUFFERSIZE           = $80003001 ; // The wSize of an embedded buffer is to small.
        PCO_ERROR_SDKDLL_BUFFERSIZE                 = $80003002 ; // The wSize of a buffer is to small.
        PCO_ERROR_SDKDLL_DIALOGNOTAVAILABLE         = $80003003 ; // A dialog is not available
        PCO_ERROR_SDKDLL_NOTAVAILABLE               = $80003004 ; // Option is not available
        PCO_ERROR_SDKDLL_SYSERR                     = $80003005 ; // a call to a windows-function fails
        PCO_ERROR_SDKDLL_BADMEMORY                  = $80003006 ; // Memory area is invalid

        PCO_ERROR_SDKDLL_BUFCNTEXHAUSTED            = $80003008 ; // Number of available buffers is exhausted

        PCO_ERROR_SDKDLL_ALREADYOPENED              = $80003009 ; // Dialog is already open
        PCO_ERROR_SDKDLL_ERRORDESTROYWND            = $8000300A ; // Error while destroying dialog.
        PCO_ERROR_SDKDLL_BUFFERNOTVALID             = $8000300B ; // A requested buffer is not available.
        PCO_ERROR_SDKDLL_WRONGBUFFERNR              = $8000300C ; // Buffer nr is out of range..
        PCO_ERROR_SDKDLL_DLLNOTFOUND                = $8000300D ; // A DLL could not be found
        PCO_ERROR_SDKDLL_BUFALREADYASSIGNED         = $8000300E ; // Buffer already assigned to another buffernr.
        PCO_ERROR_SDKDLL_EVENTALREADYASSIGNED       = $8000300F ; // Event already assigned to another buffernr.
        PCO_ERROR_SDKDLL_RECORDINGMUSTBEON          = $80003010 ; // Recording must be activated
        PCO_ERROR_SDKDLL_DLLNOTFOUND_DIVZERO        = $80003011 ; // A DLL could not be found, due to div by zero

        PCO_ERROR_SDKDLL_BUFFERALREADYQUEUED        = $80003012 ; // buffer is already queued
        PCO_ERROR_SDKDLL_BUFFERNOTQUEUED            = $80003013 ; // buffer is not queued

        PCO_WARNING_SDKDLL_BUFFER_STILL_ALLOKATED   = $C0003001 ; // Buffers are still allocated

        PCO_WARNING_SDKDLL_NO_IMAGE_BOARD           = $C0003002 ; // No Images are in the board buffer
        PCO_WARNING_SDKDLL_COC_VALCHANGE            = $C0003003 ; // value change when testing COC
        PCO_WARNING_SDKDLL_COC_STR_SHORT            = $C0003004 ; // string buffer to short for replacement

        PCO_ERROR_SDKDLL_RECORDER_RECORD_MUST_BE_OFF        = $80003021 ; // Record must be stopped
        PCO_ERROR_SDKDLL_RECORDER_ACQUISITION_MUST_BE_OFF   = $80003022 ; // Function call not possible while running
        PCO_ERROR_SDKDLL_RECORDER_SETTINGS_CHANGED          = $80003023 ; // Some camera settings have been changed outside of the recorder
        PCO_ERROR_SDKDLL_RECORDER_NO_IMAGES_AVAILABLE       = $80003024 ; // No images are avaialable for readout

        PCO_WARNING_SDKDLL_RECORDER_FILES_EXIST             = $C0003011 ; // Files already exist

        PCO_ERROR_APPLICATION_PICTURETIMEOUT        = $80004001 ; // Error while waiting for a picture
        PCO_ERROR_APPLICATION_SAVEFILE              = $80004002 ; // Error while saving file
        PCO_ERROR_APPLICATION_FUNCTIONNOTFOUND      = $80004003 ; // A function inside a DLL could not be found
        PCO_ERROR_APPLICATION_DLLNOTFOUND           = $80004004 ; // A DLL could not be found
        PCO_ERROR_APPLICATION_WRONGBOARDNR          = $80004005 ; // The board number is out of range.
        PCO_ERROR_APPLICATION_FUNCTIONNOTSUPPORTED  = $80004006 ; // The decive does not support this function.
        PCO_ERROR_APPLICATION_WRONGRES              = $80004007 ; // Started Math with different resolution than reference.
        PCO_ERROR_APPLICATION_DISKFULL              = $80004008 ; // Disk full.
        PCO_ERROR_APPLICATION_SET_VALUES            = $80004009 ; // Error setting values to camera

        PCO_WARNING_APPLICATION_RECORDERFULL        = $C0004001 ; // Memory recorder buffer is full
        PCO_WARNING_APPLICATION_SETTINGSADAPTED     = $C0004002 ; // Settings have been adapted to valid values

        PCO_ERROR_FIRMWARE_TELETIMEOUT              = $80001001 ; // timeout in telegram
        PCO_ERROR_FIRMWARE_WRONGCHECKSUM            = $80001002 ; // wrong checksum in telegram
        PCO_ERROR_FIRMWARE_NOACK                    = $80001003 ; // no acknowledge

        PCO_ERROR_FIRMWARE_WRONGSIZEARR             = $80001004 ; // wrong size in array
        PCO_ERROR_FIRMWARE_DATAINKONSISTENT         = $80001005 ; // data is inkonsistent
        PCO_ERROR_FIRMWARE_UNKNOWN_COMMAND          = $80001006 ; // unknown command telegram

        PCO_ERROR_FIRMWARE_INITFAILED               = $80001008 ; // FPGA init failed
        PCO_ERROR_FIRMWARE_CONFIGFAILED             = $80001009 ; // FPGA configuration failed
        PCO_ERROR_FIRMWARE_HIGH_TEMPERATURE         = $8000100A ; // device exceeds temp. range
        PCO_ERROR_FIRMWARE_VOLTAGEOUTOFRANGE        = $8000100B ; // Supply voltage is out of allowed range

        PCO_ERROR_FIRMWARE_I2CNORESPONSE            = $8000100C ; // no response from I2C Device
        PCO_ERROR_FIRMWARE_CHECKSUMCODEFAILED       = $8000100D ; // checksum in code area is wrong
        PCO_ERROR_FIRMWARE_ADDRESSOUTOFRANGE        = $8000100E ; // an address is out of range
        PCO_ERROR_FIRMWARE_NODEVICEOPENED           = $8000100F ; // no device is open for update

        PCO_ERROR_FIRMWARE_BUFFERTOSMALL            = $80001010 ; // the delivered buffer is to small
        PCO_ERROR_FIRMWARE_TOMUCHDATA               = $80001011 ; // To much data delivered to function
        PCO_ERROR_FIRMWARE_WRITEERROR               = $80001012 ; // Error while writing to camera
        PCO_ERROR_FIRMWARE_READERROR                = $80001013 ; // Error while reading from camera

        PCO_ERROR_FIRMWARE_NOTRENDERED              = $80001014 ; // Was not able to render graph
        PCO_ERROR_FIRMWARE_NOHANDLEAVAILABLE        = $80001015 ; // The handle is not known
        PCO_ERROR_FIRMWARE_DATAOUTOFRANGE           = $80001016 ; // Value is out of allowed range
        PCO_ERROR_FIRMWARE_NOTPOSSIBLE              = $80001017 ; // Desired function not possible

        PCO_ERROR_FIRMWARE_UNSUPPORTED_SDRAM        = $80001018 ; // SDRAM type read from SPD unknown
        PCO_ERROR_FIRMWARE_DIFFERENT_SDRAMS         = $80001019 ; // different SDRAM modules mounted
        PCO_ERROR_FIRMWARE_ONLY_ONE_SDRAM           = $8000101A ; // for CMOS sensor two modules needed
        PCO_ERROR_FIRMWARE_NO_SDRAM_MOUNTED         = $8000101B ; // for CMOS sensor two modules needed

        PCO_ERROR_FIRMWARE_SEGMENTS_TOO_LARGE       = $8000101C ; // Segment size is too large
        PCO_ERROR_FIRMWARE_SEGMENT_OUT_OF_RANGE     = $8000101D ; // Segment is out of range
        PCO_ERROR_FIRMWARE_VALUE_OUT_OF_RANGE       = $8000101E ; // Value is out of range
        PCO_ERROR_FIRMWARE_IMAGE_READ_NOT_POSSIBLE  = $8000101F ; // Image read not possible

        PCO_ERROR_FIRMWARE_NOT_SUPPORTED            = $80001020 ; // not supported by this hardware
        PCO_ERROR_FIRMWARE_ARM_NOT_SUCCESSFUL       = $80001021 ; // starting record failed due not armed
        PCO_ERROR_FIRMWARE_RECORD_MUST_BE_OFF       = $80001022 ; // arm is not possible while record active

        PCO_ERROR_FIRMWARE_SEGMENT_TOO_SMALL        = $80001025 ; // Segment too small for image

        PCO_ERROR_FIRMWARE_COC_BUFFER_TO_SMALL      = $80001026 ; // COC built is too large for internal memory
        PCO_ERROR_FIRMWARE_COC_DATAINKONSISTENT     = $80001027 ; // COC has invalid data at fix position

        PCO_ERROR_FIRMWARE_CORRECTION_DATA_INVALID  = $80001028 ; // Corr mode not possible due to invalid data
        PCO_ERROR_FIRMWARE_CCDCAL_NOT_FINISHED      = $80001029 ; // calibration is not finished

        PCO_ERROR_FIRMWARE_IMAGE_TRANSFER_PENDING   = $8000102A ; // no new image transfer can be started, because
                                                                  //   the previous image transfer is pending

        PCO_ERROR_FIRMWARE_COC_TRIGGER_INVALID      = $80001030 ; // Camera trigger setting invalid
        PCO_ERROR_FIRMWARE_COC_PIXELRATE_INVALID    = $80001031 ; // Camera pixel rate invalid
        PCO_ERROR_FIRMWARE_COC_POWERDOWN_INVALID    = $80001032 ; // Camera powerdown setting invalid
        PCO_ERROR_FIRMWARE_COC_SENSORFORMAT_INVALID = $80001033 ; // Camera sensorformat invalid
        PCO_ERROR_FIRMWARE_COC_ROI_BINNING_INVALID  = $80001034 ; // Camera setting ROI to binning invalid
        PCO_ERROR_FIRMWARE_COC_ROI_DOUBLE_INVALID   = $80001035 ; // Camera setting ROI to double invalid
        PCO_ERROR_FIRMWARE_COC_MODE_INVALID         = $80001036 ; // Camera mode setting invalid
        PCO_ERROR_FIRMWARE_COC_DELAY_INVALID        = $80001037 ; // Camera delay setting invalid
        PCO_ERROR_FIRMWARE_COC_EXPOS_INVALID        = $80001038 ; // Camera exposure setting invalid
        PCO_ERROR_FIRMWARE_COC_TIMEBASE_INVALID     = $80001039 ; // Camera timebase setting invalid
        PCO_ERROR_FIRMWARE_ACQUIRE_MODE_INVALID     = $8000103A ; // Acquire settings are invalid
        PCO_ERROR_FIRMWARE_IF_SETTINGS_INVALID      = $8000103B ; // Interface settings are invalid
        PCO_ERROR_FIRMWARE_ROI_NOT_SYMMETRICAL      = $8000103C ; // ROI is not symmetrical
        PCO_ERROR_FIRMWARE_ROI_STEPPING             = $8000103D ; // ROI steps do not match
        PCO_ERROR_FIRMWARE_ROI_SETTING              = $8000103E ; // ROI setting is wrong

        PCO_ERROR_FIRMWARE_COC_PERIOD_INVALID       = $80001040 ; //
        PCO_ERROR_FIRMWARE_COC_MONITOR_INVALID      = $80001041 ; //

        PCO_ERROR_FIRMWARE_UNKNOWN_DEVICE           = $80001050 ; // attempt to open an unknown device
        PCO_ERROR_FIRMWARE_DEVICE_NOT_AVAIL         = $80001051 ; // device not avail. for this camera type
        PCO_ERROR_FIRMWARE_DEVICE_IS_OPEN           = $80001052 ; // this or other device is already open
        PCO_ERROR_FIRMWARE_DEVICE_NOT_OPEN          = $80001053 ; // no device opened for update commands

        PCO_ERROR_FIRMWARE_NO_DEVICE_RESPONSE       = $80001054 ; // attempt to open device failed
        PCO_ERROR_FIRMWARE_WRONG_DEVICE_TYPE        = $80001055 ; // wrong/unexpected device type
        PCO_ERROR_FIRMWARE_ERASE_FLASH_FAILED       = $80001056 ; // erasing flash failed
        PCO_ERROR_FIRMWARE_DEVICE_NOT_BLANK         = $80001057 ; // device is not blank when programming

        PCO_ERROR_FIRMWARE_ADDRESS_OUT_OF_RANGE     = $80001058 ; // address for program or read out of range
        PCO_ERROR_FIRMWARE_PROG_FLASH_FAILED        = $80001059 ; // programming flash failed
        PCO_ERROR_FIRMWARE_PROG_EEPROM_FAILED       = $8000105A ; // programming eeprom failed
        PCO_ERROR_FIRMWARE_READ_FLASH_FAILED        = $8000105B ; // reading flash failed

        PCO_ERROR_FIRMWARE_READ_EEPROM_FAILED       = $8000105C ; // reading eeprom failed

        PCO_ERROR_FIRMWARE_GIGE_COMMAND_IS_INVALID           = $080001080 ; // command is invalid
        PCO_ERROR_FIRMWARE_GIGE_UART_NOT_OPERATIONAL         = $080001081 ; // camera UART not operational
        PCO_ERROR_FIRMWARE_GIGE_ACCESS_DENIED                = $080001082 ; // access denied
        PCO_ERROR_FIRMWARE_GIGE_COMMAND_UNKNOWN              = $080001083 ; // command unknown
        PCO_ERROR_FIRMWARE_GIGE_COMMAND_GROUP_UNKNOWN        = $080001084 ; // command group unknown
        PCO_ERROR_FIRMWARE_GIGE_INVALID_COMMAND_PARAMETERS   = $080001085 ; // invalid command parameters
        PCO_ERROR_FIRMWARE_GIGE_INTERNAL_ERROR               = $080001086 ; // internal error
        PCO_ERROR_FIRMWARE_GIGE_INTERFACE_BLOCKED            = $080001087 ; // interface blocked
        PCO_ERROR_FIRMWARE_GIGE_INVALID_SESSION              = $080001088 ; // invalid session
        PCO_ERROR_FIRMWARE_GIGE_BAD_OFFSET                   = $080001089 ; // bad offset
        PCO_ERROR_FIRMWARE_GIGE_NV_WRITE_IN_PROGRESS         = $08000108a ; // NV write in progress
        PCO_ERROR_FIRMWARE_GIGE_DOWNLOAD_BLOCK_LOST          = $08000108b ; // download block lost
        PCO_ERROR_FIRMWARE_GIGE_DOWNLOAD_INVALID_LDR         = $08000108c ; // flash loader block invalid

        PCO_ERROR_FIRMWARE_GIGE_DRIVER_IMG_PKT_LOST			 = $080001090 ; // Image packet lost
        PCO_ERROR_FIRMWARE_GIGE_BANDWIDTH_CONFLICT			 = $080001091 ; // GiGE Data bandwidth conflict

        PCO_ERROR_FIRMWARE_FLICAM_EXT_MOD_OUT_OF_RANGE = $80001100 ; // external modulation frequency out of range
        PCO_ERROR_FIRMWARE_FLICAM_SYNC_PLL_NOT_LOCKED  = $80001101 ; // sync PLL not locked

        PCO_WARNING_FIRMWARE_FUNC_ALREADY_ON        = $C0001001 ; // Function is already on
        PCO_WARNING_FIRMWARE_FUNC_ALREADY_OFF       = $C0001002 ; // Function is already off
        PCO_WARNING_FIRMWARE_HIGH_TEMPERATURE       = $C0001003 ; // High temperature warning

        PCO_WARNING_FIRMWARE_OFFSET_NOT_LOCKED      = $C0001004 ; // offset regulation is not locked

type

TBigWordArray = Array[0..99999999] of Word ;
PBigWordArray = ^TBigWordArray ;
TBufNumArray = Array[0..PCOAPIMaxBufs-1] of SmallInt ;
PBufNumArray = ^TBufNumArray ;


TWaitBufferThread = class(TThread)
  protected
    // the main body of the thread
    procedure Execute; override;
  end;

TPCO_Description = packed record

    wSize : Word ;                   // Sizeof this struct
    wSensorTypeDESC : Word ;         // Sensor type
    wSensorSubTypeDESC : Word ;      // Sensor subtype
    wMaxHorzResStdDESC : Word ;      // Maxmimum horz. resolution in std.mode
    wMaxVertResStdDESC : Word ;      // Maxmimum vert. resolution in std.mode // 10
    wMaxHorzResExtDESC : Word ;      // Maxmimum horz. resolution in ext.mode
    wMaxVertResExtDESC : Word ;      // Maxmimum vert. resolution in ext.mode
    wDynResDESC : Word ;             // Dynamic resolution of ADC in bit
    wMaxBinHorzDESC : Word ;         // Maxmimum horz. binning
    wBinHorzSteppingDESC : Word ;    // Horz. bin. stepping (0:bin, 1:lin)    // 20
    wMaxBinVertDESC : Word ;         // Maxmimum vert. binning
    wBinVertSteppingDESC : Word ;    // Vert. bin. stepping (0:bin, 1:lin)
    wRoiHorStepsDESC : Word ;        // Minimum granularity of ROI in pixels
    wRoiVertStepsDESC : Word ;       // Minimum granularity of ROI in pixels
    wNumADCsDESC : Word ;            // Number of ADCs in system              // 30
    wMinSizeHorzDESC : Word ;        // Minimum x-size in pixels in horz. direction
    dwPixelRateDESC : Array[0..3] of DWord ;      // Possible pixelrate in Hz              // 48
    ZZdwDummypr : Array[0..19] of DWord ;                 // 128
    wConvFactDESC : Array[0..3] of Word ;    // Possible conversion factor in e/cnt   // 136
    sCoolingSetpoints : Array[0..9] of SmallInt ;         // Cooling setpoints in case there is no cooling range // 156
    ZZdwDummycv : Array[0..7] of Word ;                                                   // 172
    wSoftRoiHorStepsDESC : Word ;    // Minimum granularity of SoftROI in pixels
    wSoftRoiVertStepsDESC : Word ;   // Minimum granularity of SoftROI in pixels
    wIRDESC : Word ;                 // IR enhancment possibility
    wMinSizeVertDESC : Word ;        // Minimum y-size in pixels in vert. direction
    dwMinDelayDESC : DWord ;          // Minimum delay time in ns
    dwMaxDelayDESC : DWord ;          // Maximum delay time in ms
    dwMinDelayStepDESC : DWord ;      // Minimum stepping of delay time in ns  // 192
    dwMinExposureDESC : DWord ;       // Minimum exposure time in ns
    dwMaxExposureDESC : DWord ;       // Maximum exposure time in ms           // 200
    dwMinExposureStepDESC : DWord ;   // Minimum stepping of exposure time in ns
    dwMinDelayIRDESC : DWord ;        // Minimum delay time in ns
    dwMaxDelayIRDESC : DWord ;        // Maximum delay time in ms              // 212
    dwMinExposureIRDESC : DWord ;     // Minimum exposure time in ns
    dwMaxExposureIRDESC : DWord ;     // Maximum exposure time in ms           // 220
    wTimeTableDESC : Word ;          // Timetable for exp/del possibility
    wDoubleImageDESC : Word ;        // Double image mode possibility
    sMinCoolSetDESC : SmallInt ;         // Minimum value for cooling
    sMaxCoolSetDESC : SmallInt ;         // Maximum value for cooling
    sDefaultCoolSetDESC : SmallInt ;     // Default value for cooling             // 230

    wPowerDownModeDESC : Word ;      // Power down mode possibility
    wOffsetRegulationDESC : Word ;   // Offset regulation possibility
    wColorPatternDESC : Word ;       // Color pattern of color chip
    wPatternTypeDESC : Word  ;        // Pattern type of color chip
    wDummy1 : Word ;                 // former DSNU correction mode             // 240
    wDummy2 : Word ;                 //
    wNumCoolingSetpoints : Word ;    //
    dwGeneralCapsDESC1 : DWord ;   // General capabilities:
                                       // Bit 0: Noisefilter available
                                       // Bit 1: Hotpixelfilter available
                                       // Bit 2: Hotpixel works only with noisefilter
                                       // Bit 3: Timestamp ASCII only available (Timestamp mode 3 enabled)

                                       // Bit 4: Dataformat 2x12
                                       // Bit 5: Record Stop Event available
                                       // Bit 6: Hot Pixel correction
                                       // Bit 7: Ext.Exp.Ctrl. not available

                                       // Bit 8: Timestamp not available
                                       // Bit 9: Acquire mode not available
                                       // Bit10: Dataformat 4x16
                                       // Bit11: Dataformat 5x16

                                       // Bit12: Camera has no internal recorder memory
                                       // Bit13: Camera can be set to fast timing mode (PIV)
                                       // Bit14: Camera can produce metadata
                                       // Bit15: Camera allows Set/GetFrameRate cmd

                                       // Bit16: Camera has Correlated Double Image Mode
                                       // Bit17: Camera has CCM
                                       // Bit18: Camera can be synched externally
                                       // Bit19: Global shutter setting not available

                                       // Bit20: Camera supports global reset rolling readout
                                       // Bit21: Camera supports extended acquire command
                                       // Bit22: Camera supports fan control command
                                       // Bit23: Camera vert.ROI must be symmetrical to horizontal axis

                                       // Bit24: Camera horz.ROI must be symmetrical to vertical axis
                                       // Bit25: Camera has cooling setpoints instead of cooling range

                                       // Bit26:
                                       // Bit27: reserved for future use

                                       // Bit28: reserved for future desc.// Bit29:  reserved for future desc.

                                       // Bit 30: HW_IO_SIGNAL_DESCRIPTOR available
                                       // Bit 31: Enhanced descriptor available

    dwGeneralCapsDESC2 : DWord ;      // General capabilities 2                  // 252
                                       // Bit 0 ... 29: reserved for future use
                                       // Bit 30: used internally (sc2_defs_intern.h)
                                       // Bit 31: used internally (sc2_defs_intern.h)
    dwExtSyncFrequency : Array[0..3] of DWord ;   // lists four frequencies for external sync feature
    dwGeneralCapsDESC3 : DWord ;      // general capabilites descr. 3
    dwGeneralCapsDESC4 : DWord ;      // general capabilites descr. 4            // 276
    ZZdwDummy : Array[0..39] of DWord ;

    end ;                                                      // 436

TPCO_ImageTiming = packed record
  wSize : Word ;
  wDummy : Word ;
  FrameTime_ns : DWord ;                 // Frametime replaces COC_Runtime
  FrameTime_s : DWord ;
  ExposureTime_ns : DWord ;
  ExposureTime_s : DWord ;               // 5
  TriggerSystemDelay_ns : DWord ;        // System internal min. trigger delay
  TriggerSystemJitter_ns : DWord ;       // Max. possible trigger jitter -0/+ ... ns
  TriggerDelay_ns : DWord ;              // Resulting trigger delay = system delay
  TriggerDelay_s : DWord ;               // + delay of SetDelayExposureTime ... // 9
  ZZdwDummy : Array[0..10] of DWord ;                // 20
  end ;

TPCO_BufListItem = packed record
  Size : Short ;
  reserved : Word ;
  StatusDll : DWord ;
  StatusDrv : DWord ;
  end ;

TPCOAPISession = record
     CamHandle : THandle ;
     NumPixelsPerFrame : Integer ;     // No. of pixels in image
     NumBytesPerFrame : Integer ;     // No. of bytes in image
     NumFramesInBuffer : Integer ;    // No. of images in circular transfer buffer
     FramePointer : Integer ;         // Current frame no.
     PFrameBuffer : PBigWordArray ;         // Pointer to start of image destination buffer
     BufNum : TBufNumArray ;           // Buffer number list
     BufPointer : Integer ;            // Latest BufNum pointer
     pBuf : Array[0..PCOAPINumBufs-1] of PWordArray ;       // Array of pointers to internal image buffers
     BufEvent : Array[0..PCOAPINumBufs-1] of THandle ;  // Array of buffer event numbers
     NumBytesPerFrameBuffer : Int64 ;                // No. of bytes in image buffer
     NumFramesAcquired : Integer ;
     GetImageInUse : LongBool ;       // GetImage procedure running
     CapturingImages : LongBool ;     // Image capture in progress
     CameraOpen : LongBool ;          // Camera open for use
     TimeStart : single ;
     Temperature : Double ;
     SetPointTemperature : SmallInt ;

     FrameLeft : Integer ;            // Left pixumbyteel in CCD readout area
     FrameTop : Integer ;             // Top pixel in CCD eadout area
     FrameRight : Integer ;           // Width of CCD readout area
     FrameBottom : Integer ;          // Width of CCD readout area
     BinFactor : Integer ;             // Binning factor (1,2,4,8,16)

     AOIWidth : Word ;
     AOIHeight : Word ;
     AOIRowSpacing : Integer ;
     ImageEnd : Integer ;
     AOINumPixels : Integer ;
     NumBitsPerPixel : Word ;

     GainList : Array[0..15] of Word ; // Pixel intensity gain list (e/bit)
     NumGains : Integer ;                // No. of gains available

     ReadoutSpeedList : Array[0..15] of DWord ; // List of Readout speeds
     NumReadoutSpeeds : Integer ;                // No. of readout speeds available
     ReadoutSpeed : Integer ;                    // Readout speed in use
     CameraMode : Integer ;
     LibFileName : String ;
     ReadoutRate : Integer ;
     ReadoutRateList : TStringList ;
     ADCNum : Integer ;
     ADConverterList : TStringList ;
     BinFactorList : Array[0..15] of DWord ;  // List of bin factors
     NumBinFactors : Integer ;                  //
     Mode : Integer ;
     ModeList : TStringList ;
     TemperatureSettingsList : TStringList ;
     PCO_Description : TPCO_Description ;
     CameraName : string ;
     end ;

PPCOAPISession = ^TPCOAPISession ;


TPCO_OpenCamera = function(
                  var ph : THandle ;
                  wCamNum : Word
                  ) : Integer ; stdcall ;

TPCO_GetRecordingState = function(
                         ph : THandle ;
                         var wRecState : Word
                         ) : Integer ; stdcall ;

TPCO_SetRecordingState = function(
                         ph : THandle ;
                         wRecState : Word
                         ) : Integer ; stdcall ;

TPCO_CloseCamera = function(
                   ph : THandle
                   ) : Integer ; stdcall ;

TPCO_GetFrameRate = function(
                    ph : THandle ;
                    var wFrameRateStatus : Word ;
                    var dwFrameRate : DWord ;
                    var dwFrameRateExposure : DWord
                   ) : Integer ; stdcall ;

TPCO_SetFrameRate = function(
                    ph : THandle ;
                    var wFrameRateStatus : Word ;
                    wFrameRateMode : Word ;
//                    var dwFrameRate : DWord ;
                    dwFrameRate : Pointer ;
                    var dwFrameRateExposure : DWord
                   ) : Integer ; stdcall ;
// Sets the frame rate mode, rate and exposure
// This option is only available with a pco.dimax
// In: HANDLE ph -> Handle to a proviously opened camera.
//     WORD* wFrameRateStatus -> WORD variable to receive the status
//           0x0000: Settings consistent, all conditions met
//           0x0001: Framerate trimmed, framerate was limited by readout time
//           0x0002: Framerate trimmed, framerate was limited by exposure time
//           0x0004: Exposure time trimmed, exposure time cut to frame time
//     WORD wFrameRateMode -> WORD variable to set the frame rate mode
//           0x0000: auto mode (camera decides which parameter will be trimmed)
//           0x0001: Framerate has priority, (exposure time will be trimmed)
//           0x0002: Exposure time has priority, (framerate will be trimmed)
//           0x0003: Strict, function shall return with error if values are not possible.
//     DWORD* dwFrameRate -> DWORD variable to receive the actual frame rate
//     DWORD* dwFrameRateExposure -> DWORD variable to receive the actual exposure time (in ns)
// Out: int -> Error message

TPCO_SetDelayExposureTime = function(
                            ph : THandle ;
                            dwDelay : DWord ;
                            dwExposure : DWord ;
                            wTimeBaseDelay : Word ;
                            wTimeBaseExposure : Word
                            ) : Integer ; stdcall ;

TPCO_GetImageTiming = function(
                      ph : THandle ;
                      var pImageTiming : TPCO_ImageTiming
                      ) : Integer ; stdcall ;

TPCO_AllocateBuffer = function(
                       ph : THandle ;
                       sBufNr : PBufNumArray ;
                       size : DWord ;
                       wBuf : Pointer ;
                       hEvent : Pointer
                       ) : Integer ; stdcall ;

TPCO_AddBufferEx = function(
                   ph : THandle ;
                   dw1stImage : DWord ;
                   dwLastImage : DWord ;
                   sBufNr : SmallInt ;
                   wXRes : Word ;
                   wYRes : Word ;
                   wBitPerPixel : Word
                   ) : Integer ; stdcall ;

TPCO_SetImageParameters = function(
                          ph : THandle ;
                          wxres : Word ;
                          wyres : Word ;
                          dwFlags : DWord ;
                          Param : Pointer ;
                          ilen : Integer
                          ) : Integer ; stdcall ;

TPCO_SetTransferParameter = function(
                            ph : THandle ;
                            Buffer : Pointer ;
                            iLen : Integer
                            ) : Integer ; stdcall ;

TPCO_WaitforBuffer = function(
                     ph : THandle ;
                     nr_of_buffer : Integer ;
                     PCO_Buflist : Pointer ;
                     timeout : Integer
                     ) : Integer ; stdcall ;

TPCO_GetBuffer = function(
                 ph : THandle ;
                 sBufNr : SmallInt ;
                 wBuf : Pointer ;
                 var hEvent : THandle
                 ) : Integer ; stdcall ;

TPCO_FreeBuffer = function(
                  ph : THandle ;
                  sBufNr : SmallInt
                 ) : Integer ; stdcall ;

TPCO_AddBuffer = function(
                  ph : THandle ;
                  dw1stImage : DWord ;
                  dwLastImage : DWord ;
                  sBufNr : SmallInt
                 ) : Integer ; stdcall ;

TPCO_GetBufferStatus = function(
                       ph : THandle ;
                       sBufNr : SmallInt ;
                       var dwStatusDLL : DWord ;
                       var dwStatusDrv : DWord
                       ) : Integer ; stdcall ;

TPCO_CancelImages = function(
                    ph : THandle
                    ) : Integer ; stdcall ;

TPCO_RemoveBuffer = function(
                    ph : THandle
                    ) : Integer ; stdcall ;


TPCO_GetPendingBuffer = function(
                        ph : THandle ;
                        var count : Integer
                        ) : Integer ; stdcall ;
// Gets the number of buffers which were previously added by PCO_AddBuffer and which are
// left in the driver queue for getting images.
// In: HANDLE ph -> Handle to a previously opened camera.
//     int *count -> Pointer to an int variable to receive the buffer count.
// Out: int -> Error message.


TPCO_ResetSettingsToDefault = function(
                             ph : THandle
                             ) : Integer ; stdcall ;
// Resets the camera to a default setting.
// In: HANDLE ph -> Handle to a previously opened camera.
// Out: int -> Error message.

TPCO_GetTemperature = function(
                      ph : THandle ;
                      var sCCDTemp : SmallInt ;
                      var sCamTemp : SmallInt ;
                      var sPowTemp : SmallInt
                      ) : Integer ; stdcall ;
// Gets the actual temperatures of the camera and the power device.
// In: HANDLE ph -> Handle to a previously opened camera.
//     SHORT *sCCDTemp -> Pointer to a SHORT variable, to receive the CCD temp. value.
//     SHORT *sCamTemp -> Pointer to a SHORT variable, to receive the camera temp. value.
//     SHORT *sPowTemp -> Pointer to a SHORT variable, to receive the power device temp. value.
// Out: int -> Error message.

TPCO_GetInfoString = function(
                     ph : THandle ;
                     dwinfotype : DWORD ;
                     buf_in : PANSIChar ;
                     size_in : Word
                     ) : Integer ; stdcall ;
// Gets the name of the camera. Max 500 bytes.
// In: HANDLE ph -> Handle to a previously opened camera.
//     DWORD dwinfotype -> 0: Camera and interface name
//                         1: Camera name only
//                         2: Sensor name
//     char *buf_in -> Pointer to a string, to receive the info string.
//     WORD size_in -> WORD variable which holds the maximum length of the string.
// Out: int -> Error message.

TPCO_GetCameraName = function(
                     ph : THandle ;
                     szCameraName : PANSIChar ;
                     wSZCameraNameLen : Word
                     ) : Integer ; stdcall ;
// Gets the name of the camera. Max 40 bytes.
// Not applicable to all cameras.
// In: HANDLE ph -> Handle to a previously opened camera.
//     char *szCameraName -> Pointer to a string, to receive the camera name.
//     WORD wSZCameraNameLen -> WORD variable which holds the maximum length of the string.
// Out: int -> Error message.

TPCO_GetCameraSetup = function(
                  ph : THandle ;
                  var wType : Word ;
                  var dwSetup : DWord ;
                  var wLen : Word
                  ) : Integer ; stdcall ;
// Gets the camera setup structure (see camera specific structures)
// Not applicable to all cameras.
// See sc2_defs.h for valid flags: -- Defines for Get / Set Camera Setup
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD* wType -> Pointer to a word to get the actual type (Can be NULL to query wLen).
//     DWORD* dwSetup -> Pointer to a dword array (Can be NULL to query wLen)
//     WORD *wLen -> WORD Pointer to get the length of the array in DWORDS
// Out: int -> Error message.

TPCO_SetCameraSetup = function(
                  ph : THandle ;
                  var wType : Word ;
                  var dwSetup : DWord ;
                  var wLen : Word
                  ) : Integer ; stdcall ;
// Sets the camera setup structure (see camera specific structures)
// Camera must be reinitialized do activate new setup: Reboot(optional)-Close-Open
// Not applicable to all cameras.
// See sc2_defs.h for valid flags: -- Defines for Get / Set Camera Setup
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wType -> Word to set the actual type
//     DWORD* dwSetup -> Pointer to a dword array
//     WORD wLen -> WORD to set the length of the array in DWORDs
// Out: int -> Error message.


TPCO_RebootCamera = function(
                  ph : THandle
                  ) : Integer ; stdcall ;
// Reboot camera. Call a PCO_CloseCamera afterwards and wait at least 10 seconds before reopening it.
// In: HANDLE ph -> Handle to a previously opened camera.
// Out: int -> Error message.


TPCO_GetCameraDescription = function(
                            ph : THandle ;
                            pPCO_Description : Pointer
//                            var PCO_Description : TPCO_Description
                            ) : Integer ; stdcall ;
// Gets the camera description data structure.
// In: HANDLE ph -> Handle to a previously opened camera.
//     PCO_Description *strDescription -> Pointer to a PCO_Description structure.
// Out: int -> Error message.

TPCO_GetSizes = function(
                ph : THandle ;
                var wXResAct : Word ; // Actual X Resolution
                var wYResAct : Word ;  // Actual Y Resolution
                var wXResMax : Word ;  // Maximum X Resolution
                var wYResMax : Word   // Maximum Y Resolution
                ) : Integer ; stdcall ;
// Gets the actual and maximum sizes of the camera. The maximum y value includes the
// size of a double shutter image.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD *wXResAct -> Pointer to a WORD variable to receive the actual X resolution.
//     WORD *wYResAct -> Pointer to a WORD variable to receive the actual Y resolution.
//     WORD *wXResMax -> Pointer to a WORD variable to receive the maximal X resolution.
//     WORD *wXResMax -> Pointer to a WORD variable to receive the maximal Y resolution.
// Out: int -> Error message.

TPCO_GetROI = function(
              ph : THandle ;
              var wRoiX0 : Word ; // Roi upper left x
              var wRoiY0 : Word ;  // Roi upper left y
              var wRoiX1 : Word ;  // Roi lower right x
              var wRoiY1 : Word  // Roi lower right y
              ) : Integer ; stdcall ;
// Gets the region of interest of the camera. X0, Y0 start at 1. X1, Y1 end with max. sensor size.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD *wRoiX0 -> Pointer to a WORD variable to receive the x value for the upper left corner.
//     WORD *wRoiY0 -> Pointer to a WORD variable to receive the y value for the upper left corner.
//     WORD *wRoiX1 -> Pointer to a WORD variable to receive the x value for the lower right corner.
//     WORD *wRoiY0 -> Pointer to a WORD variable to receive the y value for the lower right corner.
//      x0,y0----------|
//      |     ROI      |
//      ---------------x1,y1
// Out: int -> Error message.

TPCO_SetROI = function(
              ph : THandle ;
              wRoiX0 : Word ; // Roi upper left x
              wRoiY0 : Word ;  // Roi upper left y
              wRoiX1 : Word ;  // Roi lower right x
              wRoiY1 : Word  // Roi lower right y
              ) : Integer ; stdcall ;
// Sets the region of interest of the camera. X0, Y0 start at 1. X1, Y1 end with max. sensor size.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wRoiX0 -> WORD variable to hold the x value for the upper left corner.
//     WORD wRoiY0 -> WORD variable to hold the y value for the upper left corner.
//     WORD wRoiX1 -> WORD variable to hold the x value for the lower right corner.
//     WORD wRoiY0 -> WORD variable to hold the y value for the lower right corner.
//      x0,y0----------|
//      |     ROI      |
//      ---------------x1,y1
// Out: int -> Error message.

TPCO_GetBinning = function(
                  ph : THandle ;
                  var wBinHorz : Word ; // Binning horz. (x)
                  var wBinVert : Word // Binning vert. (y)
                  ) : Integer ; stdcall ;
// Gets the binning values of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD *wBinHorz -> Pointer to a WORD variable to hold the horizontal binning value.
//     WORD *wBinVert -> Pointer to a WORD variable to hold the vertikal binning value.
// Out: int -> Error message.

TPCO_SetBinning = function(
                  ph : THandle ;
                  wBinHorz : Word ; // Binning horz. (x)
                  wBinVert : Word // Binning vert. (y)
                  ) : Integer ; stdcall ;
// Sets the binning values of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wBinHorz -> WORD variable to hold the horizontal binning value.
//     WORD wBinVert -> WORD variable to hold the vertikal binning value.
// Out: int -> Error message.

TPCO_SetPixelRate = function(
                  ph : THandle ;
                  dwPixelRate : DWord     // Pixelrate
                  ) : Integer ; stdcall ;
// Sets the pixel rate of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     DWORD dwPixelRate -> DWORD variable to hold the pixelrate.
// Out: int -> Error message.

TPCO_GetConversionFactor = function(
                           ph : THandle ;
                           var wConvFact : Word   // Conversion Factor (Gain)
                           ) : Integer ; stdcall ;
// Gets the conversion factor of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD *wConvFact -> Pointer to a WORD variable to receive the conversin factor.
// Out: int -> Error message.

TPCO_SetConversionFactor = function(
                          ph : THandle ;
                          wConvFact : Word   // Conversion Factor (Gain)
                          ) : Integer ; stdcall ;

// Sets the conversion factor of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wConvFact -> WORD variable to hold the conversin factor.
// Out: int -> Error message.

TPCO_GetDoubleImageMode = function(
                          ph : THandle ;
                          var wDoubleImage : Word // DoubleShutter Mode
                          ) : Integer ; stdcall ;
// Gets the double image mode of the camera.
// Not applicable to all cameras. Check Description
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD *wDoubleImage -> Pointer to a WORD variable to receive the double image mode.
// Out: int -> Error message.

TPCO_SetDoubleImageMode = function(
                          ph : THandle ;
                          wDoubleImage : Word // DoubleShutter Mode
                          ) : Integer ; stdcall ;
// Sets the double image mode of the camera, if available.
// Not applicable to all cameras. Check Description
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wDoubleImage -> WORD variable to hold the double image mode.
// Out: int -> Error message.

TPCO_GetADCOperation = function(
                       ph : THandle ;
                       var wADCOperation : Word  // ADC Operation
                       ) : Integer ; stdcall ;
// Gets the adc operation mode of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD *wADCOperation -> Pointer to a WORD variable to receive the adc operation mode.
// Out: int -> Error message.

TPCO_SetADCOperation = function(
                       ph : THandle ;
                       wADCOperation : Word  // ADC Operation
                       ) : Integer ; stdcall ;
// Sets the adc operation mode of the camera, if available.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wADCOperation -> WORD variable to hold the adc operation mode.
// Out: int -> Error message.

TPCO_GetCoolingSetpoints = function(
                           ph : THandle ;
                           wBlockID : WORD ;
                           var wNumSetPoints : Word ;
                           var sCoolSetpoints : Array of SmallInt
                           ) : Integer ; stdcall ;
// Gets the cooling set points of the camera. This is used when there is no min max range available.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wBlockID -> Number of the block to query (currently 0)
//     WORD *wNumSetpoints -> WORD Pointer to set the max number of setpoints to query and to get the
//                            valid number of set points inside the camera. In case more than
//                            COOLING_SETPOINTS_BLOCKSIZE set points are valid they can be queried by
//                            incrementing the wBlockID till wNumSetPoints is reached.
//                            The valid members of the set points can be used to set the SetCoolingSetpointTemperature
//     SHORT *sCoolSetpoints -> Pointer to a SHORT array to receive the possible cooling setpoint temperatures.
// Out: int -> Error message.

TPCO_GetCoolingSetpointTemperature = function(
                                     ph : THandle ;
                                     var sCoolSet : SmallInt // Cooling set point
                                     ) : Integer ; stdcall ;
// Gets the cooling set point temperature of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     SHORT *sCoolSet -> Pointer to a SHORT variable to receive the cooling setpoint temperature.
// Out: int -> Error message.

TPCO_SetCoolingSetpointTemperature = function(
                                     ph : THandle ;
                                     sCoolSet : SmallInt // Cooling set point
                                     ) : Integer ; stdcall ;
// Sets the cooling set point temperature of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     SHORT sCoolSet -> SHORT variable to hold the cooling setpoint temperature.
// Out: int -> Error message.

TPCO_GetOffsetMode = function(
                     ph : THandle ;
                     var wOffsetRegulation : Word  // Offset mode
                     ) : Integer ; stdcall ;
// Gets the offset mode of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD *wOffsetRegulation -> Pointer to a WORD variable to receive the offset mode.
// Out: int -> Error message.

TPCO_SetOffsetMode = function(
                     ph : THandle ;
                     wOffsetRegulation : Word  // Offset mode
                     ) : Integer ; stdcall ;
// Sets the offset mode of the camera, if available.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wOffsetRegulation -> WORD variable to hold the offset mode.
// Out: int -> Error message.

TPCO_GetNoiseFilterMode = function(
                          ph : THandle ;
                          var wNoiseFilterMode : Word
                          ) : Integer ; stdcall ;
// Gets the noise filter mode of the camera, if available.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD *wNoiseFilterMode -> Pointer to a WORD variable to receive the noise filter mode.
// Out: int -> Error message.

TPCO_SetNoiseFilterMode = function(
                          ph : THandle ;
                          var wNoiseFilterMode : Word
                          ) : Integer ; stdcall ;
// Sets the noise filter mode of the camera, if available.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wNoiseFilterMode -> WORD variable to hold the noise filter mode.
// Out: int -> Error message.




TPCO_GetTriggerMode = function(
                  ph : THandle ;
                  var wTriggerMode : Word
                  ) : Integer ; stdcall ;
// Gets the trigger mode of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD* wTriggerMode -> Pointer to a WORD variable to receive the triggermode.
// Out: int -> Error message.

TPCO_SetTriggerMode = function(
                  ph : THandle ;
                  wTriggerMode : Word
                  ) : Integer ; stdcall ;

// Sets the trigger mode of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD wTriggerMode -> WORD variable to hold the triggermode.
// Out: int -> Error message.

TPCO_ForceTrigger = function(
                  ph : THandle ;
                  var wTriggered : Word
                  ) : Integer ; stdcall ;
// Forces a software trigger to the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD* wTriggered -> Pointer to a WORD variable to receive whether
//                         a trigger occurred or not.
// Out: int -> Error message.

TPCO_GetCameraBusyStatus = function(
                           ph : THandle ;
                  var wCameraBusyState : Word
                  ) : Integer ; stdcall ;
// Gets the busy state of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD* wCameraBusyState -> Pointer to a WORD variable to receive the busy state.
// Out: int -> Error message.


TPCO_GetExpTrigSignalStatus = function(
                              ph : THandle ;
                  var wExpTrgSignal : Word
                  ) : Integer ; stdcall ;
// Gets the exposure trigger signal state of the camera.
// In: HANDLE ph -> Handle to a previously opened camera.
//     WORD* wExpTrgSignal -> Pointer to a WORD variable to receive the
//                            exposure trigger signal state.
// Out: int -> Error message.


TPCO_ArmCamera = function(
                 ph : THandle
                  ) : Integer ; stdcall ;
// Sets all previously set data to the camera operation code. This command prepares the
// camera for recording images. This is the last command before setting the recording
// state. If you change any settings after this command, you have to send this command again.
// If you don't arm your camera after changing settings, the camera will run with the last
// 'armed' settings and in this case you do not know in what way your camera is acquiring images.
// In: HANDLE ph -> Handle to a previously opened camera.
// Out: int -> Error message.

TPCO_ResetLib = procedure ;
// Resets the sc2_cam internal enumerator and unloads all loaded interface dlls.



// Function calls

function PCOAPI_GetDLLAddress(
         Handle : THandle ;
         const ProcName : string ) : Pointer ;

function PCOAPI_CheckDLLExists( DLLName : String ) : Boolean ;

procedure PCOAPI_LoadLibrary(
          var Session : TPCOAPISession   // Camera session record  ;
          ) ;

function PCOAPI_OpenCamera(
          var Session : TPCOAPISession ;   // Camera session record
          var FrameWidthMax : Integer ;      // Returns camera frame width
          var FrameHeightMax : Integer ;     // Returns camera frame width
          var BinFactorMax : Integer ;       // Maximum bin factor
          var NumBytesPerPixel : Integer ;   // Returns bytes/pixel
          var PixelDepth : Integer ;         // Returns no. bits/pixel
          var PixelWidth : Single ;          // Returns pixel size (um)
          CameraInfo : TStringList         // Returns Camera details
          ) : LongBool ;

function PCOAPI_PixelDepth( ADConverterList : TStringList ;
                               ADCNum : Integer ) : Integer ;

procedure PCOAPI_CloseCamera(
          var Session : TPCOAPISession // Session record
          ) ;

procedure PCOAPI_GetCameraGainList(
          var Session : TPCOAPISession ; // Session record
          CameraGainList : TStringList
          ) ;

procedure PCOAPI_GetCameraReadoutSpeedList(
          var Session : TPCOAPISession ; // Session record
          CameraReadoutSpeedList : TStringList
          ) ;

procedure PCOAPI_GetCameraModeList(
          var Session : TPCOAPISession ; // Session record
          List : TStringList
          ) ;

procedure PCOAPI_GetCameraADCList(
          var Session : TPCOAPISession ; // Session record
          List : TStringList
          ) ;

procedure PCOAPI_CheckROIBoundaries(
         var Session : TPCOAPISession ;   // Camera session record
         var FrameLeft : Integer ;            // Left pixel in CCD readout area
         var FrameRight : Integer ;           // Right pixel in CCD eadout area
         var FrameTop : Integer ;             // Top of CCD readout area
         var FrameBottom : Integer ;          // Bottom of CCD readout area
         var  BinFactor : Integer ;   // Pixel binning factor (In)
         FrameWidthMax : Integer ;
         FrameHeightMax : Integer ;
         var FrameWidth : Integer ;
         var FrameHeight : Integer
         ) ;

function PCOAPI_StartCapture(
         var Session : TPCOAPISession ;   // Camera session record
         var InterFrameTimeInterval : Double ;      // Frame exposure time
         AdditionalReadoutTime : Double ; // Additional readout time (s)
         AmpGain : Integer ;              // Camera amplifier gain index
         ExternalTrigger : Integer ;      // Trigger mode
         FrameLeft : Integer ;            // Left pixel in CCD readout area
         FrameTop : Integer ;             // Top pixel in CCD eadout area
         FrameWidth : Integer ;           // Width of CCD readout area
         FrameHeight : Integer ;          // Width of CCD readout area
         BinFactor : Integer ;             // Binning factor (1,2,4,8,16)
         PFrameBuffer : Pointer ;         // Pointer to start of ring buffer
         NumFramesInBuffer : Integer ;    // No. of frames in ring buffer
         NumBytesPerFrame : Integer ;      // No. of bytes/frame
         var ReadoutTime : Double        // Return frame readout time
         ) : LongBool ;

procedure PCOAPI_UpdateCircularBufferSize(
          var Session : TPCOAPISession  ; // Camera session record
          FrameLeft : Integer ;
          FrameRight : Integer ;
          FrameTop : Integer ;
          FrameBottom : Integer ;
          BinFactor : Integer
          ) ;


function PCOAPI_CheckFrameInterval(
          var Session : TPCOAPISession ;   // Camera session record
          FrameLeft : Integer ;   // Left edge of capture region (In)
          FrameRight : Integer ;  // Right edge of capture region( In)
          FrameTop : Integer ;    // Top edge of capture region( In)
          FrameBottom : Integer ; // Bottom edge of capture region (In)
          BinFactor : Integer ;   // Pixel binning factor (In)
          FrameWidthMax : Integer ;   // Max frame width (in)
          FrameHeightMax : Integer ;  // Max. frame height (in)
          Var FrameInterval : Double ;
          Var ReadoutTime : Double ;
          TriggerMode : Integer
          ) : LongBool ;


procedure PCOAPI_Wait( Delay : Single ) ;

procedure PCOAPI_GetImage(
          var Session : TPCOAPISession  // Camera session record
          ) ;

procedure PCOAPI_StopCapture(
          var Session : TPCOAPISession   // Camera session record
          ) ;

procedure PCOAPI_SetTemperature(
          var Session : TPCOAPISession ;    // Session record
          var TemperatureSetPoint : Single  // Required temperature
          ) ;

procedure PCOAPI_SetCooling(
          var Session : TPCOAPISession ; // Session record
          CoolingOn : LongBool  // True = Cooling is on
          ) ;

procedure PCOAPI_SetFanMode(
          var Session : TPCOAPISession ; // Session record
          FanMode : Integer  // 0 = Off, 1=low, 2=high
          ) ;

procedure PCOAPI_SetCameraMode(
          var Session : TPCOAPISession ; // Session record
          Mode : Integer ) ;

procedure PCOAPI_SetCameraADC(
          var Session : TPCOAPISession ; // Session record
          ADCNum : Integer ;
          var PixelDepth : Integer ;
          var GreyLevelMin : Integer ;
          var GreyLevelMax : Integer ) ;

procedure PCOAPI_CheckError(
          FuncName : String ;   // Name of function called
          ErrNum : Integer      // Error # returned by function
          ) ;



implementation

uses SESCam ;

const
   EmptyFlag = $FFFF ;




var

  PCO_OpenCamera : TPCO_OpenCamera ;
  PCO_CloseCamera : TPCO_CloseCamera ;
  PCO_GetRecordingState : TPCO_GetRecordingState ;
  PCO_SetRecordingState : TPCO_SetRecordingState ;
  PCO_GetFrameRate : TPCO_GetFrameRate ;
  PCO_SetFrameRate : TPCO_SetFrameRate ;
  PCO_SetDelayExposureTime : TPCO_SetDelayExposureTime ;
  PCO_GetImageTiming : TPCO_GetImageTiming ;
  PCO_AllocateBuffer : TPCO_AllocateBuffer ;
  PCO_AddBufferEx : TPCO_AddBufferEx ;
  PCO_SetImageParameters : TPCO_SetImageParameters ;
  PCO_SetTransferParameter : TPCO_SetTransferParameter ;
  PCO_WaitforBuffer : TPCO_WaitforBuffer ;
  PCO_GetBuffer : TPCO_GetBuffer ;
  PCO_FreeBuffer : TPCO_FreeBuffer ;
  PCO_AddBuffer : TPCO_AddBuffer ;
  PCO_GetBufferStatus : TPCO_GetBufferStatus ;
  PCO_CancelImages : TPCO_CancelImages ;
  PCO_RemoveBuffer : TPCO_RemoveBuffer ;
  PCO_GetPendingBuffer : TPCO_GetPendingBuffer ;
  PCO_ResetSettingsToDefault : TPCO_ResetSettingsToDefault ;
  PCO_GetTemperature : TPCO_GetTemperature ;
  PCO_GetInfoString : TPCO_GetInfoString ;
  PCO_GetCameraName : TPCO_GetCameraName ;
  PCO_GetCameraSetup : TPCO_GetCameraSetup ;
  PCO_SetCameraSetup : TPCO_SetCameraSetup ;
  PCO_RebootCamera : TPCO_RebootCamera ;
  PCO_GetCameraDescription : TPCO_GetCameraDescription ;
  PCO_GetSizes : TPCO_GetSizes ;
  PCO_GetROI : TPCO_GetROI ;
  PCO_SetROI : TPCO_SetROI ;
  PCO_GetBinning : TPCO_GetBinning ;
  PCO_SetBinning : TPCO_SetBinning ;
  PCO_SetPixelRate : TPCO_SetPixelRate ;
  PCO_GetConversionFactor : TPCO_GetConversionFactor ;
  PCO_SetConversionFactor : TPCO_SetConversionFactor ;
  PCO_GetADCOperation : TPCO_GetADCOperation ;
  PCO_SetADCOperation : TPCO_SetADCOperation ;
  PCO_GetCoolingSetpoints : TPCO_GetCoolingSetpoints ;
  PCO_GetCoolingSetpointTemperature : TPCO_GetCoolingSetpointTemperature ;
  PCO_SetCoolingSetpointTemperature : TPCO_SetCoolingSetpointTemperature ;
  PCO_GetNoiseFilterMode : TPCO_GetNoiseFilterMode ;
  PCO_SetNoiseFilterMode : TPCO_SetNoiseFilterMode ;
  PCO_GetTriggerMode : TPCO_GetTriggerMode ;
  PCO_SetTriggerMode : TPCO_SetTriggerMode ;
  PCO_ForceTrigger : TPCO_ForceTrigger ;
  PCO_GetCameraBusyStatus : TPCO_GetCameraBusyStatus ;
  PCO_GetExpTrigSignalStatus : TPCO_GetExpTrigSignalStatus ;
  PCO_ArmCamera : TPCO_ArmCamera ;

  LibraryHnd : THandle ;         // DLL library handle
  LibraryLoaded : LongBool ;      // DLL library loaded flag
  ATHandle : Integer ;
  NumBuffersAcquired : Integer ;
  BufferErr : Integer ;
  WaitBufferThread : TWaitBufferThread ;
  SessionLoc : TPCOAPISession ;
  NumFramesAcquired,MaxFramesAcquired,tBufferRead : Integer ;


procedure TWaitBufferThread.Execute;
var
    NumBytes,Err : Integer ;
    pRBuf : Pointer ;
    i,iFrom,iTo,MaxFramesPerCall,t0 : Integer ;
    pBuf : PWordArray ;
    StatusDLL, StatusDrv : DWord  ;
    Done : Boolean ;
    PCO_Buflist : Array[0..PCOAPINumBufs-1] of TPCO_BuflistItem ;
begin
  // execute codes inside the following block until the thread is terminated

  for i := 0 to High(PCO_Buflist) do PCO_BufList[i].Size := SessionLoc.BufNum[i] ;

  while not Terminated do begin

    PCOAPI_CheckError('PCO_WaitforBuffer',
                      PCO_WaitforBuffer( SessionLoc.CamHandle,
                                         PCOAPINumBufs,
                                         @PCO_Buflist,
                                         1000));

    // Transfer images from camera buffer to application frame buffer
    Done := False ;
    NumFramesAcquired := 0 ;
    MaxFramesPerCall := PCOAPINumBufs div 2 ;
    t0 := timegettime ;
    repeat

      // Check for completion of buffer transfer
     { PCOAPI_CheckError('PCO_GetBufferStatus',
                       PCO_GetBufferStatus( SessionLoc.CamHandle,
                                            SessionLoc.BufNum[SessionLoc.BufPointer],
                                            StatusDLL, StatusDrv )) ;}

      // Copy camera buffer to output buffer
      if ((PCO_BufList[SessionLoc.BufPointer].StatusDLL and $8000) <> 0) and
          (PCO_BufList[SessionLoc.BufPointer].StatusDrv = PCO_NOERROR) then
         begin
         pBuf := SessionLoc.pBuf[SessionLoc.BufPointer] ;
         iTo := SessionLoc.FramePointer*SessionLoc.AOINumPixels ;
         for i := 0 to SessionLoc.AOINumPixels-1 do
             begin
             PWordArray(SessionLoc.pFrameBuffer)^[iTo] := pBuf^[i] ;
             Inc(iTo) ;
             end ;

         // Add buffer back to queue
         PCOAPI_CheckError('PCO_AddBufferEx',
                           PCO_AddBufferEx(SessionLoc.CamHandle,0,0,
                           SessionLoc.BufNum[SessionLoc.BufPointer],
                           SessionLoc.AOIWidth,
                           SessionLoc.AOIHeight,
                           SessionLoc.NumBitsPerPixel)) ;

         // Increment frame (output) buffer pointer
         Inc(SessionLoc.FramePointer) ;
         if SessionLoc.FramePointer >= SessionLoc.NumFramesInBuffer then SessionLoc.FramePointer := 0 ;
         // Increment camera buffer pointer
         Inc(SessionLoc.BufPointer) ;
         if SessionLoc.BufPointer >= PCOAPINumBufs then SessionLoc.BufPointer := 0 ;

         Inc(SessionLoc.NumFramesAcquired) ;
         Inc(NumFramesAcquired) ;
         MaxFramesAcquired := Max(MaxFramesAcquired,NumFramesAcquired);
         if NumFramesAcquired >= MaxFramesPerCall then Done := True ;
         end
      else Done := True ;
      until Done ;

    SessionLoc.GetImageInUse := False ;
    tBufferRead := Max(timegettime - t0,TBufferRead);
//    sleep(10) ;
    end;

end;


procedure PCOAPI_LoadLibrary(
          var Session : TPCOAPISession   // Camera session record
          ) ;

{ ---------------------------------------------
  Load camera interface DLL library into memory
  ---------------------------------------------}
const
    LibName = 'sc2_cam.dll' ;
begin

     LibraryLoaded := False ;

     // Look for DLL initially in Winfluor folder
     Session.LibFileName := ExtractFilePath(ParamStr(0)) + LibName ;

     // Check that DLLs are available in WinFluor program folder
     if not PCOAPI_CheckDLLExists( 'sc2_cam.dll' ) then Exit ;

     { Load DLL camera interface library }
     LibraryHnd := LoadLibrary( PChar(Session.LibFileName));
     if LibraryHnd <= 0 then begin
        ShowMessage( 'PCO: Unable to open' + Session.LibFileName ) ;
        Exit ;
        end ;

     @PCO_OpenCamera := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_OpenCamera') ;
     @PCO_CloseCamera := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_CloseCamera') ;
     @PCO_GetFrameRate := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetFrameRate') ;
     @PCO_SetFrameRate := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetFrameRate') ;
     @PCO_SetDelayExposureTime := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetDelayExposureTime') ;
     @PCO_GetImageTiming := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetImageTiming') ;
     @PCO_GetRecordingState := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetRecordingState') ;
     @PCO_SetRecordingState := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetRecordingState') ;
     @PCO_AllocateBuffer := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_AllocateBuffer') ;
     @PCO_AddBufferEx := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_AddBufferEx') ;
     @PCO_SetImageParameters := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetImageParameters') ;
     @PCO_SetTransferParameter := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetTransferParameter') ;
     @PCO_WaitforBuffer := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_WaitforBuffer') ;
     @PCO_GetBuffer := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetBuffer') ;
     @PCO_FreeBuffer := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_FreeBuffer') ;
     @PCO_AddBuffer := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_AddBuffer') ;
     @PCO_GetBufferStatus := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetBufferStatus') ;
     @PCO_CancelImages := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_CancelImages') ;
     @PCO_RemoveBuffer := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_RemoveBuffer') ;
     @PCO_GetPendingBuffer := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetPendingBuffer') ;
     @PCO_ResetSettingsToDefault := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_ResetSettingsToDefault') ;
     @PCO_GetTemperature := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetTemperature') ;
     @PCO_GetInfoString := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetInfoString') ;
     @PCO_GetCameraName := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetCameraName') ;
     @PCO_GetCameraSetup := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetCameraSetup') ;
     @PCO_SetCameraSetup := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetCameraSetup') ;
     @PCO_RebootCamera := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_RebootCamera') ;
     @PCO_GetCameraDescription := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetCameraDescription') ;
     @PCO_GetSizes := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetSizes') ;
     @PCO_GetROI := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetROI') ;
     @PCO_SetROI := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetROI') ;
     @PCO_GetBinning := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetBinning') ;
     @PCO_SetBinning := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetBinning') ;
     @PCO_SetPixelRate := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetPixelRate') ;
     @PCO_GetConversionFactor := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetConversionFactor') ;
     @PCO_SetConversionFactor := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetConversionFactor') ;
     @PCO_GetADCOperation := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetADCOperation') ;
     @PCO_SetADCOperation := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetADCOperation') ;
     @PCO_GetCoolingSetpoints := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetCoolingSetpoints') ;
     @PCO_GetCoolingSetpointTemperature := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetCoolingSetpointTemperature') ;
     @PCO_SetCoolingSetpointTemperature := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetCoolingSetpointTemperature') ;
     @PCO_GetNoiseFilterMode := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetNoiseFilterMode') ;
     @PCO_SetNoiseFilterMode := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetNoiseFilterMode') ;
     @PCO_GetTriggerMode := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetTriggerMode') ;
     @PCO_SetTriggerMode := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_SetTriggerMode') ;
     @PCO_ForceTrigger := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_ForceTrigger') ;
     @PCO_GetCameraBusyStatus := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetCameraBusyStatus') ;
     @PCO_GetExpTrigSignalStatus := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_GetExpTrigSignalStatus') ;
     @PCO_ArmCamera := PCOAPI_GetDLLAddress(LibraryHnd,'PCO_ArmCamera') ;

     LibraryLoaded := True ;

     end ;


function PCOAPI_GetDLLAddress(
         Handle : THandle ;
         const ProcName : string ) : Pointer ;
// -----------------------------------------
// Get address of procedure within DLL
// -----------------------------------------
begin
    Result := GetProcAddress(Handle,PChar(ProcName)) ;
    if Result = Nil then ShowMessage('sc2_cam.dll: ' + ProcName + ' not found') ;
    end ;

function PCOAPI_CheckDLLExists( DLLName : String ) : Boolean ;
// -------------------------------------------
// Check that a DLL present in WinFluor folder
// -------------------------------------------
var
    Source,Destination : String ;
    WinDir : Array[0..255] of Char ;
    SysDrive : String ;
begin
     // Get system drive
     GetWindowsDirectory( WinDir, High(WinDir) ) ;
     SysDrive := ExtractFileDrive(String(WinDir)) ;
     Destination := ExtractFilePath(ParamStr(0)) + DLLName ;

     // Try to get file from win32 DLL folder of SDK
     if not FileExists(Destination) then begin
        Source := SysDrive + '\Program Files\Andor SDK3\win32\' + DLLName ;
        if FileExists(Source) then begin
           CopyFile( PChar(Source), PChar(Destination), False ) ;
           end ;
        end ;

     if FileExists(Destination) then Result := True
     else begin
        ShowMessage('Andor SDK3: ' + Destination + ' is missing!') ;
        Result := False ;
        end ;
     end ;


function PCOAPI_OpenCamera(
          var Session : TPCOAPISession ;   // Camera session record
          var FrameWidthMax : Integer ;      // Returns camera frame width
          var FrameHeightMax : Integer ;     // Returns camera height width
          var BinFactorMax : Integer ;       // Maximum bin factor
          var NumBytesPerPixel : Integer ;   // Returns bytes/pixel
          var PixelDepth : Integer ;         // Returns no. bits/pixel
          var PixelWidth : Single ;          // Returns pixel size (um)
          CameraInfo : TStringList         // Returns Camera details
          ) : LongBool ;
// ---------------------
// Open PCO camera
// ---------------------
var
    Err : Integer ;
    i :Integer ;
    CameraIndex : Integer ;
    wsValue : WideString ;
    iValue : Int64 ;
    dValue : Double ;
    bValue : LongBool ;
    s,sValue : string ;
    BadCode : Integer ;
    cBuf : Array[0..99] of ANSIChar ;
    RecordingState : Word ;
begin

     Result := False ;
     CameraInfo.Clear ;

     // Load DLL libray
     if not LibraryLoaded then PCOAPI_LoadLibrary(Session)  ;
     if not LibraryLoaded then begin
        CameraInfo.Add('PCO: Unable to load sc2_cam.dll') ;
        Exit ;
        end ;

     // Open camera
     PCOAPI_CheckError( 'PCO_OpenCamera',
                        PCO_OpenCamera( Session.CamHandle,0 )) ;

     // Get camera properties
      Session.PCO_Description.wSize := SizeOf( Session.PCO_Description) ;
     PCOAPI_CheckError( 'PCO_GetCameraDescription',
                        PCO_GetCameraDescription( Session.CamHandle,@Session.PCO_Description )) ;

     // Get image area
     FrameHeightMax := Session.PCO_Description.wMaxVertResStdDESC ;
     FrameWidthMax := Session.PCO_Description.wMaxHorzResStdDESC ;

     PCOAPI_CheckError( 'PCO_GetCameraName',
                        PCO_GetCameraName(Session.CamHandle,cBuf,High(CBuf)));
     Session.CameraName := ANSIString(cBuf) ;
     CameraInfo.Add('Camera: ' + Session.CameraName) ;

     // Pixel sizes ;
     if ContainsText(Session.CameraName,'edge') then PixelWidth := 6.5
     else if ContainsText(Session.CameraName,'panda') then PixelWidth := 6.5
     else if ContainsText(Session.CameraName,'pixelfly') then PixelWidth := 6.45
     else if ContainsText(Session.CameraName,'1600') then PixelWidth := 7.4
     else if ContainsText(Session.CameraName,'2000') then PixelWidth := 7.4
     else if ContainsText(Session.CameraName,'4000') then PixelWidth := 9.0
     else if ContainsText(Session.CameraName,'dicam') then PixelWidth := 6.5
     else PixelWidth := 6.5 ;

     CameraInfo.Add( format('CCD resolution: %d x %d (%.4g um)',[FrameWidthMax,FrameHeightMax,PixelWidth]));

     Session.ADCNum := 0 ;
     PixelDepth := Session.PCO_Description.wDynResDESC ;
     Session.NumBitsPerPixel := Session.PCO_Description.wDynResDESC ;
     NumBytesPerPixel := 2 ;

     // Get available readout rates
     s := 'Readout Rates: ' ;
     Session.NumReadoutSpeeds := 0 ;
     for i := 0 to High(Session.PCO_Description.dwPixelRateDESC) do
         if Session.PCO_Description.dwPixelRateDESC[i] <> 0 then
            begin
            Session.ReadoutSpeedList[Session.NumReadoutSpeeds] := Session.PCO_Description.dwPixelRateDESC[i] ;
            s := s + format(' %.1f MHz, ',[Session.ReadoutSpeedList[Session.NumReadoutSpeeds]*1E-6]);
            Inc(Session.NumReadoutSpeeds);
            end ;
     CameraInfo.Add( s ) ;

     // Get list of available binning factors
     s := 'Bin Factors: ' ;
     i := 1 ;
     Session.NumBinFactors := 0 ;
     while (i <= Session.PCO_Description.wMaxBinHorzDESC) do
        begin
        s := s + format('%d,',[i]) ;
        Session.BinFactorList[Session.NumBinFactors] := i ;
        Inc(Session.NumBinFactors) ;
        if Session.PCO_Description.wBinHorzSteppingDESC = BINNING_STEPPING_LINEAR then Inc(i)
                                                                                  else i := i*2 ;
        end;
     CameraInfo.Add( s ) ;

     // Get list of available gain factors
     s := 'Gain Factors: ' ;
     Session.NumGains := 0 ;
     for i := 0 to High(Session.PCO_Description.wConvFactDESC) do
         if Session.PCO_Description.wConvFactDESC[i] <> 0 then
            begin
            Session.GainList[Session.NumGains] := Session.PCO_Description.wConvFactDESC[i] ;
            s := s + format('%d e/bit, ',[Session.GainList[Session.NumGains]]);
            Inc(Session.NumGains);
            end ;
     CameraInfo.Add( s ) ;

     // Get list of available cooling set points

     if (Session.PCO_Description.sMinCoolSetDESC = 0) and
        (Session.PCO_Description.sMaxCoolSetDESC = 0) then
        begin
        s := 'Cooling: None';
        end
     else if (Session.PCO_Description.dwGeneralCapsDESC1 and GENERALCAPS1_COOLING_SETPOINTS) <> 0 then
        begin
        s := 'Cooling Set Points (C): ' ;
        for i := 0 to Session.PCO_Description.wNumCoolingSetpoints-1 do
            s := s + format('%d', [Session.PCO_Description.sCoolingSetpoints[i]]) ;
        end
     else
       begin
       s := format('Cooling: Range %d .. %d',
            [Session.PCO_Description.sMinCoolSetDESC,Session.PCO_Description.sMaxCoolSetDESC]);
       end;
     CameraInfo.Add( s ) ;


     // Stop camera if recording in progress
     PCOAPI_CheckError( 'PCO_GetRecordingState',
                        PCO_GetRecordingState(Session.CamHandle, RecordingState));
     if RecordingState <> 0  then
        begin
        PCOAPI_CheckError( 'PCO_SetRecordingState',
                            PCO_SetRecordingState(Session.CamHandle, 0));
        end;

     // Reset setting to default
     PCOAPI_CheckError( 'PCO_ResetSettingsToDefault',
                        PCO_ResetSettingsToDefault(Session.CamHandle));

     // Set buffer flags to unallocated
     for i := 0 to High(Session.pBuf) do Session.pBuf[i] := Nil ;

     Session.CameraOpen := True ;
     Session.CapturingImages := False ;
     Result := Session.CameraOpen ;

     end ;


function PCOAPI_PixelDepth( ADConverterList : TStringList ;
                               ADCNum : Integer ) : Integer ;

// ------------------------------------------------
// Determine integer pixel from ADConverter setting
// ------------------------------------------------
var
    BadCode : Integer ;
    s : string ;
begin
    if ADConverterList.Count > 0 then begin
       s := ADConverterList[ADCNum] ;
       Val( LeftStr(s,Pos('-',s)-1),Result, BadCode) ;
       if Result = 0 then Result := 16 ;
       end

    else Result := 16 ;
    end ;


procedure PCOAPI_SetTemperature(
          var Session : TPCOAPISession ; // Session record
          var TemperatureSetPoint : Single  // Required temperature
          ) ;
// -------------------------------
// Set camera temperature set point
// --------------------------------
var
    TSet,TDiff,MinTDiff : SmallInt ;
    i : Integer ;
begin

     if not Session.CameraOpen then Exit ;

     if (Session.PCO_Description.dwGeneralCapsDESC1 and GENERALCAPS1_COOLING_SETPOINTS) <> 0 then
        begin
        // Find nearest set point
        MinTDiff := High(TSet) ;
        for i := 0 to Session.PCO_Description.wNumCoolingSetpoints-1 do
            begin
            TSet := Session.PCO_Description.sCoolingSetpoints[i] ;
            TDiff := Abs(Round(TemperatureSetPoint)-TSet) ;
            if TDiff <= MinTDiff then begin
               Session.SetPointTemperature := TSet ;
               MinTDiff := TDiff ;
               end ;
            end ;
        end
     else
        begin
        // Limit to cooling temp range
        TSet := Min(Max(TSet,Session.PCO_Description.sMinCoolSetDESC),Session.PCO_Description.sMaxCoolSetDESC);
        end;

     // Set cooling set point
     PCOAPI_CheckError( 'PCO_SetCoolingSetPointTemperature',
                        PCO_SetCoolingSetPointTemperature( Session.CamHandle,
                                                           Session.SetPointTemperature )) ;

     TemperatureSetPoint := Session.SetPointTemperature ;

     end ;


procedure PCOAPI_SetCooling(
          var Session : TPCOAPISession ; // Session record
          CoolingOn : LongBool  // True = Cooling is on
          ) ;
// -------------------
// Turn cooling on/off
// -------------------
var
    wsValue : WideString ;
begin
     if not Session.CameraOpen then Exit ;


     end ;


procedure PCOAPI_SetFanMode(
          var Session : TPCOAPISession ; // Session record
          FanMode : Integer  // 0 = Off, 1=low, 2=high
          ) ;
// -------------------
// Set camera fan mode
// -------------------
begin
     if not Session.CameraOpen then Exit ;

     end ;


procedure PCOAPI_SetCameraMode(
          var Session : TPCOAPISession ; // Session record
          Mode : Integer ) ;
// --------------------
// Set camera CCD mode
// --------------------
begin
    if not Session.CameraOpen then Exit ;
    exit;
    Mode := Min(Max(Mode,Session.ModeList.Count-1),0) ;
    Session.CameraMode := Mode ;

    end ;


procedure PCOAPI_SetCameraADC(
          var Session : TPCOAPISession ; // Session record
          ADCNum : Integer ;
          var PixelDepth : Integer ;
          var GreyLevelMin : Integer ;
          var GreyLevelMax : Integer ) ;
// ------------------------
// Set camera A/D converter
// ------------------------
var
    i : Integer ;
    Pixelformat : WideString ;
begin

   if not Session.CameraOpen then Exit ;

    ADCNum := Max(Min(ADCNum,Session.ADConverterList.Count-1),0) ;
    Session.ADCNum := ADCNum ;
    PixelDepth := 16 ;
    GreyLevelMin := 0 ;
    GreyLevelMax := 32767 ;
    if Session.ADConverterList.Count <= 0 then Exit ;

    // Calculate grey levels from pixel depth

    GreyLevelMax := 1 ;
    for i := 1 to PixelDepth do GreyLevelMax := GreyLevelMax*2 ;
    GreyLevelMax := GreyLevelMax - 1 ;
    GreyLevelMin := 0 ;

    end ;


procedure PCOAPI_CloseCamera(
          var Session : TPCOAPISession // Session record
          ) ;
// ----------------
// Shut down camera
// ----------------
begin

    if not Session.CameraOpen then Exit ;

    // Stop capture if in progress
    if Session.CapturingImages then PCOAPI_StopCapture( Session ) ;

    // Close camera
    PCOAPI_CheckError( 'PCO_CloseCamera', PCO_CloseCamera( Session.CamHandle )) ;

    // Free DLL library
    if LibraryLoaded then FreeLibrary(libraryHnd) ;
    LibraryLoaded := False ;

    Session.GetImageInUse := False ;
    Session.CameraOpen := False ;

    // Free string lists
    Session.ReadoutRateList.Free ;
    Session.ADConverterList.Free ;
    Session.ModeList.Free ;
    Session.TemperatureSettingsList.Free ;

    end ;


procedure PCOAPI_GetCameraGainList(
          var Session : TPCOAPISession ; // Session record
          CameraGainList : TStringList
          ) ;
// --------------------------------------------
// Get list of available camera amplifier gains
// --------------------------------------------
var
    i : Integer ;
begin

    CameraGainList.Clear ;
    if Session.NumGains = 0 then CameraGainList.Add('n/a');
    for i  := 0 to Session.NumGains-1 do
        CameraGainList.Add(format('%d e/bit',[Session.GainList[i]]));

    end ;

procedure PCOAPI_GetCameraReadoutSpeedList(
          var Session : TPCOAPISession ; // Session record
          CameraReadoutSpeedList : TStringList
          ) ;
// -------------------------------
// Get camera pixel readout speeds
// -------------------------------
var
    i : Integer ;
begin

     // Get list of available rates
     CameraReadoutSpeedList.Clear ;
    if Session.NumReadoutSpeeds = 0 then CameraReadoutSpeedList.Add('n/a');
    for i  := 0 to Session.NumReadoutSpeeds-1 do
        CameraReadoutSpeedList.Add(format('%.0f MHz',[Session.ReadoutSpeedList[i]*1E-6]));

     if not Session.CameraOpen then Exit ;

     end ;


procedure PCOAPI_GetCameraModeList(
          var Session : TPCOAPISession ; // Session record
          List : TStringList
          ) ;
// -----------------------------------------
// Return list of available camera CCD mode
// -----------------------------------------
begin

     List.Clear ;
     List.Add('n/a') ;

    end ;


procedure PCOAPI_GetCameraADCList(
          var Session : TPCOAPISession ; // Session record
          List : TStringList
          ) ;
// ---------------------------------
// Get list of A/D converter options
// ----------------------------------
begin

     List.Clear ;
     List.Add('n/a') ;

    end ;


procedure PCOAPI_CheckROIBoundaries(
          var Session : TPCOAPISession ;        // Camera session record
          var FrameLeft : Integer ;            // Left pixel in CCD readout area
          var FrameRight : Integer ;           // Right pixel in CCD eadout area
          var FrameTop : Integer ;             // Top of CCD readout area
          var FrameBottom : Integer ;          // Bottom of CCD readout area
          var BinFactor : Integer ;           // Pixel binning factor (In)
          FrameWidthMax : Integer ;
          FrameHeightMax : Integer ;
          var FrameWidth : Integer ;
          var FrameHeight : Integer
          ) ;
// -------------------------------------------------------------
// Check that a valid set of CCD region boundaries have been set
// -------------------------------------------------------------
const
    MaxTries = 10 ;
var
    i64Value : Int64 ;
    i,Diff,MinDiff,iNearest,NearestBinFactor,iValue : Integer ;
    AOIWidthSteps : Integer ;
begin
    if not Session.CameraOpen then Exit ;

    // Set to nearest valid bin factor
    iNearest := 0 ;
    NearestBinFactor := 1 ;
    MinDiff := High(MinDiff) ;
    for i := 0 to Session.NumBinFactors-1 do begin
        Diff := Abs(Session.BinFactorList[i] - BinFactor) ;
        if  Diff <= MinDiff then begin
           NearestBinFactor :=Session.BinFactorList[i] ;
           MinDiff := Diff ;
           end ;
        end ;
    BinFactor := NearestBinFactor ;

    FrameWidth := (FrameRight - FrameLeft + 1) div BinFactor ;
    FrameHeight := (FrameBottom - FrameTop + 1 ) div BinFactor ;
    FrameLeft := FrameLeft div BinFactor ;
    FrameTop := FrameTop div BinFactor ;

    // Ensure ROI limits are valid multiples of step sizes

    FrameLeft := (FrameLeft div Session.PCO_Description.wRoiHorStepsDESC)*Session.PCO_Description.wRoiHorStepsDESC ;
    FrameTop := (FrameTop div Session.PCO_Description.wRoiVertStepsDESC)*Session.PCO_Description.wRoiVertStepsDESC ;
    FrameWidth := (FrameWidth div Session.PCO_Description.wRoiHorStepsDESC)*Session.PCO_Description.wRoiHorStepsDESC ;
    FrameHeight := (FrameHeight div Session.PCO_Description.wRoiVertStepsDESC)*Session.PCO_Description.wRoiVertStepsDESC ;

    // Set width

     // Set binning factors
     PCOAPI_CheckError( 'PCO_SetBinning',
                         PCO_SetBinning( Session.CamHandle,
                                         BinFactor,BinFactor)) ;

    PCOAPI_CheckError( 'PCO_SetROI',
                       PCO_SetROI( Session.CamHandle,
                                   FrameLeft + 1,
                                   FrameTop + 1,
                                   FrameLeft + FrameWidth,
                                   FrameTop + FrameHeight)) ;

    Session.AOIWidth := FrameWidth  ;
    Session.AOIHeight := FrameHeight ;

    FrameLeft := FrameLeft*BinFactor ;
    FrameTop := FrameTop*BinFactor ;
    FrameRight := FrameLeft + FrameWidth*BinFactor - 1 ;
    FrameBottom := FrameTop + FrameHeight*BinFactor - 1 ;

   end ;


function PCOAPI_StartCapture(
         var Session : TPCOAPISession ;   // Camera session record
         var InterFrameTimeInterval : Double ;      // Frame exposure time
         AdditionalReadoutTime : Double ; // Additional readout time (s)
         AmpGain : Integer ;              // Camera amplifier gain index
         ExternalTrigger : Integer ;      // Trigger mode
         FrameLeft : Integer ;            // Left pixel in CCD readout area
         FrameTop : Integer ;             // Top pixel in CCD eadout area
         FrameWidth : Integer ;           // Width of CCD readout area
         FrameHeight : Integer ;          // Width of CCD readout area
         BinFactor : Integer ;             // Binning factor (1,2,4,8,16)
         PFrameBuffer : Pointer ;         // Pointer to start of ring buffer
         NumFramesInBuffer : Integer ;    // No. of frames in ring buffer
         NumBytesPerFrame : Integer ;      // No. of bytes/frame
         var ReadoutTime : Double        // Return frame readout time
         ) : LongBool ;
// -------------------
// Start frame capture
// -------------------
const
     TimerTickInterval = 20 ; // Timer tick resolution (ms)

var
    i,iB : Integer ;
    MaxWidth,MaxHeight : Word ;
    ExposureTime_ns,ExposureTime_us : DWord ;
    FrameRateStatus : Word ;
    CCDTemp,CameraTemp,PowTemp : SmallInt ;
begin

     Result := False ;
     if not Session.CameraOpen then Exit ;

     Session.TimeStart := TimeGetTime*0.001 ;

     // Read sensor temperature
     PCOAPI_CheckError( 'PCO_GetTemperature',
                         PCO_GetTemperature( Session.CamHandle,
                                             CCDTemp,CameraTemp,PowTemp));
     if Word(CCDTemp) = $8000 then Session.Temperature := CameraTemp*0.1
                              else Session.Temperature := CCDTemp*0.1 ;

     // Set pixel readout rate
     PCOAPI_CheckError( 'PCO_SetPixelRate',
                         PCO_SetPixelRate( Session.CamHandle,
                                           Session.ReadoutSpeedList[Session.ReadoutSpeed])) ;
     // Set binning factors
     PCOAPI_CheckError( 'PCO_SetBinning',
                         PCO_SetBinning( Session.CamHandle,
                                         BinFactor,BinFactor)) ;
     // Set image area
     PCOAPI_CheckError( 'PCO_SetROI',
                         PCO_SetROI( Session.CamHandle,
                                    (FrameLeft div BinFactor)+1,
                                    (FrameTop div BinFactor)+1,
                                    (FrameLeft div BinFactor) + (FrameWidth div BinFactor),
                                    (FrameTop div BinFactor) + FrameHeight div BinFactor)) ;

     // Set trigger mode
     if ExternalTrigger = CamFreeRun then
        begin
        // Free run
        PCOAPI_CheckError('PCO_SetTriggerMode',
                           PCO_SetTriggerMode(Session.CamHandle,TRIGGER_MODE_AUTOTRIGGER));
        ExposureTime_us := Round( 1E6*InterFrameTimeInterval );
        PCOAPI_CheckError('PCO_SetDelayExposureTime',
                          PCO_SetDelayExposureTime( Session.CamHandle,
                          0,ExposureTime_us,1,1));
        end
     else if ExternalTrigger = CamExtTrigger then
          begin
        // External frame capture trigger mode
        PCOAPI_CheckError('PCO_SetTriggerMode',
                           PCO_SetTriggerMode(Session.CamHandle,TRIGGER_MODE_EXTERNALTRIGGER));
        ExposureTime_us := Round( Max(1E6*(InterFrameTimeInterval - ReadOutTime - AdditionalReadoutTime ),750.0));
        PCOAPI_CheckError('PCO_SetDelayExposureTime',
                          PCO_SetDelayExposureTime( Session.CamHandle,
                          0,ExposureTime_us,1,1));
        end
     else
        begin
        // Bulb frame capture trigger mode (trigger pulse defined exposure
        PCOAPI_CheckError('PCO_SetTriggerMode',
                           PCO_SetTriggerMode(Session.CamHandle,TRIGGER_MODE_EXTERNALEXPOSURECONTROL));
        ExposureTime_us := Round( 1E6*(InterFrameTimeInterval  - ReadOutTime - AdditionalReadoutTime - 2.0E-3));
        ExposureTime_us := Max(ExposureTime_us,1500) ;
        PCOAPI_CheckError('PCO_SetDelayExposureTime',
                          PCO_SetDelayExposureTime( Session.CamHandle,
                          0,ExposureTime_us,1,1));
        end ;


      PCOAPI_CheckError('PCO_ArmCamera',
                          PCO_ArmCamera(Session.CamHandle));

      PCOAPI_CheckError('PCO_SetImageParameters',
                        PCO_SetImageParameters( Session.CamHandle,
                        Session.AOIWidth,Session.AOIHeight,
                        IMAGEPARAMETERS_READ_WHILE_RECORDING,Nil,0));

      PCOAPI_CheckError('PCO_ArmCamera',
                          PCO_ArmCamera(Session.CamHandle));

     // Get no. bytes in image
     PCOAPI_CheckError('PCO_GetSizes',
                        PCO_GetSizes( Session.CamHandle,
                                      Session.AOIWidth,Session.AOIHeight,
                                      MaxWidth,MaxHeight));

     Session.AOINumPixels := Session.AOIHeight*Session.AOIWidth ;
     Session.NumBytesPerFrameBuffer := Session.AOINumPixels*2 ;
     Session.ImageEnd := Session.AOINumPixels - 1 ;
     Session.NumFramesInBuffer := NumFramesInBuffer ;

     // Allocate internal camera buffers
     for iB := 0 to PCOAPINumBufs-1 do
         begin
         Session.BufNum[iB] := -1 ;
         Session.pBuf[iB] := Nil ;
         Session.BufEVent[iB] := 0 ;
         PCOAPI_CheckError('PCO_AllocateBuffer',
                            PCO_AllocateBuffer( Session.CamHandle,
                                                @Session.BufNum[iB],
                                                Session.NumBytesPerFrameBuffer,
                                                @Session.pBuf[iB],
                                                @Session.BufEvent[iB]));

         Session.pBuf[iB]^[Session.ImageEnd] :=  EmptyFlag ;
         Session.pBuf[iB]^[Session.ImageEnd-1] := 0 ;
         end ;

     Session.PFrameBuffer := PFrameBuffer ;

     // Start capture
     PCOAPI_CheckError('PCO_SetRecordingState',
                        PCO_SetRecordingState(Session.CamHandle, 1));

     // Add buffers to queue
     for iB := 0 to PCOAPINumBufs-1 do
         begin
         PCOAPI_CheckError('PCO_AddBufferEx',
                           PCO_AddBufferEx(Session.CamHandle,0,0,
                           Session.BufNum[iB],
                           Session.AOIWidth,
                           Session.AOIHeight,
                           Session.NumBitsPerPixel)) ;
         end;

     Session.FramePointer := 0 ;
     Session.BufPointer := 0 ;
     Session.NumFramesAcquired := 0 ;
     Session.NumFramesInBuffer := NumFramesInBuffer ;
     Session.CapturingImages := True ;
     Session.GetImageInUse := False ;
     ATHandle := Session.CamHandle ;
     Result := True ;
     NumBuffersAcquired := 0 ;
     MaxFramesAcquired := 0 ;
     BufferErr := 0 ;
     SessionLoc := Session ;
     TBufferRead := 0 ;

     // Start image queue transfer thread
     WaitBufferThread := TWaitBufferThread.Create(false);

     end;


procedure PCOAPI_UpdateCircularBufferSize(
          var Session : TPCOAPISession  ; // Camera session record
          FrameLeft : Integer ;
          FrameRight : Integer ;
          FrameTop : Integer ;
          FrameBottom : Integer ;
          BinFactor : Integer
          ) ;
// -----------------------------------------------------------------
// Update size of circular camera image buffer if image size changed
// -----------------------------------------------------------------
begin
     // Get number of images within camera circular image buffer
     // (Only of frame size has changed, to save time)
     if (Session.FrameLeft <> FrameLeft) or
        (Session.FrameTop <> FrameTop) or
        (Session.FrameRight <> FrameRight) or
        (Session.FrameBottom <> FrameBottom) or
        (Session.BinFactor <> BinFactor) then begin

        Session.FrameTop := FrameTop ;
        Session.FrameLeft := FrameLeft ;
        Session.FrameBottom := FrameBottom ;
        Session.FrameRight := FrameRight ;
        Session.BinFactor := BinFactor ;

        end ;
     end ;


procedure PCOAPI_Wait( Delay : Single ) ;
var
  T : Integer ;
  TExit : Integer ;
begin
    T := TimeGetTime ;
    TExit := T + Round(Delay*1E3) ;
    while T < TExit do begin
       T := TimeGetTime ;
       end ;
    end ;


function PCOAPI_CheckFrameInterval(
          var Session : TPCOAPISession ;   // Camera session record
          FrameLeft : Integer ;   // Left edge of capture region (In)
          FrameRight : Integer ;  // Right edge of capture region( In)
          FrameTop : Integer ;    // Top edge of capture region( In)
          FrameBottom : Integer ; // Bottom edge of capture region (In)
          BinFactor : Integer ;   // Pixel binning factor (In)
          FrameWidthMax : Integer ;   // Max frame width (in)
          FrameHeightMax : Integer ;  // Max. frame height (in)
          Var FrameInterval : Double ; // Frame interval in/out
          Var ReadoutTime : Double ;   // Readout time out
          TriggerMode : Integer        // Trigger mode in
          ) : LongBool ;
// ----------------------------------------
// Check that inter-frame interval is valid
// ----------------------------------------
var
    TRead : Double ;
    TempWidth,TempHeight : Integer ;
    ImageTiming : TPCO_ImageTiming ;
    ExposureTime_us : DWord ;
begin

     Result := False ;
     if not Session.CameraOpen then Exit ;

     // Set ROI boundaries (because it affects readout rate)
     PCOAPI_CheckROIBoundaries( Session,
                                   FrameLeft,
                                   FrameRight,
                                   FrameTop,
                                   FrameBottom,
                                   BinFactor,
                                   FrameWidthMax,
                                   FrameHeightMax,
                                   TempWidth,
                                   TempHeight
                                   ) ;

     // Set exposure time to min. value to determine readout time from GetImageTiming call.
     PCOAPI_CheckError('PCO_SetTriggerMode',
                        PCO_SetTriggerMode(Session.CamHandle,TRIGGER_MODE_AUTOTRIGGER));
     ExposureTime_us := 1000 ;
     PCOAPI_CheckError('PCO_SetDelayExposureTime',
                       PCO_SetDelayExposureTime( Session.CamHandle,
                       0,ExposureTime_us,1,1));
     // Arm camera to get camera to determine settings
     PCOAPI_CheckError('PCO_ArmCamera',
                       PCO_ArmCamera(Session.CamHandle));
     // Get image timing details
     ImageTiming.wSize := SizeOf(ImageTiming) ;
     PCOAPI_CheckError('PCO_GetImageTiming',
                       PCO_GetImageTiming( Session.CamHandle,
                                           ImageTiming ) );

     ReadoutTime := (ImageTiming.FrameTime_ns)*1E-9  ;

     // Limit frame interval to 2x readout time in external trigger mode
//     if TriggerMode = CamFreeRun then FrameInterval := Max(FrameInterval,ReadoutTime)
//                                 else FrameInterval := Max(FrameInterval,2.0*ReadoutTime + 1E-3) ;
     FrameInterval := Max(Max(FrameInterval,ReadoutTime),1E-3) ;
     Result := True ;

     end ;


procedure PCOAPI_GetImage(
          var Session : TPCOAPISession  // Camera session record
          ) ;
// ------------------------------------------------------
// Transfer images from Andor driverbuffer to main buffer
// ------------------------------------------------------
var
    i,iFrom,iTo,NumFramesAcquired,MaxFramesPerCall,t0 : Integer ;
    pBuf : PWordArray ;
    StatusDLL, StatusDrv : DWord  ;
    Done : Boolean ;
begin
    Session.FramePointer := SessionLoc.FramePointer ;
    Session.NumFramesAcquired := SessionLoc.NumFramesAcquired ;
    outputdebugstring(pchar(format('Max frames acq. %d %d',[MaxFramesAcquired,tBufferRead])));
    exit ;
    if not Session.CameraOpen then Exit ;
    if Session.GetImageInUse then Exit ;
    Session.GetImageInUse := True ;

    // Transfer images from camera buffer to application frame buffer

    t0 := timegettime ;

    Done := False ;
    NumFramesAcquired := 0 ;
    MaxFramesPerCall := PCOAPINumBufs div 2 ;
    repeat

      // Check for completion of buffer transfer
      PCOAPI_CheckError('PCO_GetBufferStatus',
                       PCO_GetBufferStatus( Session.CamHandle,
                                            Session.BufNum[Session.BufPointer],
                                            StatusDLL, StatusDrv )) ;

      // Copy camera buffer to output buffer
      if (StatusDLL and $8000) <> 0 then begin
         pBuf := Session.pBuf[Session.BufPointer] ;
         iTo := Session.FramePointer*Session.AOINumPixels ;
         for i := 0 to Session.AOINumPixels-1 do
             begin
             PWordArray(Session.pFrameBuffer)^[iTo] := pBuf^[i] ;
             Inc(iTo) ;
             end ;

         // Add buffer back to queue
         PCOAPI_CheckError('PCO_AddBufferEx',
                           PCO_AddBufferEx(Session.CamHandle,0,0,
                           Session.BufNum[Session.BufPointer],
                           Session.AOIWidth,
                           Session.AOIHeight,
                           Session.NumBitsPerPixel)) ;

         // Increment frame (output) buffer pointer
         Inc(Session.FramePointer) ;
         if Session.FramePointer >= Session.NumFramesInBuffer then Session.FramePointer := 0 ;
         // Increment camera buffer pointer
         Inc(Session.BufPointer) ;
         if Session.BufPointer >= PCOAPINumBufs then Session.BufPointer := 0 ;

         Inc(Session.NumFramesAcquired) ;
         Inc(NumFramesAcquired) ;
         if NumFramesAcquired >= MaxFramesPerCall then Done := True ;
         end
      else Done := True ;
      until Done ;

   outputdebugstring(pchar(format('%d %d',[timegettime-t0,NumFramesAcquired])));
    NumBuffersAcquired := 0 ;
    Session.GetImageInUse := False ;

    end ;


procedure PCOAPI_StopCapture(
          var Session : TPCOAPISession   // Camera session record
          ) ;
// ------------------
// Stop frame capture
// ------------------
var
    i : Integer ;
begin

     if not Session.CameraOpen then Exit ;
     if not Session.CapturingImages then Exit ;

     // Stop capture
     PCOAPI_CheckError('PCO_SetRecordingState',
                        PCO_SetRecordingState(Session.CamHandle, 0));

     WaitBufferThread.Destroy ;

     // Cancel images from buffer queue
     PCOAPI_CheckError('PCO_CancelImages',
                       PCO_CancelImages( Session.CamHandle )) ;

     // Free buffer memory
     for i := 0 to PCOAPINumBufs-1 do
         PCOAPI_CheckError('PCO_FreeBuffer',
                           PCO_FreeBuffer( Session.CamHandle, Session.BufNum[i] )) ;

     Session.CapturingImages := False ;



     end;


procedure PCOAPI_CheckError(
          FuncName : String ;   // Name of function called
          ErrNum : Integer      // Error # returned by function
          ) ;
// ------------
// Report error
// ------------
var
    ErrText : string ;
begin
    if ErrNum = 0 then Exit ;

    case ErrNum of
        PCO_ERROR_WRONGVALUE                         : ErrText := 'Function-call with wrong parameter' ;
        PCO_ERROR_INVALIDHANDLE                      : ErrText := 'Handle is invalid';
        PCO_ERROR_NOMEMORY                           : ErrText := 'No memory available';
        PCO_ERROR_NOFILE                             : ErrText := 'A file handle could not be opened.';
        PCO_ERROR_TIMEOUT                            : ErrText := 'Timeout in function';
        PCO_ERROR_BUFFERSIZE                         : ErrText := 'A buffer is to small';
        PCO_ERROR_NOTINIT                            : ErrText := 'The called module is not initialized';
        PCO_ERROR_DISKFULL                           : ErrText := 'Disk full.';

        PCO_ERROR_VALIDATION                         : ErrText := 'Validation after programming camera failed';
        PCO_ERROR_LIBRARYVERSION                     : ErrText := 'wrong library version';
        PCO_ERROR_CAMERAVERSION                      : ErrText := 'wrong camera version';
        PCO_ERROR_NOTAVAILABLE                       : ErrText := 'Option is not available';

        PCO_ERROR_DRIVER_NOTINIT                     : ErrText := 'Initialization failed; no camera connected';
        PCO_ERROR_DRIVER_WRONGOS                     : ErrText := 'Wrong driver for this OS';
        PCO_ERROR_DRIVER_NODRIVER                    : ErrText := ' Open driver or driver class failed';
        PCO_ERROR_DRIVER_IOFAILURE                   : ErrText := ' I/O operation failed';
        PCO_ERROR_DRIVER_CHECKSUMERROR               : ErrText := 'Error in telegram checksum';
        PCO_ERROR_DRIVER_INVMODE                     : ErrText :='Invalid Camera mode';
        PCO_ERROR_DRIVER_DEVICEBUSY                  : ErrText := 'device is hold by an other process';
        PCO_ERROR_DRIVER_DATAERROR                   : ErrText := 'Error in reading or writing data to board';
        PCO_ERROR_DRIVER_NOFUNCTION                  : ErrText := 'No function specified';
        PCO_ERROR_DRIVER_KERNELMEMALLOCFAILED        : ErrText := 'Kernel Memory allocation in driver failed';

        PCO_ERROR_DRIVER_BUFFER_CANCELLED            : ErrText := 'buffer was cancelled';
        PCO_ERROR_DRIVER_INBUFFER_SIZE               : ErrText := 'iobuffer in too small for DeviceIO call';
        PCO_ERROR_DRIVER_OUTBUFFER_SIZE              : ErrText := 'iobuffer out too small for DeviceIO call';
        PCO_ERROR_DRIVER_FUNCTION_NOT_SUPPORTED      : ErrText := 'this DeviceIO is not supported';
        PCO_ERROR_DRIVER_BUFFER_SYSTEMOFF            : ErrText := 'buffer returned because system sleep';
        PCO_ERROR_DRIVER_DEVICEOFF                   : ErrText := 'device is disconnected';
        PCO_ERROR_DRIVER_RESOURCE                    : ErrText := 'required system resource not avaiable';
        PCO_ERROR_DRIVER_BUSRESET                    : ErrText := 'busreset occured during system call';
        PCO_ERROR_DRIVER_BUFFER_LOSTIMAGE            : ErrText := 'lost image status from grabber';


        PCO_ERROR_DRIVER_SYSERR                      : ErrText := 'a call to a windows-function fails';
        PCO_ERROR_DRIVER_REGERR                      : ErrText := 'error in reading/writing to registry';
        PCO_ERROR_DRIVER_WRONGVERS                   : ErrText := 'need newer called vxd or dll';
        PCO_ERROR_DRIVER_FILE_READ_ERR               : ErrText := 'error while reading from file';
        PCO_ERROR_DRIVER_FILE_WRITE_ERR              : ErrText := 'error while writing to file';

        PCO_ERROR_DRIVER_LUT_MISMATCH                : ErrText := 'camera and dll lut do not match';
        PCO_ERROR_DRIVER_FORMAT_NOT_SUPPORTED        : ErrText := 'grabber does not support the transfer format';
        PCO_ERROR_DRIVER_BUFFER_DMASIZE              : ErrText := 'dmaerror not enough data transferred';

        PCO_ERROR_DRIVER_WRONG_ATMEL_FOUND           : ErrText := 'version information verify failed wrong typ id';
        PCO_ERROR_DRIVER_WRONG_ATMEL_SIZE            : ErrText := 'version information verify failed wrong size';
        PCO_ERROR_DRIVER_WRONG_ATMEL_DEVICE          : ErrText := 'version information verify failed wrong device id';
        PCO_ERROR_DRIVER_WRONG_BOARD                 : ErrText := 'board firmware not supported from this driver';
        PCO_ERROR_DRIVER_READ_FLASH_FAILED           : ErrText := 'board firmware verify failed';
        PCO_ERROR_DRIVER_HEAD_VERIFY_FAILED          : ErrText := 'camera head is not recognized correctly';
        PCO_ERROR_DRIVER_HEAD_BOARD_MISMATCH         : ErrText := 'firmware does not support connected camera head';

        PCO_ERROR_DRIVER_HEAD_LOST                   : ErrText := 'camera head is not connected';
        PCO_ERROR_DRIVER_HEAD_POWER_DOWN             : ErrText := 'camera head power down';
        PCO_ERROR_DRIVER_CAMERA_BUSY                 : ErrText := 'camera busy';

        PCO_ERROR_DRIVER_BUFFERS_PENDING             : ErrText := 'PCO_ERROR_DRIVER_BUFFERS_PENDING';

        PCO_ERROR_SDKDLL_NESTEDBUFFERSIZE            : ErrText := 'The wSize of an embedded buffer is to small.';
        PCO_ERROR_SDKDLL_BUFFERSIZE                  : ErrText := 'The wSize of a buffer is to small.';
        PCO_ERROR_SDKDLL_DIALOGNOTAVAILABLE          : ErrText := 'A dialog is not available';
        PCO_ERROR_SDKDLL_NOTAVAILABLE                : ErrText := 'Option is not available';
        PCO_ERROR_SDKDLL_SYSERR                      : ErrText := 'a call to a windows-function fails';
        PCO_ERROR_SDKDLL_BADMEMORY                   : ErrText := 'Memory area is invalid';

        PCO_ERROR_SDKDLL_BUFCNTEXHAUSTED             : ErrText := 'Number of available buffers is exhausted';

        PCO_ERROR_SDKDLL_ALREADYOPENED               : ErrText := 'Dialog is already open';
        PCO_ERROR_SDKDLL_ERRORDESTROYWND             : ErrText := 'Error while destroying dialog.';
        PCO_ERROR_SDKDLL_BUFFERNOTVALID              : ErrText := 'A requested buffer is not available.';
        PCO_ERROR_SDKDLL_WRONGBUFFERNR               : ErrText := 'Buffer nr is out of range.';
        PCO_ERROR_SDKDLL_DLLNOTFOUND                 : ErrText := 'A DLL could not be found';
        PCO_ERROR_SDKDLL_BUFALREADYASSIGNED          : ErrText := 'Buffer already assigned to another buffernr.';
        PCO_ERROR_SDKDLL_EVENTALREADYASSIGNED        : ErrText := 'Event already assigned to another buffernr.';
        PCO_ERROR_SDKDLL_RECORDINGMUSTBEON           : ErrText := 'Recording must be activated';
        PCO_ERROR_SDKDLL_DLLNOTFOUND_DIVZERO         : ErrText := 'A DLL could not be found, due to div by zero';

        PCO_ERROR_SDKDLL_BUFFERALREADYQUEUED         : ErrText := 'buffer is already queued';
        PCO_ERROR_SDKDLL_BUFFERNOTQUEUED             : ErrText := 'buffer is not queued';

        PCO_WARNING_SDKDLL_BUFFER_STILL_ALLOKATED    : ErrText := 'Buffers are still allocated';

        PCO_WARNING_SDKDLL_NO_IMAGE_BOARD            : ErrText := 'No Images are in the board buffer';
        PCO_WARNING_SDKDLL_COC_VALCHANGE             : ErrText := 'value change when testing COC';
        PCO_WARNING_SDKDLL_COC_STR_SHORT             : ErrText := 'string buffer to short for replacement';

        PCO_ERROR_SDKDLL_RECORDER_RECORD_MUST_BE_OFF         : ErrText := 'Record must be stopped';
        PCO_ERROR_SDKDLL_RECORDER_ACQUISITION_MUST_BE_OFF    : ErrText := 'Function call not possible while running';
        PCO_ERROR_SDKDLL_RECORDER_SETTINGS_CHANGED           : ErrText := 'Some camera settings have been changed outside of the recorder';
        PCO_ERROR_SDKDLL_RECORDER_NO_IMAGES_AVAILABLE        : ErrText := 'No images are avaialable for readout';

        PCO_WARNING_SDKDLL_RECORDER_FILES_EXIST              : ErrText := 'Files already exist';

        PCO_ERROR_APPLICATION_PICTURETIMEOUT         : ErrText := 'Error while waiting for a picture';
        PCO_ERROR_APPLICATION_SAVEFILE               : ErrText := 'Error while saving file';
        PCO_ERROR_APPLICATION_FUNCTIONNOTFOUND       : ErrText := 'A function inside a DLL could not be found';
        PCO_ERROR_APPLICATION_DLLNOTFOUND            : ErrText := 'A DLL could not be found';
        PCO_ERROR_APPLICATION_WRONGBOARDNR           : ErrText := 'The board number is out of range.';
        PCO_ERROR_APPLICATION_FUNCTIONNOTSUPPORTED   : ErrText := 'The decive does not support this function.';
        PCO_ERROR_APPLICATION_WRONGRES               : ErrText := 'Started Math with different resolution than reference.';
        PCO_ERROR_APPLICATION_DISKFULL               : ErrText := 'Disk full.';
        PCO_ERROR_APPLICATION_SET_VALUES             : ErrText := 'Error setting values to camera';
        else ErrText := format('Unknown error (%x)',[ErrNum]) ;
        end ;

    ShowMessage(FuncName + ErrText);

    end ;



end.
