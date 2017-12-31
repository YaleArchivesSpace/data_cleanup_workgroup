def check_url(u, n):
    """Check url u. Return retrieved URL and HTTP response code.
    Try to connect for 30 seconds. Retry n times after 5 seconds."""
    from urllib2 import urlopen, HTTPError, URLError
    from ssl import CertificateError, SSLError
    import socket, time
    while n > 0:
        try:
            r = urlopen(u, timeout = 30)
            r.close()
            return (r.geturl(), r.getcode())
        except HTTPError as e:
            return ('', e.code)
        except (CertificateError, SSLError) as e:
            return ('', str(e))
        except (URLError, socket.timeout, socket.error) as e:
            if n > 1:
                time.sleep(5)
                n = n - 1
            else:
                return ('', str(e))
