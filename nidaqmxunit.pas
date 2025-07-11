unit NidaqMXUnit;
{$O-}
// -------------------------------------
// National Instruments NIDAQ-MX Library
// -------------------------------------
// 14.04.05 Under Test
// 20.04.05 Checked with PCI-6014
// 21.07.05 A/D input mode (Differential, Single Ended) can now be set
// 20.07.05 Error in NIMX_ReadADC fixed
// 14.09.05 A/D samples limited to one less rhan maximum
//          (Temp. fix for hang up problem when signal off limits)
// 09.06.06 Bug in ADCGetSamples which prevented circular buffer recycling
//          under certain timing conditions fixed
// 05.04.07 MemoryToDig now works with boards which have more than 8 bits of digital I/O
//          (e.g. PCI-6229)
// 06.04.07 WriteToDigitalPort no longer reports error when output port not available
// 01.09.07 Default ADC and DAC range parameters now applied when board defined by not detected
//          to avoid FPU errors in calling programs
// 20.08.08 Min. sampling/update interval for 6221/6229 boards now 1E-6s.
// 03.11.08 DAC updates now have separate min. sampling rate check NIMX_CheckDACSamplingInterval
//          NIMX_CheckSamplingInterval renamed to NIMX_CheckADCSamplingInterval
//          GetADCSamples now uses 32 bit read buffer (DAQmxReadBinaryI32) to handle devices with >16 bit ADCs
// 08.12.08 ADCSamplingIntervalInUse and DACUpdateIntervalInUse added so that
//          .ADCSamplingInterval and .DACUpdateInterval properties return correct values
//          when A/D and D/A is running
// 12.12.08 Trigger input for externally triggered MemoryToDAC changed from PFI1 to PFI0
// 03.09.09 NIMX_ReadDigitalInputPort port:0 changed to port0. Digital input now works correctly.
// 24.06.10 Device number (Dev1, Dev2 etc.) can now be selected when device opened.
// 08.09.10 DeviceNumber kept within 1-9 range
// 04.02.11 Min./max. A/D, D/A and digital output clock rates determined
//          and whether clocked D/A and digital output supported
// 07.02.11 Sampling & update intervals now restricted to min/max limits in
//          CheckADCSamplingInterval & CheckDACUpdateInterval
// 28.02.11 Support for USB 6008/9 added. MemorytoToDAC disabled
//          when clocked D/A outputs not supported
// 02.03.11 ... DeviceExists() function added to check whether NI device hardware exist
// 12.07.11 DigMinUpdateInterval now set equal to DACMinUpdateInterval if no digital channels available
// 13.07.11
// 17.08.11 Analog input channels can now have physical input channel number remapped
//          using .ADCChannelInputNumber property (currently only supported for NI boards)
// 10.10.11 NIDAQmx_InitialiseBoard now correctly recognises boards (eg. USB-6210) which
//          do not support D/A outputs and also don't support DAQmxGetDevAOSampClkSupported
//          query.
// 14.10.11 NIMX_GetLabInterfaceInfo now returns DeviceList containing list
//          available NI devices
// 17.10.11 // No error check on analog writes to avoid warning of out of range data
// 28.01.13 DAQmx_Val_PseudoDiff now only used with NI-611X boards (not NI-61XX)
// 23.07.13 Warning message no longer produced when unsupported A/D input mode changed
// 20.08.13 Unnecessary DAQmxResetDevice in NIDAQmx_initialise() removed to speed up
//          initialisation
// 05.11.13 FDACVoltageRange now defaults to 10V when no DACs available
// 14.08.14 DAQmx_Val_Rising changed to DAQmx_Val_Rising in DAQmxCfgSampClkTiming()
//          for compatibility with USB-6002/3
// 11.09.14 GetADCSamples now acquires samples as doubles allowing ADC with more than 16 resolution
//          to be supported.
// 15.09.14 A/D buffer samples/channel limited to 1 million to avoid unable to allocate error with
//          simulated PCI-6281
// 29.07.15 NIMX_GetChannelOffsets() no longer calls NIMX_CheckMaxADCChannels() to avoid it messing up
//          existing ADC task setups
// 05.11.15 USB-6002/3 P1.0->PFI0+PFI1 now used as trigger line for A/D and D/A start synchronisation
//          instead of P0.0->PFI0+PFI1
// 28.04.17 NIMX_CheckMaxADCChannels() now checks channels using +/-5V input range
//          to avoid errors with boards which only support maximum of +/-5V input range
// 21.11.17 D/A update rate of NI USB-600X devices now forced to be no more than 500 Hz to avoid intermittent 5 sec delays when calling .StopADC.
// 25.11.17 Change in special DAQmxSetAIUsbXferReqCount setting for USB06008/9 no longer reset for other devices by NIMX_ADCToMemory to avoid
//          unsupported function error.
// 04.08.21 NIMX_CheckMaxADCChannels() Now much faster, <1ms vs 600ms by using device property
// 09.11.22 Min. AO update interval for USB-600X now reduced from  2ms to 1ms.
// 03.04.23 Digital clock support temporarily disabled for 6353 devices to determine
//          if there is a programming incompatibility with 32 bit Port0
// 24.10.24 LibraryHnd now defined as THandle (not Integer to avoid potential issues in 64 bit compiles)

interface

uses WinTypes,Dialogs, SysUtils, WinProcs, math, mmsystem, strutils, classes ;

const
//******************************************************************************
// *** NI-DAQmx Attributes ******************************************************
// ******************************************************************************/

//********** Calibration Info Attributes **********
    DAQmx_SelfCal_Supported = $1860 ;           // Indicates whether the device supports self calibration.
    DAQmx_SelfCal_LastTemp = $1864 ;            // Indicates in degrees Celsius the temperature of the device at the time of the last self calibration. Compare this temperature to the current onboard temperature to determine if you should perform another calibration.
    DAQmx_ExtCal_RecommendedInterval = $1868 ;  // Indicates in months the National Instruments recommended interval between each external calibration of the device.
    DAQmx_ExtCal_LastTemp =            $1867 ;  // Indicates in degrees Celsius the temperature of the device at the time of the last external calibration. Compare this temperature to the current onboard temperature to determine if you should perform another calibration.
    DAQmx_Cal_UserDefinedInfo =        $1861 ;  // Specifies a string that contains arbitrary, user-defined information. This number of characters in this string can be no more than Max Size.
    DAQmx_Cal_UserDefinedInfo_MaxSize =   $191C ;  // Indicates the maximum length in characters of Information.
    DAQmx_Cal_DevTemp =                $223B ;  // Indicates in degrees Celsius the current temperature of the device.

