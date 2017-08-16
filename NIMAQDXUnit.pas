unit NIMAQDXUnit;
// ----------------------------------------------------------
// National Instruments NIMAQmx image capture library support
// ----------------------------------------------------------
// JD 6.9.10 NIMAQ-DX library
// JD 07.9.10 Working
// JD 13.12.10 BGRA format now detected correctly
// JD 15.12.10 Camera now closed properly when IMAQDX_CameraClose
//             called allowing programs to shut down correctly
// JD 30.07.12 Framewidthmax and Frameheightmax now set correctly by IMAQDX_SetVideoMode
// JD 15.05.13 IMAQDX_SetVideoMode() Top/left of AOI set to 0,0 and biining to 1
//             to ensure that maximum of AOI width and height correctly reported
// 24-7-13 JD Now compiles unders Delphi XE2/3 as well as 7. (tested)
// 25-2-14 JD Camera gain and exposure time can now be set
//         Enum type variables now set correctly.
// 26-2-14 Now handles variable I32/I64/F64 attributes. Basler aca-1300 now working again
// 28-2-14 AdditionReadOutTime option added to StartCap. Note external trigger not tested
// 03-4-14 IMAQDX_GetDLLAddress() Handle changed from Integer to THandle for 64 bit compatibililty
// 09-7-14 IMAQDX_SetVideoMode() and IMAQDX_SetPixelFormat() now trap Session.CameraOpen = false
// 22-7-14 OpenCamera now returns no. of cameras available
//         Camera can be selected when more than one available
// 11-9-14 pointer arithmetic calculation now 64 compatible (NativeUInt rather than Cardinal)
// 12-8-15 Updated to work with Basler ACE
//         Get/SetAttributes and GetAttributeRange() now overloaded procedures
// 09-11-15 Support for Point Grey Grashopper 3 cameras added
//          Min/Max/Incremental steps now checked by IMAQDX_SetAttribute() which is now a function returning value set
// 16-11-15 Support for Mono12 packed formats added
// 08-12-15 Min/max check in IMAQDX_SetAttribute() disabled because Basler camera reporting incorrect values
// 23-10-16 Support for Point Grey Grasshopper camera added
// 02-12-16 CameraAttributes::ImageFormatControl::OffsetX and CameraAttributes::ImageFormatControl::OffsetY
//          now used  to correctly locate X and Y offset for Point Grey Grasshopper cameras
// 02-05-17 StartCapture() In external trigger mode, 0.0005s added to readout time because it is
//          misreported as too short immediately after switching from free run mode with GrassHopper 3.
// 03-05-17 IMAQDX_CheckFrameInterval() Divide by zero avoided when no camera available
// 15-08-17 IMAQDX_SnapImage() added

interface

uses WinTypes,sysutils, classes, dialogs, mmsystem, math, strutils ;

const

   IMAQDX_MAX_API_STRING_LENGTH = 512 ;
//==============================================================================
//  Error Codes Enumeration
//==============================================================================
    IMAQdxErrorSuccess = 0;                   // Success
    IMAQdxErrorSystemMemoryFull = $BFF69000 ;   // Not enough memory
    IMAQdxErrorInternal=1;                        // Internal error
    IMAQdxErrorInvalidParameter=2;                // Invalid parameter                                     enumer
    IMAQdxErrorInvalidPointer=3;                  // Invalid pointer
    IMAQdxErrorInvalidInterface=4;                // Invalid camera session
    IMAQdxErrorInvalidRegistryKey=5;              // Invalid registry key
    IMAQdxErrorInvalidAddress = 6;                  // Invalid address
    IMAQdxErrorInvalidDeviceType = 7;               // Invalid device type
    IMAQdxErrorNotImplemented = 8;                  // Not implemented yet
    IMAQdxErrorCameraNotFound = 9;                  // Camera not found
    IMAQdxErrorCameraInUse = 10;                     // Camera is already in use.
    IMAQdxErrorCameraNotInitialized = 11;            // Camera is not initialized.
    IMAQdxErrorCameraRemoved = 12;                   // Camera has been removed.
    IMAQdxErrorCameraRunning = 13;                   // Acquisition in progress.
    IMAQdxErrorCameraNotRunning = 14;                // No acquisition in progress.
    IMAQdxErrorAttributeNotSupported = 15;           // Attribute not supported by the camera.
    IMAQdxErrorAttributeNotSettable = 16;            // Unable to set attribute.
    IMAQdxErrorAttributeNotReadable = 17;            // Unable to get attribute.
    IMAQdxErrorAttributeOutOfRange = 18;             // Attribute value is out of range.
    IMAQdxErrorBufferNotAvailable = 19;              // Requested buffer is unavailable.

    IMAQdxErrorBufferListEmpty = 20;                 // Buffer list is empty. Add one or more buffers.
    IMAQdxErrorBufferListLocked = 21;                // Buffer list is already locked. Reconfigure acquisition and try again.
    IMAQdxErrorBufferListNotLocked = 22;             // No buffer list. Reconfigure acquisition and try again.
    IMAQdxErrorResourcesAllocated = 23;              // Transfer engine resources already allocated. Reconfigure acquisition and try again.
    IMAQdxErrorResourcesUnavailable = 24;            // Insufficient transfer engine resources.
    IMAQdxErrorAsyncWrite = 25;                      // Unable to perform asychronous register write.
    IMAQdxErrorAsyncRead = 26;                       // Unable to perform asychronous register read.
    IMAQdxErrorTimeout = 27;                         // Timeout
    IMAQdxErrorBusReset = 28;                        // Bus reset occurred during a transaction.
    IMAQdxErrorInvalidXML = 29;                      // Unable to load camera's XML file.
    IMAQdxErrorFileAccess = 30;                      // Unable to read/write to file.
    IMAQdxErrorInvalidCameraURLString = 31;          // Camera has malformed URL string.
    IMAQdxErrorInvalidCameraFile = 32;               // Invalid camera file.
    IMAQdxErrorGenICamError = 33;                    // Unknown Genicam error.
    IMAQdxErrorFormat7Parameters = 34;               // For format 7: The combination of speed = ; image position = ; image size = ; and color coding is incorrect.
    IMAQdxErrorInvalidAttributeType = 35;            // The attribute type is not compatible with the passed variable type.
    IMAQdxErrorDLLNotFound = 36;                     // The DLL could not be found.
    IMAQdxErrorFunctionNotFound = 37;                // The function could not be found.
    IMAQdxErrorLicenseNotActivated = 38;             // License not activated.
    IMAQdxErrorCameraNotConfiguredForListener = 39;  // The camera is not configured properly to support a listener.
    IMAQdxErrorCameraMulticastNotAvailable = 40;     // Unable to configure the system for multicast support.
    IMAQdxErrorBufferHasLostPackets = 41;            // The requested buffer has lost packets and the user requested an error to be generated.
    IMAQdxErrorGiGEVisionError = 42;                 // Unknown GiGE Vision error.
    IMAQdxErrorNetworkError = 43;                    // Unknown network error.
    IMAQdxErrorCameraUnreachable = 44;               // Unable to connect to the camera
    IMAQdxErrorHighPerformanceNotSupported = 45;     // High performance acquisition is not supported on the specified network interface. Connect the camera to a network interface running the high performance driver.
    IMAQdxErrorInterfaceNotRenamed = 46;             // Unable to rename interface. Invalid or duplicate name specified.
    IMAQdxErrorNoSupportedVideoModes = 47;           // The camera does not have any video modes which are supported
    IMAQdxErrorSoftwareTriggerOverrun = 48;          // Software trigger overrun
    IMAQdxErrorTestPacketNotReceived = 49;           // The system did not receive a test packet from the camera. The packet size may be too large for the network configuration or a firewall may be enabled.
    IMAQdxErrorCorruptedImageReceived = 50;          // The camera returned a corrupted image
    IMAQdxErrorCameraConfigurationHasChanged = 51;   // The camera did not return an image of the correct type it was configured for previously
    IMAQdxErrorCameraInvalidAuthentication = 52;     // The camera is configured with password authentication and either the user name and password were not configured or they are incorrect
    IMAQdxErrorUnknownHTTPError = 53;                // The camera returned an unknown HTTP error
    IMAQdxErrorGuard  = $FFFFFFFF ;


//==============================================================================
//  Bus Type Enumeration
//==============================================================================
    IMAQdxBusTypeFireWire = $31333934;
    IMAQdxBusTypeEthernet = $69707634;
    IMAQdxBusTypeSimulator = $2073696D;
    IMAQdxBusTypeDirectShow = $64736877;
    IMAQdxBusTypeIP = $4950636D;
    IMAQdxBusTypeGuard = $FFFFFFFF;

//==============================================================================
//  Camera Control Mode Enumeration
//==============================================================================
    IMAQdxCameraControlModeController = 0 ;
    IMAQdxCameraControlModeListener = 1 ;
    IMAQdxCameraControlModeGuard = $FFFFFFFF ;

//==============================================================================
//  Buffer Number Mode Enumeration
//==============================================================================
    IMAQdxBufferNumberModeNext = 0 ;
    IMAQdxBufferNumberModeLast = 1 ;
    IMAQdxBufferNumberModeBufferNumber = 2 ;
    IMAQdxBufferNumberModeGuard = $FFFFFFFF ;

//==============================================================================
//  Plug n Play Event Enumeration
//==============================================================================
    IMAQdxPnpEventCameraAttached = 0 ;
    IMAQdxPnpEventCameraDetached = 1 ;
    IMAQdxPnpEventBusReset = 2 ;
    IMAQdxPnpEventGuard = $FFFFFFFF ;

//==============================================================================
//  Bayer Pattern Enumeration
//==============================================================================
    IMAQdxBayerPatternNone = 0;
    IMAQdxBayerPatternGB = 1;
    IMAQdxBayerPatternGR = 2;
    IMAQdxBayerPatternBG = 3;
    IMAQdxBayerPatternRG = 4;
    IMAQdxBayerPatternHardware = 5;
    IMAQdxBayerPatternGuard = $FFFFFFFF ;

//==============================================================================
//  Controller Destination Mode Enumeration
//==============================================================================
    IMAQdxDestinationModeUnicast = 0;
    IMAQdxDestinationModeBroadcast = 1;
    IMAQdxDestinationModeMulticast = 2;
    IMAQdxDestinationModeGuard = $FFFFFFFF ;

//==============================================================================
//   Attribute Type Enumeration
//==============================================================================
    IMAQdxAttributeTypeU32 = 0;
    IMAQdxAttributeTypeI64 = 1;
    IMAQdxAttributeTypeF64 = 2;
    IMAQdxAttributeTypeString = 3;
    IMAQdxAttributeTypeEnum = 4;
    IMAQdxAttributeTypeBool = 5;
    IMAQdxAttributeTypeCommand = 6;
    IMAQdxAttributeTypeBlob = 7;  //Internal Use Only
    IMAQdxAttributeTypeGuard = $FFFFFFFF ;

//==============================================================================
//  Value Type Enumeration
//==============================================================================
    IMAQdxValueTypeU32 = 0;
    IMAQdxValueTypeI64 = 1;
    IMAQdxValueTypeF64 = 2;
    IMAQdxValueTypeString = 3;
    IMAQdxValueTypeEnumItem = 4;
    IMAQdxValueTypeBool = 5;
    IMAQdxValueTypeDisposableString = 6;
    IMAQdxValueTypeGuard = $FFFFFFFF ;

//==============================================================================
//  Interface File Flags Enumeration
//==============================================================================
    IMAQdxInterfaceFileFlagsConnected = 1 ;
    IMAQdxInterfaceFileFlagsDirty = 2 ;
    IMAQdxInterfaceFileFlagsGuard = $FFFFFFFF ;

//==============================================================================
//  Overwrite Mode Enumeration
//==============================================================================
    IMAQdxOverwriteModeGetOldest = 0 ;
    IMAQdxOverwriteModeFail = 2 ;
    IMAQdxOverwriteModeGetNewest = 3 ;
    IMAQdxOverwriteModeGuard = $FFFFFFFF ;

//==============================================================================
//  Lost Packet Mode Enumeration
//==============================================================================
    IMAQdxLostPacketModeIgnore = 0;
    IMAQdxLostPacketModeFail = 1;
    IMAQdxLostPacketModeGuard = $FFFFFFFF ;

//==============================================================================
//  Attribute Visibility Enumeration
//==============================================================================
    IMAQdxAttributeVisibilitySimple = $00001000 ;
    IMAQdxAttributeVisibilityIntermediate = $00002000 ;
    IMAQdxAttributeVisibilityAdvanced = $00004000 ;
    IMAQdxAttributeVisibilityGuard = $FFFFFFFF ;

//==============================================================================
//  Stream Channel Mode Enumeration
//==============================================================================
    IMAQdxStreamChannelModeAutomatic = 0;
    IMAQdxStreamChannelModeManual = 1;
    IMAQdxStreamChannelModeGuard = $FFFFFFFF ;

//==============================================================================
//  Pixel Signedness Enumeration
//==============================================================================
    IMAQdxPixelSignednessUnsigned = 0;
    IMAQdxPixelSignednessSigned = 1;
    IMAQdxPixelSignednessHardware = 2;
    IMAQdxPixelSignednessGuard = $FFFFFFFF ;

