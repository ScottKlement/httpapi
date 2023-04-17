      * EXAMPLE23:  This example demonstrates how to extend the
      *             validity checking of an x.509 certificate.
      *             (sometimes called an "SSL certificate" or "TLS
      *              certificate.")
      *
      *  This demonstrates two ways of adding checking:
      *
      *       https_strict(): tells HTTPAPI to enable/disable
      *                       strict checking of a certificate.
      *
      *       HTTP_POINT_CERT_VAL; is an exit point that provides
      *                        a way to write your own code to
      *                        validate certificate fields.
      *
      *  Note: Although the two techniques are used together in
      *        this sample program, they are only loosely related
      *        to one another.  They can be used independently as
      *        needed.
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO)
      /endif
     H BNDDIR('HTTPAPI')

      /copy httpapi_h
      /copy ifsio_h
      /copy gskssl_h

     D QCMDEXC         PR                  ExtPgm('QCMDEXC')
     D   cmd                      32702a   const options(*varsize)
     D   len                         15p 5 const
     D   igc                          3a   const options(*nopass)

     D cert_val        pr            10i 0
     D   usrdta                        *   value
     D   id                          10i 0 value
     D   data                     32767a   varying const
     D   errmsg                      80a

     D LO              c                   const('abcdefghij-
     D                                     klmnopqrstuvwxyz')
     D HI              c                   const('ABCDEFGHIJ-
     D                                     KLMNOPQRSTUVWXYZ')

     D filename        s             50a   varying
     D rc              s             10i 0
     D cmd             s            200a   varying
     D url             s           1000a   varying

     D service         s             32a
     D userid          s             32a
     D pass            s             32a
     D host            s            256a
     D port            s             10i 0
     D path            s          32767a   varying

     c                   callp     http_debug(*ON)


      **************************************************************
      * By default, HTTPAPI instructs i5/OS to ignore any SSL
      *    errors related to untrusted root certs, or expired
      *    certificates, as long as they contain enough information
      *    to enable encryption.
      *
      * The https_strict() API can turn "strict checking" on or off.
      *
      * When on, i5/OS will only allow root certificates that are
      * registered as "trusted" in the DCM.  It will also only
      * allow certificates that are not expired.
      **************************************************************
     c                   callp     https_strict(*ON)

      **************************************************************
      * In addition, we'd like to verify that the "common name" in
      * the server's SSL certificate matches the host name that
      * was supplied in the URL.
      *
      * In the following example, the URL points to a host named
      * "www.klements.com".  The HTTP_long_ParseURL() API will be
      * used to extract this hostname from the rest of the URL.
      *
      * The XLATE op-code is used to convert the hostname to
      * uppercase so we don't have to worry about case sensitivity
      * (e.g., it doesn't matter if the URL says "www.klements.com"
      *  but the certificate says "WwW.kLeMenTs.CoM" because both
      *  are converted to all uppercase.)
      **************************************************************
     c                   eval      url = 'https://www.klements.com/+
     c                                    cgi-bin/ssltest'

     c                   callp     http_long_parseURL( url
     c                                               : service
     c                                               : userid
     c                                               : pass
     c                                               : host
     c                                               : port
     c                                               : path )

     C     LO:HI         xlate     host          host

      **************************************************************
      * http_xproc() registers an "exit procedure"... that is a
      *              procedure that HTTPAPI calls during it's
      *              processing.
      *
      *              In this case, our "cert_val" procedure should
      *              be called at the point where HTTPAPI is
      *              validating a certificate.
      *
      *              We'll use the cert_val() subprocedure to
      *              verify that the common name of the certificate
      *              matches the host in the URL
      **************************************************************
     c                   callp     http_xproc( HTTP_POINT_CERT_VAL
     c                                       : %paddr(cert_val) )

      **************************************************************
      *  Request that something be downloaded from the SSL server.
      *
      *  Note: the xproc above will work with all of the
      *        APIs that access a URL (both post & get)
      *        I used get in this sample program just to provide
      *        a simple example -- if you need to use it with
      *        something more complex like http_url_post_xml(),
      *        feel free -- it will work the same way.
      **************************************************************
     c                   eval      filename = http_tempfile + '.txt'

     C                   eval      rc = http_url_get( url: filename)
     c                   if        rc <> 1
     c                   callp     http_crash
     c                   endif

      **************************************************************
      * Display the file downloaded from the HTTP server.
      * then delete it & end program.
      **************************************************************
     c                   eval      cmd = 'DSPF STMF(''' + filename + ''')'
     c                   callp(e)  QCMDEXC(cmd: %len(cmd))

     c                   callp     unlink(filename)
     c                   eval      *inlr = *on


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * cert_val():  This procedure was registered (via http_xproc)
      *              so that HTTPAPI will call it when it's time to
      *              validate a certificate.
      *
      *              HTTPAPI will call this procedure in a loop for
      *              every field in the x.509 partner certificate.
      *
      *      usrdta = (input) this lets you pass your own data
      *                       to/from the certificate validation
      *                       routine.  This can be anything...
      *
      *          id = (input) certificate field identifier.
      *                       this corresponds to a CERT_xxx constant
      *                       in the GSKSSL_H copybook. l
      *
      *        data = (input) data contained in the certificate field
      *
      *      errmsg = (output) error message to report if the certificate
      *                        data is not accepted by this procedure.
      *
      *  This procedure should return 0 if the certificate field is
      *  acceptable, or -1 if it is not.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P cert_val        B
     D cert_val        pi            10i 0
     D   usrdta                        *   value
     D   id                          10i 0 value
     D   data                     32767a   varying const
     D   errmsg                      80a

     D cn              s            256a

      * In this example, we want to make sure the common name of
      *  the certificate matches the hostname in the URL.
      *
      * So if the id is set to CERT_COMMON_NAME, we make sure
      * they match.
      *
      * for any other certificate field, 0 is returned to indicate
      * that the value is okay -- this way, we can ignore all of
      * the other fields in the certificate.
      *
     c                   if        id = CERT_COMMON_NAME
     c                   eval      cn = %xlate(LO:HI:data)
     c                   if        cn <> host
     c                   eval      errmsg = 'Certificate is for a +
     c                                      different web site!'
     c                   return    -1
     c                   endif
     c                   endif

     c                   return    0
     P                 E