//********** Channel Attributes **********
    DAQmx_ChanType =                   $187F ; // Indicates the type of the virtual channel.
    DAQmx_PhysicalChanName =           $18F5 ; // Indicates the name of the physical channel upon which this virtual channel is based.
    DAQmx_ChanDescr =                  $1926 ; // Specifies a user-defined description for the channel.
    DAQmx_AI_Max =                     $17DD ; // Specifies the maximum value you expect to measure. This value is in the units you specify with a units property. When you query this property, it returns the coerced maximum value that the device can measure with the current settings.
    DAQmx_AI_Min =                     $17DE ; // Specifies the minimum value you expect to measure. This value is in the units you specify with a units property.  When you query this property, it returns the coerced minimum value that the device can measure with the current settings.
    DAQmx_AI_CustomScaleName =         $17E0 ; // Specifies the name of a custom scale for the channel.
    DAQmx_AI_MeasType =                $0695 ; // Indicates the measurement to take with the analog input channel and in some cases, such as for temperature measurements, the sensor to use.
    DAQmx_AI_Voltage_Units =           $1094 ; // Specifies the units to use to return voltage measurements from the channel.
    DAQmx_AI_Temp_Units =              $1033 ; // Specifies the units to use to return temperature measurements from the channel.
    DAQmx_AI_Thrmcpl_Type =            $1050 ; // Specifies the type of thermocouple connected to the channel. Thermocouple types differ in composition and measurement range.
    DAQmx_AI_Thrmcpl_CJCSrc =          $1035 ; // Indicates the source of cold-junction compensation.
    DAQmx_AI_Thrmcpl_CJCVal =          $1036 ; // Specifies the temperature of the cold junction if CJC Source is DAQmx_Val_ConstVal. Specify this value in the units of the measurement.
    DAQmx_AI_Thrmcpl_CJCChan =         $1034 ; // Indicates the channel that acquires the temperature of the cold junction if CJC Source is DAQmx_Val_Chan. If the channel is a temperature channel, NI-DAQmx acquires the temperature in the correct units. Other channel types, such as a resistance channel with a custom sensor, must use a custom scale to scale values to degrees Celsius.
    DAQmx_AI_RTD_Type =                $1032 ; // Specifies the type of RTD connected to the channel.
    DAQmx_AI_RTD_R0 =                  $1030 ; // Specifies in ohms the sensor resistance at 0 deg C. The Callendar-Van Dusen equation requires this value. Refer to the sensor documentation to determine this value.
    DAQmx_AI_RTD_A =                   $1010 ; // Specifies the 'A' constant of the Callendar-Van Dusen equation. NI-DAQmx requires this value when you use a custom RTD.
    DAQmx_AI_RTD_B =                   $1011 ; // Specifies the 'B' constant of the Callendar-Van Dusen equation. NI-DAQmx requires this value when you use a custom RTD.
    DAQmx_AI_RTD_C =                   $1013 ; // Specifies the 'C' constant of the Callendar-Van Dusen equation. NI-DAQmx requires this value when you use a custom RTD.
    DAQmx_AI_Thrmstr_A =               $18C9 ; // Specifies the 'A' constant of the Steinhart-Hart thermistor equation.
    DAQmx_AI_Thrmstr_B =               $18CB ; // Specifies the 'B' constant of the Steinhart-Hart thermistor equation.
    DAQmx_AI_Thrmstr_C =               $18CA ; // Specifies the 'C' constant of the Steinhart-Hart thermistor equation.
    DAQmx_AI_Thrmstr_R1 =              $1061 ; // Specifies in ohms the value of the reference resistor if you use voltage excitation. NI-DAQmx ignores this value for current excitation.
    DAQmx_AI_ForceReadFromChan =       $18F8 ; // Specifies whether to read from the channel if it is a cold-junction compensation channel. By default, an NI-DAQmx Read function does not return data from cold-junction compensation channels.  Setting this property to TRUE forces read operations to return the cold-junction compensation channel data with the other channels in the task.
    DAQmx_AI_Current_Units =           $0701 ; // Specifies the units to use to return current measurements from the channel.
    DAQmx_AI_Strain_Units =            $0981 ; // Specifies the units to use to return strain measurements from the channel.
    DAQmx_AI_StrainGage_GageFactor =   $0994 ; // Specifies the sensitivity of the strain gage.  Gage factor relates the change in electrical resistance to the change in strain. Refer to the sensor documentation for this value.
    DAQmx_AI_StrainGage_PoissonRatio = $0998 ; // Specifies the ratio of lateral strain to axial strain in the material you are measuring.
    DAQmx_AI_StrainGage_Cfg =          $0982 ; // Specifies the bridge configuration of the strain gages.
    DAQmx_AI_Resistance_Units =        $0955 ; // Specifies the units to use to return resistance measurements.
    DAQmx_AI_Freq_Units =              $0806 ; // Specifies the units to use to return frequency measurements from the channel.
    DAQmx_AI_Freq_ThreshVoltage =      $0815 ; // Specifies the voltage level at which to recognize waveform repetitions. You should select a voltage level that occurs only once within the entire period of a waveform. You also can select a voltage that occurs only once while the voltage rises or falls.
    DAQmx_AI_Freq_Hyst =               $0814 ; // Specifies in volts a window below Threshold Level. The input voltage must pass below Threshold Level minus this value before NI-DAQmx recognizes a waveform repetition at Threshold Level. Hysteresis can improve the measurement accuracy when the signal contains noise or jitter.
    DAQmx_AI_LVDT_Units =              $0910 ; // Specifies the units to use to return linear position measurements from the channel.
    DAQmx_AI_LVDT_Sensitivity =        $0939 ; // Specifies the sensitivity of the LVDT. This value is in the units you specify with Sensitivity Units. Refer to the sensor documentation to determine this value.
    DAQmx_AI_LVDT_SensitivityUnits =   $219A ; // Specifies the units of Sensitivity.
    DAQmx_AI_RVDT_Units =              $0877 ; // Specifies the units to use to return angular position measurements from the channel.
    DAQmx_AI_RVDT_Sensitivity =        $0903 ; // Specifies the sensitivity of the RVDT. This value is in the units you specify with Sensitivity Units. Refer to the sensor documentation to determine this value.
    DAQmx_AI_RVDT_SensitivityUnits =   $219B ; // Specifies the units of Sensitivity.
    DAQmx_AI_SoundPressure_MaxSoundPressureLvl  = $223A ; // Specifies the maximum instantaneous sound pressure level you expect to measure. This value is in decibels, referenced to 20 micropascals. NI-DAQmx uses the maximum sound pressure level to calculate values in pascals for Maximum Value and Minimum Value for the channel.
    DAQmx_AI_SoundPressure_Units =     $1528 ; // Specifies the units to use to return sound pressure measurements from the channel.
    DAQmx_AI_Microphone_Sensitivity =  $1536 ; // Specifies the sensitivity of the microphone. This value is in mV/Pa. Refer to the sensor documentation to determine this value.
    DAQmx_AI_Accel_Units =             $0673 ; // Specifies the units to use to return acceleration measurements from the channel.
    DAQmx_AI_Accel_Sensitivity =       $0692 ; // Specifies the sensitivity of the accelerometer. This value is in the units you specify with Sensitivity Units. Refer to the sensor documentation to determine this value.
    DAQmx_AI_Accel_SensitivityUnits =  $219C ; // Specifies the units of Sensitivity.
    DAQmx_AI_TEDS_Units =              $21E0 ; // Indicates the units defined by TEDS information associated with the channel.
    DAQmx_AI_Coupling =                $0064 ; // Specifies the coupling for the channel.
    DAQmx_AI_Impedance =               $0062 ; // Specifies the input impedance of the channel.
    DAQmx_AI_TermCfg =                 $1097 ; // Specifies the terminal configuration for the channel.
    DAQmx_AI_InputSrc =                $2198 ; // Specifies the source of the channel. You can use the signal from the I/O connector or one of several calibration signals. Certain devices have a single calibration signal bus. For these devices, you must specify the same calibration signal for all channels you connect to a calibration signal.
    DAQmx_AI_ResistanceCfg =           $1881 ; // Specifies the resistance configuration for the channel. NI-DAQmx uses this value for any resistance-based measurements, including temperature measurement using a thermistor or RTD.
    DAQmx_AI_LeadWireResistance =      $17EE ; // Specifies in ohms the resistance of the wires that lead to the sensor.
    DAQmx_AI_Bridge_Cfg =              $0087 ; // Specifies the type of Wheatstone bridge that the sensor is.
    DAQmx_AI_Bridge_NomResistance =    $17EC ; // Specifies in ohms the resistance across each arm of the bridge in an unloaded position.
    DAQmx_AI_Bridge_InitialVoltage =   $17ED ; // Specifies in volts the output voltage of the bridge in the unloaded condition. NI-DAQmx subtracts this value from any measurements before applying scaling equations.
    DAQmx_AI_Bridge_ShuntCal_Enable =  $0094 ; // Specifies whether to enable a shunt calibration switch. Use Shunt Cal Select to select the switch(es) to enable.
    DAQmx_AI_Bridge_ShuntCal_Select =  $21D5 ; // Specifies which shunt calibration switch(es) to enable.  Use Shunt Cal Enable to enable the switch(es) you specify with this property.
    DAQmx_AI_Bridge_ShuntCal_GainAdjust = $193F ; // Specifies the result of a shunt calibration. NI-DAQmx multiplies data read from the channel by the value of this property. This value should be close to 1.0.
    DAQmx_AI_Bridge_Balance_CoarsePot = $17F1 ; // Specifies by how much to compensate for offset in the signal. This value can be between 0 and 127.
    DAQmx_AI_Bridge_Balance_FinePot =  $18F4 ; // Specifies by how much to compensate for offset in the signal. This value can be between 0 and 4095.
    DAQmx_AI_CurrentShunt_Loc =        $17F2 ; // Specifies the shunt resistor location for current measurements.
    DAQmx_AI_CurrentShunt_Resistance = $17F3 ; // Specifies in ohms the external shunt resistance for current measurements.
    DAQmx_AI_Excit_Src =               $17F4 ; // Specifies the source of excitation.
    DAQmx_AI_Excit_Val =               $17F5 ; // Specifies the amount of excitation that the sensor requires. If Voltage or Current is  DAQmx_Val_Voltage, this value is in volts. If Voltage or Current is  DAQmx_Val_Current, this value is in amperes.
    DAQmx_AI_Excit_UseForScaling =     $17FC ; // Specifies if NI-DAQmx divides the measurement by the excitation. You should typically set this property to TRUE for ratiometric transducers. If you set this property to TRUE, set Maximum Value and Minimum Value to reflect the scaling.
    DAQmx_AI_Excit_UseMultiplexed =    $2180 ; // Specifies if the SCXI-1122 multiplexes the excitation to the upper half of the channels as it advances through the scan list.
    DAQmx_AI_Excit_ActualVal =         $1883 ; // Specifies the actual amount of excitation supplied by an internal excitation source.  If you read an internal excitation source more precisely with an external device, set this property to the value you read.  NI-DAQmx ignores this value for external excitation.
    DAQmx_AI_Excit_DCorAC =            $17FB ; // Specifies if the excitation supply is DC or AC.
    DAQmx_AI_Excit_VoltageOrCurrent =  $17F6 ; // Specifies if the channel uses current or voltage excitation.
    DAQmx_AI_ACExcit_Freq =            $0101 ; // Specifies the AC excitation frequency in Hertz.
    DAQmx_AI_ACExcit_SyncEnable =      $0102 ; // Specifies whether to synchronize the AC excitation source of the channel to that of another channel. Synchronize the excitation sources of multiple channels to use multichannel sensors. Set this property to FALSE for the master channel and to TRUE for the slave channels.
    DAQmx_AI_ACExcit_WireMode =        $18CD ; // Specifies the number of leads on the LVDT or RVDT. Some sensors require you to tie leads together to create a four- or five- wire sensor. Refer to the sensor documentation for more information.
    DAQmx_AI_Atten =                   $1801 ; // Specifies the amount of attenuation to use.
    DAQmx_AI_Lowpass_Enable =          $1802 ; // Specifies whether to enable the lowpass filter of the channel.
    DAQmx_AI_Lowpass_CutoffFreq =      $1803 ; // Specifies the frequency in Hertz that corresponds to the -3dB cutoff of the filter.
    DAQmx_AI_Lowpass_SwitchCap_ClkSrc =                                $1884 ; // Specifies the source of the filter clock. If you need a higher resolution for the filter, you can supply an external clock to increase the resolution. Refer to the SCXI-1141/1142/1143 User Manual for more information.
    DAQmx_AI_Lowpass_SwitchCap_ExtClkFreq =                            $1885 ; // Specifies the frequency of the external clock when you set Clock Source to DAQmx_Val_External.  NI-DAQmx uses this frequency to set the pre- and post- filters on the SCXI-1141, SCXI-1142, and SCXI-1143. On those devices, NI-DAQmx determines the filter cutoff by using the equation f/(100*n), where f is the external frequency, and n is the external clock divisor. Refer to the SCXI-1141/1142/1143 User Manual for more...
    DAQmx_AI_Lowpass_SwitchCap_ExtClkDiv =                             $1886 ; // Specifies the divisor for the external clock when you set Clock Source to DAQmx_Val_External. On the SCXI-1141, SCXI-1142, and SCXI-1143, NI-DAQmx determines the filter cutoff by using the equation f/(100*n), where f is the external frequency, and n is the external clock divisor. Refer to the SCXI-1141/1142/1143 User Manual for more information.
    DAQmx_AI_Lowpass_SwitchCap_OutClkDiv =                             $1887 ; // Specifies the divisor for the output clock.  NI-DAQmx uses the cutoff frequency to determine the output clock frequency. Refer to the SCXI-1141/1142/1143 User Manual for more information.
    DAQmx_AI_ResolutionUnits =         $1764 ; // Indicates the units of Resolution Value.
    DAQmx_AI_Resolution =              $1765 ; // Indicates the resolution of the analog-to-digital converter of the channel. This value is in the units you specify with Resolution Units.
    DAQmx_AI_Dither_Enable =           $0068 ; // Specifies whether to enable dithering.  Dithering adds Gaussian noise to the input signal. You can use dithering to achieve higher resolution measurements by over sampling the input signal and averaging the results.
    DAQmx_AI_Rng_High =                $1815 ; // Specifies the upper limit of the input range of the device. This value is in the native units of the device. On E Series devices, for example, the native units is volts.
    DAQmx_AI_Rng_Low =                 $1816 ; // Specifies the lower limit of the input range of the device. This value is in the native units of the device. On E Series devices, for example, the native units is volts.
    DAQmx_AI_Gain =                    $1818 ; // Specifies a gain factor to apply to the channel.
    DAQmx_AI_SampAndHold_Enable =      $181A ; // Specifies whether to enable the sample and hold circuitry of the device. When you disable sample and hold circuitry, a small voltage offset might be introduced into the signal.  You can eliminate this offset by using Auto Zero Mode to perform an auto zero on the channel.
    DAQmx_AI_AutoZeroMode =            $1760 ; // Specifies when to measure ground. NI-DAQmx subtracts the measured ground voltage from every sample.
    DAQmx_AI_DataXferMech =            $1821 ; // Specifies the data transfer mode for the device.
    DAQmx_AI_DataXferReqCond =         $188B ; // Specifies under what condition to transfer data from the onboard memory of the device to the buffer.
    DAQmx_AI_MemMapEnable =            $188C ; // Specifies for NI-DAQmx to map hardware registers to the memory space of the customer process, if possible. Mapping to the memory space of the customer process increases performance. However, memory mapping can adversely affect the operation of the device and possibly result in a system crash if software in the process unintentionally accesses the mapped registers.
    DAQmx_AI_DevScalingCoeff =         $1930 ; // Indicates the coefficients of a polynomial equation that NI-DAQmx uses to scale values from the native format of the device to volts. Each element of the array corresponds to a term of the equation. For example, if index two of the array is 4, the third term of the equation is 4x^2. Scaling coefficients do not account for any custom scales or sensors contained by the channel.
    DAQmx_AI_EnhancedAliasRejectionEnable =                            $2294 ; // Specifies whether to enable enhanced alias rejection. By default, enhanced alias rejection is enabled on supported devices. Leave this property set to the default value for most applications.
    DAQmx_AO_Max =                     $1186 ; // Specifies the maximum value you expect to generate. The value is in the units you specify with a units property. If you try to write a value larger than the maximum value, NI-DAQmx generates an error. NI-DAQmx might coerce this value to a smaller value if other task settings restrict the device from generating the desired maximum.
    DAQmx_AO_Min =                     $1187 ; // Specifies the minimum value you expect to generate. The value is in the units you specify with a units property. If you try to write a value smaller than the minimum value, NI-DAQmx generates an error. NI-DAQmx might coerce this value to a larger value if other task settings restrict the device from generating the desired minimum.
    DAQmx_AO_CustomScaleName =         $1188 ; // Specifies the name of a custom scale for the channel.
    DAQmx_AO_OutputType =              $1108 ; // Indicates whether the channel generates voltage or current.
    DAQmx_AO_Voltage_Units =           $1184 ; // Specifies in what units to generate voltage on the channel. Write data to the channel in the units you select.
    DAQmx_AO_Current_Units =           $1109 ; // Specifies in what units to generate current on the channel. Write data to the channel is in the units you select.
    DAQmx_AO_OutputImpedance =         $1490 ; // Specifies in ohms the impedance of the analog output stage of the device.
    DAQmx_AO_LoadImpedance =           $0121 ; // Specifies in ohms the load impedance connected to the analog output channel.
    DAQmx_AO_IdleOutputBehavior =      $2240 ; // Specifies the state of the channel when no generation is in progress.
    DAQmx_AO_TermCfg =                 $188E ; // Specifies the terminal configuration of the channel.
    DAQmx_AO_ResolutionUnits =         $182B ; // Specifies the units of Resolution Value.
    DAQmx_AO_Resolution =              $182C ; // Indicates the resolution of the digital-to-analog converter of the channel. This value is in the units you specify with Resolution Units.
    DAQmx_AO_DAC_Rng_High =            $182E ; // Specifies the upper limit of the output range of the device. This value is in the native units of the device. On E Series devices, for example, the native units is volts.
    DAQmx_AO_DAC_Rng_Low =             $182D ; // Specifies the lower limit of the output range of the device. This value is in the native units of the device. On E Series devices, for example, the native units is volts.
    DAQmx_AO_DAC_Ref_ConnToGnd =       $0130 ; // Specifies whether to ground the internal DAC reference. Grounding the internal DAC reference has the effect of grounding all analog output channels and stopping waveform generation across all analog output channels regardless of whether the channels belong to the current task. You can ground the internal DAC reference only when Source is DAQmx_Val_Internal and Allow Connecting DAC Reference to Ground at Runtime is...
    DAQmx_AO_DAC_Ref_AllowConnToGnd =  $1830 ; // Specifies whether to allow grounding the internal DAC reference at run time. You must set this property to TRUE and set Source to DAQmx_Val_Internal before you can set Connect DAC Reference to Ground to TRUE.
    DAQmx_AO_DAC_Ref_Src =             $0132 ; // Specifies the source of the DAC reference voltage. The value of this voltage source determines the full-scale value of the DAC.
    DAQmx_AO_DAC_Ref_ExtSrc =          $2252 ; // Specifies the source of the DAC reference voltage if Source is DAQmx_Val_External.
    DAQmx_AO_DAC_Ref_Val =             $1832 ; // Specifies in volts the value of the DAC reference voltage. This voltage determines the full-scale range of the DAC. Smaller reference voltages result in smaller ranges, but increased resolution.
    DAQmx_AO_DAC_Offset_Src =          $2253 ; // Specifies the source of the DAC offset voltage. The value of this voltage source determines the full-scale value of the DAC.
    DAQmx_AO_DAC_Offset_ExtSrc =       $2254 ; // Specifies the source of the DAC offset voltage if Source is DAQmx_Val_External.
    DAQmx_AO_DAC_Offset_Val =          $2255 ; // Specifies in volts the value of the DAC offset voltage.
    DAQmx_AO_ReglitchEnable =          $0133 ; // Specifies whether to enable reglitching.  The output of a DAC normally glitches whenever the DAC is updated with a new value. The amount of glitching differs from code to code and is generally largest at major code transitions.  Reglitching generates uniform glitch energy at each code transition and provides for more uniform glitches.  Uniform glitch energy makes it easier to filter out the noise introduced from g...
    DAQmx_AO_Gain =                    $0118 ; // Specifies in decibels the gain factor to apply to the channel.
    DAQmx_AO_UseOnlyOnBrdMem =         $183A ; // Specifies whether to write samples directly to the onboard memory of the device, bypassing the memory buffer. Generally, you cannot update onboard memory after you start the task. Onboard memory includes data FIFOs.
    DAQmx_AO_DataXferMech =            $0134 ; // Specifies the data transfer mode for the device.
    DAQmx_AO_DataXferReqCond =         $183C ; // Specifies under what condition to transfer data from the buffer to the onboard memory of the device.
    DAQmx_AO_MemMapEnable =            $188F ; // Specifies if NI-DAQmx maps hardware registers to the memory space of the customer process, if possible. Mapping to the memory space of the customer process increases performance. However, memory mapping can adversely affect the operation of the device and possibly result in a system crash if software in the process unintentionally accesses the mapped registers.
    DAQmx_AO_DevScalingCoeff =         $1931 ; // Indicates the coefficients of a linear equation that NI-DAQmx uses to scale values from a voltage to the native format of the device.  Each element of the array corresponds to a term of the equation. For example, if index two of the array is 4, the third term of the equation is 4x^2.  Scaling coefficients do not account for any custom scales that may be applied to the channel.
    DAQmx_DI_InvertLines =             $0793 ; // Specifies whether to invert the lines in the channel. If you set this property to TRUE, the lines are at high logic when off and at low logic when on.
    DAQmx_DI_NumLines =                $2178 ; // Indicates the number of digital lines in the channel.
    DAQmx_DI_DigFltr_Enable =          $21D6 ; // Specifies whether to enable the digital filter for the line(s) or port(s). You can enable the filter on a line-by-line basis. You do not have to enable the filter for all lines in a channel.
    DAQmx_DI_DigFltr_MinPulseWidth =   $21D7 ; // Specifies in seconds the minimum pulse width the filter recognizes as a valid high or low state transition.
    DAQmx_DI_Tristate =                $1890 ; // Specifies whether to tristate the lines in the channel. If you set this property to TRUE, NI-DAQmx tristates the lines in the channel. If you set this property to FALSE, NI-DAQmx does not modify the configuration of the lines even if the lines were previously tristated. Set this property to FALSE to read lines in other tasks or to read output-only lines.
    DAQmx_DI_DataXferMech =            $2263 ; // Specifies the data transfer mode for the device.
    DAQmx_DI_DataXferReqCond =         $2264 ; // Specifies under what condition to transfer data from the onboard memory of the device to the buffer.
    DAQmx_DO_InvertLines =             $1133 ; // Specifies whether to invert the lines in the channel. If you set this property to TRUE, the lines are at high logic when off and at low logic when on.
    DAQmx_DO_NumLines =                $2179 ; // Indicates the number of digital lines in the channel.
    DAQmx_DO_Tristate =                $18F3 ; // Specifies whether to stop driving the channel and set it to a Hi-Z state.
    DAQmx_DO_UseOnlyOnBrdMem =         $2265 ; // Specifies whether to write samples directly to the onboard memory of the device, bypassing the memory buffer. Generally, you cannot update onboard memory after you start the task. Onboard memory includes data FIFOs.
    DAQmx_DO_DataXferMech =            $2266 ; // Specifies the data transfer mode for the device.
    DAQmx_DO_DataXferReqCond =         $2267 ; // Specifies under what condition to transfer data from the buffer to the onboard memory of the device.
    DAQmx_CI_Max =                     $189C ; // Specifies the maximum value you expect to measure. This value is in the units you specify with a units property. When you query this property, it returns the coerced maximum value that the hardware can measure with the current settings.
    DAQmx_CI_Min =                     $189D ; // Specifies the minimum value you expect to measure. This value is in the units you specify with a units property. When you query this property, it returns the coerced minimum value that the hardware can measure with the current settings.
    DAQmx_CI_CustomScaleName =         $189E ; // Specifies the name of a custom scale for the channel.
    DAQmx_CI_MeasType =                $18A0 ; // Indicates the measurement to take with the channel.
    DAQmx_CI_Freq_Units =              $18A1 ; // Specifies the units to use to return frequency measurements.
    DAQmx_CI_Freq_Term =               $18A2 ; // Specifies the input terminal of the signal to measure.
    DAQmx_CI_Freq_StartingEdge =       $0799 ; // Specifies between which edges to measure the frequency of the signal.
    DAQmx_CI_Freq_MeasMeth =           $0144 ; // Specifies the method to use to measure the frequency of the signal.
    DAQmx_CI_Freq_MeasTime =           $0145 ; // Specifies in seconds the length of time to measure the frequency of the signal if Method is DAQmx_Val_HighFreq2Ctr. Measurement accuracy increases with increased measurement time and with increased signal frequency. If you measure a high-frequency signal for too long, however, the count register could roll over, which results in an incorrect measurement.
    DAQmx_CI_Freq_Div =                $0147 ; // Specifies the value by which to divide the input signal if  Method is DAQmx_Val_LargeRng2Ctr. The larger the divisor, the more accurate the measurement. However, too large a value could cause the count register to roll over, which results in an incorrect measurement.
    DAQmx_CI_Freq_DigFltr_Enable =     $21E7 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_Freq_DigFltr_MinPulseWidth =                              $21E8 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_Freq_DigFltr_TimebaseSrc =                                $21E9 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_Freq_DigFltr_TimebaseRate =                               $21EA ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_Freq_DigSync_Enable =     $21EB ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_Period_Units =            $18A3 ; // Specifies the unit to use to return period measurements.
    DAQmx_CI_Period_Term =             $18A4 ; // Specifies the input terminal of the signal to measure.
    DAQmx_CI_Period_StartingEdge =     $0852 ; // Specifies between which edges to measure the period of the signal.
    DAQmx_CI_Period_MeasMeth =         $192C ; // Specifies the method to use to measure the period of the signal.
    DAQmx_CI_Period_MeasTime =         $192D ; // Specifies in seconds the length of time to measure the period of the signal if Method is DAQmx_Val_HighFreq2Ctr. Measurement accuracy increases with increased measurement time and with increased signal frequency. If you measure a high-frequency signal for too long, however, the count register could roll over, which results in an incorrect measurement.
    DAQmx_CI_Period_Div =              $192E ; // Specifies the value by which to divide the input signal if Method is DAQmx_Val_LargeRng2Ctr. The larger the divisor, the more accurate the measurement. However, too large a value could cause the count register to roll over, which results in an incorrect measurement.
    DAQmx_CI_Period_DigFltr_Enable =   $21EC ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_Period_DigFltr_MinPulseWidth =                            $21ED ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_Period_DigFltr_TimebaseSrc =                              $21EE ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_Period_DigFltr_TimebaseRate =                             $21EF ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_Period_DigSync_Enable =   $21F0 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_CountEdges_Term =         $18C7 ; // Specifies the input terminal of the signal to measure.
    DAQmx_CI_CountEdges_Dir =          $0696 ; // Specifies whether to increment or decrement the counter on each edge.
    DAQmx_CI_CountEdges_DirTerm =      $21E1 ; // Specifies the source terminal of the digital signal that controls the count direction if Direction is DAQmx_Val_ExtControlled.
    DAQmx_CI_CountEdges_CountDir_DigFltr_Enable =                      $21F1 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_CountEdges_CountDir_DigFltr_MinPulseWidth =               $21F2 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_CountEdges_CountDir_DigFltr_TimebaseSrc =                 $21F3 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_CountEdges_CountDir_DigFltr_TimebaseRate =                $21F4 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_CountEdges_CountDir_DigSync_Enable =                      $21F5 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_CountEdges_InitialCnt =   $0698 ; // Specifies the starting value from which to count.
    DAQmx_CI_CountEdges_ActiveEdge =   $0697 ; // Specifies on which edges to increment or decrement the counter.
    DAQmx_CI_CountEdges_DigFltr_Enable =                               $21F6 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_CountEdges_DigFltr_MinPulseWidth =                        $21F7 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_CountEdges_DigFltr_TimebaseSrc =                          $21F8 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_CountEdges_DigFltr_TimebaseRate =                         $21F9 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_CountEdges_DigSync_Enable =                               $21FA ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_AngEncoder_Units =        $18A6 ; // Specifies the units to use to return angular position measurements from the channel.
    DAQmx_CI_AngEncoder_PulsesPerRev = $0875 ; // Specifies the number of pulses the encoder generates per revolution. This value is the number of pulses on either signal A or signal B, not the total number of pulses on both signal A and signal B.
    DAQmx_CI_AngEncoder_InitialAngle = $0881 ; // Specifies the starting angle of the encoder. This value is in the units you specify with Units.
    DAQmx_CI_LinEncoder_Units =        $18A9 ; // Specifies the units to use to return linear encoder measurements from the channel.
    DAQmx_CI_LinEncoder_DistPerPulse = $0911 ; // Specifies the distance to measure for each pulse the encoder generates on signal A or signal B. This value is in the units you specify with Units.
    DAQmx_CI_LinEncoder_InitialPos =   $0915 ; // Specifies the position of the encoder when the measurement begins. This value is in the units you specify with Units.
    DAQmx_CI_Encoder_DecodingType =    $21E6 ; // Specifies how to count and interpret the pulses the encoder generates on signal A and signal B. DAQmx_Val_X1, DAQmx_Val_X2, and DAQmx_Val_X4 are valid for quadrature encoders only. DAQmx_Val_TwoPulseCounting is valid for two-pulse encoders only.
    DAQmx_CI_Encoder_AInputTerm =      $219D ; // Specifies the terminal to which signal A is connected.
    DAQmx_CI_Encoder_AInput_DigFltr_Enable =                           $21FB ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_Encoder_AInput_DigFltr_MinPulseWidth =                    $21FC ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_Encoder_AInput_DigFltr_TimebaseSrc =                      $21FD ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_Encoder_AInput_DigFltr_TimebaseRate =                     $21FE ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_Encoder_AInput_DigSync_Enable =                           $21FF ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_Encoder_BInputTerm =      $219E ; // Specifies the terminal to which signal B is connected.
    DAQmx_CI_Encoder_BInput_DigFltr_Enable =                           $2200 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_Encoder_BInput_DigFltr_MinPulseWidth =                    $2201 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_Encoder_BInput_DigFltr_TimebaseSrc =                      $2202 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_Encoder_BInput_DigFltr_TimebaseRate =                     $2203 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_Encoder_BInput_DigSync_Enable =                           $2204 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_Encoder_ZInputTerm =      $219F ; // Specifies the terminal to which signal Z is connected.
    DAQmx_CI_Encoder_ZInput_DigFltr_Enable =                           $2205 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_Encoder_ZInput_DigFltr_MinPulseWidth =                    $2206 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_Encoder_ZInput_DigFltr_TimebaseSrc =                      $2207 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_Encoder_ZInput_DigFltr_TimebaseRate =                     $2208 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_Encoder_ZInput_DigSync_Enable =                           $2209 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_Encoder_ZIndexEnable =    $0890 ; // Specifies whether to use Z indexing for the channel.
    DAQmx_CI_Encoder_ZIndexVal =       $0888 ; // Specifies the value to which to reset the measurement when signal Z is high and signal A and signal B are at the states you specify with Z Index Phase. Specify this value in the units of the measurement.
    DAQmx_CI_Encoder_ZIndexPhase =     $0889 ; // Specifies the states at which signal A and signal B must be while signal Z is high for NI-DAQmx to reset the measurement. If signal Z is never high while signal A and signal B are high, for example, you must choose a phase other than DAQmx_Val_AHighBHigh.
    DAQmx_CI_PulseWidth_Units =        $0823 ; // Specifies the units to use to return pulse width measurements.
    DAQmx_CI_PulseWidth_Term =         $18AA ; // Specifies the input terminal of the signal to measure.
    DAQmx_CI_PulseWidth_StartingEdge = $0825 ; // Specifies on which edge of the input signal to begin each pulse width measurement.
    DAQmx_CI_PulseWidth_DigFltr_Enable =                               $220A ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_PulseWidth_DigFltr_MinPulseWidth =                        $220B ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_PulseWidth_DigFltr_TimebaseSrc =                          $220C ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_PulseWidth_DigFltr_TimebaseRate =                         $220D ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_PulseWidth_DigSync_Enable =                               $220E ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_TwoEdgeSep_Units =        $18AC ; // Specifies the units to use to return two-edge separation measurements from the channel.
    DAQmx_CI_TwoEdgeSep_FirstTerm =    $18AD ; // Specifies the source terminal of the digital signal that starts each measurement.
    DAQmx_CI_TwoEdgeSep_FirstEdge =    $0833 ; // Specifies on which edge of the first signal to start each measurement.
    DAQmx_CI_TwoEdgeSep_First_DigFltr_Enable =                         $220F ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_TwoEdgeSep_First_DigFltr_MinPulseWidth =                  $2210 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_TwoEdgeSep_First_DigFltr_TimebaseSrc =                    $2211 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_TwoEdgeSep_First_DigFltr_TimebaseRate =                   $2212 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_TwoEdgeSep_First_DigSync_Enable =                         $2213 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_TwoEdgeSep_SecondTerm =   $18AE ; // Specifies the source terminal of the digital signal that stops each measurement.
    DAQmx_CI_TwoEdgeSep_SecondEdge =   $0834 ; // Specifies on which edge of the second signal to stop each measurement.
    DAQmx_CI_TwoEdgeSep_Second_DigFltr_Enable =                        $2214 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_TwoEdgeSep_Second_DigFltr_MinPulseWidth =                 $2215 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_TwoEdgeSep_Second_DigFltr_TimebaseSrc =                   $2216 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_TwoEdgeSep_Second_DigFltr_TimebaseRate =                  $2217 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_TwoEdgeSep_Second_DigSync_Enable =                        $2218 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_SemiPeriod_Units =        $18AF ; // Specifies the units to use to return semi-period measurements.
    DAQmx_CI_SemiPeriod_Term =         $18B0 ; // Specifies the input terminal of the signal to measure.
    DAQmx_CI_SemiPeriod_DigFltr_Enable =                               $2219 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_SemiPeriod_DigFltr_MinPulseWidth =                        $221A ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_SemiPeriod_DigFltr_TimebaseSrc =                          $221B ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_SemiPeriod_DigFltr_TimebaseRate =                         $221C ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_SemiPeriod_DigSync_Enable =                               $221D ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_CtrTimebaseSrc =          $0143 ; // Specifies the terminal of the timebase to use for the counter.
    DAQmx_CI_CtrTimebaseRate =         $18B2 ; // Specifies in Hertz the frequency of the counter timebase. Specifying the rate of a counter timebase allows you to take measurements in terms of time or frequency rather than in ticks of the timebase. If you use an external timebase and do not specify the rate, you can take measurements only in terms of ticks of the timebase.
    DAQmx_CI_CtrTimebaseActiveEdge =   $0142 ; // Specifies whether a timebase cycle is from rising edge to rising edge or from falling edge to falling edge.
    DAQmx_CI_CtrTimebase_DigFltr_Enable =                              $2271 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CI_CtrTimebase_DigFltr_MinPulseWidth =                       $2272 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CI_CtrTimebase_DigFltr_TimebaseSrc =                         $2273 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CI_CtrTimebase_DigFltr_TimebaseRate =                        $2274 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CI_CtrTimebase_DigSync_Enable =                              $2275 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CI_Count =                   $0148 ; // Indicates the current value of the count register.
    DAQmx_CI_OutputState =             $0149 ; // Indicates the current state of the out terminal of the counter.
    DAQmx_CI_TCReached =               $0150 ; // Indicates whether the counter rolled over. When you query this property, NI-DAQmx resets it to FALSE.
    DAQmx_CI_CtrTimebaseMasterTimebaseDiv =                            $18B3 ; // Specifies the divisor for an external counter timebase. You can divide the counter timebase in order to measure slower signals without causing the count register to roll over.
    DAQmx_CI_DataXferMech =            $0200 ; // Specifies the data transfer mode for the channel.
    DAQmx_CI_NumPossiblyInvalidSamps = $193C ; // Indicates the number of samples that the device might have overwritten before it could transfer them to the buffer.
    DAQmx_CI_DupCountPrevent =         $21AC ; // Specifies whether to enable duplicate count prevention for the channel.
    DAQmx_CI_Prescaler =               $2239 ; // Specifies the divisor to apply to the signal you connect to the counter source terminal. Scaled data that you read takes this setting into account. You should use a prescaler only when you connect an external signal to the counter source terminal and when that signal has a higher frequency than the fastest onboard timebase.
    DAQmx_CO_OutputType =              $18B5 ; // Indicates how to define pulses generated on the channel.
    DAQmx_CO_Pulse_IdleState =         $1170 ; // Specifies the resting state of the output terminal.
    DAQmx_CO_Pulse_Term =              $18E1 ; // Specifies on which terminal to generate pulses.
    DAQmx_CO_Pulse_Time_Units =        $18D6 ; // Specifies the units in which to define high and low pulse time.
    DAQmx_CO_Pulse_HighTime =          $18BA ; // Specifies the amount of time that the pulse is at a high voltage. This value is in the units you specify with Units or when you create the channel.
    DAQmx_CO_Pulse_LowTime =           $18BB ; // Specifies the amount of time that the pulse is at a low voltage. This value is in the units you specify with Units or when you create the channel.
    DAQmx_CO_Pulse_Time_InitialDelay = $18BC ; // Specifies in seconds the amount of time to wait before generating the first pulse.
    DAQmx_CO_Pulse_DutyCyc =           $1176 ; // Specifies the duty cycle of the pulses. The duty cycle of a signal is the width of the pulse divided by period. NI-DAQmx uses this ratio and the pulse frequency to determine the width of the pulses and the delay between pulses.
    DAQmx_CO_Pulse_Freq_Units =        $18D5 ; // Specifies the units in which to define pulse frequency.
    DAQmx_CO_Pulse_Freq =              $1178 ; // Specifies the frequency of the pulses to generate. This value is in the units you specify with Units or when you create the channel.
    DAQmx_CO_Pulse_Freq_InitialDelay = $0299 ; // Specifies in seconds the amount of time to wait before generating the first pulse.
    DAQmx_CO_Pulse_HighTicks =         $1169 ; // Specifies the number of ticks the pulse is high.
    DAQmx_CO_Pulse_LowTicks =          $1171 ; // Specifies the number of ticks the pulse is low.
    DAQmx_CO_Pulse_Ticks_InitialDelay =                                $0298 ; // Specifies the number of ticks to wait before generating the first pulse.
    DAQmx_CO_CtrTimebaseSrc =          $0339 ; // Specifies the terminal of the timebase to use for the counter. Typically, NI-DAQmx uses one of the internal counter timebases when generating pulses. Use this property to specify an external timebase and produce custom pulse widths that are not possible using the internal timebases.
    DAQmx_CO_CtrTimebaseRate =         $18C2 ; // Specifies in Hertz the frequency of the counter timebase. Specifying the rate of a counter timebase allows you to define output pulses in seconds rather than in ticks of the timebase. If you use an external timebase and do not specify the rate, you can define output pulses only in ticks of the timebase.
    DAQmx_CO_CtrTimebaseActiveEdge =   $0341 ; // Specifies whether a timebase cycle is from rising edge to rising edge or from falling edge to falling edge.
    DAQmx_CO_CtrTimebase_DigFltr_Enable =                              $2276 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_CO_CtrTimebase_DigFltr_MinPulseWidth =                       $2277 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_CO_CtrTimebase_DigFltr_TimebaseSrc =                         $2278 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_CO_CtrTimebase_DigFltr_TimebaseRate =                        $2279 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_CO_CtrTimebase_DigSync_Enable =                              $227A ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_CO_Count =                   $0293 ; // Indicates the current value of the count register.
    DAQmx_CO_OutputState =             $0294 ; // Indicates the current state of the output terminal of the counter.
    DAQmx_CO_AutoIncrCnt =             $0295 ; // Specifies a number of timebase ticks by which to increment each successive pulse.
    DAQmx_CO_CtrTimebaseMasterTimebaseDiv =                             $18C3 ; // Specifies the divisor for an external counter timebase. You can divide the counter timebase in order to generate slower signals without causing the count register to roll over.
    DAQmx_CO_PulseDone =               $190E ; // Indicates if the task completed pulse generation. Use this value for retriggerable pulse generation when you need to determine if the device generated the current pulse. When you query this property, NI-DAQmx resets it to FALSE.
    DAQmx_CO_Prescaler =               $226D ; // Specifies the divisor to apply to the signal you connect to the counter source terminal. Pulse generations defined by frequency or time take this setting into account, but pulse generations defined by ticks do not. You should use a prescaler only when you connect an external signal to the counter source terminal and when that signal has a higher frequency than the fastest onboard timebase.

//********** Export Signal Attributes **********
    DAQmx_Exported_AIConvClk_OutputTerm = $1687 ; // Specifies the terminal to which to route the AI Convert Clock.
    DAQmx_Exported_AIConvClk_Pulse_Polarity =                           $1688 ; // Indicates the polarity of the exported AI Convert Clock. The polarity is fixed and independent of the active edge of the source of the AI Convert Clock.
    DAQmx_Exported_10MHzRefClk_OutputTerm =                             $226E ; // Specifies the terminal to which to route the 10MHz Clock.
    DAQmx_Exported_20MHzTimebase_OutputTerm =                           $1657 ; // Specifies the terminal to which to route the 20MHz Timebase.
    DAQmx_Exported_SampClk_OutputBehavior =                             $186B ; // Specifies whether the exported Sample Clock issues a pulse at the beginning of a sample or changes to a high state for the duration of the sample.
    DAQmx_Exported_SampClk_OutputTerm =   $1663 ; // Specifies the terminal to which to route the Sample Clock.
    DAQmx_Exported_SampClkTimebase_OutputTerm =                        $18F9 ; // Specifies the terminal to which to route the Sample Clock Timebase.
    DAQmx_Exported_DividedSampClkTimebase_OutputTerm =                $21A1 ; // Specifies the terminal to which to route the Divided Sample Clock Timebase.
    DAQmx_Exported_AdvTrig_OutputTerm =   $1645 ; // Specifies the terminal to which to route the Advance Trigger.
    DAQmx_Exported_AdvTrig_Pulse_Polarity =                             $1646 ; // Indicates the polarity of the exported Advance Trigger.
    DAQmx_Exported_AdvTrig_Pulse_WidthUnits =                           $1647 ; // Specifies the units of Width Value.
    DAQmx_Exported_AdvTrig_Pulse_Width =  $1648 ; // Specifies the width of an exported Advance Trigger pulse. Specify this value in the units you specify with Width Units.
    DAQmx_Exported_RefTrig_OutputTerm =   $0590 ; // Specifies the terminal to which to route the Reference Trigger.
    DAQmx_Exported_StartTrig_OutputTerm = $0584 ; // Specifies the terminal to which to route the Start Trigger.
    DAQmx_Exported_AdvCmpltEvent_OutputTerm =                           $1651 ; // Specifies the terminal to which to route the Advance Complete Event.
    DAQmx_Exported_AdvCmpltEvent_Delay =  $1757 ; // Specifies the output signal delay in periods of the sample clock.
    DAQmx_Exported_AdvCmpltEvent_Pulse_Polarity =                       $1652 ; // Specifies the polarity of the exported Advance Complete Event.
    DAQmx_Exported_AdvCmpltEvent_Pulse_Width =                          $1654 ; // Specifies the width of the exported Advance Complete Event pulse.
    DAQmx_Exported_AIHoldCmpltEvent_OutputTerm =                        $18ED ; // Specifies the terminal to which to route the AI Hold Complete Event.
    DAQmx_Exported_AIHoldCmpltEvent_PulsePolarity =                     $18EE ; // Specifies the polarity of an exported AI Hold Complete Event pulse.
    DAQmx_Exported_ChangeDetectEvent_OutputTerm =                       $2197 ; // Specifies the terminal to which to route the Change Detection Event.
    DAQmx_Exported_CtrOutEvent_OutputTerm =                             $1717 ; // Specifies the terminal to which to route the Counter Output Event.
    DAQmx_Exported_CtrOutEvent_OutputBehavior =                         $174F ; // Specifies whether the exported Counter Output Event pulses or changes from one state to the other when the counter reaches terminal count.
    DAQmx_Exported_CtrOutEvent_Pulse_Polarity =                         $1718 ; // Specifies the polarity of the pulses at the output terminal of the counter when Output Behavior is DAQmx_Val_Pulse. NI-DAQmx ignores this property if Output Behavior is DAQmx_Val_Toggle.
    DAQmx_Exported_CtrOutEvent_Toggle_IdleState =                       $186A ; // Specifies the initial state of the output terminal of the counter when Output Behavior is DAQmx_Val_Toggle. The terminal enters this state when NI-DAQmx commits the task.
    DAQmx_Exported_SyncPulseEvent_OutputTerm =                          $223C ; // Specifies the terminal to which to route the Synchronization Pulse Event.
    DAQmx_Exported_WatchdogExpiredEvent_OutputTerm =                    $21AA ; // Specifies the terminal  to which to route the Watchdog Timer Expired Event.

//********** Device Attributes **********
    DAQmx_Dev_ProductType =            $0631 ; // Indicates the product name of the device.
    DAQmx_Dev_SerialNum =              $0632 ; // Indicates the serial number of the device. This value is zero if the device does not have a serial number.