//==============================================================================
//  Attributes
//==============================================================================
      IMAQdxAttributeBaseAddress =              'CameraInformation::BaseAddress'         ; // Read only. Gets the base address of the camera registers.
      IMAQdxAttributeBusType =                  'CameraInformation::BusType'             ; // Read only. Gets the bus type of the camera.
      IMAQdxAttributeModelName =                'CameraInformation::ModelName'           ; // Read only. Returns the model name.
      IMAQdxAttributeSerialNumberHigh =         'CameraInformation::SerialNumberHigh'    ; // Read only. Gets the upper 32-bits of the camera 64-bit serial number.
      IMAQdxAttributeSerialNumberLow =          'CameraInformation::SerialNumberLow'     ; // Read only. Gets the lower 32-bits of the camera 64-bit serial number.
      IMAQdxAttributeVendorName =               'CameraInformation::VendorName'          ; // Read only. Returns the vendor name.
      IMAQdxAttributeHostIPAddress =            'CameraInformation::HostIPAddress'       ; // Read only. Returns the host adapter IP address.
      IMAQdxAttributeIPAddress =                'CameraInformation::IPAddress'           ; // Read only. Returns the IP address.
      IMAQdxAttributePrimaryURLString =         'CameraInformation::PrimaryURLString'    ; // Read only. Gets the camera's primary URL string.
      IMAQdxAttributeSecondaryURLString =       'CameraInformation::SecondaryURLString'  ; // Read only. Gets the camera's secondary URL string.
      IMAQdxAttributeAcqInProgress =             'StatusInformation::AcqInProgress'       ; // Read only. Gets the current state of the acquisition. TRUE if acquiring; otherwise FALSE.
      IMAQdxAttributeLastBufferCount =          'StatusInformation::LastBufferCount'     ; // Read only. Gets the number of transferred buffers.
      IMAQdxAttributeLastBufferNumber =         'StatusInformation::LastBufferNumber'    ; // Read only. Gets the last cumulative buffer number transferred.
      IMAQdxAttributeLostBufferCount =          'StatusInformation::LostBufferCount'     ; // Read only. Gets the number of lost buffers during an acquisition session.
      IMAQdxAttributeLostPacketCount =          'StatusInformation::LostPacketCount'     ; // Read only. Gets the number of lost packets during an acquisition session.
      IMAQdxAttributeRequestedResendPackets =   'StatusInformation::RequestedResendPacketCount' ; // Read only. Gets the number of packets requested to be resent during an acquisition session.
      IMAQdxAttributeReceivedResendPackets =    'StatusInformation::ReceivedResendPackets' ; // Read only. Gets the number of packets that were requested to be resent during an acquisition session and were completed.
      IMAQdxAttributeHandledEventCount =        'StatusInformation::HandledEventCount'   ; // Read only. Gets the number of handled events during an acquisition session.
      IMAQdxAttributeLostEventCount =           'StatusInformation::LostEventCount'      ; // Read only. Gets the number of lost events during an acquisition session.
      IMAQdxAttributeBayerGainB =               'AcquisitionAttributes::Bayer::GainB'    ; // Sets/gets the white balance gain for the blue component of the Bayer conversion.
      IMAQdxAttributeBayerGainG=                'AcquisitionAttributes::Bayer::GainG'    ; // Sets/gets the white balance gain for the green component of the Bayer conversion.
      IMAQdxAttributeBayerGainR=                'AcquisitionAttributes::Bayer::GainR'    ; // Sets/gets the white balance gain for the red component of the Bayer conversion.
      IMAQdxAttributeBayerPattern=              'AcquisitionAttributes::Bayer::Pattern'  ; // Sets/gets the Bayer pattern to use.
      IMAQdxAttributeStreamChannelMode=         'AcquisitionAttributes::Controller::StreamChannelMode' ; // Gets/sets the mode for allocating a FireWire stream channel.
      IMAQdxAttributeDesiredStreamChannel=      'AcquisitionAttributes::Controller::DesiredStreamChannel' ; // Gets/sets the stream channel to manually allocate.
      IMAQdxAttributeFrameInterval=             'AcquisitionAttributes::FrameInterval'   ; // Read only. Gets the duration in milliseconds between successive frames.
      IMAQdxAttributeIgnoreFirstFrame=          'AcquisitionAttributes::IgnoreFirstFrame' ; // Gets/sets the video delay of one frame between starting the camera and receiving the video feed.
      IMAQdxAttributeOffsetX=                   'AcquisitionAttributes::OffsetX'                                ; // Gets/sets the left offset of the image.
      IMAQdxAttributeOffsetY=                   'AcquisitionAttributes::OffsetY'                                ; // Gets/sets the top offset of the image.
      IMAQdxAttributeWidth=                     'AcquisitionAttributes::Width'                                  ; // Gets/sets the width of the image.
      IMAQdxAttributeHeight=                    'AcquisitionAttributes::Height'                                 ; // Gets/sets the height of the image.
      IMAQdxAttributePixelFormat=               'PixelFormat'                            ; // Gets/sets the pixel format of the source sensor.
      IMAQdxAttributePacketSize=                'PacketSize'                             ; // Gets/sets the packet size in bytes.
      IMAQdxAttributePayloadSize=               'PayloadSize'                            ; // Gets/sets the frame size in bytes.
      IMAQdxAttributeSpeed=                     'AcquisitionAttributes::Speed'           ; // Gets/sets the transfer speed in Mbps for a FireWire packet.
      IMAQdxAttributeShiftPixelBits=            'AcquisitionAttributes::ShiftPixelBits'  ; // Gets/sets the alignment of 16-bit cameras. Downshift the pixel bits if the camera returns most significant bit-aligned data.
      IMAQdxAttributeSwapPixelBytes=            'AcquisitionAttributes::SwapPixelBytes'  ; // Gets/sets the endianness of 16-bit cameras. Swap the pixel bytes if the camera returns little endian data.
      IMAQdxAttributeOverwriteMode=             'AcquisitionAttributes::OverwriteMode'   ; // Gets/sets the overwrite mode, used to determine acquisition when an image transfer cannot be completed due to an overwritten internal buffer.
      IMAQdxAttributeTimeout=                   'AcquisitionAttributes::Timeout'         ; // Gets/sets the timeout value in milliseconds, used to abort an acquisition when the image transfer cannot be completed within the delay.
      IMAQdxAttributeVideoMode=                 'AcquisitionAttributes::VideoMode'       ; // Gets/sets the video mode for a camera.
      IMAQdxAttributeBitsPerPixel=              'AcquisitionAttributes::BitsPerPixel'    ; // Gets/sets the actual bits per pixel. For 16-bit components, this represents the actual bit depth (10-, 12-, 14-, or 16-bit).
      IMAQdxAttributePixelSignedness=           'AcquisitionAttributes::PixelSignedness' ; // Gets/sets the signedness of the pixel. For 16-bit components, this represents the actual pixel signedness (Signed, or Unsigned).
      IMAQdxAttributeReserveDualPackets=        'AcquisitionAttributes::ReserveDualPackets' ; // Gets/sets if dual packets will be reserved for a very large FireWire packet.
      IMAQdxAttributeReceiveTimestampMode=      'AcquisitionAttributes::ReceiveTimestampMode' ; // Gets/sets the mode for timestamping images received by the driver.
      IMAQdxAttributeActualPeakBandwidth=       'AcquisitionAttributes::AdvancedEthernet::BandwidthControl::ActualPeakBandwidth' ; // Read only. Returns the actual maximum peak bandwidth the camera will be configured to use.
      IMAQdxAttributeDesiredPeakBandwidth=      'AcquisitionAttributes::AdvancedEthernet::BandwidthControl::DesiredPeakBandwidth' ; // Gets/sets the desired maximum peak bandwidth the camera should use.
      IMAQdxAttributeDestinationMode=           'AcquisitionAttributes::AdvancedEthernet::Controller::DestinationMode' ; // Gets/Sets where the camera is instructed to send the image stream.
      IMAQdxAttributeDestinationMulticastAddress= 'AcquisitionAttributes::AdvancedEthernet::Controller::DestinationMulticastAddress' ; // Gets/Sets the multicast address the camera should send data in multicast mode.
      IMAQdxAttributeEventsEnabled=             'AcquisitionAttributes::AdvancedEthernet::EventParameters::EventsEnabled' ; // Gets/Sets if events will be handled.
      IMAQdxAttributeMaxOutstandingEvents=      'AcquisitionAttributes::AdvancedEthernet::EventParameters::MaxOutstandingEvents' ; // Gets/Sets the maximum number of outstanding events to queue.
      IMAQdxAttributeTestPacketEnabled=         'AcquisitionAttributes::AdvancedEthernet::TestPacketParameters::TestPacketEnabled' ; // Gets/Sets whether the driver will validate the image streaming settings using test packets prior to an acquisition
      IMAQdxAttributeTestPacketTimeout=         'AcquisitionAttributes::AdvancedEthernet::TestPacketParameters::TestPacketTimeout' ; // Gets/Sets the timeout for validating test packet reception (if enabled)
      IMAQdxAttributeMaxTestPacketRetries=      'AcquisitionAttributes::AdvancedEthernet::TestPacketParameters::MaxTestPacketRetries' ; // Gets/Sets the number of retries for validating test packet reception (if enabled)
      IMAQdxAttributeLostPacketMode=            'AcquisitionAttributes::AdvancedEthernet::LostPacketMode' ; // Gets/sets the behavior when the user extracts a buffer that has missing packets.
      IMAQdxAttributeMemoryWindowSize=          'AcquisitionAttributes::AdvancedEthernet::ResendParameters::MemoryWindowSize' ; // Gets/sets the size of the memory window of the camera in kilobytes. Should match the camera's internal buffer size.
      IMAQdxAttributeResendsEnabled=            'AcquisitionAttributes::AdvancedEthernet::ResendParameters::ResendsEnabled' ; // Gets/sets if resends will be issued for missing packets.
      IMAQdxAttributeResendThresholdPercentage= 'AcquisitionAttributes::AdvancedEthernet::ResendParameters::ResendThresholdPercentage' ; // Gets/sets the threshold of the packet processing window that will trigger packets to be resent.
      IMAQdxAttributeResendBatchingPercentage=  'AcquisitionAttributes::AdvancedEthernet::ResendParameters::ResendBatchingPercentage' ; // Gets/sets the percent of the packet resend threshold that will be issued as one group past the initial threshold sent in a single request.
      IMAQdxAttributeMaxResendsPerPacket=       'AcquisitionAttributes::AdvancedEthernet::ResendParameters::MaxResendsPerPacket' ; // Gets/sets the maximum number of resend requests that will be issued for a missing packet.
      IMAQdxAttributeResendResponseTimeout=     'AcquisitionAttributes::AdvancedEthernet::ResendParameters::ResendResponseTimeout' ; // Gets/sets the time to wait for a resend request to be satisfied before sending another.
      IMAQdxAttributeNewPacketTimeout=          'AcquisitionAttributes::AdvancedEthernet::ResendParameters::NewPacketTimeout' ; // Gets/sets the time to wait for new packets to arrive in a partially completed image before assuming the rest of the image was lost.
      IMAQdxAttributeMissingPacketTimeou=      'AcquisitionAttributes::AdvancedEthernet::ResendParameters::MissingPacketTimeout' ; // Gets/sets the time to wait for a missing packet before issuing a resend.
      IMAQdxAttributeResendTimerResolution=     'AcquisitionAttributes::AdvancedEthernet::ResendParameters::ResendTimerResolution' ; // Gets/sets the resolution of the packet processing system that is used for all packet-related timeouts.

      IMAQdxAttributeAOIBinningHorizontal = 'CameraAttributes::AOI::BinningHorizontal';
      IMAQdxAttributeAOIBinningVertical = 'CameraAttributes::AOI::BinningVertical';
      IMAQdxAttributeAOICenterX = 'CameraAttributes::AOI::CenterX';
      IMAQdxAttributeAOICenterY = 'CameraAttributes::AOI::CenterY';
      IMAQdxAttributeAOIHeight = 'CameraAttributes::AOI::Height';
      IMAQdxAttributeAOIOffsetX = 'CameraAttributes::AOI::OffsetX';
      IMAQdxAttributeAOIOffsetY = 'CameraAttributes::AOI::OffsetY';
      IMAQdxAttributeAOIWidth = 'CameraAttributes::AOI::Width';

      IMAQdxAttributeImageFormatPixelColorFilter = 'CameraAttributes::ImageFormat::PixelColorFilter';
      IMAQdxAttributeImageFormatPixelDynamicRangeMax = 'CameraAttributes::ImageFormat::PixelDynamicRangeMax';
      IMAQdxAttributeImageFormatPixelDynamicRangeMin = 'CameraAttributes::ImageFormat::PixelDynamicRangeMin';
      IMAQdxAttributeImageFormatPixelFormat = 'CameraAttributes::ImageFormat::PixelFormat';
      IMAQdxAttributeImageFormatPixelSize = 'CameraAttributes::ImageFormat::PixelSize';
      IMAQdxAttributeImageFormatReverseX = 'CameraAttributes::ImageFormat::ReverseX';
      IMAQdxAttributeImageFormatTestImageSelector = 'CameraAttributes::ImageFormat::TestImageSelector';




//==============================================================================
//  Camera Information Structure
//==============================================================================

Type

    TIMAQdxCameraInformation = packed Record
        IType : DWord ;
        Version : DWord ;
        Flags : DWord ;
        SerialNumberHi : DWord ;
        SerialNumberLo : DWord ;
        IMAQdxBusType : DWord ;
        InterfaceName : Array[0..IMAQDX_MAX_API_STRING_LENGTH-1] of ANSIChar ;
        VendorName : Array[0..IMAQDX_MAX_API_STRING_LENGTH-1] of ANSIChar ;
        ModelName : Array[0..IMAQDX_MAX_API_STRING_LENGTH-1] of ANSIChar ;
        CameraFileName : Array[0..IMAQDX_MAX_API_STRING_LENGTH-1] of ANSIChar ;
        CameraAttributeURL : Array[0..IMAQDX_MAX_API_STRING_LENGTH-1] of ANSIChar ;
        end ;

//==============================================================================
//  Attribute Information Structure
//==============================================================================
    TIMAQdxAttributeInformation= packed record
       iType : DWord ;
       Readable : LongBool ;
       Writable : LongBool ;
       Name : Array[0..IMAQDX_MAX_API_STRING_LENGTH-1] of ANSIChar ;
       end ;

//==============================================================================
//  Enumeration Item Structure
//==============================================================================
    TIMAQdxEnumItem = packed record
       Value : DWord ;
       Reserved : DWord ;
       Name : Array[0..IMAQDX_MAX_API_STRING_LENGTH-1] of ANSIChar ;
       end ;



 TIMAQDXSession = packed record
    ID : Integer ;
    CameraOpen : Boolean ;
    SelectedCamera : Integer ;
    AcquisitionInProgress : Boolean ;
    NumFramesInBuffer : Integer ;
    FrameBufPointer : Pointer ;
    NumBytesPerFrame : Integer ;
    NumPixelComponents : Integer ;
    NumBytesPerComponent : Integer ;
    MonochromeImage : Boolean ;
    UseComponent : Integer ;
    FrameCounter : Integer ;
    BufferIndex : Integer ;
    CameraInfo : Array [0..9] of TIMAQdxCameraInformation ;
    Attributes : Array[0..999] of TIMAQdxAttributeInformation ;
    PixelSettings : Array[0..31] of TIMAQdxEnumItem ;
    CameraNames : Array [0..9] of string ;
    NumPixelSettings : Cardinal ;
    NumAttributes : Cardinal ;
    NumCameras : Cardinal ;
    VideoMode : Integer ;
    VideoModes : Array[0..255] of TIMAQdxEnumItem ;
    NumVideoModes : Cardinal ;
    PixelFormat : Integer ;
    PixelFormatType : Integer ;
    PixelFormats : Array[0..255] of TIMAQdxEnumItem ;
    NumPixelFormats : Cardinal ;
    CurrentVideoMode : Cardinal ;
    FrameWidthMax : Integer ;
    FrameHeightMax : Integer ;
    FrameLeft : Integer ;
    FrameTop : Integer ;
    FrameWidth : Integer ;
    FrameHeight : Integer ;
    PixelDepth : Integer ;
    GreyLevelMin : Integer ;
    GreyLevelMax : Integer ;
    Buf : PByteArray ;
    BufSize : Integer ;
    AttrHeightMax : Integer ;
    AttrWidthMax : Integer ;
    AttrHeight : Integer ;
    AttrWidth : Integer ;
    AttrXOffset : Integer ;
    AttrYOffset : Integer ;
    AttrXBin : Integer ;
    AttrYBin : Integer ;
    AttrPixelFormat : Integer ;
    AttrPixelSize : Integer ;
    AttrBitsPerPixel : Integer ;
    AttrVideoMode : Integer ;
    AttrExposureTime : Integer ;
    AttrExposureMode : Integer ;
    AttrExposureAuto : Integer ;
    AttrPgrExposureCompensationAuto : Integer ;
    AttrAcquisitionFrameRateEnabled : Integer ;
    AttrAcquisitionFrameRate : Integer ;
    AttrAcquisitionFrameRateAuto : Integer ;
    AttrLastBufferNumber : Integer ;
    AttrLastBufferCount : Integer ;
    AttrAcqInProgress : Integer ;
    AttrTriggerMode : Integer ;
    AttrTriggerSelector : Integer ;
    AttrTriggerSource : Integer ;
    AttrTriggerActivation : Integer ;
    AttrGain : Integer ;
    AttrGainMode : Integer ;
    AttrGainAuto : Integer ;
    AttrPacketSize : Integer ;
    GainMin : Integer ;
    GainMax : Integer ;
    AOIAvailable : Boolean ;
    SingleImage : Boolean ;
    end ;



//==============================================================================
//  Camera File Structure
//==============================================================================
    TIMAQdxCameraFile= packed record
      iType : DWord ;
      Version : DWord ;
      FileName : Array[0..IMAQDX_MAX_API_STRING_LENGTH-1] of ANSIChar ;
      end ;




//==============================================================================
//  Camera Information Structure
//==============================================================================
//typedef IMAQdxEnumItem IMAQdxVideoMode;


//==============================================================================
//  Callbacks
//==============================================================================
//typedef     uInt32 (NI_FUNC *FrameDoneEventCallbackPtr)(IMAQdxSession id, uInt32 bufferNumber, void* callbackData);
//typedef     uInt32 (NI_FUNC *PnpEventCallbackPtr)(IMAQdxSession id, IMAQdxPnpEvent pnpEvent, void* callbackData);
//typedef     void (NI_FUNC *AttributeUpdatedEventCallbackPtr)(IMAQdxSession id, const char* name, void* callbackData);



