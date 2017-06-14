cmake_minimum_required(VERSION 3.1 FATAL_ERROR)
# If necessary bring in the quickcpplib cmake tooling
list(FIND CMAKE_MODULE_PATH "quickcpplib/cmake" quickcpplib_idx)
if(${quickcpplib_idx} EQUAL -1)
  # CMAKE_SOURCE_DIR is the very topmost parent cmake project
  # CMAKE_CURRENT_SOURCE_DIR is the current cmake subproject
  
  # If there is a magic .quickcpplib_use_siblings directory above the topmost project, use sibling edition
  if(EXISTS "${CMAKE_SOURCE_DIR}/../.quickcpplib_use_siblings")
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/../quickcpplib/cmake")
  elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.gitmodules")
    # Read in .gitmodules and look for myself
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/.gitmodules" GITMODULESCONTENTS)
    if(GITMODULESCONTENTS MATCHES ".*\\n?\\[submodule \"([^\"]+\\/quickcpplib)\"\\]")
      set(quickcpplibpath "${CMAKE_MATCH_1}")
      if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${quickcpplibpath}/cmake")
        set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/${quickcpplibpath}/cmake")
      else()
        message(WARNING "WARNING: ${quickcpplibpath}/cmake does not exist, attempting git submodule update --init --recursive ...")
        include(FindGit)
        execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
          WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        )
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${quickcpplibpath}/cmake")
          set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/${quickcpplibpath}/cmake")
        else()
          message(FATAL_ERROR "FATAL: ${quickcpplibpath}/cmake does not exist and git submodule update --init --recursive did not make it available, bailing out")
        endif()
      endif()
    else()
      message(FATAL_ERROR "FATAL: A copy of quickcpplib cannot be found, and cannot find a quickcpplib submodule in this git repository")
    endif()
  else()
    message(FATAL_ERROR "FATAL: A copy of quickcpplib cannot be found, and there are no git submodules to search")
  endif()
endif()
message(STATUS "CMAKE_MODULE_PATH = ${CMAKE_MODULE_PATH}")