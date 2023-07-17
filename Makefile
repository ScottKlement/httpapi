.SECONDARY:
.PRECIOUS:

.SECONDEXPANSION:
.ONESHELL:
SHELL = /usr/bin/qsh
.SHELLFLAGS = -ec

VERSION        := 1.46
COPYRIGHT      := Version $(VERSION). Copyright 2001-2023 Scott C. Klement.
LIBRARY				 ?= LIBHTTP
PKGLIB				 ?= LIBHTTPPKG
TGTRLS         ?= v7r1m0
USE_XML			 	 ?= 1
BUILD_EXAMPLES ?= 1
DEBUG					 ?= 1

ifneq (,$(BUILDLIB))
LIBRARY=$(BUILDLIB)
endif

# Make sure LIBRARY has been set and doesn't have any blanks
ifneq (1,$(words [$(LIBRARY)]))
$(error LIBRARY variable is not set correctly. Set to a valid library name and try again)
endif
ifeq (,$(LIBRARY))
$(error LIBRARY variable is not set correctly. Set to a valid library name and try again)
endif

ILIBRARY      := /qsys.lib/$(LIBRARY).lib
IPKGLIB       := /qsys.lib/$(PKGLIB).lib
RPGINCDIR     := 'src/rpglesrc'
RPGINCDIR     := incdir($(RPGINCDIR))
CINCDIR       := 'src' 'src/expat' 
CINCDIR       := incdir($(CINCDIR))
BNDDIR        :=
C_OPTS				:= localetype(*localeucs2) sysifcopt(*ifsio) define(HAVE_EXPAT_CONFIG_H)
CL_OPTS       :=
RPG_OPTS      := option(*noseclvl)
PGM_OPTS      :=
OWNER         := qpgmr
USRPRF        := *user
BNDSRVPGM			:=
PGM_ACTGRP		:= HTTPAPI
SRVPGM_ACTGRP := *caller

SETLIBLIST    := liblist | grep ' USR' | while read lib type; do liblist -d $$lib; done; liblist -a $(LIBRARY)
TMPSRC        := tmpsrc
ISRCFILE      := $(ILIBRARY)/$(TMPSRC).file
SRCFILE       := srcfile($(LIBRARY)/$(TMPSRC)) srcmbr($(TMPSRC))
SRCFILE2      := $(LIBRARY)/$(TMPSRC)($(TMPSRC))
SRCFILE3      := file($(LIBRARY)/$(TMPSRC)) mbr($(TMPSRC))
PRDLIB        := $(LIBRARY)
TGTCCSID      := *job
DEVELOPER     ?= $(USER)
MAKE          := make
LOGFILE       = $(CURDIR)/tmp/$(@F).txt
OUTPUT        = >$(LOGFILE) 2>&1