//==============================================================================
//  Functions
//==============================================================================
     TIMAQdxSnap= function(
       SessionID : Integer ;
       pImage : Pointer ) : Integer ; stdcall ;

     TIMAQdxConfigureGrab= function(
       SessionID : Integer ) : Integer ; stdcall ;

     TIMAQdxGrab= function(
       SessionID : Integer ;
       pImage : Pointer ;
       waitForNextBuffer : LongBool ;
       var actualBufferNumber : Cardinal ) : Integer ; stdcall ;

     TIMAQdxSequence= function(
        SessionID : Integer ;
        pImages : Pointer ;
        Count : Cardinal ) : Integer ; stdcall ;

     TIMAQdxDiscoverEthernetCameras= function(
         Address : PANSIChar ;
         Timeout : Cardinal
         ) : Integer ; stdcall ;

     TIMAQdxEnumerateCameras= function(
        pIMAQdxCameraInformation : Pointer ;
        var Count : Cardinal ;
        ConnectedOnly : LongBool ) : Integer ; stdcall ; //

     TIMAQdxResetCamera= function(
          Name : PANSIChar ;
          ResetAll  : LongBool) : Integer ; stdcall ; //

     TIMAQdxOpenCamera= function(
          Name : PANSIChar ;
          Mode : DWord ;
          var SessionID : Integer  ) : Integer ; stdcall ; //

     TIMAQdxCloseCamera= function(
          SessionID : Integer ) : Integer ; stdcall ; //

     TIMAQdxConfigureAcquisition= function(
          SessionID : Integer ;
          Continuous : Cardinal ;
          BufferCount : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxStartAcquisition= function(
          SessionID : Integer ) : Integer ; stdcall ; //

     TIMAQdxGetImage= function(
          SessionID : Integer ;
          pImage : Pointer ;
          BufferNumberMode : Cardinal ;
          DesiredBufferNumber : Cardinal ;
          var ActualBufferNumber : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxGetImageData= function(
         SessionID : Integer ;
         pBuffer : Pointer ;
         BufferSize : Cardinal ;
         BufferNumberMode  : Cardinal ;
         DesiredBufferNumber : Cardinal ;
         var ActualBufferNumber : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxStopAcquisition= function(
         SessionID : Integer ) : Integer ; stdcall ; //

     TIMAQdxUnconfigureAcquisition= function(
         SessionID : Integer ) : Integer ; stdcall ; //

     TIMAQdxEnumerateVideoModes= function(
         SessionID : Integer ;
         pVideoMode : Pointer ;
         var Count : Cardinal ;
         var currentMode  : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxEnumerateAttributes= function(
         SessionID : Integer ;
         pAttributeInformation : Pointer ;
         var count : Cardinal ;
         Root : PANSIChar ) : Integer ; stdcall ; //

     TIMAQdxGetAttribute= function(
         SessionID : Integer ;
         Name : PANSIChar ;
         ValueType : Cardinal ;
         pValue : Pointer ) : Integer ; stdcall ; //

     TIMAQdxSetAttributeI32= function(
         SessionID : Integer ;
         Name : PANSIChar ;
         ValueType : Cardinal ;
         Value : Integer ) : Integer ; cdecl ; //

     TIMAQdxSetAttributeI64= function(
         SessionID : Integer ;
         Name : PANSIChar ;
         ValueType : Cardinal ;
         Value : Int64 ) : Integer ; cdecl ; //

     TIMAQdxSetAttributeF64= function(
         SessionID : Integer ;
         const Name : PANSIChar ;
         ValueType : Cardinal ;
         Value : Double ) : Integer ; cdecl ; //

     TIMAQdxSetAttributeEnum= function(
         SessionID : Integer ;
         Name : PANSIChar ;
         ValueType : Cardinal ;
         Value : TIMAQdxEnumItem ) : Integer ; cdecl ; //

     TIMAQdxSetAttributeBool= function(
         SessionID : Integer ;
         Name : PANSIChar ;
         ValueType : Cardinal ;
         Value : LongBool ) : Integer ; cdecl ; //

     TIMAQdxGetAttributeMinimum= function(
         SessionID : Integer ;
         Name : PANSIChar ;
         ValueType : Cardinal ;
         pValue : Pointer ) : Integer ; stdcall ; //

     TIMAQdxGetAttributeMaximum= function(
         SessionID : Integer ;
         Name : PANSIChar ;
         ValueType : Cardinal ;
         pValue : Pointer ) : Integer ; stdcall ; //

     TIMAQdxGetAttributeIncrement= function(
         SessionID : Integer ;
         Name : PANSIChar ;
         ValueType : Cardinal ;
         pValue : Pointer ) : Integer ; stdcall ; //

     TIMAQdxGetAttributeType= function(
         SessionID : Integer ;
         Name : PANSIChar ;
         var AttributeType : Cardinal) : Integer ; stdcall ; //

     TIMAQdxIsAttributeReadable= function(
        SessionID : Integer ;
        Name : PANSIChar ;
        var Readable : LongBool ) : Integer ; stdcall ; //

     TIMAQdxIsAttributeWritable= function(
        SessionID : Integer ;
        Name : PANSIChar ;
        var writable : LongBool ) : Integer ; stdcall ; //

     TIMAQdxEnumerateAttributeValues= function(
        SessionID : Integer ;
        Name : PANSIChar ;
        pEnumItems : Pointer ;
        var Size : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxGetAttributeTooltip= function(
        SessionID : Integer ;
        Name : PANSIChar ;
        Tooltip : PANSIChar ;
        Length : Cardinal ) : Integer ; stdcall ; //
        
     TIMAQdxGetAttributeUnits= function(
        SessionID : Integer ;
        Name : PANSIChar ;
        Units : PANSIChar ;
        Length : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxRegisterFrameDoneEvent= function(
        SessionID : Integer ;
        BufferInterval : Cardinal ;
        pFrameDoneEventCallbackPtr : Pointer ;
        pCallbackData : Pointer ) : Integer ; stdcall ; //

     TIMAQdxRegisterPnpEvent= function(
        SessionID : Integer ;
        Event : Cardinal ;
        PnpEventCallbackPtr : Pointer ;
        pCallbackData : Pointer) : Integer ; stdcall ; //

     TIMAQdxWriteRegister= function(
        SessionID : Integer ;
        Offset : Cardinal ;
        Value : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxReadRegister= function(
        SessionID : Integer ;
        Offset : Cardinal ;
        var Value : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxWriteMemory= function(
        SessionID : Integer ;
        Offset : Cardinal ;
        Values : pANSIChar ;
        Count : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxReadMemory= function(
        SessionID : Integer ;
        offset : Cardinal ;
        Values : PANSIChar ;
        Count  : Cardinal) : Integer ; stdcall ; //

     TIMAQdxGetErrorString= function(
        Error : DWord ;
        ErrorMsg : PANSIChar ;
        MessageLength : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxWriteAttributes= function(
        SessionID : Integer ;
        Filename : PANSIChar ) : Integer ; stdcall ; //

     TIMAQdxReadAttributes= function(
        SessionID : Integer ;
        Filename : PANSIChar ) : Integer ; stdcall ; //

     TIMAQdxResetEthernetCameraAddress= function(
        Name : PANSIChar ;
        Address : PANSIChar ;
        Subnet : PANSIChar ;
        Gateway : PANSIChar ;
        Timeout : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxEnumerateAttributes2= function(
        SessionID : Integer ;
        pAttributeInformation : Pointer  ;
        var Count : Cardinal ;
        Root : PANSIChar ;
        Visibility : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxGetAttributeVisibility= function(
        SessionID : Integer ;
        Name : PANSIChar ;
        var visibility : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxGetAttributeDescription= function(
        SessionID : Integer ;
        Name : PANSIChar ;
        Description : PANSIChar ;
        Length : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxGetAttributeDisplayName= function(
        SessionID : Integer ;
        Name : PANSIChar ;
        DisplayName : PANSIChar ;
        Length : Cardinal ) : Integer ; stdcall ; //

     TIMAQdxRegisterAttributeUpdatedEvent= function(
        SessionID : Integer ;
        Name : PANSIChar ;
        AttributeUpdatedEventCallbackPtr : Pointer ;
        CallbackData : Pointer ) : Integer ; stdcall ; //

// ----------------------
// Library function calls
// ----------------------

function IMAQDX_OpenCamera(
          var Session : TIMAQDXSession ;   // Camera session
          var SelectedCamera : Integer ;   // Selected camera #
          var CameraMode : Integer ;
          var PixelFormat : Integer ;
          var FrameWidthMax : Integer ;
          var FrameHeightMax : Integer ;
          var NumBytesPerPixel : Integer ;
          var PixelDepth : Integer ;
          var BinFactorMax : Integer ;
          var NumCameras : Integer ;       // No. of cameraS available (returned)
          CameraInfo : TStringList         // Returns Camera details
          ) : Boolean ;

procedure IMAQDX_CloseCamera(
          var Session : TIMAQDXSession     // Camera session #
          ) ;

procedure IMAQDX_SetVideoMode(
          var Session : TIMAQDXSession ;
          VideoMode : Integer ;
          PixelFormat : Integer ;
          var FrameWidthMax : Integer ;  // Returns camera frame width
          var FrameHeightMax : Integer ; // Returns camera height width
          var NumBytesPerComponent : Integer ; // Returns bytes/pixel
          var PixelDepth : Integer ;        // Returns no. bits/pixel
          var GreyLevelMin : Integer ;      // Min. grey level
          var GreyLevelMax : Integer        // Max. grey level
          ) ;

procedure IMAQDX_SetPixelFormat(
          var Session : TIMAQDXSession ;
          var PixelFormat : Integer ;               // Video mode
          var NumBytesPerComponent : Integer ; // Returns bytes/pixel
          var PixelDepth : Integer ;        // Returns no. bits/pixel
          var GreyLevelMin : Integer ;      // Min. grey level
          var GreyLevelMax : Integer        // Max. grey level
          ) ;


{function IMAQDX_GetVideoMode(
          var Session : TIMAQDXSession ) : Integer ;}

function IMAQDX_StartCapture(
         var Session : TIMAQDXSession ;
         var FrameInterval : Double ;      // Frame exposure interval (s)
         AdditionalReadoutTime : Double ;
         AmpGain : Integer ;
         ExternalTrigger : Integer ;
         FrameLeft : Integer ;
         FrameTop : Integer ;
         FrameWidth : Integer ;
         FrameHeight : Integer ;
         BinFactor : Integer ;
         PFrameBuffer : Pointer ;
         NumFramesInBuffer : Integer ;
         NumBytesPerFrame : Integer ;
         MonochromeImage : Boolean
         ) : Boolean ;

function IMAQDX_SnapImage(
         var Session : TIMAQDXSession ;          // Camera session #
         var FrameInterval : Double ;      // Frame exposure interval (s)
         AdditionalReadoutTime : Double ;  // Additional readout time
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
         MonochromeImage : Boolean       // TRUE = extract monochrome image
         ) : Boolean ;


procedure IMAQDX_StopCapture(
          var Session : TIMAQDXSession              // Camera session #
          ) ;

procedure IMAQDX_GetImage(
          var Session : TIMAQDXSession
          ) ;

procedure IMAQDX_GetCameraGainList( var Session : TIMAQDXSession ;
                                    CameraGainList : TStringList ) ;

procedure IMAQDX_GetCameraVideoModeList(
          var Session : TIMAQDXSession ;
          List : TStringList ) ;

procedure IMAQDX_GetCameraPixelFormatList(
          var Session : TIMAQDXSession ;
          List : TStringList ) ;

function IMAQDX_CheckFrameInterval(
          var Session : TIMAQDXSession ;
          var FrameInterval : Double ) : Integer ;

procedure IMAQDX_LoadLibrary  ;
function IMAQDX_GetDLLAddress(
         Handle : THandle ;
         const ProcName : String ) : Pointer ;

procedure IMAQDX_CheckROIBoundaries( var Session : TIMAQDXSession ;
                                   var FrameLeft : Integer ;
                                   var FrameRight : Integer ;
                                   var FrameTop : Integer ;
                                   var FrameBottom : Integer ;
                                   var BinFactor : Integer ;
                                   var FrameWidth : Integer ;
                                   var FrameHeight : Integer ;
                                   Var FrameInterval : double ;
                                   var ReadoutTime : double
                                   ) ;

function IMAQDX_AttributeAvailable(
         var Session : TIMAQDXSession ;
         AttributeName : PANSIChar ;
         CheckWritable : Boolean
         ) : Boolean ;

procedure IMAQDX_CheckError( ErrNum : Integer ) ;

function IMAQDX_CharArrayToString( cBuf : Array of ANSIChar ) : String ;

function IMAQDX_FindAttribute(
          var Session : TIMAQDXSession ;      // Session record
          Name : ANSIString ;                 // Target name/fragment
          FullMatch : Boolean ) : Integer ;   // Match whole of attribute name

function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;
          Attribute : Integer ;
          Value : Integer
          ) : Integer ; overload ;

function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;
          Attribute : Integer ;
          Value : Int64
          ) : Int64 ; overload ;

function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;
          Attribute : Integer ;
          Value : Double
          ) : Double ; overload ;

function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;
          Attribute : Integer ;
          Value : String
          ) : string ; overload ;

function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;
          Attribute : Integer ;
          Value : LongBool
          ) : LongBool ; overload ;


procedure IMAQDX_GetAttrRange(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Min : Double ;
          var Max : Double ;
          var Increment : Double ) ; overload ;

procedure IMAQDX_GetAttrRange(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Min : Int64 ;
          var Max : Int64 ;
          var Increment : Int64 ) ; overload ;

procedure IMAQDX_GetAttrRange(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Min : Integer ;
          var Max : Integer ;
          var Increment : Integer ) ; overload ;

procedure IMAQDX_GetAttribute(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Value : Double ) ; overload ;

procedure IMAQDX_GetAttribute(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Value : Int64  ) ; overload ;

procedure IMAQDX_GetAttribute(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Value : Integer ) ; overload ;

procedure IMAQDX_CopyImage(
          pFromBuf : Pointer ;   // pointer to image source
          pToBuf : Pointer ;     // pointer to image destination
          iStart : Integer ;     // Starting pixel component
          iStep : Integer ;      // pixel step
          nCopy : Integer ;      // no. of pixels to copy
          NumBytesPerPixel : Integer // No. bytes per pixel
          ) ;

procedure IMAQDX_CopyImageBGRA(
          var Session : TIMAQDXSession ;
          xLeft : Integer ;
          yTop : Integer ;
          FrameWidth : Integer ;
          FrameHeight : Integer ;
          FrameWidthMax : Integer ;
          pToBuf : Pointer      // pointer to image destination
          ) ;

procedure IMAQDX_CopyImageRGB(
          var Session : TIMAQDXSession ;
          xLeft : Integer ;
          yTop : Integer ;
          FrameWidth : Integer ;
          FrameHeight : Integer ;
          FrameWidthMax : Integer ;
          pToBuf : Pointer      // pointer to image destination
          ) ;

procedure IMAQDX_CopyImageMono(
          var Session : TIMAQDXSession ;
          xLeft : Integer ;
          yTop : Integer ;
          FrameWidth : Integer ;
          FrameHeight : Integer ;
          FrameWidthMax : Integer ;
          pToBuf : Pointer      // pointer to image destination
          ) ;

procedure IMAQDX_CopyImageMono12Packed(
          var Session : TIMAQDXSession ;  // Session record
          xLeft : Integer ;               // Start copy at column X
          yTop : Integer ;                // Start copy at row Y
          FrameWidth : Integer ;          // Height of area to copy
          FrameHeight : Integer ;         // Height of area to copy
          FrameWidthMax : Integer ;       // Width of line
          pToBuf : Pointer                // pointer to image destination
          ) ;

procedure IMAQDX_CopyImageMono12PackedIIDC(
          var Session : TIMAQDXSession ;  // Session record
          xLeft : Integer ;               // Start copy at column X
          yTop : Integer ;                // Start copy at row Y
          FrameWidth : Integer ;          // Height of area to copy
          FrameHeight : Integer ;         // Height of area to copy
          FrameWidthMax : Integer ;       // Width of line
          pToBuf : Pointer                // pointer to image destination
          ) ;

function IMAQDX_ExposureTimeScale(
         var Session : TIMAQDXSession ) : double ;
var

     IMAQdxSnap : TIMAQdxSnap;
     IMAQdxConfigureGrab : TIMAQdxConfigureGrab;
     IMAQdxGrab : TIMAQdxGrab;
     IMAQdxSequence : TIMAQdxSequence;
     IMAQdxDiscoverEthernetCameras : TIMAQdxDiscoverEthernetCameras ;
     IMAQdxEnumerateCameras : TIMAQdxEnumerateCameras ;
     IMAQdxResetCamera : TIMAQdxResetCamera ;
     IMAQdxOpenCamera : TIMAQdxOpenCamera ;
     IMAQdxCloseCamera : TIMAQdxCloseCamera ;
     IMAQdxConfigureAcquisition : TIMAQdxConfigureAcquisition ;
     IMAQdxStartAcquisition : TIMAQdxStartAcquisition ;
     IMAQdxGetImage : TIMAQdxGetImage ;
     IMAQdxGetImageData : TIMAQdxGetImageData ;
     IMAQdxStopAcquisition : TIMAQdxStopAcquisition ;
     IMAQdxUnconfigureAcquisition : TIMAQdxUnconfigureAcquisition ;
     IMAQdxEnumerateVideoModes : TIMAQdxEnumerateVideoModes ;
     IMAQdxEnumerateAttributes : TIMAQdxEnumerateAttributes ;
     IMAQdxGetAttribute : TIMAQdxGetAttribute ;
     IMAQdxSetAttributeI32 : TIMAQdxSetAttributeI32 ;
     IMAQdxSetAttributeI64 : TIMAQdxSetAttributeI64 ;
     IMAQdxSetAttributeF64 : TIMAQdxSetAttributeF64 ;
     IMAQdxSetAttributeEnum : TIMAQdxSetAttributeEnum ;
     IMAQdxSetAttributeBool : TIMAQdxSetAttributeBool ;
     IMAQdxGetAttributeMinimum : TIMAQdxGetAttributeMinimum ;
     IMAQdxGetAttributeMaximum : TIMAQdxGetAttributeMaximum ;
     IMAQdxGetAttributeIncrement : TIMAQdxGetAttributeIncrement ;
     IMAQdxGetAttributeType : TIMAQdxGetAttributeType ;
     IMAQdxIsAttributeReadable : TIMAQdxIsAttributeReadable ;
     IMAQdxIsAttributeWritable : TIMAQdxIsAttributeWritable ;
     IMAQdxEnumerateAttributeValues : TIMAQdxEnumerateAttributeValues ;
     IMAQdxGetAttributeTooltip : TIMAQdxGetAttributeTooltip ;
     IMAQdxGetAttributeUnits : TIMAQdxGetAttributeUnits ;
     IMAQdxRegisterFrameDoneEvent : TIMAQdxRegisterFrameDoneEvent ;
     IMAQdxRegisterPnpEvent : TIMAQdxRegisterPnpEvent ;
     IMAQdxWriteRegister : TIMAQdxWriteRegister ;
     IMAQdxReadRegister : TIMAQdxReadRegister ;
     IMAQdxWriteMemory : TIMAQdxWriteMemory ;
     IMAQdxReadMemory : TIMAQdxReadMemory ;
     IMAQdxGetErrorString : TIMAQdxGetErrorString ;
     IMAQdxWriteAttributes : TIMAQdxWriteAttributes ;
     IMAQdxReadAttributes : TIMAQdxReadAttributes ;
     IMAQdxResetEthernetCameraAddress : TIMAQdxResetEthernetCameraAddress ;
     IMAQdxEnumerateAttributes2 : TIMAQdxEnumerateAttributes2 ;
     IMAQdxGetAttributeVisibility : TIMAQdxGetAttributeVisibility ;
     IMAQdxGetAttributeDescription : TIMAQdxGetAttributeDescription ;
     IMAQdxGetAttributeDisplayName : TIMAQdxGetAttributeDisplayName ;
     IMAQdxRegisterAttributeUpdatedEvent : TIMAQdxRegisterAttributeUpdatedEvent ;

implementation

uses sescam ;

//  Internal pixel format codes
const
    pfUnknown = 0 ;
    pfRGB8 = 1;
    pfYUV422 = 2;
    pfMono8 = 3;
    pfMono12PackedIIDC = 4 ;
    pfMono12Packed = 5 ;
    pfMono12 = 6 ;
    pfMono16 = 7 ;
    pfBGRA8 = 8 ;
    pfBGR8 = 9 ;

var
    LibraryHnd : THandle ;         // PVCAM32.DLL library handle
    LibraryLoaded : boolean ;      // PVCAM32.DLL library loaded flag
    Val : Integer ;

procedure IMAQDX_LoadLibrary  ;
{ -------------------------------------
  Load IMAQ.DLL library into memory
  -------------------------------------}
var
    LibFileName : String ;
begin

     if LibraryLoaded then Exit ;

     { Load interface DLL library }
     LibFileName := 'NIIMAQDX.DLL' ;
     LibraryHnd := LoadLibrary( PChar(LibFileName));

     { Get addresses of procedures in library }
     if LibraryHnd > 0 then begin

        @IMAQdxRegisterAttributeUpdatedEvent := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxRegisterAttributeUpdatedEvent') ;
        @IMAQdxGetAttributeDisplayName := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttributeDisplayName') ;
        @IMAQdxGetAttributeDescription := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttributeDescription') ;
        @IMAQdxGetAttributeVisibility := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttributeVisibility') ;
        @IMAQdxEnumerateAttributes2 := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxEnumerateAttributes2') ;
        @IMAQdxResetEthernetCameraAddress := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxResetEthernetCameraAddress') ;
        @IMAQdxReadAttributes := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxReadAttributes') ;
        @IMAQdxWriteAttributes := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxWriteAttributes') ;
        @IMAQdxGetErrorString := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetErrorString') ;
        @IMAQdxReadMemory := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxReadMemory') ;
        @IMAQdxWriteMemory := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxWriteMemory') ;
        @IMAQdxReadRegister := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxReadRegister') ;
        @IMAQdxWriteRegister := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxWriteRegister') ;
        @IMAQdxRegisterPnpEvent := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxRegisterPnpEvent') ;
        @IMAQdxRegisterFrameDoneEvent := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxRegisterFrameDoneEvent') ;
        @IMAQdxGetAttributeUnits := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttributeUnits') ;
        @IMAQdxGetAttributeTooltip:= IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttributeTooltip') ;
        @IMAQdxEnumerateAttributeValues := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxEnumerateAttributeValues') ;
        @IMAQdxIsAttributeWritable := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxIsAttributeWritable') ;
        @IMAQdxIsAttributeReadable := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxIsAttributeReadable') ;
        @IMAQdxGetAttributeType := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttributeType') ;
        @IMAQdxGetAttributeIncrement := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttributeIncrement') ;
        @IMAQdxGetAttributeMaximum := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttributeMaximum') ;
        @IMAQdxGetAttributeMinimum := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttributeMinimum') ;
        @IMAQdxSetAttributeI32 := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxSetAttribute') ;
        @IMAQdxSetAttributeI64 := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxSetAttribute') ;
        @IMAQdxSetAttributeF64 := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxSetAttribute') ;
        @IMAQdxSetAttributeEnum := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxSetAttribute') ;
        @IMAQdxSetAttributeBool := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxSetAttribute') ;
        @IMAQdxGetAttribute := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetAttribute') ;
        @IMAQdxEnumerateAttributes := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxEnumerateAttributes') ;
        @IMAQdxEnumerateVideoModes := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxEnumerateVideoModes') ;
        @IMAQdxUnconfigureAcquisition := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxUnconfigureAcquisition') ;
        @IMAQdxStopAcquisition := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxStopAcquisition') ;
        @IMAQdxGetImageData := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetImageData') ;
        @IMAQdxGetImage := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGetImage') ;
        @IMAQdxStartAcquisition := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxStartAcquisition') ;
        @IMAQdxConfigureAcquisition := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxConfigureAcquisition') ;
        @IMAQdxCloseCamera := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxCloseCamera') ;
        @IMAQdxOpenCamera := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxOpenCamera') ;
        @IMAQdxResetCamera := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxResetCamera') ;
        @IMAQdxEnumerateCameras := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxEnumerateCameras') ;
        @IMAQdxDiscoverEthernetCameras := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxDiscoverEthernetCameras') ;
        @IMAQdxSequence := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxSequence') ;
        @IMAQdxGrab := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxGrab') ;
        @IMAQdxConfigureGrab := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxConfigureGrab') ;
        @IMAQdxSnap := IMAQDX_GetDLLAddress(LibraryHnd,'IMAQdxSnap') ;

        LibraryLoaded := True ;
        end
     else begin
          ShowMessage( 'IMAQDX: ' + LibFileName + ' not found!' ) ;
          LibraryLoaded := False ;
          end ;

     end ;


function IMAQDX_GetDLLAddress(
         Handle : THandle ;
         const ProcName : String ) : Pointer ;
// -----------------------------------------
// Get address of procedure within PVCAM32.DLL
// -----------------------------------------
begin
    Result := GetProcAddress(Handle,PChar(ProcName)) ;
    if Result = Nil then
       ShowMessage('NIIMAQDX.DLL: ' + ProcName + ' not found') ;
    end ;


function IMAQDX_OpenCamera(
          var Session : TIMAQDXSession ;   // Camera session
          var SelectedCamera : Integer ;   // Selected camera #
          var CameraMode : Integer ;       // Video mode
          var PixelFormat : Integer ;        // Pixel format
          var FrameWidthMax : Integer ;    // Returns max. frame width (pixels)
          var FrameHeightMax : Integer ;   // Returns max. frame height (pixels)
          var NumBytesPerPixel : Integer ; // Returns no. of bytes per pixel
          var PixelDepth : Integer ;       // Returns bits per pixel
          var BinFactorMax : Integer ;
          var NumCameras : Integer ;       // No. of cameraS available (returned)
          CameraInfo : TStringList         // Returns Camera details
          ) : Boolean ;
// ---------------------
// Open camera
// ---------------------
var
    Err : Integer ;
    i,j  :Integer ;
    NumValues : Cardinal ;
    s : String ;
    List : Array[0..100] of TIMAQdxEnumItem ;
    DMin,DMax,DInc : Double ;
    iMin,iMax,Inc64 : Int64 ;
    uMin,uMax,Inc32 : Integer ;
    NumCameraInits : Integer;
begin

     Result := False ;

     // Load DLL libray
     if not LibraryLoaded then IMAQDX_LoadLibrary  ;
     if not LibraryLoaded then Exit ;

     // Discover available cameras
     Err := IMAQdxEnumerateCameras( Nil, Session.NumCameras, True) ;
     if Session.NumCameras > 0 then begin
        Err := IMAQdxEnumerateCameras( @Session.CameraInfo, Session.NumCameras, True) ;
        CameraInfo.Add( 'Cameras available:' ) ;
        for i := 0 to Session.NumCameras-1 do begin
           Session.CameraNames[i] := format('%s: %s %s',[ANSIString(Session.CameraInfo[i].InterfaceName),
                                                         ANSIString(Session.CameraInfo[i].VendorName),
                                                         ANSIString(Session.CameraInfo[i].ModelName)]);
           CameraInfo.Add(Session.CameraNames[i]);
           end;
        CameraInfo.Add('');
        end
     else begin
        ShowMessage('IMAQDX: No cameras detected!') ;
        Exit ;
        end ;
     NumCameras := Session.NumCameras ;
    // SelectedCamera := 1 ;
     SelectedCamera := Max(Min(SelectedCamera,Session.NumCameras-1),0) ;
     Session.SelectedCamera := SelectedCamera ;
     CameraInfo.Add( 'Interface Name: ' + IMAQDX_CharArrayToString(Session.CameraInfo[SelectedCamera].InterfaceName)) ;
     CameraInfo.Add( 'Vendor: ' + IMAQDX_CharArrayToString(Session.CameraInfo[SelectedCamera].VendorName)) ;
     CameraInfo.Add( 'Model: ' + IMAQDX_CharArrayToString(Session.CameraInfo[SelectedCamera].ModelName)) ;
     CameraInfo.Add( 'Camera File: ' + IMAQDX_CharArrayToString(Session.CameraInfo[SelectedCamera].CameraFileName)) ;
     CameraInfo.Add( 'URL: ' + IMAQDX_CharArrayToString(Session.CameraInfo[SelectedCamera].CameraAttributeURL)) ;

     // Open and initialise camera TWICE
     // 23/10/16 This is a fix to ensure that 'AcquisitionFrameRateAuto=Off' is recognised by Point Grey
     // Grasshopper cameras which seem to require the camera to be open/closed before the setting
     // is recognised.

     NumCameraInits := 0 ;
     repeat

     // Open camera
     Err := IMAQdxOpenCamera ( Session.CameraInfo[SelectedCamera].InterfaceName,
                               IMAQdxCameraControlModeController,
                               Session.ID) ;

     // -----------------------------------------------------------------------
     // Camera closed and re-opened to avoid "attribute out range" error
     // when IMAQdxConfigureAcquisition() called after program has been restarted
     // when using a GIGE camera. Not known why this occurs.
     IMAQdxCloseCamera( Session.ID ) ;
     Err := IMAQdxOpenCamera ( Session.CameraInfo[Session.SelectedCamera].InterfaceName,
                               IMAQdxCameraControlModeController,
                               Session.ID) ;
     // -----------------------------------------------------------------------

     IMAQDX_CheckError( Err ) ;
     if Err = 0 then Session.CameraOpen := True
     else begin
        Session.CameraOpen := False ;
        ShowMessage('IMAQDX: Unable to open camera!') ;
        Exit ;
        end ;

     // Get list of available camera attributes
     Session.NumAttributes := 0 ;
     Err := IMAQdxEnumerateAttributes2( Session.id,
                                        Nil,
                                        Session.NumAttributes,
                                        PANSIChar(''),
                                        IMAQdxAttributeVisibilityAdvanced ) ;
     if Err = 0 then IMAQdxEnumerateAttributes2( Session.id,
                                                 @Session.Attributes,
                                                 Session.NumAttributes,
                                                 PANSIChar(''),
                                                 IMAQdxAttributeVisibilityAdvanced ) ;

     // Get attribute code
     Session.AttrVideoMode  := IMAQDX_FindAttribute( Session, 'AcquisitionAttributes::VideoMode', true ) ;
     Session.AttrWidthMax := IMAQDX_FindAttribute( Session, 'WidthMax', false ) ;
     Session.AttrHeightMax := IMAQDX_FindAttribute( Session, 'HeightMax', false ) ;

     Session.AttrWidth := IMAQDX_FindAttribute( Session, 'CameraAttributes::ImageFormatControl::Width', true ) ;
     if Session.AttrWidth < 0 then Session.AttrWidth := IMAQDX_FindAttribute( Session, 'AOI::Width', false ) ;
     if Session.AttrWidth < 0 then Session.AttrWidth := IMAQDX_FindAttribute( Session, 'Width', false ) ;

     Session.AttrHeight := IMAQDX_FindAttribute( Session, 'CameraAttributes::ImageFormatControl::Height', true ) ;
     if Session.AttrHeight < 0 then Session.AttrHeight := IMAQDX_FindAttribute( Session, 'AOI::Height', false ) ;
     if Session.AttrHeight < 0 then Session.AttrHeight := IMAQDX_FindAttribute( Session, 'Height', false ) ;

     Session.AttrXOffset := IMAQDX_FindAttribute( Session, 'CameraAttributes::ImageFormatControl::OffsetX', true ) ;
     if Session.AttrXOffset < 0 then Session.AttrXOffset := IMAQDX_FindAttribute( Session, 'AOI::OffsetX', false ) ;
     if Session.AttrXOffset < 0 then Session.AttrXOffset := IMAQDX_FindAttribute( Session, 'OffsetX', false ) ;

     Session.AttrYOffset := IMAQDX_FindAttribute( Session, 'CameraAttributes::ImageFormatControl::OffsetY', true ) ;
     if Session.AttrYOffset < 0 then Session.AttrYOffset := IMAQDX_FindAttribute( Session, 'AOI::OffsetY', false ) ;
     if Session.AttrYOffset < 0 then Session.AttrYOffset := IMAQDX_FindAttribute( Session, 'OffsetY', false ) ;

     Session.AttrXBin := IMAQDX_FindAttribute( Session, 'AOI::BinningHorizontal', false ) ;
     if Session.AttrXBin < 0 then Session.AttrXBin := IMAQDX_FindAttribute( Session, 'BinningHorizontal', false ) ;
     Session.AttrYBin := IMAQDX_FindAttribute( Session, 'AOI::BinningVertical', false ) ;
     if Session.AttrYBin < 0 then Session.AttrYBin := IMAQDX_FindAttribute( Session, 'BinningVertical', false ) ;

     Session.AttrPixelFormat  := IMAQDX_FindAttribute( Session, 'ImageFormat::PixelFormat', false ) ;
     if Session.AttrPixelFormat < 0 then Session.AttrPixelFormat  := IMAQDX_FindAttribute( Session, 'PixelFormat', false ) ;
     Session.AttrBitsPerPixel  := IMAQDX_FindAttribute( Session, 'BitsPerPixel', false ) ;
     Session.AttrPixelSize  := IMAQDX_FindAttribute( Session, 'PixelSize', false ) ;

     Session.AttrExposureTime  := IMAQDX_FindAttribute( Session, 'CameraAttributes::Exposure::Value', false ) ;
     if Session.AttrExposureTime < 0 then Session.AttrExposureTime  := IMAQDX_FindAttribute( Session, 'AcquisitionAttributes::ExposureTime', false ) ;
     if Session.AttrExposureTime < 0 then Session.AttrExposureTime  := IMAQDX_FindAttribute( Session, 'AcquisitionControl::ExposureTime', false ) ;
     if Session.AttrExposureTime < 0 then Session.AttrExposureTime  := IMAQDX_FindAttribute( Session, 'ExposureTimeAbs', false ) ;
     if Session.AttrExposureTime < 0 then Session.AttrExposureTime  := IMAQDX_FindAttribute( Session, 'ExposureTime', false ) ;

     Session.AttrExposureMode  := IMAQDX_FindAttribute( Session, 'CameraAttributes::Exposure::Mode', false ) ;
     if Session.AttrExposureMode < 0 then Session.AttrExposureMode  := IMAQDX_FindAttribute( Session, 'AcquisitionControl::ExposureMode', false ) ;
     if Session.AttrExposureMode < 0 then Session.AttrExposureMode  := IMAQDX_FindAttribute( Session, 'AcquisitionAttributes::ExposureMode', false ) ;
     if Session.AttrExposureMode < 0 then Session.AttrExposureMode  := IMAQDX_FindAttribute( Session, 'Exposure::Mode', false ) ;
     if Session.AttrExposureMode < 0 then Session.AttrExposureMode  := IMAQDX_FindAttribute( Session, 'ExposureMode', false ) ;

     Session.AttrExposureAuto := IMAQDX_FindAttribute( Session, 'AcquisitionControl::ExposureAuto', false ) ;
     Session.AttrPgrExposureCompensationAuto := IMAQDX_FindAttribute( Session, 'AcquisitionControl::pgrExposureCompensationAuto', false ) ;

     Session.AttrAcquisitionFrameRateEnabled := IMAQDX_FindAttribute( Session, 'AcquisitionFrameRateEnabled', false ) ;
     Session.AttrAcquisitionFrameRate := IMAQDX_FindAttribute( Session, 'CameraAttributes::AcquisitionControl::AcquisitionFrameRate', true ) ;
     Session.AttrAcquisitionFrameRateAuto := IMAQDX_FindAttribute( Session, 'AcquisitionFrameRateAuto', false ) ;

     Session.AttrAcqInProgress  := IMAQDX_FindAttribute( Session, 'StatusInformation::AcqInProgress', false ) ;
     Session.AttrLastBufferNumber  := IMAQDX_FindAttribute( Session, 'StatusInformation::LastBufferNumber', false ) ;
     Session.AttrLastBufferCount  := IMAQDX_FindAttribute( Session, 'StatusInformation::LastBufferCount', false ) ;

     // Camera Triggering
     Session.AttrTriggerMode :=  IMAQDX_FindAttribute( Session, 'AcquisitionTrigger::TriggerMode', false) ;
     if Session.AttrTriggerMode < 0 then Session.AttrTriggerMode :=  IMAQDX_FindAttribute( Session, 'AcquisitionControl::TriggerMode', false) ;
     if Session.AttrTriggerMode < 0 then Session.AttrTriggerMode :=  IMAQDX_FindAttribute( Session, 'TriggerMode', false) ;

     Session.AttrTriggerSelector := IMAQDX_FindAttribute( Session, 'AcquisitionTrigger::TriggerSelector', false);
     if Session.AttrTriggerSelector < 0 then Session.AttrTriggerSelector := IMAQDX_FindAttribute( Session, 'AcquisitionControl::TriggerSelector', false);
     if Session.AttrTriggerSelector < 0 then Session.AttrTriggerSelector := IMAQDX_FindAttribute( Session, 'TriggerSelector', false);

     Session.AttrTriggerSource := IMAQDX_FindAttribute( Session, 'AcquisitionTrigger::TriggerSource', false);
     if Session.AttrTriggerSource < 0 then Session.AttrTriggerSource := IMAQDX_FindAttribute( Session, 'AcquisitionControl::TriggerSource', false);
     if Session.AttrTriggerSource < 0 then Session.AttrTriggerSource := IMAQDX_FindAttribute( Session, 'TriggerSource', false);

     Session.AttrTriggerActivation := IMAQDX_FindAttribute( Session, 'AcquisitionTrigger::TriggerActivation', false);
     if Session.AttrTriggerActivation < 0 then Session.AttrTriggerActivation := IMAQDX_FindAttribute( Session, 'AcquisitionControl::TriggerActivation', false);
     if Session.AttrTriggerActivation < 0 then Session.AttrTriggerActivation := IMAQDX_FindAttribute( Session, 'TriggerActivation', false);

     // Camera gain
     Session.AttrGain := IMAQDX_FindAttribute( Session, 'CameraAttributes::AnalogControl::Gain', true) ;
     if Session.AttrGain < 0 then Session.AttrGain := IMAQDX_FindAttribute( Session, 'CameraAttributes::Gain::Value', true ) ;
     if Session.AttrGain < 0 then Session.AttrGain := IMAQDX_FindAttribute( Session, 'GainRaw', false) ;
     Session.AttrGainMode := IMAQDX_FindAttribute( Session, 'CameraAttributes::Gain::Mode', true) ;
     Session.AttrGainAuto := IMAQDX_FindAttribute( Session, 'GainAuto', false ) ;

     //if Session.AttrGainMode < 0 then Session.AttrGainMode := IMAQDX_FindAttribute( Session, 'CameraAttributes::AnalogControl::Gain', true) ;

     Session.AttrPacketSize := IMAQDX_FindAttribute( Session, 'AcquisitionAttributes::PacketSize', false) ;

     // Area of interest supported by camera
     if (Session.AttrXOffset >= 0) and (Session.AttrYOffset >= 0) then Session.AOIAvailable := True
                                                                  else Session.AOIAvailable := False ;

     // Get list of video modes
     if Session.AttrVideoMode >= 0 then begin

        IMAQdxEnumerateAttributeValues(  Session.id,
                                         Session.Attributes[Session.AttrVideoMode].Name,
                                         Nil,
                                         Session.NumVideoModes) ;
        IMAQdxEnumerateAttributeValues(  Session.id,
                                         Session.Attributes[Session.AttrVideoMode].Name,
                                         @Session.VideoModes,
                                         Session.NumVideoModes) ;

        end
     else begin
        CameraInfo.Add('None') ;
        CameraMode := 0 ;
        Session.VideoMode := 0 ;
        Session.NumVideoModes := 0 ;
        end ;

     // Pixel binning
     if (Session.AttrXBin >= 0) and (Session.AttrYBin >= 0) then begin
        // Set binning to 1X1 during opening of camera
        IMAQDX_SetAttribute( Session, Session.AttrXBin, 1 ) ;
        IMAQDX_SetAttribute( Session, Session.AttrXBin, 1 ) ;
        // Get maximum pixel binning
        IMAQDX_GetAttrRange( Session,Session.AttrXBin, i, BinfactorMax, Inc32 ) ;
        end
     else BinFactorMax := 1 ;

    // Camera gain
    Session.GainMin := 1 ;
    Session.GainMax := 1 ;
    // Get minimum gain
    IMAQDX_GetAttrRange( Session,Session.AttrGain,Session.GainMin,Session.GainMax, Inc32 ) ;

     // Pixel depth
     if Session.AttrBitsPerPixel >= 0 then begin
        IMAQdxEnumerateAttributeValues( Session.id,
                                        Session.Attributes[Session.AttrBitsPerPixel].Name,
                                        Nil,
                                        Session.NumPixelSettings ) ;
        IMAQdxEnumerateAttributeValues( Session.id,
                                        Session.Attributes[Session.AttrBitsPerPixel].Name,
                                        @Session.PixelSettings,
                                        Session.NumPixelSettings ) ;
        IMAQdx_SetAttribute( Session, Session.AttrBitsPerPixel, Session.PixelSettings[0].Name ) ;
        end
     else   CameraInfo.Add('Bits per pixel attribute not available!') ;

     // Set video mode
     IMAQDX_SetVideoMode( Session,
                          CameraMode,
                          PixelFormat,
                          Session.FrameWidthMax,
                          Session.FrameHeightMax,
                          Session.NumBytesPerComponent,
                          Session.PixelDepth,
                          Session.GreyLevelMin,
                          Session.GreyLevelMax ) ;

     CameraInfo.Add( format('CCD: Width %d, Height %d, Pixel depth %d',
                             [Session.FrameWidthMax,Session.FrameHeightMax,Session.PixelDepth]));

     // Disable automatic exposure setting features and set to timed exposure mode
     IMAQdx_SetAttribute( Session, Session.AttrExposureAuto, 'Off' ) ;
     IMAQdx_SetAttribute( Session, Session.AttrPgrExposureCompensationAuto, 'Off' ) ;
     IMAQdx_SetAttribute( Session, Session.AttrExposureMode, 'Timed' ) ;
     IMAQdx_SetAttribute( Session, Session.AttrAcquisitionFrameRateAuto, 'Off' ) ;

     // List camera attributes
     CameraInfo.Add('Camera Attributes:') ;
     for i := 0 to Session.NumAttributes-1 do begin
         s := IMAQDX_CharArrayToString( Session.Attributes[i].Name) ;
         if Session.Attributes[i].Readable then s := s + ' R' ;
         if Session.Attributes[i].Writable then s := s + 'W' ;
         case Session.Attributes[i].iType of

             IMAQdxAttributeTypeU32 : begin
                IMAQdx_GetAttrRange( Session, i, uMin, uMax,Inc32 ) ;
                s := s + format(' U32 %6d - %6d',[uMin,uMax,Inc32]) ;
                end;

             IMAQdxAttributeTypeI64 : begin
                IMAQdx_GetAttrRange( Session, i, iMin,iMax,Inc64 ) ;
                s := s + format(' I64 %6d - %6d',[iMin,iMax,Inc64]) ;
                end;


             IMAQdxAttributeTypeF64 : begin
                  IMAQdx_GetAttrRange( Session, i, DMin, DMax, DInc ) ;
                  s := s + format(' F64 %.4g - %.4g',[DMin,DMax,DInc]) ;
                end;

             IMAQdxAttributeTypeString : s := s + ' S' ;

             IMAQdxAttributeTypeEnum : begin
                 s := s + ' En: ' ;
                 IMAQdxEnumerateAttributeValues(  Session.id,
                                                  Session.Attributes[i].Name,
                                                  Nil,
                                                  NumValues) ;
                 IMAQdxEnumerateAttributeValues(  Session.id,
                                                  Session.Attributes[i].Name,
                                                  @List,
                                                  NumValues ) ;
                 if NumValues < 4 then begin
                    for j := 0 to NumValues-1 do
                     s := s + format('%d=%s,',[List[j].Value,ANSIString(List[j].Name)]);
                     end
                 else begin
                     CameraInfo.Add( s ) ;
                     for j := 0 to NumValues-1 do begin
                         s := format('%d=%s,',[List[j].Value,ANSIString(List[j].Name)]);
                         CameraInfo.Add( s ) ;
                         end;
                     s := '' ;
                     end;
                 end;
             IMAQdxAttributeTypeBool : s := s + ' B' ;
             IMAQdxAttributeTypeCommand : s := s + ' COM' ;
             else s := s + '??' ;
             end;
         if s <> '' then CameraInfo.Add( s ) ;
         end ;

     IMAQdx_SetAttribute( Session,Session.AttrPacketSize, 8000 ) ;

     if NumCameraInits = 0 then IMAQdxCloseCamera( Session.ID ) ;
     Inc( NumCameraInits ) ;
     until NumCameraInits >= 2 ;

     // Clear flags
     Session.AcquisitionInProgress := False ;
     Session.CameraOpen := True ;
     Session.Buf := Nil ;

     CameraMode := Session.VideoMode ;
     PixelFormat := Session.PixelFormat ;
     FrameWidthMax := Session.FrameWidthMax ;
     FrameHeightMax := Session.FrameHeightMax ;
     NumBytesPerPixel := Session.NumBytesPerComponent ;
     PixelDepth := Session.PixelDepth  ;

     Result := True ;

     end ;

procedure IMAQDX_GetAttrRange(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Min : Double ;
          var Max : Double ;
          var Increment : Double ) ; overload ;
// -------------------------------------------------------------
// Get upper and lower limits of range of attribute settings
// -------------------------------------------------------------
var
    iMin32,iMax32,iInc32 : Integer ;
    iMin64,iMax64,iInc64 : Int64 ;
    DMin,DMax,DInc : Double ;
begin

     if iAttr < 0 then Exit ;

     case Session.Attributes[iAttr].iType of

         IMAQdxAttributeTypeU32 : begin
            IMAQdxGetAttributeMinimum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMin32 ) ;
            IMAQdxGetAttributeMaximum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMax32 ) ;
            IMAQdxGetAttributeIncrement( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iInc32 ) ;
            Min := iMin32 ;
            Max := iMax32 ;
            Increment := iInc32
            end;

         IMAQdxAttributeTypeI64 : begin
            IMAQdxGetAttributeMinimum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMin64 ) ;
            IMAQdxGetAttributeMaximum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMax64 ) ;
            IMAQdxGetAttributeIncrement( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iInc64 ) ;
            Min := iMin64 ;
            Max := iMax64 ;
            Increment := iInc64
            end;

         else begin
            IMAQdxGetAttributeMinimum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @DMin ) ;
            IMAQdxGetAttributeMaximum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @DMax ) ;
            IMAQdxGetAttributeIncrement( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @DInc ) ;
            Min := DMin ;
            Max := DMax ;
            Increment := DInc ;
            end;
         end ;
     outputdebugstring(pchar(format('%s %.6g, %.6g, %.6g',[Session.Attributes[iAttr].Name,Min,Max,Increment])));
     end;


procedure IMAQDX_GetAttrRange(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Min : Int64 ;
          var Max : Int64 ;
          var Increment : Int64 ) ; overload ;
// -------------------------------------------------------------
// Get upper and lower limits of range of I64 attribute settings
// -------------------------------------------------------------
var
    iMin32,iMax32,iInc32 : Integer ;
    iMin64,iMax64,iInc64 : Int64 ;
    DMin,DMax,DInc : Double ;
begin

     if iAttr < 0 then Exit ;

     case Session.Attributes[iAttr].iType of

         IMAQdxAttributeTypeU32 : begin
            IMAQdxGetAttributeMinimum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMin32 ) ;
            IMAQdxGetAttributeMaximum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMax32 ) ;
            IMAQdxGetAttributeIncrement( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iInc32 ) ;
            Min := iMin32 ;
            Max := iMax32 ;
            Increment := iInc32 ;
            end;

         IMAQdxAttributeTypeI64 : begin
            IMAQdxGetAttributeMinimum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMin64 ) ;
            IMAQdxGetAttributeMaximum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMax64 ) ;
            IMAQdxGetAttributeIncrement( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iInc64 ) ;
            Min := iMin64 ;
            Max := iMax64 ;
            Increment := iInc64 ;
            end;

         else begin
            IMAQdxGetAttributeMinimum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @DMin ) ;
            IMAQdxGetAttributeMaximum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @DMax ) ;
            IMAQdxGetAttributeIncrement( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @DInc ) ;
            Min := Round(DMin) ;
            Max := Round(DMax) ;
            Increment := Round(DInc) ;
            end;
         end ;
     outputdebugstring(pchar(format('%s %d, %d',[Session.Attributes[iAttr].Name,Min,Max])));
     end;


