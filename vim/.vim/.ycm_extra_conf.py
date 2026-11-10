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
  extension = os.path.splitext( filename )
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]


def GetCompilationInfoForFile( filename ):
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        compilation_info = database.GetCompilationInfoForFile(
          replacement_file )
        if compilation_info.compiler_flags_:
          return compilation_info
    return None
  return database.GetCompilationInfoForFile( filename )


def Settings( **kwargs ):
  filename = kwargs.get( 'filename', '' )
  final_flags = list( flags )

  if filename:
    # Get directory of current active file
    file_dir = os.path.dirname( os.path.abspath( filename ) )
    final_flags.extend( [ '-I', file_dir ] )

    # Safely find the absolute path of the root "Auto-assignment" folder
    current = file_dir
    project_root = None
    while current and current != os.path.dirname(current):
      if os.path.basename(current) == 'Auto-assignment':
        project_root = current
        break
      current = os.path.dirname(current)

    # Use clean absolute locations based on the project root directory
    if project_root:
      final_flags.extend( [ '-I', os.path.join(project_root, 'include') ] )
      final_flags.extend( [ '-I', os.path.join(project_root, 'external/include') ] )
      final_flags.extend( [ '-I', os.path.join(project_root, 'libs') ] )
    else:
      # Fallback defaults for other programs
      resolved_include = os.path.abspath( os.path.join( file_dir, '../include' ) )
      external_include = os.path.abspath( os.path.join( file_dir, '../external/include' ) )
      resolved_libs = os.path.abspath( os.path.join( file_dir, '../libs' ) )
      final_flags.extend( [ '-I', resolved_include ] )
      final_flags.extend( [ '-I', external_include ] )
      final_flags.extend( [ '-I', resolved_libs ] )

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

  db_flags = list( compilation_info.compiler_flags_ ) + [ '-std=c++23' ]
  return {
    'flags': db_flags,
    'include_paths_relative_to_dir': compilation_info.compiler_working_dir_,
    'override_clang_flags': True,
    'do_not_cache': True
  }
