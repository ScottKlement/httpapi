/*-                                                                            +
 * Copyright (c) 2008-2024 Scott C. Klement                                    +
 * All rights reserved.                                                        +
 *                                                                             +
 * Redistribution and use in source and binary forms, with or without          +
 * modification, are permitted provided that the following conditions          +
 * are met:                                                                    +
 * 1. Redistributions of source code must retain the above copyright           +
 *    notice, this list of conditions and the following disclaimer.            +
 * 2. Redistributions in binary form must reproduce the above copyright        +
 *    notice, this list of conditions and the following disclaimer in the      +
 *    documentation and/or other materials provided with the distribution.     +
 *                                                                             +
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ''AS IS'' AND      +
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
 * SUCH DAMAGE.                                                                +
 *                                                                             +
 */                                                                            +

 /*   TO COMPILE MANUALLY:                                    */
 /*>             CRTPNLGRP  PNLGRP(&O/HTTPAPI) -             <*/
 /*>                          SRCFILE(&L/QCMDSRC) -          <*/
 /*>                          SRCMBR(HTTPAPIPNL)             <*/

 /*>            CRTCMD     CMD(&O/HTTPAPI) -                 <*/
 /*>                         PGM(&O/HTTPCMDR4) -             <*/
 /*>                         SRCFILE(&L/QCMDSRC) -           <*/
 /*>                         PRDLIB(LIBHTTP) -               <*/
 /*>                         HLPPNLGRP(&O/HTTPAPI) -         <*/
 /*>                         HLPID(*CMD)                     <*/

CMD PROMPT('HTTPAPI CL Interface')

PARM KWD(URL) TYPE(*CHAR) LEN(32767) VARY(*YES) EXPR(*YES) +
     MIN(1) +
     CHOICE('URL') CASE(*MIXED) INLPMTLEN(80) +
     PROMPT('HTTP URL (i.e. "web address")')

PARM KWD(DOWNLOAD) TYPE(*PNAME) LEN(256) VARY(*YES) EXPR(*YES) +
     DFT(*BASENAME) SPCVAL((*BASENAME)) +
     INLPMTLEN(80) +
     PROMPT('Stream file to save result to')

PARM KWD(REQTYPE) TYPE(*CHAR) LEN(5) EXPR(*YES) +
     RSTD(*YES) DFT(*GET) SPCVAL((*GET) (*POST)) +
     PROMPT('Request type')

PARM KWD(UPLOAD) TYPE(*PNAME) LEN(256) VARY(*YES) EXPR(*YES) +
     DFT(*NONE) SPCVAL((*NONE)) INLPMTLEN(80) +
     PROMPT('Stream file with POST data')

PARM KWD(TYPE) TYPE(*CHAR) LEN(64) VARY(*YES) EXPR(*YES) +
     DFT('text/xml') INLPMTLEN(50) +
     PROMPT('Content-Type of POST data')

PARM KWD(USER) TYPE(*CHAR) LEN(80) VARY(*YES) EXPR(*YES) +
     DFT(*NONE) SPCVAL((*NONE)) INLPMTLEN(12) CASE(*MIXED) +
     PROMPT('User ID')

PARM KWD(PASS) TYPE(*CHAR) LEN(1024) VARY(*YES) EXPR(*YES) +
     DFT(*NONE) SPCVAL((*NONE)) INLPMTLEN(12) CASE(*MIXED) +
     PROMPT('Password')

PARM KWD(REDIRECT) TYPE(*CHAR) LEN(4) EXPR(*YES) +
     RSTD(*YES) DFT(*YES) SPCVAL((*YES) (*NO)) +
     PROMPT('Follow redirects?')

PARM KWD(PROXY) TYPE(*CHAR) LEN(256) VARY(*YES) EXPR(*YES) +
     DFT(*NONE) SPCVAL((*NONE)) INLPMTLEN(50) CASE(*MIXED) +
     PROMPT('Proxy hostname')

PARM KWD(PROXYUSER) TYPE(*CHAR) LEN(80) VARY(*YES) EXPR(*YES) +
     DFT(*NONE) SPCVAL((*NONE)) INLPMTLEN(12) CASE(*MIXED) +
     PROMPT('Proxy User ID')

PARM KWD(PROXYPASS) TYPE(*CHAR) LEN(1024) VARY(*YES) EXPR(*YES) +
     DFT(*NONE) SPCVAL((*NONE)) INLPMTLEN(12) CASE(*MIXED) +
     PROMPT('Proxy Password')

PARM KWD(DEBUG) TYPE(*PNAME) LEN(256) VARY(*YES) EXPR(*YES) +
     DFT(*NONE) SPCVAL((*NONE)) INLPMTLEN(80) +
     PROMPT('Stream file for HTTP debug')

PARM KWD(SSLID) TYPE(*CHAR) LEN(100) VARY(*YES) EXPR(*YES) +
     DFT(*DFT) SPCVAL((*DFT)) INLPMTLEN(12) +
     PROMPT('SSL application ID')

PARM KWD(COOKIES) TYPE(*PNAME) LEN(256) VARY(*YES) EXPR(*YES) +
     DFT(*NONE) SPCVAL((*NONE)) INLPMTLEN(80) +
     PROMPT('Stream file to keep cookies')

PARM KWD(SESSCOOK) TYPE(*CHAR) LEN(4) +
     RSTD(*YES) CONSTANT(*NO) SPCVAL((*NO))