procedure IMAQDX_GetAttrRange(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Min : Integer ;
          var Max : Integer ;
          var Increment : Integer ) ; overload ;
// -------------------------------------------------------------
// Get upper and lower limits of attribute range (return as 32 bit)
// -------------------------------------------------------------
var
    iMin32,iMax32,iInc32 : Integer ;
    iMin64,iMax64,iInc64 : Int64 ;
    DMin,DMax,DInc : Double ;
begin

     if iAttr < 0 then Exit ;

     case Session.Attributes[iAttr].iType of

         IMAQdxAttributeTypeU32 : begin
            IMAQdxGetAttributeMinimum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMin32 ) ;
            IMAQdxGetAttributeMaximum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMax32 ) ;
            IMAQdxGetAttributeIncrement( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iInc32 ) ;
            Min := iMin32 ;
            Max := iMax32 ;
            Increment := iInc32 ;
            end;

         IMAQdxAttributeTypeI64 : begin
            IMAQdxGetAttributeMinimum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMin64 ) ;
            IMAQdxGetAttributeMaximum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iMax64 ) ;
            IMAQdxGetAttributeIncrement( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @iInc64 ) ;
            Min := iMin64 ;
            Max := iMax64 ;
            Increment := iInc64 ;
            end;

         else begin
            IMAQdxGetAttributeMinimum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @DMin ) ;
            IMAQdxGetAttributeMaximum( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @DMax ) ;
            IMAQdxGetAttributeIncrement( Session.id,
                                       Session.Attributes[iAttr].Name,
                                       Session.Attributes[iAttr].iType,
                                       @DInc ) ;
            Min := Round(DMin) ;
            Max := Round(DMax) ;
            Increment := ROund(DInc) ;
            end;
         end ;
     outputdebugstring(pchar(format('%s %d, %d',[Session.Attributes[iAttr].Name,Min,Max])));
     end;