//********** Read Attributes **********
    DAQmx_Read_RelativeTo =            $190A ; // Specifies the point in the buffer at which to begin a read operation. If you also specify an offset with Offset, the read operation begins at that offset relative to the point you select with this property. The default value is DAQmx_Val_CurrReadPos unless you configure a Reference Trigger for the task. If you configure a Reference Trigger, the default value is DAQmx_Val_FirstPretrigSamp.
    DAQmx_Read_Offset =                $190B ; // Specifies an offset in samples per channel at which to begin a read operation. This offset is relative to the location you specify with RelativeTo.
    DAQmx_Read_ChannelsToRead =        $1823 ; // Specifies a subset of channels in the task from which to read.
    DAQmx_Read_ReadAllAvailSamp =      $1215 ; // Specifies whether subsequent read operations read all samples currently available in the buffer or wait for the buffer to become full before reading. NI-DAQmx uses this setting for finite acquisitions and only when the number of samples to read is -1. For continuous acquisitions when the number of samples to read is -1, a read operation always reads all samples currently available in the buffer.
    DAQmx_Read_AutoStart =             $1826 ; // Specifies if an NI-DAQmx Read function automatically starts the task  if you did not start the task explicitly by using DAQmxStartTask(). The default value is TRUE. When  an NI-DAQmx Read function starts a finite acquisition task, it also stops the task after reading the last sample.
    DAQmx_Read_OverWrite =             $1211 ; // Specifies whether to overwrite samples in the buffer that you have not yet read.
    DAQmx_Read_CurrReadPos =           $1221 ; // Indicates in samples per channel the current position in the buffer.
    DAQmx_Read_AvailSampPerChan =      $1223 ; // Indicates the number of samples available to read per channel. This value is the same for all channels in the task.
    DAQmx_Read_TotalSampPerChanAcquired =                             $192A ; // Indicates the total number of samples acquired by each channel. NI-DAQmx returns a single value because this value is the same for all channels.
    DAQmx_Read_OverloadedChansExist =  $2174 ; // Indicates if the device detected an overload in any channel in the task. Reading this property clears the overload status for all channels in the task. You must read this property before you read Overloaded Channels. Otherwise, you will receive an error.
    DAQmx_Read_OverloadedChans =       $2175 ; // Indicates the names of any overloaded virtual channels in the task. You must read Overloaded Channels Exist before you read this property. Otherwise, you will receive an error.
    DAQmx_Read_ChangeDetect_HasOverflowed =                           $2194 ; // Indicates if samples were missed because change detection events occurred faster than the device could handle them. Some devices detect overflows differently than others.
    DAQmx_Read_RawDataWidth =          $217A ; // Indicates in bytes the size of a raw sample from the task.
    DAQmx_Read_NumChans =              $217B ; // Indicates the number of channels that an NI-DAQmx Read function reads from the task. This value is the number of channels in the task or the number of channels you specify with Channels to Read.
    DAQmx_Read_DigitalLines_BytesPerChan =                            $217C ; // Indicates the number of bytes per channel that NI-DAQmx returns in a sample for line-based reads. If a channel has fewer lines than this number, the extra bytes are FALSE.
    DAQmx_ReadWaitMode =               $2232 ; // Specifies how an NI-DAQmx Read function waits for samples to become available.

//********** Switch Channel Attributes **********
    DAQmx_SwitchChan_Usage =           $18E4 ; // Specifies how you can use the channel. Using this property acts as a safety mechanism to prevent you from connecting two source channels, for example.
    DAQmx_SwitchChan_MaxACCarryCurrent =                                $0648 ; // Indicates in amperes the maximum AC current that the device can carry.
    DAQmx_SwitchChan_MaxACSwitchCurren =                               $0646 ; // Indicates in amperes the maximum AC current that the device can switch. This current is always against an RMS voltage level.
    DAQmx_SwitchChan_MaxACCarryPwr =   $0642 ; // Indicates in watts the maximum AC power that the device can carry.
    DAQmx_SwitchChan_MaxACSwitchPwr =  $0644 ; // Indicates in watts the maximum AC power that the device can switch.
    DAQmx_SwitchChan_MaxDCCarryCurrent =                               $0647 ; // Indicates in amperes the maximum DC current that the device can carry.
    DAQmx_SwitchChan_MaxDCSwitchCurrent =                             $0645 ; // Indicates in amperes the maximum DC current that the device can switch. This current is always against a DC voltage level.
    DAQmx_SwitchChan_MaxDCCarryPwr =   $0643 ; // Indicates in watts the maximum DC power that the device can carry.
    DAQmx_SwitchChan_MaxDCSwitchPwr =  $0649 ; // Indicates in watts the maximum DC power that the device can switch.
    DAQmx_SwitchChan_MaxACVoltage =    $0651 ; // Indicates in volts the maximum AC RMS voltage that the device can switch.
    DAQmx_SwitchChan_MaxDCVoltage =    $0650 ; // Indicates in volts the maximum DC voltage that the device can switch.
    DAQmx_SwitchChan_WireMode =        $18E5 ; // Indicates the number of wires that the channel switches.
    DAQmx_SwitchChan_Bandwidth =       $0640 ; // Indicates in Hertz the maximum frequency of a signal that can pass through the switch without significant deterioration.
    DAQmx_SwitchChan_Impedance =       $0641 ; // Indicates in ohms the switch impedance. This value is important in the RF domain and should match the impedance of the sources and loads.

//********** Switch Device Attributes **********
    DAQmx_SwitchDev_SettlingTime =     $1244 ; // Specifies in seconds the amount of time to wait for the switch to settle (or debounce). NI-DAQmx adds this time to the settling time of the motherboard. Modify this property only if the switch does not settle within the settling time of the motherboard. Refer to device documentation for supported settling times.
    DAQmx_SwitchDev_AutoConnAnlgBus =  $17DA ; // Specifies if NI-DAQmx routes multiplexed channels to the analog bus backplane. Only the SCXI-1127 and SCXI-1128 support this property.
    DAQmx_SwitchDev_Settled =          $1243 ; // Indicates when Settling Time expires.
    DAQmx_SwitchDev_RelayList =        $17DC ; // Indicates a comma-delimited list of relay names.
    DAQmx_SwitchDev_NumRelays =        $18E6 ; // Indicates the number of relays on the device. This value matches the number of relay names in Relay List.
    DAQmx_SwitchDev_SwitchChanList =   $18E7 ; // Indicates a comma-delimited list of channel names for the current topology of the device.
    DAQmx_SwitchDev_NumSwitchChans =   $18E8 ; // Indicates the number of switch channels for the current topology of the device. This value matches the number of channel names in Switch Channel List.
    DAQmx_SwitchDev_NumRows =          $18E9 ; // Indicates the number of rows on a device in a matrix switch topology. Indicates the number of multiplexed channels on a device in a mux topology.
    DAQmx_SwitchDev_NumColumns =       $18EA ; // Indicates the number of columns on a device in a matrix switch topology. This value is always 1 if the device is in a mux topology.
    DAQmx_SwitchDev_Topology =         $193D ; // Indicates the current topology of the device. This value is one of the topology options in DAQmxSwitchSetTopologyAndReset().

//********** Switch Scan Attributes **********
    DAQmx_SwitchScan_BreakMode =       $1247 ; // Specifies the break mode between each entry in a scan list.
    DAQmx_SwitchScan_RepeatMode =      $1248 ; // Specifies if the task advances through the scan list multiple times.
    DAQmx_SwitchScan_WaitingForAdv =   $17D9 ; // Indicates if the switch hardware is waiting for an  Advance Trigger. If the hardware is waiting, it completed the previous entry in the scan list.

//********** Scale Attributes **********
    DAQmx_Scale_Descr =                $1226 ; // Specifies a description for the scale.
    DAQmx_Scale_ScaledUnits =          $191B ; // Specifies the units to use for scaled values. You can use an arbitrary string.
    DAQmx_Scale_PreScaledUnits =       $18F7 ; // Specifies the units of the values that you want to scale.
    DAQmx_Scale_Type =                 $1929 ; // Indicates the method or equation form that the custom scale uses.
    DAQmx_Scale_Lin_Slope =            $1227 ; // Specifies the slope, m, in the equation y=mx+b.
    DAQmx_Scale_Lin_YIntercept =       $1228 ; // Specifies the y-intercept, b, in the equation y=mx+b.
    DAQmx_Scale_Map_ScaledMax =        $1229 ; // Specifies the largest value in the range of scaled values. NI-DAQmx maps this value to Pre-Scaled Maximum Value. Reads clip samples that are larger than this value. Writes generate errors for samples that are larger than this value.
    DAQmx_Scale_Map_PreScaledMax =     $1231 ; // Specifies the largest value in the range of pre-scaled values. NI-DAQmx maps this value to Scaled Maximum Value.
    DAQmx_Scale_Map_ScaledMin =        $1230 ; // Specifies the smallest value in the range of scaled values. NI-DAQmx maps this value to Pre-Scaled Minimum Value. Reads clip samples that are smaller than this value. Writes generate errors for samples that are smaller than this value.
    DAQmx_Scale_Map_PreScaledMin =     $1232 ; // Specifies the smallest value in the range of pre-scaled values. NI-DAQmx maps this value to Scaled Minimum Value.
    DAQmx_Scale_Poly_ForwardCoeff =    $1234 ; // Specifies an array of coefficients for the polynomial that converts pre-scaled values to scaled values. Each element of the array corresponds to a term of the equation. For example, if index three of the array is 9, the fourth term of the equation is 9x^3.
    DAQmx_Scale_Poly_ReverseCoeff =    $1235 ; // Specifies an array of coefficients for the polynomial that converts scaled values to pre-scaled values. Each element of the array corresponds to a term of the equation. For example, if index three of the array is 9, the fourth term of the equation is 9y^3.
    DAQmx_Scale_Table_ScaledVals =     $1236 ; // Specifies an array of scaled values. These values map directly to the values in Pre-Scaled Values.
    DAQmx_Scale_Table_PreScaledVals =  $1237 ; // Specifies an array of pre-scaled values. These values map directly to the values in Scaled Values.

//********** System Attributes **********
    DAQmx_Sys_GlobalChans =            $1265 ; // Indicates an array that contains the names of all global channels saved on the system.
    DAQmx_Sys_Scales =                 $1266 ; // Indicates an array that contains the names of all custom scales saved on the system.
    DAQmx_Sys_Tasks =                  $1267 ; // Indicates an array that contains the names of all tasks saved on the system.
    DAQmx_Sys_DevNames =               $193B ; // Indicates an array that contains the names of all devices installed in the system.
    DAQmx_Sys_NIDAQMajorVersion =      $1272 ; // Indicates the major portion of the installed version of NI-DAQ, such as 7 for version 7.0.
    DAQmx_Sys_NIDAQMinorVersion =      $1923 ; // Indicates the minor portion of the installed version of NI-DAQ, such as 0 for version 7.0.

//********** Task Attributes **********
    DAQmx_Task_Name =                  $1276 ; // Indicates the name of the task.
    DAQmx_Task_Channels =              $1273 ; // Indicates the names of all virtual channels in the task.
    DAQmx_Task_NumChans =              $2181 ; // Indicates the number of virtual channels in the task.
    DAQmx_Task_Complete =              $1274 ; // Indicates whether the task completed execution.

//********** Timing Attributes **********
    DAQmx_SampQuant_SampMode =         $1300 ; // Specifies if a task acquires or generates a finite number of samples or if it continuously acquires or generates samples.
    DAQmx_SampQuant_SampPerChan =      $1310 ; // Specifies the number of samples to acquire or generate for each channel if Sample Mode is DAQmx_Val_FiniteSamps. If Sample Mode is DAQmx_Val_ContSamps, NI-DAQmx uses this value to determine the buffer size.
    DAQmx_SampTimingType =             $1347 ; // Specifies the type of sample timing to use for the task.
    DAQmx_SampClk_Rate =               $1344 ; // Specifies the sampling rate in samples per channel per second. If you use an external source for the Sample Clock, set this input to the maximum expected rate of that clock.
    DAQmx_SampClk_Src =                $1852 ; // Specifies the terminal of the signal to use as the Sample Clock.
    DAQmx_SampClk_ActiveEdge =         $1301 ; // Specifies on which edge of a clock pulse sampling takes place. This property is useful primarily when the signal you use as the Sample Clock is not a periodic clock.
    DAQmx_SampClk_TimebaseDiv =        $18EB ; // Specifies the number of Sample Clock Timebase pulses needed to produce a single Sample Clock pulse.
    DAQmx_SampClk_Timebase_Rate =      $1303 ; // Specifies the rate of the Sample Clock Timebase. Some applications require that you specify a rate when you use any signal other than the onboard Sample Clock Timebase. NI-DAQmx requires this rate to calculate other timing parameters.
    DAQmx_SampClk_Timebase_Src =       $1308 ; // Specifies the terminal of the signal to use as the Sample Clock Timebase.
    DAQmx_SampClk_Timebase_ActiveEdge =                                 $18EC ; // Specifies on which edge to recognize a Sample Clock Timebase pulse. This property is useful primarily when the signal you use as the Sample Clock Timebase is not a periodic clock.
    DAQmx_SampClk_Timebase_MasterTimebaseDiv =                          $1305 ; // Specifies the number of pulses of the Master Timebase needed to produce a single pulse of the Sample Clock Timebase.
    DAQmx_SampClk_DigFltr_Enable =     $221E ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_SampClk_DigFltr_MinPulseWidth =                               $221F ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_SampClk_DigFltr_TimebaseSrc =                                 $2220 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_SampClk_DigFltr_TimebaseRate =                                $2221 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_SampClk_DigSync_Enable =     $2222 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_ChangeDetect_DI_RisingEdgePhysicalChans =                     $2195 ; // Specifies the names of the digital lines or ports on which to detect rising edges. The lines or ports must be used by virtual channels in the task. You also can specify a string that contains a list or range of digital lines or ports.
    DAQmx_ChangeDetect_DI_FallingEdgePhysicalChans =                    $2196 ; // Specifies the names of the digital lines or ports on which to detect rising edges. The lines or ports must be used by virtual channels in the task. You also can specify a string that contains a list or range of digital lines or ports.
    DAQmx_OnDemand_SimultaneousAOEnable =                               $21A0 ; // Specifies whether to update all channels in the task simultaneously, rather than updating channels independently when you write a sample to that channel.
    DAQmx_AIConv_Rate =                $1848 ; // Specifies the rate at which to clock the analog-to-digital converter. This clock is specific to the analog input section of an E Series device.
    DAQmx_AIConv_Src =                 $1502 ; // Specifies the terminal of the signal to use as the AI Convert Clock.
    DAQmx_AIConv_ActiveEdge =          $1853 ; // Specifies on which edge of the clock pulse an analog-to-digital conversion takes place.
    DAQmx_AIConv_TimebaseDiv =         $1335 ; // Specifies the number of AI Convert Clock Timebase pulses needed to produce a single AI Convert Clock pulse.
    DAQmx_AIConv_Timebase_Src =        $1339 ; // Specifies the terminal  of the signal to use as the AI Convert Clock Timebase.
    DAQmx_MasterTimebase_Rate =        $1495 ; // Specifies the rate of the Master Timebase.
    DAQmx_MasterTimebase_Src =         $1343 ; // Specifies the terminal of the signal to use as the Master Timebase. On an E Series device, you can choose only between the onboard 20MHz Timebase or the RTSI7 terminal.
    DAQmx_RefClk_Rate =                $1315 ; // Specifies the frequency of the Reference Clock.
    DAQmx_RefClk_Src =                 $1316 ; // Specifies the terminal of the signal to use as the Reference Clock.
    DAQmx_SyncPulse_Src =              $223D ; // Specifies the terminal of the signal to use as the synchronization pulse. The synchronization pulse resets the clock dividers and the ADCs/DACs on the device.
    DAQmx_SyncPulse_SyncTime =         $223E ; // Indicates in seconds the delay required to reset the ADCs/DACs after the device receives the synchronization pulse.
    DAQmx_SyncPulse_MinDelayToStart =  $223F ; // Specifies in seconds the amount of time that elapses after the master device issues the synchronization pulse before the task starts.
    DAQmx_DelayFromSampClk_DelayUnits =                                 $1304 ; // Specifies the units of Delay.
    DAQmx_DelayFromSampClk_Delay =     $1317 ; // Specifies the amount of time to wait after receiving a Sample Clock edge before beginning to acquire the sample. This value is in the units you specify with Delay Units.

//********** Trigger Attributes **********
    DAQmx_StartTrig_Type =             $1393 ; // Specifies the type of trigger to use to start a task.
    DAQmx_DigEdge_StartTrig_Src =      $1407 ; // Specifies the name of a terminal where there is a digital signal to use as the source of the Start Trigger.
    DAQmx_DigEdge_StartTrig_Edge =     $1404 ; // Specifies on which edge of a digital pulse to start acquiring or generating samples.
    DAQmx_DigEdge_StartTrig_DigFltr_Enable =                            $2223 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_DigEdge_StartTrig_DigFltr_MinPulseWidth =                     $2224 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_DigEdge_StartTrig_DigFltr_TimebaseSrc =                       $2225 ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_DigEdge_StartTrig_DigFltr_TimebaseRate =                      $2226 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_DigEdge_StartTrig_DigSync_Enable =                            $2227 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_AnlgEdge_StartTrig_Src =     $1398 ; // Specifies the name of a virtual channel or terminal where there is an analog signal to use as the source of the Start Trigger.
    DAQmx_AnlgEdge_StartTrig_Slope =   $1397 ; // Specifies on which slope of the trigger signal to start acquiring or generating samples.
    DAQmx_AnlgEdge_StartTrig_Lvl =     $1396 ; // Specifies at what threshold in the units of the measurement or generation to start acquiring or generating samples. Use Slope to specify on which slope to trigger on this threshold.
    DAQmx_AnlgEdge_StartTrig_Hyst =    $1395 ; // Specifies a hysteresis level in the units of the measurement or generation. If Slope is DAQmx_Val_RisingSlope, the trigger does not deassert until the source signal passes below  Level minus the hysteresis. If Slope is DAQmx_Val_FallingSlope, the trigger does not deassert until the source signal passes above Level plus the hysteresis.
    DAQmx_AnlgEdge_StartTrig_Coupling =                                 $2233 ; // Specifies the coupling for the source signal of the trigger if the source is a terminal rather than a virtual channel.
    DAQmx_AnlgWin_StartTrig_Src =      $1400 ; // Specifies the name of a virtual channel or terminal where there is an analog signal to use as the source of the Start Trigger.
    DAQmx_AnlgWin_StartTrig_When =     $1401 ; // Specifies whether the task starts acquiring or generating samples when the signal enters or leaves the window you specify with Bottom and Top.
    DAQmx_AnlgWin_StartTrig_Top =      $1403 ; // Specifies the upper limit of the window. Specify this value in the units of the measurement or generation.
    DAQmx_AnlgWin_StartTrig_Btm =      $1402 ; // Specifies the lower limit of the window. Specify this value in the units of the measurement or generation.
    DAQmx_AnlgWin_StartTrig_Coupling = $2234 ; // Specifies the coupling for the source signal of the trigger if the source is a terminal rather than a virtual channel.
    DAQmx_StartTrig_Delay =            $1856 ; // Specifies an amount of time to wait after the Start Trigger is received before acquiring or generating the first sample. This value is in the units you specify with Delay Units.
    DAQmx_StartTrig_DelayUnits =       $18C8 ; // Specifies the units of Delay.
    DAQmx_StartTrig_Retriggerable =    $190F ; // Specifies whether to enable retriggerable counter pulse generation. When you set this property to TRUE, the device generates pulses each time it receives a trigger. The device ignores a trigger if it is in the process of generating pulses.
    DAQmx_RefTrig_Type =               $1419 ; // Specifies the type of trigger to use to mark a reference point for the measurement.
    DAQmx_RefTrig_PretrigSamples =     $1445 ; // Specifies the minimum number of pretrigger samples to acquire from each channel before recognizing the reference trigger. Post-trigger samples per channel are equal to Samples Per Channel minus the number of pretrigger samples per channel.
    DAQmx_DigEdge_RefTrig_Src =        $1434 ; // Specifies the name of a terminal where there is a digital signal to use as the source of the Reference Trigger.
    DAQmx_DigEdge_RefTrig_Edge =       $1430 ; // Specifies on what edge of a digital pulse the Reference Trigger occurs.
    DAQmx_AnlgEdge_RefTrig_Src =       $1424 ; // Specifies the name of a virtual channel or terminal where there is an analog signal to use as the source of the Reference Trigger.
    DAQmx_AnlgEdge_RefTrig_Slope =     $1423 ; // Specifies on which slope of the source signal the Reference Trigger occurs.
    DAQmx_AnlgEdge_RefTrig_Lvl =       $1422 ; // Specifies in the units of the measurement the threshold at which the Reference Trigger occurs.  Use Slope to specify on which slope to trigger at this threshold.
    DAQmx_AnlgEdge_RefTrig_Hyst =      $1421 ; // Specifies a hysteresis level in the units of the measurement. If Slope is DAQmx_Val_RisingSlope, the trigger does not deassert until the source signal passes below Level minus the hysteresis. If Slope is DAQmx_Val_FallingSlope, the trigger does not deassert until the source signal passes above Level plus the hysteresis.
    DAQmx_AnlgEdge_RefTrig_Coupling =  $2235 ; // Specifies the coupling for the source signal of the trigger if the source is a terminal rather than a virtual channel.
    DAQmx_AnlgWin_RefTrig_Src =        $1426 ; // Specifies the name of a virtual channel or terminal where there is an analog signal to use as the source of the Reference Trigger.
    DAQmx_AnlgWin_RefTrig_When =       $1427 ; // Specifies whether the Reference Trigger occurs when the source signal enters the window or when it leaves the window. Use Bottom and Top to specify the window.
    DAQmx_AnlgWin_RefTrig_Top =        $1429 ; // Specifies the upper limit of the window. Specify this value in the units of the measurement.
    DAQmx_AnlgWin_RefTrig_Btm =        $1428 ; // Specifies the lower limit of the window. Specify this value in the units of the measurement.
    DAQmx_AnlgWin_RefTrig_Coupling =   $1857 ; // Specifies the coupling for the source signal of the trigger if the source is a terminal rather than a virtual channel.
    DAQmx_AdvTrig_Type =               $1365 ; // Specifies the type of trigger to use to advance to the next entry in a scan list.
    DAQmx_DigEdge_AdvTrig_Src =        $1362 ; // Specifies the name of a terminal where there is a digital signal to use as the source of the Advance Trigger.
    DAQmx_DigEdge_AdvTrig_Edge =       $1360 ; // Specifies on which edge of a digital signal to advance to the next entry in a scan list.
    DAQmx_DigEdge_AdvTrig_DigFltr_Enable =                              $2238 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_PauseTrig_Type =             $1366 ; // Specifies the type of trigger to use to pause a task.
    DAQmx_AnlgLvl_PauseTrig_Src =      $1370 ; // Specifies the name of a virtual channel or terminal where there is an analog signal to use as the source of the trigger.
    DAQmx_AnlgLvl_PauseTrig_When =     $1371 ; // Specifies whether the task pauses above or below the threshold you specify with Level.
    DAQmx_AnlgLvl_PauseTrig_Lvl =      $1369 ; // Specifies the threshold at which to pause the task. Specify this value in the units of the measurement or generation. Use Pause When to specify whether the task pauses above or below this threshold.
    DAQmx_AnlgLvl_PauseTrig_Hyst =     $1368 ; // Specifies a hysteresis level in the units of the measurement or generation. If Pause When is DAQmx_Val_AboveLvl, the trigger does not deassert until the source signal passes below Level minus the hysteresis. If Pause When is DAQmx_Val_BelowLvl, the trigger does not deassert until the source signal passes above Level plus the hysteresis.
    DAQmx_AnlgLvl_PauseTrig_Coupling = $2236 ; // Specifies the coupling for the source signal of the trigger if the source is a terminal rather than a virtual channel.
    DAQmx_AnlgWin_PauseTrig_Src =      $1373 ; // Specifies the name of a virtual channel or terminal where there is an analog signal to use as the source of the trigger.
    DAQmx_AnlgWin_PauseTrig_When =     $1374 ; // Specifies whether the task pauses while the trigger signal is inside or outside the window you specify with Bottom and Top.
    DAQmx_AnlgWin_PauseTrig_Top =      $1376 ; // Specifies the upper limit of the window. Specify this value in the units of the measurement or generation.
    DAQmx_AnlgWin_PauseTrig_Btm =      $1375 ; // Specifies the lower limit of the window. Specify this value in the units of the measurement or generation.
    DAQmx_AnlgWin_PauseTrig_Coupling = $2237 ; // Specifies the coupling for the source signal of the trigger if the source is a terminal rather than a virtual channel.
    DAQmx_DigLvl_PauseTrig_Src =       $1379 ; // Specifies the name of a terminal where there is a digital signal to use as the source of the Pause Trigger.
    DAQmx_DigLvl_PauseTrig_When =      $1380 ; // Specifies whether the task pauses while the signal is high or low.
    DAQmx_DigLvl_PauseTrig_DigFltr_Enable =                             $2228 ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_DigLvl_PauseTrig_DigFltr_MinPulseWidth =                      $2229 ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_DigLvl_PauseTrig_DigFltr_TimebaseSrc =                        $222A ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_DigLvl_PauseTrig_DigFltr_TimebaseRate =                       $222B ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_DigLvl_PauseTrig_DigSync_Enable =                             $222C ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.
    DAQmx_ArmStartTrig_Type =          $1414 ; // Specifies the type of trigger to use to arm the task for a Start Trigger. If you configure an Arm Start Trigger, the task does not respond to a Start Trigger until the device receives the Arm Start Trigger.
    DAQmx_DigEdge_ArmStartTrig_Src =   $1417 ; // Specifies the name of a terminal where there is a digital signal to use as the source of the Arm Start Trigger.
    DAQmx_DigEdge_ArmStartTrig_Edge =  $1415 ; // Specifies on which edge of a digital signal to arm the task for a Start Trigger.
    DAQmx_DigEdge_ArmStartTrig_DigFltr_Enable =                         $222D ; // Specifies whether to apply the pulse width filter to the signal.
    DAQmx_DigEdge_ArmStartTrig_DigFltr_MinPulseWidth =                  $222E ; // Specifies in seconds the minimum pulse width the filter recognizes.
    DAQmx_DigEdge_ArmStartTrig_DigFltr_TimebaseSrc =                    $222F ; // Specifies the input terminal of the signal to use as the timebase of the pulse width filter.
    DAQmx_DigEdge_ArmStartTrig_DigFltr_TimebaseRate =                   $2230 ; // Specifies in hertz the rate of the pulse width filter timebase. NI-DAQmx uses this value to compute settings for the filter.
    DAQmx_DigEdge_ArmStartTrig_DigSync_Enable =                         $2231 ; // Specifies whether to synchronize recognition of transitions in the signal to the internal timebase of the device.

