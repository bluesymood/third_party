cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

cmake_policy(PUSH)

if(POLICY CMP0063)
  cmake_policy(SET CMP0063 NEW) # Honor visibility properties.
endif()

if(POLICY CMP0092)
  cmake_policy(SET CMP0092 NEW) # Don't add -W3 warning level by default.
endif()

include(CheckCXXCompilerFlag)

# Don't create a project if it was already created by another CMakeLists.txt.
# This allows one library to embed another library without making a collision.
if (NOT CMAKE_PROJECT_NAME OR "${CMAKE_PROJECT_NAME}" STREQUAL "asmjit")
  project(asmjit CXX)
endif()

# =============================================================================
# [AsmJit - Deprecated]
# =============================================================================

if (DEFINED ASMJIT_BUILD_EMBED)
  message(DEPRECATION "ASMJIT_BUILD_EMBED is deprecated, use ASMJIT_EMBED")
  set(ASMJIT_EMBED "${ASMJIT_BUILD_EMBED}")
endif()

if (DEFINED ASMJIT_BUILD_STATIC)
  message(DEPRECATION "ASMJIT_BUILD_STATIC is deprecated, use ASMJIT_STATIC")
  set(ASMJIT_STATIC "${ASMJIT_BUILD_STATIC}")
endif()

# =============================================================================
# [AsmJit - Configuration]
# =============================================================================

if (NOT DEFINED ASMJIT_EMBED)
  set(ASMJIT_EMBED FALSE)
endif()

if (NOT DEFINED ASMJIT_STATIC)
  set(ASMJIT_STATIC ${ASMJIT_EMBED})
endif()

if (NOT DEFINED ASMJIT_BUILD_ARM)
  set(ASMJIT_BUILD_ARM FALSE)
endif()

if (NOT DEFINED ASMJIT_BUILD_X86)
  set(ASMJIT_BUILD_X86 FALSE)
endif()

# EMBED implies STATIC.
if (ASMJIT_EMBED AND NOT ASMJIT_STATIC)
  set(ASMJIT_STATIC TRUE)
endif()

set(ASMJIT_DIR        "${CMAKE_CURRENT_LIST_DIR}" CACHE PATH "Location of 'asmjit'")
set(ASMJIT_EMBED      ${ASMJIT_EMBED}             CACHE BOOL "Embed 'asmjit' library (no targets)")
set(ASMJIT_STATIC     ${ASMJIT_STATIC}            CACHE BOOL "Build 'asmjit' library as static")
set(ASMJIT_SANITIZE   ${ASMJIT_SANITIZE}          CACHE STRING "Build with sanitizers: 'address', 'undefined', etc...")
set(ASMJIT_BUILD_X86  ${ASMJIT_BUILD_X86}         CACHE BOOL "Build X86 backends (X86 and X86_64)")
set(ASMJIT_BUILD_ARM  ${ASMJIT_BUILD_ARM}         CACHE BOOL "Build ARM backends (ARM/Trumb and AArch64")

# =============================================================================
# [AsmJit - Project]
# =============================================================================

set(ASMJIT_INCLUDE_DIRS "${ASMJIT_DIR}/src")     # Include directory is the same as source dir.
set(ASMJIT_DEPS "")                              # AsmJit dependencies (libraries) for the linker.
set(ASMJIT_LIBS "")                              # Dependencies of libs/apps that want to use AsmJit.
set(ASMJIT_CFLAGS "")                            # Public compiler flags.
set(ASMJIT_PRIVATE_CFLAGS "")                    # Private compiler flags independent of build type.
set(ASMJIT_PRIVATE_CFLAGS_DBG "")                # Private compiler flags used by debug builds.
set(ASMJIT_PRIVATE_CFLAGS_REL "")                # Private compiler flags used by release builds.
set(ASMJIT_SANITIZE_CFLAGS "")                   # Compiler flags required by currently enabled sanitizers.
set(ASMJIT_SANITIZE_LFLAGS "")                   # Linker flags required by currently enabled sanitizers.

