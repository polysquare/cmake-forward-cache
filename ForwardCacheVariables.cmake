# /ForwardCacheVariables.cmake
#
# CMake utility script to forward variables in the cache
# to an initial_cache.cmake file, for use in CMake sub-invocations.
#
# See /LICENCE.md for Copyright information

include ("cmake/cmake-include-guard/IncludeGuard")
cmake_include_guard (SET_MODULE_PATH)

# psq_append_typed_cache_definition
#
# Appends some typed values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# COPT: Name of the option
# VALUE: Value
# TYPE: (string, bool, path, file path)
# CLINES: Variable constituting the cache arguments
macro (psq_append_typed_cache_definition COPT VALUE TYPE CLINES)

    string (TOUPPER "${TYPE}" UTYPE)
    set (${CLINES}
         "${${CLINES}}\nset (${COPT} \"${VALUE}\" CACHE ${UTYPE} \"\" FORCE)")

endmacro ()

# psq_append_cache_definition
#
# Appends some values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# CACHE_OPTION: Name of the option
# VALUE: Value
# CACHE_LINES: Variable constituting the cache arguments
macro (psq_append_cache_definition CACHE_OPTION VALUE CACHE_LINES)

    psq_append_typed_cache_definition (${CACHE_OPTION}
                                       ${VALUE}
                                       string
                                       ${CACHE_LINES})

endmacro ()

# psq_append_cache_definition_variable
#
# Appends some values to a CMakeCache definition (eg, -DVALUE=OPTION)
#
# CACHE_OPTION: Name of the option
# VALUE: Variable containing the value to append
# CACHE_LINES: Variable constituting the cache arguments,
macro (psq_append_cache_definition_variable CACHE_OPTION
                                            VALUE
                                            CACHE_LINES)

    if (DEFINED ${VALUE})
        psq_append_cache_definition (${CACHE_OPTION}
                                     ${VALUE}
                                     ${CACHE_LINES})
    endif ()

endmacro ()

# psq_forward_cache_namespaces_to_file
#
# Appends all variables in this project's cache matching any of
# of the namespaces provided in NAMESPACES to the file specified
# in CACHE_FILE
function (psq_forward_cache_namespaces_to_file CACHE_FILE)

    set (FORWARD_CACHE_MULTIVAR_ARGS NAMESPACES)

    cmake_parse_arguments (FORWARD_CACHE
                           ""
                           ""
                           "${FORWARD_CACHE_MULTIVAR_ARGS}"
                           ${ARGN})

    get_property (AVAILABLE_CACHE_VARIABLES
                  GLOBAL
                  PROPERTY CACHE_VARIABLES)

    # First pass - getting all the variables in the specified namespaces
    foreach (VAR ${AVAILABLE_CACHE_VARIABLES})

        # Search for the namespace at the beginning of the var name. If the
        # found position is 0, then this is a usable cache entry and we should
        # search for the next ":"
        foreach (NAMESPACE ${FORWARD_CACHE_NAMESPACES})

            string (FIND "${VAR}" "${NAMESPACE}" NS_POS)

            if (NS_POS EQUAL 0)

                list (APPEND NAMESPACED_VARIABLES ${VAR})

            endif ()

        endforeach ()

    endforeach ()

    # Second pass - adding those variables to the CACHE_DEFS
    foreach (VAR ${NAMESPACED_VARIABLES})

        get_property (CACHE_VARIABLE_TYPE
                      CACHE ${VAR}
                      PROPERTY TYPE)

        # Ignore STATIC, INTERNAL or UNINITIALIZED type cache entries
        # as they aren't user-modifiable or set.
        if (NOT CACHE_VARIABLE_TYPE STREQUAL "STATIC" AND
            NOT CACHE_VARIABLE_TYPE STREQUAL "INTERNAL" AND
            NOT CACHE_VARIABLE_TYPE STREQUAL "UNINITIALIZED")

            set (TYPE ${CACHE_VARIABLE_TYPE})
            psq_append_typed_cache_definition (${VAR}
                                               "${${VAR}}"
                                               ${TYPE}
                                               CACHE_DEFS)

        endif ()

    endforeach ()

    file (WRITE "${CACHE_FILE}" "${CACHE_DEFS}")

endfunction ()