//********** Watchdog Attributes **********
    DAQmx_Watchdog_Timeout =           $21A9 ; // Specifies in seconds the amount of time until the watchdog timer expires. A value of -1 means the internal timer never expires. Set this input to -1 if you use an Expiration Trigger to expire the watchdog task.
    DAQmx_WatchdogExpirTrig_Type =     $21A3 ; // Specifies the type of trigger to use to expire a watchdog task.
    DAQmx_DigEdge_WatchdogExpirTrig_Src =                               $21A4 ; // Specifies the name of a terminal where a digital signal exists to use as the source of the Expiration Trigger.
    DAQmx_DigEdge_WatchdogExpirTrig_Edge =                              $21A5 ; // Specifies on which edge of a digital signal to expire the watchdog task.
    DAQmx_Watchdog_DO_ExpirState =     $21A7 ; // Specifies the state to which to set the digital physical channels when the watchdog task expires.  You cannot modify the expiration state of dedicated digital input physical channels.
    DAQmx_Watchdog_HasExpired =        $21A8 ; // Indicates if the watchdog timer expired. You can read this property only while the task is running.

//********** Write Attributes **********
    DAQmx_Write_RelativeTo =           $190C ; // Specifies the point in the buffer at which to write data. If you also specify an offset with Offset, the write operation begins at that offset relative to this point you select with this property.
    DAQmx_Write_Offset =               $190D ; // Specifies in samples per channel an offset at which a write operation begins. This offset is relative to the location you specify with Relative To.
    DAQmx_Write_RegenMode =            $1453 ; // Specifies whether to allow NI-DAQmx to generate the same data multiple times.
    DAQmx_Write_CurrWritePos =         $1458 ; // Indicates the number of the next sample for the device to generate. This value is identical for all channels in the task.
    DAQmx_Write_SpaceAvail =           $1460 ; // Indicates in samples per channel the amount of available space in the buffer.
    DAQmx_Write_TotalSampPerChanGenerated =                             $192B ; // Indicates the total number of samples generated by each channel in the task. This value is identical for all channels in the task.
    DAQmx_Write_RawDataWidth =         $217D ; // Indicates in bytes the required size of a raw sample to write to the task.
    DAQmx_Write_NumChans =             $217E ; // Indicates the number of channels that an NI-DAQmx Write function writes to the task. This value is the number of channels in the task.
    DAQmx_Write_DigitalLines_BytesPerChan  =                          $217F ; // Indicates the number of bytes expected per channel in a sample for line-based writes. If a channel has fewer lines than this number, NI-DAQmx ignores the extra bytes.

//********** Physical Channel Attributes **********
    DAQmx_PhysicalChan_TEDS_MfgID =    $21DA ; // Indicates the manufacturer ID of the sensor.
    DAQmx_PhysicalChan_TEDS_ModelNum = $21DB ; // Indicates the model number of the sensor.
    DAQmx_PhysicalChan_TEDS_SerialNum =                                 $21DC ; // Indicates the serial number of the sensor.
    DAQmx_PhysicalChan_TEDS_VersionNum =                                $21DD ; // Indicates the version number of the sensor.
    DAQmx_PhysicalChan_TEDS_VersionLetter =                             $21DE ; // Indicates the version letter of the sensor.
    DAQmx_PhysicalChan_TEDS_BitStream =                                 $21DF ; // Indicates the TEDS binary bitstream without checksums.
    DAQmx_PhysicalChan_TEDS_TemplateIDs =                               $228F ; // Indicates the IDs of the templates in the bitstream in BitStream.


//******************************************************************************
// *** NI-DAQmx Values **********************************************************
// ******************************************************************************/

//******************************************************/
//***    Non-Attribute Function Parameter Values     ***/
//******************************************************/

//*** Values for the Mode parameter of DAQmxTaskControl ***
    DAQmx_Val_Task_Start =              0   ; // Start
    DAQmx_Val_Task_Stop =               1   ; // Stop
    DAQmx_Val_Task_Verify =             2   ; // Verify
    DAQmx_Val_Task_Commit =             3   ; // Commit
    DAQmx_Val_Task_Reserve =            4   ; // Reserve
    DAQmx_Val_Task_Unreserve =          5   ; // Unreserve
    DAQmx_Val_Task_Abort =              6   ; // Abort

//*** Values for the Action parameter of DAQmxControlWatchdogTask ***
    DAQmx_Val_ResetTimer =              0   ; // Reset Timer
    DAQmx_Val_ClearExpiration =         1   ; // Clear Expiration

//*** Values for the Line Grouping parameter of DAQmxCreateDIChan and DAQmxCreateDOChan ***
    DAQmx_Val_ChanPerLine =             0   ; // One Channel For Each Line
    DAQmx_Val_ChanForAllLines =         1   ; // One Channel For All Lines

//*** Values for the Fill Mode parameter of DAQmxReadAnalogF64, DAQmxReadBinaryI16, DAQmxReadBinaryU16, DAQmxReadBinaryI32, DAQmxReadBinaryU32,
//    DAQmxReadDigitalU8, DAQmxReadDigitalU32, DAQmxReadDigitalLines ***
//*** Values for the Data Layout parameter of DAQmxWriteAnalogF64, DAQmxWriteBinaryI16, DAQmxWriteDigitalU8, DAQmxWriteDigitalU32, DAQmxWriteDigitalLines ***
    DAQmx_Val_GroupByChannel =          0   ; // Group by Channel
    DAQmx_Val_GroupByScanNumber =       1   ; // Group by Scan Number

//*** Values for the Signal Modifiers parameter of DAQmxConnectTerms ***/
    DAQmx_Val_DoNotInvertPolarity =     0   ; // Do not invert polarity
    DAQmx_Val_InvertPolarity =          1   ; // Invert polarity

//*** Values for the Action paramter of DAQmxCloseExtCal ***
    DAQmx_Val_Action_Commit =           0   ; // Commit
    DAQmx_Val_Action_Cancel =           1   ; // Cancel

//*** Values for the Trigger ID parameter of DAQmxSendSoftwareTrigger ***
    DAQmx_Val_AdvanceTrigger =          12488 ; // Advance Trigger

//*** Value set for the ActiveEdge parameter of DAQmxCfgSampClkTiming ***
    DAQmx_Val_Rising =                  10280 ; // Rising
    DAQmx_Val_Falling =                 10171 ; // Falling

//*** Value set SwitchPathType ***
//*** Value set for the output Path Status parameter of DAQmxSwitchFindPath ***
    DAQmx_Val_PathStatus_Available =    10431 ; // Path Available
    DAQmx_Val_PathStatus_AlreadyExists =                               10432 ; // Path Already Exists
    DAQmx_Val_PathStatus_Unsupported =  10433 ; // Path Unsupported
    DAQmx_Val_PathStatus_ChannelInUse = 10434 ; // Channel In Use
    DAQmx_Val_PathStatus_SourceChannelConflict =                         10435 ; // Channel Source Conflict
    DAQmx_Val_PathStatus_ChannelReservedForRouting =                     10436 ; // Channel Reserved for Routing

//*** Value set for the Units parameter of DAQmxCreateAIThrmcplChan, DAQmxCreateAIRTDChan, DAQmxCreateAIThrmstrChanIex, DAQmxCreateAIThrmstrChanVex and DAQmxCreateAITempBuiltInSensorChan ***
    DAQmx_Val_DegC =                    10143 ; // Deg C
    DAQmx_Val_DegF =                    10144 ; // Deg F
    DAQmx_Val_Kelvins =                 10325 ; // Kelvins
    DAQmx_Val_DegR =                    10145 ; // Deg R

//*** Value set for the state parameter of DAQmxSetDigitalPowerUpStates ***
    DAQmx_Val_High =                    10192 ; // High
    DAQmx_Val_Low =                     10214 ; // Low
    DAQmx_Val_Tristate =                10310 ; // Tristate

//*** Value set RelayPos ***
//*** Value set for the state parameter of DAQmxSwitchGetSingleRelayPos and DAQmxSwitchGetMultiRelayPos ***
    DAQmx_Val_Open =                    10437 ; // Open
    DAQmx_Val_Closed =                  10438 ; // Closed

//*** Value for the Terminal Config parameter of DAQmxCreateAIVoltageChan, DAQmxCreateAICurrentChan and DAQmxCreateAIVoltageChanWithExcit ***
    DAQmx_Val_Cfg_Default =             -1 ; // Default

//*** Value for the Timeout parameter of DAQmxWaitUntilTaskDone
    DAQmx_Val_WaitInfinitely =          -1.0 ;

//*** Value for the Number of Samples per Channel parameter of DAQmxReadAnalogF64, DAQmxReadBinaryI16, DAQmxReadBinaryU16,
//    DAQmxReadBinaryI32, DAQmxReadBinaryU32, DAQmxReadDigitalU8, DAQmxReadDigitalU32,
//    DAQmxReadDigitalLines, DAQmxReadCounterF64, DAQmxReadCounterU32 and DAQmxReadRaw ***
    DAQmx_Val_Auto =                    -1 ;

//******************************************************/
//***              Attribute Values                  ***/
//******************************************************/

//*** Values for DAQmx_AI_ACExcit_WireMode ***
//*** Value set ACExcitWireMode ***
    DAQmx_Val_4Wire =                       4 ; // 4-Wire
    DAQmx_Val_5Wire =                       5 ; // 5-Wire

//*** Values for DAQmx_AI_MeasType ***
//*** Value set AIMeasurementType ***
    DAQmx_Val_Voltage =                 10322 ; // Voltage
    DAQmx_Val_Current =                 10134 ; // Current
    DAQmx_Val_Voltage_CustomWithExcitation =                             10323 ; // More:Voltage:Custom with Excitation
    DAQmx_Val_Freq_Voltage =            10181 ; // Frequency
    DAQmx_Val_Resistance =              10278 ; // Resistance
    DAQmx_Val_Temp_TC =                 10303 ; // Temperature:Thermocouple
    DAQmx_Val_Temp_Thrmstr =            10302 ; // Temperature:Thermistor
    DAQmx_Val_Temp_RTD =                10301 ; // Temperature:RTD
    DAQmx_Val_Temp_BuiltInSensor =      10311 ; // Temperature:Built-in Sensor
    DAQmx_Val_Strain_Gage =             10300 ; // Strain Gage
    DAQmx_Val_Position_LVDT =           10352 ; // Position:LVDT
    DAQmx_Val_Position_RVDT =           10353 ; // Position:RVDT
    DAQmx_Val_Accelerometer =           10356 ; // Accelerometer
    DAQmx_Val_SoundPressure_Microphone =                               10354 ; // Sound Pressure:Microphone
    DAQmx_Val_TEDS_Sensor =             12531 ; // TEDS Sensor

//*** Values for DAQmx_AO_IdleOutputBehavior ***
//*** Value set AOIdleOutputBehavior ***
    DAQmx_Val_ZeroVolts =               12526 ; // Zero Volts
    DAQmx_Val_HighImpedance =           12527 ; // High Impedance
    DAQmx_Val_MaintainExistingValue =   12528 ; // Maintain Existing Value

//*** Values for DAQmx_AI_Accel_SensitivityUnits ***
//*** Value set AccelSensitivityUnits1 ***
    DAQmx_Val_mVoltsPerG =              12509 ; // mVolts/g
    DAQmx_Val_VoltsPerG =               12510 ; // Volts/g

//*** Values for DAQmx_AI_Accel_Units ***
//*** Value set AccelUnits2 ***
    DAQmx_Val_AccelUnit_g =             10186 ; // g
    DAQmx_Val_FromCustomScale =         10065 ; // From Custom Scale

//*** Values for DAQmx_SampQuant_SampMode ***
//*** Value set AcquisitionType ***
    DAQmx_Val_FiniteSamps =             10178 ; // Finite Samples
    DAQmx_Val_ContSamps =               10123 ; // Continuous Samples
    DAQmx_Val_HWTimedSinglePoint =      12522 ; // Hardware Timed Single Point

//*** Values for DAQmx_AnlgLvl_PauseTrig_When ***
//*** Value set ActiveLevel ***
    DAQmx_Val_AboveLvl =                10093 ; // Above Level
    DAQmx_Val_BelowLvl =                10107 ; // Below Level

//*** Values for DAQmx_AI_RVDT_Units ***
//*** Value set AngleUnits1 ***
    DAQmx_Val_Degrees =                 10146 ; // Degrees
    DAQmx_Val_Radians =                 10273 ; // Radians

//*** Values for DAQmx_CI_AngEncoder_Units ***
//*** Value set AngleUnits2 ***
    DAQmx_Val_Ticks =                   10304 ; // Ticks

//*** Values for DAQmx_AI_AutoZeroMode ***
//*** Value set AutoZeroType1 ***
    DAQmx_Val_None =                    10230 ; // None
    DAQmx_Val_Once =                    10244 ; // Once

//*** Values for DAQmx_SwitchScan_BreakMode ***
//*** Value set BreakMode ***
    DAQmx_Val_NoAction =                10227 ; // No Action
    DAQmx_Val_BreakBeforeMake =         10110 ; // Break Before Make

//*** Values for DAQmx_AI_Bridge_Cfg ***
//*** Value set BridgeConfiguration1 ***
    DAQmx_Val_FullBridge =              10182 ; // Full Bridge
    DAQmx_Val_HalfBridge =              10187 ; // Half Bridge
    DAQmx_Val_QuarterBridge =           10270 ; // Quarter Bridge
    DAQmx_Val_NoBridge =                10228 ; // No Bridge

//*** Values for DAQmx_CI_MeasType ***
//*** Value set CIMeasurementType ***
    DAQmx_Val_CountEdges =              10125 ; // Count Edges
    DAQmx_Val_Freq =                    10179 ; // Frequency
    DAQmx_Val_Period =                  10256 ; // Period
    DAQmx_Val_PulseWidth =              10359 ; // Pulse Width
    DAQmx_Val_SemiPeriod =              10289 ; // Semi Period
    DAQmx_Val_Position_AngEncoder =     10360 ; // Position:Angular Encoder
    DAQmx_Val_Position_LinEncoder =     10361 ; // Position:Linear Encoder
    DAQmx_Val_TwoEdgeSep =              10267 ; // Two Edge Separation

//*** Values for DAQmx_AI_Thrmcpl_CJCSrc ***
//*** Value set CJCSource1 ***
    DAQmx_Val_BuiltIn =                 10200 ; // Built-In
    DAQmx_Val_ConstVal =                10116 ; // Constant Value
    DAQmx_Val_Chan =                    10113 ; // Channel

//*** Values for DAQmx_CO_OutputType ***
//*** Value set COOutputType ***
    DAQmx_Val_Pulse_Time =              10269 ; // Pulse:Time
    DAQmx_Val_Pulse_Freq =              10119 ; // Pulse:Frequency
    DAQmx_Val_Pulse_Ticks =             10268 ; // Pulse:Ticks

//*** Values for DAQmx_ChanType ***
//*** Value set ChannelType ***
    DAQmx_Val_AI =                      10100 ; // Analog Input
    DAQmx_Val_AO =                      10102 ; // Analog Output
    DAQmx_Val_DI =                      10151 ; // Digital Input
    DAQmx_Val_DO =                      10153 ; // Digital Output
    DAQmx_Val_CI =                      10131 ; // Counter Input
    DAQmx_Val_CO =                      10132 ; // Counter Output

//*** Values for DAQmx_CI_CountEdges_Dir ***
//*** Value set CountDirection1 ***
    DAQmx_Val_CountUp =                 10128 ; // Count Up
    DAQmx_Val_CountDown =               10124 ; // Count Down
    DAQmx_Val_ExtControlled =           10326 ; // Externally Controlled

    DAQmx_Val_LowFreq1Ctr =             10105 ; // Low Frequency with 1 Counter
    DAQmx_Val_HighFreq2Ctr =            10157 ; // High Frequency with 2 Counters
    DAQmx_Val_LargeRng2Ctr =            10205 ; // Large Range with 2 Counters

    DAQmx_Val_AC =                      10045 ; // AC
    DAQmx_Val_DC =                      10050 ; // DC
    DAQmx_Val_GND =                     10066 ; // GND

    DAQmx_Val_Internal =                10200 ; // Internal
    DAQmx_Val_External =                10167 ; // External

    DAQmx_Val_Amps =                    10342 ; // Amps
    DAQmx_Val_FromTEDS =                12516 ; // From TEDS

    DAQmx_Val_DMA =                     10054 ; // DMA
    DAQmx_Val_Interrupts =              10204 ; // Interrupts
    DAQmx_Val_ProgrammedIO =            10264 ; // Programmed I/O

    DAQmx_Val_NoChange =                10160 ; // No Change

    DAQmx_Val_SampClkPeriods =          10286 ; // Sample Clock Periods
    DAQmx_Val_Seconds =                 10364 ; // Seconds

    DAQmx_Val_X1 =                      10090 ; // X1
    DAQmx_Val_X2 =                      10091 ; // X2
    DAQmx_Val_X4 =                      10092 ; // X4
    DAQmx_Val_TwoPulseCounting =        10313 ; // Two Pulse Counting

    DAQmx_Val_AHighBHigh =              10040 ; // A High B High
    DAQmx_Val_AHighBLow =               10041 ; // A High B Low
    DAQmx_Val_ALowBHigh =               10042 ; // A Low B High
    DAQmx_Val_ALowBLow =                10043 ; // A Low B Low

    DAQmx_Val_Pulse =                   10265 ; // Pulse
    DAQmx_Val_Toggle =                  10307 ; // Toggle

    DAQmx_Val_Lvl =                     10210 ; // Level

    DAQmx_Val_Hz =                      10373 ; // Hz

    DAQmx_Val_OnBrdMemMoreThanHalfFull =                                 10237 ; // On Board Memory More than Half Full
    DAQmx_Val_OnBrdMemNotEmpty =        10241 ; // On Board Memory Not Empty

    DAQmx_Val_RSE =                     10083 ; // RSE
    DAQmx_Val_NRSE =                    10078 ; // NRSE
    DAQmx_Val_Diff =                    10106 ; // Differential
    DAQmx_Val_PseudoDiff =              12529 ; // Pseudodifferential

    DAQmx_Val_mVoltsPerVoltPerMillimeter =                               12506 ; // mVolts/Volt/mMeter
    DAQmx_Val_mVoltsPerVoltPerMilliInch =                                12505 ; // mVolts/Volt/0.001 Inch

    DAQmx_Val_Meters =                  10219 ; // Meters
    DAQmx_Val_Inches =                  10379 ; // Inches

    DAQmx_Val_SameAsSampTimebase =      10284 ; // Same as Sample Timebase
    DAQmx_Val_SameAsMasterTimebase =    10282 ; // Same as Master Timebase
    DAQmx_Val_20MHzTimebase =           12537 ; // 20MHz Timebase

    DAQmx_Val_OnBrdMemEmpty =           10235 ; // On Board Memory Empty
    DAQmx_Val_OnBrdMemHalfFullOrLess =  10239 ; // On Board Memory Half Full or Less
    DAQmx_Val_OnBrdMemNotFull =         10242 ; // On Board Memory Less than Full

    DAQmx_Val_OverwriteUnreadSamps =    10252 ; // Overwrite Unread Samples
    DAQmx_Val_DoNotOverwriteUnreadSamps =                              10159 ; // Do Not Overwrite Unread Samples

    DAQmx_Val_ActiveHigh =              10095 ; // Active High
    DAQmx_Val_ActiveLow =               10096 ; // Active Low

    DAQmx_Val_Pt3750 =                  12481 ; // Pt3750
    DAQmx_Val_Pt3851 =                  10071 ; // Pt3851
    DAQmx_Val_Pt3911 =                  12482 ; // Pt3911
    DAQmx_Val_Pt3916 =                  10069 ; // Pt3916
    DAQmx_Val_Pt3920 =                  10053 ; // Pt3920
    DAQmx_Val_Pt3928 =                  12483 ; // Pt3928
    DAQmx_Val_Custom =                  10137 ; // Custom

    DAQmx_Val_mVoltsPerVoltPerDegree =  12507 ; // mVolts/Volt/Degree
    DAQmx_Val_mVoltsPerVoltPerRadian =  12508 ; // mVolts/Volt/Radian

    DAQmx_Val_FirstSample =             10424 ; // First Sample
    DAQmx_Val_CurrReadPos =             10425 ; // Current Read Position
    DAQmx_Val_RefTrig =                 10426 ; // Reference Trigger
    DAQmx_Val_FirstPretrigSamp =        10427 ; // First Pretrigger Sample
    DAQmx_Val_MostRecentSamp =          10428 ; // Most Recent Sample

    DAQmx_Val_AllowRegen =              10097 ; // Allow Regeneration
    DAQmx_Val_DoNotAllowRegen =         10158 ; // Do Not Allow Regeneration

    DAQmx_Val_2Wire =                       2 ; // 2-Wire
    DAQmx_Val_3Wire =                       3 ; // 3-Wire

    DAQmx_Val_Ohms =                    10384 ; // Ohms

    DAQmx_Val_Bits =                    10109 ; // Bits

    DAQmx_Val_SampClk =                 10388 ; // Sample Clock
    DAQmx_Val_Handshake =               10389 ; // Handshake
    DAQmx_Val_Implicit =                10451 ; // Implicit
    DAQmx_Val_OnDemand =                10390 ; // On Demand
    DAQmx_Val_ChangeDetection =         12504 ; // Change Detection

    DAQmx_Val_Linear =                  10447 ; // Linear
    DAQmx_Val_MapRanges =               10448 ; // Map Ranges
    DAQmx_Val_Polynomial =              10449 ; // Polynomial
    DAQmx_Val_Table =                   10450 ; // Table

    DAQmx_Val_A =                       12513 ; // A
    DAQmx_Val_B =                       12514 ; // B
    DAQmx_Val_AandB =                   12515 ; // A and B

    DAQmx_Val_AIConvertClock =          12484 ; // AI Convert Clock
    DAQmx_Val_10MHzRefClock =           12536 ; // 10MHz Reference Clock
    DAQmx_Val_20MHzTimebaseClock =      12486 ; // 20MHz Timebase Clock
    DAQmx_Val_SampleClock =             12487 ; // Sample Clock
    DAQmx_Val_ReferenceTrigger =        12490 ; // Reference Trigger
    DAQmx_Val_StartTrigger =            12491 ; // Start Trigger
    DAQmx_Val_AdvCmpltEvent =           12492 ; // Advance Complete Event
    DAQmx_Val_AIHoldCmpltEvent =        12493 ; // AI Hold Complete Event
    DAQmx_Val_CounterOutputEvent =      12494 ; // Counter Output Event
    DAQmx_Val_ChangeDetectionEvent =    12511 ; // Change Detection Event
    DAQmx_Val_WDTExpiredEvent =         12512 ; // Watchdog Timer Expired Event

    DAQmx_Val_RisingSlope =             10280 ; // Rising
    DAQmx_Val_FallingSlope =            10171 ; // Falling

    DAQmx_Val_Pascals =                 10081 ; // Pascals

    DAQmx_Val_FullBridgeI =             10183 ; // Full Bridge I
    DAQmx_Val_FullBridgeII =            10184 ; // Full Bridge II
    DAQmx_Val_FullBridgeIII =           10185 ; // Full Bridge III
    DAQmx_Val_HalfBridgeI =             10188 ; // Half Bridge I
    DAQmx_Val_HalfBridgeII =            10189 ; // Half Bridge II
    DAQmx_Val_QuarterBridgeI =          10271 ; // Quarter Bridge I
    DAQmx_Val_QuarterBridgeII =         10272 ; // Quarter Bridge II

    DAQmx_Val_Strain =                  10299 ; // Strain

    DAQmx_Val_Finite =                  10172 ; // Finite
    DAQmx_Val_Cont =                    10117 ; // Continuous

    DAQmx_Val_Source =                  10439 ; // Source
    DAQmx_Val_Load =                    10440 ; // Load
    DAQmx_Val_ReservedForRouting =      10441 ; // Reserved for Routing

    DAQmx_Val_J_Type_TC =               10072 ; // J
    DAQmx_Val_K_Type_TC =               10073 ; // K
    DAQmx_Val_N_Type_TC =               10077 ; // N
    DAQmx_Val_R_Type_TC =               10082 ; // R
    DAQmx_Val_S_Type_TC =               10085 ; // S
    DAQmx_Val_T_Type_TC =               10086 ; // T
    DAQmx_Val_B_Type_TC =               10047 ; // B
    DAQmx_Val_E_Type_TC =               10055 ; // E

    DAQmx_Val_AnlgEdge =                10099 ; // Analog Edge
    DAQmx_Val_DigEdge =                 10150 ; // Digital Edge
    DAQmx_Val_AnlgWin =                 10103 ; // Analog Window

    DAQmx_Val_Software =                10292 ; // Software

    DAQmx_Val_AnlgLvl =                 10101 ; // Analog Level
    DAQmx_Val_DigLvl =                  10152 ; // Digital Level

    DAQmx_Val_Volts =                   10348 ; // Volts
    DAQmx_Val_g =                       10186 ; // g

    DAQmx_Val_WaitForInterrupt =        12523 ; // Wait For Interrupt
    DAQmx_Val_Poll =                    12524 ; // Poll
    DAQmx_Val_Yield =                   12525 ; // Yield

    DAQmx_Val_EnteringWin =             10163 ; // Entering Window
    DAQmx_Val_LeavingWin =              10208 ; // Leaving Window

    DAQmx_Val_InsideWin =               10199 ; // Inside Window
    DAQmx_Val_OutsideWin =              10251 ; // Outside Window

    DAQmx_Val_WriteToEEPROM =           12538 ; // Write To EEPROM
    DAQmx_Val_WriteToPROM =             12539 ; // Write To PROM Once
    DAQmx_Val_DoNotWrite =              12540 ; // Do Not Write

    DAQmx_Val_CurrWritePos = 10430 ; // Current Write Position