# =============================================================================
# [AsmJit - Utilities]
# =============================================================================

function(asmjit_detect_cflags out)
  set(out_array ${${out}})
  foreach(flag ${ARGN})
    string(REGEX REPLACE "[+]" "x" flag_signature "${flag}")
    string(REGEX REPLACE "[-=:;/.\]" "_" flag_signature "${flag_signature}")
    check_cxx_compiler_flag(${flag} "__CxxFlag_${flag_signature}")
    if (${__CxxFlag_${flag_signature}})
      list(APPEND out_array "${flag}")
    endif()
  endforeach()
  set(${out} "${out_array}" PARENT_SCOPE)
endfunction()

# Support for various sanitizers provided by C/C++ compilers.
function(asmjit_detect_sanitizers out)
  set(_out_array ${${out}})
  set(_flags "")

  foreach(_arg ${ARGN})
    string(REPLACE "," ";" _arg "${_arg}")
    list(APPEND _flags ${_arg})
  endforeach()

  foreach(_flag ${_flags})
    if (NOT "${_flag}" MATCHES "^-fsanitize=")
      SET(_flag "-fsanitize=${_flag}")
    endif()

    # Sanitizers also require link flags, see CMAKE_REQUIRED_FLAGS.
    set(CMAKE_REQUIRED_FLAGS "${_flag}")
    asmjit_detect_cflags(_out_array ${_flag})
    unset(CMAKE_REQUIRED_FLAGS)
  endforeach()

  set(${out} "${_out_array}" PARENT_SCOPE)
endfunction()

function(asmjit_add_target target target_type)
  set(single_val "")
  set(multi_val SOURCES LIBRARIES CFLAGS CFLAGS_DBG CFLAGS_REL)
  cmake_parse_arguments("X" "" "${single_val}" "${multi_val}" ${ARGN})

  add_library(${target} ${target_type} ${X_SOURCES})

  target_link_libraries(${target} PRIVATE ${X_LIBRARIES})

  # target_link_options was added in cmake v3.13, don't use it for now...
  foreach(link_flag ${ASMJIT_SANITIZE_LFLAGS})
    set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS " ${link_flag}")
  endforeach()

  if (${CMAKE_VERSION} VERSION_LESS "3.8.0")
    set_property(TARGET ${target} PROPERTY CXX_STANDARD 11)
  else()
    target_compile_features(${target} PUBLIC cxx_std_11)
  endif()
  set_property(TARGET ${target} PROPERTY CXX_EXTENSIONS NO)
  set_property(TARGET ${target} PROPERTY CXX_VISIBILITY_PRESET hidden)
  target_compile_options(${target} PRIVATE ${X_CFLAGS} ${ASMJIT_SANITIZE_CFLAGS} $<$<CONFIG:Debug>:${X_CFLAGS_DBG}> $<$<NOT:$<CONFIG:Debug>>:${X_CFLAGS_REL}>)
endfunction()

# =============================================================================
# [AsmJit - Compiler Support]
# =============================================================================

set(ASMJIT_INCLUDE_DIRS "${ASMJIT_DIR}/src")     # Include directory is the same as source dir.
set(ASMJIT_DEPS "arkbase")                       # AsmJit dependencies (libraries) for the linker.
set(ASMJIT_LIBS "")                              # Dependencies of libs/apps that want to use AsmJit.
set(ASMJIT_CFLAGS "")                            # Public compiler flags.
set(ASMJIT_PRIVATE_CFLAGS "")                    # Private compiler flags independent of build type.
set(ASMJIT_PRIVATE_CFLAGS_DBG "")                # Private compiler flags used by debug builds.
set(ASMJIT_PRIVATE_CFLAGS_REL "")                # Private compiler flags used by release builds.
set(ASMJIT_SANITIZE_CFLAGS "")                   # Compiler flags required by currently enabled sanitizers.
set(ASMJIT_SANITIZE_LFLAGS "")                   # Linker flags required by currently enabled sanitizers.