procedure IMAQDX_GetAttribute(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Value : Double ) ; overload ;
// -------------------------------------
// Get attribute value return as doubele
// -------------------------------------
var
    iValue64 : Int64 ;
    iValue32 : Integer ;
    DValue : Double ;
begin

     if iAttr < 0 then Exit ;

     case Session.Attributes[iAttr].iType of

         IMAQdxAttributeTypeU32 : begin
            IMAQdxGetAttribute( Session.id,
                                Session.Attributes[iAttr].Name,
                                Session.Attributes[iAttr].iType,
                                @iValue32 ) ;
            Value := iValue32 ;
            end;

         IMAQdxAttributeTypeI64 : begin
            IMAQdxGetAttribute( Session.id,
                                Session.Attributes[iAttr].Name,
                                Session.Attributes[iAttr].iType,
                                @iValue64 ) ;
            Value := iValue64 ;
            end;

         else begin
            IMAQdxGetAttribute( Session.id,
                                Session.Attributes[iAttr].Name,
                                Session.Attributes[iAttr].iType,
                                @DValue ) ;
            Value := DValue ;
            end;
         end ;
     end;


procedure IMAQDX_GetAttribute(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Value : Integer ) ; overload ;
// ---------------------------------------------
// Get attribute value return as 32 bit integer
// ---------------------------------------------
var
    iValue64 : Int64 ;
    iValue32 : Integer ;
    DValue : Double ;
