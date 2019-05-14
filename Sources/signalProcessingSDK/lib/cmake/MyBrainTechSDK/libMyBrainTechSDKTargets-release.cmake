#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "MyBrainTechSDK::SNR" for configuration "Release"
set_property(TARGET MyBrainTechSDK::SNR APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(MyBrainTechSDK::SNR PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libSNR.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MyBrainTechSDK::SNR )
list(APPEND _IMPORT_CHECK_FILES_FOR_MyBrainTechSDK::SNR "${_IMPORT_PREFIX}/lib/libSNR.a" )

# Import target "MyBrainTechSDK::TimeFrequency" for configuration "Release"
set_property(TARGET MyBrainTechSDK::TimeFrequency APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(MyBrainTechSDK::TimeFrequency PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libTimeFrequency.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MyBrainTechSDK::TimeFrequency )
list(APPEND _IMPORT_CHECK_FILES_FOR_MyBrainTechSDK::TimeFrequency "${_IMPORT_PREFIX}/lib/libTimeFrequency.a" )

# Import target "MyBrainTechSDK::QualityChecker" for configuration "Release"
set_property(TARGET MyBrainTechSDK::QualityChecker APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(MyBrainTechSDK::QualityChecker PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libQualityChecker.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MyBrainTechSDK::QualityChecker )
list(APPEND _IMPORT_CHECK_FILES_FOR_MyBrainTechSDK::QualityChecker "${_IMPORT_PREFIX}/lib/libQualityChecker.a" )

# Import target "MyBrainTechSDK::NF_Melomind" for configuration "Release"
set_property(TARGET MyBrainTechSDK::NF_Melomind APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(MyBrainTechSDK::NF_Melomind PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libNF_Melomind.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MyBrainTechSDK::NF_Melomind )
list(APPEND _IMPORT_CHECK_FILES_FOR_MyBrainTechSDK::NF_Melomind "${_IMPORT_PREFIX}/lib/libNF_Melomind.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