# We will have to keep this most likely forever as some users may still be using it.
set(ASMJIT_INCLUDE_DIR "${ASMJIT_INCLUDE_DIRS}")

if (NOT ASMJIT_NO_CUSTOM_FLAGS)
  if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "^(GNU|Clang|AppleClang)$")
    # disabled because of arkbase allocators integration
    #list(APPEND ASMJIT_PRIVATE_CFLAGS -Wall -Wextra -Wconversion)
    list(APPEND ASMJIT_PRIVATE_CFLAGS -fno-math-errno)
    list(APPEND ASMJIT_PRIVATE_CFLAGS -Wno-shadow)

    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 14.0.0)
      list(APPEND ASMJIT_PRIVATE_CFLAGS -Wno-bitwise-instead-of-logical)
      list(APPEND ASMJIT_PRIVATE_CFLAGS -Wno-unused-but-set-variable)
      list(APPEND ASMJIT_PRIVATE_CFLAGS -Wno-deprecated-copy)
    endif()

    list(APPEND ASMJIT_PRIVATE_CFLAGS_REL -O2)

    asmjit_detect_cflags(ASMJIT_PRIVATE_CFLAGS
      -fno-threadsafe-statics
      -fno-semantic-interposition)

    # The following flags can save few bytes in the resulting binary.
    asmjit_detect_cflags(ASMJIT_PRIVATE_CFLAGS_REL
      -fmerge-all-constants    # Merge all constants even if it violates ISO C++.
      -fno-enforce-eh-specs)   # Don't enforce termination if noexcept function throws.
  endif()
endif()

# Support for sanitizers.
if (ASMJIT_SANITIZE)
  ASMJIT_detect_sanitizers(ASMJIT_SANITIZE_CFLAGS ${ASMJIT_SANITIZE})
  if (ASMJIT_SANITIZE_CFLAGS)
    message("-- Enabling sanitizers: '${ASMJIT_SANITIZE_CFLAGS}'")

    # Linker must receive the same flags as the compiler when it comes to sanitizers.
    set(ASMJIT_SANITIZE_LFLAGS ${ASMJIT_SANITIZE_CFLAGS})

    # Don't omit frame pointer if sanitizers are enabled.
    list(APPEND ASMJIT_SANITIZE_CFLAGS -fno-omit-frame-pointer -g)

    list(APPEND ASMJIT_PRIVATE_CFLAGS ${ASMJIT_SANITIZE_CFLAGS})
    list(APPEND ASMJIT_PRIVATE_LFLAGS ${ASMJIT_SANITIZE_LFLAGS})
  endif()
endif()

list(APPEND ASMJIT_DEPS pthread)