begin

     if iAttr < 0 then Exit ;

     case Session.Attributes[iAttr].iType of

         IMAQdxAttributeTypeU32 : begin
            IMAQdxGetAttribute( Session.id,
                                Session.Attributes[iAttr].Name,
                                Session.Attributes[iAttr].iType,
                                @iValue32 ) ;
            Value := iValue32 ;
            end;

         IMAQdxAttributeTypeI64 : begin
            IMAQdxGetAttribute( Session.id,
                                Session.Attributes[iAttr].Name,
                                Session.Attributes[iAttr].iType,
                                @iValue64 ) ;
            Value := iValue64 ;
            end;

         else begin
            IMAQdxGetAttribute( Session.id,
                                Session.Attributes[iAttr].Name,
                                Session.Attributes[iAttr].iType,
                                @DValue ) ;
            Value := Round(DValue) ;
            end;
         end ;
     end;


procedure IMAQDX_GetAttribute(
          var Session : TIMAQDXSession ;
          iAttr : Integer ;
          var Value : Int64 ) ; overload ;
// ---------------------------------------------
// Get attribute value return as 64 bit integer
// ---------------------------------------------
var
    iValue64 : Int64 ;
    iValue32 : Integer ;
    DValue : Double ;
begin

     if iAttr < 0 then Exit ;

     case Session.Attributes[iAttr].iType of

         IMAQdxAttributeTypeU32 : begin
            IMAQdxGetAttribute( Session.id,
                                Session.Attributes[iAttr].Name,
                                Session.Attributes[iAttr].iType,
                                @iValue32 ) ;
            Value := iValue32 ;
            end;

         IMAQdxAttributeTypeI64 : begin
            IMAQdxGetAttribute( Session.id,
                                Session.Attributes[iAttr].Name,
                                Session.Attributes[iAttr].iType,
                                @iValue64 ) ;
            Value := iValue64 ;
            end;

         else begin
            IMAQdxGetAttribute( Session.id,
                                Session.Attributes[iAttr].Name,
                                Session.Attributes[iAttr].iType,
                                @DValue ) ;
            Value := Round(DValue) ;
            end;
         end ;
     end;


function IMAQDX_FindAttribute(
          var Session : TIMAQDXSession ;      // Session record
          Name : ANSIString ;                 // Target name/fragment
          FullMatch : Boolean ) : Integer ;   // Match whole of attribute name
// ----------------------------------------------------
// Find camera attribute matching Name and return index
// ----------------------------------------------------
var
    i : Integer ;
    s : ANSIString ;
    Match : Boolean ;
begin
     Result := -1 ;

     for i := 0 to Session.NumAttributes-1 do begin
         s := IMAQDX_CharArrayToString( Session.Attributes[i].Name) ;
         if FullMatch then begin
            if Uppercase(s) = UpperCase(Name) then Match := True
                                              else Match := False ;
            end
         else Match := ANSIContainsText( s, Name ) ;
         if Match then begin
            Result := i ;
            Break ;
            end ;
         end;
     end ;


procedure IMAQDX_SetVideoMode(
          var Session : TIMAQDXSession ;
          VideoMode : Integer ;
          PixelFormat : Integer ;
          var FrameWidthMax : Integer ;  // Returns camera frame width
          var FrameHeightMax : Integer ; // Returns camera height width
          var NumBytesPerComponent : Integer ; // Returns bytes/pixel
          var PixelDepth : Integer ;        // Returns no. bits/pixel
          var GreyLevelMin : Integer ;      // Min. grey level
          var GreyLevelMax : Integer        // Max. grey level
          ) ;
// --------------
// Set video mode
// --------------
var
    i,Inc32 : Integer ;
begin

      if not Session.CameraOpen then Exit ;

      // Set mode (if available)
      IMAQdx_SetAttribute( Session,
                           Session.AttrVideoMode,
                           Session.VideoModes[VideoMode].Name ) ;

     // Get pixel formats available in this video mode
     if Session.AttrPixelFormat >= 0 then
        begin
        IMAQdxEnumerateAttributeValues( Session.id,
                                        Session.Attributes[Session.AttrPixelFormat].Name,
                                        Nil,
                                        Session.NumPixelFormats ) ;
        IMAQdxEnumerateAttributeValues( Session.id,
                                        Session.Attributes[Session.AttrPixelFormat].Name,
                                        @Session.PixelFormats,
                                        Session.NumPixelFormats ) ;
        end ;

     // Set pixel format
     IMAQDX_SetPixelFormat( Session,
                            PixelFormat,
                            NumBytesPerComponent,
                            PixelDepth,
                            GreyLevelMin,
                            GreyLevelMax ) ;

   //      If Err <> 0 then ShowMessage('Video mode error') ;

      // Set top-left of AOI to 0,0 and binning to 1
      // to ensure that maximum of AOI width and heght correctly reported

      IMAQdx_SetAttribute( Session,Session.AttrXOffset, 0 ) ;
      IMAQdx_SetAttribute( Session,Session.AttrYOffset, 0 ) ;
      IMAQdx_SetAttribute( Session,Session.AttrXBin, 1 ) ;
      IMAQdx_SetAttribute( Session,Session.AttrYBin, 1 ) ;

     // Max. Image height & width
     if Session.AttrWidthMax >= 0 then IMAQdx_GetAttribute(Session,Session.AttrWidthMax,Session.FrameWidthMax )
     else IMAQdx_GetAttrRange( Session, Session.AttrWidth, i, Session.FrameWidthMax, Inc32 ) ;

     if Session.AttrHeightMax >= 0 then IMAQdx_GetAttribute(Session,Session.AttrHeightMax,Session.FrameHeightMax )
     else IMAQdx_GetAttrRange( Session, Session.AttrHeight, i, Session.FrameHeightMax, Inc32 ) ;

     FrameWidthMax := Session.FrameWidthMax ;
     FrameHeightMax := Session.FrameHeightMax ;

     end ;


{function IMAQDX_GetVideoMode(
          var Session : TIMAQDXSession ) : Integer ;
// --------------
// Get video mode
// --------------
var
    Mode : TIMAQdxEnumItem ;
begin
      if Session.AttrVideoMode >= 0 then begin
         IMAQdx_GetAttributeEnum( Session.id,
                                  Session.Attributes[Session.AttrVideoMode].Name,
                                  IMAQdxAttributeTypeU32,
                                  @Mode) ;
         Result := Mode ;
         end
      else Result := 0 ;

      end ;       }


procedure IMAQDX_SetPixelFormat(
          var Session : TIMAQDXSession ;
          var PixelFormat : Integer ;               // Video mode
          var NumBytesPerComponent : Integer ; // Returns bytes/pixel
          var PixelDepth : Integer ;        // Returns no. bits/pixel
          var GreyLevelMin : Integer ;      // Min. grey level
          var GreyLevelMax : Integer        // Max. grey level
          ) ;
// ----------------
// Set pixel format
// ----------------
var
  i : Integer ;
begin

    if not Session.CameraOpen then Exit ;

    // Set pixel format (if attribute available)
    if Session.AttrPixelFormat < 0 then PixelFormat := 0 ;

     PixelFormat := Max(Min(PixelFormat,Session.NumPixelFormats-1),0);
     Session.PixelFormat := PixelFormat ;

     IMAQdx_SetAttribute( Session,
                          Session.AttrPixelFormat,
                          Session.PixelFormats[PixelFormat].Name ) ;

     // Set image format
     if ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'RGB') and
        ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'8')then begin
        Session.PixelFormatType := pfRGB8 ;
        Session.NumPixelComponents := 3 ;
        Session.UseComponent := 1 ;
        PixelDepth := 8 ;
        end
     else if ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'YUV 422') then begin
        Session.PixelFormatType := pfYUV422 ;
        Session.NumPixelComponents := 2 ;
        Session.UseComponent := 1 ;
        PixelDepth := 8 ;
        end
     else if ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'Mono') and
             ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'8')then begin
        Session.PixelFormatType := pfMono8 ;
        Session.NumPixelComponents := 1 ;
        Session.UseComponent := 0 ;
        PixelDepth := 8 ;
        end
     else if ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'Mono') and
        ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'12')then begin
        if ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'IIDC') then Session.PixelFormatType := pfMono12PackedIIDC
        else if ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'packed') then Session.PixelFormatType := pfMono12Packed
        else Session.PixelFormatType := pfMono12 ;
        Session.NumPixelComponents := 1 ;
        Session.UseComponent := 0 ;
        PixelDepth := 12 ;
        end
     else if ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'Mono') and
        ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'16')then begin
        Session.PixelFormatType := pfMono16 ;
        Session.NumPixelComponents := 1 ;
        Session.UseComponent := 0 ;
        PixelDepth := 16 ;
        end
     else if ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'BGRA') and
        ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'8')then begin
        Session.PixelFormatType := pfBGRA8 ;
        Session.NumPixelComponents := 4 ;
        Session.UseComponent := 1 ;
        PixelDepth := 8 ;
        end
     else if ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'BGR') and
        ANSIContainsText(String(Session.PixelFormats[Session.PixelFormat].Name),'8')then begin
        Session.PixelFormatType := pfBGR8 ;
        Session.NumPixelComponents := 3 ;
        Session.UseComponent := 1 ;
        PixelDepth := 8 ;
        end
     else begin
        Session.PixelFormatType := pfUnknown ;
        Session.NumPixelComponents := 1 ;
        Session.UseComponent := 0 ;
        PixelDepth := 8 ;
        end ;

     // Bytes per pixel
     if PixelDepth <= 8 then Session.NumBytesPerComponent := 1
                        else Session.NumBytesPerComponent := 2 ;
     NumBytesPerComponent := Session.NumBytesPerComponent ;

     GreyLevelMin := 0 ;
     GreyLevelMax := 1 ;
     for i := 1 to PixelDepth do  GreyLevelMax := GreyLevelMax*2 ;
     GreyLevelMax := GreyLevelMax - 1 ;

     end ;


procedure IMAQDX_CheckROIBoundaries( var Session : TIMAQDXSession ;
                                   var FrameLeft : Integer ;
                                   var FrameRight : Integer ;
                                   var FrameTop : Integer ;
                                   var FrameBottom : Integer ;
                                   var BinFactor : Integer ;
                                   var FrameWidth : Integer ;
                                   var FrameHeight : Integer ;
                                   Var FrameInterval : double ;
                                   var ReadoutTime : double
                                   ) ;
// -------------------------------
// Ensure ROI boundaries are valid
// -------------------------------
var
    DMin,DMax,DInc : double ;
begin

      if not Session.CameraOpen then Exit ;

      FrameLeft := Min(Max(FrameLeft,0),Session.FrameWidthMax-1) ;
      FrameTop := Min(Max(FrameTop,0),Session.FrameHeightMax-1) ;
      FrameRight := Min(Max(FrameRight,FrameLeft),Session.FrameWidthMax-1) ;
      FrameBottom := Min(Max(FrameBottom,FrameTop),Session.FrameHeightMax-1) ;

      FrameLeft := FrameLeft div BinFactor ;
      FrameTop := FrameTop div BinFactor ;
      FrameRight := FrameRight div BinFactor ;
      FrameBottom := FrameBottom div BinFactor ;

      // Set horizontal binning
      BinFactor := IMAQdx_SetAttribute( Session,Session.AttrXBin, BinFactor ) ;

      // Set vertical binning
      BinFactor := IMAQdx_SetAttribute( Session,Session.AttrYBin, BinFactor ) ;

      // Left edge of CCD readout area
      {FrameLeft :=} IMAQdx_SetAttribute( Session,Session.AttrXOffset, FrameLeft ) ;

      // Set top edge of CCD readout areas
      {FrameTop :=} IMAQdx_SetAttribute( Session,Session.AttrYOffset, FrameTop ) ;

      // Set width of CCD readout areas
      FrameWidth := FrameRight - FrameLeft + 1 ;
      FrameWidth := IMAQdx_SetAttribute( Session,Session.AttrWidth, FrameWidth ) ;

      // Set height of CCD readout areas
      FrameHeight := FrameBottom - FrameTop + 1 ;
      FrameHeight := IMAQdx_SetAttribute( Session,Session.AttrHeight, FrameHeight ) ;

     FrameRight := (FrameLeft + FrameWidth)*BinFactor -1;
     FrameBottom := (FrameTop + FrameHeight)*BinFactor -1;
     FrameLeft := FrameLeft*BinFactor ;
     FrameTop := FrameTop*BinFactor ;
     Session.FrameHeight := FrameHeight ;
     Session.FrameWidth := FrameWidth ;

     // Get min/max exposure time limits
     DMin := 1E-4 ;
     DMax := 1E4 ;
     IMAQdx_GetAttrRange( Session, Session.AttrAcquisitionFrameRate, DMin, DMax,DInc ) ;
     ReadoutTime := 1.0/DMax ;
     FrameInterval := Min(Max(FrameInterval,ReadoutTime),1.0/DMin);

     end ;


procedure IMAQDX_CloseCamera(
          var Session : TIMAQDXSession     // Camera session #
          ) ;
// ----------------
// Shut down camera
// ----------------
begin

     if not LibraryLoaded then Exit ;

     // Stop any acquisition which is in progress
     IMAQDX_StopCapture( Session ) ;

    // Close camera
    IMAQDX_CheckError(IMAQdxCloseCamera( Session.ID )) ;
    Session.CameraOpen := False ;

    // Unload library
    FreeLibrary(libraryHnd) ;
    LibraryLoaded := False ;

    end ;


function IMAQDX_StartCapture(
         var Session : TIMAQDXSession ;          // Camera session #
         var FrameInterval : Double ;      // Frame exposure interval (s)
         AdditionalReadoutTime : Double ;  // Additional readout time
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
         MonochromeImage : Boolean       // TRUE = extract monochrome image
         ) : Boolean ;
// -------------------
// Start frame capture
// -------------------
var
    FrameRight,FrameBottom : Integer ;
    ExposureTime,FrameRate : Double ;
    DMin,DMax,DInc : DOuble ;
    ReadOutTime : Double ;
begin

      // Stop any acquisition which is in progress
      if Session.AcquisitionInProgress then begin
          IMAQDX_StopCapture( Session ) ;
          end ;

      // Set monochrome image extraction flag
      Session.MonochromeImage := MonochromeImage ;

      // Set camera gain
      // Set gain mode to manual
      IMAQdx_SetAttribute( Session, Session.AttrGainMode, 'manual' ) ;
      IMAQdx_SetAttribute( Session, Session.AttrGainAuto, 'Off' ) ;
      IMAQdx_SetAttribute( Session, Session.AttrGain, Session.GainMin + AmpGain ) ;

      // Set AOI boundaries
      FrameRight := FrameLeft + FrameWidth - 1 ;
      FrameBottom := FrameTop + FrameHeight - 1 ;
      IMAQDX_CheckROIBoundaries( Session,
                                 FrameLeft,
                                 FrameRight,
                                 FrameTop,
                                 FrameBottom,
                                 BinFactor,
                                 FrameWidth,
                                 FrameHeight,
                                 ExposureTime,
                                 ReadOutTime) ;

     // Set exposure time
     IMAQdx_SetAttribute( Session, Session.AttrExposureMode, 'Timed' ) ;

     // Internal/external triggering of frame capture

     if ExternalTrigger = CamFreeRun then begin
        // Free run trigger mode
        // ---------------------
        IMAQdx_SetAttribute( Session,Session.AttrTriggerMode, 'Off' ) ;
        // Set frame rate
        IMAQdx_SetAttribute( Session, Session.AttrAcquisitionFrameRateEnabled, True ) ;
        FrameRate := 1.0/FrameInterval ;
        FrameRate := IMAQdx_SetAttribute( Session, Session.AttrAcquisitionFrameRate, FrameRate ) ;
        IMAQdx_GetAttribute( Session, Session.AttrAcquisitionFrameRate, FrameRate ) ;
        // Set exposure time to match frame rate
        ExposureTime :=  (1.0/FrameRate)*IMAQDX_ExposureTimeScale( Session ) ;
        IMAQdx_SetAttribute( Session, Session.AttrExposureTime, ExposureTime ) ;

        end
     else begin
        // External trigger
        // ----------------
        IMAQdx_SetAttribute( Session,Session.AttrTriggerMode, 'on' ) ;
        IMAQdx_SetAttribute( Session,Session.AttrTriggerSelector, 'frame start' ) ;   // Trigger frame
        IMAQdx_SetAttribute( Session,Session.AttrTriggerSource, 'line 1' ) ;     // Line 1
        IMAQdx_SetAttribute( Session,Session.AttrTriggerActivation, 'rising edge' ) ; //Rising Edge

        // Set camera exposure time.
        // Note 0.0005 s added to readout time because extra time seems to be required in
        // triggered mode.
        IMAQdx_GetAttrRange( Session, Session.AttrAcquisitionFrameRate, DMin, DMax,DInc ) ;
        ReadoutTime := (1.0/DMax) + 0.0005 ;
        ExposureTime := (FrameInterval - ReadOutTime - AdditionalReadoutTime)*IMAQDX_ExposureTimeScale( Session ) ;
        // Keep within min/max exposure time limits
        IMAQdx_GetAttrRange( Session, Session.AttrExposureTime, DMin, DMax,DInc) ;
        ExposureTime := Min(Max(ExposureTime,DMin),DMax);
        IMAQdx_SetAttribute( Session, Session.AttrExposureTime, ExposureTime ) ;

        end ;

      // Allocate camera buffer
      if Session.Buf <> Nil then FreeMem(Session.Buf) ;
      Session.BufSize := Session.FrameWidthMax*Session.FrameHeightMax*
                         Session.NumPixelComponents*Session.NumBytesPerComponent ;
      GetMem( Session.Buf, Session.BufSize ) ;

      // Set up ring buffer
      IMAQDX_CheckError( IMAQdxConfigureAcquisition( Session.ID,1,NumFramesInBuffer)) ;

      Session.NumFramesInBuffer := NumFramesInBuffer ;
      Session.FrameBufPointer := PFrameBuffer ;
      Session.NumBytesPerFrame := NumBytesPerFrame ;
      Session.BufferIndex := 0 ;
      Session.FrameCounter := 0 ;
      Session.FrameHeight := FrameHeight ;
      Session.FrameWidth := FrameWidth ;
      Session.FrameLeft := FrameLeft ;
      Session.FrameTop := FrameTop ;

     // Start acquisition
     IMAQDX_CheckError(IMAQdxStartAcquisition(Session.id));

     Result := True ;
     Session.AcquisitionInProgress := True ;
     Session.SingleImage := False ;

     end;


