      * EXAMPLE24:  This example demonstrates how to extend the
      *             validity checking of an x.509 certificate.
      *             using the GSKit callback feature (req V5R3+)
      *
      *  Note: This isn't for the feint-of-heart.  For most
      *        the code in EXAMPLE23 will work fine, and be much
      *        easier to implement.
      *
      *        However, this method has the advantage that you can
      *        view the entire certificate chain, including the
      *        CA certificates.
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO)
      /endif
     H BNDDIR('HTTPAPI')

     FQSYSPRT   O    F  132        PRINTER

      /copy httpapi_h
      /copy ifsio_h
      /copy gskssl_h

     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
     D   cmd                      32702a   const options(*varsize)
     D   len                         15p 5 const
     D   igc                          3a   const options(*nopass)

     D cert_val        pr            10i 0
     D   cert_chain                    *   value
     D   status                      10i 0 value

     D LO              c                   const('abcdefghij-
     D                                     klmnopqrstuvwxyz')
     D HI              c                   const('ABCDEFGHIJ-
     D                                     KLMNOPQRSTUVWXYZ')

     D Fields          s             33a   dim(19) ctdata

     D filename        s             50a   varying
     D rc              s             10i 0
     D cmd             s            200a   varying
     D url             s           1000a   varying
     D VerifyCert      ds                  likeds(CertCallback_t)

      /free

        http_debug(*ON);
        https_strict(*OFF);

        VerifyCert.vc_proc     = %paddr(cert_val);
        VerifyCert.vc_valreq   = GSK_NO_VALIDATION;
        VerifyCert.vc_certneed = GSK_CERTIFICATE_CHAIN_SENT_VIA_SSL;

        http_xproc( HTTP_POINT_GSKIT_CERT_VAL
                  : *null
                  : %addr(VerifyCert) );

        //**********************************************************
        // Request that something be downloaded from the SSL server.
        //**********************************************************

        filename = http_tempfile + '.txt';
        url = 'https://www.klements.com/cgi-bin/ssltest';

        rc = http_url_get( url: filename );
        if (rc <> 1);
           http_crash();
        endif;

        //**********************************************************
        // Display the file downloaded from the HTTP server.
        // then delete it & end program.
        //**********************************************************
        cmd = 'DSPF STMF(''' + filename + ''')';
        QCMDEXC(cmd: %len(cmd));
        unlink(filename);
        *inlr = *on;

      /end-free


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cert_val():  This procedure was registered with the GSKit
      *              (IBM-supplied SSL routines in i5/OS) for
      *              certificate validation.
      *
      *              IBM documents this callback in the Information
      *              Center.  Here's a link to the V5R4 docs:
      *                http://publib.boulder.ibm.com/infocenter/iseries
      *                  /v5r4/topic/apis/gsk_attribute_set_callback.htm
      *
      *              In this example, the certificates are extracted,
      *              and parsed using the QsyParseCertificate() API.
      *                http://publib.boulder.ibm.com/infocenter/iseries
      *                  /v5r4/topic/apis/QSYPARSC.htm
      *
      *  cert_chain = (input) ASN.1 DER encoded certificate chain
      *                       in raw, binary format.
      *
      *      status = (input) The result of the GSKit validation
      *                       routine.  It can be set to one of the
      *                       following constants from the GSKSSL_H
      *                       copy book:
      *
      *           GSK_VALIDATION_SUCCESSFUL
      *           GSK_IBMI_ERROR_NOT_TRUSTED_ROOT
      *           GSK_KEYFILE_CERT_EXPIRED
      *
      *  This procedure should return GSK_OK if cert is acceptable
      *  or GSK_ERROR_CERT_VALIDATION if unacceptable
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cert_val        B
     D cert_val        pi            10i 0
     D   cert_chain                    *   value
     D   status                      10i 0 value

     D DER_SEQUENCE    C                   x'30'
     D DER_LONGFORM    C                   x'80'
     D DER_BIN_X509    c                   1

     D QsyParseCertificate...
     D                 PR                  extproc('QsyParseCertificate')
     D  certificate                    *   value
     D  type                         10i 0 value
     D  length                       10i 0 value
     D  format                         *   value options(*string)
     D  rcvvar                    65535a   options(*varsize)
     D  rcvvarlen                    10i 0 value
     D  ErrorCode                 32767a   options(*varsize)

     D CERT0200        DS         65535    qualified
     D   len_rtn                     10i 0
     D   len_avail                   10i 0

     D ErrorCode       ds                  qualified
     D   bytes_prov                  10i 0 inz(0)
     D   bytes_avail                 10i 0 inz(0)

     D                 ds
     D  len                          10u 0
     D  bytes                         1a   dim(4) overlay(len)

     D data            s          65535a   based(p_data)
     D cn              s           1000a   varying
     D byte            s              1a   based(p_byte)
     D pos             s             10i 0
     D num_bytes       s              3u 0
     D cert            s               *
     D x               s             10i 0
     D certno          s             10i 0
     D offset          s             10i 0 based(p_offset)
     D dtalen          s             10i 0 based(p_dtalen)

     D printme         ds           132    qualified
     D   certno                       2a
     D   field                       25a
     D                                1a
     D   data                        94a

      /free

         pos    = 1;
         p_byte = cert_chain;
         certno = 0;

         dow byte = DER_SEQUENCE;

            cert = p_byte;

            // ------------------------------------------------
            //  follow DER rules to extract the length of the
            //  DER sequence object.  This outermost sequence
            //  object represents the whole certificate.
            // ------------------------------------------------
            pos += 1;
            p_byte += 1;

            if %bitand(byte:DER_LONGFORM) = x'00';
                len = 0;
                bytes(4) = byte;
                len += pos;
            else;
                len = 0;
                bytes(4) = %bitxor( byte: DER_LONGFORM );
                num_bytes = len;
                len = 0;

                if (num_bytes<1 or num_bytes>4);
                   // this shouldn't happen on a valid certificate...
                   // DER rules forbid num_bytes to be zero
                   // and no certificate should be > 4gb.
                   return GSK_ERROR_CERT_VALIDATION;
                endif;

                for x = num_bytes downto 1;
                   pos += 1;
                   p_byte += 1;
                   bytes(5 - x) = byte;
                endfor;

                len += pos;
            endif;

            // ------------------------------------------------
            //   At this point, cert should point to the start
            //   of a certificate, and len should represent
            //   the length of that certificate.
            // ------------------------------------------------

            certno += 1;
            QsyParseCertificate( cert
                               : DER_BIN_X509
                               : len
                               : 'CERT0200'
                               : CERT0200
                               : %size(CERT0200)
                               : ErrorCode );

            for x = 1 to %elem(fields);
                p_offset = %addr(CERT0200)
                         + %int(%subst(fields(x):26:4));
                p_dtalen = %addr(CERT0200)
                         + %int(%subst(fields(x):30:4));
                if (offset>0 and dtalen>0);
                    p_data = %addr(CERT0200) + offset;
                    printme.certno = %char(certno);
                    printme.field  = %subst(fields(x):1:25);
                    printme.data   = %subst(data:1:dtalen);
                    write QSYSPRT printme;
                endif;
            endfor;

            p_byte = cert + len;
         enddo;

         return GSK_OK;
      /end-free
     P                 E
**
Serial                     24  28
Issuer Common Name         32  36
Issuer Country/Region      40  44
Issuer State/Province      48  52
Issuer Locality            56  60
Issuer Organization        64  68
Issuer Org Unit            72  76
Issuer Postal Code         80  84
Issuer Valid From          88  92
Issuer Valid To            96 100
Subject Common Name       104 108
Subject Country/Region    112 116
Subject State/Province    120 124
Subject Locality          128 132
Subject Organization      136 140
Subject Org Unit          144 148
Subject Postal Code       152 156
Issuer E-mail             184 188
Subject E-mail            192 196