if ("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
  list(APPEND ASMJIT_DEPS rt)
endif()

set(ASMJIT_LIBS ${ASMJIT_DEPS})
if (NOT ASMJIT_EMBED)
  list(INSERT ASMJIT_LIBS 0 asmjit)
endif()

if (ASMJIT_EMBED)
  set(ASMJIT_TARGET_TYPE "EMBED")
elseif (ASMJIT_STATIC)
  set(ASMJIT_TARGET_TYPE "STATIC")
else()
  set(ASMJIT_TARGET_TYPE "SHARED")
endif()

foreach(build_option ASMJIT_STATIC
                     ASMJIT_BUILD_X86
                     #ASMJIT_BUILD_ARM
                     ASMJIT_BUILD_A64
                     ASMJIT_NO_DEPRECATED
                     ASMJIT_NO_JIT
                     ASMJIT_NO_LOGGING
                     ASMJIT_NO_BUILDER
                     ASMJIT_NO_COMPILER
                     ASMJIT_NO_TEXT
                     ASMJIT_NO_VALIDATION
                     ASMJIT_NO_INTROSPECTION)
  if (${build_option})
    List(APPEND ASMJIT_CFLAGS         "-D${build_option}")
    List(APPEND ASMJIT_PRIVATE_CFLAGS "-D${build_option}")
  endif()
endforeach()

# =============================================================================
# [AsmJit - Linker Support]
# =============================================================================

# =============================================================================
# [AsmJit - Source]
# =============================================================================

set(ASMJIT_SRC_LIST
  asmjit/asmjit.h

  asmjit/core.h
  asmjit/core/api-build_p.h
  asmjit/core/api-config.h
  asmjit/core/arch.cpp
  asmjit/core/arch.h
  asmjit/core/assembler.cpp
  asmjit/core/assembler.h
  asmjit/core/builder.cpp
  asmjit/core/builder.h
  asmjit/core/callconv.cpp
  asmjit/core/callconv.h
  asmjit/core/codebuffer.h
  asmjit/core/codebufferwriter_p.h
  asmjit/core/codeholder.cpp
  asmjit/core/codeholder.h
  asmjit/core/compiler.cpp
  asmjit/core/compiler.h
  asmjit/core/constpool.cpp
  asmjit/core/constpool.h
  asmjit/core/cpuinfo.cpp
  asmjit/core/cpuinfo.h
  asmjit/core/datatypes.h
  asmjit/core/emitter.cpp
  asmjit/core/emitter.h
  asmjit/core/emitterutils.cpp
  asmjit/core/emitterutils_p.h
  asmjit/core/environment.cpp
  asmjit/core/environment.h
  asmjit/core/errorhandler.cpp
  asmjit/core/errorhandler.h
  asmjit/core/features.h
  asmjit/core/formatter.cpp
  asmjit/core/formatter.h
  asmjit/core/func.cpp
  asmjit/core/func.h
  asmjit/core/globals.cpp
  asmjit/core/globals.h
  asmjit/core/inst.cpp
  asmjit/core/inst.h
  asmjit/core/jitallocator.cpp
  asmjit/core/jitallocator.h
  asmjit/core/jitruntime.cpp
  asmjit/core/jitruntime.h
  asmjit/core/logger.cpp
  asmjit/core/logger.h
  asmjit/core/misc_p.h
  asmjit/core/operand.cpp
  asmjit/core/operand.h
  asmjit/core/osutils.cpp
  asmjit/core/osutils.h
  asmjit/core/raassignment_p.h
  asmjit/core/rabuilders_p.h
  asmjit/core/radefs_p.h
  asmjit/core/ralocal.cpp
  asmjit/core/ralocal_p.h
  asmjit/core/rapass.cpp
  asmjit/core/rapass_p.h
  asmjit/core/rastack.cpp
  asmjit/core/rastack_p.h
  asmjit/core/string.cpp
  asmjit/core/string.h
  asmjit/core/support.cpp
  asmjit/core/support.h
  asmjit/core/target.cpp
  asmjit/core/target.h
  asmjit/core/type.cpp
  asmjit/core/type.h
  asmjit/core/virtmem.cpp
  asmjit/core/virtmem.h
  asmjit/core/zone.cpp
  asmjit/core/zone.h
  asmjit/core/zonehash.cpp
  asmjit/core/zonehash.h
  asmjit/core/zonelist.cpp
  asmjit/core/zonelist.h
  asmjit/core/zonestack.cpp
  asmjit/core/zonestack.h
  asmjit/core/zonestring.h
  asmjit/core/zonetree.cpp
  asmjit/core/zonetree.h
  asmjit/core/zonevector.cpp
  asmjit/core/zonevector.h

  asmjit/x86.h
  asmjit/x86/x86archdata.cpp
  asmjit/x86/x86archdata_p.h
  asmjit/x86/x86assembler.cpp
  asmjit/x86/x86assembler.h
  asmjit/x86/x86builder.cpp
  asmjit/x86/x86builder.h
  asmjit/x86/x86callconv.cpp
  asmjit/x86/x86callconv_p.h
  asmjit/x86/x86compiler.cpp
  asmjit/x86/x86compiler.h
  asmjit/x86/x86emitter.h
  asmjit/x86/x86features.cpp
  asmjit/x86/x86features.h
  asmjit/x86/x86formatter.cpp
  asmjit/x86/x86formatter_p.h
  asmjit/x86/x86globals.h
  asmjit/x86/x86internal.cpp
  asmjit/x86/x86internal_p.h
  asmjit/x86/x86instdb.cpp
  asmjit/x86/x86instdb.h
  asmjit/x86/x86instdb_p.h
  asmjit/x86/x86instapi.cpp
  asmjit/x86/x86instapi_p.h
  asmjit/x86/x86operand.cpp
  asmjit/x86/x86operand.h
  asmjit/x86/x86rapass.cpp
  asmjit/x86/x86rapass_p.h
)

set(ASMJIT_SRC "")
foreach(src_file ${ASMJIT_SRC_LIST})
  set(src_file "${ASMJIT_DIR}/src/${src_file}")
  list(APPEND ASMJIT_SRC ${src_file})
endforeach()

if (NOT ${CMAKE_VERSION} VERSION_LESS "3.8.0")
  source_group(TREE "${ASMJIT_DIR}" FILES ${ASMJIT_SRC})
endif()

# =============================================================================
# [AsmJit - Summary]
# =============================================================================

set(ASMJIT_SUMMARY FALSE)
if (ASMJIT_SUMMARY)
  message("** AsmJit Summary **")
  message("   ASMJIT_DIR=${ASMJIT_DIR}")
  message("   ASMJIT_TARGET_TYPE=${ASMJIT_TARGET_TYPE}")
  message("   ASMJIT_DEPS=${ASMJIT_DEPS}")
  message("   ASMJIT_LIBS=${ASMJIT_LIBS}")
  message("   ASMJIT_CFLAGS=${ASMJIT_CFLAGS}")
  message("   ASMJIT_PRIVATE_CFLAGS=${ASMJIT_PRIVATE_CFLAGS}")
  message("   ASMJIT_PRIVATE_CFLAGS_DBG=${ASMJIT_PRIVATE_CFLAGS_DBG}")
  message("   ASMJIT_PRIVATE_CFLAGS_REL=${ASMJIT_PRIVATE_CFLAGS_REL}")
endif()

# =============================================================================
# [AsmJit - Targets]
# =============================================================================

if (NOT ASMJIT_EMBED)
  # Add AsmJit target.
  asmjit_add_target(asmjit "${ASMJIT_TARGET_TYPE}"
                    SOURCES    ${ASMJIT_SRC}
                    LIBRARIES  ${ASMJIT_DEPS}
                    CFLAGS     ${ASMJIT_PRIVATE_CFLAGS}
                    CFLAGS_DBG ${ASMJIT_PRIVATE_CFLAGS_DBG}
                    CFLAGS_REL ${ASMJIT_PRIVATE_CFLAGS_REL})
  target_include_directories(asmjit SYSTEM BEFORE INTERFACE ${ASMJIT_INCLUDE_DIRS})
  target_compile_options(asmjit INTERFACE ${ASMJIT_CFLAGS})
  set_target_properties(asmjit PROPERTIES POSITION_INDEPENDENT_CODE ON)
  add_library(AsmJit::AsmJit ALIAS asmjit)

  # Add AsmJit install instructions (library and public headers).
  if (NOT ASMJIT_NO_INSTALL)
    install(TARGETS asmjit RUNTIME DESTINATION "bin"
                           LIBRARY DESTINATION "lib${LIB_SUFFIX}"
                           ARCHIVE DESTINATION "lib${LIB_SUFFIX}")
    foreach(_src_file ${ASMJIT_SRC_LIST})
      if ("${_src_file}" MATCHES "\\.h$" AND NOT "${_src_file}" MATCHES "_p\\.h$")
        get_filename_component(_src_dir ${_src_file} PATH)
        install(FILES "${ASMJIT_DIR}/src/${_src_file}" DESTINATION "include/${_src_dir}")
      endif()
    endforeach()
  endif()
endif()

cmake_policy(POP)
