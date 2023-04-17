      * THE STORY SO FAR:
      * -----------------
      *  EXAMPLE1 showed the basics of downloading a file with HTTP
      *  EXAMPLE2 showed how to use some of the more advanced
      *            parameters related to downloading a file.
      *  EXAMPLE3 showed how you can use SSL/TLS to protect your
      *            HTTP data transferred with HTTPAPI
      *  EXAMPLE4 showed how to encode data like a browser would,
      *            how to POST data to a web site, and how to
      *            handle a "redirect" message from the site.
      *
      * EXAMPLE5:
      * ----------
      *  Some web sites aren't available to the public.  They ask
      *  you for a userid/password in order to view their content.
      *  This is especially common with Intranets and Extranets.
      *
      *  Now, there are several ways to ask a user for a userid/password.
      *  One way is to display a form in a browser where you'd fill in
      *  the username and password, and that would work exactly as
      *  the code in the previous member (EXAMPLE4) demonstrated.
      *  However, sometimes the userid/password is not part of the form
      *  data on the screen, but is requested separately by the browser.
      *  This example (EXAMPLE5) demonstrates how to handle that data
      *  with HTTPAPI.
      *
      *  Under the covers, this is handled by the www-authenticate
      *  HTTP keyword. HTTPAPI supports two different methods of
      *  doing this type of authentication, they are the "basic"
      *  (clear text) method and the "digest" (encrypted) method.
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP(*NEW)
      /endif
     H BNDDIR('HTTPAPI')

      * This is an example of how your application detects that
      * a userid/password is required for a web site.  It can then
      * ask the user for userid/password and try again.
      *
      * Note: This method supports both Basic & Digest authentication
      *
      *  NOTE:  UserId = testuser
      *       Password = testpass
      *

     D/copy httpapi_h

     D cmd             pr                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     D rc              S             10I 0
     D err             S             10I 0
     D basic           S              1N
     D digest          S              1N
     D realm           S            124A
     D userid          S             50A
     D pass            S             50A
     D URL             s            256A
     D msg             S             50A

     c                   eval      *inlr = *on

      ** EXAMPLE:
      **   This document requires you to sign in with
      **   user=testuser, password=testpass
      **
     c                   eval      URL = 'http://www.scottklement.com' +
     c                                   '/locked/index.html'

      * If you try to retrieve this URL, and you haven't provided a
      * valid userid/password, HTTPAPI will return a -1, and will
      * set it's error code to HTTP_NDAUTH.
      *
      * If that happens, we do the getpasswd subroutine, which asks
      * for a userid/password.
      *
     c                   dou       rc = 1

     c                   eval      rc = http_url_get( URL
     c                                              : '/tmp/testauth.html')

     c                   if        rc <> 1
     c                   callp     http_error(err)
     c                   if        err <> HTTP_NDAUTH
     c                   callp     http_crash
     c                   return
     c                   endif
     c                   exsr      getpasswd
     c                   endif

     c                   enddo

     c                   callp     cmd('DSPF ''/tmp/testauth.html''': 200)

      *-------------------------------------------------------------
      * this is called when the web server requests a userid/passwd
      *
      * http_getauth(): gets information about the request.
      *     "realm" is a string that the browser would normally
      *        show to the user to tell them what they're logging
      *        into.  It might say "Acme's web server" so the user
      *        knows he/she is logging into that server.
      *     "digest" is an indicator specifying whether digest
      *        authentication is allowed or not.
      *     "basic" is an indicator specifying whether basic
      *        authentication is allowed or not.
      *
      *  http_setauth() sets the authentication type (digesst or basic)
      *      as well as the actual userid/password that will be sent
      *      for future http requests.
      *
      * BASIC authentication sends your userid and password over
      * the Internet. I recommend only using this if your session
      * is SSL-encrypted. Without SSL, this password is sent over
      * the Internet unencrypted, and therefore can be intercepted
      * by a miscreant.
      *
      * Note that if you know in advance that you'll need basic
      * authentication, it's possible to set the userid and
      * password by calling http_setauth prior to the http_url_get
      * routine above.
      *
      * In my experience, 99% of the sites that require this sort
      * of userid/password use basic authentication.
      *
      * DIGEST authentication is encrypted, and is safe to use in
      * unencrypted transactions.
      *
      * Digest authentication will only work AFTER http_url_get
      * has failed, and returned HTTP_NDAUTH. This is because there
      * are some encryption parameters that are set by the HTTP
      * server when the first request fails, and HTTPAPI needs that
      * information to encrypt the userid/password that it sends
      * back.
      *
      * If both types of encryption are allowed, it makes sense
      * to use Digest, because it's more secure. However, I have
      * found that Digest authentication is rarely used on the web.
      *
      * HTTPAPI does not (currently) support other authetnication
      * methods such as NTLM/NTLMv2 (which is a Microsoft technique
      * that was not developed by the open standards committees that
      * created the HTTP protocol.)
      *-------------------------------------------------------------
     csr   getpasswd     begsr

     c                   eval      rc = http_getauth(basic: digest: realm)
     c                   if        rc < 0
     c                   eval      msg = HTTP_ERROR
     c                   dsply                   msg
     c                   return
     c                   endif

     c                   eval      userid = 'enter userid for ' + realm
     c                   dsply                   userid

     c                   eval      pass = 'enter passwd for ' + realm
     c                   dsply                   pass

     c                   if        Digest
     c                   callp     http_setauth(HTTP_AUTH_MD5_DIGEST:
     c                                          userid: pass)
     c                   else
     c                   callp     http_setauth(HTTP_AUTH_BASIC:
     c                                          userid: pass)
     c                   endif

     csr                 endsr