# Remove compile listings from previous `make`
$(shell test -d $(CURDIR)/tmp || mkdir $(CURDIR)/tmp; rm $(CURDIR)/tmp/*.txt >/dev/null 2>&1)

#
# Set variables for adding in a debugging view if desired
#

ifeq ($(DEBUG), 1)
	DEBUG_OPTS     := dbgview(*all)
	SQL_DEBUG_OPTS := dbgview(*source)
	CPP_OPTS       := $(CPP_OPTS) output(*print)
else
	DEBUG_OPTS     := dbgview(*none)
	SQL_DEBUG_OPTS := dbgview(*none)
	CPP_OPTS       := $(CPP_OPTS) optimize(40) output(*none)
	RPG_OPTS       := $(RPG_OPTS) optimize(*full)
endif

define EXAMPLES
	EXAMPLE14S.file 
	EXAMPLE1.pgm  EXAMPLE2.pgm  EXAMPLE3.pgm  EXAMPLE4.pgm  EXAMPLE5.pgm  EXAMPLE6.pgm
	EXAMPLE7.pgm  EXAMPLE8.pgm  EXAMPLE9.pgm  EXAMPLE10.pgm EXAMPLE11.pgm EXAMPLE12.pgm	
	EXAMPLE13.pgm EXAMPLE14.pgm EXAMPLE15.pgm EXAMPLE16.pgm EXAMPLE17.pgm EXAMPLE18.pgm	
	EXAMPLE19.pgm EXAMPLE20.pgm EXAMPLE21.pgm EXAMPLE22.pgm EXAMPLE23.pgm EXAMPLE24.pgm	
	EXAMPLE25.pgm
	EXAMPLE40.pgm EXAMPLE41.pgm 
	EXAMPLE9.cmd
endef	
EXAMPLES := $(addprefix $(ILIBRARY)/, $(EXAMPLES))
	
define EXPAT_OBJS
	EXPAT.bnddir EXPAT.srvpgm
endef
EXPAT_OBJS := $(addprefix $(ILIBRARY)/, $(EXPAT_OBJS))

define HTTP_OBJS
	HTTPAPI.bnddir HTTPAPIR4.srvpgm HTTPCMDR4.pgm HTTPQSHR4.pgm
	HTTPAPI.pnlgrp HTTPAPI.cmd INSTALL.pgm
endef	
HTTP_OBJS := $(addprefix $(ILIBRARY)/, $(HTTP_OBJS))

define SRCF_OBJS
	EXPAT.file QCLSRC.file QCMDSRC.file QDDSSRC.file QRPGLESRC.file QSRVSRC.file
endef
SRCF_OBJS := $(addprefix $(ILIBRARY)/, $(SRCF_OBJS))

TARGETS := $(HTTP_OBJS)
SRVPGMS := $(addprefix $(ILIBRARY)/, HTTPAPIR4.srvpgm)
ifeq ($(USE_XML), 1)
	SRVPGMS := $(SRVPGMS) $(addprefix $(ILIBRARY)/, EXPAT.srvpgm)
	TARGETS := $(EXPAT_OBJS) $(TARGETS)
	XML_DEPS := HTTPXMLR4.module EXPAT.srvpgm
else	
	XML_DEPS := XMLSTUBR4.module
endif

NTLM_OBJS := MD4R4.module ENCRYPTR4.module NTLMR4.module

HTTPAPIR4.module_deps := src/rpglesrc/VERSION.rpgleinc
HTTPCMDR4.module_deps := src/rpglesrc/VERSION.rpgleinc
HTTPQSHR4.module_deps := src/rpglesrc/VERSION.rpgleinc 
HTTPQSHR4.pgm_deps		:= $(addprefix $(ILIBRARY)/, HTTPCMDR4.module)
HTTPAPIR4.srvpgm_deps := $(addprefix $(ILIBRARY)/, HTTPAPIR4.module COMPATR4.module COMMTCPR4.module COMMSSLR4.module HTTPUTILR4.module ENCODERR4.module DECODERR4.module CCSIDR4.module HEADERR4.module $(NTLM_OBJS) $(XML_DEPS))
EXPAT.srvpgm_deps     := $(addprefix $(ILIBRARY)/, XMLPARSE.module XMLTOK.module XMLROLE.module)

.PHONY: all clean release

all: examples | $(ILIBRARY) 

http: $(ILIBRARY)/QRPGLESRC.file $(TARGETS)

examples: $(TARGETS) $(EXAMPLES)

clean:
	rm -rf $(ISRCFILE) $(EXAMPLES) $(HTTP_OBJS) $(EXPAT_OBJS) $(ILIBRARY)/*.MODULE
	rm -rf $(SRCF_OBJS) $(IPKGLIB)/HTTPAPI.file build
	rm -f src/rpglesrc/VERSION.rpgleinc src/srvsrc/HTTPAPIR4.bnd 

$(ILIBRARY): | tmp
	-system -v 'crtlib lib($(LIBRARY)) type(*PROD)'
	system -v "chgobjown obj($(LIBRARY)) objtype(*lib) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)) objtype(*lib) user(*public) aut(*use) replace(*yes)"

$(IPKGLIB):
	-system -v 'crtlib lib($(PKGLIB)) type(*PROD)'
	system -v "chgobjown obj($(PKGLIB)) objtype(*lib) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(PKGLIB)) objtype(*lib) user(*public) aut(*use) replace(*yes)"

$(ISRCFILE): | $(ILIBRARY)
	-system -v 'crtsrcpf rcdlen(250) $(SRCFILE3)'

tmp:
	mkdir $(CURDIR)/tmp	

#
#  Specific rules for objects that don't follow the "cookbook" rules, below.
#

src/rpglesrc/VERSION.rpgleinc:
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -f '$(@)'
	touch -C 819 '$(@)'
	echo "     H COPYRIGHT('$(COPYRIGHT) +" >> '$(@)'
	echo "     H All rights reserved. A member called LICENSE was included +" >> '$(@)'
	echo "     H with this distribution and contains important license +" >> '$(@)'
	echo "     H information.')" >> '$(@)') $(OUTPUT)

$(ILIBRARY)/HTTPAPI.bnddir: | $(ILIBRARY)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -rf '$(@)'
	system -v "crtbnddir bnddir($(LIBRARY)/$(basename $(@F)))"
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"
	system -v "addbnddire bnddir($(LIBRARY)/$(basename $(@F))) obj((*libl/httpapir4 *srvpgm) (*libl/expat *srvpgm))") $(OUTPUT)

$(ILIBRARY)/EXPAT.bnddir: | $(ILIBRARY)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -rf '$(@)'
	system -v "crtbnddir bnddir($(LIBRARY)/$(basename $(@F)))"
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"
	system -v "addbnddire bnddir($(LIBRARY)/$(basename $(@F))) obj((*libl/expat *srvpgm))") $(OUTPUT)

$(ILIBRARY)/QRPGLESRC.file: src/rpglesrc/VERSION.rpgleinc | $(ILIBRARY)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -f '$(@)'
	system -v 'crtsrcpf file($(LIBRARY)/$(basename $(@F))) rcdlen(112)'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"
	for MBR in ERRNO_H CONFIG_H HTTPAPI_H IFSIO_H COMM_H EXPAT_H GSKSSL_H HEADER_H HTTPCMD_H MD4_H NTLM_C NTLM_H \
					   NTLM_P PRIVATE_H RDWR_H SOCKET_H VERSION; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(rpgle)"; \
	  cat "src/rpglesrc/$${MBR}.rpgleinc" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	for MBR in CCSIDR4 COMMSSLR4 COMMTCPR4 COMPATR4 CONFIGR4 DECODERR4 ENCODERR4 ENCRYPTR4 \
						 EXAMPLE1 EXAMPLE2 EXAMPLE3 EXAMPLE4 EXAMPLE5 EXAMPLE6 EXAMPLE7 EXAMPLE8 EXAMPLE9 EXAMPLE10 \
						 EXAMPLE11 EXAMPLE12 EXAMPLE14 EXAMPLE15 EXAMPLE16 EXAMPLE17 EXAMPLE18 EXAMPLE19 EXAMPLE20 \
						 EXAMPLE21 EXAMPLE22 EXAMPLE23 EXAMPLE24 EXAMPLE25 EXAMPLE26 EXAMPLE27 \
						 EXAMPLE35 EXAMPLE37 EXAMPLE38 EXAMPLE40 EXAMPLE41 \
						 HEADERR4 HTTPAPIR4 HTTPCMDR4 HTTPQSHR4 HTTPUTILR4 HTTPXMLR4 INSTALLR4 MD4R4 \
						 MSTRINGR4 NTLMR4 XMLSTUBR4; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(rpgle)"; \
	  cat "src/rpglesrc/$${MBR}.rpgle" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	for MBR in EXAMPLE13; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(sqlrpgle)"; \
	  cat "src/rpglesrc/$${MBR}.sqlrpgle" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	for MBR in README; do \
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(txt)"; \
	  cat "$${MBR}.md" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	for MBR in CHANGELOG; do \
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(txt)"; \
	  cat "$${MBR}.txt" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	for MBR in LICENSE; do \
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(txt)"; \
	  cat "src/rpglesrc/$${MBR}.txt" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done) $(OUTPUT)

$(ILIBRARY)/QCLSRC.file: | $(ILIBRARY)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -f '$(@)'
	system -v 'crtsrcpf file($(LIBRARY)/$(basename $(@F))) rcdlen(92)'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"
	for MBR in INSTALL INSTMSGF MKEXPATCL PACKAGE; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(clle)"; \
	  cat "src/clsrc/$${MBR}.clle" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	for MBR in LICENSE; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(txt)"; \
	  cat "src/clsrc/$${MBR}.txt" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done) $(OUTPUT)

$(ILIBRARY)/EXPAT.file: | $(ILIBRARY)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -f '$(@)'
	system -v 'crtsrcpf file($(LIBRARY)/$(basename $(@F))) rcdlen(112)'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"
	for MBR in AMIGACON.H ASCII.H ASCIITAB.H EXPAT.DSP EXPAT.H EXPAT_CO.H EXPAT_EX.H EXPAT_ST.D EXPATW.DSP EXPATW_S.D \
						 IASCIITA.H INTERNAL.H LATIN1TA.H LIBEXPAT.D MACCONFI.H MAKEFILE.M NAMETAB.H UTF8TAB.H WINCONFI.H XMLPARSE.C \
						 XMLROLE.C XMLROLE.H XMLTOK.C XMLTOK.H XMLTOK_I.C XMLTOK_I.H XMLTOK_N.C; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(c)"; \
	  cat "src/expat/$${MBR}" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	for MBR in REF.HTML STYLE.CSS; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(txt)"; \
	  cat "src/expat/$${MBR}" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	for MBR in COPYING; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(txt)"; \
	  cat "src/expat/$${MBR}.txt" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done) $(OUTPUT)
	
$(ILIBRARY)/QCMDSRC.file: | $(ILIBRARY)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -f '$(@)'
	system -v 'crtsrcpf file($(LIBRARY)/$(basename $(@F))) rcdlen(92)'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"
	for MBR in HTTPAPI EXAMPLE9; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(cmd)"; \
	  cat "src/cmdsrc/$${MBR}" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr(HTTPAPIPNL) srctype(pnlgrp)"
	cat "src/pnlsrc/HTTPAPI.pnlgrp" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))(HTTPAPIPNL)") $(OUTPUT)
	
$(ILIBRARY)/QDDSSRC.file: | $(ILIBRARY)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -f '$(@)'
	system -v 'crtsrcpf file($(LIBRARY)/$(basename $(@F))) rcdlen(92)'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"
	for MBR in CONFIGS EXAMPLE14S; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(dspf)"; \
	  cat "src/ddssrc/$${MBR}.dspf" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done) $(OUTPUT)
	
$(ILIBRARY)/QSRVSRC.file: | $(ILIBRARY)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -f '$(@)'
	system -v 'crtsrcpf file($(LIBRARY)/$(basename $(@F))) rcdlen(92)'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"
	for MBR in EXPAT HTTPAPI1 HTTPAPI2; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(bnd)"; \
	  cat "src/srvsrc/$${MBR}.bnd" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done
	for MBR in LICENSE; do
	  system -v "addpfm file($(LIBRARY)/$(basename $(@F))) mbr($${MBR}) srctype(txt)"; \
	  cat "src/srvsrc/$${MBR}.txt" | Rfile -wQ "$(LIBRARY)/$(basename $(@F))($${MBR})"; \
	done) $(OUTPUT)
	
$(ILIBRARY)/HTTPAPI.cmd: src/cmdsrc/HTTPAPI.cmd $(ILIBRARY)/HTTPAPI.pnlgrp $(ILIBRARY)/HTTPCMDR4.pgm | $(ISRCFILE)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	cat '$(<)' | Rfile -wQ '$(SRCFILE2)'
	system -v 'crtcmd cmd($(LIBRARY)/HTTPAPI) $(SRCFILE) pgm(*libl/HTTPCMDR4) hlppnlgrp(HTTPAPI) hlpid(*cmd) prdlib($(PRDLIB))'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)") $(OUTPUT)

src/srvsrc/HTTPAPIR4.bnd:
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -rf '$(@)'
	cp src/srvsrc/HTTPAPI2.bnd '$(@)') $(OUTPUT)

#
#  Standard "cookbook" recipes for building objects
#
$(ILIBRARY)/%.module: src/clsrc/%.clle | $(ISRCFILE) $$($$*.module_files) $$($$*.module_spgms)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	cat '$(<)' | Rfile -wQ '$(SRCFILE2)'
	system -v "crtclmod module($(LIBRARY)/$(*F)) $(SRCFILE) $(CL_OPTS) tgtrls($(TGTRLS)) $(DEBUG_OPTS)") $(OUTPUT)
							
$(ILIBRARY)/%.module: src/expat/%.c $$($$*.module_deps) | $(ILIBRARY)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	system -v "crtcmod module($(LIBRARY)/$(*F)) srcstmf('$(<)') $(CINCDIR) $(C_OPTS) tgtrls($(TGTRLS)) $(DEBUG_OPTS) tgtccsid($(TGTCCSID))") $(OUTPUT)
	
$(ILIBRARY)/%.module: src/rpglesrc/%.rpgle $$($$*.module_deps) | $(ISRCFILE)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	cat '$(<)' | Rfile -wQ '$(SRCFILE2)'
	system -v "crtrpgmod module($(LIBRARY)/$(*F)) $(SRCFILE) $(RPGINCDIR) $(RPG_OPTS) tgtrls($(TGTRLS)) $(DEBUG_OPTS)") $(OUTPUT)
	
$(ILIBRARY)/%.module: src/rpglesrc/%.sqlrpgle $$($$*.module_deps) | $(ISRCFILE)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	cat '$(<)' | Rfile -wQ '$(SRCFILE2)'
	system -v "crtsqlrpgi obj($(LIBRARY)/$(*F)) $(SRCFILE) compileopt('$(subst ','',$(RPGINCDIR)) $(subst ','',$(RPG_OPTS))') $(SQL_OPTS) tgtrls($(TGTRLS)) $(SQL_DEBUG_OPTS) objtype(*module) rpgppopt(*lvl2)") $(OUTPUT)
	
$(ILIBRARY)/%.pnlgrp: src/pnlsrc/%.pnlgrp | $$($$*.pnlgrp_deps) $(ISRCFILE)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	cat '$(<)' | Rfile -wQ '$(SRCFILE2)'
	system -v "crtpnlgrp pnlgrp($(LIBRARY)/$(*F)) $(SRCFILE)"
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)") $(OUTPUT)

$(ILIBRARY)/%.cmd: src/cmdsrc/%.cmd $$($$*.cmd_deps) | $(ISRCFILE)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	cat '$(<)' | Rfile -wQ '$(SRCFILE2)'
	system -v 'crtcmd cmd($(LIBRARY)/$(*F)) $(SRCFILE) pgm(*libl/$(*F)) prdlib($(PRDLIB))'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)") $(OUTPUT)

$(ILIBRARY)/%.pgm: $$($$*.pgm_deps) $(ILIBRARY)/%.module | $(ILIBRARY) $(SRVPGMS)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	system -v 'dltpgm pgm($(LIBRARY)/$(*F))' || true
	system -v 'crtpgm pgm($(LIBRARY)/$(*F)) module($(foreach MODULE, $(notdir $(filter %.module, $(^))), ($(LIBRARY)/$(basename $(MODULE))))) entmod(*pgm) $(PGM_OPTS) actgrp($(PGM_ACTGRP)) tgtrls($(TGTRLS)) bndsrvpgm($(foreach SRVPGM, $(notdir $(filter %.srvpgm, $(|))), ($(basename $(SRVPGM))))) $(BNDDIR) $($(@F)_opts) usrprf($(USRPRF))'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)") $(OUTPUT)
			
$(ILIBRARY)/%.srvpgm: src/srvsrc/%.bnd $$($$*.srvpgm_deps) | $(ISRCFILE)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -rf '$(@)'
	cat '$(<)' | Rfile -wQ '$(SRCFILE2)'
	$(SETLIBLIST)
	system -v 'dltsrvpgm srvpgm($(LIBRARY)/$(*F))' || true
	system -v 'crtsrvpgm srvpgm($(LIBRARY)/$(*F)) module($(foreach MODULE, $(notdir $(filter %.module, $(^))), ($(LIBRARY)/$(basename $(MODULE))))) $(SRCFILE) $(PGM_OPTS) actgrp($(SRVPGM_ACTGRP)) tgtrls($(TGTRLS)) bndsrvpgm($(foreach SRVPGM, $(notdir $(filter %.srvpgm, $(^))), ($(basename $(SRVPGM))))) $($(@F)_opts) $(BNDDIR) usrprf($(USRPRF))'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)") $(OUTPUT)

$(ILIBRARY)/%.file: src/ddssrc/%.dspf | $$($$*.file_deps) $(ISRCFILE)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -rf '$(@)'
	cat '$(<)' | Rfile -wQ '$(SRCFILE2)'
	$(SETLIBLIST)
	system -v 'crtdspf file($(LIBRARY)/$(*F)) $(SRCFILE)'
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)") $(OUTPUT)

$(IPKGLIB)/HTTPAPI.file: all $(SRCF_OBJS) membertext | $(IPKGLIB)
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -rf $(ISRCFILE) $(ILIBRARY)/EVFEVENT.file $(ILIBRARY)/*.MODULE $(ILIBRARY)/MKEXPATCL.pgm
	system -v 'dltf file($(PKGLIB)/HTTPAPI)' || true
	system -v 'crtsavf file($(PKGLIB)/HTTPAPI)'
	system -v 'savlib lib($(LIBRARY)) dev(*savf) savf($(PKGLIB)/HTTPAPI) tgtrls($(TGTRLS)) DTACPR(*HIGH)') $(OUTPUT)

build:
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(rm -rf build
	mkdir build) $(OUTPUT)

membertext: $(SRCF_OBJS) | $(ILIBRARY)
	@$(info Setting member text descriptions)touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	while read FILE MBR TEXT; do \
		system -v "chgpfm file($(LIBRARY)/$${FILE}) mbr($${MBR}) text('$${TEXT}')"; \
	done < scripts/member_text.txt) $(OUTPUT)

build/httpapi.zip: $(SRCF_OBJS) membertext | build
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	(scripts/mkzip.sh "$(LIBRARY)" "$(CURDIR)") $(OUTPUT)

build/httpapi.savf: $(IPKGLIB)/HTTPAPI.file | build
	@$(info Creating $(@))touch -C 1208 $(LOGFILE)
	($(SETLIBLIST)
	system -v " CPYTOSTMF FROMMBR('$(IPKGLIB)/HTTPAPI.file') TOSTMF('build/httpapi.savf') STMFOPT(*REPLACE) CVTDTA(*NONE)") $(OUTPUT)

package: clean build/httpapi.savf build/httpapi.zip