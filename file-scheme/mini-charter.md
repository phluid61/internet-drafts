**[draft-ietf-appsawg-file-scheme]**

The "file" URI scheme is woefully out of date. The document that defines
it, [RFC 1738][RFC1738], has been superseded by the generic URI syntax
of [RFC 3986][RFC3986], and the status of [RFC 1738][RFC1738] is listed
as "Obsolete". As such, the "file" URI scheme is viewed by many in the
internet community as being without a current defining standard, and in
need of updating to match current standards and implementations.

This document defines an updated "file" URI scheme, promoting
interoperability by being compatible with the generic syntax of
[RFC 3986][RFC3986], while enumerating commonly-encountered variations
that have arisen during the scheme's long history of vague
standardisation.

Specifically:

1.  A normative syntax specification that defines a subset of
    [RFC 3986][RFC3986] URI syntax that will be considered valid "file"
    URI strings, and sufficient to cover common "file" URI usage in the
    wild where it does not conflict with [RFC 3986][RFC3986].

2.  An informative section describing common syntaxes that are not
    compatible with [RFC 3986][RFC3986], possibly with advice for
    translating to a compatible syntax.

3.  An informative section that describes some common "file" URI usages
    and how they map onto underlying file systems.

Reviewers:

* Julian Reschke <[julian.reschke@gmx.de](mailto:julian.reschke@gmx.de)>
* Nico Williams <[nico@cryptonector.com](mailto:nico@cryptonector.com)>
* Sean Leonard <[dev+ietf@seantek.com](mailto:dev+ietf@seantek.com)>

[draft-ietf-appsawg-file-scheme]: https://tools.ietf.org/html/draft-ietf-appsawg-file-scheme
[RFC1738]: https://tools.ietf.org/html/rfc1738
[RFC3986]: https://tools.ietf.org/html/rfc3986