function IMAQDX_SnapImage(
         var Session : TIMAQDXSession ;          // Camera session #
         var FrameInterval : Double ;      // Frame exposure interval (s)
         AdditionalReadoutTime : Double ;  // Additional readout time
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
         MonochromeImage : Boolean       // TRUE = extract monochrome image
         ) : Boolean ;
// ----------------------
// Acquire a single image
// ----------------------
var
    FrameRight,FrameBottom : Integer ;
    ExposureTime,FrameRate : Double ;
    DMin,DMax,DInc : DOuble ;
    ReadOutTime : Double ;
begin

      // Stop any acquisition which is in progress
      if Session.AcquisitionInProgress then begin
          IMAQDX_StopCapture( Session ) ;
          end ;

      // Set monochrome image extraction flag
      Session.MonochromeImage := MonochromeImage ;

      // Set camera gain
      // Set gain mode to manual
      IMAQdx_SetAttribute( Session, Session.AttrGainMode, 'manual' ) ;
      IMAQdx_SetAttribute( Session, Session.AttrGainAuto, 'Off' ) ;
      IMAQdx_SetAttribute( Session, Session.AttrGain, Session.GainMin + AmpGain ) ;

      // Set AOI boundaries
      FrameRight := FrameLeft + FrameWidth - 1 ;
      FrameBottom := FrameTop + FrameHeight - 1 ;
      IMAQDX_CheckROIBoundaries( Session,
                                 FrameLeft,
                                 FrameRight,
                                 FrameTop,
                                 FrameBottom,
                                 BinFactor,
                                 FrameWidth,
                                 FrameHeight,
                                 ExposureTime,
                                 ReadOutTime) ;

     // Set exposure time
     IMAQdx_SetAttribute( Session, Session.AttrExposureMode, 'Timed' ) ;

     // Internal/external triggering of frame capture

     if ExternalTrigger = CamFreeRun then begin
        // Free run trigger mode
        // ---------------------
        IMAQdx_SetAttribute( Session,Session.AttrTriggerMode, 'Off' ) ;
        // Set frame rate
        IMAQdx_SetAttribute( Session, Session.AttrAcquisitionFrameRateEnabled, True ) ;
        FrameRate := 1.0/FrameInterval ;
        FrameRate := IMAQdx_SetAttribute( Session, Session.AttrAcquisitionFrameRate, FrameRate ) ;
        IMAQdx_GetAttribute( Session, Session.AttrAcquisitionFrameRate, FrameRate ) ;
        // Set exposure time to match frame rate
        ExposureTime :=  (1.0/FrameRate)*IMAQDX_ExposureTimeScale( Session ) ;
        IMAQdx_SetAttribute( Session, Session.AttrExposureTime, ExposureTime ) ;

        end
     else begin
        // External trigger
        // ----------------
        IMAQdx_SetAttribute( Session,Session.AttrTriggerMode, 'on' ) ;
        IMAQdx_SetAttribute( Session,Session.AttrTriggerSelector, 'frame start' ) ;   // Trigger frame
        IMAQdx_SetAttribute( Session,Session.AttrTriggerSource, 'line 1' ) ;     // Line 1
        IMAQdx_SetAttribute( Session,Session.AttrTriggerActivation, 'rising edge' ) ; //Rising Edge

        // Set camera exposure time.
        // Note 0.0005 s added to readout time because extra time seems to be required in
        // triggered mode.
        IMAQdx_GetAttrRange( Session, Session.AttrAcquisitionFrameRate, DMin, DMax,DInc ) ;
        ReadoutTime := (1.0/DMax) + 0.0005 ;
        ExposureTime := (FrameInterval - ReadOutTime - AdditionalReadoutTime)*IMAQDX_ExposureTimeScale( Session ) ;
        // Keep within min/max exposure time limits
        IMAQdx_GetAttrRange( Session, Session.AttrExposureTime, DMin, DMax,DInc) ;
        ExposureTime := Min(Max(ExposureTime,DMin),DMax);
        IMAQdx_SetAttribute( Session, Session.AttrExposureTime, ExposureTime ) ;

        end ;

      // Allocate camera buffer
      if Session.Buf <> Nil then FreeMem(Session.Buf) ;
      Session.BufSize := Session.FrameWidthMax*Session.FrameHeightMax*
                         Session.NumPixelComponents*Session.NumBytesPerComponent ;
      GetMem( Session.Buf, Session.BufSize ) ;

      // Set up ring buffer to acquire a single image
      IMAQDX_CheckError( IMAQdxConfigureAcquisition( Session.ID,0,NumFramesInBuffer)) ;

      Session.NumFramesInBuffer := NumFramesInBuffer ;
      Session.FrameBufPointer := PFrameBuffer ;
      Session.NumBytesPerFrame := NumBytesPerFrame ;
      Session.BufferIndex := 0 ;
      Session.FrameCounter := 0 ;
      Session.FrameHeight := FrameHeight ;
      Session.FrameWidth := FrameWidth ;
      Session.FrameLeft := FrameLeft ;
      Session.FrameTop := FrameTop ;

     // Start acquisition
     IMAQDX_CheckError(IMAQdxStartAcquisition(Session.id));

     Result := True ;
     Session.AcquisitionInProgress := True ;
     Session.SingleImage := True ;

     end;


function IMAQDX_ExposureTimeScale(
         var Session : TIMAQDXSession ) : double ;
// -----------------------------------------------------
// Resturn seconds -> exposure time units scaling factor
// -----------------------------------------------------
var
    ExpUnits : Array[0..255] of ANSIChar ;
begin

     Result := 1.0 ;
     if Session.AttrExposureTime = -1 then Exit ;

     IMAQdxGetAttributeUnits( Session.ID,
                               Session.Attributes[Session.AttrExposureTime].Name,
                               ExpUnits,
                               High(ExpUnits));
      if ANSIContainsText( ANSIString(ExpUnits), 'us') then Result := 1E6
      else if ANSIContainsText( ANSIString(ExpUnits), 'ms') then Result := 1E3
      else Result := 1.0 ;
      end;


function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;           // Camera session #
          Attribute : Integer ;
          Value : Int64
          ) : Int64 ; overload ;
// -----------------------------------
// Set attribute (from 64 bit integer)
// -----------------------------------
var
    DValue : Double ;
    i64Value,Inc64,Max64,Min64 : Int64 ;
    i32Value : Integer ;
begin
      outputdebugstring(pchar(format('Int64 %d %s,%d',
      [Attribute,ansistring(Session.Attributes[Attribute].name),Value])));

      Result := Value ;
      if Attribute < 0 then Exit ;
      if not Session.Attributes[Attribute].Writable then Exit ;

      // Keep within min-max limits and incremental steps
      IMAQDX_GetAttrRange( Session, Attribute, Min64,Max64,Inc64) ;
      If Inc64 > 0 then Value := (Value div Inc64)*Inc64 ;
      Value := Min(Max(Value,Min64),Max64) ;
      Result := Value ;

      case Session.Attributes[Attribute].iType of
          IMAQdxValueTypeI64 : begin
             i64Value := Value ;
             IMAQdxSetAttributeI64( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    i64Value) ;
             end ;
          IMAQdxValueTypeF64 : begin
             DValue := Value ;
             IMAQdxSetAttributeF64( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    DValue) ;
             end ;
          else begin
             i32Value := Value ;
             IMAQdxSetAttributeI32( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    i32Value) ;
             end;
          end;

      end ;


function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;           // Camera session #
          Attribute : Integer ;
          Value : Integer
          ): Integer ; overload ;
// -------------
// Set attribute (from 32 bit integer)
// -------------
var
    DValue : Double ;
    i64Value : Int64 ;
    i32Value,Inc32,Max32,Min32 : Integer ;
begin
      outputdebugstring(pchar(format('Int32 %d %s,%d',
      [Attribute,ansistring(Session.Attributes[Attribute].name),Value])));

      Result := Value ;
      if Attribute < 0 then Exit ;
      if not Session.Attributes[Attribute].Writable then Exit ;

      // Keep within min-max limits and incremental steps
      IMAQDX_GetAttrRange( Session, Attribute, Min32,Max32,Inc32) ;
      If Inc32 > 0 then Value := (Value div Inc32)*Inc32 ;
     // Value := Min(Max(Value,Min32),Max32) ;
      Result := Value ;

      case Session.Attributes[Attribute].iType of
          IMAQdxValueTypeI64 : begin
             i64Value := Value ;
             IMAQdxSetAttributeI64( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    i64Value) ;
             end ;
          IMAQdxValueTypeF64 : begin
             DValue := Value ;
             IMAQdxSetAttributeF64( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    DValue) ;
             end ;
          else begin
             i32Value := Value ;
             IMAQdxSetAttributeI32( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    i32Value) ;
             end;
          end;

      end ;


function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;           // Camera session #
          Attribute : Integer ;
          Value : Double
          ) : Double ; overload ;
// -------------
// Set attribute (from double)
// -------------
var
    DValue, DMin,DMax,DInc : Double ;
    i64Value : Int64 ;
    i32Value : Integer ;
begin
      outputdebugstring(pchar(format('double %d %s,%.3g',
      [Attribute,ansistring(Session.Attributes[Attribute].name),Value])));

      Result := Value ;
      if Attribute < 0 then Exit ;
      if not Session.Attributes[Attribute].Writable then Exit ;

      // Keep within min-max limits and incremental steps
      IMAQDX_GetAttrRange( Session, Attribute, DMin,DMax,DInc) ;
      If DInc > 0 then Value := Floor(Value / DInc)*DInc ;
      Value := Min(Max(Value,DMin),DMax) ;
      Result := Value ;

      case Session.Attributes[Attribute].iType of
          IMAQdxValueTypeI64 : begin
             i64Value := Round(Value);
             IMAQdxSetAttributeI64( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    i64Value) ;
             end ;
          IMAQdxValueTypeF64 : begin
             DValue := Value ;
             IMAQdxSetAttributeF64( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    DValue) ;
             end ;
          else begin
             i32Value := Round(Value) ;
             IMAQdxSetAttributeI32( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    i32Value) ;
             end;
          end;

      end ;


function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;           // Camera session #
          Attribute : Integer ;
          Value : string
          ) : string ; overload ;
// -----------------------
// Set enum type attribute
// -----------------------
var
    List : Array[0..100] of TIMAQdxEnumItem ;
    i,nList : Cardinal ;
begin
      outputdebugstring(pchar(format('Int64 %d %s,%s',
      [Attribute,ansistring(Session.Attributes[Attribute].name),Value])));

      Result := Value ;
      if Attribute < 0 then Exit ;
      if not Session.Attributes[Attribute].Writable then Exit ;

      // Get list of attribute values
      IMAQdxEnumerateAttributeValues(  Session.id,
                                       Session.Attributes[Attribute].Name,
                                       Nil,
                                       nList) ;
      IMAQdxEnumerateAttributeValues(  Session.id,
                                       Session.Attributes[Attribute].Name,
                                       @List,
                                       nList) ;

      // Find and set required value in list
      for i := 0 to nList-1 do
         if Lowercase(ANSIString(List[i].Name)) = Lowercase(ANSIString(Value)) then begin
            IMAQdxSetAttributeEnum( Session.id,
                                    Session.Attributes[Attribute].Name,
                                    Session.Attributes[Attribute].iType,
                                    List[i]) ;
            end ;

      end ;


function IMAQDX_SetAttribute(
          var Session : TIMAQDXSession ;           // Camera session #
          Attribute : Integer ;
          Value : LongBool
          ) : LongBool ; overload ;
// -----------------------
// Set attribute (boolean)
// -----------------------
var
    BoolVal : LongBool ;
begin

      Result := Value ;
      if Attribute < 0 then Exit ;
      if not Session.Attributes[Attribute].Writable then Exit ;

      outputdebugstring(pchar(format('bool %d %s,%d',
      [Attribute,ansistring(Session.Attributes[Attribute].name),Integer(Value)])));

      case Session.Attributes[Attribute].iType of
          IMAQdxAttributeTypeBool : begin
             BoolVal := Value ;
             IMAQdxSetAttributeBool( Session.id,
                                     Session.Attributes[Attribute].Name,
                                     Session.Attributes[Attribute].iType,
                                     BoolVal) ;
             end ;
          end;

      end ;



procedure IMAQDX_StopCapture(
          var Session : TIMAQDXSession            // Camera session #
          ) ;
// -----------------
// Stop frame capture
// ------------------
begin

     if not Session.AcquisitionInProgress then Exit ;

     // Stop acquisition
     IMAQDX_CheckError(IMAQdxStopAcquisition(Session.ID)) ;

     IMAQDX_CheckError(IMAQdxUnconfigureAcquisition(Session.ID)) ;

     FreeMem( Session.Buf ) ;
     Session.Buf := Nil ;

     Session.AcquisitionInProgress := False ;

     end;


procedure IMAQDX_GetImage(
          var Session : TIMAQDXSession
          ) ;
// -----------------------------------------------------
// Copy images from IMAQ buffer to circular frame buffer
// -----------------------------------------------------
var
    Err,LatestFrameTransferred,iLeft,iTop,nWidthMax : Integer ;
    PToBuf : Pointer ;
    ActualBufferNumber,NumCopied : Cardinal ;
    LatestFrameCount : Int64 ;