function NIMX_IsLabInterfaceAvailable : boolean ;
function NIMX_InitialiseBoard : Boolean ;
function NIMX_DeviceExists( DevName : ANSIString ) : Boolean ;

procedure NIMX_LoadLibrary  ;

function NIMX_LoadProcedure(
         Hnd : THandle ;       { Library DLL handle }
         Name : string         { Procedure name within DLL }
         ) : Pointer ;         { Return pointer to procedure }

procedure NIMX_DisableFPUExceptions ;

procedure NIMX_EnableFPUExceptions ;

procedure NIMX_GetDeviceList(
          var DeviceList : TStringList
          ) ;

function  NIMX_GetLabInterfaceInfo(
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

procedure NIMX_GetChannelOffsets(
          ADCInputMode : Integer ;
          var Offsets : Array of Integer ;
          var NumChannels : Integer
          ) ;

procedure  NIMX_CheckError( Err : Integer ) ;

procedure NIMX_CheckADCSamplingInterval(
               var SamplingInterval : double ;
               NumADCChannels : Integer ;
               ADCInputMode : Integer ) ;

procedure NIMX_CheckDACSamplingInterval(
               var SamplingInterval : double ;
               NumDACChannels : Integer
               ) ;


function NIMX_ADCToMemory(
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

procedure NIMX_GetADCSamples(
          var ADCBuf : Array of SmallInt  ;
          var OutPointer : Integer ;
          var ADCChannelVoltageRanges : Array of Single
          ) ;

function NIMX_StopADC : Boolean ;

function NIMX_MemoryToDAC(
            var DACBuf : Array of SmallInt  ;
            nChannels : Integer ;
            nPoints : Integer ;
            UpdateInterval : Double ;
            ExternalTrigger : Boolean ;
            RepeatWaveform : Boolean
            ) : Boolean ;

function NIMX_StopDAC : Boolean ;

function NIMX_MemoryToDIG(
            var DIGBuf : Array of SmallInt  ;
            nPoints : Integer ;
            UpdateInterval : Double ;
            RepeatWaveform : Boolean
            ) : Boolean ;

function NIMX_StopDIG : Boolean ;

procedure NIMX_WriteDACs(
               DACVolts : array of Single ;
               nChannels : Integer
               ) ;

function NIMX_ReadADC(
              Channel : Integer ;
              ADCVoltageRange : Single ;
              ADCInputMode : Integer
              ) : Integer ;

procedure NIMX_WriteToDigitalOutPutPort(
          Pattern : Integer
          ) ;

function NIMX_ReadDigitalInputPort : Integer ;

function NIMX_GetValidExternalTriggerPolarity(
         Value : Boolean
         ) : Boolean ;

procedure NIMX_CloseLaboratoryInterface ;

function NIMX_CheckMaxADCChannels(
          ADCInputMode : Integer
          ) : Integer ;

function NIMX_GetADCInputModeCode( ADCInputMode : Integer ) : Integer ;


type

TDAQmxLoadTask = function(
                 const TaskName : PANSIChar ;
                 var TaskHandle : Integer) : Integer ; stdcall  ;

TDAQmxCreateTask          = function(
                            const TaskName : PANSIChar ;
                            var TaskHandle : Integer) : Integer ; stdcall  ;

TDAQmxSelfCal = function(
                const DeviceName : PANSIChar
                ) : Integer ; stdcall  ;

TDAQmxGetDevAIMaxMultiChanRate = function(
                                 const DeviceName : PANSIChar ;
                                 var Rate : Double
                                 ) : Integer ; stdcall  ;

TDAQmxGetDevAIMinRate = function(
                        const DeviceName : PANSIChar ;
                        var Rate : Double
                        ) : Integer ; stdcall  ;

TDAQmxGetDevAIPhysicalChans = function(
                              const DeviceName : PANSIChar ;
                              AINames : PANSIChar;
                              NumChars : Integer
                              ) : Integer ; stdcall  ;

TDAQmxGetDevAIVoltageRngs = function(
                       const DeviceName : PANSIChar ;
                       var AIRanges : Array of Double ;
                       ArraySize : Integer
                       ) : Integer ; stdcall  ;

TDAQmxGetDevAOSampClkSupported = function(
                        const DeviceName : PANSIChar ;
                        var ClockSupported : LongBool
                        ) : Integer ; stdcall  ;

TDAQmxGetDevAOMaxRate = function(
                        const DeviceName : PANSIChar ;
                        var Rate : Double
                        ) : Integer ; stdcall  ;

TDAQmxGetDevAOMinRate = function(
                        const DeviceName : PANSIChar ;
                        var Rate : Double
                        ) : Integer ; stdcall  ;

TDAQmxGetDevAOPhysicalChans = function(
                              const DeviceName : PANSIChar ;
                              AONames : PANSIChar;
                              NumChars : Integer
                              ) : Integer ; stdcall  ;

TDAQmxGetDevAOVoltageRngs = function(
                            const DeviceName : PANSIChar ;
                            var AORanges : Array of Double ;
                            ArraySize : Integer
                            ) : Integer ; stdcall  ;

TDAQmxGetDevDOMaxRate = function(
                        const DeviceName : PANSIChar ;
                        var Rate : Double
                        ) : Integer ; stdcall  ;


TDAQmxGetAIDevScalingCoeff = function(
                             TaskHandle : Integer ;
                             const ChannelName : PANSIChar ;
                             var ScaleFactors : Array of Double ;
                             ScaleFactorsSize : Integer
                             )  : Integer ; stdcall  ;

// Channel Names must be valid channels already available in MAX. They are not created.
TDAQmxAddGlobalChansToTask= function(
                            TaskHandle : Integer ;
                            const channelNames : PANSIChar ) : Integer ; stdcall  ;

TDAQmxStartTask           = function(TaskHandle : Integer ) : Integer ; stdcall  ;

TDAQmxStopTask            = function(TaskHandle : Integer ) : Integer ; stdcall  ;

TDAQmxClearTask           = function(TaskHandle : Integer ) : Integer ; stdcall  ;

TDAQmxWaitUntilTaskDone   = function(
                            TaskHandle : Integer ;
                            TimeToWait : Double) : Integer ; stdcall  ;

TDAQmxIsTaskDone          = function(
                            TaskHandle : Integer;
                            var IsTaskDone : LongBool ) : Integer ; stdcall  ;

TDAQmxTaskControl         = function(
                            TaskHandle : Integer ;
                            Action : Integer) : Integer ; stdcall  ;

TDAQmxGetNthTaskChannel   = function(
                            TaskHandle : Integer ;
                            Index : Cardinal;
                            Buffer : PANSIChar;
                            BufferSize : Integer) : Integer ; stdcall  ;

TDAQmxCreateAIVoltageChan          = function(
                                     TaskHandle : Integer ;
                                     PhysicalChannel : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     TerminalConfig : Integer;
                                     MinVal : Double ;
                                     MaxVal : Double ;
                                     Units : Integer ;
                                     const CustomScaleName : PANSIChar ) : Integer ; stdcall  ;

TDAQmxCreateAOVoltageChan          = function(
                                     TaskHandle : Integer ;
                                     PhysicalChannel : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     MinVal : Double ;
                                     MaxVal : Double  ;
                                     Units : Integer ;
                                     const CustomScaleName : PANSIChar) : Integer ; stdcall  ;

TDAQmxCreateDIChan                 = function(
                                     TaskHandle : Integer;
                                     const Lines : PANSIChar;
                                     const NameToAssignToLines : PANSIChar;
                                     LineGrouping : Integer) : Integer ; stdcall  ;

TDAQmxCreateDOChan                 = function(
                                     TaskHandle : Integer;
                                     const Lines : PANSIChar;
                                     const NameToAssignToLines : PANSIChar;
                                     LineGrouping : Integer) : Integer ; stdcall  ;

TDAQmxCreateCIFreqChan             = function(
                                     TaskHandle : Integer ;
                                     const Counter : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     MinVal : Double ;
                                     MaxVal : Double  ;
                                     Edge : Integer;
                                     measMethod : Integer ;
                                     measTime : Double;
                                     divisor : Cardinal;
                                     const CustomScaleName : PANSIChar) : Integer ; stdcall  ;

TDAQmxCreateCIPeriodChan           = function(
                                     TaskHandle : Integer ;
                                     const Counter : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     MinVal : Double ;
                                     MaxVal : Double  ;
                                     Edge : Integer;
                                     measMethod : Integer ;
                                     measTime : Double;
                                     divisor : Cardinal;
                                     const CustomScaleName : PANSIChar) : Integer ; stdcall  ;

TDAQmxCreateCICountEdgesChan       = function(
                                     TaskHandle : Integer ;
                                     const Counter : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     Edge : Integer; initialCount : Cardinal;
                                     countDirection : Integer) : Integer ; stdcall  ;

TDAQmxCreateCIPulseWidthChan       = function(
                                     TaskHandle : Integer ;
                                     const Counter : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     MinVal : Double ;
                                     MaxVal : Double  ;
                                     startingEdge : Integer;
                                     const CustomScaleName : PANSIChar) : Integer ; stdcall  ;

TDAQmxCreateCISemiPeriodChan       = function(
                                     TaskHandle : Integer ;
                                     const Counter : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     MinVal : Double ;
                                     MaxVal : Double  ;
                                     const CustomScaleName : PANSIChar) : Integer ; stdcall  ;

TDAQmxCreateCITwoEdgeSepChan       = function(
                                     TaskHandle : Integer ;
                                     const Counter : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     MinVal : Double ;
                                     MaxVal : Double  ;
                                     firstEdge : Integer;
                                     secondEdge : Integer;
                                     const CustomScaleName : PANSIChar) : Integer ; stdcall  ;

TDAQmxCreateCOPulseChanFreq        = function(
                                     TaskHandle : Integer ;
                                     const Counter : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     Units : Integer ;
                                     idleState : Integer ;
                                     initialDelay : Double ;
                                     freq : Double ;
                                     dutyCycle : Double ) : Integer ; stdcall  ;

TDAQmxCreateCOPulseChanTime        = function(
                                     TaskHandle : Integer ;
                                     Counter : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     Units : Integer ;
                                     idleState : Integer;
                                     initialDelay : Double;
                                     lowTime : Double;
                                     highTime : Double) : Integer ; stdcall  ;

TDAQmxCreateCOPulseChanTicks       = function(
                                     TaskHandle : Integer ;
                                     const Counter : PANSIChar;
                                     NameToAssignToChannel : PANSIChar;
                                     const sourceTerminal : PANSIChar;
                                     idleState : Integer; initialDelay : Integer ;
                                     lowTicks : Integer;
                                     highTicks : Integer) : Integer ; stdcall  ;

TDAQmxCfgSampClkTiming          = function(
                                  TaskHandle : Integer ;
                                  const source : PANSIChar;
                                  rate : Double;
                                  activeEdge : integer;
                                  sampleMode : Integer;
                                  sampsPerChan : Int64) : Integer ; stdcall  ;

TDAQmxCfgHandshakingTiming      = function(
                                  TaskHandle : Integer ;
                                  sampleMode : Integer;
                                  sampsPerChan : Int64) : Integer ; stdcall  ;

TDAQmxCfgChangeDetectionTiming  = function(
                                  TaskHandle : Integer ;
                                  const risingEdgeChan : PANSIChar;
                                  const fallingEdgeChan : PANSIChar;
                                  sampleMode : Integer;
                                  sampsPerChan : Int64) : Integer ; stdcall  ;

TDAQmxCfgImplicitTiming         = function(
                                  TaskHandle : Integer ;
                                  sampleMode : Integer;
                                  sampsPerChan : Int64) : Integer ; stdcall  ;

TDAQmxResetTimingAttribute      = function(
                                  TaskHandle : Integer ;
                                  attribute : Integer) : Integer ; stdcall  ;

TDAQmxDisableStartTrig      = function(
                              TaskHandle : Integer ) : Integer ; stdcall  ;

TDAQmxCfgDigEdgeStartTrig   = function(
                              TaskHandle : Integer ;
                              triggerSource : PANSIChar ;
                              triggerEdge : Integer) : Integer ; stdcall  ;

TDAQmxCfgAnlgEdgeStartTrig  = function(
                              TaskHandle : Integer ;
                              const triggerSource : PANSIChar;
                              triggerSlope : Integer;
                              triggerLevel : Double) : Integer ; stdcall  ;

TDAQmxCfgAnlgWindowStartTrig= function(
                              TaskHandle : Integer ;
                              const triggerSource : PANSIChar;
                              triggerWhen : Integer;
                              windowTop : Double;
                              windowBottom : Double) : Integer ; stdcall  ;

TDAQmxDisableRefTrig        = function(
                              TaskHandle : Integer ) : Integer ; stdcall  ;

TDAQmxCfgDigEdgeRefTrig     = function(
                              TaskHandle : Integer ;
                              const triggerSource : PANSIChar;
                              triggerEdge : Integer;
                              pretriggerSamples : Cardinal) : Integer ; stdcall  ;

TDAQmxCfgAnlgEdgeRefTrig    = function(
                              TaskHandle : Integer ;
                              const triggerSource : PANSIChar;
                              triggerSlope : Integer;
                              triggerLevel : Double;
                              pretriggerSamples : Cardinal) : Integer ; stdcall  ;

TDAQmxCfgAnlgWindowRefTrig  = function(
                              TaskHandle : Integer ;
                              const triggerSource : PANSIChar;
                              triggerWhen : Integer;
                              windowTop : Double;
                              windowBottom : Double;
                              pretriggerSamples : Cardinal) : Integer ; stdcall  ;

TDAQmxDisableAdvTrig        = function(
                              TaskHandle : Integer ) : Integer ; stdcall  ;

TDAQmxCfgDigEdgeAdvTrig     = function(
                              TaskHandle : Integer ;
                              const triggerSource : PANSIChar;
                              triggerEdge : Integer) : Integer ; stdcall  ;

TDAQmxSendSoftwareTrigger   = function(
                              TaskHandle : Integer ;
                              triggerID : Integer) : Integer ; stdcall  ;

TDAQmxReadAnalogF64         = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              fillMode : Integer ;
                              readArray :  Pointer ;
                              arraySizeInSamps : Integer ;
                              var sampsPerChanRead : Integer;
                              reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxReadAnalogScalarF64   = function(
                              TaskHandle : Integer ;
                              timeout : Double;
                              var value : Double;
                              reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxReadBinaryI16         = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              fillMode : Integer ;
                              readArray : Pointer ;
                              arraySizeInSamps : Integer ;
                              var sampsPerChanRead : Integer;
                              Reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxReadBinaryU16         = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              fillMode : LongBool;
                              var readArray : Array of Word;
                              arraySizeInSamps : Cardinal;
                              var sampsPerChanRead : Integer;
                              var reserved : LongBool) : Integer ; stdcall  ;

TDAQmxReadBinaryI32         = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              fillMode : Integer ;
                              readArray : Pointer ;
                              arraySizeInSamps : Integer ;
                              var sampsPerChanRead : Integer;
                              Reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxReadBinaryU32         = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              fillMode : Integer ;
                              readArray : Pointer ;
                              arraySizeInSamps : Integer ;
                              var sampsPerChanRead : Integer;
                              Reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxReadDigitalU8         = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              fillMode : Integer ;
                              var readArray : Array of Byte;
                              arraySizeInSamps : Integer ;
                              var sampsPerChanRead : Integer;
                              reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxReadDigitalU32        = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              fillMode : Integer ;
                              var readArray : Array of Cardinal;
                              arraySizeInSamps : Cardinal;
                              var sampsPerChanRead : Integer;
                              var reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxReadDigitalScalarU32  = function(
                              TaskHandle : Integer ;
                              timeout : Double;
                              var value : Integer ;
                              Reserved : Pointer
                              ) : Integer ; stdcall  ;

TDAQmxReadDigitalLines      = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              fillMode : LongBool;
                              var readArray : Array of Byte;
                              arraySizeInBytes : Cardinal;
                              var sampsPerChanRead : Integer;
                              var numBytesPerSamp : Integer;
                              var reserved : LongBool) : Integer ; stdcall  ;

TDAQmxReadCounterF64        = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              var readArray : Array of Double;
                              arraySizeInSamps : Cardinal;
                              var sampsPerChanRead : Integer;
                              var reserved : LongBool) : Integer ; stdcall  ;

TDAQmxReadCounterU32        = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              var readArray : Array of Cardinal;
                              arraySizeInSamps : Cardinal;
                              var sampsPerChanRead : Integer;
                              var reserved : LongBool) : Integer ; stdcall  ;

TDAQmxReadCounterScalarF64  = function(
                              TaskHandle : Integer ;
                              timeout : Double;
                              var value : Double;
                              var reserved : LongBool) : Integer ; stdcall  ;

TDAQmxReadCounterScalarU32  = function(
                              TaskHandle : Integer ;
                              timeout : Double;
                              var value : Cardinal;
                              var reserved : LongBool) : Integer ; stdcall  ;

