# Copyright (C) 2014 Google Inc.
# This file is part of ycmd.
#
# ycmd is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ycmd is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ycmd.  If not, see <http://gnu.org>.

import os
import ycm_core

# Base flags layout used to initialize system C++23 parsing
flags = [
'-Wall',
'-Wextra',
'-Werror',
'-fexceptions',
'-DNDEBUG',
'-std=c++23',
'-pthread',
'-x',
'c++',
# TARGET CONFIGURATION: Match Ubuntu 15 native arch & optimization expectations
'-target',
'x86_64-pc-linux-gnu',
'-march=x86-64-v3',
# Ubuntu C++ Standard Library Paths
'-D_GLIBCXX_USE_CXX11_ABI=1',
'-D_GLIBCXX_RELEASE=15',
'-D__GXX_EXPERIMENTAL_CXX0X__=1',
'-isystem',
'/usr/include/c++/15',
'-isystem',
'/usr/include/x86_64-linux-gnu/c++/15',
'-isystem',
'/usr/include/c++/15/backward',
# GCC Internal Header Path (Required for feature macros resolution)
'-isystem',
'/usr/lib/gcc/x86_64-linux-gnu/15/include',
'--gcc-toolchain=/usr',
'-stdlib=libstdc++',
'-isystem',
'/usr/local/include',
'-isystem',
'/usr/include/x86_64-linux-gnu',
'-isystem',
'/usr/include'
]

compilation_database_folder = ''

if os.path.exists( compilation_database_folder ):
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )


def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[1]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]


def GetCompilationInfoForFile( filename ):
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[0]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        compilation_info = database.GetCompilationInfoForFile(
          replacement_file )
        if compilation_info.compiler_flags_:
          return compilation_info
    return None
  return database.GetCompilationInfoForFile( filename )


# This is the entry point; this function is called by ycmd to produce flags for a file.
def Settings( **kwargs ):
  filename = kwargs.get( 'filename', '' )
  # Initialize using our base flags
  final_flags = list( flags )

  # DYNAMIC PATH RESOLUTION: If a file is active, resolve '../include' relative to it
  if filename:
    file_dir = os.path.dirname( os.path.abspath( filename ) )
    # Resolve the true location of '../include' relative to the file being edited
    resolved_include = os.path.abspath( os.path.join( file_dir, '../include' ) )
    final_flags.extend( [ '-I', resolved_include ] )
    final_flags.extend( [ '-I', file_dir ] )
    external_include = os.path.abspath( os.path.join( file_dir, '../external/include' ) )
    final_flags.extend( [ '-I', external_include ] )

  if not database:
    return {
      'flags': final_flags,
      'include_paths_relative_to_dir': DirectoryOfThisScript(),
      'override_clang_flags': True,
      'do_not_cache': True
    }

  compilation_info = GetCompilationInfoForFile( filename )
  if not compilation_info:
    return None

  # Handle compilation database values safely if one gets generated later
  db_flags = list( compilation_info.compiler_flags_ ) + [ '-std=c++23' ]
  return {
    'flags': db_flags,
    'include_paths_relative_to_dir': compilation_info.compiler_working_dir_,
    'override_clang_flags': True,
    'do_not_cache': True
  }

