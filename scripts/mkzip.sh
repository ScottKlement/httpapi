#!/usr/bin/env qsh

set -x
INPREF=/qsys.lib/$1.lib
MAKEDIR=$2
OUTPREF=${HOME}/httpapi
eval UPLOAD=/tmp/upload$$.tmp
eval WORKF=/tmp/workf$$.tmp

############################################
# make output dir
############################################

rm -rf ${OUTPREF}
mkdir ${OUTPREF} || exit 1

############################################
# make a list of members to include
#
#  The grep statement includes only files
#  that start with letters 'Q' or 'E'
#  (so we'll get QRPGLESRC, QSRVSRC, EXPAT, etc)
############################################

cd ${INPREF} || exit 1
find . -name '*.MBR' > ${WORKF}

############################################
# copy each member to a stream file
# Note: We use CPYTOSTMF instead of CAT
#       because it trims trailing blanks.
############################################

SRCFILE=""
SRCMBR=""
srctype=""

for FILE in $(cat ${WORKF} | cut -c 3-); do

  INFULL="${INPREF}/${FILE}"
  OUTFULL="${OUTPREF}/${FILE}"
  DIRNAME=$(dirname "${OUTFULL}")
  SRCFILE=${DIRNAME##*/}
  SRCFILE=${SRCFILE%.FILE}
  SRCMBR=${FILE##*/}
  SRCMBR=${SRCMBR%.MBR}

  if [ ! -d "${DIRNAME}" ]; then
    echo "mkdir $DIRNAME"
    mkdir "${DIRNAME}" || exit 1
  fi

  case "$SRCFILE" in
    QRPGLESRC) srctype=RPGLE ;;
    QCLSRC) srctype=CLP ;;
    QDDSSRC) srctype=DSPF ;;
    QSRVSRC) srctype=BND ;;
    QCMDSRC) srctype=CMD ;;
    EXPAT) srctype=C ;;
    *) srctype=TXT ;;
  esac

  case "$SRCMBR" in
    CHANGELOG) srctype=TXT ;;
    README) srctype=TXT ;;
    LICENSE) srctype=TXT ;;
    COPYING) srctype=TXT ;;
    REF.HTML) srctype=HTML ;;
    STYLE.CSS) srctype=CSS ;;
    HTTPAPIPNL) srctype=PNLGRP ;;
    MD4C) srctype=C ;;
    EXAMPLE13) srctype=SQLRPGLE ;;
  esac

  system -vq "CPYTOSTMF FROMMBR('$INFULL') TOSTMF('$OUTFULL') STMFOPT(*REPLACE) STMFCODPAG(819)" || exit 1
  echo "echo put ${FILE} ${SRCFILE}.${SRCMBR} >> %TEMPFILE%" >> $UPLOAD
  echo "echo quote rcmd chgpfm file(%LIB%/$SRCFILE) mbr($SRCMBR) srctype($srctype) >> %TEMPFILE%" >> $UPLOAD

done

############################################
# Zip up results
############################################
cd $OUTPREF
cp $MAKEDIR/scripts/upload1.txt upload.bat
cat $UPLOAD >> upload.bat
cat $MAKEDIR/scripts/upload2.txt >> upload.bat
rm -f $UPLOAD ${WORKF}
# jar Mcvf ../httpapi.zip *
cd ..
rm -f ${MAKEDIR}/build/httpapi.zip
zip -r ${MAKEDIR}/build/httpapi.zip httpapi
