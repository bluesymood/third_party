if (TARGET Zycore)
    return()
endif ()

cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

project(Zycore VERSION 1.1.0.0 LANGUAGES C CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# =============================================================================================== #
# Overridable options                                                                             #
# =============================================================================================== #

# Global configuration
option(ZYAN_NO_LIBC
    "Don't use any C standard library functions (for exotic build-envs like kernel drivers)"
    OFF)

# =============================================================================================== #
# Library configuration                                                                           #
# =============================================================================================== #

set(ZYCORE_SOURCES
    # API
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/API/Memory.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/API/Process.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/API/Synchronization.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/API/Terminal.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/API/Thread.h"
    # Common
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Allocator.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/ArgParse.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Atomic.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Bitset.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Comparison.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Defines.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Format.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/LibC.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/List.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Object.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Status.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/String.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Types.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Vector.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Zycore.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Internal/AtomicGNU.h"
    "${CMAKE_CURRENT_LIST_DIR}/include/Zycore/Internal/AtomicMSVC.h"
    # API
    "src/API/Memory.c"
    "src/API/Process.c"
    "src/API/Synchronization.c"
    "src/API/Terminal.c"
    "src/API/Thread.c"
    # Common
    "src/Allocator.c"
    "src/ArgParse.c"
    "src/Bitset.c"
    "src/Format.c"
    "src/List.c"
    "src/String.c"
    "src/Vector.c"
    "src/Zycore.c"
)

add_library("Zycore" STATIC "${ZYCORE_SOURCES}")

set_target_properties("Zycore" PROPERTIES LINKER_LANGUAGE C)
target_include_directories("Zycore" SYSTEM PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}>
)
target_include_directories("Zycore" PRIVATE "src")
target_compile_definitions("Zycore" PRIVATE "_CRT_SECURE_NO_WARNINGS")
target_compile_options("Zycore" PRIVATE "-std=c99")

if (ZYAN_NO_LIBC)
    target_compile_definitions("Zycore" PUBLIC "ZYAN_NO_LIBC")
    if (UNIX)
        set_target_properties("Zycore" PROPERTIES LINK_FLAGS "-nostdlib -nodefaultlibs")
    endif ()
endif ()

if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND NOT ZYAN_NO_LIBC)
    target_compile_definitions("Zycore" PRIVATE "_GNU_SOURCE")
    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_package(Threads REQUIRED)
    target_link_libraries("Zycore" Threads::Threads)
endif ()
