unit ThorLabsUnit;
// ====================
// Thorlabs DCx Cameras
// ====================
interface

uses WinTypes,sysutils, classes, dialogs, mmsystem, messages, controls, math, strutils ;

const
   ThorLabsMaxFrames = 10000 ;
   IS_COLORMODE_INVALID = 0 ;
   IS_COLORMODE_MONOCHROME = 1 ;
   IS_COLORMODE_BAYER =   2 ;
   IS_COLORMODE_CBYCRY =  4 ;

   IMGFRMT_CMD_GET_NUM_ENTRIES  = 1 ;  //* Get the number of supported image formats.
                                       //                  pParam hast to be a Pointer to IS_U32. If  -1 is reported, the device
                                       //                  supports continuous AOI settings (maybe with fixed increments)
   IMGFRMT_CMD_GET_LIST                     = 2;  //* Get a array of IMAGE_FORMAT_ELEMENTs.
   IMGFRMT_CMD_SET_FORMAT                   = 3;  //* Select a image format
   IMGFRMT_CMD_GET_ARBITRARY_AOI_SUPPORTED  = 4;  //* Does the device supports the setting of an arbitrary AOI.
   IMGFRMT_CMD_GET_FORMAT_INFO              = 5;  //* Get

// ----------------------------------------------------------------------------
//  Sensor Types
// ----------------------------------------------------------------------------
   IS_SENSOR_INVALID    = $0000 ;

//* CMOS sensors */
   IS_SENSOR_C0640R13M  = $0001;  // cmos, 064 = $0480, rolling, 1/3", mono,
   IS_SENSOR_C0640R13C  = $0002;  // cmos, 064 = $0480, rolling, 1/3", color,
   IS_SENSOR_C1280R23M  = $0003;  // cmos, 128 = $1024, rolling, 1/1.8", mono,
   IS_SENSOR_C1280R23C  = $0004;  // cmos, 128 = $1024, rolling, 1/1.8", color,

   IS_SENSOR_C1600R12C  = $0008;  // cmos, 160 = $1200, rolling, 1/2", color,

   IS_SENSOR_C2048R12C  = $000A;  // cmos, 2048x1536, rolling, 1/2", color,
   IS_SENSOR_C2592R12M  = $000B;  // cmos, 2592x1944, rolling, 1/2", mono
   IS_SENSOR_C2592R12C  = $000C;  // cmos, 2592x1944, rolling, 1/2", color

   IS_SENSOR_C0640G12M  = $0010;  // cmos, 064 = $0480, global,  1/2", mono,
   IS_SENSOR_C0640G12C  = $0011;  // cmos, 064 = $0480, global,  1/2", color,
   IS_SENSOR_C0752G13M  = $0012;  // cmos, 0752x0480, global,  1/3", mono,
   IS_SENSOR_C0752G13C  = $0013;  // cmos, 0752x0480, global,  1/3", color,

   IS_SENSOR_C1282R13C  = $0015;  // cmos, 128 = $1024, rolling, 1/3", color,

   IS_SENSOR_C1601R13C  = $0017;  // cmos, 160 = $1200, rolling, 1/3.2", color,

   IS_SENSOR_C0753G13M  = $0018;  // cmos, 0752x0480, global,  1/3", mono,
   IS_SENSOR_C0753G13C  = $0019;  // cmos, 0752x0480, global,  1/3", color,

   IS_SENSOR_C0754G13M  = $0022;  // cmos, 0752x0480, global,  1/3", mono, single board (LE)
   IS_SENSOR_C0754G13C  = $0023;  // cmos, 0752x0480, global,  1/3", color, single board (LE)

   IS_SENSOR_C1284R13C  = $0025;  // cmos, 128 = $1024, rolling, 1/3", color, single board (LE))
   IS_SENSOR_C1604R13C  = $0027;  // cmos, 160 = $1200, rolling, 1/3.2", color, single board (LE)
   IS_SENSOR_C1285R12M  = $0028;  // cmos, 128 = $1024, rolling, 1/2", mono,  single board
   IS_SENSOR_C1285R12C  = $0029;  // cmos, 128 = $1024, rolling, 1/2", color, single board
   IS_SENSOR_C1605R12C  = $002B;  // cmos, 160 = $1200, rolling, 1/2", color, single board
   IS_SENSOR_C2055R12C  = $002D;  // cmos, 2048x1536, rolling, 1/2", color, single board
   IS_SENSOR_C2595R12M  = $002E;  // cmos, 2592x1944, rolling, 1/2", mono,  single board
   IS_SENSOR_C2595R12C  = $002F;  // cmos, 2592x1944, rolling, 1/2", color, single board

   IS_SENSOR_C1280R12M  = $0030;  // cmos, 128 = $1024, rolling, 1/2", mono,
   IS_SENSOR_C1280R12C  = $0031;  // cmos, 128 = $1024, rolling, 1/2", color,

   IS_SENSOR_C1283R12M  = $0032;  // cmos, 128 = $1024, rolling, 1/2", mono, single board
   IS_SENSOR_C1283R12C  = $0033;  // cmos, 128 = $1024, rolling, 1/2", color, single board

   IS_SENSOR_C1603R12M  = $0034;  // cmos, 160 = $1200, rolling, 1/2", mono, single board
   IS_SENSOR_C1603R12C  = $0035;  // cmos, 160 = $1200, rolling, 1/2", color, single board
   IS_SENSOR_C2053R12C  = $0037;  // cmos, 2048x1536, rolling, 1/2", color, single board
   IS_SENSOR_C2593R12M  = $0038;  // cmos, 2592x1944, rolling, 1/2", mono,  single board
   IS_SENSOR_C2593R12C  = $0039;  // cmos, 2592x1944, rolling, 1/2", color, single board

   IS_SENSOR_C1286R12M  = $003A;  // cmos, 128 = $1024, rolling, 1/2", mono, single board
   IS_SENSOR_C1286R12C  = $003B;  // cmos, 128 = $1024, rolling, 1/2", color, single board

   IS_SENSOR_C1287R12M_WO  = $003C;  // cmos, 128 = $1024, rolling, 1/2", color, USB board
   IS_SENSOR_C1287R12C_WO  = $003D;  // cmos, 128 = $1024, rolling, 1/2", color, USB board

   IS_SENSOR_C3840R12M  = $003E;  // cmos, 384 = $2760, rolling, 1/2.5", mono
   IS_SENSOR_C3840R12C  = $003F;  // cmos, 384 = $2760, rolling, 1/2.5", color

   IS_SENSOR_C3845R12M  = $0040;  // cmos, 384 = $2760, rolling, 1/2.5", mono,  single board
   IS_SENSOR_C3845R12C  = $0041;  // cmos, 384 = $2760, rolling, 1/2.5", color, single board

   IS_SENSOR_C0768R12M  = $004A;  // cmos, 0768x0576, rolling, HDR sensor, 1/2", mono
   IS_SENSOR_C0768R12C  = $004B;  // cmos, 0768x0576, rolling, HDR sensor, 1/2", color

   IS_SENSOR_C2057R12M_WO  = $0044;  // cmos, 2048x1536, rolling, 1/2", mono,  USB board (special version WO)
   IS_SENSOR_C2057R12C_WO  = $0045;  // cmos, 2048x1536, rolling, 1/2", color, USB board (special version WO)

   IS_SENSOR_C2597R12M  = $0048;  // cmos, 2592x1944, rolling, 1/2", mono,  USB board (special version WO)
   IS_SENSOR_C2597R12C  = $0049;  // cmos, 2592x1944, rolling, 1/2", color, WO board (special version WO)

   IS_SENSOR_C1280G12M  = $0050;  // cmos, 128 = $1024, global, 1/2", mono
   IS_SENSOR_C1280G12C  = $0051;  // cmos, 128 = $1024, global, 1/2", color

//* CCD sensors */
   IS_SENSOR_D1024G13M  = $0080;  // ccd, 1024x0768, global, 1/3", mono,
   IS_SENSOR_D1024G13C  = $0081;  // ccd, 1024x0768, global, 1/3", color,

   IS_SENSOR_D0640G13M  = $0082;  // ccd, 064 = $0480, global, 1/3", mono
   IS_SENSOR_D0640G13C  = $0083;  // ccd, 064 = $0480, global, 1/3", color

   IS_SENSOR_D1281G12M  = $0084;  // ccd, 128 = $1024, global, 1/2", mono
   IS_SENSOR_D1281G12C  = $0085;  // ccd, 128 = $1024, global, 1/2", color

   IS_SENSOR_D0640G12M  = $0088;  // ccd, 064 = $0480, global, 1/2", mono,
   IS_SENSOR_D0640G12C  = $0089;  // ccd, 064 = $0480, global, 1/2", color,

   IS_SENSOR_D0640G14M  = $0090;  // ccd, 064 = $0480, global, 1/4", mono,
   IS_SENSOR_D0640G14C  = $0091;  // ccd, 064 = $0480, global, 1/4", color,

   IS_SENSOR_D0768G12M  = $0092;  // ccd, 0768x0582, global, 1/2", mono,
   IS_SENSOR_D0768G12C  = $0093;  // ccd, 0768x0582, global, 1/2", color,

   IS_SENSOR_D1280G12M  = $0096;  // ccd, 128 = $1024, global, 1/2", mono,
   IS_SENSOR_D1280G12C  = $0097;  // ccd, 128 = $1024, global, 1/2", color,

   IS_SENSOR_D1600G12M  = $0098;  // ccd, 160 = $1200, global, 1/1.8", mono,
   IS_SENSOR_D1600G12C  = $0099;  // ccd, 160 = $1200, global, 1/1.8", color,

   IS_SENSOR_D1280G13M  = $009A;  // ccd, 128 = $960, global, 1/3", mono,
   IS_SENSOR_D1280G13C  = $009B;  // ccd, 128 = $960, global, 1/3", color,


// ----------------------------------------------------------------------------
// error codes
// ----------------------------------------------------------------------------
   IS_NO_SUCCESS =         -1 ;  // function call failed
   IS_SUCCESS =             0 ;  // function call succeeded
   IS_INVALID_CAMERA_HANDLE =  1  ;  // camera handle is not valid or zero
   IS_INVALID_HANDLE =      1 ;  // a handle other than the camera handle is invalid

   IS_IO_REQUEST_FAILED =   2 ;  // an io request to the driver failed
   IS_CANT_OPEN_DEVICE =    3 ;  // returned by is_InitCamera
   IS_CANT_CLOSE_DEVICE =   4 ;
   IS_CANT_SETUP_MEMORY =   5 ;
   IS_NO_HWND_FOR_ERROR_REPORT = 6 ;
   IS_ERROR_MESSAGE_NOT_CREATED = 7 ;
   IS_ERROR_STRING_NOT_FOUND = 8 ;
   IS_HOOK_NOT_CREATED =    9 ;
   IS_TIMER_NOT_CREATED =  10 ;
   IS_CANT_OPEN_REGISTRY = 11 ;
   IS_CANT_READ_REGISTRY = 12 ;
   IS_CANT_VALIDATE_BOARD = 13 ;
   IS_CANT_GIVE_BOARD_ACCESS = 14 ;
   IS_NO_IMAGE_MEM_ALLOCATED =  15 ;
   IS_CANT_CLEANUP_MEMORY = 16 ;
   IS_CANT_COMMUNICATE_WITH_DRIVER = 17 ;
   IS_FUNCTION_NOT_SUPPORTED_YET = 18;
   IS_OPERATING_SYSTEM_NOT_SUPPORTED = 19 ;

   IS_INVALID_VIDEO_IN =   20 ;
   IS_INVALID_IMG_SIZE =   21 ;
   IS_INVALID_ADDRESS =    22 ;
   IS_INVALID_VIDEO_MODE = 23;
   IS_INVALID_AGC_MODE =   24 ;
   IS_INVALID_GAMMA_MODE = 25 ;
   IS_INVALID_SYNC_LEVEL = 26 ;
   IS_INVALID_CBARS_MODE = 27 ;
   IS_INVALID_COLOR_MODE = 28 ;
   IS_INVALID_SCALE_FACTOR = 29 ;
   IS_INVALID_IMAGE_SIZE = 30 ;
   IS_INVALID_IMAGE_POS =  31 ;
   IS_INVALID_CAPTURE_MODE = 32 ;
   IS_INVALID_RISC_PROGRAM = 33 ;
   IS_INVALID_BRIGHTNESS = 34 ;
   IS_INVALID_CONTRAST =   35 ;
   IS_INVALID_SATURATION_U = 36 ;
   IS_INVALID_SATURATION_V = 37 ;
   IS_INVALID_HUE =        38 ;
   IS_INVALID_HOR_FILTER_STEP = 39 ;
   IS_INVALID_VERT_FILTER_STEP = 40 ;
   IS_INVALID_EEPROM_READ_ADDRESS = 41 ;
   IS_INVALID_EEPROM_WRITE_ADDRESS = 42 ;
   IS_INVALID_EEPROM_READ_LENGTH = 43 ;
   IS_INVALID_EEPROM_WRITE_LENGTH = 44 ;
   IS_INVALID_BOARD_INFO_POINTER = 45 ;
   IS_INVALID_DISPLAY_MODE = 46 ;
   IS_INVALID_ERR_REP_MODE = 47 ;
   IS_INVALID_BITS_PIXEL = 48 ;
   IS_INVALID_MEMORY_POINTER = 49 ;

   IS_FILE_WRITE_OPEN_ERROR = 50 ;
   IS_FILE_READ_OPEN_ERROR = 51 ;
   IS_FILE_READ_INVALID_BMP_ID = 52 ;
   IS_FILE_READ_INVALID_BMP_SIZE = 53 ;
   IS_FILE_READ_INVALID_BIT_COUNT =  54 ;
   IS_WRONG_KERNEL_VERSION = 55 ;

   IS_RISC_INVALID_XLENGTH = 60 ;
   IS_RISC_INVALID_YLENGTH = 61 ;
   IS_RISC_EXCEED_IMG_SIZE = 62 ;

// DirectDraw Mode errors
   IS_DD_MAIN_FAILED =     70 ;
   IS_DD_PRIMSURFACE_FAILED = 71 ;
   IS_DD_SCRN_SIZE_NOT_SUPPORTED = 72 ;
   IS_DD_CLIPPER_FAILED =  73 ;
   IS_DD_CLIPPER_HWND_FAILED = 74 ;
   IS_DD_CLIPPER_CONNECT_FAILED = 75 ;
   IS_DD_BACKSURFACE_FAILED = 76 ;
   IS_DD_BACKSURFACE_IN_SYSMEM = 77 ;
   IS_DD_MDL_MALLOC_ERR =  78 ;
   IS_DD_MDL_SIZE_ERR =    79 ;
   IS_DD_CLIP_NO_CHANGE =  80 ;
   IS_DD_PRIMMEM_NULL =    81 ;
   IS_DD_BACKMEM_NULL =    82 ;
   IS_DD_BACKOVLMEM_NULL = 83 ;
   IS_DD_OVERLAYSURFACE_FAILED = 84 ;
   IS_DD_OVERLAYSURFACE_IN_SYSMEM =  85 ;
   IS_DD_OVERLAY_NOT_ALLOWED = 86 ;
   IS_DD_OVERLAY_COLKEY_ERR = 87 ;
   IS_DD_OVERLAY_NOT_ENABLED = 88 ;
   IS_DD_GET_DC_ERROR =    89 ;
   IS_DD_DDRAW_DLL_NOT_LOADED = 90 ;
   IS_DD_THREAD_NOT_CREATED = 91 ;
   IS_DD_CANT_GET_CAPS =   92 ;
   IS_DD_NO_OVERLAYSURFACE = 93 ;
   IS_DD_NO_OVERLAYSTRETCH = 94 ;
   IS_DD_CANT_CREATE_OVERLAYSURFACE = 95 ;
   IS_DD_CANT_UPDATE_OVERLAYSURFACE = 96 ;
   IS_DD_INVALID_STRETCH = 97 ;

   IS_EV_INVALID_EVENT_NUMBER = 100 ;
   IS_INVALID_MODE =      101 ;
   IS_CANT_FIND_FALCHOOK = 102 ;
   IS_CANT_FIND_HOOK =    102 ;
   IS_CANT_GET_HOOK_PROC_ADDR =  103 ;
   IS_CANT_CHAIN_HOOK_PROC = 104 ;
   IS_CANT_SETUP_WND_PROC = 105 ;
   IS_HWND_NULL =         106 ;
   IS_INVALID_UPDATE_MODE = 107 ;
   IS_NO_ACTIVE_IMG_MEM = 108 ;
   IS_CANT_INIT_EVENT =   109 ;
   IS_FUNC_NOT_AVAIL_IN_OS = 10 ;
   IS_CAMERA_NOT_CONNECTED = 111 ;
   IS_SEQUENCE_LIST_EMPTY = 112 ;
   IS_CANT_ADD_TO_SEQUENCE = 113 ;
   IS_LOW_OF_SEQUENCE_RISC_MEM = 114 ;
   IS_IMGMEM2FREE_USED_IN_SEQ = 115 ;
   IS_IMGMEM_NOT_IN_SEQUENCE_LIST = 116 ;
   IS_SEQUENCE_BUF_ALREADY_LOCKED = 117 ;
   IS_INVALID_DEVICE_ID = 118 ;
   IS_INVALID_BOARD_ID =  119 ;
   IS_ALL_DEVICES_BUSY =  120 ;
   IS_HOOK_BUSY =         121 ;
   IS_TIMED_OUT =         122 ;
   IS_NULL_POINTER =      123 ;
   IS_WRONG_HOOK_VERSION = 124 ;
   IS_INVALID_PARAMETER = 125 ;  // a parameter specified was invalid
   IS_NOT_ALLOWED =       126 ;
   IS_OUT_OF_MEMORY =     127 ;
   IS_INVALID_WHILE_LIVE = 128 ;
   IS_ACCESS_VIOLATION =  129 ;  // an internal exception occurred
   IS_UNKNOWN_ROP_EFFECT = 130 ;
   IS_INVALID_RENDER_MODE = 131 ;
   IS_INVALID_THREAD_CONTEXT  =  132 ;
   IS_NO_HARDWARE_INSTALLED = 133 ;
   IS_INVALID_WATCHDOG_TIME = 134 ;
   IS_INVALID_WATCHDOG_MODE = 135 ;
   IS_INVALID_PASSTHROUGH_IN = 136 ;
   IS_ERROR_SETTING_PASSTHROUGH_IN =  137 ;
   IS_FAILURE_ON_SETTING_WATCHDOG = 138 ;
   IS_NO_USB20 =          139 ;  // the usb port doesnt support usb 2.0
   IS_CAPTURE_RUNNING =   140 ;  // there is already a capture running

   IS_MEMORY_BOARD_ACTIVATED = 141 ;  // operation could not execute while mboard is enabled
   IS_MEMORY_BOARD_DEACTIVATED = 142 ;  // operation could not execute while mboard is disabled
   IS_NO_MEMORY_BOARD_CONNECTED = 143 ;  // no memory board connected
   IS_TOO_LESS_MEMORY =   144 ;  // image size is above memory capacity
   IS_IMAGE_NOT_PRESENT = 145 ;  // requested image is no longer present in the camera
   IS_MEMORY_MODE_RUNNING = 146 ;
   IS_MEMORYBOARD_DISABLED = 147 ;

   IS_TRIGGER_ACTIVATED = 148 ;  // operation could not execute while trigger is enabled
   IS_WRONG_KEY =         150 ;
   IS_CRC_ERROR =         151 ;
   IS_NOT_YET_RELEASED =  152 ;  // this feature is not available yet
   IS_NOT_CALIBRATED =    153 ;  // the camera is not calibrated
   IS_WAITING_FOR_KERNEL = 154 ;  // a request to the kernel exceeded
   IS_NOT_SUPPORTED =     155 ;  // operation mode is not supported
   IS_TRIGGER_NOT_ACTIVATED = 156 ;  // operation could not execute while trigger is disabled
   IS_OPERATION_ABORTED = 157 ;
   IS_BAD_STRUCTURE_SIZE = 158 ;
   IS_INVALID_BUFFER_SIZE = 159 ;
   IS_INVALID_PIXEL_CLOCK = 160 ;
   IS_INVALID_EXPOSURE_TIME = 161 ;
   IS_AUTO_EXPOSURE_RUNNING = 162 ;
   IS_CANNOT_CREATE_BB_SURF = 163 ;  // error creating backbuffer surface
   IS_CANNOT_CREATE_BB_MIX = 164 ;  // backbuffer mixer surfaces can not be created
   IS_BB_OVLMEM_NULL =    165 ;  // backbuffer overlay mem could not be locked
   IS_CANNOT_CREATE_BB_OVL = 166 ;  // backbuffer overlay mem could not be created
   IS_NOT_SUPP_IN_OVL_SURF_MODE = 167 ;  // function not supported in overlay surface mode
   IS_INVALID_SURFACE =   168 ;  // surface invalid
   IS_SURFACE_LOST =      169 ;  // surface has been lost
   IS_RELEASE_BB_OVL_DC = 170 ;  // error releasing backbuffer overlay DC
   IS_BB_TIMER_NOT_CREATED = 171 ;  // backbuffer timer could not be created
   IS_BB_OVL_NOT_EN =     172 ;  // backbuffer overlay has not been enabled
   IS_ONLY_IN_BB_MODE =   173 ;  // only possible in backbuffer mode
   IS_INVALID_COLOR_FORMAT = 174 ;  // invalid color format
   IS_INVALID_WB_BINNING_MODE = 175 ;  // invalid binning mode for AWB
   IS_INVALID_I2C_DEVICE_ADDRESS = 176 ;  // invalid I2C device address
   IS_COULD_NOT_CONVERT = 177  ;  // current image couldn't be converted
   IS_TRANSFER_ERROR =    178 ;  // transfer failed
   IS_PARAMETER_SET_NOT_PRESENT = 179 ;   // the parameter set is not present
   IS_INVALID_CAMERA_TYPE = 180 ;  // the camera type in the ini file doesn't match
   IS_INVALID_HOST_IP_HIBYTE = 181 ;  // HIBYTE of host address is invalid
   IS_CM_NOT_SUPP_IN_CURR_DISPLAYMODE = 182  ;  // color mode is not supported in the current display mode
   IS_NO_IR_FILTER =      183 ;
   IS_STARTER_FW_UPLOAD_NEEDED = 184 ;  // device starter firmware is not compatible

   IS_DR_LIBRARY_NOT_FOUND =  185 ;  // the DirectRender library could not be found
   IS_DR_DEVICE_OUT_OF_MEMORY = 186 ;  // insufficient graphics adapter video memory
   IS_DR_CANNOT_CREATE_SURFACE = 187 ;  // the image or overlay surface could not be created
   IS_DR_CANNOT_CREATE_VERTEX_BUFFER = 188 ;  // the vertex buffer could not be created
   IS_DR_CANNOT_CREATE_TEXTURE = 189 ;  // the texture could not be created
   IS_DR_CANNOT_LOCK_OVERLAY_SURFACE = 190 ;  // the overlay surface could not be locked
   IS_DR_CANNOT_UNLOCK_OVERLAY_SURFACE = 191 ;  // the overlay surface could not be unlocked
   IS_DR_CANNOT_GET_OVERLAY_DC = 193  ;  // cannot release the overlay surface DC
   IS_DR_DEVICE_CAPS_INSUFFICIENT =194 ;  // insufficient graphics adapter capabilities
   IS_INCOMPATIBLE_SETTING =  195 ;  // Operation is not possible because of another incompatible setting
   IS_DR_NOT_ALLOWED_WHILE_DC_IS_ACTIVE =   196 ;  // user App still has DC handle.
   IS_DEVICE_ALREADY_PAIRED = 197 ;  // The device is already paired
   IS_SUBNETMASK_MISMATCH =   198 ;  // The subnetmasks of the device and the adapter differ
   IS_SUBNET_MISMATCH =       199 ;  // The subnets of the device and the adapter differ
   IS_INVALID_IP_CONFIGURATION = 200 ;  // The IP configuation of the device is invalid
   IS_DEVICE_NOT_COMPATIBLE = 201 ;  // The device is incompatible to the driver
   IS_NETWORK_FRAME_SIZE_INCOMPATIBLE =     202 ;  // The frame size settings of the device and the network adapter are incompatible
   IS_NETWORK_CONFIGURATION_INVALID =       203 ;  // The network adapter configuration is invalid
   IS_ERROR_CPU_IDLE_STATES_CONFIGURATION = 204 ;  // The setting of the CPU idle state configuration failed
   IS_DEVICE_BUSY =           205 ;  // The device is busy. The operation must be executed again later.