begin

    if not Session.AcquisitionInProgress then Exit ;
    if Session.AttrAcqInProgress < 0 then Exit ;
    if Session.AttrLastBufferNumber < 0 then Exit ;
    if Session.AttrLastBufferCount < 0 then Exit ;

    if Session.SingleImage and (Session.FrameCounter >= 1) then Exit ;

    // If no buffers yet .. exit
    IMAQdx_GetAttribute( Session,Session.AttrLastBufferCount,LatestFrameCount);
    if LatestFrameCount <= 0 then Exit ;

    // Get latest buffer
    IMAQdx_GetAttribute( Session,Session.AttrLastBufferNumber,LatestFrameTransferred);

    // Copy all new frames to output buffer

    NumCopied := 0 ;
    while (LatestFrameTransferred > Session.FrameCounter) and
          (NumCopied < Session.NumFramesInBuffer) do begin

       // Try to read latest frame
       Err := IMAQdxGetImageData( Session.id,
                              Session.Buf,
                              Session.BufSize,
                              IMAQdxBufferNumberModeBufferNumber,
                              Session.FrameCounter,
                              ActualBufferNumber);

       IMAQDX_CheckError( Err ) ;
       if Err = 0 then begin
          // If frame available copy to output to frame buffer
          PToBuf := Pointer( NativeUInt(Session.BufferIndex)*NativeUInt(Session.NumBytesPerFrame)
                             + NativeUInt(PByte(Session.FrameBufPointer)) ) ;


          if Session.AOIAvailable then begin
             // On-camera AOI available, copy whole image from buffer
             iLeft := 0 ;
             iTop := 0 ;
             nWidthMax := Session.FrameWidth ;
             end
          else begin
             // Software AOI, copy sub-area from buffer
             iLeft := Session.FrameLeft ;
             iTop := Session.FrameTop ;
             nWidthMax := Session.FrameWidthMax ;
             end ;

          // Copy image and convert image format

          case Session.PixelFormatType of
             pfMono12Packed : IMAQDX_CopyImageMono12Packed(Session,iLeft,iTop,Session.FrameWidth,Session.FrameHeight,nWidthMax, PToBuf) ;
             pfMono12PackedIIDC : IMAQDX_CopyImageMono12PackedIIDC(Session,iLeft,iTop,Session.FrameWidth,Session.FrameHeight,nWidthMax, PToBuf) ;
             pfMono8,pfMono16,pfUnknown : IMAQDX_CopyImageMono(Session,iLeft,iTop,Session.FrameWidth,Session.FrameHeight,nWidthMax, PToBuf) ;
             pfBGRA8,pfBGR8 : begin
                if Session.MonochromeImage then begin
                   IMAQDX_CopyImageMono(Session,iLeft,iTop,Session.FrameWidth,Session.FrameHeight,nWidthMax, PToBuf) ;
                   end
                else begin
                   IMAQDX_CopyImageBGRA(Session,iLeft,iTop,Session.FrameWidth,Session.FrameHeight,nWidthMax, PToBuf) ;
                   end ;
                end;
             pfRGB8 : begin
                if Session.MonochromeImage then begin
                   IMAQDX_CopyImageMono(Session,iLeft,iTop,Session.FrameWidth,Session.FrameHeight,nWidthMax, PToBuf) ;
                   end
                else begin
                   IMAQDX_CopyImageRGB(Session,iLeft,iTop,Session.FrameWidth,Session.FrameHeight,nWidthMax, PToBuf) ;
                   end ;
                end;
             end ;

          // Increment circular output buffer index
          Inc(Session.BufferIndex) ;
          if Session.BufferIndex >= Session.NumFramesInBuffer then Session.BufferIndex := 0 ;
          // Increment next buffer counter
          Inc(Session.FrameCounter) ;
          Inc(NumCopied) ;
          end ;
       end ;

    end ;

procedure IMAQDX_CopyImage(
          pFromBuf : Pointer ;   // pointer to image source
          pToBuf : Pointer ;     // pointer to image destination
          iStart : Integer ;     // Starting pixel component
          iStep : Integer ;      // pixel step
          nCopy : Integer ;      // no. of pixels to copy
          NumBytesPerPixel : Integer // No. bytes per pixel
          ) ;
// --------------------------------------------
// Copy image from source to destination buffer
// --------------------------------------------
var
    i,j : Integer ;
begin

    if NumBytesPerPixel = 1 then begin
        // 1 byte per pixel
        j := iStart ;
        for i := 0 to nCopy-1 do begin
            PByteArray(PToBuf)^[i] := PByteArray(pFromBuf)^[j] ;
            j := j + iStep ;
            end ;
        end
    else begin
        // two byte pixels
        j := iStart ;
        for i := 0 to nCopy-1 do begin
            PWordArray(PToBuf)^[i] := PWordArray(pFromBuf)^[j] ;
            j := j + iStep ;
            end ;
        end ;
    end;


procedure IMAQDX_CopyImageMono(
          var Session : TIMAQDXSession ;  // Session record
          xLeft : Integer ;               // Start copy at column X
          yTop : Integer ;                // Start copy at row Y
          FrameWidth : Integer ;          // Height of area to copy
          FrameHeight : Integer ;         // Height of area to copy
          FrameWidthMax : Integer ;       // Width of line
          pToBuf : Pointer                // pointer to image destination
          ) ;
// ---------------------------------------------------------------
// Copy monochrome image from source to destination buffer in RGB format
// ---------------------------------------------------------------
var
    x,y,ifrom,ito : Integer ;
begin

    if Session.NumBytesPerComponent = 1 then
        begin
        // 1 bytes per component
        ito := 0 ;
        for y := yTop to yTop + FrameHeight -1 do
            begin
            ifrom := (y*FrameWidthMax + xLeft)*Session.NumPixelComponents + Session.UseComponent ;
            for x := 0 to FrameWidth -1 do
                begin
                PByteArray(PToBuf)^[ito] := PByteArray(Session.Buf)^[ifrom] ;
                ifrom := ifrom + Session.NumPixelComponents ;
                Inc(ito) ;
                end ;
            end ;
        end
    else
        begin
        // 2 bytes per component
        ito := 0 ;
        for y := yTop to yTop + FrameHeight -1 do
            begin
            ifrom := (y*FrameWidthMax + xLeft)*Session.NumPixelComponents + Session.UseComponent ;
            for x := 0 to FrameWidth -1 do
                begin
                PWordArray(PToBuf)^[ito] := PWordArray(Session.Buf)^[ifrom] ;
                ifrom := ifrom + Session.NumPixelComponents ;
                Inc(ito) ;
                end ;
            end ;
        end;
end;


procedure IMAQDX_CopyImageMono12Packed(
          var Session : TIMAQDXSession ;  // Session record
          xLeft : Integer ;               // Start copy at column X
          yTop : Integer ;                // Start copy at row Y
          FrameWidth : Integer ;          // Height of area to copy
          FrameHeight : Integer ;         // Height of area to copy
          FrameWidthMax : Integer ;       // Width of line
          pToBuf : Pointer                // pointer to image destination
          ) ;
// ---------------------------------------------------------------
// Copy packed Mono 12 pixel from source to destination buffer in
// ---------------------------------------------------------------
var
    x,y,ifrom,ito,FromByte,FromNibble : Integer ;
    LoNibble,HiByte : Word ;
begin

    ito := 0 ;
    for y := yTop to yTop + FrameHeight -1 do begin
        ifrom := (y*FrameWidthMax + xLeft)*Session.NumPixelComponents + Session.UseComponent ;
        for x := 0 to FrameWidth -1 do begin
            FromNibble := iFrom*3 ;
            FromByte := FromNibble div 2 ;
            if (FromNibble mod 6) <> 0 then begin
               LoNibble := (Word(PByteArray(Session.Buf)^[FromByte]) and $F0) shr 4 ;
               HiByte := PByteArray(Session.Buf)^[FromByte+1] ;
               PWordArray(PToBuf)^[ito] := (HiByte shl 4) + LoNibble ;
               end
            else begin
               HiByte := PByteArray(Session.Buf)^[FromByte] ;
               LoNibble := Word(PByteArray(Session.Buf)^[FromByte+1]) and $F ;
               PWordArray(PToBuf)^[ito] := HiByte + (LoNibble shl 8);
               end;
            ifrom := ifrom + Session.NumPixelComponents ;
            Inc(ito) ;
            end ;
       end;
    end;


procedure IMAQDX_CopyImageMono12PackedIIDC(
          var Session : TIMAQDXSession ;  // Session record
          xLeft : Integer ;               // Start copy at column X
          yTop : Integer ;                // Start copy at row Y
          FrameWidth : Integer ;          // Height of area to copy
          FrameHeight : Integer ;         // Height of area to copy
          FrameWidthMax : Integer ;       // Width of line
          pToBuf : Pointer                // pointer to image destination
          ) ;
// ----------------------------------------------------------------
// Copy packed Mono 12 IIDC pixel from source to destination buffer
// ----------------------------------------------------------------
var
    x,y,ifrom,ito,FromByte,FromNibble : Integer ;
    LoNibble,HiByte : Word ;
begin

    ito := 0 ;
    for y := yTop to yTop + FrameHeight -1 do begin
        ifrom := (y*FrameWidthMax + xLeft)*Session.NumPixelComponents + Session.UseComponent ;
        for x := 0 to FrameWidth -1 do begin
            FromNibble := iFrom*3 ;
            FromByte := FromNibble div 2 ;
            if (FromNibble mod 6) <> 0 then begin
               LoNibble := (Word(PByteArray(Session.Buf)^[FromByte]) and $F0) shr 4 ;
               HiByte := PByteArray(Session.Buf)^[FromByte+1] ;
               PWordArray(PToBuf)^[ito] := (HiByte shl 4) + LoNibble ;
               end
            else begin
               HiByte := PByteArray(Session.Buf)^[FromByte] ;
               LoNibble := Word(PByteArray(Session.Buf)^[FromByte+1]) and $F ;
               PWordArray(PToBuf)^[ito] := (HiByte shl 4) + LoNibble ;
               end;

            ifrom := ifrom + Session.NumPixelComponents ;
            Inc(ito) ;
            end ;
       end;
    end;


procedure IMAQDX_CopyImageRGB(
          var Session : TIMAQDXSession ;  // Session record
          xLeft : Integer ;               // Start copy at column X
          yTop : Integer ;                // Start copy at row Y
          FrameWidth : Integer ;          // Height of area to copy
          FrameHeight : Integer ;         // Height of area to copy
          FrameWidthMax : Integer ;       // Width of line
          pToBuf : Pointer                // pointer to image destination
          ) ;
// ---------------------------------------------------------------
// Copy RGB image from source to destination buffer in RGB format
// ---------------------------------------------------------------
var
    x,y,ifrom,ito : Integer ;
begin

    if Session.NumBytesPerComponent = 1 then begin
        // 1 bytes per component
        ito := 0 ;
        for y := yTop to yTop + FrameHeight -1 do begin
            ifrom := (y*FrameWidthMax + xLeft)*Session.NumPixelComponents ;
            for x := 0 to FrameWidth -1 do begin
                PByteArray(PToBuf)^[ito] := PByteArray(Session.Buf)^[ifrom] ;
                PByteArray(PToBuf)^[ito+1] := PByteArray(Session.Buf)^[ifrom+1] ;
                PByteArray(PToBuf)^[ito+2] := PByteArray(Session.Buf)^[ifrom+2] ;
                ifrom := ifrom + Session.NumPixelComponents ;
                ito := ito + 3 ;
                end ;
            end ;
        end
    else begin
        // 2 bytes per component
        ito := 0 ;
        for y := yTop to yTop + FrameHeight -1 do begin
            ifrom := (y*FrameWidthMax + xLeft)*Session.NumPixelComponents + Session.UseComponent ;
            for x := 0 to FrameWidth -1 do begin
                PWordArray(PToBuf)^[ito] := PWordArray(Session.Buf)^[ifrom] ;
                PWordArray(PToBuf)^[ito+1] := PWordArray(Session.Buf)^[ifrom+1] ;
                PWordArray(PToBuf)^[ito+2] := PWordArray(Session.Buf)^[ifrom+2] ;
                ifrom := ifrom + Session.NumPixelComponents ;
                ito := ito + 3 ;
                end ;
            end ;
       end;
    end;


procedure IMAQDX_CopyImageBGRA(
          var Session : TIMAQDXSession ;  // Session record
          xLeft : Integer ;               // Start copy at column X
          yTop : Integer ;                // Start copy at row Y
          FrameWidth : Integer ;          // Height of area to copy
          FrameHeight : Integer ;         // Height of area to copy
          FrameWidthMax : Integer ;       // Width of line
          pToBuf : Pointer                // pointer to image destination
          ) ;
// ---------------------------------------------------------------
// Copy BGRA image from source to destination buffer in RGB format
// ---------------------------------------------------------------
var
    x,y,ifrom,ito : Integer ;
begin

    if Session.NumBytesPerComponent = 1 then begin
        // 1 bytes per component
        ito := 0 ;
        for y := yTop to yTop + FrameHeight -1 do begin
            ifrom := (y*FrameWidthMax + xLeft)*Session.NumPixelComponents ;
            for x := 0 to FrameWidth -1 do begin
                PByteArray(PToBuf)^[ito] := PByteArray(Session.Buf)^[ifrom+2] ;
                PByteArray(PToBuf)^[ito+1] := PByteArray(Session.Buf)^[ifrom+1] ;
                PByteArray(PToBuf)^[ito+2] := PByteArray(Session.Buf)^[ifrom] ;
                ifrom := ifrom + Session.NumPixelComponents ;
                ito := ito + 3 ;
                end ;
            end ;
        end
    else begin
        // 2 bytes per component
        ito := 0 ;
        for y := yTop to yTop + FrameHeight -1 do begin
            ifrom := (y*FrameWidthMax + xLeft)*Session.NumPixelComponents + Session.UseComponent ;
            for x := 0 to FrameWidth -1 do begin
                PWordArray(PToBuf)^[ito] := PWordArray(Session.Buf)^[ifrom+1] ;
                PWordArray(PToBuf)^[ito+1] := PWordArray(Session.Buf)^[ifrom+1] ;
                PWordArray(PToBuf)^[ito+2] := PWordArray(Session.Buf)^[ifrom] ;
                ifrom := ifrom + Session.NumPixelComponents ;
                ito := ito + 3 ;
                end ;
            end ;
       end;
    end;



procedure IMAQDX_GetCameraGainList(
          var Session : TIMAQDXSession ;
          CameraGainList : TStringList ) ;
// --------------------------------------------
// Get list of available camera amplifier gains
// --------------------------------------------
var
    i : Integer ;
begin

    CameraGainList.Clear ;

    for i  := Session.GainMin to Session.GainMax do begin
        CameraGainList.Add( format( '%d',[i] )) ;
        end;
    end ;


procedure IMAQDX_GetCameraVideoModeList(
          var Session : TIMAQDXSession ;
          List : TStringList ) ;
// --------------------------------------------
// Get list of available camera video mode
// --------------------------------------------
var
    i : Integer ;
begin

    List.Clear ;
    for i := 0 to Session.NumVideoModes-1 do begin
        List.Add(String(Session.VideoModes[i].Name)) ;
        end ;

    end ;


procedure IMAQDX_GetCameraPixelFormatList(
          var Session : TIMAQDXSession ;
          List : TStringList ) ;
// --------------------------------------------
// Get list of available camera video mode
// --------------------------------------------
var
    i : Integer ;
begin

    List.Clear ;
    for i := 0 to Session.NumPixelFormats-1 do begin
        List.Add(String(Session.PixelFormats[i].Name)) ;
        end ;

    end ;


function IMAQDX_CheckFrameInterval(
         var Session : TIMAQDXSession ;
         var FrameInterval : Double
         ) : Integer ;
// -------------------------------------------
// Check that selected frame interval is valid
// -------------------------------------------
var
    RateMin,RateMax,RateInc : Double ;
    IntervalMin,IntervalMax : Double ;
begin
     // Get frame interval (this is a read-only value)
     IMAQdx_GetAttrRange( Session, Session.AttrAcquisitionFrameRate,RateMin,RateMax,RateInc ) ;
     if (RateMax > 0.0) and (RateMin > 0.0) then
        begin
        IntervalMin := 1.0/RateMax ;
        IntervalMax := 1.0/RateMin ;
        FrameInterval := Min(Max(IntervalMin,FrameInterval),IntervalMax);
        end;
     Result := 0 ;
     end ;


procedure IMAQDX_CheckError( ErrNum : Integer ) ;
// ------------
// Report error
// ------------
const
    MaxMsgSize = 256 ;
var
    cBuf : Array[0..MaxMsgSize-1] of ANSIChar ;
    i : Integer ;
    s : string ;
begin

    if ErrNum <> 0 then begin
       for i := 0 to High(cBuf) do cBuf[i] := #0 ;

       IMAQdxGetErrorString( ErrNum, cBuf, MaxMsgSize ) ;
       s := '' ;
       for i := 0 to High(cBuf) do if cBuf[i] <> #0 then s := s + cBuf[i] ;
       ShowMessage( 'IMAQdx: ' + s ) ;
       end ;

    end ;


function IMAQDX_CharArrayToString(
         cBuf : Array of ANSIChar
         ) : String ;
// ---------------------------------
// Convert character array to string
// ---------------------------------
var
     i : Integer ;
begin
     i := 0 ;
     Result := '' ;
     while (cBuf[i] <> #0) and (i <= High(cBuf)) do begin
         Result := Result + cBuf[i] ;
         Inc(i) ;
         end ;
     end ;

function IMAQDX_AttributeAvailable(
         var Session : TIMAQDXSession ;
         AttributeName : PANSIChar ;
         CheckWritable : Boolean
         ) : Boolean ;
// -------------------------------------
// Return TRUE if Attribute is available
// -------------------------------------
var
    i : Integer ;
    s : string ;
begin
      Result := False ;
      for i := 0 to Session.NumAttributes-1 do begin
          s := IMAQDX_CharArrayToString(Session.Attributes[i].Name) ;
          if AnsiContainsText(s,AttributeName) then begin
             if CheckWritable then Result := Session.Attributes[i].Writable
                              else Result := True ;
             Break ;
             end ;
          end ;
      end ;

initialization
    LibraryLoaded := false ;

end.
