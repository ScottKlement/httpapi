#   File:       Makefile.MPW
#   Targets:    All, Dynamic, Static (and Clean, Clean-All)
#   Created:    Tuesday, July 02, 2002
#
#   MPW Makefile for building expat under the "classic" (i.e. pre-X) Mac OS
#   Copyright © 2002 Daryle Walker
#   Portions Copyright © 2002 Thomas Wegner
#   See the COPYING file for distribution information
#
#   Description:
#   This Makefile lets you build static, dynamic (i.e. shared) and stub
#   versions of the expat library as well as the elements.c and outline.c
#   examples (built as tools for MPW). This is for PPC only; it should be
#   no problem to build a 68K version of the expat library, though.
#
#       Usage:
#                              Buildprogram All
#                        or    Buildprogram Dynamic
#                        or    Buildprogram Static
#
#   Note: You first have to rename this file to "Makefile", or the Buildprogram
#         commando will not recognize it.
#

MAKEFILE        = Makefile
¥MondoBuild¥    = {MAKEFILE}  # Make blank to avoid rebuilds when makefile is modified

ObjDir          = :
SrcDir          = :
HdrDir          = :

ToolDir         = ::examples:

Includes        = -i {HdrDir}

Sym-PPC         = -sym off

Defines         = -d MACOS_CLASSIC

PPCCOptions     = {Includes} {Sym-PPC} -w 35 {Defines}

FragName        = libexpat


### Source Files ###

SrcFiles        =  ¶
                                  "{SrcDir}xmlparse.c" ¶
                                  "{SrcDir}xmlrole.c" ¶
                                  "{SrcDir}xmltok.c"

ToolSrcFiles    =  ¶
                                  "{ToolDir}elements.c" ¶
                                  "{ToolDir}outline.c"


### Object Files ###

ObjFiles-PPC    =  ¶
                                  "{ObjDir}xmlparse.c.o" ¶
                                  "{ObjDir}xmlrole.c.o" ¶
                                  "{ObjDir}xmltok.c.o"

ElementToolObjFile   =  "{ObjDir}elements.c.o"

OutlineToolObjFile   =  "{ObjDir}outline.c.o"


### Libraries ###

StLibFiles-PPC    =  ¶
                                  "{PPCLibraries}StdCRuntime.o" ¶
                                  "{PPCLibraries}PPCCRuntime.o" ¶
                                  "{PPCLibraries}PPCToolLibs.o"

ShLibFiles-PPC    =  ¶
                                  "{SharedLibraries}InterfaceLib" ¶
                                  "{SharedLibraries}StdCLib" ¶
                                  "{SharedLibraries}MathLib"

LibFiles-PPC    =  ¶
                                  {StLibFiles-PPC} ¶
                                  {ShLibFiles-PPC}


### Special Files ###

ExportFile      = "{ObjDir}{FragName}.exp"

StLibFile       = "{ObjDir}{FragName}.MrC.o"

ShLibFile       = "{ObjDir}{FragName}"

StubFile        = "{ObjDir}{FragName}.stub"

ElementsTool    = "{ToolDir}elements"

OutlineTool     = "{ToolDir}outline"


### Default Rules ###

.c.o  Ä  .c  {¥MondoBuild¥}
        {PPCC} {depDir}{default}.c -o {targDir}{default}.c.o {PPCCOptions}


### Build Rules ###

All  Ä  Dynamic {ElementsTool} {OutlineTool}

Static  Ä  {StLibFile}

Dynamic  Ä  Static {ShLibFile} {StubFile}

{StLibFile}  ÄÄ  {ObjFiles-PPC} {StLibFiles-PPC} {¥MondoBuild¥}
        PPCLink ¶
                -o {Targ} ¶
                {ObjFiles-PPC} ¶
                {StLibFiles-PPC} ¶
                {Sym-PPC} ¶
                -mf -d ¶
                -t 'XCOF' ¶
                -c 'MPS ' ¶
                -xm l

{ShLibFile}  ÄÄ  {StLibFile} {ShLibFiles-PPC} {ExportFile} {¥MondoBuild¥}
        PPCLink ¶
                -o {Targ} ¶
                {StLibFile} ¶
                {ShLibFiles-PPC} ¶
                {Sym-PPC} ¶
                -@export {ExportFile} ¶
                -fragname {FragName} ¶
                -mf -d ¶
                -t 'shlb' ¶
                -c '????' ¶
                -xm s

{StubFile}  ÄÄ  {ShLibFile} {¥MondoBuild¥}
        shlb2stub -o {Targ} {ShLibFile}

{ElementsTool}  ÄÄ  {ElementToolObjFile} {StubFile} {LibFiles-PPC} {¥MondoBuild¥}
        PPCLink ¶
                -o {Targ} ¶
                {ElementToolObjFile} ¶
                {StLibFile} ¶
                {LibFiles-PPC} ¶
                {Sym-PPC} ¶
                -mf -d ¶
                -t 'MPST' ¶
                -c 'MPS '

{OutlineTool}  ÄÄ  {OutlineToolObjFile} {StubFile} {LibFiles-PPC} {¥MondoBuild¥}
        PPCLink ¶
                -o {Targ} ¶
                {OutlineToolObjFile} ¶
                {StLibFile} ¶
                {LibFiles-PPC} ¶
                {Sym-PPC} ¶
                -mf -d ¶
                -t 'MPST' ¶
                -c 'MPS '


### Special Rules ###

{ExportFile}  ÄÄ  "{HdrDir}expat.h" {¥MondoBuild¥}
        StreamEdit -d ¶
                -e "/¥('XMLPARSEAPI('Å') ')Ç0,1È'XML_'([A-Za-z0-9_]+)¨1'('/ Print 'XML_' ¨1" ¶
                "{HdrDir}expat.h" > {Targ}


### Required Dependencies ###

"{ObjDir}xmlparse.c.o"  Ä  "{SrcDir}xmlparse.c"
"{ObjDir}xmlrole.c.o"  Ä  "{SrcDir}xmlrole.c"
"{ObjDir}xmltok.c.o"  Ä  "{SrcDir}xmltok.c"

"{ObjDir}elements.c.o"  Ä "{ToolDir}elements.c"
"{ObjDir}outline.c.o"  Ä "{ToolDir}outline.c"


### Optional Dependencies ###
### Build this target to clean out generated intermediate files. ###

Clean  Ä
        Delete {ObjFiles-PPC} {ExportFile} {ElementToolObjFile} {OutlineToolObjFile}

### Build this target to clean out all generated files. ###

Clean-All  Ä  Clean
        Delete {StLibFile} {ShLibFile} {StubFile} {ElementsTool} {OutlineTool}

### Build this target to generate "include file" dependencies. ###

Dependencies  Ä  $OutOfDate
        MakeDepend ¶
                -append {MAKEFILE} ¶
                -ignore "{CIncludes}" ¶
                -objdir "{ObjDir}" ¶
                -objext .o ¶
                {Defines} ¶
                {Includes} ¶
                {SrcFiles}