// ----------------------------------------------------------------------------
// common definitions
// ----------------------------------------------------------------------------
   IS_OFF =               0 ;
   IS_ON =                1 ;
   IS_IGNORE_PARAMETER =  -1 ;


// ----------------------------------------------------------------------------
//  device enumeration
// ----------------------------------------------------------------------------
   IS_USE_DEVICE_ID =       $8000 ;
   IS_ALLOW_STARTER_FW_UPLOAD           = $10000 ;

// ----------------------------------------------------------------------------
// AutoExit enable/disable
// ----------------------------------------------------------------------------
   IS_GET_AUTO_EXIT_ENABLED             = $8000 ;
   IS_DISABLE_AUTO_EXIT = 0 ;
   IS_ENABLE_AUTO_EXIT =  1 ;


// ----------------------------------------------------------------------------
// live/freeze parameters
// ----------------------------------------------------------------------------
   IS_GET_LIVE = $8000 ;

   IS_WAIT                = $0001 ;
   IS_DONT_WAIT           = $0000 ;
   IS_FORCE_VIDEO_STOP    = $4000 ;
   IS_FORCE_VIDEO_START   = $4000 ;
   IS_USE_NEXT_MEM        = $8000 ;


// ----------------------------------------------------------------------------
// video finish constants
// ----------------------------------------------------------------------------
   IS_VIDEO_NOT_FINISH =  0 ;
   IS_VIDEO_FINISH =      1 ;


// ----------------------------------------------------------------------------
// bitmap render modes
// ----------------------------------------------------------------------------
   IS_GET_RENDER_MODE =     $8000 ;

   IS_RENDER_DISABLED =     $0000 ;
   IS_RENDER_NORMAL =       $0001 ;
   IS_RENDER_FIT_TO_WINDOW              = $0002 ;
   IS_RENDER_DOWNSCALE_1_2              = $0004 ;
   IS_RENDER_MIRROR_UPDOWN              = $0010 ;
   IS_RENDER_DOUBLE_HEIGHT              = $0020 ;
   IS_RENDER_HALF_HEIGHT                = $0040 ;

   IS_RENDER_PLANAR_COLOR_RED           = $0080 ;
   IS_RENDER_PLANAR_COLOR_GREEN         = $0100 ;
   IS_RENDER_PLANAR_COLOR_BLUE          = $0200 ;

   IS_RENDER_PLANAR_MONO_RED            = $0400 ;
   IS_RENDER_PLANAR_MONO_GREEN          = $0800 ;
   IS_RENDER_PLANAR_MONO_BLUE           = $1000 ;

   IS_USE_AS_DC_STRUCTURE               = $4000 ;
   IS_USE_AS_DC_HANDLE =    $8000 ;

// ----------------------------------------------------------------------------
// external trigger modes
// ----------------------------------------------------------------------------
   IS_GET_EXTERNALTRIGGER               = $8000 ;
   IS_GET_TRIGGER_STATUS                = $8001 ;
   IS_GET_TRIGGER_MASK =   $8002 ;
   IS_GET_TRIGGER_INPUTS                = $8003 ;
   IS_GET_SUPPORTED_TRIGGER_MODE        = $8004 ;
   IS_GET_TRIGGER_COUNTER               = $8000 ;

// old defines for compatibility
   IS_SET_TRIG_OFF =        $0000 ;
   IS_SET_TRIG_HI_LO =      $0001 ;
   IS_SET_TRIG_LO_HI =      $0002 ;
   IS_SET_TRIG_SOFTWARE =   $0008 ;
   IS_SET_TRIG_HI_LO_SYNC               = $0010 ;
   IS_SET_TRIG_LO_HI_SYNC               = $0020 ;

   IS_SET_TRIG_MASK =       $0100 ;

// New defines
   IS_SET_TRIGGER_CONTINUOUS            = $1000 ;
   IS_SET_TRIGGER_OFF =   IS_SET_TRIG_OFF ;
   IS_SET_TRIGGER_HI_LO = (IS_SET_TRIGGER_CONTINUOUS or IS_SET_TRIG_HI_LO) ;
   IS_SET_TRIGGER_LO_HI = (IS_SET_TRIGGER_CONTINUOUS or IS_SET_TRIG_LO_HI) ;
   IS_SET_TRIGGER_SOFTWARE = (IS_SET_TRIGGER_CONTINUOUS or IS_SET_TRIG_SOFTWARE) ;
   IS_SET_TRIGGER_HI_LO_SYNC = IS_SET_TRIG_HI_LO_SYNC ;
   IS_SET_TRIGGER_LO_HI_SYNC = IS_SET_TRIG_LO_HI_SYNC ;
   IS_SET_TRIGGER_PRE_HI_LO = (IS_SET_TRIGGER_CONTINUOUS or $0040) ;
   IS_SET_TRIGGER_PRE_LO_HI = (IS_SET_TRIGGER_CONTINUOUS or $0080) ;

   IS_GET_TRIGGER_DELAY =  $8000 ;
   IS_GET_MIN_TRIGGER_DELAY             = $8001;
   IS_GET_MAX_TRIGGER_DELAY             = $8002 ;
   IS_GET_TRIGGER_DELAY_GRANULARITY     = $8003 ;


// ----------------------------------------------------------------------------
// Timing
// ----------------------------------------------------------------------------
// pixelclock
   IS_GET_PIXEL_CLOCK =    $8000 ;
   IS_GET_DEFAULT_PIXEL_CLK             = $8001 ;
   IS_GET_PIXEL_CLOCK_INC               = $8005 ;

// frame rate
   IS_GET_FRAMERATE =       $8000 ;
   IS_GET_DEFAULT_FRAMERATE             = $8001 ;
// exposure
   IS_GET_EXPOSURE_TIME =   $8000 ;
   IS_GET_DEFAULT_EXPOSURE              = $8001 ;
   IS_GET_EXPOSURE_MIN_VALUE            = $8002 ;
   IS_GET_EXPOSURE_MAX_VALUE            = $8003 ;
   IS_GET_EXPOSURE_INCREMENT            = $8004 ;
   IS_GET_EXPOSURE_FINE_INCREMENT       = $8005 ;


// ----------------------------------------------------------------------------
// Gain definitions
// ----------------------------------------------------------------------------
   IS_GET_MASTER_GAIN =     $8000 ;
   IS_GET_RED_GAIN =        $8001 ;
   IS_GET_GREEN_GAIN =      $8002 ;
   IS_GET_BLUE_GAIN =       $8003 ;
   IS_GET_DEFAULT_MASTER                = $8004 ;
   IS_GET_DEFAULT_RED =     $8005 ;
   IS_GET_DEFAULT_GREEN =   $8006 ;
   IS_GET_DEFAULT_BLUE =    $8007 ;
   IS_GET_GAINBOOST =       $8008 ;
   IS_SET_GAINBOOST_ON =    $0001 ;
   IS_SET_GAINBOOST_OFF =   $0000 ;
   IS_GET_SUPPORTED_GAINBOOST           = $0002 ;
   IS_MIN_GAIN =          0 ;
   IS_MAX_GAIN =          100 ;


// ----------------------------------------------------------------------------
// Gain factor definitions
// ----------------------------------------------------------------------------
   IS_GET_MASTER_GAIN_FACTOR            = $8000 ;
   IS_GET_RED_GAIN_FACTOR               = $8001 ;
   IS_GET_GREEN_GAIN_FACTOR             = $8002 ;
   IS_GET_BLUE_GAIN_FACTOR              = $8003 ;
   IS_SET_MASTER_GAIN_FACTOR            = $8004 ;
   IS_SET_RED_GAIN_FACTOR               = $8005 ;
   IS_SET_GREEN_GAIN_FACTOR             = $8006 ;
   IS_SET_BLUE_GAIN_FACTOR              = $8007 ;
   IS_GET_DEFAULT_MASTER_GAIN_FACTOR    = $8008 ;
   IS_GET_DEFAULT_RED_GAIN_FACTOR       = $8009 ;
   IS_GET_DEFAULT_GREEN_GAIN_FACTOR     = $800a ;
   IS_GET_DEFAULT_BLUE_GAIN_FACTOR      = $800b ;
   IS_INQUIRE_MASTER_GAIN_FACTOR        = $800c ;
   IS_INQUIRE_RED_GAIN_FACTOR           = $800d ;
   IS_INQUIRE_GREEN_GAIN_FACTOR         = $800e ;
   IS_INQUIRE_BLUE_GAIN_FACTOR          = $800f ;


// ----------------------------------------------------------------------------
// Global Shutter definitions
// ----------------------------------------------------------------------------
   IS_SET_GLOBAL_SHUTTER_ON             = $0001  ;
   IS_SET_GLOBAL_SHUTTER_OFF            = $0000  ;
   IS_GET_GLOBAL_SHUTTER                = $0010  ;
   IS_GET_SUPPORTED_GLOBAL_SHUTTER      = $0020  ;


// ----------------------------------------------------------------------------
// Black level definitions
// ----------------------------------------------------------------------------
   IS_GET_BL_COMPENSATION               = $8000 ;
   IS_GET_BL_OFFSET =       $8001 ;
   IS_GET_BL_DEFAULT_MODE               = $8002 ;
   IS_GET_BL_DEFAULT_OFFSET             = $8003 ;
   IS_GET_BL_SUPPORTED_MODE             = $8004 ;

   IS_BL_COMPENSATION_DISABLE        =  0 ;
   IS_BL_COMPENSATION_ENABLE         =  1 ;
   IS_BL_COMPENSATION_OFFSET         =  32;

   IS_MIN_BL_OFFSET =     0 ;
   IS_MAX_BL_OFFSET =     255 ;

// ----------------------------------------------------------------------------
// hardware gamma definitions
// ----------------------------------------------------------------------------
   IS_GET_HW_GAMMA =        $8000 ;
   IS_GET_HW_SUPPORTED_GAMMA            = $8001 ;

   IS_SET_HW_GAMMA_OFF =    $0000 ;
   IS_SET_HW_GAMMA_ON =     $0001 ;

// ----------------------------------------------------------------------------
// camera LUT
// ----------------------------------------------------------------------------
   IS_ENABLE_CAMERA_LUT =       $0001 ;
   IS_SET_CAMERA_LUT_VALUES =   $0002 ;
   IS_ENABLE_RGB_GRAYSCALE =    $0004 ;
   IS_GET_CAMERA_LUT_USER =     $0008  ;
   IS_GET_CAMERA_LUT_COMPLETE               = $0010 ;
   IS_GET_CAMERA_LUT_SUPPORTED_CHANNELS     = $0020 ;

// ----------------------------------------------------------------------------
// camera LUT presets
// ----------------------------------------------------------------------------
   IS_CAMERA_LUT_IDENTITY               = $00000100  ;
   IS_CAMERA_LUT_NEGATIV                = $00000200  ;
   IS_CAMERA_LUT_GLOW1 =    $00000400 ;
   IS_CAMERA_LUT_GLOW2 =    $00000800 ;
   IS_CAMERA_LUT_ASTRO1 =   $00001000 ;
   IS_CAMERA_LUT_RAINBOW1               = $00002000 ;
   IS_CAMERA_LUT_MAP1 =     $00004000               ;
   IS_CAMERA_LUT_COLD_HOT               = $00008000 ;
   IS_CAMERA_LUT_SEPIC =    $00010000               ;
   IS_CAMERA_LUT_ONLY_RED               = $00020000 ;
   IS_CAMERA_LUT_ONLY_GREEN             = $00040000 ;
   IS_CAMERA_LUT_ONLY_BLUE              = $00080000 ;

   IS_CAMERA_LUT_64 =     64  ;
   IS_CAMERA_LUT_128 =    128 ;


// ----------------------------------------------------------------------------
// image parameters
// ----------------------------------------------------------------------------
// brightness
   IS_GET_BRIGHTNESS =      $8000 ;
   IS_MIN_BRIGHTNESS =    0 ;
   IS_MAX_BRIGHTNESS =    255 ;
   IS_DEFAULT_BRIGHTNESS  = -1 ;
// contrast
   IS_GET_CONTRAST =        $8000 ;
   IS_MIN_CONTRAST =      0 ;
   IS_MAX_CONTRAST =      511 ;
   IS_DEFAULT_CONTRAST =  -1 ;
// gamma
   IS_GET_GAMMA =           $8000 ;
   IS_MIN_GAMMA =         1 ;
   IS_MAX_GAMMA =         1000 ;
   IS_DEFAULT_GAMMA =     -1 ;
// saturation   (Falcon)
   IS_GET_SATURATION_U =    $8000 ;
   IS_MIN_SATURATION_U =  0       ;
   IS_MAX_SATURATION_U =  200     ;
   IS_DEFAULT_SATURATION_U         = 100 ;
   IS_GET_SATURATION_V =    $8001 ;
   IS_MIN_SATURATION_V =  0 ;
   IS_MAX_SATURATION_V =  200 ;
   IS_DEFAULT_SATURATION_V = 100 ;
// hue  (Falcon)
   IS_GET_HUE =             $8000 ;
   IS_MIN_HUE =           0 ;
   IS_MAX_HUE =           255 ;
   IS_DEFAULT_HUE =       128 ;


// ----------------------------------------------------------------------------
// Image position and size
// ----------------------------------------------------------------------------

// deprecated defines
   IS_GET_IMAGE_SIZE_X =    $8000 ;
   IS_GET_IMAGE_SIZE_Y =    $8001 ;
   IS_GET_IMAGE_SIZE_X_INC              = $8002 ;
   IS_GET_IMAGE_SIZE_Y_INC              = $8003 ;
   IS_GET_IMAGE_SIZE_X_MIN              = $8004 ;
   IS_GET_IMAGE_SIZE_Y_MIN              = $8005 ;
   IS_GET_IMAGE_SIZE_X_MAX              = $8006 ;
   IS_GET_IMAGE_SIZE_Y_MAX              = $8007 ;

   IS_GET_IMAGE_POS_X =     $8001 ;
   IS_GET_IMAGE_POS_Y =     $8002 ;
   IS_GET_IMAGE_POS_X_ABS               = $C001 ;
   IS_GET_IMAGE_POS_Y_ABS               = $C002 ;
   IS_GET_IMAGE_POS_X_INC               = $C003 ;
   IS_GET_IMAGE_POS_Y_INC               = $C004 ;
   IS_GET_IMAGE_POS_X_MIN               = $C005 ;
   IS_GET_IMAGE_POS_Y_MIN               = $C006 ;
   IS_GET_IMAGE_POS_X_MAX               = $C007 ;
   IS_GET_IMAGE_POS_Y_MAX               = $C008 ;

   IS_SET_IMAGE_POS_X_ABS               = $00010000 ;
   IS_SET_IMAGE_POS_Y_ABS               = $00010000 ;
   IS_SET_IMAGEPOS_X_ABS                = $8000 ;
   IS_SET_IMAGEPOS_Y_ABS                = $8000 ;


// Valid defines

//* Image */
   IS_AOI_IMAGE_SET_AOI =   $0001 ;
   IS_AOI_IMAGE_GET_AOI =   $0002 ;
   IS_AOI_IMAGE_SET_POS =   $0003 ;
   IS_AOI_IMAGE_GET_POS =   $0004 ;
   IS_AOI_IMAGE_SET_SIZE                = $0005 ;
   IS_AOI_IMAGE_GET_SIZE                = $0006 ;
   IS_AOI_IMAGE_GET_POS_MIN             = $0007 ;
   IS_AOI_IMAGE_GET_SIZE_MIN            = $0008 ;
   IS_AOI_IMAGE_GET_POS_MAX             = $0009 ;
   IS_AOI_IMAGE_GET_SIZE_MAX            = $0010 ;
   IS_AOI_IMAGE_GET_POS_INC             = $0011 ;
   IS_AOI_IMAGE_GET_SIZE_INC            = $0012 ;
   IS_AOI_IMAGE_GET_POS_X_ABS           = $0013 ;
   IS_AOI_IMAGE_GET_POS_Y_ABS           = $0014 ;
   IS_AOI_IMAGE_GET_ORIGINAL_AOI        = $0015 ;

   IS_AOI_IMAGE_POS_ABSOLUTE            = $10000000 ;

//* Fast move */
   IS_AOI_IMAGE_SET_POS_FAST            = $0020 ;
   IS_AOI_IMAGE_SET_POS_FAST_SUPPORTED  = $0021 ;

//* Auto features */
   IS_AOI_AUTO_BRIGHTNESS_SET_AOI       = $0030 ;
   IS_AOI_AUTO_BRIGHTNESS_GET_AOI       = $0031 ;
   IS_AOI_AUTO_WHITEBALANCE_SET_AOI     = $0032 ;
   IS_AOI_AUTO_WHITEBALANCE_GET_AOI     = $0033 ;

//* Multi AOI */
   IS_AOI_MULTI_GET_SUPPORTED_MODES     = $0100 ;
   IS_AOI_MULTI_SET_AOI =   $0200 ;
   IS_AOI_MULTI_GET_AOI =   $0400 ;
   IS_AOI_MULTI_DISABLE_AOI             = $0800 ;
   IS_AOI_MULTI_MODE_AXES               = $0001 ;
   IS_AOI_MULTI_MODE_X_Y_AXES           = $0001 ;
   IS_AOI_MULTI_MODE_Y_AXES             = $0002 ;

//* AOI sequence */
   IS_AOI_SEQUENCE_GET_SUPPORTED        = $0050 ;
   IS_AOI_SEQUENCE_SET_PARAMS           = $0051 ;
   IS_AOI_SEQUENCE_GET_PARAMS           = $0052 ;
   IS_AOI_SEQUENCE_SET_ENABLE           = $0053 ;
   IS_AOI_SEQUENCE_GET_ENABLE           = $0054 ;

   IS_AOI_SEQUENCE_INDEX_AOI_1 = 0 ;
   IS_AOI_SEQUENCE_INDEX_AOI_2 =        1  ;
   IS_AOI_SEQUENCE_INDEX_AOI_3 =        2 ;
   IS_AOI_SEQUENCE_INDEX_AOI_4 =        4 ;

// ----------------------------------------------------------------------------
// ROP effect constants
// ----------------------------------------------------------------------------
   IS_GET_ROP_EFFECT =      $8000 ;
   IS_GET_SUPPORTED_ROP_EFFECT          = $8001 ;

   IS_SET_ROP_NONE =      0                ;
   IS_SET_ROP_MIRROR_UPDOWN           = 8   ;
   IS_SET_ROP_MIRROR_UPDOWN_ODD       = 16  ;
   IS_SET_ROP_MIRROR_UPDOWN_EVEN      = 32  ;
   IS_SET_ROP_MIRROR_LEFTRIGHT        = 64  ;


// ----------------------------------------------------------------------------
// Subsampling
// ----------------------------------------------------------------------------
   IS_GET_SUBSAMPLING =         $8000 ;
   IS_GET_SUPPORTED_SUBSAMPLING             = $8001 ;
   IS_GET_SUBSAMPLING_TYPE =    $8002               ;
   IS_GET_SUBSAMPLING_FACTOR_HORIZONTAL     = $8004 ;
   IS_GET_SUBSAMPLING_FACTOR_VERTICAL       = $8008 ;

   IS_SUBSAMPLING_DISABLE =     $00                 ;

   IS_SUBSAMPLING_2X_VERTICAL               = $0001 ;
   IS_SUBSAMPLING_2X_HORIZONTAL             = $0002 ;
   IS_SUBSAMPLING_4X_VERTICAL               = $0004 ;
   IS_SUBSAMPLING_4X_HORIZONTAL             = $0008 ;
   IS_SUBSAMPLING_3X_VERTICAL               = $0010 ;
   IS_SUBSAMPLING_3X_HORIZONTAL             = $0020 ;
   IS_SUBSAMPLING_5X_VERTICAL               = $0040 ;
   IS_SUBSAMPLING_5X_HORIZONTAL             = $0080 ;
   IS_SUBSAMPLING_6X_VERTICAL               = $0100 ;
   IS_SUBSAMPLING_6X_HORIZONTAL             = $0200 ;
   IS_SUBSAMPLING_8X_VERTICAL               = $0400 ;
   IS_SUBSAMPLING_8X_HORIZONTAL             = $0800 ;
   IS_SUBSAMPLING_16X_VERTICAL              = $1000 ;
   IS_SUBSAMPLING_16X_HORIZONTAL            = $2000 ;

   IS_SUBSAMPLING_COLOR =       $01 ;
   IS_SUBSAMPLING_MONO =        $02  ;

   IS_SUBSAMPLING_MASK_VERTICAL = (IS_SUBSAMPLING_2X_VERTICAL or IS_SUBSAMPLING_4X_VERTICAL or IS_SUBSAMPLING_3X_VERTICAL or IS_SUBSAMPLING_5X_VERTICAL or IS_SUBSAMPLING_6X_VERTICAL or IS_SUBSAMPLING_8X_VERTICAL or IS_SUBSAMPLING_16X_VERTICAL) ;
   IS_SUBSAMPLING_MASK_HORIZONTAL = (IS_SUBSAMPLING_2X_HORIZONTAL or IS_SUBSAMPLING_4X_HORIZONTAL or IS_SUBSAMPLING_3X_HORIZONTAL or IS_SUBSAMPLING_5X_HORIZONTAL or IS_SUBSAMPLING_6X_HORIZONTAL or IS_SUBSAMPLING_8X_HORIZONTAL or IS_SUBSAMPLING_16X_HORIZONTAL) ;

