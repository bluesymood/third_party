cmake_minimum_required(VERSION 3.1 FATAL_ERROR)

project(Zydis VERSION 3.2.1.0 LANGUAGES C CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# =============================================================================================== #
# Overridable options                                                                             #
# =============================================================================================== #

# Features
option(ZYDIS_MINIMAL_MODE
    "Enable minimal mode (forces ZYDIS_DECODER_MODE_MINIMAL runtime option)"
    OFF)
option(ZYDIS_FEATURE_DECODER
    "Enable instruction decoding functionality"
    ON)
option(ZYDIS_FEATURE_FORMATTER
    "Enable instruction formatting functionality"
    ON)
option(ZYDIS_FEATURE_AVX512
    "Enable support for AVX-512 instructions"
    OFF)
option(ZYDIS_FEATURE_KNC
    "Enable support for KNC instructions"
    OFF)

# Build configuration
set(ZYDIS_ZYCORE_PATH
    "${CMAKE_CURRENT_LIST_DIR}/zycore"
    CACHE
    PATH
    "The path to look for Zycore")

add_subdirectory(${ZYDIS_ZYCORE_PATH} "zycore" EXCLUDE_FROM_ALL)

# =============================================================================================== #
# Library configuration                                                                           #
# =============================================================================================== #

set(ZYDIS_SOURCES
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/MetaInfo.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Mnemonic.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Register.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/SharedTypes.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/ShortString.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Status.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Utils.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Zydis.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Internal/SharedData.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Internal/String.h"
    "src/MetaInfo.c"
    "src/Mnemonic.c"
    "src/Register.c"
    "src/SharedData.c"
    "src/String.c"
    "src/Utils.c"
    "src/Zydis.c"
)

if (ZYDIS_FEATURE_DECODER)
    list(APPEND ZYDIS_SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Decoder.h"
        "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/DecoderTypes.h"
        "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Internal/DecoderData.h"
        "src/Decoder.c"
        "src/DecoderData.c"
    )

    if (ZYDIS_FEATURE_FORMATTER AND (NOT ZYDIS_MINIMAL_MODE))
        list(APPEND ZYDIS_SOURCES
            "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Formatter.h"
            "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/FormatterBuffer.h"
            "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Internal/FormatterATT.h"
            "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Internal/FormatterBase.h"
            "${CMAKE_CURRENT_LIST_DIR}/include/Zydis/Internal/FormatterIntel.h"
            "src/Formatter.c"
            "src/FormatterBuffer.c"
            "src/FormatterATT.c"
            "src/FormatterBase.c"
            "src/FormatterIntel.c"
        )
    endif ()
endif ()

add_library("Zydis" STATIC "${ZYDIS_SOURCES}")
set_property(TARGET Zydis PROPERTY POSITION_INDEPENDENT_CODE ON)

target_link_libraries("Zydis" PUBLIC "Zycore")
target_include_directories("Zydis" SYSTEM PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}>
)

target_include_directories("Zydis" PRIVATE "src")
target_include_directories("Zydis" SYSTEM PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/zycore/include
)

target_compile_definitions("Zydis" PRIVATE "_CRT_SECURE_NO_WARNINGS")
target_compile_options("Zydis" PRIVATE "-std=c99")

if (ZYDIS_FEATURE_FORMATTER AND NOT ZYDIS_FEATURE_DECODER)
    message(
        FATAL_ERROR
        "\nZYDIS_FEATURE_FORMATTER requires ZYDIS_FEATURE_DECODER to be enabled"
    )
endif ()

if (ZYDIS_MINIMAL_MODE)
    target_compile_definitions("Zydis" PUBLIC "ZYDIS_MINIMAL_MODE")
endif ()
if (NOT ZYDIS_FEATURE_DECODER)
    target_compile_definitions("Zydis" PUBLIC "ZYDIS_DISABLE_DECODER")
endif ()
if (NOT ZYDIS_FEATURE_FORMATTER)
    target_compile_definitions("Zydis" PUBLIC "ZYDIS_DISABLE_FORMATTER")
endif ()
if (NOT ZYDIS_FEATURE_AVX512)
    target_compile_definitions("Zydis" PUBLIC "ZYDIS_DISABLE_AVX512")
endif ()
if (NOT ZYDIS_FEATURE_KNC)
    target_compile_definitions("Zydis" PUBLIC "ZYDIS_DISABLE_KNC")
endif ()