TDAQmxReadRaw               = function(
                              TaskHandle : Integer ;
                              numSampsPerChan : Integer;
                              timeout : Double;
                              ReadArray : Pointer;
                              arraySizeInBytes : Integer ;
                              var sampsRead : Integer ;
                              var numBytesPerSamp : Integer;
                              Reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxGetNthTaskReadChannel = function(
                              TaskHandle : Integer ;
                              Index : Cardinal;
                              Buffer : PANSIChar;
                              BufferSize : Integer) : Integer ; stdcall  ;

TDAQmxWriteAnalogF64          = function(
                                TaskHandle : Integer ;
                                numSampsPerChan : Integer;
                                autoStart : LongBool;
                                timeout : Double;
                                dataLayout : Integer ;
                                writeArray : Pointer ;
                                var sampsPerChanWritten : Integer ;
                                reserved : Pointer
                                ) : Integer ; stdcall  ;

TDAQmxWriteAnalogScalarF64    = function(
                                TaskHandle : Integer ;
                                autoStart : LongBool;
                                timeout : Double;
                                value : Double;
                                var reserved : LongBool) : Integer ; stdcall  ;

TDAQmxWriteBinaryI16          = function(
                                TaskHandle : Integer ;
                                numSampsPerChan : Integer;
                                autoStart : LongBool;
                                timeout : Double;
                                dataLayout : Integer ;
                                writeArray :  Pointer ;
                                var sampsPerChanWritten : Integer;
                                reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxWriteBinaryU16          = function(
                                TaskHandle : Integer ;
                                numSampsPerChan : Integer;
                                autoStart : LongBool;
                                timeout : Double;
                                dataLayout : LongBool;
                                var writeArray : Array of Word;
                                var sampsPerChanWritten : Integer;
                                Reserved : Pointer) : Integer ; stdcall  ;

TDAQmxWriteDigitalU8          = function(
                                TaskHandle : Integer ;
                                numSampsPerChan : Integer;
                                autoStart : LongBool;
                                timeout : Double;
                                dataLayout : Integer ;
                                writeArray : Pointer ;
                                var sampsPerChanWritten : Integer;
                                Reserved : Pointer ) : Integer ; stdcall  ;

TDAQmxWriteDigitalU32         = function(
                                TaskHandle : Integer ;
                                numSampsPerChan : Integer;
                                autoStart : LongBool;
                                timeout : Double;
                                dataLayout : Integer ;
                                writeArray : Pointer ;
                                var sampsPerChanWritten : Integer;
                                Reserved : Pointer) : Integer ; stdcall  ;

TDAQmxWriteDigitalScalarU32   = function(
                                TaskHandle : Integer ;
                                autoStart : LongBool;
                                timeout : Double;
                                value : Integer ;
                                Reserved : Pointer) : Integer ; stdcall  ;

TDAQmxWriteDigitalLines       = function(
                                TaskHandle : Integer ;
                                numSampsPerChan : Integer;
                                autoStart : LongBool;
                                timeout : Double;
                                dataLayout : LongBool;
                                var writeArray : Array of Byte;
                                var sampsPerChanWritten : Integer;
                                Reserved : Pointer) : Integer ; stdcall  ;

TDAQmxWriteRaw                = function(
                                TaskHandle : Integer ;
                                numSamps : Integer ;
                                autoStart : LongBool;
                                timeout : Double;
                                writeArray : Pointer;
                                var sampsPerChanWritten : Integer ;
                                Reserved : Pointer
                                ) : Integer ; stdcall  ;

TDAQmxExportSignal                = function(
                                    TaskHandle : Integer ;
                                    signalID : Integer ;
                                    const outputTerminal : PANSIChar ) : Integer ; stdcall  ;

TDAQmxCfgInputBuffer   = function(
                         TaskHandle : Integer ;
                         numSampsPerChan : Integer ) : Integer ; stdcall  ;

TDAQmxCfgOutputBuffer  = function(
                         TaskHandle : Integer ;
                         numSampsPerChan : Integer ) : Integer ; stdcall  ;

TDAQmxConnectTerms         = function(
                             const sourceTerminal : PANSIChar ;
                             const destinationTerminal : PANSIChar ;
                             signalModifiers : Integer) : Integer ; stdcall  ;

TDAQmxDisconnectTerms      = function(
                             const sourceTerminal : PANSIChar ;
                             const destinationTerminal : PANSIChar ) : Integer ; stdcall  ;

TDAQmxTristateOutputTerm   = function(
                             const outputTerminal : PANSIChar ) : Integer ; stdcall  ;

TDAQmxResetDevice              = function(
                                 const deviceName : PANSIChar) : Integer ; stdcall  ;

TDAQmxGetErrorString       = function(
                             errorCode : Integer ;
                             var errorString : Array of ANSIChar ;
                             bufferSize : Cardinal ) : Integer ; stdcall  ;

TDAQmxGetExtendedErrorInfo = function(
                             const errorString : Array of ANSIChar ;
                             bufferSize : Cardinal ) : Integer ; stdcall  ;


TDAQmxGetAIResolutionUnits= function(
                            TaskHandle : Integer ;
                            const channel : PANSIChar ;
                            var Result : Integer
                            ) : Integer ; stdcall ;

TDAQmxGetAIResolution= function(
                       TaskHandle : Integer ;
                       const channel : PANSIChar ;
                       var Result : Double
                       ) : Integer ; stdcall  ;

TDAQmxGetAOResolutionUnits= function(
                            TaskHandle : Integer ;
                            const channel : PANSIChar ;
                            var Result : Integer
                            ) : Integer ; stdcall ;

TDAQmxGetAOResolution= function(
                       TaskHandle : Integer ;
                       const channel : PANSIChar ;
                       var Result : Double
                       ) : Integer ; stdcall  ;

TDAQmxGetAIRngHigh= function(
                    TaskHandle : Integer ;
                    const channel : PANSIChar ;
                     var Result : Double
                     ) : Integer ; stdcall  ;

TDAQmxSetAIRngHigh= function(
                    TaskHandle : Integer ;
                    const channel : PANSIChar ;
                    Value : Double
                    ) : Integer ; stdcall  ;

TDAQmxResetAIRngHigh= function(
                      TaskHandle : Integer ;
                      const channel : PANSIChar
                      ) : Integer ; stdcall  ;

TDAQmxGetAIRngLow= function(
                   TaskHandle : Integer ;
                   const channel : PANSIChar ;
                   var Result : Double
                   ) : Integer ; stdcall  ;

TDAQmxSetAIRngLow= function(
                   TaskHandle : Integer ;
                   const channel : PANSIChar ;
                   Value : Double
                   ) : Integer ; stdcall  ;

TDAQmxResetAIRngLow= function(
                     TaskHandle : Integer ;
                     const channel : PANSIChar
                     ) : Integer ; stdcall  ;

TDAQmxGetAIMax= function(
                    TaskHandle : Integer ;
                    const channel : PANSIChar ;
                     var Result : Double
                     ) : Integer ; stdcall  ;

TDAQmxSetAIMax= function(
                    TaskHandle : Integer ;
                    const channel : PANSIChar ;
                    Value : Double
                    ) : Integer ; stdcall  ;

TDAQmxResetAIMax= function(
                      TaskHandle : Integer ;
                      const channel : PANSIChar
                      ) : Integer ; stdcall  ;

TDAQmxGetAIMin= function(
                   TaskHandle : Integer ;
                   const channel : PANSIChar ;
                   var Result : Double
                   ) : Integer ; stdcall  ;

TDAQmxSetAIMin= function(
                   TaskHandle : Integer ;
                   const channel : PANSIChar ;
                   Value : Double
                   ) : Integer ; stdcall  ;

TDAQmxResetAIMin= function(
                     TaskHandle : Integer ;
                     const channel : PANSIChar
                     ) : Integer ; stdcall  ;


TDAQmxGetAIGain= function(
                 TaskHandle : Integer ;
                 const channel : PANSIChar ;
                 var Result : Double
                 ) : Integer ; stdcall  ;

TDAQmxSetAIGain= function(
                 TaskHandle : Integer ;
                 const channel : PANSIChar ;
                 Value : Double
                 ) : Integer ; stdcall  ;

TDAQmxResetAIGain= function(
                   TaskHandle : Integer ;
                   const channel : PANSIChar
                   ) : Integer ; stdcall  ;

TDAQmxGetAIConvMaxRate= function(
                        TaskHandle : Integer ;
                        var Result : Double
                        ) : Integer ; stdcall ;

TDAQmxGetAOMax= function(
                TaskHandle : Integer ;
                const channel : PANSIChar ;
                var Result : Double
                ) : Integer ; stdcall  ;

TDAQmxSetAOMax= function(
                TaskHandle : Integer ;
                const channel : PANSIChar ;
                Value : Double
                ) : Integer ; stdcall  ;

TDAQmxResetAOMax= function(
                  TaskHandle : Integer ;
                  const channel : PANSIChar
                  ) : Integer ; stdcall  ;

TDAQmxGetAOMin= function(
                TaskHandle : Integer ;
                const channel : PANSIChar ;
                var Result : Double
                ) : Integer ; stdcall  ;

TDAQmxSetAOMin= function(
                TaskHandle : Integer ;
                const channel : PANSIChar ;
                Value : Double
                ) : Integer ; stdcall  ;

TDAQmxResetAOMin= function(
                  TaskHandle : Integer ;
                  const channel : PANSIChar
                  ) : Integer ; stdcall  ;

TDAQmxGetDevProductType= function(
                         Device : PANSIChar ;
                         var data : Array of ANSIChar ;
                         bufferSize : Cardinal ) : Integer ; stdcall  ;

TDAQmxGetAODACRngHigh= function(
                TaskHandle : Integer ;
                const channel : PANSIChar ;
                var Result : Double
                ) : Integer ; stdcall  ;

TDAQmxSetAODACRngHigh= function(
                TaskHandle : Integer ;
                const channel : PANSIChar ;
                Value : Double
                ) : Integer ; stdcall  ;

TDAQmxResetAODACRngHigh= function(
                  TaskHandle : Integer ;
                  const channel : PANSIChar
                  ) : Integer ; stdcall  ;

TDAQmxGetAODACRngLow= function(
                TaskHandle : Integer ;
                const channel : PANSIChar ;
                var Result : Double
                ) : Integer ; stdcall  ;

TDAQmxSetAODACRngLow= function(
                TaskHandle : Integer ;
                const channel : PANSIChar ;
                Value : Double
                ) : Integer ; stdcall  ;

TDAQmxResetAODACRngLow= function(
                  TaskHandle : Integer ;
                  const channel : PANSIChar
                  ) : Integer ; stdcall  ;

TDAQmxGetReadReadAllAvailSamp= function(
                 TaskHandle : Integer ;
                 var Value : Boolean
                  ) : Integer ; stdcall  ;

TDAQmxSetReadReadAllAvailSamp= function(
                 TaskHandle : Integer ;
                 Value : Boolean
                  ) : Integer ; stdcall  ;

TDAQmxGetSampClkRate = function(
                       TaskHandle : Integer ;
                       var Value : Double
                       ) : Integer ; stdcall  ;

TDAQmxSetReadOverWrite = function(
                       TaskHandle : Integer ;
                       Value : Integer
                       ) : Integer ; stdcall  ;

TDAQmxGetSysDevNames = function(
                       var NameBuf : Array of ANSIChar ;
                       BufSize : Integer
                       ) : Integer ; stdcall  ;

TDAQmxSetAIUsbXferReqCount = function(
                             TaskHandle : Integer ;
                             const channel : PANSIChar ;
                             Count : Cardinal
                              ) : Integer ; stdcall  ;

TDAQmxGetAIUsbXferReqCount = function(
                             TaskHandle : Integer ;
                             const channel : PANSIChar ;
                             Count : Cardinal
                              ) : Integer ; stdcall  ;

TDAQmxResetAIUsbXferReqCount = function(
                             TaskHandle : Integer ;
                             const channel : PANSIChar
                              ) : Integer ; stdcall  ;

TDAQmxSetAOUsbXferReqCount = function(
                             TaskHandle : Integer ;
                             const channel : PANSIChar ;
                             Count : Cardinal
                              ) : Integer ; stdcall  ;

TDAQmxGetAOUsbXferReqCount = function(
                             TaskHandle : Integer ;
                             const channel : PANSIChar ;
                             Count : Cardinal
                              ) : Integer ; stdcall  ;

TDAQmxResetAOUsbXferReqCount = function(
                             TaskHandle : Integer ;
                             const channel : PANSIChar
                              ) : Integer ; stdcall  ;



const
    MaxDACChannels = 16 ;
    DefaultTimeOut = 2.0 ;

var
    NIDAQMXLoaded : Boolean ;
    DeviceName : ANSIstring ;

    DAQmxLoadTask : TDAQmxLoadTask ;
    DAQmxCreateTask : TDAQmxCreateTask ;
    DAQmxSelfCal : TDAQmxSelfCal ;

    DAQmxGetDevAIMaxMultiChanRate : TDAQmxGetDevAIMaxMultiChanRate ;
    DAQmxGetDevAIMinRate : TDAQmxGetDevAIMinRate ;
    DAQmxGetDevAIPhysicalChans : TDAQmxGetDevAIPhysicalChans ;
    DAQmxGetDevAIVoltageRngs : TDAQmxGetDevAIVoltageRngs ;
    DAQmxGetDevAOSampClkSupported : TDAQmxGetDevAOSampClkSupported ;
    DAQmxGetDevAOMaxRate : TDAQmxGetDevAOMaxRate ;
    DAQmxGetDevAOMinRate : TDAQmxGetDevAOMinRate ;
    DAQmxGetDevDOMaxRate : TDAQmxGetDevDOMaxRate ;
    DAQmxGetDevAOPhysicalChans : TDAQmxGetDevAOPhysicalChans ;
    DAQmxGetDevAOVoltageRngs : TDAQmxGetDevAOVoltageRngs ;

    DAQmxGetAIDevScalingCoeff : TDAQmxGetAIDevScalingCoeff ;
    DAQmxAddGlobalChansToTask : TDAQmxAddGlobalChansToTask ;
    DAQmxStartTask : TDAQmxStartTask ;
    DAQmxStopTask  : TDAQmxStopTask ;
    DAQmxClearTask : TDAQmxClearTask ;
    DAQmxWaitUntilTaskDone : TDAQmxWaitUntilTaskDone ;
    DAQmxIsTaskDone : TDAQmxIsTaskDone ;
    DAQmxTaskControl : TDAQmxTaskControl ;
    DAQmxGetNthTaskChannel : TDAQmxGetNthTaskChannel ;
    DAQmxCreateAIVoltageChan : TDAQmxCreateAIVoltageChan ;
    DAQmxCreateAOVoltageChan : TDAQmxCreateAOVoltageChan ;
    DAQmxCreateDIChan : TDAQmxCreateDIChan ;
    DAQmxCreateDOChan : TDAQmxCreateDOChan ;
    DAQmxCreateCIFreqChan : TDAQmxCreateCIFreqChan ;
    DAQmxCreateCIPeriodChan : TDAQmxCreateCIPeriodChan ;
    DAQmxCreateCICountEdgesChan : TDAQmxCreateCICountEdgesChan ;
    DAQmxCreateCIPulseWidthChan : TDAQmxCreateCIPulseWidthChan ;
    DAQmxCreateCISemiPeriodChan : TDAQmxCreateCISemiPeriodChan ;
    DAQmxCreateCITwoEdgeSepChan : TDAQmxCreateCITwoEdgeSepChan ;
    DAQmxCreateCOPulseChanFreq : TDAQmxCreateCOPulseChanFreq ;
    DAQmxCreateCOPulseChanTime : TDAQmxCreateCOPulseChanTime ;
    DAQmxCreateCOPulseChanTicks : TDAQmxCreateCOPulseChanTicks ;
    DAQmxCfgSampClkTiming : TDAQmxCfgSampClkTiming ;
    DAQmxCfgHandshakingTiming : TDAQmxCfgHandshakingTiming ;
    DAQmxCfgChangeDetectionTiming : TDAQmxCfgChangeDetectionTiming ;
    DAQmxCfgImplicitTiming : TDAQmxCfgImplicitTiming ;
    DAQmxDisableStartTrig : TDAQmxDisableStartTrig ;
    DAQmxCfgDigEdgeStartTrig : TDAQmxCfgDigEdgeStartTrig ;
    DAQmxCfgAnlgEdgeStartTrig : TDAQmxCfgAnlgEdgeStartTrig ;
    DAQmxCfgAnlgWindowStartTrig : TDAQmxCfgAnlgWindowStartTrig ;
    DAQmxDisableRefTrig : TDAQmxDisableRefTrig ;
    DAQmxCfgDigEdgeRefTrig : TDAQmxCfgDigEdgeRefTrig ;
    DAQmxCfgAnlgEdgeRefTrig : TDAQmxCfgAnlgEdgeRefTrig ;
    DAQmxCfgAnlgWindowRefTrig : TDAQmxCfgAnlgWindowRefTrig ;
    DAQmxDisableAdvTrig : TDAQmxDisableAdvTrig ;
    DAQmxCfgDigEdgeAdvTrig : TDAQmxCfgDigEdgeAdvTrig ;
    DAQmxSendSoftwareTrigger : TDAQmxSendSoftwareTrigger ;
    DAQmxReadAnalogF64 : TDAQmxReadAnalogF64 ;
    DAQmxReadAnalogScalarF64 : TDAQmxReadAnalogScalarF64 ;
    DAQmxReadBinaryI16 : TDAQmxReadBinaryI16 ;
    DAQmxReadBinaryU16 : TDAQmxReadBinaryU16 ;
    DAQmxReadBinaryI32 : TDAQmxReadBinaryI32 ;
    DAQmxReadBinaryU32 : TDAQmxReadBinaryU32 ;
    DAQmxReadDigitalU8 : TDAQmxReadDigitalU8 ;
    DAQmxReadDigitalU32 : TDAQmxReadDigitalU32 ;
    DAQmxReadDigitalScalarU32 : TDAQmxReadDigitalScalarU32 ;
    DAQmxReadDigitalLines : TDAQmxReadDigitalLines ;
    DAQmxReadCounterF64 : TDAQmxReadCounterF64 ;
    DAQmxReadCounterU32 : TDAQmxReadCounterU32 ;
    DAQmxReadCounterScalarF64 : TDAQmxReadCounterScalarF64 ;
    DAQmxReadCounterScalarU32 : TDAQmxReadCounterScalarU32 ;
    DAQmxReadRaw : TDAQmxReadRaw ;
    DAQmxGetNthTaskReadChannel : TDAQmxGetNthTaskReadChannel ;
    DAQmxWriteAnalogF64 : TDAQmxWriteAnalogF64 ;
    DAQmxWriteAnalogScalarF64 : TDAQmxWriteAnalogScalarF64 ;
    DAQmxWriteBinaryI16 : TDAQmxWriteBinaryI16 ;
    DAQmxWriteBinaryU16 : TDAQmxWriteBinaryU16 ;
    DAQmxWriteDigitalU8 : TDAQmxWriteDigitalU8 ;
    DAQmxWriteDigitalU32 : TDAQmxWriteDigitalU32 ;
    DAQmxWriteDigitalScalarU32 : TDAQmxWriteDigitalScalarU32 ;
    DAQmxWriteDigitalLines : TDAQmxWriteDigitalLines ;
    DAQmxWriteRaw : TDAQmxWriteRaw ;
    DAQmxExportSignal : TDAQmxExportSignal ;
    DAQmxCfgInputBuffer : TDAQmxCfgInputBuffer ;
    DAQmxCfgOutputBuffer  : TDAQmxCfgOutputBuffer ;
    DAQmxConnectTerms : TDAQmxConnectTerms ;
    DAQmxDisconnectTerms : TDAQmxDisconnectTerms ;
    DAQmxTristateOutputTerm : TDAQmxTristateOutputTerm ;
    DAQmxResetDevice : TDAQmxResetDevice ;
    DAQmxGetErrorString : TDAQmxGetErrorString ;
    DAQmxGetExtendedErrorInfo : TDAQmxGetExtendedErrorInfo ;

    DAQmxGetAIResolutionUnits : TDAQmxGetAIResolutionUnits ;
    DAQmxGetAIResolution : TDAQmxGetAIResolution  ;
    DAQmxGetAOResolutionUnits : TDAQmxGetAOResolutionUnits ;
    DAQmxGetAOResolution : TDAQmxGetAOResolution  ;
    DAQmxGetAIRngHigh : TDAQmxGetAIRngHigh ;
    DAQmxSetAIRngHigh : TDAQmxSetAIRngHigh ;
    DAQmxResetAIRngHigh : TDAQmxResetAIRngHigh ;
    DAQmxGetAIRngLow : TDAQmxGetAIRngLow ;
    DAQmxSetAIRngLow : TDAQmxSetAIRngLow ;
    DAQmxResetAIRngLow : TDAQmxResetAIRngLow ;

    DAQmxGetAIMax : TDAQmxGetAIMax ;
    DAQmxSetAIMax : TDAQmxSetAIMax ;
    DAQmxResetAIMax : TDAQmxResetAIMax ;
    DAQmxGetAIMin : TDAQmxGetAIMin ;
    DAQmxSetAIMin : TDAQmxSetAIMin ;
    DAQmxResetAIMin : TDAQmxResetAIMin ;

    DAQmxGetAIGain : TDAQmxGetAIGain ;
    DAQmxSetAIGain : TDAQmxSetAIGain ;
    DAQmxResetAIGain : TDAQmxResetAIGain ;
    DAQmxGetAOMax : TDAQmxGetAOMax ;
    DAQmxGetAIConvMaxRate : TDAQmxGetAIConvMaxRate ;
    DAQmxSetAOMax : TDAQmxSetAOMax ;
    DAQmxResetAOMax : TDAQmxResetAOMax ;
    DAQmxGetAOMin : TDAQmxGetAOMin ;
    DAQmxSetAOMin : TDAQmxSetAOMin ;
    DAQmxResetAOMin : TDAQmxResetAOMin ;
    DAQmxGetAODACRngHigh : TDAQmxGetAODACRngHigh ;
    DAQmxSetAODACRngHigh : TDAQmxSetAODACRngHigh ;
    DAQmxResetAODACRngHigh : TDAQmxResetAODACRngHigh ;
    DAQmxGetAODACRngLow : TDAQmxGetAODACRngLow ;
    DAQmxSetAODACRngLow : TDAQmxSetAODACRngLow ;
    DAQmxResetAODACRngLow : TDAQmxResetAODACRngLow ;

    DAQmxGetReadReadAllAvailSamp : TDAQmxGetReadReadAllAvailSamp ;
    DAQmxSetReadReadAllAvailSamp : TDAQmxSetReadReadAllAvailSamp ;

    DAQmxGetDevProductType : TDAQmxGetDevProductType ;
    DAQmxGetSampClkRate : TDAQmxGetSampClkRate ;
    DAQmxSetReadOverWrite : TDAQmxSetReadOverWrite ;
    DAQmxGetSysDevNames : TDAQmxGetSysDevNames ;

    DAQmxSetAIUsbXferReqCount : TDAQmxSetAIUsbXferReqCount ;
    DAQmxGetAIUsbXferReqCount : TDAQmxGetAIUsbXferReqCount ;
    DAQmxResetAIUsbXferReqCount : TDAQmxResetAIUsbXferReqCount ;

    DAQmxSetAOUsbXferReqCount : TDAQmxSetAOUsbXferReqCount ;
    DAQmxGetAOUsbXferReqCount : TDAQmxGetAOUsbXferReqCount ;
    DAQmxResetAOUsbXferReqCount : TDAQmxResetAOUsbXferReqCount ;

    LibraryLoaded : Boolean ;
    ADCActive : Boolean ;     { A/D sampling inn progress flag }
    DACActive : Boolean ;     { D/A output in progress flag }
    DigActive : Boolean ;
    DACDigActive : Boolean ;          // TRUE = Combined DAC/digital output active
    ADCInputMode : Integer ;          // A/D (Differential/ SingleEnded) input mode
    ADCSamplingIntervalInUse : Double ; // Current A/D sampling interval in use
    DACUpdateIntervalInUse : Double ;   // Curent D/A update interval in use

    FPUExceptionMask : Set of TFPUException ;

implementation

uses seslabio ;

var
    LibraryHnd : THandle ;
    FBoardModel : String ;

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
//    FADCScaleFactors : Array[0..10] of Double ;
    FADCCircularBuffer : Boolean ;
    FADCNumSamplesAcquired : Integer ;
    FValidADCInputMode : Integer ;

    PulseTaskHandle : Integer ;

    BoardInitialised : Boolean ;

    DIGTaskHandle : Integer ;
    FDigClockSupported : LongBool ; // TRUE = Digital output clock controlled
    FNoTriggerOnSampleClock : LongBool ; // TRUE = Cannot trigger AI sampling from AO clock
    //InBuf : PIntArray ;
    DBuf : PDoubleArray ;

    FDigMinUpdateInterval : Double ;
    FDigMaxUpdateInterval : Double ;



function NIMX_IsLabInterfaceAvailable : boolean ;
{ ------------------------------------------------------------
  Check to see if a lab. interface library is available
  ------------------------------------------------------------}
begin
     Result := NIMX_InitialiseBoard ;
     end ;


function NIMX_DeviceExists( DevName : ANSIString ) : Boolean ;
// -------------------------------
// Return TRUE if device available
// -------------------------------
var
    Err : Integer ;
begin

    Result := False ;
    if not LibraryLoaded then NIMX_LoadLibrary ;
    if not LibraryLoaded then Exit ;

    // Disable floating point exceptions
    NIMX_DisableFPUExceptions ;

    Err := DAQmxResetDevice ( PANSIChar(DevName) ) ;

    // Enable floating point exceptions
    NIMX_EnableFPUExceptions ;

    if Err = 0 then Result := True

    end ;


procedure NIMX_GetDeviceList(
          var DeviceList : TStringList
          ) ;
// ----------------------------
// Get list of available boards
// ----------------------------
var
    Done : Boolean ;
    i : Integer ;
    CBuf : Array[0..500] of ANSIChar ;
    DeviceName : ANSIString ;
begin

   DeviceList.Clear ;

   if not LibraryLoaded then NIMX_LoadLibrary ;
   if not LibraryLoaded then Exit ;

   // Get list of devices available
   NIMX_CheckError(DAQmxGetSysDevNames( CBuf, High(CBuf)+1 )) ;

   Done := False ;
   DeviceName := '' ;
   i := 0 ;
   repeat
        if (CBuf[i] <> ',') and (CBuf[i] <> #0) then begin
           if CBuf[i] <> ' ' then
              DeviceName := DeviceName + CBuf[i] ;
           end
        else begin
           if DeviceName <> '' then DeviceList.Add(DeviceName) ;
           DeviceName := '' ;
           if CBuf[i] = #0 then Done := True ;
           end ;
        Inc(i) ;
        if i >= High(CBuf) then Done := True ;
        until Done ;

    end ;

function NIMX_InitialiseBoard : Boolean ;
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
    ChannelName : ANSIString ;
    CBuf : Array[0..99] of ANSIChar ;
    AORanges : Array[0..MaxRanges] of Double ;
begin

    Result := False ;
    if BoardInitialised then Exit ;

    // Disable floating point exceptions
    NIMX_DisableFPUExceptions ;

    { Clear A/D and D/A in progress flags }
    ADCActive := False ;
    DACActive := False ;
    DigActive := False ;
    DACDigActive := False ;
    Result := False ;

    if not LibraryLoaded then NIMX_LoadLibrary ;
    if not LibraryLoaded then Exit ;

//    Err := DAQmxResetDevice ( PANSIChar(DeviceName) ) ;
//    if Err <> 0 then begin
//       ShowMessage('Unable to detect device') ;
//       Exit ;
//       end ;

    ADCSamplingIntervalInUse := -1.0 ;
    DACUpdateIntervalInUse := -1.0 ;

    // Get interface card model
    NIMX_CheckError(DAQmxGetDevProductType( PANSIChar(DeviceName), CBuf, High(CBuf) )) ;
    FBoardModel := '' ;
    i := 0 ;
    While (CBuf[i] <> #0) and (i < High(CBuf)) do begin
        FBoardModel := FBoardModel + CBuf[i] ;
        Inc(i) ;
        end ;

    // Minimum ADC, DAC and dig. update interval

    // Min./max. sampling intervals
    if (@DAQmxGetDevAIMaxMultiChanRate <> Nil) and
       (@DAQmxGetDevAIMinRate <> nil) and
       (@DAQmxGetDevAOSampClkSupported <> Nil) and
       (@DAQmxGetDevAOMaxRate <> Nil) and
       (@DAQmxGetDevDOMaxRate <> Nil) then begin

       // Timing properties available

       // Determine if DAC output can be clock controlled and DAC min update interval
       Err := DAQmxGetDevAOSampClkSupported( PANSIChar(DeviceName), FDACClockSupported ) ;
       if Err <> 0 then FDACClockSupported := False ;
       if FDACClockSupported then begin
          NIMX_CheckError( DAQmxGetDevAOMaxRate( PANSIChar(DeviceName), DValue )) ;
          FDACMinUpdateInterval := 1.0/DValue ;
          end
       else FDACMinUpdateInterval := 1E-3 ;

       // Determine min/max sampling intervals
       NIMX_CheckError( DAQmxGetDevAIMaxMultiChanRate( PANSIChar(DeviceName), DValue )) ;
       FADCMinSamplingInterval := 1.0/DValue ;
       NIMX_CheckError( DAQmxGetDevAIMinRate( PANSIChar(DeviceName), DValue )) ;
       FADCMaxSamplingInterval := 1.0 /DValue ;

       if DAQmxGetDevDOMaxRate( PANSIChar(DeviceName), DValue ) = 0 then begin
          FDigMinUpdateInterval := 1.0/DValue ;
          FDigClockSupported := True ;
          end
       else begin
          FDigClockSupported := False ;
          FDigMinUpdateInterval := FDACMinUpdateInterval ;
          end ;

       // Limitations associated with USB-600X devices
       // Determine if analog output clock can be used as a trigger signal
       if ANSIContainsText(FBoardModel,'6000') or
          ANSIContainsText(FBoardModel,'6001') or
          ANSIContainsText(FBoardModel,'6002') or
          ANSIContainsText(FBoardModel,'6003') or
          ANSIContainsText(FBoardModel,'6004') or
          ANSIContainsText(FBoardModel,'6005') then begin
          FNoTriggerOnSampleClock := True ;
          FDACMinUpdateInterval := 1E-3 ;
          end
       else FNoTriggerOnSampleClock := False ;

       end
    else begin
       // Timing properties not available. Based limits on board type

       FDACClockSupported := True ;
       FADCMaxSamplingInterval := 100.0 ;
       if ANSIContainsText(FBoardModel,'6014') or
          ANSIContainsText(FBoardModel,'6024') or
          ANSIContainsText(FBoardModel,'6025') or
          ANSIContainsText(FBoardModel,'6036') then begin
          // E-Series boards with interrupt-driven DAC update
          FADCMinSamplingInterval := 5E-6 ;
          FDACMinUpdateInterval := 1E-3 ;
          FDigMinUpdateInterval := 1E-3 ;
          FDigClockSupported := False ;
          end
       else if ANSIContainsText(FBoardModel,'6052') then begin
          // 333 E/M series models
          FADCMinSamplingInterval := 1.0/3.33E5 ;
          FDACMinUpdateInterval := 1.0/3.33E5 ;
          FDigMinUpdateInterval := 1.0/3.33E5 ;
          FDigClockSupported := False ;
          end
       else if ANSIContainsText(FBoardModel,'6040') then begin
          // 250 KHz E series model
          FADCMinSamplingInterval := 1.0/2.5E5 ;
          FDACMinUpdateInterval := 1.0/1.0E6 ;
          FDigMinUpdateInterval := 1.0/1.0E6 ;
          FDigClockSupported := False ;
          end
       else if ANSIContainsText(FBoardModel,'625') then begin
          // 1.25 MHz M series models
          FADCMinSamplingInterval := 1.0 / 1.256 ;
          FDACMinUpdateInterval := 1.0 / 2.86E6 ;
          FDigMinUpdateInterval := 1.0 / 2.86E6 ;
          FDigClockSupported := True ;
          end
       else if ANSIContainsText(FBoardModel,'622')then begin
          // 1.25 MHz M series models
          FADCMinSamplingInterval := 1.0 / 2.5E5 ;
          FDACMinUpdateInterval := 1.0 / 8.33E5 ;
          FDigMinUpdateInterval := 1.0 / 8.33E5 ;
          FDigClockSupported := True ;
          end
       else if ANSIContainsText(FBoardModel,'61') then begin
          // S series PCI-6110 or PCI-6111
          if ANSIContainsText(FBoardModel,'6115') then FADCMinSamplingInterval := 1E-7
          else if ANSIContainsText(FBoardModel,'6120') then FADCMinSamplingInterval := 1E-6
          else FADCMinSamplingInterval := 2E-7 ;
          FDACMinUpdateInterval := 5E-7 ;
          FDigMinUpdateInterval := 1.25E-7 ;
          FDigClockSupported := False ;
          end
       else if ANSIContainsText(FBoardModel,'6008') then begin
          FADCMinSamplingInterval := 1E-1 ;
          FDACClockSupported := False ;
          FDigClockSupported := False ;
          end
       else if ANSIContainsText(FBoardModel,'6009') then begin
          FADCMinSamplingInterval := 1.0/48000 ;
          FDACClockSupported := False ;
          FDigClockSupported := False ;
          end
       else begin
          // Other M and E Series boards
          FADCMinSamplingInterval := 5E-6 ;
          FDACMinUpdateInterval := 5E-6 ;
          FDigMinUpdateInterval := 5E-6 ;
          end ;
       end ;

    FDigMaxUpdateInterval := 1000.0 ;

    // 03.04.23 Digital clock support temporarily disabled for 6353 devices to determine
    // if there is a programming incompatibility with 32 bit Port0
    if ANSIContainsText(FBoardModel,'6353') then FDigClockSupported := False ;

    // Calibrate device
    //NIMX_CheckError( DAQmxSelfCal( PANSIChar(DeviceName) )) ;


    // Get number of D/A channels and properties
    // -----------------------------------------

    // Default is +/-10V
    FDACMinVolts := -10.0 ;
    FDACMaxVolts := 10.0 ;
    if (@DAQmxGetDevAOPhysicalChans <> Nil) and
       (@DAQmxGetDevAOVoltageRngs <> Nil) then begin
       // Get data from device (if possible)
       for i := 0 to High(AORanges) do AORanges[i] := 0.0 ;
       DAQmxGetDevAOVoltageRngs( PANSIChar(DeviceName), AORanges, High(AORanges) ) ;
       FDACMinVolts := 0.0 ;
       FDACMaxVolts := 0.0 ;
       for i := 0 to High(AORanges) do begin
           FDACMinVolts := Min(AORanges[i],FDACMinVolts) ;
           FDACMaxVolts := Max(AORanges[i],FDACMaxVolts) ;
           end ;
       end ;
    if FDACMaxVolts = 0 then FDACMaxVolts := 10.0 ;

    // Create D/A task
    FDACNumChannels := 0 ;
    FDACResolution := 16 ;
    FDACMaxValue := 32767 ;
    FDACMinValue := -FDACMaxValue - 1 ;

    Err := 0 ;
    While (Err = 0) do begin

        NIMX_CheckError( DAQmxCreateTask( '', Task ) ) ;
        ChannelName := format('%s/ao%d',[DeviceName,FDACNumChannels]) ;
        Err := DAQmxCreateAOVoltageChan( Task,
                                      PANSIChar(ChannelName),
                                      nil ,
                                      FDACMinVolts,
                                      FDACMaxVolts,
                                      DAQmx_Val_Volts,
                                      nil);
        if Err = 0 then begin
           // D/A output range
           NIMX_CheckError(DAQmxGetAODACRngHigh( Task,
                                                 PANSIChar(ChannelName),
                                                 FDACMaxVolts ));

           // Get D/A converter resolution
           NIMX_CheckError( DAQmxGetAOResolution( Task,
                                                  PANSIChar(ChannelName),
                                                  DValue)) ;
           FDACResolution := Round(DValue) ;
           FDACMaxValue := Round(Power(2.0,DValue-1.0)) - 1 ;
           FDACMaxValue := Min( FDACMaxValue, 32767 ) ;       // Keep to 16 bits or less
           FDACMinValue := -FDACMaxValue - 1 ;
           Inc(FDACNumChannels) ;
           end ;

        NIMX_CheckError( DAQmxClearTask( Task ) ) ;
        end ;


    // Get max. number of A/D channels and properties
    // ----------------------------------------------
    FADCNumChannels := 0 ;
    FADCResolution := 16 ;
    FADCMaxValue := 32767 ;
    FADCMinValue := -FADCMaxValue - 1 ;

    // Enable floating point exceptions
    NIMX_EnableFPUExceptions ;

    // Create input buffer
    GetMem(DBuf,MaxADCSamples*8) ;

    BoardInitialised := True ;
    Result := True ;

   end ;


function NIMX_CheckMaxADCChannels(
          ADCInputMode : Integer
          ) : Integer ;
// -------------------------------------------------------------
// Return the number of A/D channels supported in the input mode
// -------------------------------------------------------------
var
    Err,ADCNumChannels : Integer ;
    DValue : Double ;
    Task : Integer ;
    ChannelName : ANSIString ;
    ChannelList : Array[0..10000] of ANSICHar ;
    NumChannels : Integer ;
begin

    // Create A/D task
    ADCNumChannels := 0 ;
    Result := 0 ;

    // Determine number of available AI channels
    NIMX_CheckError( DAQmxGetDevAIPhysicalChans( PANSIChar(DeviceName), ChannelList, High(ChannelList)) ) ;
    NumChannels := 0 ;
    while ContainsText(String(ChannelList),format('ai%d',[NumChannels])) do Inc(NumChannels) ;
//    CheckError( DAQmxGetDevAISimultaneousSamplingSupported( PANSIChar(DeviceName[DeviceNum]),SimultaneousSampling));
    if ADCInputMode = DAQmx_Val_Diff then NumChannels := NumChannels div 2 ;

    Result := NumChannels ;

    Err := 0 ;
    While Err = 0 do begin

        // Note. +/- 5V range used to be compatible with
        // interfaces (like PCI-6010) which have +/-5V max input range
        NIMX_CheckError( DAQmxCreateTask( '', Task ) ) ;
        ChannelName := format('%s/ai%d',[DeviceName,ADCNumChannels]) ;
        Err := DAQmxCreateAIVoltageChan( Task,
                                      PANSIChar(ChannelName),
                                      nil ,
                                      ADCInputMode,
                                      -5.0,
                                      5.0,
                                      DAQmx_Val_Volts,
                                      nil);
        if Err = 0 then begin

           // A/D output range
           NIMX_CheckError( DAQmxGetAIRngHigh( Task,
                            PANSIChar(ChannelName),
                            FADCMaxVolts ));

           // Get D/A converter resolution
           NIMX_CheckError( DAQmxGetAIResolution( Task,
                            PANSIChar(ChannelName),
                            DValue)) ;

           // Channel scaling factors
  {         NIMX_CheckError( DAQmxGetAIDevScalingCoeff( Task,
                            PANSIChar(ChannelName),
                            FADCScaleFactors,
                            High(FADCScaleFactors)+1 )) ;}

           FADCResolution := Round(DValue) ;
           FADCMaxValue := Round(Power(2.0,DValue-1.0)) - 1 ;
           FADCMaxValue := Min( FADCMaxValue, 32767 ) ;       // Keep to 16 bits or less
           FADCMinValue := -FADCMaxValue - 1 ;
           FValidADCInputMode := ADCInputMode ;

           Inc(ADCNumChannels) ;

           end ;

        NIMX_CheckError( DAQmxClearTask( Task ) ) ;

        Result := ADCNumChannels ;

        end ;

    if ADCNumChannels > FADCNumChannels then FADCNumChannels := ADCNumChannels ;

    end ;


procedure NIMX_LoadLibrary  ;
{ --------------------------------------
  Load nimcaiu.dll functions into memory
  --------------------------------------}
begin

     { Load library }
     LibraryHnd := LoadLibrary( PChar('nicaiu.dll') ) ;
     if LibraryHnd <> 0 then begin
       { Get addresses of procedure NIMX_s used }
        @DAQmxLoadTask := NIMX_LoadProcedure( LibraryHnd, 'DAQmxLoadTask' ) ;
        @DAQmxCreateTask := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateTask'  ) ;
        @DAQmxSelfCal := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSelfCal'  ) ;

        @DAQmxGetDevAIMaxMultiChanRate := GetProcAddress(LibraryHnd,'DAQmxGetDevAIMaxMultiChanRate') ;
        @DAQmxGetDevAIMinRate := GetProcAddress(LibraryHnd,'DAQmxGetDevAIMinRate'  ) ;
        @DAQmxGetDevAIPhysicalChans := GetProcAddress(LibraryHnd,'DAQmxGetDevAIPhysicalChans'  ) ;
        @DAQmxGetDevAOVoltageRngs := GetProcAddress(LibraryHnd,'DAQmxGetDevAOVoltageRngs'  ) ;
        @DAQmxGetDevAOSampClkSupported := GetProcAddress(LibraryHnd,'DAQmxGetDevAOSampClkSupported'  ) ;
        @DAQmxGetDevAOMaxRate := GetProcAddress(LibraryHnd,'DAQmxGetDevAOMaxRate'  ) ;
        @DAQmxGetDevAOMinRate := GetProcAddress(LibraryHnd,'DAQmxGetDevAOMinRate'  ) ;
        @DAQmxGetDevDOMaxRate := GetProcAddress(LibraryHnd,'DAQmxGetDevDOMaxRate'  ) ;
        @DAQmxGetDevAOPhysicalChans := GetProcAddress(LibraryHnd,'DAQmxGetDevAOPhysicalChans'  ) ;
        @DAQmxGetDevAOVoltageRngs := GetProcAddress(LibraryHnd,'DAQmxGetDevAOVoltageRngs'  ) ;

        @DAQmxGetAIDevScalingCoeff := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIDevScalingCoeff'  ) ;
        @DAQmxAddGlobalChansToTask := NIMX_LoadProcedure( LibraryHnd, 'DAQmxAddGlobalChansToTask' ) ;
        @DAQmxStartTask := NIMX_LoadProcedure( LibraryHnd, 'DAQmxStartTask' ) ;
        @DAQmxStopTask := NIMX_LoadProcedure( LibraryHnd, 'DAQmxStopTask'  ) ;
        @DAQmxClearTask := NIMX_LoadProcedure( LibraryHnd, 'DAQmxClearTask' ) ;
        @DAQmxWaitUntilTaskDone  := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWaitUntilTaskDone' ) ;
        @DAQmxIsTaskDone := NIMX_LoadProcedure( LibraryHnd, 'DAQmxIsTaskDone' ) ;
        @DAQmxTaskControl := NIMX_LoadProcedure( LibraryHnd, 'DAQmxTaskControl' ) ;
        @DAQmxGetNthTaskChannel := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetNthTaskChannel' ) ;
        @DAQmxCreateAIVoltageChan := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateAIVoltageChan' ) ;
        @DAQmxCreateAOVoltageChan  := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateAOVoltageChan' ) ;
        @DAQmxCreateDIChan := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateDIChan' ) ;
        @DAQmxCreateDOChan := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateDOChan' ) ;
        @DAQmxCreateCIFreqChan := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateCIFreqChan' ) ;
        @DAQmxCreateCIPeriodChan := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateCIPeriodChan' ) ;
        @DAQmxCreateCICountEdgesChan := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateCICountEdgesChan' ) ;
        @DAQmxCreateCIPulseWidthChan := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateCIPulseWidthChan' ) ;
        @DAQmxCreateCISemiPeriodChan := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateCISemiPeriodChan' ) ;
        @DAQmxCreateCITwoEdgeSepChan := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateCITwoEdgeSepChan' ) ;
        @DAQmxCreateCOPulseChanFreq := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateCOPulseChanFreq' ) ;
        @DAQmxCreateCOPulseChanTime := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateCOPulseChanTime' ) ;
        @DAQmxCreateCOPulseChanTicks := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCreateCOPulseChanTicks' ) ;
        @DAQmxCfgSampClkTiming := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgSampClkTiming' ) ;
        @DAQmxCfgSampClkTiming := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgSampClkTiming' ) ;
        @DAQmxCfgHandshakingTiming := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgHandshakingTiming' ) ;
        @DAQmxCfgChangeDetectionTiming := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgChangeDetectionTiming' ) ;
        @DAQmxCfgImplicitTiming := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgImplicitTiming' ) ;
        @DAQmxDisableStartTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxDisableStartTrig' ) ;
        @DAQmxCfgDigEdgeStartTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgDigEdgeStartTrig' ) ;
        @DAQmxCfgAnlgEdgeStartTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgAnlgEdgeStartTrig' ) ;
        @DAQmxCfgAnlgWindowStartTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgAnlgWindowStartTrig' ) ;
        @DAQmxDisableRefTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxDisableRefTrig' ) ;
        @DAQmxCfgDigEdgeRefTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgDigEdgeRefTrig' ) ;
        @DAQmxCfgAnlgEdgeRefTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgAnlgEdgeRefTrig' ) ;
        @DAQmxCfgAnlgWindowRefTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgAnlgWindowRefTrig' ) ;
        @DAQmxDisableAdvTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxDisableAdvTrig' ) ;
        @DAQmxCfgDigEdgeAdvTrig := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgDigEdgeAdvTrig' ) ;
        @DAQmxSendSoftwareTrigger := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSendSoftwareTrigger' ) ;
        @DAQmxReadAnalogF64 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadAnalogF64' ) ;
        @DAQmxReadAnalogScalarF64 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadAnalogScalarF64' ) ;
        @DAQmxReadBinaryI16 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadBinaryI16'  ) ;
        @DAQmxReadBinaryU16 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadBinaryU16' ) ;
        @DAQmxReadBinaryI32 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadBinaryI32'  ) ;
        @DAQmxReadBinaryU32 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadBinaryU32' ) ;
        @DAQmxReadDigitalU8 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadDigitalU8' ) ;
        @DAQmxReadDigitalU32 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadDigitalU32' ) ;
        @DAQmxReadDigitalScalarU32 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadDigitalScalarU32' ) ;
        @DAQmxReadDigitalScalarU32 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadDigitalScalarU32' ) ;
        @DAQmxReadDigitalLines := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadDigitalLines' ) ;
        @DAQmxReadCounterF64 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadCounterF64' ) ;
        @DAQmxReadCounterU32 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadCounterU32' ) ;
        @DAQmxReadCounterScalarF64 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadCounterScalarF64' ) ;
        @DAQmxReadCounterScalarU32 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadCounterScalarU32' ) ;
        @DAQmxReadRaw := NIMX_LoadProcedure( LibraryHnd, 'DAQmxReadRaw' ) ;
        @DAQmxGetNthTaskReadChannel := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetNthTaskReadChannel' ) ;
        @DAQmxWriteAnalogF64 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteAnalogF64' ) ;
        @DAQmxWriteAnalogScalarF64 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteAnalogScalarF64' ) ;
        @DAQmxWriteBinaryI16 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteBinaryI16' ) ;
        @DAQmxWriteBinaryU16 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteBinaryU16' ) ;
        @DAQmxWriteDigitalU8 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteDigitalU8' ) ;
        @DAQmxWriteDigitalU32 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteDigitalU32' ) ;
        @DAQmxWriteDigitalScalarU32 := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteDigitalScalarU32' ) ;
        @DAQmxWriteDigitalLines := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteDigitalLines' ) ;
        @DAQmxWriteDigitalLines := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteDigitalLines' ) ;
        @DAQmxWriteRaw := NIMX_LoadProcedure( LibraryHnd, 'DAQmxWriteRaw' ) ;
        @DAQmxExportSignal := NIMX_LoadProcedure( LibraryHnd, 'DAQmxExportSignal' ) ;
        @DAQmxCfgInputBuffer := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgInputBuffer' ) ;
        @DAQmxCfgOutputBuffer := NIMX_LoadProcedure( LibraryHnd, 'DAQmxCfgOutputBuffer' ) ;
        @DAQmxConnectTerms := NIMX_LoadProcedure( LibraryHnd, 'DAQmxConnectTerms' ) ;
        @DAQmxDisconnectTerms := NIMX_LoadProcedure( LibraryHnd, 'DAQmxDisconnectTerms' ) ;
        @DAQmxTristateOutputTerm := NIMX_LoadProcedure( LibraryHnd, 'DAQmxTristateOutputTerm' ) ;
        @DAQmxResetDevice := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetDevice' ) ;
        @DAQmxGetErrorString := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetErrorString' ) ;
        @DAQmxGetExtendedErrorInfo := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetExtendedErrorInfo' ) ;

        @DAQmxGetAIResolutionUnits := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIResolutionUnits' ) ;
        @DAQmxGetAIResolution := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIResolution' ) ;
        @DAQmxGetAOResolutionUnits := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAOResolutionUnits' ) ;
        @DAQmxGetAOResolution := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAOResolution' ) ;
        @DAQmxGetAIRngHigh := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIRngHigh' ) ;
        @DAQmxSetAIRngHigh := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAIRngHigh' ) ;
        @DAQmxResetAIRngHigh := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAIRngHigh' ) ;
        @DAQmxGetAIRngLow := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIRngLow' ) ;
        @DAQmxSetAIRngLow := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAIRngLow' ) ;
        @DAQmxResetAIRngLow := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAIRngLow' ) ;

        @DAQmxGetAIMax := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIMax' ) ;
        @DAQmxSetAIMax := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAIMax' ) ;
        @DAQmxResetAIMax := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAIMax' ) ;
        @DAQmxGetAIMin := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIMin' ) ;
        @DAQmxSetAIMin := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAIMin' ) ;
        @DAQmxResetAIMin := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAIMin' ) ;

        @DAQmxGetAIGain := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIGain' ) ;
        @DAQmxSetAIGain := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAIGain' ) ;
        @DAQmxResetAIGain := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAIGain' ) ;
        @DAQmxGetAIConvMaxRate := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIConvMaxRate' ) ;

        @DAQmxGetAOMax := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAOMax' ) ;
        @DAQmxSetAOMax := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAOMax' ) ;
        @DAQmxResetAOMax := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAOMax' ) ;
        @DAQmxGetAOMin := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAOMin' ) ;
        @DAQmxSetAOMin := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAOMin' ) ;
        @DAQmxResetAOMin := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAOMin' ) ;
        @DAQmxGetAODACRngHigh := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAODACRngHigh' ) ;
        @DAQmxSetAODACRngHigh := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAODACRngHigh' ) ;
        @DAQmxResetAODACRngHigh := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAODACRngHigh' ) ;
        @DAQmxGetAODACRngLow := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAODACRngLow' ) ;
        @DAQmxSetAODACRngLow := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAODACRngLow' ) ;
        @DAQmxResetAODACRngLow := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAODACRngLow' ) ;

        @DAQmxGetReadReadAllAvailSamp := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetReadReadAllAvailSamp' ) ;
        @DAQmxSetReadReadAllAvailSamp := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetReadReadAllAvailSamp' ) ;

        @DAQmxGetDevProductType := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetDevProductType' ) ;
        @DAQmxGetSampClkRate := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetSampClkRate' ) ;
        @DAQmxSetReadOverWrite := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetReadOverWrite' ) ;
        @DAQmxGetSysDevNames := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetSysDevNames' ) ;
        @DAQmxSetAIUsbXferReqCount := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAIUsbXferReqCount' ) ;
        @DAQmxGetAIUsbXferReqCount := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAIUsbXferReqCount' ) ;
        @DAQmxResetAIUsbXferReqCount := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAIUsbXferReqCount' ) ;
        @DAQmxSetAOUsbXferReqCount := NIMX_LoadProcedure( LibraryHnd, 'DAQmxSetAOUsbXferReqCount' ) ;
        @DAQmxGetAOUsbXferReqCount := NIMX_LoadProcedure( LibraryHnd, 'DAQmxGetAOUsbXferReqCount' ) ;
        @DAQmxResetAOUsbXferReqCount := NIMX_LoadProcedure( LibraryHnd, 'DAQmxResetAOUsbXferReqCount' ) ;

        LibraryLoaded := True ;
        end
     else begin
          //MessageDlg( 'nicaiu.dll library not found', mtWarning, [mbOK], 0 ) ;
          LibraryLoaded := False ;
          end ;

     end ;


function  NIMX_LoadProcedure(
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

procedure  NIMX_CheckError( Err : Integer ) ;
var
   ErrString : Array[0..255] of ANSIChar ;
begin
     if Err = 0 then Exit ;
     DAQmxGetErrorString( Err, ErrString, 255 ) ;
     ShowMessage( String(ErrString) ) ;
     end ;


procedure NIMX_DisableFPUExceptions ;
// ----------------------
// Disable FPU exceptions
// ----------------------
var
    FPUNoExceptions : Set of TFPUException ;
begin

     FPUExceptionMask := GetExceptionMask ;
     Include(FPUNoExceptions, exInvalidOp );
     Include(FPUNoExceptions, exDenormalized );
     Include(FPUNoExceptions, exZeroDivide );
     Include(FPUNoExceptions, exOverflow );
     Include(FPUNoExceptions, exUnderflow );
     Include(FPUNoExceptions, exPrecision );
     SetExceptionMask( FPUNoExceptions ) ;

     end ;


procedure NIMX_EnableFPUExceptions ;
// ----------------------
// Disable FPU exceptions
// ----------------------
begin
     SetExceptionMask( FPUExceptionMask ) ;
     end ;


function  NIMX_GetLabInterfaceInfo(
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
    NIMX_GetDeviceList( DeviceList ) ;
    if DeviceList.Count < 1 then begin
       ShowMessage('No National Instruments interface cards detected!') ;
       exit ;
       end ;

    // Check selected device
    DeviceNumber := Min(Max(1,DeviceNumber),DeviceList.Count) ;
    DeviceName := DeviceList.Strings[DeviceNumber-1] ;
    if not NIMX_DeviceExists(DeviceName) then begin
       ShowMessage(format('Unable to detect device %s',[DeviceName])) ;
       exit ;
       end ;

    if not BoardInitialised then NIMX_InitialiseBoard ;
    if not BoardInitialised then Exit ;

    NIMX_DisableFPUExceptions ;

    // set A/D input mode and determine no. channels
    ADCModeCode := NIMX_GetADCInputModeCode( ADCInputMode ) ;
    ADCMaxChannels := NIMX_CheckMaxADCChannels( ADCModeCode ) ;

    // If mode not supported, select another
    if ADCMaxChannels <= 0 then begin
       ADCInputModes[0] := imDifferential ;
       ADCInputModes[1] := imSingleEnded ;
       ADCInputModes[2] := imSingleEndedRSE ;
       i := 0 ;
       while (ADCMaxChannels <= 0) and (i <= High(ADCInputModes)) do begin
          ADCInputMode := ADCInputModes[i] ;
          ADCModeCode := NIMX_GetADCInputModeCode( ADCInputMode ) ;
          ADCMaxChannels := NIMX_CheckMaxADCChannels( ADCModeCode ) ;
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

    // A/D voltage range
    NumADCVoltageRanges := 0 ;
    for i := 0 to NumVRanges-1 do begin

        NIMX_CheckError( DAQmxCreateTask( '', ADCTask ) ) ;

        ChannelName := DeviceName + '/ai0' ;
        Err := DAQmxCreateAIVoltageChan( ADCTask,
                                         PANSIChar(ChannelName),
                                         nil ,
                                         ADCModeCode,
                                         -0.9*VRanges[i],
                                         0.9*VRanges[i],
                                         DAQmx_Val_Volts,
                                         nil);

        if Err = 0 then begin
          Err := DAQmxGetAIMax( ADCTask, PANSIChar(ChannelName), DValue );
          if (Err = 0) and (Abs((DValue - VRanges[i])/VRanges[i]) < 0.1) then begin
             ADCVoltageRanges[NumADCVoltageRanges] := DValue ;
             if NumADCVoltageRanges <= High(ADCVoltageRanges) then Inc(NumADCVoltageRanges) ;
             end ;
          end ;
        NIMX_CheckError( DAQmxClearTask( ADCTask ) ) ;
        end ;

    if NumADCVoltageRanges <= 0 then begin
       ADCVoltageRanges[0] := 10.0 ;
       NumADCVoltageRanges := 1 ;
       end ;

    FADCMaxVolts := ADCVoltageRanges[0] ;

    NIMX_EnableFPUExceptions ;

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


procedure NIMX_GetChannelOffsets(
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


procedure NIMX_CheckADCSamplingInterval(
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

     if not BoardInitialised then NIMX_InitialiseBoard ;
     if not BoardInitialised then Exit ;

     if ADCActive then begin
        SamplingInterval := ADCSamplingIntervalInUse ;
        Exit ;
        end ;

     NIMX_DisableFPUExceptions ;

     // Create A/D task
     NIMX_CheckError( DAQmxCreateTask( '', ADCTaskHandle ) ) ;

     // Select A/D input channels
     ChannelList := format( DeviceName + '/AI0:%d', [NumADCChannels-1] ) ;

     ADCModeCode := NIMX_GetADCInputModeCode( ADCInputMode ) ;

     NIMX_CheckError( DAQmxCreateAIVoltageChan( ADCTaskHandle,
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
        NIMX_CheckError(Err);
        if Err <> 0 then break ;

        // Read rate back from board
        Err := DAQmxGetSampClkRate( ADCTaskHandle, ActualSamplingRate ) ;
        if Err <> 0 then SamplingRate := SamplingRate*0.75 ;
        Until Err = 0 ;

     // Return actual sampling interval
//     outputdebugstring(pchar(format('Sampling Rate: Set %.4g Actual %.4g', [SamplingInterval, (1.0 / ActualSamplingRate)])));
     SamplingInterval := 1.0 / ActualSamplingRate ;

     // Clear task
     NIMX_CheckError( DAQmxClearTask(ADCTaskHandle)) ;

     NIMX_EnableFPUExceptions ;

     end ;


function NIMX_ADCToMemory(
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
begin
     Result := False ;
     if not BoardInitialised then NIMX_InitialiseBoard ;
     if not BoardInitialised then Exit ;
     if FADCNumChannels <= 0 then Exit ;

     NIMX_DisableFPUExceptions ;

     // Stop running A/D task
     if ADCActive then
        begin
        NIMX_CheckError( DAQmxClearTask(ADCTaskHandle)) ;
        ADCActive := False ;
        end ;

     // Create A/D task
     NIMX_CheckError( DAQmxCreateTask( '', ADCTaskHandle ) ) ;

     // Select A/D input channels
     ChannelList := '' ;
     for ch := 0 to nChannels-1 do begin
         ChannelList := ChannelList +
                        format( DeviceName + '/AI%d',[ADCChannelInputNumber[ch]] ) ;
         if ch < (nChannels-1) then ChannelList := ChannelList + ',' ;
         end ;

     ADCVoltageRange := ADCVoltageRanges[0] ;
     // Set A/D input mode
     ADCModeCode := NIMX_GetADCInputModeCode( ADCInputMode ) ;

     // Call this to ensure A/D scaling factors are correct for this input mode
//     FADCNumChannels := NIMX_CheckMaxADCChannels( ADCModeCode ) ;
//   No longer required and removed since slows down routine


     NIMX_CheckError( DAQmxCreateAIVoltageChan( ADCTaskHandle,
                                                PANSIChar(ChannelList),
                                                nil ,
                                                ADCModeCode,
                                                -ADCVoltageRange,
                                                ADCVoltageRange,
                                                DAQmx_Val_Volts,
                                                nil));

     // Special processing for USB6008 or USB6009 devices. USB Transfer requests limited to 1
     // to avoid "Onboard device memory overflow" error when running under Windows 7
     // Workaround for known Microsoft bug in Windows 7 USB stack. NIDAQmx 9.4 or later required
     if (ANSIContainsText(FBoardModel, '6008') or ANSIContainsText(FBoardModel, '6009') ) and
         (@DAQmxSetAIUsbXferReqCount <> Nil) then begin
        NIMX_CheckError( DAQmxSetAIUsbXferReqCount( ADCTaskHandle,PANSIChar(ChannelList),1 )) ;
        end ;

     // Set individual channel voltage range
     for ch := 0 to nChannels-1 do
         begin
         ADCVoltageRange := ADCVoltageRanges[ch] ;
         Channel := format(DeviceName + '/AI%d',[ADCChannelInputNumber[ch]]) ;
         NIMX_CheckError( DAQmxSetAIRngHigh( ADCTaskHandle, PANSIChar(Channel),ADCVoltageRange)) ;
         end ;

     // Select continuous sampling if circular buffer selected
     FADCCircularBuffer := CircularBuffer ;
     if CircularBuffer then SampleMode := DAQmx_Val_ContSamps
                       else SampleMode := DAQmx_Val_FiniteSamps ;

     // Set timing
     SamplingRate := 1.0 / SamplingInterval ;
     NIMX_CheckError( DAQmxCfgSampClkTiming( ADCTaskHandle,
                                             nil,
                                             SamplingRate,
                                             DAQmx_Val_Rising,
                                             SampleMode,
                                             nSamples ));

     // Get clock rate set
     NIMX_CheckError( DAQmxGetSampClkRate( ADCTaskHandle, SamplingRate )) ;
     SamplingInterval := 1.0 / SamplingRate ;
     ADCSamplingIntervalInUse := SamplingInterval ; // Keep interval in use

     // Configure buffer (samples / channel limited to 1 million to avoid unable to allocate error with
     // simulated PCI-6281

     NIMX_CheckError( DAQmxCfgInputBuffer ( ADCTaskHandle, Min(nSamples,1000000)) ) ;
     // Enable immediate return with any available data within buffer
     NIMX_CheckError( DAQmxSetReadReadAllAvailSamp( ADCTaskHandle, True )) ;

     // Set triggering
     // --------------

     if TriggerMode = tmFreeRun then begin
        // Start sampling immediately on task start
        NIMX_CheckError(DAQmxDisableStartTrig(ADCTaskHandle));
        end
     else if TriggerMode = tmExtTrigger then begin
        // Starting sampling when external trigger received

        // Trigger polarity (rising/falling TTL pulse)
        if ADCExternalTriggerActiveHigh then TriggerPolarity := DAQmx_Val_Rising
                                        else TriggerPolarity := DAQmx_Val_Falling ;

        TriggerSource := '/' + DeviceName + '/pfi0' ;
        NIMX_CheckError( DAQmxCfgDigEdgeStartTrig( ADCTaskHandle,
                                                   PANSIChar(TriggerSource),
                                                   TriggerPolarity )) ;
        end
     else begin
        if FDACClockSupported then begin
           // Start sampling when DAC waveform sweep starts

           // Use PFI1 as shared trigger for AI and AO when AO/sampleclock not available
           if FNoTriggerOnSampleClock then TriggerSource := '/' + DeviceName + '/pfi1'
                                      else TriggerSource := '/' + DeviceName + '/ao/sampleclock' ;

           NIMX_CheckError( DAQmxCfgDigEdgeStartTrig( ADCTaskHandle,
                                                      PANSIChar(TriggerSource),
                                                      DAQmx_Val_Rising )) ;
           end
        else begin
           // Start sampling immediately (if DAC clock not supported)
           NIMX_CheckError(DAQmxDisableStartTrig(ADCTaskHandle));
           end ;
        end ;

    // Start A/D task
    NIMX_CheckError( DAQmxStartTask(ADCTaskHandle)) ;

{
    // Pulse stream used to test A/D timing 22.07.18
    NIMX_CheckError( DAQmxCreateTask( '', PulseTaskHandle ) ) ;
    NIMX_CheckError( DAQmxCreateCOPulseChanFreq(
                     PulseTaskHandle,
                     PANSICHar('/' + DeviceName + '/freqout'),
                     NIl,
                     DAQmx_Val_Hz,
                     DAQmx_Val_Low ,
                     0.0,
                     25000.0,
                     0.5));
    NIMX_CheckError( DAQmxStartTask(PulseTaskHandle)) ;
 }
    // Restore FPU exceptions
    NIMX_EnableFPUExceptions ;

    ADCActive := True ;
    FADCPointer := 0 ;
    FADCNumChannels := nChannels ;
    FADCNumSamples := nSamples ;
    FADCNumSamplesAcquired := 0 ;

    end ;

function NIMX_GetADCInputModeCode( ADCInputMode : Integer ) : Integer ;
// ---------------------------------------------
// Get NI A/D input mode code from SESLABIO mode
// ---------------------------------------------
begin
     case ADCInputMode of
        imDifferential,imBNC2110 : begin
            if ANSIContainsText(FBoardModel,'611') then Result := DAQmx_Val_PseudoDiff
                                                  else Result := DAQmx_Val_Diff ;
            end ;
        imSingleEndedRSE : Result := DAQmx_Val_RSE ;
        else Result := DAQmx_Val_NRSE ;
        end ;
     end ;


procedure NIMX_GetADCSamples(
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
    NumSamplesRead : Integer ;
    ScaledValue,MaxVal,MinVal : Integer ;
    VScale : Array[0..MaxADCChannels-1] of Single ;
begin

    if not ADCActive then Exit ;

    NIMX_DisableFPUExceptions ;

    ADCBufNumSamples := FADCNumSamples*FADCNumChannels ;
    ADCBufEnd := FADCNumSamples*FADCNuMChannels - 1 ;

    if (not FADCCircularBuffer) and (FADCNumSamplesAcquired >= ADCBufNumSamples) then Exit ;

    // Read data from A/D converter
    NIMX_CheckError( DAQmxReadAnalogF64( ADCTaskHandle,
                     -1,
                     DefaultTimeOut,
                     DAQmx_Val_GroupByScanNumber,
                     DBuf,
                     ADCBufNumSamples,
                     NumSamplesRead,
                     Nil )) ;

    // Apply calibration factors and copy to output buffer

    MaxVal := FADCMaxValue - 1 ;
    MinVal := FADCMinValue + 1 ;

    for ch := 0 to FADCNumChannels-1 do VScale[ch] := FADCMaxValue/ADCChannelVoltageRanges[ch] ;
    j := 0 ;
    for i := 0 to NumSamplesRead-1 do begin
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

    NIMX_EnableFPUExceptions ;

    end ;


function NIMX_StopADC : Boolean ;
// ----------------------------------
// Stop a running A/D conversion task
// ----------------------------------
var
    t0 : Integer ;
begin
    Result := False ;
    if not BoardInitialised then Exit ;
    if not ADCActive then Exit ;
    if FADCNumChannels <= 0 then Exit ;

     NIMX_DisableFPUExceptions ;

     T0 := timegettime ;
     NIMX_CheckError( DAQmxClearTask(ADCTaskHandle)) ;
     if (timegettime - t0) > 1000 then
        outputdebugstring(pchar(format('NIMX_StopADC: %d ms Delay in DAQmxClearTask call. ',[timegettime - t0])));
     ADCActive := False ;

{    Pulse task stopped ... used to test A/D timing.
     NIMX_CheckError( DAQmxStopTask(PulseTaskHandle)) ;
}
     NIMX_EnableFPUExceptions ;

     end ;


procedure NIMX_CheckDACSamplingInterval(
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

     if not BoardInitialised then NIMX_InitialiseBoard ;
     if not BoardInitialised then Exit ;

     if DACActive then begin
        SamplingInterval := DACUpdateIntervalInUse ;
        Exit ;
        end ;

     if not FDACClockSupported then begin ;
        SamplingInterval := FDACMinUpdateInterval ;
        Exit ;
        end ;

     NIMX_DisableFPUExceptions ;

     // Create A/D task
     NIMX_CheckError( DAQmxCreateTask( '', TaskHandle ) ) ;

     // Select A/D input channels
     ChannelList := format( DeviceName + '/AO0:%d', [NumDACChannels-1] ) ;

     NIMX_CheckError( DAQmxCreateAOVoltageChan( TaskHandle,
                                                PANSIChar(ChannelList),
                                                nil ,
                                                FDACMinVolts,
                                                FDACMaxVolts,
                                                DAQmx_Val_Volts,
                                                nil));

     // Set sampling rate (ensuring that it can be supported by board)

     SamplingRate := 1.0/Max(SamplingInterval,FDACMinUpdateInterval) ;  ;

     ActualSamplingRate := 1.0 ;
     Repeat
        // Set sampling rate
        Err := DAQmxCfgSampClkTiming( TaskHandle,
                               nil,
                               SamplingRate,
                               DAQmx_Val_Rising,
                               DAQmx_Val_FiniteSamps,
                               2);
        if Err <> 0 then break ;

        // Read rate back from board
        Err := DAQmxGetSampClkRate( TaskHandle, ActualSamplingRate ) ;
        if Err <> 0 then SamplingRate := SamplingRate*0.75 ;
        Until Err = 0 ;

     // Return actual sampling interval
     SamplingInterval := 1.0 / ActualSamplingRate ;

     // Clear task
     NIMX_CheckError( DAQmxClearTask(TaskHandle)) ;

     NIMX_EnableFPUExceptions ;

     end ;


function NIMX_MemoryToDAC(
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
    SampleMode : Integer ;
    TriggerSource : ANSIString ;
    TriggerPolarity : Integer ;
    ChannelList : ANSIString ;
    PortList : ANSIString ;
    i,Err : Integer ;
    NumSamplesWritten : Integer ;
    VScale : Double ;
    UpdateRate : Double ;
    VDACS : Array[0..31] of Single ;
    TaskHandle : Integer ;
begin
    Result := False ;
    if not BoardInitialised then NIMX_InitialiseBoard ;
    if not BoardInitialised then Exit ;
    if FDACNumChannels <= 0 then Exit ;

    // Stop any running D/A task
     NIMX_StopDAC ;

    // If clocked D/A not supported, write initial D/A values
    if not FDACClockSupported then begin ;
       VScale := FDACMaxVolts / (FDACMaxValue) ;
       for i := 0 to nChannels-1 do VDACS[i] := DACBuf[i]*VScale ;
       NIMX_WriteDACS( VDACS, nChannels ) ;
       Exit ;
       end ;

     NIMX_DisableFPUExceptions ;

     // Create D/A task
     NIMX_CheckError( DAQmxCreateTask( '', DACTaskHandle ) ) ;

     // Select D/A output channels
     ChannelList := format( DeviceName + '/AO0:%d', [nChannels-1] ) ;
     NIMX_CheckError( DAQmxCreateAOVoltageChan( DACTaskHandle,
                                                PANSIChar(ChannelList),
                                                nil ,
                                                FDACMinVolts,
                                                FDACMaxVolts,
                                                DAQmx_Val_Volts,
                                                nil));

     // Select continuous sampling if repeated waveform selected
     if RepeatWaveform then SampleMode := DAQmx_Val_ContSamps
                       else SampleMode := DAQmx_Val_FiniteSamps ;

     UpdateRate := 1.0/UpdateInterval ;

     // Set D/A output timing
     NIMX_CheckError( DAQmxCfgSampClkTiming( DACTaskHandle,
                                             nil,
                                             UpdateRate,
                                             DAQmx_Val_Rising,
                                             SampleMode,
                                             nPoints )) ;
    DACUpdateIntervalInUse := 1.0/UpdateRate ;

     // Configure buffer
     NIMX_CheckError( DAQmxCfgOutputBuffer ( DACTaskHandle, nPoints )) ;

    // Get voltage waveform
     VScale := FDACMaxVolts / (FDACMaxValue) ;
     for i := 0 to (nChannels*nPoints)-1 do DBuf^[i] := DACBuf[i]*VScale ;

     // Write data to buffer
     // No error check to avoid warning of out of range data
     DAQmxWriteAnalogF64 ( DACTaskHandle,
                           nPoints,
                           False,
                           DefaultTimeOut,
                           DAQmx_Val_GroupByScanNumber,
                           DBuf,
                           NumSamplesWritten,
                           Nil
                           ) ;

     if not ExternalTrigger then begin
        // Start sampling immediately on task start
        if FNoTriggerOnSampleClock then begin
           // If ao/sampleclock not available, use PFI1 as trigger
           TriggerSource := '/' + DeviceName + '/PFI0' ;
           NIMX_CheckError( DAQmxCfgDigEdgeStartTrig( DACTaskHandle,
                                                      PANSIChar(TriggerSource),
                                                      DAQmx_Val_Rising )) ;
           // Digital output
           NIMX_CheckError( DAQmxCreateTask( '', TaskHandle ) ) ;
           PortList := DeviceName + '/port0' ;
           Err := DAQmxCreateDOChan( TaskHandle,
                                     PANSIChar(PortList),
                                     nil,
                                     DAQmx_Val_ChanForAllLines );
           if Err = 0 then DAQmxWriteDigitalScalarU32( TaskHandle,
                                                       True,
                                                       DefaultTimeOut,
                                                       0,
                                                       Nil ) ;
           // Clear task
           NIMX_CheckError( DAQmxClearTask ( TaskHandle ) ) ;

           end
        else begin
           NIMX_CheckError(DAQmxDisableStartTrig(DACTaskHandle));
           end;
        end
     else begin
        // Starting sampling when external trigger received

        if True then TriggerPolarity := DAQmx_Val_Rising
                else TriggerPolarity := DAQmx_Val_Falling ;

        // Trigger source for stimulus is PFI0
        TriggerSource := '/' + DeviceName + '/PFI0' ;
        NIMX_CheckError( DAQmxCfgDigEdgeStartTrig( DACTaskHandle,
                                                   PANSIChar(TriggerSource),
                                                   TriggerPolarity )) ;
        end ;

     // Start A/D task
     NIMX_CheckError( DAQmxStartTask(DACTaskHandle)) ;

     // If not in external trigger mode and AO/sampleclock not available for trigger
     // use 5V pulse on P1.0 connected to PFI0 and PFI1 to trigger both A/D and D/A sampling
     if (not ExternalTrigger) and FNoTriggerOnSampleClock then begin
        NIMX_CheckError( DAQmxCreateTask( '', TaskHandle ) ) ;
        Err := DAQmxCreateDOChan( TaskHandle,
                                  PANSIChar(DeviceName + '/port1/Line0'),
                                  nil,
                                  DAQmx_Val_ChanPerLine );
        if Err = 0 then DAQmxWriteDigitalScalarU32( TaskHandle,     // Set = 0
                                                    True,
                                                    DefaultTimeOut,
                                                    0,
                                                    Nil ) ;
        if Err = 0 then DAQmxWriteDigitalScalarU32( TaskHandle,    // Set = 1
                                                    True,
                                                    DefaultTimeOut,
                                                    1,
                                                    Nil ) ;


{        NIMX_CheckError( DAQmxCreateTask( '', TaskHandle ) ) ;
        PortList := DeviceName + '/port1' ;
        Err := DAQmxCreateDOChan( TaskHandle,
                                  PANSIChar(PortList),
                                  nil,
                                  DAQmx_Val_ChanForAllLines );
        if Err = 0 then DAQmxWriteDigitalScalarU32( TaskHandle,
                                                    True,
                                                    DefaultTimeOut,
                                                    1,
                                                    Nil ) ;}
        NIMX_CheckError( DAQmxClearTask ( TaskHandle ) ) ;

        end ;

     // Restore FPU exceptions
     NIMX_EnableFPUExceptions ;

     DACActive := True ;

     end ;


function NIMX_StopDAC : Boolean ;
// ----------------------------------
// Stop a running A/D conversion task
// ----------------------------------
begin
    Result := False ;
    if not BoardInitialised then Exit ;
    if not DACActive then Exit ;
    if FDACNumChannels <= 0 then Exit ;
    if not FDACClockSupported then Exit ;

     NIMX_DisableFPUExceptions ;

     // Stop running D/A task
     NIMX_CheckError( DAQmxClearTask(DACTaskHandle)) ;
     DACActive := False ;

     NIMX_EnableFPUExceptions ;

     end ;


function NIMX_MemoryToDIG(
            var DIGBuf : Array of SmallInt  ;
            nPoints : Integer ;
            UpdateInterval : Double ;
            RepeatWaveform : Boolean
            ) : Boolean ;
// ------------------------------------------
// Generate timed pulse pattern to digital outputs
// ------------------------------------------
var
    SampleMode : Integer ;
    PortList : ANSIString ;
    i : Integer ;
    NumBytesWritten : Integer ;
    ClockSource : ANSIString ;
    PBuf : PIntArray ;
    Err : Integer ;
    UpdateRate : Double ;
begin
    Result := False ;
    if not BoardInitialised then NIMX_InitialiseBoard ;
    if not BoardInitialised then Exit ;
    if not FDigClockSupported then Exit ;

    // Stop any running D/A task
     NIMX_StopDIG ;

     NIMX_DisableFPUExceptions ;

     // Create D/A task
     NIMX_CheckError( DAQmxCreateTask( '', DIGTaskHandle ) ) ;

     // Select digital port 0 for output
     PortList := DeviceName + '/port0' ;
     NIMX_CheckError( DAQmxCreateDOChan( DIGTaskHandle,
                                         PANSIChar(PortList),
                                         nil,
                                         DAQmx_Val_ChanForAllLines ));

     // Select continuous sampling if repeated waveform selected
     if RepeatWaveform then SampleMode := DAQmx_Val_ContSamps
                       else SampleMode := DAQmx_Val_FiniteSamps ;

     // Set digital output timing
     ClockSource := '/' + DeviceName + '/ao/SampleClock' ;
     UpdateRate := 1.0/UpdateInterval ;
     Err := DAQmxCfgSampClkTiming( DIGTaskHandle,
                                   PANSIChar(ClockSource),
                                   1.0/UpdateRate,
                                   DAQmx_Val_Falling ,
                                   SampleMode,
                                   nPoints) ;

     // Exit if clocked digital output not supported
     if Err <> 0 then begin
        NIMX_CheckError( DAQmxClearTask(DIGTaskHandle)) ;
        NIMX_EnableFPUExceptions ;
        Exit ;
        end ;

     // Configure buffer
     NIMX_CheckError( DAQmxCfgOutputBuffer ( DIGTaskHandle, nPoints )) ;

     // Write bit pattern to port
     GetMem( PBuf, nPoints*4 ) ;
     for i := 0 to nPoints-1 do PBuf^[i] := DigBuf[i] ;
     NIMX_CheckError( DAQmxWriteDigitalU32( DIGTaskHandle,
                                           nPoints,
                                           False,
                                           DefaultTimeOut,
                                           DAQmx_Val_GroupByScanNumber ,
                                           PBuf,
                                           NumBytesWritten,
                                           Nil)) ;
     FreeMem( PBuf ) ;

     // Start digital task
     NIMX_CheckError( DAQmxStartTask(DIGTaskHandle)) ;

     // Restore FPU exceptions
     NIMX_EnableFPUExceptions ;

     DigActive := True ;

     end ;


function NIMX_StopDIG : Boolean ;
// --------------------------------
// Stop a running digital I/O  task
// --------------------------------
begin

    Result := False ;
    if not BoardInitialised then Exit ;
    if not DIGActive then Exit ;
    if not FDigClockSupported then Exit ;

     NIMX_DisableFPUExceptions ;

     // Stop running D/A task
     NIMX_CheckError( DAQmxClearTask(DIGTaskHandle)) ;
     DIGActive := False ;

     NIMX_EnableFPUExceptions ;
     Result := DIGActive ;

     end ;



procedure NIMX_WriteDACs(
               DACVolts : array of Single ;
               nChannels : Integer
               ) ;
// -----------------------------------
// Update D/A output channels voltages
// -----------------------------------
var
    DACBuf : Array[0..MaxDACChannels-1] of Double ;
    ChannelList : ANSIString ;
    TaskHandle : Integer ;
    NumSamplesWritten : Integer ;
    i : Integer ;
begin

     if not BoardInitialised then NIMX_InitialiseBoard ;
     if not BoardInitialised then Exit ;
     if FDACNumChannels <= 0 then Exit ;

     // Stop any running D/A task
     NIMX_StopDAC ;

     NIMX_DisableFPUExceptions ;

     // Create task
     NIMX_CheckError( DAQmxCreateTask( '', TaskHandle ) ) ;

     // Select D/A output channels
     ChannelList := format( DeviceName + '/AO0:%d', [nChannels-1] ) ;
     NIMX_CheckError( DAQmxCreateAOVoltageChan( TaskHandle,
                                                PANSIChar(ChannelList),
                                                nil ,
                                                FDACMinVolts,
                                                FDACMaxVolts,
                                                DAQmx_Val_Volts,
                                                nil)) ;

     // Copy into double array
     for i := 0 to nChannels-1 do DACBuf[i] := DACVolts[i] ;

     // No error check to avoid warning of out of range data
     DAQmxWriteAnalogF64 ( TaskHandle,
                                            1,
                                            True,
                                            DefaultTimeOut,
                                            DAQmx_Val_GroupByScanNumber,
                                            @DACBuf,
                                            NumSamplesWritten,
                                            Nil
                                            ) ;

     // Clear task
     NIMX_CheckError( DAQmxClearTask ( TaskHandle ) ) ;

     NIMX_EnableFPUExceptions ;

     end ;


function NIMX_ReadADC(
              Channel : Integer ;        // A/D channel to be read
              ADCVoltageRange : Single ; // A/D input voltage range
              ADCInputMode : Integer
              ) : Integer ;              // Returns raw A/D reading
// ----------------
// Read A/D channel
// ----------------
var
    ChannelList : ANSIString ;
    TaskHandle : Integer ;
    Voltage : Double ;
    ADCModeCode : Integer ;
begin
     Result := 0 ;
     if not BoardInitialised then NIMX_InitialiseBoard ;
     if not BoardInitialised then Exit ;
     if FADCNumChannels <= 0 then Exit ;

     // Stop any running A/D task
     NIMX_StopADC ;

     NIMX_DisableFPUExceptions ;

     // Create task
     NIMX_CheckError( DAQmxCreateTask( '', TaskHandle ) ) ;

     // Select A/D input channel
     ChannelList := format( DeviceName + '/AI%d', [Channel] ) ;

     // Set A/D input mode
     ADCModeCode := NIMX_GetADCInputModeCode( ADCInputMode ) ;

     NIMX_CheckError( DAQmxCreateAIVoltageChan( TaskHandle,
                                      PANSIChar(ChannelList),
                                      nil ,
                                      ADCModeCode,
                                      -ADCVoltageRange,
                                      ADCVoltageRange,
                                      DAQmx_Val_Volts,
                                      nil));

     // Read voltage
     NIMX_CheckError( DAQmxReadAnalogScalarF64( TaskHandle,
                                                 DefaultTimeOut,
                                                 Voltage,
                                                 Nil )) ;

     // Clear task
     NIMX_CheckError( DAQmxClearTask ( TaskHandle ) ) ;

     NIMX_EnableFPUExceptions ;

     Result := Round( (Voltage/ADCVoltageRange)*FADCMaxValue ) ;

     end ;


procedure NIMX_WriteToDigitalOutPutPort(
          Pattern : Integer
          ) ;
// ------------------------------
// Write bits to digital O/P port
// ------------------------------
var
    PortList : ANSIString ;
    TaskHandle : Integer ;
    Err : Integer ;
begin

     if not BoardInitialised then NIMX_InitialiseBoard ;
     if not BoardInitialised then Exit ;

     NIMX_DisableFPUExceptions ;

     // Create task
     NIMX_CheckError( DAQmxCreateTask( '', TaskHandle ) ) ;

     // Select digital port 0 for output
     PortList := DeviceName + '/port0' ;
     Err := DAQmxCreateDOChan( TaskHandle,
                               PANSIChar(PortList),
                               nil,
                               DAQmx_Val_ChanForAllLines );

     // Write bit pattern to output (first 8 bits only used)
     if Err = 0 then DAQmxWriteDigitalScalarU32( TaskHandle,
                                                 True,
                                                 DefaultTimeOut,
                                                 Pattern,
                                                 Nil ) ;

     // Clear task
     NIMX_CheckError( DAQmxClearTask ( TaskHandle ) ) ;
     NIMX_EnableFPUExceptions ;

     end ;


function NIMX_ReadDigitalInputPort : Integer ;
// ------------------------------
// Read bits from digital I/P port
// ------------------------------
var
    PortList : ANSIString ;
    TaskHandle : Integer ;
    Pattern : Integer ;
    Err : Integer ;
begin
     Result := 0 ;
     if not BoardInitialised then NIMX_InitialiseBoard ;
     if not BoardInitialised then Exit ;

     NIMX_StopDIG ;

     NIMX_DisableFPUExceptions ;

     // Create task
     NIMX_CheckError( DAQmxCreateTask( '', TaskHandle ) ) ;

     // Select digital port 0 for input
     PortList := DeviceName + '/port0' ;
     Err := DAQmxCreateDIChan( TaskHandle,
                               PANSIChar(PortList),
                               nil,
                               DAQmx_Val_ChanForAllLines );

     // Read bit pattern from port
     if Err = 0 then DAQmxReadDigitalScalarU32( TaskHandle,
                                                 DefaultTimeOut,
                                                 Pattern,
                                                 Nil ) ;

     // Clear task
     NIMX_CheckError( DAQmxClearTask ( TaskHandle ) ) ;

     NIMX_EnableFPUExceptions ;

     Result := Pattern ;

     end ;


function NIMX_GetValidExternalTriggerPolarity(
         Value : Boolean // TRUE=Active High, False=Active Low
         ) : Boolean ;
// -----------------------------------------------------------------------
// Check that the selected External Trigger polarity is supported by board
// -----------------------------------------------------------------------
begin
    // Both active high and low supported
    Result := Value ;
    end ;


procedure NIMX_CloseLaboratoryInterface ;
// -------------------------------
// Close down laboratory interface
// -------------------------------
begin

    if not BoardInitialised then Exit ;

    // Stop any running A/D task
    NIMX_StopADC ;
    // stop any running D/A task
    NIMX_StopDAC ;

    //FreeMem(InBuf) ;
    FreeMem( DBuf ) ;

    // Free NIDAQ-MX DLL library
    if LibraryLoaded then FreeLibrary( LibraryHnd ) ;
    LibraryLoaded := False ;
    BoardInitialised := False ;

    end ;

end.