// Compatibility
   IS_SUBSAMPLING_VERT =      IS_SUBSAMPLING_2X_VERTICAL ;
   IS_SUBSAMPLING_HOR =       IS_SUBSAMPLING_2X_HORIZONTAL ;


// ----------------------------------------------------------------------------
// Binning
// ----------------------------------------------------------------------------
   IS_GET_BINNING =         $8000 ;
   IS_GET_SUPPORTED_BINNING             = $8001 ;
   IS_GET_BINNING_TYPE =    $8002              ;
   IS_GET_BINNING_FACTOR_HORIZONTAL     = $8004 ;
   IS_GET_BINNING_FACTOR_VERTICAL       = $8008 ;

   IS_BINNING_DISABLE =     $00                 ;

   IS_BINNING_2X_VERTICAL               = $0001 ;
   IS_BINNING_2X_HORIZONTAL             = $0002 ;
   IS_BINNING_4X_VERTICAL               = $0004 ;
   IS_BINNING_4X_HORIZONTAL             = $0008 ;
   IS_BINNING_3X_VERTICAL               = $0010 ;
   IS_BINNING_3X_HORIZONTAL             = $0020 ;
   IS_BINNING_5X_VERTICAL               = $0040 ;
   IS_BINNING_5X_HORIZONTAL             = $0080 ;
   IS_BINNING_6X_VERTICAL               = $0100 ;
   IS_BINNING_6X_HORIZONTAL             = $0200 ;
   IS_BINNING_8X_VERTICAL               = $0400 ;
   IS_BINNING_8X_HORIZONTAL             = $0800 ;
   IS_BINNING_16X_VERTICAL              = $1000 ;
   IS_BINNING_16X_HORIZONTAL            = $2000 ;

   IS_BINNING_COLOR =       $01 ;
   IS_BINNING_MONO =        $02 ;

   IS_BINNING_MASK_VERTICAL = (IS_BINNING_2X_VERTICAL or IS_BINNING_3X_VERTICAL or IS_BINNING_4X_VERTICAL or IS_BINNING_5X_VERTICAL or IS_BINNING_6X_VERTICAL or IS_BINNING_8X_VERTICAL or IS_BINNING_16X_VERTICAL) ;
   IS_BINNING_MASK_HORIZONTAL = (IS_BINNING_2X_HORIZONTAL or IS_BINNING_3X_HORIZONTAL or IS_BINNING_4X_HORIZONTAL or IS_BINNING_5X_HORIZONTAL or IS_BINNING_6X_HORIZONTAL or IS_BINNING_8X_HORIZONTAL or IS_BINNING_16X_HORIZONTAL) ;

// Compatibility
   IS_BINNING_VERT =      IS_BINNING_2X_VERTICAL ;
   IS_BINNING_HOR =       IS_BINNING_2X_HORIZONTAL ;

// ----------------------------------------------------------------------------
// Auto Control Parameter
// ----------------------------------------------------------------------------
   IS_SET_ENABLE_AUTO_GAIN              = $8800 ;
   IS_GET_ENABLE_AUTO_GAIN              = $8801 ;
   IS_SET_ENABLE_AUTO_SHUTTER           = $8802 ;
   IS_GET_ENABLE_AUTO_SHUTTER           = $8803  ;
   IS_SET_ENABLE_AUTO_WHITEBALANCE      = $8804 ;
   IS_GET_ENABLE_AUTO_WHITEBALANCE      = $8805 ;
   IS_SET_ENABLE_AUTO_FRAMERATE         = $8806 ;
   IS_GET_ENABLE_AUTO_FRAMERATE         = $8807 ;
   IS_SET_ENABLE_AUTO_SENSOR_GAIN       = $8808 ;
   IS_GET_ENABLE_AUTO_SENSOR_GAIN       = $8809 ;
   IS_SET_ENABLE_AUTO_SENSOR_SHUTTER    = $8810 ;
   IS_GET_ENABLE_AUTO_SENSOR_SHUTTER    = $8811 ;
   IS_SET_ENABLE_AUTO_SENSOR_GAIN_SHUTTER   = $8812 ;
   IS_GET_ENABLE_AUTO_SENSOR_GAIN_SHUTTER   = $8813 ;
   IS_SET_ENABLE_AUTO_SENSOR_FRAMERATE      = $8814 ;
   IS_GET_ENABLE_AUTO_SENSOR_FRAMERATE      = $8815 ;
   IS_SET_ENABLE_AUTO_SENSOR_WHITEBALANCE   = $8816 ;
   IS_GET_ENABLE_AUTO_SENSOR_WHITEBALANCE   = $8817 ;


   IS_SET_AUTO_REFERENCE                = $8000 ;
   IS_GET_AUTO_REFERENCE                = $8001 ;
   IS_SET_AUTO_GAIN_MAX =   $8002               ;
   IS_GET_AUTO_GAIN_MAX =   $8003               ;
   IS_SET_AUTO_SHUTTER_MAX              = $8004 ;
   IS_GET_AUTO_SHUTTER_MAX              = $8005 ;
   IS_SET_AUTO_SPEED =      $8006                ;
   IS_GET_AUTO_SPEED =      $8007               ;
   IS_SET_AUTO_WB_OFFSET                = $8008 ;
   IS_GET_AUTO_WB_OFFSET                = $8009 ;
   IS_SET_AUTO_WB_GAIN_RANGE            = $800A ;
   IS_GET_AUTO_WB_GAIN_RANGE            = $800B ;
   IS_SET_AUTO_WB_SPEED =   $800C               ;
   IS_GET_AUTO_WB_SPEED =   $800D               ;
   IS_SET_AUTO_WB_ONCE =    $800E               ;
   IS_GET_AUTO_WB_ONCE =    $800F               ;
   IS_SET_AUTO_BRIGHTNESS_ONCE          = $8010 ;
   IS_GET_AUTO_BRIGHTNESS_ONCE          = $8011 ;
   IS_SET_AUTO_HYSTERESIS               = $8012 ;
   IS_GET_AUTO_HYSTERESIS               = $8013 ;
   IS_GET_AUTO_HYSTERESIS_RANGE         = $8014 ;
   IS_SET_AUTO_WB_HYSTERESIS            = $8015 ;
   IS_GET_AUTO_WB_HYSTERESIS            = $8016 ;
   IS_GET_AUTO_WB_HYSTERESIS_RANGE      = $8017 ;
   IS_SET_AUTO_SKIPFRAMES               = $8018 ;
   IS_GET_AUTO_SKIPFRAMES               = $8019 ;
   IS_GET_AUTO_SKIPFRAMES_RANGE         = $801A ;
   IS_SET_AUTO_WB_SKIPFRAMES            = $801B ;
   IS_GET_AUTO_WB_SKIPFRAMES            = $801C ;
   IS_GET_AUTO_WB_SKIPFRAMES_RANGE      = $801D ;
   IS_SET_SENS_AUTO_SHUTTER_PHOTOM              = $801E ;
   IS_SET_SENS_AUTO_GAIN_PHOTOM =   $801F               ;
   IS_GET_SENS_AUTO_SHUTTER_PHOTOM              = $8020 ;
   IS_GET_SENS_AUTO_GAIN_PHOTOM =   $8021               ;
   IS_GET_SENS_AUTO_SHUTTER_PHOTOM_DEF          = $8022 ;
   IS_GET_SENS_AUTO_GAIN_PHOTOM_DEF             = $8023 ;
   IS_SET_SENS_AUTO_CONTRAST_CORRECTION         = $8024 ;
   IS_GET_SENS_AUTO_CONTRAST_CORRECTION         = $8025 ;
   IS_GET_SENS_AUTO_CONTRAST_CORRECTION_RANGE   = $8026 ;
   IS_GET_SENS_AUTO_CONTRAST_CORRECTION_INC     = $8027 ;
   IS_GET_SENS_AUTO_CONTRAST_CORRECTION_DEF     = $8028 ;
   IS_SET_SENS_AUTO_CONTRAST_FDT_AOI_ENABLE     = $8029 ;
   IS_GET_SENS_AUTO_CONTRAST_FDT_AOI_ENABLE     = $8030 ;
   IS_SET_SENS_AUTO_BACKLIGHT_COMP              = $8031 ;
   IS_GET_SENS_AUTO_BACKLIGHT_COMP              = $8032 ;
   IS_GET_SENS_AUTO_BACKLIGHT_COMP_RANGE        = $8033 ;
   IS_GET_SENS_AUTO_BACKLIGHT_COMP_INC          = $8034 ;
   IS_GET_SENS_AUTO_BACKLIGHT_COMP_DEF          = $8035 ;
   IS_SET_ANTI_FLICKER_MODE =       $8036 ;
   IS_GET_ANTI_FLICKER_MODE =       $8037 ;
   IS_GET_ANTI_FLICKER_MODE_DEF =   $8038 ;

// ----------------------------------------------------------------------------
// Auto Control definitions
// ----------------------------------------------------------------------------
   IS_MIN_AUTO_BRIGHT_REFERENCE =         0 ;
   IS_MAX_AUTO_BRIGHT_REFERENCE =       255 ;
   IS_DEFAULT_AUTO_BRIGHT_REFERENCE =   128 ;
   IS_MIN_AUTO_SPEED =      0 ;
   IS_MAX_AUTO_SPEED =    100 ;
   IS_DEFAULT_AUTO_SPEED = 50 ;

   IS_DEFAULT_AUTO_WB_OFFSET =            0 ;
   IS_MIN_AUTO_WB_OFFSET = -50 ;
   IS_MAX_AUTO_WB_OFFSET = 50 ;
   IS_DEFAULT_AUTO_WB_SPEED =            50 ;
   IS_MIN_AUTO_WB_SPEED =   0 ;
   IS_MAX_AUTO_WB_SPEED = 100 ;
   IS_MIN_AUTO_WB_REFERENCE =             0 ;
   IS_MAX_AUTO_WB_REFERENCE =           255 ;


// ----------------------------------------------------------------------------
// AOI types to set/get
// ----------------------------------------------------------------------------
   IS_SET_AUTO_BRIGHT_AOI               = $8000 ;
   IS_GET_AUTO_BRIGHT_AOI               = $8001 ;
   IS_SET_IMAGE_AOI =       $8002 ;
   IS_GET_IMAGE_AOI =       $8003 ;
   IS_SET_AUTO_WB_AOI =     $8004 ;
   IS_GET_AUTO_WB_AOI =     $8005  ;


// ----------------------------------------------------------------------------
// color modes
// ----------------------------------------------------------------------------
   IS_GET_COLOR_MODE =      $8000 ;

   IS_SET_CM_RGB32 =      0 ;
   IS_SET_CM_RGB24 =      1 ;
   IS_SET_CM_RGB16 =      2 ;
   IS_SET_CM_RGB15 =      3 ;
   IS_SET_CM_Y8 =         6 ;
   IS_SET_CM_RGB8 =       7 ;
   IS_SET_CM_BAYER =      11;
   IS_SET_CM_UYVY =       12 ;
   IS_SET_CM_UYVY_MONO =  13 ;
   IS_SET_CM_UYVY_BAYER = 14 ;
   IS_SET_CM_CBYCRY =     23 ;

   IS_SET_CM_RGBY =       24 ;
   IS_SET_CM_RGB30 =      25 ;
   IS_SET_CM_Y12 =        26 ;
   IS_SET_CM_BAYER12 =    27 ;
   IS_SET_CM_Y16 =        28 ;
   IS_SET_CM_BAYER16 =    29 ;

   IS_CM_MODE_MASK =        $007F ;

// planar vs packed format
   IS_CM_FORMAT_PACKED =    $0000 ;
   IS_CM_FORMAT_PLANAR =    $2000 ;
   IS_CM_FORMAT_MASK =      $2000 ;

// BGR vs. RGB order
   IS_CM_ORDER_BGR =        $0000 ;
   IS_CM_ORDER_RGB =        $0080 ;
   IS_CM_ORDER_MASK =       $0080 ;


// define compliant color format names
   IS_CM_MONO8 =  IS_SET_CM_Y8 ;               // occupies 8 Bit
   IS_CM_MONO12 = IS_SET_CM_Y12 ;              // occupies 16 Bit
   IS_CM_MONO16 = IS_SET_CM_Y16 ;              // occupies 16 Bit

   IS_CM_BAYER_RG8 =            IS_SET_CM_BAYER ;            // occupies 8 Bit
   IS_CM_BAYER_RG12 =           IS_SET_CM_BAYER12 ;          // occupies 16 Bit
   IS_CM_BAYER_RG16 =           IS_SET_CM_BAYER16 ;          // occupies 16 Bit

   IS_CM_SENSOR_RAW8 =          IS_SET_CM_BAYER ;            // occupies 8 Bit
   IS_CM_SENSOR_RAW12 =         IS_SET_CM_BAYER12 ;          // occupies 16 Bit
   IS_CM_SENSOR_RAW16 =         IS_SET_CM_BAYER16 ;          // occupies 16 Bit

   IS_CM_BGR5_PACKED =          (IS_SET_CM_RGB15 or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;// occupies 16 Bit
   IS_CM_BGR555_PACKED =        (IS_SET_CM_RGB15 or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;// occupies 16 Bit
   IS_CM_BGR565_PACKED =        (IS_SET_CM_RGB16 or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;// occupies 16 Bit

   IS_CM_RGB8_PACKED =          (IS_SET_CM_RGB24 or IS_CM_ORDER_RGB or IS_CM_FORMAT_PACKED) ;// occupies 24 Bit
   IS_CM_BGR8_PACKED =          (IS_SET_CM_RGB24 or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;// occupies 24 Bit
   IS_CM_RGBA8_PACKED =         (IS_SET_CM_RGB32 or IS_CM_ORDER_RGB or IS_CM_FORMAT_PACKED) ;// occupies 32 Bit
   IS_CM_BGRA8_PACKED =         (IS_SET_CM_RGB32 or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;// occupies 32 Bit
   IS_CM_RGBY8_PACKED =         (IS_SET_CM_RGBY  or IS_CM_ORDER_RGB or IS_CM_FORMAT_PACKED) ;// occupies 32 Bit
   IS_CM_BGRY8_PACKED =         (IS_SET_CM_RGBY  or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;// occupies 32 Bit
   IS_CM_RGB10V2_PACKED =       (IS_SET_CM_RGB30 or IS_CM_ORDER_RGB or IS_CM_FORMAT_PACKED) ;// occupies 32 Bit
   IS_CM_BGR10V2_PACKED =       (IS_SET_CM_RGB30 or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;// occupies 32 Bit

   IS_CM_RGB10_PACKED =         (25 or IS_CM_ORDER_RGB or IS_CM_FORMAT_PACKED) ;
   IS_CM_BGR10_PACKED =         (25 or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;

   IS_CM_RGB12_PACKED =         (30 or IS_CM_ORDER_RGB or IS_CM_FORMAT_PACKED) ;             // occupies 48 Bit
   IS_CM_BGR12_PACKED =         (30 or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;             // occupies 48 Bit
   IS_CM_RGBA12_PACKED =        (31 or IS_CM_ORDER_RGB or IS_CM_FORMAT_PACKED) ;             // occupies 64 Bit
   IS_CM_BGRA12_PACKED =        (31 or IS_CM_ORDER_BGR or IS_CM_FORMAT_PACKED) ;             // occupies 64 Bit

   //IS_CM_YUV422_PACKED =        //no compliant version
   IS_CM_UYVY_PACKED =          (IS_SET_CM_UYVY or IS_CM_FORMAT_PACKED) ;     // occupies 16 Bit
   IS_CM_UYVY_MONO_PACKED =     (IS_SET_CM_UYVY_MONO or IS_CM_FORMAT_PACKED) ;
   IS_CM_UYVY_BAYER_PACKED =    (IS_SET_CM_UYVY_BAYER or IS_CM_FORMAT_PACKED) ;
   IS_CM_CBYCRY_PACKED =        (IS_SET_CM_CBYCRY or IS_CM_FORMAT_PACKED) ;   // occupies 16 Bit

   IS_CM_RGB8_PLANAR =          (1 or IS_CM_ORDER_RGB or IS_CM_FORMAT_PLANAR) ;
//   IS_CM_RGB12_PLANAR =         //no compliant version
//   IS_CM_RGB16_PLANAR =         //no compliant version


   IS_CM_ALL_POSSIBLE           = $FFFF ;
   //IS_CM_MODE_MASK              = $007F ;

// ----------------------------------------------------------------------------
// Hotpixel correction
// ----------------------------------------------------------------------------

// Deprecated defines
   IS_GET_BPC_MODE =         $8000 ;
   IS_GET_BPC_THRESHOLD =    $8001 ;
   IS_GET_BPC_SUPPORTED_MODE             = $8002 ;

   IS_BPC_DISABLE =        0                      ;
   IS_BPC_ENABLE_LEVEL_1 = 1                      ;
   IS_BPC_ENABLE_LEVEL_2 = 2                      ;
   IS_BPC_ENABLE_USER =    4                      ;
   IS_BPC_ENABLE_SOFTWARE =         IS_BPC_ENABLE_LEVEL_2 ;
   IS_BPC_ENABLE_HARDWARE =         IS_BPC_ENABLE_LEVEL_1 ;

   IS_SET_BADPIXEL_LIST =    $01                          ;
   IS_GET_BADPIXEL_LIST =    $02                           ;
   IS_GET_LIST_SIZE =        $03                           ;


// Valid defines
   IS_HOTPIXEL_DISABLE_CORRECTION =     $0000 ;
   IS_HOTPIXEL_ENABLE_SENSOR_CORRECTION             = $0001 ;
   IS_HOTPIXEL_ENABLE_CAMERA_CORRECTION             = $0002 ;
   IS_HOTPIXEL_ENABLE_SOFTWARE_USER_CORRECTION      = $0004 ;

   IS_HOTPIXEL_GET_CORRECTION_MODE =    $8000                ;
   IS_HOTPIXEL_GET_SUPPORTED_CORRECTION_MODES       = $8001  ;

   IS_HOTPIXEL_GET_SOFTWARE_USER_LIST_EXISTS        = $8100 ;
   IS_HOTPIXEL_GET_SOFTWARE_USER_LIST_NUMBER        = $8101 ;
   IS_HOTPIXEL_GET_SOFTWARE_USER_LIST               = $8102 ;
   IS_HOTPIXEL_SET_SOFTWARE_USER_LIST               = $8103 ;
   IS_HOTPIXEL_SAVE_SOFTWARE_USER_LIST              = $8104 ;
   IS_HOTPIXEL_LOAD_SOFTWARE_USER_LIST              = $8105 ;

   IS_HOTPIXEL_GET_CAMERA_FACTORY_LIST_EXISTS       = $8106 ;
   IS_HOTPIXEL_GET_CAMERA_FACTORY_LIST_NUMBER       = $8107 ;
   IS_HOTPIXEL_GET_CAMERA_FACTORY_LIST              = $8108 ;

   IS_HOTPIXEL_GET_CAMERA_USER_LIST_EXISTS          = $8109 ;
   IS_HOTPIXEL_GET_CAMERA_USER_LIST_NUMBER          = $810A ;
   IS_HOTPIXEL_GET_CAMERA_USER_LIST =   $810B              ;
   IS_HOTPIXEL_SET_CAMERA_USER_LIST =   $810C              ;
   IS_HOTPIXEL_GET_CAMERA_USER_LIST_MAX_NUMBER      = $810D ;
   IS_HOTPIXEL_DELETE_CAMERA_USER_LIST              = $810E ;

   IS_HOTPIXEL_GET_MERGED_CAMERA_LIST_NUMBER        = $810F ;
   IS_HOTPIXEL_GET_MERGED_CAMERA_LIST               = $8110 ;

   IS_HOTPIXEL_SAVE_SOFTWARE_USER_LIST_UNICODE      = $8111 ;
   IS_HOTPIXEL_LOAD_SOFTWARE_USER_LIST_UNICODE      = $8112 ;

// ----------------------------------------------------------------------------
// color correction definitions
// ----------------------------------------------------------------------------
   IS_GET_CCOR_MODE =       $8000 ;
   IS_GET_SUPPORTED_CCOR_MODE           = $8001 ;
   IS_GET_DEFAULT_CCOR_MODE             = $8002 ;
   IS_GET_CCOR_FACTOR =    $8003              ;
   IS_GET_CCOR_FACTOR_MIN               = $8004 ;
   IS_GET_CCOR_FACTOR_MAX               = $8005 ;
   IS_GET_CCOR_FACTOR_DEFAULT           = $8006 ;

   IS_CCOR_DISABLE =        $0000 ;
   IS_CCOR_ENABLE =         $0001 ;
   IS_CCOR_ENABLE_NORMAL   =        IS_CCOR_ENABLE ;
   IS_CCOR_ENABLE_BG40_ENHANCED         = $0002 ;
   IS_CCOR_ENABLE_HQ_ENHANCED           = $0004 ;
   IS_CCOR_SET_IR_AUTOMATIC             = $0080 ;
   IS_CCOR_FACTOR =         $0100 ;

   IS_CCOR_ENABLE_MASK = (IS_CCOR_ENABLE_NORMAL or IS_CCOR_ENABLE_BG40_ENHANCED or IS_CCOR_ENABLE_HQ_ENHANCED) ;


// ----------------------------------------------------------------------------
// bayer algorithm modes
// ----------------------------------------------------------------------------
   IS_GET_BAYER_CV_MODE =   $8000 ;

   IS_SET_BAYER_CV_NORMAL               = $0000 ;
   IS_SET_BAYER_CV_BETTER               = $0001 ;
   IS_SET_BAYER_CV_BEST =   $0002 ;


// ----------------------------------------------------------------------------
// color converter modes
// ----------------------------------------------------------------------------
   IS_CONV_MODE_NONE =      $0000 ;
   IS_CONV_MODE_SOFTWARE                = $0001 ;
   IS_CONV_MODE_SOFTWARE_3X3            = $0002 ;
   IS_CONV_MODE_SOFTWARE_5X5            = $0004 ;
   IS_CONV_MODE_HARDWARE_3X3            = $0008 ;
   IS_CONV_MODE_OPENCL_3X3              = $0020 ;
   IS_CONV_MODE_OPENCL_5X5              = $0040 ;

// ----------------------------------------------------------------------------
// Edge enhancement
// ----------------------------------------------------------------------------
   IS_GET_EDGE_ENHANCEMENT              = $8000 ;

   IS_EDGE_EN_DISABLE =   0 ;
   IS_EDGE_EN_STRONG =    1 ;
   IS_EDGE_EN_WEAK =      2 ;


// ----------------------------------------------------------------------------
// white balance modes
// ----------------------------------------------------------------------------
   IS_GET_WB_MODE =         $8000 ;

   IS_SET_WB_DISABLE =      $0000 ;
   IS_SET_WB_USER =         $0001 ;
   IS_SET_WB_AUTO_ENABLE                = $0002 ;
   IS_SET_WB_AUTO_ENABLE_ONCE           = $0004 ;

   IS_SET_WB_DAYLIGHT_65                = $0101 ;
   IS_SET_WB_COOL_WHITE =   $0102               ;
   IS_SET_WB_U30 =          $0103               ;
   IS_SET_WB_ILLUMINANT_A               = $0104 ;
   IS_SET_WB_HORIZON =      $0105              ;


// ----------------------------------------------------------------------------
// flash strobe constants
// ----------------------------------------------------------------------------
   IS_GET_FLASHSTROBE_MODE              = $8000 ;
   IS_GET_FLASHSTROBE_LINE              = $8001 ;
   IS_GET_SUPPORTED_FLASH_IO_PORTS      =  $8002  ;

   IS_SET_FLASH_OFF =     0                     ;
   IS_SET_FLASH_ON =      1                     ;
   IS_SET_FLASH_LO_ACTIVE =         IS_SET_FLASH_ON  ;
   IS_SET_FLASH_HI_ACTIVE =             2 ;
   IS_SET_FLASH_HIGH =    3 ;
   IS_SET_FLASH_LOW =     4;
   IS_SET_FLASH_LO_ACTIVE_FREERUN     = 5 ;
   IS_SET_FLASH_HI_ACTIVE_FREERUN     = 6 ;
   IS_SET_FLASH_IO_1 =      $0010 ;
   IS_SET_FLASH_IO_2 =      $0020   ;
   IS_SET_FLASH_IO_3 =      $0040 ;
   IS_SET_FLASH_IO_4 =      $0080 ;
   IS_FLASH_IO_PORT_MASK = (IS_SET_FLASH_IO_1 or IS_SET_FLASH_IO_2 or IS_SET_FLASH_IO_3 or IS_SET_FLASH_IO_4) ;

   IS_GET_FLASH_DELAY =   -1 ;
   IS_GET_FLASH_DURATION =              -2 ;
   IS_GET_MAX_FLASH_DELAY =             -3 ;
   IS_GET_MAX_FLASH_DURATION =          -4 ;
   IS_GET_MIN_FLASH_DELAY =             -5 ;
   IS_GET_MIN_FLASH_DURATION =          -6 ;
   IS_GET_FLASH_DELAY_GRANULARITY =     -7 ;
   IS_GET_FLASH_DURATION_GRANULARITY =  -8 ;

// ----------------------------------------------------------------------------
// Digital IO constants
// ----------------------------------------------------------------------------
   IS_GET_IO =              $8000 ;
   IS_GET_IO_MASK =         $8000 ;
   IS_GET_INPUT_MASK =      $8001 ;
   IS_GET_OUTPUT_MASK =     $8002 ;
   IS_GET_SUPPORTED_IO_PORTS            = $8004 ;


// ----------------------------------------------------------------------------
// EEPROM defines
// ----------------------------------------------------------------------------
   IS_EEPROM_MIN_USER_ADDRESS =         0 ;
   IS_EEPROM_MAX_USER_ADDRESS =         63 ;
   IS_EEPROM_MAX_USER_SPACE =           64 ;


// ----------------------------------------------------------------------------
// error report modes
// ----------------------------------------------------------------------------
   IS_GET_ERR_REP_MODE =    $8000 ;
   IS_ENABLE_ERR_REP =    1       ;
   IS_DISABLE_ERR_REP =   0       ;


// ----------------------------------------------------------------------------
// display mode selectors
// ----------------------------------------------------------------------------
   IS_GET_DISPLAY_MODE =    $8000 ;
   IS_GET_DISPLAY_SIZE_X                = $8000 ;
   IS_GET_DISPLAY_SIZE_Y                = $8001 ;
   IS_GET_DISPLAY_POS_X =   $8000 ;
   IS_GET_DISPLAY_POS_Y =   $8001 ;

   IS_SET_DM_DIB =        1 ;
   IS_SET_DM_DIRECTDRAW = 2 ;
   IS_SET_DM_DIRECT3D =   4 ;
   IS_SET_DM_OPENGL =     8 ;

   IS_SET_DM_ALLOW_SYSMEM               = $40 ;
   IS_SET_DM_ALLOW_PRIMARY              = $80 ;

// -- overlay display mode ---
   IS_GET_DD_OVERLAY_SCALE              = $8000 ;

   IS_SET_DM_ALLOW_OVERLAY              = $100 ;
   IS_SET_DM_ALLOW_SCALING              = $200 ;
   IS_SET_DM_ALLOW_FIELDSKIP            = $400 ;
   IS_SET_DM_MONO =         $800 ;
   IS_SET_DM_BAYER =        $1000 ;
   IS_SET_DM_YCBCR =        $4000 ;

// -- backbuffer display mode ---
   IS_SET_DM_BACKBUFFER =   $2000 ;


// ----------------------------------------------------------------------------
// DirectRenderer commands
// ----------------------------------------------------------------------------
   DR_GET_OVERLAY_DC =        1 ;
   DR_GET_MAX_OVERLAY_SIZE =  2 ;
   DR_GET_OVERLAY_KEY_COLOR = 3 ;
   DR_RELEASE_OVERLAY_DC =    4 ;
   DR_SHOW_OVERLAY =          5 ;
   DR_HIDE_OVERLAY =          6 ;
   DR_SET_OVERLAY_SIZE =      7 ;
   DR_SET_OVERLAY_POSITION =  8 ;
   DR_SET_OVERLAY_KEY_COLOR = 9 ;
   DR_SET_HWND =              10 ;
   DR_ENABLE_SCALING =        11 ;
   DR_DISABLE_SCALING =       12 ;
   DR_CLEAR_OVERLAY =         13 ;
   DR_ENABLE_SEMI_TRANSPARENT_OVERLAY =     14 ;
   DR_DISABLE_SEMI_TRANSPARENT_OVERLAY =    15 ;
   DR_CHECK_COMPATIBILITY =   16 ;
   DR_SET_VSYNC_OFF =         17 ;
   DR_SET_VSYNC_AUTO =        18 ;
   DR_SET_USER_SYNC =         19 ;
   DR_GET_USER_SYNC_POSITION_RANGE =        20 ;
   DR_LOAD_OVERLAY_FROM_FILE =              21 ;
   DR_STEAL_NEXT_FRAME =      22 ;
   DR_SET_STEAL_FORMAT =      23 ;
   DR_GET_STEAL_FORMAT =      24 ;
   DR_ENABLE_IMAGE_SCALING =  25 ;
   DR_GET_OVERLAY_SIZE =      26 ;
   DR_CHECK_COLOR_MODE_SUPPORT =            27 ;
   DR_GET_OVERLAY_DATA =						28 ;
   DR_UPDATE_OVERLAY_DATA	=				29 ;
   DR_GET_SUPPORTED =         30 ;

// ----------------------------------------------------------------------------
// DirectDraw keying color constants
// ----------------------------------------------------------------------------
   IS_GET_KC_RED =          $8000 ;
   IS_GET_KC_GREEN =        $8001 ;
   IS_GET_KC_BLUE =         $8002 ;
   IS_GET_KC_RGB =          $8003 ;
   IS_GET_KC_INDEX =        $8004 ;
   IS_GET_KEYOFFSET_X =     $8000 ;
   IS_GET_KEYOFFSET_Y =     $8001 ;

// RGB-triple for default key-color in 15,16,24,32 bit mode
   IS_SET_KC_DEFAULT =      $FF00FF ;  //  = $bbggrr
// color index for default key-color in 8bit palette mode
   IS_SET_KC_DEFAULT_8 =  253 ;


// ----------------------------------------------------------------------------
// Memoryboard
// ----------------------------------------------------------------------------
   IS_MEMORY_GET_COUNT =    $8000 ;
   IS_MEMORY_GET_DELAY =    $8001 ;
   IS_MEMORY_MODE_DISABLE               = $0000 ;
   IS_MEMORY_USE_TRIGGER                = $FFFF ;


// ----------------------------------------------------------------------------
// Test image modes
// ----------------------------------------------------------------------------
   IS_GET_TEST_IMAGE =      $8000 ;

   IS_SET_TEST_IMAGE_DISABLED           = $0000 ;
   IS_SET_TEST_IMAGE_MEMORY_1           = $0001 ;
   IS_SET_TEST_IMAGE_MEMORY_2           = $0002 ;
   IS_SET_TEST_IMAGE_MEMORY_3           = $0003 ;


// ----------------------------------------------------------------------------
// Led settings
// ----------------------------------------------------------------------------
   IS_SET_LED_OFF =       0 ;
   IS_SET_LED_ON =        1 ;
   IS_SET_LED_TOGGLE =    2 ;
   IS_GET_LED =             $8000 ;


// ----------------------------------------------------------------------------
// save options
// ----------------------------------------------------------------------------
   IS_SAVE_USE_ACTUAL_IMAGE_SIZE        = $00010000 ;

// ----------------------------------------------------------------------------
// renumeration modes
// ----------------------------------------------------------------------------
   IS_RENUM_BY_CAMERA =   0 ;
   IS_RENUM_BY_HOST =     1 ;

// ----------------------------------------------------------------------------
// event constants
// ----------------------------------------------------------------------------
   IS_SET_EVENT_ODD =         0 ;
   IS_SET_EVENT_EVEN =        1 ;
   IS_SET_EVENT_FRAME =       2 ;
   IS_SET_EVENT_EXTTRIG =     3 ;
   IS_SET_EVENT_VSYNC =       4 ;
   IS_SET_EVENT_SEQ =         5 ;
   IS_SET_EVENT_STEAL =       6 ;
   IS_SET_EVENT_VPRES =       7 ;
   IS_SET_EVENT_TRANSFER_FAILED =           8 ;
   IS_SET_EVENT_CAPTURE_STATUS =            8 ;
   IS_SET_EVENT_DEVICE_RECONNECTED =        9 ;
   IS_SET_EVENT_MEMORY_MODE_FINISH =        10 ;
   IS_SET_EVENT_FRAME_RECEIVED     =        11 ;
   IS_SET_EVENT_WB_FINISHED = 12               ;
   IS_SET_EVENT_AUTOBRIGHTNESS_FINISHED =   13 ;
   IS_SET_EVENT_OVERLAY_DATA_LOST       =   16 ;
   IS_SET_EVENT_CAMERA_MEMORY           =   17 ;
   IS_SET_EVENT_CONNECTIONSPEED_CHANGED =   18 ;

   IS_SET_EVENT_REMOVE =      128               ;
   IS_SET_EVENT_REMOVAL =     129               ;
   IS_SET_EVENT_NEW_DEVICE =  130               ;
   IS_SET_EVENT_STATUS_CHANGED           =  131 ;


// ----------------------------------------------------------------------------
// Window message defines
// ----------------------------------------------------------------------------
  // IS_UC480_MESSAGE =      (WM_USER +  $0100) ;
     IS_FRAME =             $0000 ;
     IS_SEQUENCE =          $0001 ;
     IS_TRIGGER =           $0002 ;
     IS_TRANSFER_FAILED =   $0003 ;
     IS_CAPTURE_STATUS =    $0003 ;
     IS_DEVICE_RECONNECTED              = $0004 ;
     IS_MEMORY_MODE_FINISH              = $0005 ;
     IS_FRAME_RECEIVED =   $0006 ;
     IS_GENERIC_ERROR =     $0007 ;
     IS_STEAL_VIDEO =       $0008 ;
     IS_WB_FINISHED =       $0009 ;
     IS_AUTOBRIGHTNESS_FINISHED         = $000A ;
     IS_OVERLAY_DATA_LOST               = $000B ;
     IS_CAMERA_MEMORY =     $000C ;
     IS_CONNECTIONSPEED_CHANGED         = $000D ;

     IS_DEVICE_REMOVED =    $1000                ;
     IS_DEVICE_REMOVAL =    $1001                ;
     IS_NEW_DEVICE =        $1002                ;
     IS_DEVICE_STATUS_CHANGED           = $1003 ;


// ----------------------------------------------------------------------------
// camera id constants
// ----------------------------------------------------------------------------
   IS_GET_CAMERA_ID =       $8000 ;


// ----------------------------------------------------------------------------
// camera info constants
// ----------------------------------------------------------------------------
   IS_GET_STATUS =          $8000 ;

   IS_EXT_TRIGGER_EVENT_CNT          =  0 ;
   IS_FIFO_OVR_CNT =      1               ;
   IS_SEQUENCE_CNT =      2               ;
   IS_LAST_FRAME_FIFO_OVR             = 3 ;
   IS_SEQUENCE_SIZE =     4               ;
   IS_VIDEO_PRESENT =     5               ;
   IS_STEAL_FINISHED =    6               ;
   IS_STORE_FILE_PATH =   7               ;
   IS_LUMA_BANDWIDTH_FILTER           = 8  ;
   IS_BOARD_REVISION =    9            ;
   IS_MIRROR_BITMAP_UPDOWN            = 10 ;
   IS_BUS_OVR_CNT =       11               ;
   IS_STEAL_ERROR_CNT =   12               ;
   IS_LOW_COLOR_REMOVAL = 13               ;
   IS_CHROMA_COMB_FILTER              = 14 ;
   IS_CHROMA_AGC =        15               ;
   IS_WATCHDOG_ON_BOARD = 16               ;
   IS_PASSTHROUGH_ON_BOARD            = 17 ;
   IS_EXTERNAL_VREF_MODE              = 18 ;
   IS_WAIT_TIMEOUT =      19               ;
   IS_TRIGGER_MISSED =    20               ;
   IS_LAST_CAPTURE_ERROR             =  21 ;
   IS_PARAMETER_SET_1 =   22               ;
   IS_PARAMETER_SET_2 =   23               ;
   IS_STANDBY =           24               ;
   IS_STANDBY_SUPPORTED = 25               ;
   IS_QUEUED_IMAGE_EVENT_CNT          = 26 ;
   IS_PARAMETER_EXT =     27               ;


// ----------------------------------------------------------------------------
// interface type defines
// ----------------------------------------------------------------------------
   IS_INTERFACE_TYPE_USB                = $40 ;
   IS_INTERFACE_TYPE_USB3               = $60 ;
   IS_INTERFACE_TYPE_ETH                = $80 ;

// ----------------------------------------------------------------------------
// board type defines
// ----------------------------------------------------------------------------
   IS_BOARD_TYPE_FALCON = 1                    ;
   IS_BOARD_TYPE_EAGLE =  2                    ;
   IS_BOARD_TYPE_FALCON2             =  3 ;
   IS_BOARD_TYPE_FALCON_PLUS         =  7 ;
   IS_BOARD_TYPE_FALCON_QUATTRO      =  9 ;
   IS_BOARD_TYPE_FALCON_DUO          =  10 ;
   IS_BOARD_TYPE_EAGLE_QUATTRO       =  11 ;
   IS_BOARD_TYPE_EAGLE_DUO           =  12 ;
   IS_BOARD_TYPE_UC480_USB           =   (IS_INTERFACE_TYPE_USB + 0) ;     //  = $40
   IS_BOARD_TYPE_UC480_USB_SE        =   IS_BOARD_TYPE_UC480_USB ;         //  = $40
   IS_BOARD_TYPE_UC480_USB_RE        =   IS_BOARD_TYPE_UC480_USB  ;        //  = $40
   IS_BOARD_TYPE_UC480_USB_ME        =   (IS_INTERFACE_TYPE_USB +  $01) ;  //  = $41
   IS_BOARD_TYPE_UC480_USB_LE        =   (IS_INTERFACE_TYPE_USB +  $02) ;  //  = $42
   IS_BOARD_TYPE_UC480_USB_XS        =   (IS_INTERFACE_TYPE_USB +  $03) ;  //  = $43
   IS_BOARD_TYPE_UC480_USB_ML        =   (IS_INTERFACE_TYPE_USB +  $05) ;  //  = $45

   IS_BOARD_TYPE_UC480_USB3_CP       =   (IS_INTERFACE_TYPE_USB3 +  $04) ; //  = $64

   IS_BOARD_TYPE_UC480_ETH            =  IS_INTERFACE_TYPE_ETH ;           //  = $80
   IS_BOARD_TYPE_UC480_ETH_HE         =  IS_BOARD_TYPE_UC480_ETH ;         //  = $80
   IS_BOARD_TYPE_UC480_ETH_SE         =  (IS_INTERFACE_TYPE_ETH +  $01) ;  //  = $81
   IS_BOARD_TYPE_UC480_ETH_RE         =  IS_BOARD_TYPE_UC480_ETH_SE ;      //  = $81
   IS_BOARD_TYPE_UC480_ETH_CP         =  IS_BOARD_TYPE_UC480_ETH +  $04 ;  //  = $84

// ----------------------------------------------------------------------------
// camera type defines
// ----------------------------------------------------------------------------
   IS_CAMERA_TYPE_UC480_USB    =     IS_BOARD_TYPE_UC480_USB_SE ;
   IS_CAMERA_TYPE_UC480_USB_SE =     IS_BOARD_TYPE_UC480_USB_SE ;
   IS_CAMERA_TYPE_UC480_USB_RE =     IS_BOARD_TYPE_UC480_USB_RE ;
   IS_CAMERA_TYPE_UC480_USB_ME =     IS_BOARD_TYPE_UC480_USB_ME ;
   IS_CAMERA_TYPE_UC480_USB_LE =     IS_BOARD_TYPE_UC480_USB_LE ;
   IS_CAMERA_TYPE_UC480_USB_ML =     IS_BOARD_TYPE_UC480_USB_ML ;

   IS_CAMERA_TYPE_UC480_USB3_CP =    IS_BOARD_TYPE_UC480_USB3_CP ;

   IS_CAMERA_TYPE_UC480_ETH     =    IS_BOARD_TYPE_UC480_ETH_HE ;
   IS_CAMERA_TYPE_UC480_ETH_HE  =    IS_BOARD_TYPE_UC480_ETH_HE ;
   IS_CAMERA_TYPE_UC480_ETH_SE  =    IS_BOARD_TYPE_UC480_ETH_SE ;
   IS_CAMERA_TYPE_UC480_ETH_RE  =    IS_BOARD_TYPE_UC480_ETH_RE ;
   IS_CAMERA_TYPE_UC480_ETH_CP  =    IS_BOARD_TYPE_UC480_ETH_CP ;

// ----------------------------------------------------------------------------
// readable operation system defines
// ----------------------------------------------------------------------------
   IS_OS_UNDETERMINED =   0 ;
   IS_OS_WIN95 =          1 ;
   IS_OS_WINNT40 =        2 ;
   IS_OS_WIN98 =          3 ;
   IS_OS_WIN2000 =        4 ;
   IS_OS_WINXP =          5 ;
   IS_OS_WINME =          6 ;
   IS_OS_WINNET =         7 ;
   IS_OS_WINSERVER2003 =  8 ;
   IS_OS_WINVISTA =       9 ;
   IS_OS_LINUX24 =        10 ;
   IS_OS_LINUX26 =        11 ;
   IS_OS_WIN7 =           12 ;
   IS_OS_WIN8 =           13 ;


// ----------------------------------------------------------------------------
// Bus speed
// ----------------------------------------------------------------------------
   IS_USB_10 =              $0001 ;//  1,5 Mb/s
   IS_USB_11 =              $0002 ;//   12 Mb/s
   IS_USB_20 =              $0004 ;//  480 Mb/s
   IS_USB_30 =              $0008 ;// 4000 Mb/s
   IS_ETHERNET_10 =         $0080 ;//   10 Mb/s
   IS_ETHERNET_100 =        $0100 ;//  100 Mb/s
   IS_ETHERNET_1000 =       $0200 ;// 1000 Mb/s
   IS_ETHERNET_10000 =      $0400 ;//10000 Mb/s

   IS_USB_LOW_SPEED =     1     ;
   IS_USB_FULL_SPEED =    12    ;
   IS_USB_HIGH_SPEED =    480   ;
   IS_USB_SUPER_SPEED =   4000  ;
   IS_ETHERNET_10Base =   10    ;
   IS_ETHERNET_100Base =  100   ;
   IS_ETHERNET_1000Base = 1000  ;
   IS_ETHERNET_10GBase =  10000 ;

// ----------------------------------------------------------------------------
// HDR
// ----------------------------------------------------------------------------
   IS_HDR_NOT_SUPPORTED = 0      ;
   IS_HDR_KNEEPOINTS =    1      ;
   IS_DISABLE_HDR =       0       ;
   IS_ENABLE_HDR =        1      ;


// ----------------------------------------------------------------------------
// Test images
// ----------------------------------------------------------------------------
   IS_TEST_IMAGE_NONE =             $00000000 ;
   IS_TEST_IMAGE_WHITE = $00000001            ;
   IS_TEST_IMAGE_BLACK = $00000002            ;
   IS_TEST_IMAGE_HORIZONTAL_GREYSCALE           = $00000004 ;
   IS_TEST_IMAGE_VERTICAL_GREYSCALE             = $00000008 ;
   IS_TEST_IMAGE_DIAGONAL_GREYSCALE             = $00000010 ;
   IS_TEST_IMAGE_WEDGE_GRAY =       $00000020              ;
   IS_TEST_IMAGE_WEDGE_COLOR =      $00000040              ;
   IS_TEST_IMAGE_ANIMATED_WEDGE_GRAY            = $00000080 ;

   IS_TEST_IMAGE_ANIMATED_WEDGE_COLOR           = $00000100 ;
   IS_TEST_IMAGE_MONO_BARS =        $00000200              ;
   IS_TEST_IMAGE_COLOR_BARS1 =      $00000400              ;
   IS_TEST_IMAGE_COLOR_BARS2 =      $00000800              ;
   IS_TEST_IMAGE_GREYSCALE1 =       $00001000              ;
   IS_TEST_IMAGE_GREY_AND_COLOR_BARS            = $00002000  ;
   IS_TEST_IMAGE_MOVING_GREY_AND_COLOR_BARS     = $00004000  ;
   IS_TEST_IMAGE_ANIMATED_LINE =    $00008000               ;

   IS_TEST_IMAGE_ALTERNATE_PATTERN              = $00010000  ;
   IS_TEST_IMAGE_VARIABLE_GREY =    $00020000               ;
   IS_TEST_IMAGE_MONOCHROME_HORIZONTAL_BARS     = $00040000  ;
   IS_TEST_IMAGE_MONOCHROME_VERTICAL_BARS       = $00080000  ;
   IS_TEST_IMAGE_CURSOR_H =         $00100000               ;
   IS_TEST_IMAGE_CURSOR_V =         $00200000               ;
   IS_TEST_IMAGE_COLDPIXEL_GRID =   $00400000               ;
   IS_TEST_IMAGE_HOTPIXEL_GRID =    $00800000               ;

   IS_TEST_IMAGE_VARIABLE_RED_PART              = $01000000  ;
   IS_TEST_IMAGE_VARIABLE_GREEN_PART            = $02000000  ;
   IS_TEST_IMAGE_VARIABLE_BLUE_PART             = $04000000  ;
   IS_TEST_IMAGE_SHADING_IMAGE =    $08000000               ;
   IS_TEST_IMAGE_WEDGE_GRAY_SENSOR              = $10000000  ;
// =  =  =    = $20000000
// =  =  =    = $40000000
// =  =  =    = $80000000


// ----------------------------------------------------------------------------
// Sensor scaler
// ----------------------------------------------------------------------------
   IS_ENABLE_SENSOR_SCALER         =    1 ;
   IS_ENABLE_ANTI_ALIASING         =    2 ;


// ----------------------------------------------------------------------------
// Timeouts
// ----------------------------------------------------------------------------
   IS_TRIGGER_TIMEOUT =   0                ;


// ----------------------------------------------------------------------------
// Auto pixel clock modes
// ----------------------------------------------------------------------------
   IS_BEST_PCLK_RUN_ONCE             =  0 ;

// ----------------------------------------------------------------------------
// sequence flags
// ----------------------------------------------------------------------------
   IS_LOCK_LAST_BUFFER =    $8002               ;
   IS_GET_ALLOC_ID_OF_THIS_BUF          = $8004 ;
   IS_GET_ALLOC_ID_OF_LAST_BUF          = $8008 ;
   IS_USE_ALLOC_ID =        $8000               ;
   IS_USE_CURRENT_IMG_SIZE              = $C000 ;

// ------------------------------------------
// Memory information flags
// ------------------------------------------
   IS_GET_D3D_MEM =         $8000 ;

// ----------------------------------------------------------------------------
// Image files types
// ----------------------------------------------------------------------------
   IS_IMG_BMP =           0 ;
   IS_IMG_JPG =           1 ;
   IS_IMG_PNG =           2 ;
   IS_IMG_RAW =           4  ;
   IS_IMG_TIF =           8  ;

// ----------------------------------------------------------------------------
// I2C defines
// nRegisterAddr or IS_I2C_16_BIT_REGISTER
// ----------------------------------------------------------------------------
   IS_I2C_16_BIT_REGISTER               = $10000000 ;
   IS_I2C_0_BIT_REGISTER	             = $20000000  ;

// nDeviceAddr or IS_I2C_DONT_WAIT
   IS_I2C_DONT_WAIT =       $00800000 ;


// ----------------------------------------------------------------------------
// DirectDraw steal video constants   (Falcon)
// ----------------------------------------------------------------------------
   IS_INIT_STEAL_VIDEO =  1                 ;
   IS_EXIT_STEAL_VIDEO =  2                 ;
   IS_INIT_STEAL_VIDEO_MANUAL        =  3    ;
   IS_INIT_STEAL_VIDEO_AUTO          =  4    ;
   IS_SET_STEAL_RATIO =   64                ;
   IS_USE_MEM_IMAGE_SIZE             =  128  ;
   IS_STEAL_MODES_MASK =  7                 ;
   IS_SET_STEAL_COPY =      $1000          ;
   IS_SET_STEAL_NORMAL =    $2000          ;

// ----------------------------------------------------------------------------
// AGC modes   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_AGC_MODE =        $8000 ;
   IS_SET_AGC_OFF =       0       ;
   IS_SET_AGC_ON =        1       ;


// ----------------------------------------------------------------------------
// Gamma modes   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_GAMMA_MODE =      $8000 ;
   IS_SET_GAMMA_OFF =     0       ;
   IS_SET_GAMMA_ON =      1       ;


// ----------------------------------------------------------------------------
// sync levels   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_SYNC_LEVEL =      $8000 ;
   IS_SET_SYNC_75 =       0       ;
   IS_SET_SYNC_125 =      1       ;


// ----------------------------------------------------------------------------
// color bar modes   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_CBARS_MODE =     $8000 ;
   IS_SET_CBARS_OFF =     0        ;
   IS_SET_CBARS_ON =      1        ;


// ----------------------------------------------------------------------------
// horizontal filter defines   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_HOR_FILTER_MODE               = $8000 ;
   IS_GET_HOR_FILTER_STEP               = $8001 ;

   IS_DISABLE_HOR_FILTER              = 0 ;
   IS_ENABLE_HOR_FILTER = 1               ;
   //IS_HOR_FILTER_STEP(_s_) =        ((_s_ + 1) << 1) ;
   IS_HOR_FILTER_STEP1 =  2 ;
   IS_HOR_FILTER_STEP2 =  4 ;
   IS_HOR_FILTER_STEP3 =  6 ;


// ----------------------------------------------------------------------------
// vertical filter defines   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_VERT_FILTER_MODE              = $8000 ;
   IS_GET_VERT_FILTER_STEP              = $8001 ;

   IS_DISABLE_VERT_FILTER            =  0 ;
   IS_ENABLE_VERT_FILTER             =  1 ;
   //IS_VERT_FILTER_STEP(_s_)      =  ((_s_ + 1) << 1) ;
   IS_VERT_FILTER_STEP1 = 2                          ;
   IS_VERT_FILTER_STEP2 = 4                          ;
   IS_VERT_FILTER_STEP3 = 6                          ;


// ----------------------------------------------------------------------------
// scaler modes   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_SCALER_MODE= 1000.0 ;
   IS_SET_SCALER_OFF = 0      ;
   IS_SET_SCALER_ON  = 1      ;

   IS_MIN_SCALE_X              =   6.25 ;
   IS_MAX_SCALE_X              = 100.00 ;
   IS_MIN_SCALE_Y              =   6.25 ;
   IS_MAX_SCALE_Y              = 100.00 ;


// ----------------------------------------------------------------------------
// video source selectors   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_VIDEO_IN =        $8000 ;
   IS_GET_VIDEO_PASSTHROUGH             = $8000 ;
   IS_GET_VIDEO_IN_TOGGLE               = $8001 ;
   IS_GET_TOGGLE_INPUT_1                = $8000 ;
   IS_GET_TOGGLE_INPUT_2                = $8001 ;
   IS_GET_TOGGLE_INPUT_3                = $8002 ;
   IS_GET_TOGGLE_INPUT_4                = $8003 ;

   IS_SET_VIDEO_IN_1 =      $00 ;
   IS_SET_VIDEO_IN_2 =      $01 ;
   IS_SET_VIDEO_IN_S =      $02 ;
   IS_SET_VIDEO_IN_3 =      $03 ;
   IS_SET_VIDEO_IN_4 =      $04 ;
   IS_SET_VIDEO_IN_1S =     $10 ;
   IS_SET_VIDEO_IN_2S =     $11 ;
   IS_SET_VIDEO_IN_3S =     $13 ;
   IS_SET_VIDEO_IN_4S =     $14 ;
   IS_SET_VIDEO_IN_EXT =    $40 ;
   IS_SET_TOGGLE_OFF =      $FF ;
   IS_SET_VIDEO_IN_SYNC =   $4000 ;


// ----------------------------------------------------------------------------
// video crossbar selectors   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_CROSSBAR =        $8000 ;

   IS_CROSSBAR_1 =        0 ;
   IS_CROSSBAR_2 =        1 ;
   IS_CROSSBAR_3 =        2 ;
   IS_CROSSBAR_4 =        3 ;
   IS_CROSSBAR_5 =        4 ;
   IS_CROSSBAR_6 =        5 ;
   IS_CROSSBAR_7 =        6 ;
   IS_CROSSBAR_8 =        7 ;
   IS_CROSSBAR_9 =        8 ;
   IS_CROSSBAR_10 =       9 ;
   IS_CROSSBAR_11 =       10 ;
   IS_CROSSBAR_12 =       11 ;
   IS_CROSSBAR_13 =       12 ;
   IS_CROSSBAR_14 =       13 ;
   IS_CROSSBAR_15 =       14 ;
   IS_CROSSBAR_16 =       15 ;
   IS_SELECT_AS_INPUT =   128 ;


// ----------------------------------------------------------------------------
// video format selectors   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_VIDEO_MODE =      $8000 ;

   IS_SET_VM_PAL =        0 ;
   IS_SET_VM_NTSC =       1 ;
   IS_SET_VM_SECAM =      2 ;
   IS_SET_VM_AUTO =       3 ;


// ----------------------------------------------------------------------------
// capture modes   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_CAPTURE_MODE =    $8000 ;

   IS_SET_CM_ODD =          $0001 ;
   IS_SET_CM_EVEN =         $0002 ;
   IS_SET_CM_FRAME =        $0004 ;
   IS_SET_CM_NONINTERLACED              = $0008 ;
   IS_SET_CM_NEXT_FRAME =   $0010    ;
   IS_SET_CM_NEXT_FIELD =   $0020    ;
   IS_SET_CM_BOTHFIELDS    =        (IS_SET_CM_ODD or IS_SET_CM_EVEN or IS_SET_CM_NONINTERLACED);
   IS_SET_CM_FRAME_STEREO               = $2004                                               ;


// ----------------------------------------------------------------------------
// display update mode constants   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_UPDATE_MODE =     $8000 ;
   IS_SET_UPDATE_TIMER =  1       ;
   IS_SET_UPDATE_EVENT =  2       ;


// ----------------------------------------------------------------------------
// sync generator mode constants   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_SYNC_GEN =        $8000 ;
   IS_SET_SYNC_GEN_OFF =  0       ;
   IS_SET_SYNC_GEN_ON =   1       ;


// ----------------------------------------------------------------------------
// decimation modes   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_DECIMATION_MODE               = $8000 ;
   IS_GET_DECIMATION_NUMBER             = $8001 ;

   IS_DECIMATION_OFF =    0                      ;
   IS_DECIMATION_CONSECUTIVE         =  1         ;
   IS_DECIMATION_DISTRIBUTED         =  2         ;


// ----------------------------------------------------------------------------
// hardware watchdog defines   (Falcon)
// ----------------------------------------------------------------------------
   IS_GET_WATCHDOG_TIME =   $2000 ;
   IS_GET_WATCHDOG_RESOLUTION           = $4000 ;
   IS_GET_WATCHDOG_ENABLE               = $8000 ;

   IS_WATCHDOG_MINUTES =  0                      ;
   IS_WATCHDOG_SECONDS =    $8000 ;
   IS_DISABLE_WATCHDOG =  0       ;
   IS_ENABLE_WATCHDOG =   1       ;
   IS_RETRIGGER_WATCHDOG           =    2 ;
   IS_ENABLE_AUTO_DEACTIVATION     =    4 ;
   IS_DISABLE_AUTO_DEACTIVATION    =    8 ;
   IS_WATCHDOG_RESERVED =   $1000         ;

        IS_EXPOSURE_CMD_GET_CAPS                        = 1;
        IS_EXPOSURE_CMD_GET_EXPOSURE_DEFAULT            = 2;
        IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE_MIN          = 3;
        IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE_MAX          = 4;
        IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE_INC          = 5;
        IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE              = 6;
        IS_EXPOSURE_CMD_GET_EXPOSURE                    = 7;
        IS_EXPOSURE_CMD_GET_FINE_INCREMENT_RANGE_MIN    = 8;
        IS_EXPOSURE_CMD_GET_FINE_INCREMENT_RANGE_MAX    = 9;
        IS_EXPOSURE_CMD_GET_FINE_INCREMENT_RANGE_INC    = 10;
        IS_EXPOSURE_CMD_GET_FINE_INCREMENT_RANGE        = 11;
        IS_EXPOSURE_CMD_SET_EXPOSURE                    = 12;
        IS_EXPOSURE_CMD_GET_LONG_EXPOSURE_RANGE_MIN     = 13;
        IS_EXPOSURE_CMD_GET_LONG_EXPOSURE_RANGE_MAX     = 14;
        IS_EXPOSURE_CMD_GET_LONG_EXPOSURE_RANGE_INC     = 15;
        IS_EXPOSURE_CMD_GET_LONG_EXPOSURE_RANGE         = 16;
        IS_EXPOSURE_CMD_GET_LONG_EXPOSURE_ENABLE        = 17;
        IS_EXPOSURE_CMD_SET_LONG_EXPOSURE_ENABLE        = 18;
        IS_EXPOSURE_CMD_GET_DUAL_EXPOSURE_RATIO         = 19;
        IS_EXPOSURE_CMD_SET_DUAL_EXPOSURE_RATIO         = 20;

        IS_PIXELCLOCK_CMD_GET_NUMBER    = 1;
        IS_PIXELCLOCK_CMD_GET_LIST      = 2;
        IS_PIXELCLOCK_CMD_GET_RANGE     = 3;
        IS_PIXELCLOCK_CMD_GET_DEFAULT   = 4;
        IS_PIXELCLOCK_CMD_GET           = 5;
        IS_PIXELCLOCK_CMD_SET           = 6;

        IS_DEVICE_FEATURE_CMD_GET_SUPPORTED_FEATURES               = 1;
        IS_DEVICE_FEATURE_CMD_SET_LINESCAN_MODE                    = 2;
        IS_DEVICE_FEATURE_CMD_GET_LINESCAN_MODE                    = 3;
        IS_DEVICE_FEATURE_CMD_SET_LINESCAN_NUMBER                  = 4;
        IS_DEVICE_FEATURE_CMD_GET_LINESCAN_NUMBER                  = 5;
        IS_DEVICE_FEATURE_CMD_SET_SHUTTER_MODE                     = 6;
        IS_DEVICE_FEATURE_CMD_GET_SHUTTER_MODE                     = 7;
        IS_DEVICE_FEATURE_CMD_SET_PREFER_XS_HS_MODE                = 8;
        IS_DEVICE_FEATURE_CMD_GET_PREFER_XS_HS_MODE                = 9;
        IS_DEVICE_FEATURE_CMD_GET_DEFAULT_PREFER_XS_HS_MODE        = 10;
        IS_DEVICE_FEATURE_CMD_GET_LOG_MODE_DEFAULT                 = 11;
        IS_DEVICE_FEATURE_CMD_GET_LOG_MODE                         = 12;
        IS_DEVICE_FEATURE_CMD_SET_LOG_MODE                         = 13;
        IS_DEVICE_FEATURE_CMD_GET_LOG_MODE_MANUAL_VALUE_DEFAULT    = 14;
        IS_DEVICE_FEATURE_CMD_GET_LOG_MODE_MANUAL_VALUE_RANGE      = 15;
        IS_DEVICE_FEATURE_CMD_GET_LOG_MODE_MANUAL_VALUE            = 16;
        IS_DEVICE_FEATURE_CMD_SET_LOG_MODE_MANUAL_VALUE            = 17;
        IS_DEVICE_FEATURE_CMD_GET_LOG_MODE_MANUAL_GAIN_DEFAULT     = 18;
        IS_DEVICE_FEATURE_CMD_GET_LOG_MODE_MANUAL_GAIN_RANGE       = 19;
        IS_DEVICE_FEATURE_CMD_GET_LOG_MODE_MANUAL_GAIN             = 20;
        IS_DEVICE_FEATURE_CMD_SET_LOG_MODE_MANUAL_GAIN             = 21;



        IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_ROLLING                      = $00000001;
        IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_GLOBAL                       = $00000002;
        IS_DEVICE_FEATURE_CAP_LINESCAN_MODE_FAST                        = $00000004;
        IS_DEVICE_FEATURE_CAP_LINESCAN_NUMBER                           = $00000008;
        IS_DEVICE_FEATURE_CAP_PREFER_XS_HS_MODE                         = $00000010;
        IS_DEVICE_FEATURE_CAP_LOG_MODE                                  = $00000020;
        IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_ROLLING_GLOBAL_START         = $00000040;
        IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_GLOBAL_ALTERNATIVE_TIMING    = $00000080;

        IS_LOG_MODE_FACTORY_DEFAULT    = 0;
        IS_LOG_MODE_OFF                = 1;
        IS_LOG_MODE_MANUAL             = 2;





type
  TThorLabsSession = record
     CamHandle : DWORD ;
     LibraryLoaded : Boolean ;
     LibraryHnd : THandle ;
     CameraOpen : Boolean ;
     CapturingImages : Boolean ;
     NumCameras : Integer ;
     BinFactors: Array[0..15] of Integer ;
     BinFactorBits: Array[0..15] of Integer ;
     NumBinFactors : Integer ;
     ShutterMode : Integer ;
     ShutterModes: Array[0..15] of string ;
     ShutterModeBit: Array[0..15] of Integer ;
     NumShutterModes : Integer ;
     GainAvailable : Boolean ;
     FrameWidth : Integer ;
     FrameHeight : Integer ;
     BitsPerPixel : Integer ;
     NumBytesPerPixel : Integer ;
     NumComponentsPerPixel : Integer ;
     UseComponent : Integer ;
     NumBytesPerFrame : Integer ;
     NumFramesInBuffer : Integer ;
     pFrameBuf : Pointer ;
     FrameCounter : Integer ;
     ActiveFrameCounter : Integer ;
     NumBytesPerLine : Integer ;
     pImageBuf : Array[0..ThorLabsMaxFrames-1] of Pointer ;
     ImageBufID : Array[0..ThorLabsMaxFrames-1] of Integer ;
     end ;

  TUC480_CAMERA_INFO = record
    CameraID : DWORD ;
    DeviceID : DWORD ;
    SensorID : DWORD ;
    InUse : DWORD ;
    SerNo : Array[0..15] of ANSIChar ;
    Model : Array[0..15] of ANSIChar ;
    Status : DWORD ;
    Reserved : Array[1..15] of DWORD ;
    end;

  TUC480_CAMERA_LIST = record
    NumCameras : DWORD ;
    CameraInfo : Array[0..0] of TUC480_CAMERA_INFO ;
    end;

  TIS_IMAGE_FORMAT_INFO = record
    ID : Integer ;
    Width : DWORD ;
    Height : DWORD ;
    XO : DWORD ;
    YO  : DWORD ;
    NumSupportedCaptureModes  : DWORD ;
    BinningMode : DWORD ;
    SubSamplingMode  : DWORD ;
    Name : Array[0..63] of ANSIChar ;
    SensorScalerFactor : Double ;
    Reserved : Array[1..22] of DWORD ;
    end;

  TIS_IMAGE_FORMAT_LIST = record
    SizeofListEntry : DWORD ;
    NumFormats : DWORD ;
    Reserved : Array[1..4] of DWORD ;
    FormatInfo : Array[0..19] of TIS_IMAGE_FORMAT_INFO ;
    end;

  TIS_SENSOR_INFO = record
    SensorID : WORD ;
    SensorName : Array[0..31] of ANSIChar ;
    ColorMode : Byte ;
    MaxWidth : DWORD ;
    MaxHeight : DWORD ;
    MasterGain : LongBool ;
    RGain : LongBool ;
    GGain : LongBool ;
    BGain : LongBool ;
    bGlobShutter : LongBool ;
    PixelSize : Word ;
    Reserved : Array[1..14] of Byte ;
    end ;

  TIS_RECT = record
    s32X : Integer ;
    s32Y : Integer ;
    s32Width : Integer ;
    s32Height : Integer ;
    end;

// ----------------------------------------------------------------------------
// alias functions for compatibility
// ----------------------------------------------------------------------------
 Tis_InitBoard = function(
                 var hCam ;
                 hWnd : Pointer )  : Integer ; cdecl ;
 Tis_ExitBoard  =   function(hCam : DWord ) : Integer ; cdecl ;

 Tis_GetBoardType  =  function(hCam : DWord ) : Integer ; cdecl ;
 Tis_GetBoardInfo  =  function(
                      hCam : DWord ;
                      pInfo : Pointer ) : Integer ; cdecl ;
 Tis_BoardStatus   =  function(
                      hCam : DWord ;
                      nInfo: Integer ;
                      ulValue : DWORD ) : DWORD ; cdecl ;
 Tis_GetNumberOfDevices =  function : Integer ; cdecl ;
 Tis_GetNumberOfBoards  =  function(
                           var nNumBoards : Integer ) : Integer ; cdecl ;

// ----------------------------------------------------------------------------
// common function
// ----------------------------------------------------------------------------
 Tis_StopLiveVideo =  function(hCam : DWord ; Wait : Integer) : Integer ; cdecl ;
 Tis_FreezeVideo   =  function(hCam : DWord ; Wait : Integer) : Integer ; cdecl ;
 Tis_CaptureVideo  =  function(hCam : DWord ; Wait : Integer) : Integer ; cdecl ;
 Tis_IsVideoFinish =  function(hCam : DWord ; var Value : Integer ) : Integer ; cdecl ;
 Tis_HasVideoStarted = function(hCam : DWord ; var pbo : LongBool ) : Integer ; cdecl ;

 Tis_SetBrightness =  function(hCam : DWord ; Bright : Integer) : Integer ; cdecl ;
 Tis_SetContrast   =  function(hCam : DWord ; Cont : Integer) : Integer ; cdecl ;
 Tis_SetGamma      =  function(hCam : DWord ; nGamma : Integer) : Integer ; cdecl ;

 Tis_AllocImageMem =  function(hCam : DWord ;
                               width : Integer ;
                               height : Integer ;
                               bitspixel : Integer ;
                               var ppcImgMem : Pointer ;
                               var pid : Integer ) : Integer ; cdecl ;
 Tis_SetImageMem   =  function(hCam : DWord ;
                      pcMem : Pointer ;
                      id : Integer) : Integer ; cdecl ;
 Tis_FreeImageMem  =  function(hCam : DWord ;
                      pcMem : Pointer ;
                      id : Integer) : Integer ; cdecl ;
 Tis_GetImageMem   =  function(hCam : DWord ;
                               pMem : Pointer ) : Integer ; cdecl ;
 Tis_GetActiveImageMem       = function(hCam : DWord ;
                               ppcMem : Pointer ;
                               var pnID : Integer ) : Integer ; cdecl ;
 Tis_InquireImageMem         = function(
                               hCam : DWord ;
                               pcMem : Pointer ;
                               nID : Integer ;
                               var pnX : Integer ;
                               var pnY : Integer ;
                               var pnBits : Integer ;
                               var pnPitch : Integer
                               ) : Integer ; cdecl ;
 Tis_GetImageMemPitch        = function(hCam : DWord ;
                               var Pitch : Integer) : Integer ; cdecl ;

 Tis_SetAllocatedImageMem    = function(hCam : DWord ;
                               width : Integer ;
                               height : Integer ;
                               bitspixel : Integer ;
                               pcImgMem : Pointer ;
                               var pid : Integer
                               ) : Integer ; cdecl ;
 Tis_SaveImageMem  =  function( hCam : DWord ;
                                FileName : PChar ;
                                pcMem : Pointer ;
                                nID : Integer) : Integer ; cdecl ;

 Tis_CopyImageMem  =  function(hCam : DWord ;
                                pcSource : Pointer ;
                                nID : Integer ;
                                pcDest : Pointer) : Integer ; cdecl ;

 Tis_CopyImageMemLines       = function(hCam : DWord ;
                               pcSource : Pointer ;
                               nID : Integer ;
                               nLines : Integer ;
                               pcDest : Pointer) : Integer ; cdecl ;

 Tis_AddToSequence =  function( hCam : DWord ;
                                pcMem : Pointer ;
                                nID : Integer ) : Integer ; cdecl ;

 Tis_ClearSequence =  function(hCam : DWord ) : Integer ; cdecl ;

 Tis_GetActSeqBuf  =  function(hCam : DWord ;
                      var pnNum : Integer ;
                      var ppcMem : Pointer ;
                      var ppcMemLast : Pointer
                      ) : Integer ; cdecl ;

 Tis_LockSeqBuf    =  function(hCam : DWord ;
                      nNum : Integer ;
                      pcMem : Pointer
                      ) : Integer ; cdecl ;

 Tis_UnlockSeqBuf  =  function(hCam : DWord ;
                      nNum : Integer ;
                      pcMem : Pointer
                      ) : Integer ; cdecl ;

  Tis_WaitForNextImage  =  function( hCam : DWord ;
                                     Timeout : DWORD ;
                                     var pImageBuf : Pointer ;
                                     var imageID : Integer
                                     ) : Integer ; cdecl ;

  Tis_InitImageQueue  =  function( hCam : DWord ;
                                    nMode : Integer
                                    ) : Integer ; cdecl ;

  Tis_ExitImageQueue  =  function( hCam : DWord ) : Integer ; cdecl ;


 Tis_SetImageSize  =  function(hCam : DWord ;
                      x : Integer ;
                      y : Integer
                      ) : Integer ; cdecl ;

 Tis_SetImagePos   =  function(hCam : DWord ;
                      x : Integer ;
                      y : Integer
                      ) : Integer ; cdecl ;

 Tis_GetError      =  function(hCam : DWord ;
                      var pErr : Integer ;
                      var ppcErr : PANSIChar
                      ) : Integer ; cdecl ;

 Tis_SetErrorReport   = function(hCam : DWord ;
                        Mode : Integer) : Integer ; cdecl ;

 Tis_ReadEEPROM    =  function(hCam : DWord ;
                      Adr : Integer ;
                      pcString : PANSIChar ;
                      Count : Integer
                      ) : Integer ; cdecl ;

 Tis_WriteEEPROM   =  function(hCam : DWord ;
                      Adr : Integer ;
                       pcString : PANSIChar ;
                      Count : Integer
                      ) : Integer ; cdecl ;

 Tis_SaveImage     =  function(hCam : DWord ;
                      FileName : PANSIChar ) : Integer ; cdecl ;

 Tis_SetColorMode  =  function(hCam : DWord ;
                      Mode : Integer) : Integer ; cdecl ;

 Tis_GetColorDepth =  function(hCam : DWord ;
                      var pnCol : Integer ;
                      var pnColMode : Integer) : Integer ; cdecl ;

  // bitmap display function
 Tis_RenderBitmap  =  function(hCam : DWord ;
                      nMemID : Integer ;
                      hwnd : THandle ;
                      nMode : Integer ) : Integer ; cdecl ;

 Tis_SetDisplayMode  = function(hCam : DWord ;
                       Mode : Integer) : Integer ; cdecl ;

 Tis_GetDC  =  function(hCam : DWord ;
               phDC : Pointer ) : Integer ; cdecl ;

 Tis_ReleaseDC  =  function(hCam : DWord ;
                   hDC : Integer ) : Integer ; cdecl ;

 Tis_UpdateDisplay =  function(hCam : DWord ) : Integer ; cdecl ;

 Tis_SetDisplaySize  = function(hCam : DWord ;
                       x : Integer ;
                       y : Integer ) : Integer ; cdecl ;

 Tis_SetDisplayPos =  function(hCam : DWord ;
                      x : Integer ;
                      y : Integer ) : Integer ; cdecl ;


 Tis_GetOsVersion =  function : Integer ; cdecl ;
  // version information
 Tis_GetDLLVersion =  function : Integer ; cdecl ;

 Tis_InitEvent     =  function(hCam : DWord ;
                      hEv : THandle ;
                      which : Integer) : Integer ; cdecl ;

 Tis_ExitEvent     =  function(hCam : DWord ;
                      which : Integer) : Integer ; cdecl ;

 Tis_EnableEvent   =  function(hCam : DWord ;
                      which : Integer) : Integer ; cdecl ;

 Tis_DisableEvent  =  function(hCam : DWord ;
                      which : Integer) : Integer ; cdecl ;

 Tis_SetIO  =  function(hCam : DWord ;
               nIO : Integer) : Integer ; cdecl ;

 Tis_SetFlashStrobe  = function(hCam : DWord ;
                       nMode : Integer ;
                       nLine : Integer) : Integer ; cdecl ;

 Tis_SetExternalTrigger  = function(hCam : DWord ;
                           nTriggerMode : Integer) : Integer ; cdecl ;

 Tis_SetTriggerCounter  = function(hCam : DWord ;
                          nValue : Integer) : Integer ; cdecl ;

 Tis_SetRopEffect  =  function(hCam : DWord ;
                      effect : Integer ;
                      param : Integer ;
                      reserved : Integer ) : Integer ; cdecl ;

// ----------------------------------------------------------------------------
// new functions only valid for uc480 camera family
// ----------------------------------------------------------------------------
  // Camera functions
  Tis_InitCamera   =  function(var hCam : DWORD ;
                      hWnd : THandle ) : Integer ; cdecl ;

  Tis_ExitCamera  =  function(hCam : DWord ) : Integer ; cdecl ;

  Tis_GetCameraInfo  =  function(hCam : DWord ;
                                 pInfo : Pointer ) : Integer ; cdecl ;

  Tis_CameraStatus   =  function(hCam : DWord ;
                                   nInfo: Integer ;
                                   Value : DWORD ) : DWORD ; cdecl ;

  Tis_GetCameraType   =  function(hCam : DWord ) : Integer ; cdecl ;

  Tis_GetNumberOfCameras   =  function(var pnNumCams : Integer) : Integer ; cdecl ;

  Tis_ImageFormat = function( hCam : DWord ;
                              nCommand : DWord ;
                              pParam : Pointer ;
                              nSizeOfParam : DWord ) : DWORD ; cdecl ;

  // PixelClock
  Tis_GetPixelClockRange =  function(hCam : DWord ;
                            var pnMin: Integer ;
                            var pnMax: Integer ) : Integer ; cdecl ;

  Tis_SetPixelClock      =  function(hCam : DWord ;
                            Clock : Integer ) : Integer ; cdecl ;

  Tis_GetUsedBandwidth   =  function(hCam : DWord ) : Integer ; cdecl ;
  // Set/Get Frame rate
  Tis_GetFrameTimeRange  =  function(hCam : DWord ;
                            var min : Double ;
                            var max : Double ;
                            var interval : Double ) : Integer ; cdecl ;

  Tis_SetFrameRate       =  function(hCam : DWord ;
                            FPS : Double ;
                            var newFPS : Double ) : Integer ; cdecl ;

  Tis_Exposure       =  function( hCam : DWord ;
                                  nCommand : DWORD ;
                                  pParam : Pointer ;
                                  cbSizeOfParam : DWORD ) : Integer ; cdecl ;
  // Set/Get Exposure
  Tis_GetExposureRange   =  function(hCam : DWord ;
                            var min : Double ;
                            var max : Double ;
                            var interval : Double ) : Integer ; cdecl ;

  Tis_SetExposureTime    =  function(hCam : DWord ;
                            EXP : Double ;
                            var newEXP : Double ) : Integer ; cdecl ;
  // get frames per second
  Tis_GetFramesPerSecond =  function(hCam : DWord ;
                            var dblFPS : Double) : Integer ; cdecl ;

  // is_SetIOMask ( only uc480 USB )
  Tis_SetIOMask          =  function(hCam : DWord ;
                            nMask : Integer) : Integer ; cdecl ;

  // Get Sensor info
  Tis_GetSensorInfo      =  function(hCam : DWord ;
                            pInfo : Pointer ) : Integer ; cdecl ;
  // Get RevisionInfo
  Tis_GetRevisionInfo    =  function(hCam : DWord ;
                            prevInfo : Pointer ) : Integer ; cdecl ;

  // enable/disable AutoExit after device remove
  Tis_EnableAutoExit     =  function(hCam : DWord ;
                            nMode : Integer) : Integer ; cdecl ;
  // Message
  Tis_EnableMessage      =  function(hCam : DWord ;
                            which  : Integer ;
                            hWnd : THandle ) : Integer ; cdecl ;

  // hardware gain settings
  Tis_SetHardwareGain    =  function(hCam : DWord ;
                            nMaster : Integer ;
                            nRed : Integer ;
                            nGreen : Integer ;
                            nBlue : Integer ) : Integer ; cdecl ;

  // set render mode
  Tis_SetRenderMode      =  function(hCam : DWord ;
                            Mode : Integer) : Integer ; cdecl ;

  // enable/disable WhiteBalance
  Tis_SetWhiteBalance    =  function(hCam : DWord ;
                            nMode : Integer) : Integer ; cdecl ;

  Tis_SetWhiteBalanceMultipliers   = function(hCam : DWord ;
                                     Red : Double ;
                                     Green : Double ;
                                     Blue : Double ) : Integer ; cdecl ;

  Tis_GetWhiteBalanceMultipliers   = function(hCam : DWord ;
                                     var pdblRed : Double ;
                                     var pdblGreen : Double ;
                                     var pdblBlue : Double ) : Integer ; cdecl ;

  // Edge enhancement
  Tis_SetEdgeEnhancement =  function(hCam : DWord ;
                            nEnable: Integer) : Integer ; cdecl ;

  // Sensor features
  Tis_SetColorCorrection =  function(hCam : DWord ;
                            nEnable : Integer ;
                            var factors : Double ) : Integer ; cdecl ;

  Tis_SetBlCompensation  =  function(hCam : DWord ;
                            nEnable : Integer ;
                            offset : Integer ;
                            reserved : Integer ) : Integer ; cdecl ;

  // Hotpixel
  Tis_SetBadPixelCorrection        = function(hCam : DWord ;
                                      nEnable : Integer ;
                                      threshold : Integer ) : Integer ; cdecl ;

  Tis_LoadBadPixelCorrectionTable  = function(hCam : DWord ;
                                     FileName : PANSIChar ) : Integer ; cdecl ;

  Tis_SaveBadPixelCorrectionTable  = function(hCam : DWord ;
                                     FileName : PANSIChar ) : Integer ; cdecl ;

  Tis_SetBadPixelCorrectionTable   = function(hCam : DWord ;
                                     nMode : Integer ;
                                     pList : Pointer ) : Integer ; cdecl ;

  // Memoryboard
  Tis_SetMemoryMode      =  function(hCam : DWord ;
                            nCount : Integer ;
                            nDelay : Integer ) : Integer ; cdecl ;

  Tis_TransferImage      =  function(hCam : DWord ;
                            nMemID : Integer ;
                            seqID : Integer ;
                            imageNr : Integer ;
                            reserved : Integer ) : Integer ; cdecl ;

  Tis_TransferMemorySequence  = function(hCam : DWord ;
                                seqID : Integer ;
                                StartNr : Integer ;
                                nCount : Integer ;
                                nSeqPos : Integer ) : Integer ; cdecl ;

  Tis_MemoryFreezeVideo  =  function(hCam : DWord ;
                            nMemID : Integer ;
                            Wait : Integer) : Integer ; cdecl ;

  Tis_GetLastMemorySequence  = function(hCam : DWord ;
                              var pID : Integer ) : Integer ; cdecl ;

  Tis_GetNumberOfMemoryImages  = function(hCam : DWord ;
                                  nID : Integer ;
                                  var pnCount : Integer ) : Integer ; cdecl ;

  Tis_GetMemorySequenceWindow   = function(hCam : DWord ;
                                  nID : Integer ;
                                  var left : Integer ;
                                  var top : Integer ;
                                  var right : Integer ;
                                  var bottom : Integer ) : Integer ; cdecl ;

  Tis_IsMemoryBoardConnected  = function(hCam : DWord ;
                                var pConnected) : Integer ; cdecl ;

  Tis_ResetMemory        =  function(hCam : DWord ;
                            nReserved : Integer) : Integer ; cdecl ;

  Tis_SetSubSampling     =  function(hCam : DWord ;
                            mode : Integer) : Integer ; cdecl ;

  Tis_ForceTrigger       =  function(hCam : DWord ) : Integer ; cdecl ;

  // new with driver version 1.12.0006
  Tis_GetBusSpeed        =  function(hCam : DWord ) : Integer ; cdecl ;

  // new with driver version 1.12.0015
  Tis_SetBinning         =  function(hCam : DWord ;
                            mode : Integer) : Integer ; cdecl ;

  // new with driver version 1.12.0017
  Tis_ResetToDefault     =  function(hCam : DWord ) : Integer ; cdecl ;

  Tis_LoadParameters     =  function(hCam : DWord ;
                            pFilename : PANSIChar ) : Integer ; cdecl ;

  Tis_SaveParameters     =  function(hCam : DWord ;
                            pFilename : PANSIChar ) : Integer ; cdecl ;

  // new with driver version 1.14.0001
  Tis_GetGlobalFlashDelays = function(hCam : DWord ;
                             var pulDelay : DWord ;
                             var pulDuration : DWord
                             ) : Integer ; cdecl ;

  Tis_SetFlashDelay      =  function(hCam : DWord ;
                            ulDelay : DWord ;
                            ulDuration : DWord ) : Integer ; cdecl ;

  // new with driver version 1.14.0002
  Tis_LoadImage          =  function(hCam : DWord ;
                            pFilename : PANSIChar ) : Integer ; cdecl ;

  // new with driver version 1.14.0008
  Tis_SetImageAOI        =  function(hCam : DWord ;
                            xPos : Integer ;
                            yPos : Integer ;
                            width : Integer ;
                            height : Integer ) : Integer ; cdecl ;

  Tis_SetCameraID        =  function(hCam : DWord ;
                            nID : Integer ) : Integer ; cdecl ;

  Tis_SetBayerConversion =  function(hCam : DWord ;
                            nMode : Integer ) : Integer ; cdecl ;

  Tis_SetTestImage       =  function(hCam : DWord ;
                            nMode : Integer ) : Integer ; cdecl ;

  // new with driver version 1.14.0009
  Tis_SetHardwareGamma   =  function(hCam : DWord ;
                            nMode : Integer ) : Integer ; cdecl ;

  // new with driver version 2.00.0001
  Tis_GetCameraList =  function( pucl : Pointer ) : Integer ; cdecl ;

  // new with driver version 2.00.0011
  Tis_SetAOI  =  function(hCam : DWord ;
                 itype: Integer ;
                 var pXPos: Integer ;
                 var pYPos: Integer ;
                 var pWidth: Integer ;
                 var pHeight: Integer ) : Integer ; cdecl ;

  Tis_SetAutoParameter   =  function(hCam : DWord ;
                            param: Integer ;
                            var pval1 : double ;
                            var pval2 : double ) : Integer ; cdecl ;

  Tis_GetAutoInfo        =  function(hCam : DWord ;
                            pInfo : Pointer ) : Integer ; cdecl ;

  Tis_SetSensorScaler        =  function(hCam : DWord ;
                                Mode : DWORD ;
                                Factor : Double ) : Integer ; cdecl ;

  // new with driver version 2.20.0001
//  Tis_ConvertImage       =  function(hCam : DWord ; char* pcSource, int nIDSource, char** pcDest, INT *nIDDest, INT *reserved) : Integer ; cdecl ;
//  Tis_SetConvertParam    =  function(hCam : DWord ; BOOL ColorCorrection, INT BayerConversionMode, INT ColorMode, INT Gamma, double* WhiteBalanceMultipliers) : Integer ; cdecl ;

//  Tis_SaveImageEx        =  function(hCam : DWord ; const IS_CHAR* File, INT fileFormat, INT Param) : Integer ; cdecl ;
//  Tis_SaveImageMemEx     =  function(hCam : DWord ; const IS_CHAR* File, char* pcMem, INT nID, INT FileFormat, INT Param) : Integer ; cdecl ;
//  Tis_LoadImageMem       =  function(hCam : DWord ; const IS_CHAR* File, char** ppcImgMem, INT* pid) : Integer ; cdecl ;

//  Tis_GetImageHistogram  =  function(hCam : DWord ; int nID, INT ColorMode, DWORD* pHistoMem) : Integer ; cdecl ;
  Tis_SetTriggerDelay    =  function(hCam : DWord ;
                            nTriggerDelay : Integer) : Integer ; cdecl ;

  // new with driver version 2.21.0000
  Tis_SetGainBoost       =  function(hCam : DWord ;
                            mode : Integer) : Integer ; cdecl ;

  Tis_SetLED             =  function(hCam : DWord ;
                            nValue : Integer )  : Integer ; cdecl ;

  Tis_SetGlobalShutter   =  function(hCam : DWord ;
                            mode : Integer) : Integer ; cdecl ;

  Tis_SetExtendedRegister   = function(hCam : DWord ;
                              index : Integer ;
                              value : DWORD ) : Integer ; cdecl ;

  Tis_GetExtendedRegister   = function(hCam : DWord ;
                              index : Integer ;
                              var pwValue : DWORD ) : Integer ; cdecl ;

  // new with driver version 2.22.0002
  Tis_SetHWGainFactor    =  function(hCam : DWord ;
                            nMode : Integer ;
                            nFactor : Integer ) : Integer ; cdecl ;

  // camera renumeration
  Tis_Renumerate         =  function(hCam : DWord ;
                            nMode : Integer
                            ) : Integer ; cdecl ;

  Tis_AOI         =  function( hCam : DWord ;
                               nCommand : DWord ;
                               pParam : Pointer ;
                               nSizeOfParam : DWORD ) : Integer ; cdecl ;

  Tis_pixelclock         =  function( hCam : DWord ;
                             nCommand : DWord ;
                               pParam : Pointer ;
                               nSizeOfParam : DWORD ) : Integer ; cdecl ;

  Tis_DeviceFeature         =  function( hCam : DWord ;
                             nCommand : DWord ;
                               pParam : Pointer ;
                               nSizeOfParam : DWORD ) : Integer ; cdecl ;


  // Read / Write I2C
//  Tis_WriteI2C           =  function(hCam : DWord ; INT nDeviceAddr, INT nRegisterAddr, BYTE* pbData, INT nLen) : Integer ; cdecl ;
//  Tis_ReadI2C            =  function(hCam : DWord ; INT nDeviceAddr, INT nRegisterAddr, BYTE* pbData, INT nLen) : Integer ; cdecl ;


function ThorLabs_GetDLLAddress(
         Handle : THandle ;
         const ProcName : string ) : Pointer ;

function ThorLabs_CheckDLLExists( DLLName : String ) : Boolean ;

procedure ThorLabs_LoadLibrary(
          var Session : TThorLabsSession    // camera session record  ;
          ) ;

function ThorLabs_OpenCamera(
          var Session : TThorLabsSession ;  // camera session record
          var FrameWidthMax : Integer ;      // Returns camera frame width
          var FrameHeightMax : Integer ;     // Returns camera frame width
          var BinFactorMax : Integer ;       // Maximum bin factor
          var NumBytesPerPixel : Integer ;   // Returns bytes/pixel
          var PixelDepth : Integer ;         // Returns no. bits/pixel
          var PixelWidth : Single ;          // Returns pixel size (um)
          CameraInfo : TStringList         // Returns Camera details
          ) : LongBool ;

function ThorLabs_PixelDepth( ADConverterList : TStringList ;
                 ADCNum : Integer ) : Integer ;

procedure ThorLabs_CloseCamera(
          var Session : TThorLabsSession // Session record
          ) ;

procedure ThorLabs_GetCameraGainList(
          var Session : TThorLabsSession ; // Session record
          CameraGainList : TStringList
          ) ;

procedure ThorLabs_GetCameraReadoutSpeedList(
          var Session : TThorLabsSession ; // Session record
          CameraReadoutSpeedList : TStringList
          ) ;

procedure ThorLabs_GetCameraModeList(
          var Session : TThorLabsSession ; // Session record
          List : TStringList
          ) ;

procedure ThorLabs_GetCameraADCList(
          var Session : TThorLabsSession ; // Session record
          List : TStringList
          ) ;

procedure ThorLabs_CheckROIBoundaries(
         var Session : TThorLabsSession ;  // camera session record
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

function ThorLabs_BinFactor( BinFactorList : TStringList ;
                Index : Integer ) : Integer ;

function ThorLabs_StartCapture(
         var Session : TThorLabsSession ;  // camera session record
         var InterFrameTimeInterval : Double ;      // Frame exposure time
         AdditionalReadoutTime : Double ; // Additional readout time (s)
         AmpGain : Integer ;               // camera amplifier gain index
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

procedure ThorLabs_UpdateCircularBufferSize(
          var Session : TThorLabsSession  ;  // camera session record
          FrameLeft : Integer ;
          FrameRight : Integer ;
          FrameTop : Integer ;
          FrameBottom : Integer ;
          BinFactor : Integer
          ) ;

function ThorLabs_CheckFrameInterval(
          var Session : TThorLabsSession ;  // camera session record
          Var FrameInterval : Double ;
          Var ReadoutTime : Double) : LongBool ;


procedure ThorLabs_Wait( Delay : Single ) ;

procedure ThorLabs_SetBinning(
          var Session : TThorLabsSession ;  // camera session record
          BinFactor : Integer
          ) ;

procedure ThorLabs_GetImage(
          var Session : TThorLabsSession   // camera session record
          ) ;

procedure ThorLabs_StopCapture(
          var Session : TThorLabsSession   // camera session record
          ) ;

procedure ThorLabs_SetTemperature(
          var Session : TThorLabsSession ; // Session record
          var TemperatureSetPoint : Single  // Required temperature
          ) ;

procedure ThorLabs_SetCooling(
          var Session : TThorLabsSession ; // Session record
          CoolingOn : LongBool  // True = Cooling is on
          ) ;

procedure ThorLabs_SetFanMode(
          var Session : TThorLabsSession ; // Session record
          FanMode : Integer  // 0 = Off, 1=low, 2=high
          ) ;

procedure ThorLabs_SetCameraMode(
          var Session : TThorLabsSession ; // Session record
          Mode : Integer ) ;

procedure ThorLabs_SetCameraADC(
          var Session : TThorLabsSession ; // Session record
          ADCNum : Integer ;
          var PixelDepth : Integer ;
          var GreyLevelMin : Integer ;
          var GreyLevelMax : Integer ) ;

procedure ThorLabs_CheckError(
          CamHandle : DWord ;
          FuncName : String ;   // Name of function called
          ErrNum : Integer      // Error # returned by function
          ) ;

var

  is_InitCamera : Tis_InitCamera ;
  is_ExitCamera : Tis_ExitCamera ;
  is_GetCameraInfo : Tis_GetCameraInfo ;
  is_GetDLLVersion : Tis_GetDLLVersion ;
  is_CameraStatus : Tis_CameraStatus ;
  is_GetCameraType : Tis_GetCameraType ;
  is_GetNumberOfCameras : Tis_GetNumberOfCameras ;
  is_GetPixelClockRange : Tis_GetPixelClockRange ;
  is_SetPixelClock : Tis_SetPixelClock ;
  is_GetUsedBandwidth : Tis_GetUsedBandwidth ;
  is_GetFrameTimeRange : Tis_GetFrameTimeRange ;
  is_SetFrameRate : Tis_SetFrameRate ;
  is_GetExposureRange : Tis_GetExposureRange ;
  is_SetExposureTime : Tis_SetExposureTime ;
  is_GetFramesPerSecond : Tis_GetFramesPerSecond ;
  is_SetIOMask : Tis_SetIOMask ;
  is_GetSensorInfo : Tis_GetSensorInfo ;
  is_GetRevisionInfo : Tis_GetRevisionInfo ;
  is_EnableAutoExit : Tis_EnableAutoExit ;
  is_EnableMessage : Tis_EnableMessage ;
  is_SetHardwareGain : Tis_SetHardwareGain ;
  is_SetRenderMode : Tis_SetRenderMode ;
  is_SetWhiteBalance : Tis_SetWhiteBalance ;
  is_SetWhiteBalanceMultipliers : Tis_SetWhiteBalanceMultipliers ;
  is_GetWhiteBalanceMultipliers : Tis_GetWhiteBalanceMultipliers ;
  is_SetEdgeEnhancement : Tis_SetEdgeEnhancement ;
  is_SetColorCorrection : Tis_SetColorCorrection ;
  is_SetBlCompensation : Tis_SetBlCompensation ;
  is_SetBadPixelCorrection : Tis_SetBadPixelCorrection ;
  is_LoadBadPixelCorrectionTable : Tis_LoadBadPixelCorrectionTable ;
  is_SaveBadPixelCorrectionTable : Tis_SaveBadPixelCorrectionTable ;
  is_SetBadPixelCorrectionTable : Tis_SetBadPixelCorrectionTable ;
  is_SetMemoryMode : Tis_SetMemoryMode ;
  is_TransferImage : Tis_TransferImage ;
  is_TransferMemorySequence : Tis_TransferMemorySequence ;
  is_MemoryFreezeVideo : Tis_MemoryFreezeVideo ;
  is_GetLastMemorySequence : Tis_GetLastMemorySequence ;
  is_GetNumberOfMemoryImages : Tis_GetNumberOfMemoryImages ;
  is_GetMemorySequenceWindow : Tis_GetMemorySequenceWindow ;
  is_IsMemoryBoardConnected : Tis_IsMemoryBoardConnected ;
  is_ResetMemory : Tis_ResetMemory ;
  is_SetSubSampling : Tis_SetSubSampling ;
  is_ForceTrigger : Tis_ForceTrigger ;
  is_GetBusSpeed : Tis_GetBusSpeed ;
  is_SetBinning : Tis_SetBinning ;
  is_ResetToDefault : Tis_ResetToDefault ;
  is_LoadParameters : Tis_LoadParameters ;
  is_SaveParameters : Tis_SaveParameters ;
  is_GetGlobalFlashDelays : Tis_GetGlobalFlashDelays ;
  is_SetFlashDelay : Tis_SetFlashDelay ;
  is_LoadImage : Tis_LoadImage ;
  is_SetImageAOI : Tis_SetImageAOI ;
  is_SetCameraID : Tis_SetCameraID ;
  is_SetBayerConversion : Tis_SetBayerConversion ;
  is_SetTestImage : Tis_SetTestImage ;
  is_SetHardwareGamma : Tis_SetHardwareGamma ;
  is_GetCameraList : Tis_GetCameraList ;
  is_SetAOI : Tis_SetAOI ;
  is_SetAutoParameter : Tis_SetAutoParameter ;
  is_GetAutoInfo : Tis_GetAutoInfo ;
  is_SetTriggerDelay : Tis_SetTriggerDelay ;
  is_SetGainBoost : Tis_SetGainBoost ;
  is_SetLED : Tis_SetLED ;
  is_SetGlobalShutter : Tis_SetGlobalShutter ;
  is_SetExtendedRegister : Tis_SetExtendedRegister ;
  is_GetExtendedRegister : Tis_GetExtendedRegister ;
  is_SetHWGainFactor : Tis_SetHWGainFactor ;
  is_Renumerate : Tis_Renumerate ;
  is_SetDisplayMode : Tis_SetDisplayMode ;
  is_GetError : Tis_GetError ;
  is_ImageFormat : Tis_ImageFormat ;
  is_SetColorMode : Tis_SetColorMode ;
  is_AOI : Tis_AOI ;
  is_SetExternalTrigger : Tis_SetExternalTrigger ;

  is_AllocImageMem : Tis_AllocImageMem ;
  is_SetImageMem : Tis_SetImageMem ;
  is_FreeImageMem : Tis_FreeImageMem ;
  is_GetImageMem : Tis_GetImageMem ;
  is_GetActiveImageMem : Tis_GetActiveImageMem ;
  is_InquireImageMem : Tis_InquireImageMem ;
  is_GetImageMemPitch : Tis_GetImageMemPitch ;
  is_SetAllocatedImageMem : Tis_SetAllocatedImageMem ;
  is_SaveImageMem : Tis_SaveImageMem ;
  is_CopyImageMem : Tis_CopyImageMem ;
  is_CopyImageMemLines : Tis_CopyImageMemLines;
  is_AddToSequence : Tis_AddToSequence ;
  is_ClearSequence : Tis_ClearSequence ;
  is_GetActSeqBuf : Tis_GetActSeqBuf ;
  is_LockSeqBuf : Tis_LockSeqBuf ;
  is_UnlockSeqBuf : Tis_UnlockSeqBuf ;
  is_WaitForNextImage : Tis_WaitForNextImage ;
  is_ExitImageQueue : Tis_ExitImageQueue ;
  is_InitImageQueue : Tis_InitImageQueue ;
  is_CaptureVideo : Tis_CaptureVideo ;
  is_SetSensorScaler : Tis_SetSensorScaler ;
  is_Exposure : Tis_Exposure ;
  is_pixelclock : Tis_pixelclock ;
  is_DeviceFeature : Tis_DeviceFeature ;
  tlast : DWORD ;

implementation

uses SESCam ;
procedure ThorLabs_LoadLibrary(
          var Session : TThorLabsSession    // camera session record
          ) ;

{ ---------------------------------------------
  Load camera interface DLL library into memory
  ---------------------------------------------}
const
    LibName = 'uc480.dll' ;
var
    LibFileName : string ;
begin

     Session.LibraryLoaded := False ;

     // Look for DLL initially in Winfluor folder
     LibFileName := {ExtractFilePath(ParamStr(0)) +} LibName ;

     { Load DLL camera interface library }
     Session.LibraryHnd := LoadLibrary( PChar(LibFileName));
     if Session.LibraryHnd <= 0 then begin
        ShowMessage( 'ThorLabs: Unable to open' + LibFileName ) ;
        Exit ;
        end ;

     @is_GetDLLVersion := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetDLLVersion') ;
     @is_Renumerate := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_Renumerate') ;
     @is_SetHWGainFactor := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetHWGainFactor') ;
     @is_GetExtendedRegister := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetExtendedRegister') ;
     @is_SetExtendedRegister := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetExtendedRegister') ;
     @is_SetGlobalShutter := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetGlobalShutter') ;
     @is_SetLED := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetLED') ;
     @is_SetGainBoost := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetGainBoost') ;
     @is_SetTriggerDelay := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetTriggerDelay') ;
     @is_GetAutoInfo := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetAutoInfo') ;
     @is_SetAutoParameter := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetAutoParameter') ;
     @is_SetAOI := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetAOI') ;
     @is_GetCameraList := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetCameraList') ;
     @is_SetHardwareGamma := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetHardwareGamma') ;
     @is_SetTestImage := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetTestImage') ;
     @is_SetBayerConversion := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetBayerConversion') ;
     @is_SetCameraID := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetCameraID') ;
     @is_SetImageAOI := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetImageAOI') ;
     @is_LoadImage := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_LoadImage') ;
     @is_SetFlashDelay := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetFlashDelay') ;
     @is_GetGlobalFlashDelays := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetGlobalFlashDelays') ;
     @is_SaveParameters := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SaveParameters') ;
     @is_LoadParameters := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_LoadParameters') ;
     @is_ResetToDefault := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_ResetToDefault') ;
     @is_SetBinning := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetBinning') ;
     @is_GetBusSpeed := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetBusSpeed') ;
     @is_ForceTrigger := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_ForceTrigger') ;
     @is_SetSubSampling := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetSubSampling') ;
     @is_ResetMemory := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_ResetMemory') ;
     @is_IsMemoryBoardConnected := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_IsMemoryBoardConnected') ;
     @is_GetMemorySequenceWindow := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetMemorySequenceWindow') ;
     @is_GetNumberOfMemoryImages := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetNumberOfMemoryImages') ;
     @is_GetLastMemorySequence := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetLastMemorySequence') ;
     @is_MemoryFreezeVideo := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_MemoryFreezeVideo') ;
     @is_TransferMemorySequence := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_TransferMemorySequence') ;
     @is_TransferImage := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_TransferImage') ;
     @is_SetMemoryMode := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetMemoryMode') ;
     @is_SetBadPixelCorrectionTable := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetBadPixelCorrectionTable') ;
     @is_SaveBadPixelCorrectionTable := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SaveBadPixelCorrectionTable') ;
     @is_LoadBadPixelCorrectionTable := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_LoadBadPixelCorrectionTable') ;
     @is_SetBadPixelCorrection := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetBadPixelCorrection') ;
     @is_SetBlCompensation := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetBlCompensation') ;
     @is_SetColorCorrection := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetColorCorrection') ;
     @is_SetEdgeEnhancement := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetEdgeEnhancement') ;
     @is_GetWhiteBalanceMultipliers := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetWhiteBalanceMultipliers') ;
     @is_SetWhiteBalanceMultipliers := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetWhiteBalanceMultipliers') ;
     @is_SetWhiteBalance := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetWhiteBalance') ;
     @is_SetRenderMode := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetRenderMode') ;
     @is_SetHardwareGain := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetHardwareGain') ;
     @is_EnableMessage := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_EnableMessage') ;
     @is_EnableAutoExit := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_EnableAutoExit') ;
     @is_GetRevisionInfo := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetRevisionInfo') ;
     @is_GetSensorInfo := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetSensorInfo') ;
     @is_SetIOMask := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetIOMask') ;
     @is_GetFramesPerSecond := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetFramesPerSecond') ;
     @is_SetExposureTime := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetExposureTime') ;
     @is_GetExposureRange := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetExposureRange') ;
     @is_SetFrameRate := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetFrameRate') ;
     @is_GetFrameTimeRange := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetFrameTimeRange') ;
     @is_GetUsedBandwidth := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetUsedBandwidth') ;
     @is_SetPixelClock := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetPixelClock') ;
     @is_GetPixelClockRange := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetPixelClockRange') ;
     @is_GetNumberOfCameras := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetNumberOfCameras') ;
     @is_GetCameraType := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetCameraType') ;
     @is_CameraStatus := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_CameraStatus') ;
     @is_GetCameraInfo := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetCameraInfo') ;
     @is_ExitCamera := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_ExitCamera') ;
     @is_InitCamera := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_InitCamera') ;
     @is_SetDisplayMode := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetDisplayMode') ;
     @is_GetError := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetError') ;
     @is_ImageFormat := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_ImageFormat') ;
     @is_SetColorMode := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetColorMode') ;
     @is_AOI := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_AOI') ;
     @is_SetExternalTrigger := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetExternalTrigger') ;

     @is_AllocImageMem := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_AllocImageMem') ;
     @is_SetImageMem := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetImageMem') ;
     @is_FreeImageMem := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_FreeImageMem') ;
     @is_GetImageMem := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetImageMem') ;
     @is_GetActiveImageMem := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetActiveImageMem') ;
     @is_InquireImageMem := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_InquireImageMem') ;
     @is_GetImageMemPitch := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetImageMemPitch') ;
     @is_SetAllocatedImageMem := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetAllocatedImageMem') ;
     @is_SaveImageMem := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SaveImageMem') ;
     @is_CopyImageMem := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_CopyImageMem') ;
     @is_CopyImageMemLines := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_CopyImageMemLines') ;
     @is_AddToSequence := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_AddToSequence') ;
     @is_ClearSequence := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_ClearSequence') ;
     @is_GetActSeqBuf := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_GetActSeqBuf') ;
     @is_LockSeqBuf := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_LockSeqBuf') ;
     @is_UnlockSeqBuf := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_UnlockSeqBuf') ;
     @is_WaitForNextImage := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_WaitForNextImage') ;
     @is_ExitImageQueue := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_ExitImageQueue') ;
     @is_InitImageQueue := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_InitImageQueue') ;
     @is_CaptureVideo := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_CaptureVideo') ;
     @is_SetSensorScaler := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_SetSensorScaler') ;
     @is_Exposure := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_Exposure') ;
     @is_PixelClock := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_PixelClock') ;
     @is_DeviceFeature := ThorLabs_GetDLLAddress(Session.LibraryHnd,'is_DeviceFeature') ;

     Session.LibraryLoaded := True ;

     end ;


function ThorLabs_GetDLLAddress(
         Handle : THandle ;
         const ProcName : string ) : Pointer ;
// -----------------------------------------
// Get address of procedure within DLL
// -----------------------------------------
begin
    Result := GetProcAddress(Handle,PChar(ProcName)) ;
    if Result = Nil then ShowMessage('uc480_Api.dll: ' + ProcName + ' not found') ;
    end ;

function ThorLabs_CheckDLLExists( DLLName : String ) : Boolean ;
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

     // Try to get file from main SDK3 folder
     if not FileExists(Destination) then begin
        Source := SysDrive + '\Program Files\Andor SDK3\' + DLLName ;
        if FileExists(Source) then begin
           CopyFile( PChar(Source), PChar(Destination), False ) ;
           end ;
        end ;

     // Try to get file from SOLIS folder
     if not FileExists(Destination) then begin
        Source := SysDrive + '\Program Files\Andor SOLIS\' + DLLName ;
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


function ThorLabs_OpenCamera(
          var Session : TThorLabsSession ;  // camera session record
          var FrameWidthMax : Integer ;      // Returns camera frame width
          var FrameHeightMax : Integer ;     // Returns camera height width
          var BinFactorMax : Integer ;       // Maximum bin factor
          var NumBytesPerPixel : Integer ;   // Returns bytes/pixel
          var PixelDepth : Integer ;         // Returns no. bits/pixel
          var PixelWidth : Single ;          // Returns pixel size (um)
          CameraInfo : TStringList         // Returns Camera details
          ) : LongBool ;
// ---------------------
// Open Andor camera
// ---------------------
var
    Err : Integer ;
    i,iFormat :Integer ;
    CameraIndex : Integer ;
    wsValue : WideString ;
    iValue : Int64 ;
    dValue : Double ;
    bValue : LongBool ;
    s,sValue : string ;
    BadCode : Integer ;
    Ver,MinVer,MajVer,Build : DWORD ;
    CameraList : TUC480_CAMERA_LIST ;
    NumImageFormats : DWORD ;
    ImageFormats : TIS_Image_Format_List ;
    SensorInfo : TIS_SENSOR_INFO ;
    BinningModes,Bits : Integer ;
    PixelClock : DWORD ;
    DeviceFeatures :DWORD ;
begin

     Result := False ;
     CameraInfo.Clear ;

     // Load DLL libray
     if not Session.LibraryLoaded then ThorLabs_LoadLibrary(Session)  ;
     if not Session.LibraryLoaded then begin
        CameraInfo.Add('Thorlabs DCx: Unable to load uc480.dll') ;
        Exit ;
        end ;

    Ver := is_GetDLLVersion ;
    Build := Ver and $FFFF ;
    Ver := Ver shr 16 ;
    MinVer := Ver and $FF ;
    MajVer := (Ver shr 8)  and $FF ;
    CameraInfo.Add( format('API V%d.%d.(%d)',[MajVer,MinVer,Build]));

    is_GetNumberOfCameras( Session.NumCameras ) ;
    CameraInfo.Add( format('No. of cameras available = %d',[Session.NumCameras]));

    CameraList.NumCameras := Session.NumCameras ;
    is_GetCameraList( @CameraList ) ;
    for i := 0 to Session.NumCameras-1 do begin
      CameraInfo.Add( format('Cam.%d %s (s/n %s)',[i,
                      ANSIString(CameraList.CameraInfo[i].Model),
                      ANSIString(CameraList.CameraInfo[i].SerNo)]));
      end;

     // Initialise camera
     Session.CamHandle := 0 ;
     is_initcamera( Session.CamHandle, 0 ) ;

     // Set to bitmap display mode
     Thorlabs_CheckError( Session.CamHandle, 'is_SetDisplayMode',
     is_SetDisplayMode( Session.CamHandle,IS_SET_DM_DIB )) ;

     Thorlabs_CheckError( Session.CamHandle, 'is_ImageFormat(IMGFRMT_CMD_GET_NUM_ENTRIES)',
     is_ImageFormat(Session.CamHandle, IMGFRMT_CMD_GET_NUM_ENTRIES, @ImageFormats.NumFormats, SizeOf(ImageFormats.NumFormats) ));

     ImageFormats.SizeofListEntry := SizeOf(TIS_IMAGE_FORMAT_INFO);
     //ImageFormats.NumFormats := 4 ;
     Thorlabs_CheckError( Session.CamHandle, 'is_ImageFormat(IMGFRMT_CMD_GET_LIST)',
     is_ImageFormat( Session.CamHandle,
                     IMGFRMT_CMD_GET_LIST,
                     @ImageFormats,
                     24+ImageFormats.NumFormats*SizeOf(TIS_Image_Format_Info) ));

     for i := 0 to ImageFormats.NumFormats-1 do begin
        CameraInfo.Add( format('Image Format.%d %dx%d %s',[i,
                      ImageFormats.FormatInfo[i].Width,
                      ImageFormats.FormatInfo[i].Height,
                      ANSIString(ImageFormats.FormatInfo[i].Name)]));
        end;

     iFormat := 25 ;
 //    Thorlabs_CheckError( Session.CamHandle, 'is_ImageFormat',
 //    is_ImageFormat( Session.CamHandle,
 //                    IMGFRMT_CMD_SET_FORMAT,@iFormat,Sizeof(iFormat)));


     is_GetSensorInfo(Session.CamHandle, @SensorInfo ) ;
     FrameWidthMax := SensorInfo.MaxWidth ;
     FrameHeightMax := SensorInfo.MaxHeight ;
     PixelWidth := SensorInfo.PixelSize*0.01 ;
     s := format('CCD: %d x %d (%.3g um pixels)',[FrameWidthMax,FrameHeightMax,PixelWidth]) ;

     case SensorInfo.ColorMode of
         IS_COLORMODE_MONOCHROME : begin
           // Monochrome cameras
           Thorlabs_CheckError( Session.CamHandle, 'is_SetColorMode',
           is_SetColorMode(Session.CamHandle, IS_CM_MONO8));
           s := s + ' Monochrome' ;
           Session.NumComponentsPerPixel := 1 ;
           Session.UseComponent := 0 ;
           end ;
         else begin
           // Colour cameras
           Thorlabs_CheckError( Session.CamHandle, 'is_SetColorMode',
           is_SetColorMode(Session.CamHandle, IS_CM_UYVY_PACKED));
           s := s + ' Colour' ;
           Session.NumComponentsPerPixel := 4 ;
           Session.UseComponent := 1 ;
           end ;
         end;

     CameraInfo.Add(s) ;


     Session.GainAvailable := SensorInfo.MasterGain ;

     // Binning
     BinningModes := is_SetBinning( Session.CamHandle, IS_GET_SUPPORTED_BINNING ) ;
     Session.NumBinFactors := 0 ;
     Session.BinFactors[Session.NumBinFactors] := 1 ;
     Inc(Session.NumBinFactors) ;
     s := 'Binning Factors: X1' ;
     Bits := IS_BINNING_2X_VERTICAL or IS_BINNING_2X_HORIZONTAL ;
     if (BinningModes and Bits) <> 0 Then begin
        Session.BinFactors[Session.NumBinFactors] := 2 ;
        Session.BinFactorBits[Session.NumBinFactors] := Bits ;
        s := s + ', X2' ;
        Inc(Session.NumBinFactors) ;
        end ;
     Bits := IS_BINNING_3X_VERTICAL or IS_BINNING_3X_HORIZONTAL ;
     if (BinningModes and Bits) <> 0 Then begin
        Session.BinFactors[Session.NumBinFactors] := 3 ;
        Session.BinFactorBits[Session.NumBinFactors] := Bits ;
        s := s + ', X3' ;
        Inc(Session.NumBinFactors) ;
        end ;
     Bits := IS_BINNING_4X_VERTICAL or IS_BINNING_4X_HORIZONTAL ;
     if (BinningModes and Bits) <> 0 Then begin
        Session.BinFactors[Session.NumBinFactors] := 4 ;
        Session.BinFactorBits[Session.NumBinFactors] := Bits ;
        s := s + ', X4' ;
        Inc(Session.NumBinFactors) ;
        end ;
     Bits := IS_BINNING_5X_VERTICAL or IS_BINNING_5X_HORIZONTAL ;
     if (BinningModes and Bits) <> 0 Then begin
        Session.BinFactors[Session.NumBinFactors] := 5 ;
        Session.BinFactorBits[Session.NumBinFactors] := Bits ;
        s := s + ', X5' ;
        Inc(Session.NumBinFactors) ;
        end ;
     Bits := IS_BINNING_6X_VERTICAL or IS_BINNING_6X_HORIZONTAL ;
     if (BinningModes and Bits) <> 0 Then begin
        Session.BinFactors[Session.NumBinFactors] := 6 ;
        Session.BinFactorBits[Session.NumBinFactors] := Bits ;
        s := s + ', X6' ;
        Inc(Session.NumBinFactors) ;
        end ;
     Bits := IS_BINNING_8X_VERTICAL or IS_BINNING_8X_HORIZONTAL ;
     if (BinningModes and Bits) <> 0 Then begin
        Session.BinFactors[Session.NumBinFactors] := 8 ;
        Session.BinFactorBits[Session.NumBinFactors] := Bits ;
        s := s + ', X8' ;
        Inc(Session.NumBinFactors) ;
        end ;
     Bits := IS_BINNING_16X_VERTICAL or IS_BINNING_16X_HORIZONTAL ;
     if (BinningModes and Bits) <> 0 Then begin
        Session.BinFactors[Session.NumBinFactors] := 16 ;
        Session.BinFactorBits[Session.NumBinFactors] := Bits ;
        s := s + ', X16' ;
        Inc(Session.NumBinFactors) ;
        end ;

     CameraInfo.Add(s) ;
     BinFactorMax := Session.NumBinFactors ;

     // Get default pixel clock
     Thorlabs_CheckError( Session.CamHandle, 'is_PixelClock',
     is_PixelClock( Session.CamHandle,is_PixelClock_CMD_GET_DEFAULT,
                    @PixelClock,SizeOf(PixelClock)));
     Thorlabs_CheckError( Session.CamHandle, 'is_PixelClock',
     is_PixelClock( Session.CamHandle,is_PixelClock_CMD_SET,
                    @PixelClock,SizeOf(PixelClock)));
     CameraInfo.Add( format('Pixel Clock: %dMHz',[PixelClock]));


     // Get shutter modes

     Thorlabs_CheckError( Session.CamHandle, 'is_DeviceFeature',
     is_DeviceFeature( Session.CamHandle,
                       IS_DEVICE_FEATURE_CMD_GET_SUPPORTED_FEATURES,
                       @DeviceFeatures,SizeOf(DeviceFeatures)));

     if (DeviceFeatures and IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_ROLLING) <> 0 then begin
        Session.ShutterModes[Session.NumShutterModes] := 'Rolling Shutter' ;
        Session.ShutterModeBit[Session.NumShutterModes] := IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_ROLLING ;
        Inc(Session.NumShutterModes) ;
        end;
     if (DeviceFeatures and IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_GLOBAL) <> 0 then begin
        Session.ShutterModes[Session.NumShutterModes] := 'Global Shutter' ;
        Session.ShutterModeBit[Session.NumShutterModes] := IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_GLOBAL ;
        Inc(Session.NumShutterModes) ;
        end;

     s := 'Shutter modes: ' ;
     for i  := 0 to Session.NumShutterModes-1 do begin
       s := s + Session.ShutterModes[i] ;
       if i < (Session.NumShutterModes-1) then s := s + ', ';
       end;
      CameraInfo.Add( s ) ;

     NumBytesPerPixel := 1 ;
     PixelDepth := 8 ;
     Session.BitsPerPixel := PixelDepth ;
     Session.NumBytesPerPixel := NumBytesPerPixel ;

     Session.CameraOpen := True ;
     Session.CapturingImages := False ;
     Result := Session.CameraOpen ;



     end ;


function ThorLabs_PixelDepth( ADConverterList : TStringList ;
                ADCNum : Integer ) : Integer ;

// ------------------------------------------------
// Determine integer pixel from ADConverter setting
// ------------------------------------------------
var
    BadCode : Integer ;
    s : string ;
begin
    end ;


procedure ThorLabs_SetTemperature(
          var Session : TThorLabsSession ; // Session record
          var TemperatureSetPoint : Single  // Required temperature
          ) ;
// -------------------------------
// Set camera temperature set point
// --------------------------------
var
    TSet,TDiff,MinTDiff : Double ;
    i : Integer ;
    s,TNearest : Widestring ;
    BadCode : Integer ;
begin

     if not Session.CameraOpen then Exit ;


     end ;


procedure ThorLabs_SetCooling(
          var Session : TThorLabsSession ; // Session record
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


procedure ThorLabs_SetBinning(
          var Session : TThorLabsSession ;  // camera session record
          BinFactor : Integer
          ) ;
// ----------------------
// Set CCD binning factor
// ----------------------
var
    i : Integer ;
begin
    for i  := 0 to Session.NumBinFactors-1 do begin
      if Session.BinFactors[i] = BinFactor then begin
         Thorlabs_CheckError( Session.CamHandle, 'is_SetBinning',
         is_SetBinning(Session.CamHandle, Session.BinFactorBits[i]));
         end;
      end;
    end;


procedure ThorLabs_SetFanMode(
          var Session : TThorLabsSession ; // Session record
          FanMode : Integer  // 0 = Off, 1=low, 2=high
          ) ;
// -------------------
// Set camera fan mode
// -------------------
begin
     if not Session.CameraOpen then Exit ;

     end ;


procedure ThorLabs_SetCameraMode(
          var Session : TThorLabsSession ; // Session record
          Mode : Integer ) ;
// --------------------
// Set camera CCD mode
// --------------------
begin
    if not Session.CameraOpen then Exit ;

    end ;


procedure ThorLabs_SetCameraADC(
          var Session : TThorLabsSession ; // Session record
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


    GreyLevelMax := 1 ;
    for i := 1 to PixelDepth do GreyLevelMax := GreyLevelMax*2 ;
    GreyLevelMax := GreyLevelMax - 1 ;
    GreyLevelMin := 0 ;

    end ;


procedure ThorLabs_CloseCamera(
          var Session : TThorLabsSession // Session record
          ) ;
// ----------------
// Shut down camera
// ----------------
begin

    if not Session.CameraOpen then Exit ;

    Thorlabs_CheckError( Session.CamHandle, 'is_exitCamera',
    is_exitCamera( Session.CamHandle )) ;

    // Free DLL library
    if Session.LibraryLoaded then FreeLibrary(Session.libraryHnd) ;
    Session.LibraryLoaded := False ;

    Session.CameraOpen := False ;


    end ;


procedure ThorLabs_GetCameraGainList(
          var Session : TThorLabsSession ; // Session record
          CameraGainList : TStringList
          ) ;
// --------------------------------------------
// Get list of available camera amplifier gains
// --------------------------------------------
var
    i : Integer ;
begin

    CameraGainList.Clear ;
    CameraGainList.Add('n/a') ;
    CameraGainList.Clear ;
    // Gain = 1-100%
    for i := 1 to 100 do CameraGainList.Add( format( '%d%%',[i] )) ;

    end ;

procedure ThorLabs_GetCameraReadoutSpeedList(
          var Session : TThorLabsSession ; // Session record
          CameraReadoutSpeedList : TStringList
          ) ;
// -------------------------------
// Get camera pixel readout speeds
// -------------------------------
begin

     // Get list of available rates
     CameraReadoutSpeedList.Clear ;
     CameraReadoutSpeedList.Add('n/a') ;
     if not Session.CameraOpen then Exit ;

     end ;


procedure ThorLabs_GetCameraModeList(
          var Session : TThorLabsSession ; // Session record
          List : TStringList
          ) ;
// -----------------------------------------
// Return list of available camera CCD mode
// -----------------------------------------
var
    i : Integer ;
begin

     // Get list of available modes
     List.Clear ;
     for i := 0 to Session.NumShutterModes-1 do begin
        List.Add(Session.ShutterModes[i]) ;
        end;

    end ;


procedure ThorLabs_GetCameraADCList(
          var Session : TThorLabsSession ; // Session record
          List : TStringList
          ) ;
// ---------------------------------
// Get list of A/D converter options
// ----------------------------------
begin

     // Get list of available ADCs

    end ;


procedure ThorLabs_CheckROIBoundaries(
          var Session : TThorLabsSession ;  // camera session record
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
// -------------------------------------------------------------
// Check that a valid set of CCD region boundaries have been set
// -------------------------------------------------------------
var
    AOI : TIS_RECT ;
    FW,FH,DivF : Integer ;
begin
    if not Session.CameraOpen then Exit ;

    AOI.s32X := FrameLeft ;
    AOI.s32Y := FrameTop ;
    AOI.s32Width := FrameRight - FrameLeft + 1 ;
    AOI.s32Height := FrameBottom - FrameTop + 1 ;

    BinFactor := Max(BinFactor,1) ;
    DivF := BinFactor ;

    FrameLeft := (FrameLeft div DivF)*DivF ;
    FrameTop := (FrameTop div DivF)*DivF ;
    FW := Max((FrameRight - FrameLeft + 1) div DivF,1)*DivF ;
    FrameRight := FrameLeft + FW - 1 ;
    FH := Max((FrameBottom - FrameTop + 1) div DivF,1)*DivF ;
    FrameBottom := FrameTop + FH - 1 ;

//    is_aoi( Session.CamHandle, IS_AOI_IMAGE_SET_AOI, @AOI, SizeOf(AOI));

 {   // read position back
    is_aoi( Session.CamHandle, IS_AOI_IMAGE_GET_AOI, @AOI, SizeOf(AOI));
    FrameLeft := AOI.s32X ;
    FrameTop := AOI.s32Y ;
    FrameRight := AOI.s32Width + FrameLeft - 1 ;
    FrameBottom := AOI.s32Height + FrameTop - 1 ;}

    FrameWidth := (FrameRight - FrameLeft + 1) div BinFactor ;
    FrameHeight := (FrameBottom - FrameTop + 1) div BinFactor ;

    // Set binning
    Thorlabs_SetBinning( Session, BinFactor ) ;

   end ;


function ThorLabs_BinFactor( BinFactorList : TStringList ;
                Index : Integer ) : Integer ;
// ------------------------------------------------
// Return bin factor from list of available factors
// ------------------------------------------------
var
    s : string ;
    BadCode : Integer ;
begin
     Result := 1 ;
     if BinFactorList.Count > 0 then begin
        Index := Max(Min(Index,BinFactorList.Count-1),0) ;
        s := BinFactorList[Index] ;
        Val(LeftStr(LowerCase(s),Pos('x',s)-1),Result,BadCode) ;
        end ;
     Result := Max(Result,1) ;
     end ;

function ThorLabs_StartCapture(
         var Session : TThorLabsSession ;  // camera session record
         var InterFrameTimeInterval : Double ;      // Frame exposure time
         AdditionalReadoutTime : Double ; // Additional readout time (s)
         AmpGain : Integer ;               // camera amplifier gain index
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
    i : Integer ;
    i64Value : Int64 ;
    dValue,ExposureTime,TRead,ActualFPS : Double ;
    PixelFormat : WideString ;
    OverlapMode : LongBool ;
    AOI : TIS_RECT ;
begin

     Result := False ;
     if not Session.CameraOpen then Exit ;

     // Set shutter mode
     ThorLabs_CheckError( Session.CamHandle, 'is_DeviceFeature',
     is_DeviceFeature( Session.CamHandle,
                       IS_DEVICE_FEATURE_CMD_SET_SHUTTER_MODE,
                       @Session.ShutterModeBit[Session.ShutterMode],
                       SizeOf(Session.ShutterModeBit[Session.ShutterMode]))) ;

    // Set binning
    Thorlabs_SetBinning( Session, BinFactor ) ;

    // Set CCD readout area
    AOI.s32X := FrameLeft ;
    AOI.s32Y := FrameTop ;
    AOI.s32Width := FrameWidth ;
    AOI.s32Height := FrameHeight ;
    ThorLabs_CheckError( Session.CamHandle, 'is_aoi(IS_AOI_IMAGE_SET_AOI)',
    is_aoi( Session.CamHandle, IS_AOI_IMAGE_SET_AOI, @AOI, SizeOf(AOI)));

    ThorLabs_CheckError( Session.CamHandle, 'is_SetSensorScaler',
    is_SetSensorScaler( Session.CamHandle, 0, 1.0 ));

    // Set gain
    ThorLabs_CheckError( Session.CamHandle, 'is_SetHardwareGain',
    is_SetHardwareGain(Session.CamHandle, AmpGain, AmpGain, AmpGain, AmpGain) ) ;

    // Set exposure triggering
    if ExternalTrigger = CamFreeRun then begin
       // Set to free run mode
       ThorLabs_CheckError( Session.CamHandle, 'is_SetExternalTrigger(IS_SET_TRIGGER_SOFTWARE)',
                            is_SetExternalTrigger(Session.CamHandle, IS_SET_TRIGGER_SOFTWARE)) ;

       // Set frame interval
       ThorLabs_CheckError( Session.CamHandle, 'is_SetFrameRate',
       is_SetFrameRate(Session.CamHandle, (1.0/InterFrameTimeInterval), ActualFPS));
        ExposureTime := InterFrameTimeInterval*9500.0 ;
       ThorLabs_CheckError( Session.CamHandle, 'is_Exposure',
       is_Exposure(Session.CamHandle, IS_EXPOSURE_CMD_SET_EXPOSURE,@ExposureTime,SizeOf(ExposureTime)));

       end
    else begin
       // Set to external trigger mode
       ThorLabs_CheckError( Session.CamHandle, 'is_SetExternalTrigger(IS_SET_TRIGGER_LO_HI)',
       is_SetExternalTrigger(Session.CamHandle, IS_SET_TRIGGER_LO_HI)) ;
       end ;

     //
    // Allocate image buffers
    Session.NumFramesInBuffer := Min(NumFramesInBuffer,High(Session.pImageBuf)) ;
    ThorLabs_CheckError( Session.CamHandle, 'is_ClearSequence',
                         is_ClearSequence( Session.CamHandle )) ;
    for i := 0 to Session.NumFramesInBuffer-1 do begin
        // Allocate buffer
        ThorLabs_CheckError( Session.CamHandle, 'is_AllocImageMem',
        is_AllocImageMem( Session.CamHandle,
                          FrameWidth,
                          FrameHeight,
                          Session.BitsPerPixel,
                          Session.pImageBuf[i],
                          Session.ImageBufID[i]));
        // Add to ring buffer
        ThorLabs_CheckError( Session.CamHandle, 'is_AddToSequence',
        is_AddToSequence( Session.CamHandle,
                          Session.pImageBuf[i],
                          Session.ImageBufID[i]));
    {    // Make active
        ThorLabs_CheckError( Session.CamHandle, 'is_SetImageMem',
        is_SetImageMem( Session.CamHandle,
                        Session.pImageBuf[i],
                        Session.ImageBufID[i]));}
        end ;

    // Set into image queue capture mode
    ThorLabs_CheckError( Session.CamHandle, 'is_InitImageQueue',
    is_InitImageQueue(Session.CamHandle,0)) ;

    Session.FrameWidth := FrameWidth div Max(BinFactor,1) ;
    Session.FrameHeight := FrameHeight div Max(BinFactor,1) ;
    Session.NumBytesPerFrame :=  Session.FrameWidth*Session.FrameHeight*Session.NumBytesPerPixel ;

    ThorLabs_CheckError( Session.CamHandle, 'is_GetImageMemPitch',
    is_GetImageMemPitch( Session.CamHandle, Session.NumBytesPerLine));

    is_GetFramesPerSecond(Session.CamHandle, ActualFPS );
    outputdebugstring(pchar(format('Actual FPS = %.3g',[ActualFPS])));

    Session.pFrameBuf := pFrameBuffer ;
    Session.FrameCounter := 0 ;
    Session.ActiveFrameCounter := 0 ;
    Session.CapturingImages := True ;
    tlast := Timegettime ;
    ThorLabs_CheckError( Session.CamHandle, 'is_CaptureVideo',
    is_CaptureVideo(Session.CamHandle, IS_DONT_WAIT )) ;

    Result := True ;

    end;


procedure ThorLabs_UpdateCircularBufferSize(
          var Session : TThorLabsSession  ;  // camera session record
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

     end ;


procedure ThorLabs_Wait( Delay : Single ) ;
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


function ThorLabs_CheckFrameInterval(
          var Session : TThorLabsSession ;   // camera session record
          Var FrameInterval : Double ;
          Var ReadoutTime : Double ) : LongBool ;
// ----------------------------------------
// Check that inter-frame interval is valid
// ----------------------------------------
var
    TMin,TMax,TStep,ActualFPS : Double ;
    TempWidth,TempHeight : Integer ;
begin

     Result := False ;
     if not Session.CameraOpen then Exit ;

     is_GetFrameTimeRange(Session.CamHandle,TMin,TMax,TStep);
     FrameInterval := Round(FrameInterval/TStep)*TStep ;
     FrameInterval := Min(Max(FrameInterval,TMin),TMax) ;
     ReadoutTime := TMin ;

     ThorLabs_CheckError( Session.CamHandle, 'is_SetFrameRate',
     is_SetFrameRate(Session.CamHandle, (1.0/FrameInterval), ActualFPS));
     FrameInterval := 1.0/ActualFPS ;

     Result := True ;

     end ;


procedure ThorLabs_GetImage(
          var Session : TThorLabsSession  // camera session record
          ) ;
// ------------------------------------------------------
// Transfer images from Andor driverbuffer to main buffer
// ------------------------------------------------------
var
    i,j,jStep,NumFramesAcquired,y,iBufNum,imageID,Err : Integer ;
    pImageBuf,pFrom,pTo,pBuf : Pointer ;
    nBytes : NativeInt ;
    t : DWORD ;
    Done : Boolean ;
begin

    if not Session.CameraOpen then Exit ;

    // Get currently active image buffer
{    is_GetActSeqBuf( Session.CamHandle,
                     iBufNum,
                     pActiveImage,
                     pLastActiveImage);}
    //  if is_WaitForNextImage( Session.CamHandle, 0, pImageBuf, imageID) = IS_CAPTURE_STATUS then outputdebugstring(pchar('err'));
tlast := Timegettime ;

    Done := False ;
    while not Done do begin
       Err := is_WaitForNextImage( Session.CamHandle, 0, pImageBuf, imageID) ;
       if Err = IS_CAPTURE_STATUS then begin
          outputdebugstring(pchar('err'));
          Err := is_WaitForNextImage( Session.CamHandle, 0, pImageBuf, imageID) ;
          end;
       if Err = IS_SUCCESS then begin

       nBytes := Session.FrameWidth*Session.NumBytesPerPixel ;
       pBuf := Pointer( NativeUInt(Pbyte(Session.pFrameBuf)) +
                        NativeUInt(Session.NumBytesPerFrame*Session.FrameCounter) ) ;
       for y := 0 to Session.FrameHeight-1 do begin
           pFrom := Pointer( NativeUInt(PByte(pImageBuf)) + NativeUInt(y*Session.NumBytesPerLine) );
           pTo := Pointer( NativeUInt(Pbyte(pBuf)) + NativeUInt(y*nBytes));
           j := Session.UseComponent ;
           jStep := Session.NumBytesPerPixel*Session.NumComponentsPerPixel ;
           //Move( pFrom, pTo, nBytes ) ;
           for i := 0 to nBytes-1 do begin
              PByteArray(pTo)^[i] := PByteArray(pFrom)^[j] ;
              j := j + jStep ;
              end;

          end;

{       outputdebugstring(pchar(format('Frame counter = %d %d %d',
       [Session.FrameCounter,
        NativeUint(pImageBuf),
        NativeUint(Session.pImageBuf[Session.FrameCounter])])));}

       // Unlock queue buffer
       is_UnlockSeqBuf(Session.CamHandle, IS_IGNORE_PARAMETER, pImageBuf) ;

       Inc(Session.FrameCounter) ;
       if Session.FrameCounter >= Session.NumFramesInBuffer then Session.FrameCounter := 0 ;

       end
       else done := True ;
       end ;
t := Timegettime ;

    end ;


procedure ThorLabs_StopCapture(
          var Session : TThorLabsSession   // camera session record
          ) ;
// ------------------
// Stop frame capture
// ------------------
var
    i : Integer ;
begin

    if not Session.CameraOpen then Exit ;
    if not Session.CapturingImages then Exit ;
    Session.CapturingImages := False ;

    // Exit image queue mode
    ThorLabs_CheckError( Session.CamHandle, 'is_ExitImageQueue',
    is_ExitImageQueue(Session.CamHandle)) ;

    // Clear image capture sequence
    ThorLabs_CheckError( Session.CamHandle, 'is_ClearSequence',
    is_ClearSequence( Session.CamHandle )) ;
    for i := 0 to Session.NumFramesInBuffer-1 do begin
        ThorLabs_CheckError( Session.CamHandle, 'is_FreeImageMem',
        is_FreeImageMem( Session.CamHandle,
                         Session.pImageBuf[i],
                         Session.ImageBufID[i]));
        end ;

     end;


procedure ThorLabs_CheckError(
          CamHandle : DWord ;
          FuncName : String ;   // Name of function called
          ErrNum : Integer      // Error # returned by function
          ) ;
// ------------
// Report error
// ------------
var
    ErrMsg : PANSIChar ;
    Err : Integer ;
begin
  //  if ErrNum <> AT_SUCCESS then
  //     ShowMessage(format('%s Err=%d',[FuncName,ErrNum])) ;
    if ErrNum <> IS_SUCCESS then begin
        is_GetError( CamHandle, Err, ErrMsg) ;
        ShowMessage( FuncName + ': ' + ANSIString(ErrMsg)) ;
        end;

    end ;




end.
