---
title: The file URI Scheme
abbrev: file-scheme
docname: draft-kerwin-file-scheme-12
date: 2014
category: std

ipr: trust200902
area: General
workgroup: Independent Submission
keyword: Internet-Draft

#updates: 3986
obsoletes: 1738

stand_alone: yes #_
pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
-
    ins: M. Kerwin
    name: Matthew Kerwin
    organization: QUT
    email: matthew.kerwin@qut.edu.au

normative:
  RFC1035:
  RFC1123:
  RFC2119:
  RFC3986:
  RFC3987:
  RFC4291:
  RFC5234:
  RFC6874:
  MS-DTYP:
    title: Windows Data Types, 2.2.56 UNC
    author:
    - organization: Microsoft Open Specifications
      #url: http://www.microsoft.com/openspecifications/en/us/default.aspx
    date: 2013-01
    target: http://msdn.microsoft.com/en-us/library/gg465305.aspx
  MS-NBTE:
    title: NetBIOS over TCP (NBT) Extensions
    author:
    - organization: Microsoft Open Specifications
      #url: http://www.microsoft.com/openspecifications/en/us/default.aspx
    date: 2014-05
    target: http://msdn.microsoft.com/en-us/library/dd891412.aspx
  ISO10646:
    title: Information Technology - Universal Multiple-Octet Coded Character Set (UCS)
    author:
    - organization: International Organization for Standardization
    date: 2003-12
    seriesinfo:
      ISO/IEC: 10646:2003
  UTR15:
    title: Unicode Normalization Forms
    author:
    - ins: M. Davis
      name: Mark Davis
      #email: markdavis@google.com
    - ins: K. Whistler
      name: Ken Whistler
      #email: ken@unicode.org
    date: 2012-08-31

informative:
  STD63:
    title: UTF-8, a transformation format of ISO 10646
    author:
    - ins: F. Yergeau
      name: F. Yergeau
    date: 2003-11
    seriesinfo:
      STD: 63
      RFC: 3629
  RFC1630:
  RFC1738:
  RFC3530:
  RFC4395:
  I-D.draft-hoffman-file-uri:
  IANA-URI-Schemes:
    title: Uniform Resource Identifier (URI) Schemes registry
    author:
    - organization: Internet Assigned Numbers Authority
    date: 2013-06
    target: http://www.iana.org/assignments/uri-schemes/uri-schemes.xml
  WHATWG-URL:
    title: URL Living Standard
    author:
    - organization: WHATWG
      #url: http://www.whatwg.org/
    date: 2013-05
    target: http://url.spec.whatwg.org/
  MS-SMB:
    title: Server Message Block (SMB) Protocol
    author:
    - organization: Microsoft Open Specifications
      #url: http://www.microsoft.com/openspecifications/en/us/default.aspx
    date: 2013-01
    target: http://msdn.microsoft.com/en-us/library/cc246231.aspx
  NOVELL:
    title: NetWare Core Protocols
    author:
    - organization: Novell
      #url: http://www.novell.com/
    date: 2013
    target: http://www.novell.com/developer/ndk/netware_core_protocols.html
  POSIX:
    title: IEEE Std 1003.1, 2013 Edition
    #abbrev: POSIX.1-2008
    author:
    - organization: IEEE
    date: 2013
  Win32-Namespaces:
    title: Naming Files, Paths, and Namespaces
    author:
    - organization: Microsoft Developer Network
    date: 2013-06


--- abstract

This document specifies the file Uniform Resource Identifier (URI)
scheme, replacing the definition in RFC 1738.

**Note to Readers (To be removed by the RFC Editor)**

This draft should be discussed on its github project page
<https://github.com/phluid61/internet-drafts/>.

--- middle

# Introduction

A file URI identifies a file on a particular file system.  It can be
used in discussions about the file, and if other conditions are met it
can be dereferenced to directly access the file.

The file URI scheme is not coupled with a specific protocol. As such,
there is no well-defined set of methods that can be performed on file
URIs, nor a media type associated with them.


## History {#history}

The file URI scheme was first defined in {{RFC1630}}, which, being an
informational RFC, does not specify an Internet standard.  The
definition was standardised in {{RFC1738}}, and the scheme was
registered with the Internet Assigned Numbers Authority (IANA)
{{IANA-URI-Schemes}}; however that definition omitted certain
language included by former that clarified aspects such as:

* the use of slashes to denote boundaries between directory
  levels of a hierarchical file system; and
* the requirement that client software convert the file URI
  into a file name in the local file name conventions.

The Internet draft {{I-D.draft-hoffman-file-uri}} was written in an
effort to keep the file URI scheme on standards track when {{RFC1738}}
was made obsolete, but that draft expired in 2005.  It enumerated
concerns arising from the various, often conflicting implementations
of the scheme.  It serves as the spiritual predecessor of this document.

Additionally the WHATWG defines a living URL standard {{WHATWG-URL}},
which includes algorithms for interpreting file URIs (as URLs).


## UNC

The Universal Naming Convention (UNC) {{MS-DTYP}} defines a string
format that can perform a similar role in describing the location of
files. This UNC filespace selector string has three parts: host,
share, and path. This document describes a means of translating
between UNC filespace selector strings and file URIs.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.


## Idealism vs Pragmatism vs History

Because the file URI scheme has a long history of loosely-defined
standardisation and divergent implementations, this document will
inevitably make some assertions that go against some implementers'
expectations. We will attempt to label all assertions as either
"ideal" preferred behaviour or practical behaviour to support
compatibility and interoperability, and in all cases we will attempt to
describe the difference between this and any previous specifications.


# Syntax {#syntax}

The file URI syntax is defined here in Augmented Backus-Naur Form (ABNF)
{{RFC5234}}, including the core ABNF syntax rule `ALPHA` defined by that
specification, and importing the `userinfo`, `host`, `path-absolute`,
and `query` rules from {{RFC3986}} (as updated by {{RFC6874}}.)

~~~~~~~~~~
   file-URI       = f-scheme ":" f-hier-part [ "?" query ]

   f-scheme       = "file"

   f-hier-part    = "//" auth-path
                  / local-path

   auth-path      = [ f-auth ] path-absolute
                  / unc-path
                  / windows-path

   f-auth         = [ userinfo "@" ] host

   local-path     = path-absolute
                  / windows-path

   unc-path       = 2\*3"/" authority path-absolute

   windows-path   = drive-letter path-absolute
   drive-letter   = ALPHA [ drive-marker ]
   drive-marker   = ":" / "|"
~~~~~~~~~~

Note well: the `drive-marker` rule intentionally includes a bar
character "|" even though that character is not part of either the
unreserved or reserved character sets in {{RFC3986}}, and thus would
normally have to be percent-encoded to be included in a URI. This
specification explicitly supports parsing of otherwise invalid URIs --
with an unencoded bar character forming part of a DOS or Windows drive
letter identifier -- for parsing extant historical URIs, but new URIs of
this form MUST NOT be generated.

The query field contains non-hierarchical data that, along with
data in the path components (path-absolute, unc-path, or windows-path)
serves to identify a resource. This is not commonly used in practice,
but could be used to refer to a specific version of a file in a
versioning file system, for example.

Systems exhibit different levels of case-sensitivity. Unless the file
system is known to be case-insensitive, implementations MUST maintain
the case of file and directory names when translating file URIs to and
from the local system's representation of file paths, and any systems or
devices that transport file URIs MUST NOT alter the case of file URIs
they transport.

The syntax definition above is necessarily different from those given in
{{RFC1630}} and {{RFC1738}} because it depends on the generic syntax
from {{RFC3986}} that post-dates all previous specifications.

It is intended to support file URIs that take the following forms:

Local files:

* `file:///path/to/file`

   > A "traditional" file URI for a local file, with an empty
     authority. This is the most common format in use today, despite
     being technically incompatible with the definition in {{RFC1738}}.

* `file:///c:/path/to/file`

   > The traditional representation of a local file in a DOS- or
     Windows-based environment.

* `file:/path/to/file`

   > The ideal representation of a local file in a UNIX-like
     environment, with no authority field and an absolute path
     that begins with a slash "/".

* `file:c:/path/to/file`

   > The ideal representation of a local file in a DOS- or
     Windows-based environment, with no authority field and an
     absolute path that begins with a drive letter.

* `file:///c/path/to/file`
* `file:/c/path/to/file`
* `file:c/path/to/file`

   > Representations of a local file in a DOS- or Windows-based
     environment, using alternative representations of drive letters.
     These are supported for compatibility with historical
     implementationsm, but deprecated by this specification.

* `file:/c:/path/to/file`

   > A representation of a local file in a DOS- or Windows-based
     environment, with no authority field and a slash preceding
     the drive letter. This representation is less common than those
     above, and is deprecated by this specification.

Non-local files:

* `file://host.example.com/path/to/file`

   > The ideal representation of a non-local file, with an explicit
     authority.

* `file:////host.example.com/path/to/file`

   > The "traditional" representation of a non-local file, with an
     empty authority and a complete (transformed) UNC string in the
     path. This encoding is commonly implemented, but the ideal
     representation above is preferred by this specification.

* `file://///host.example.com/path/to/file`

   > As above, with an extra slash between the empty authority and the
     transformed UNC string, conformant with the definition from
     {{RFC1738}}. This representation is deprecated by this
     specification. It is notably used by the Firefox web browser.

Dubious encodings:

* `file://c:/path/to/file`
* `file://c/path/to/file`

   > A dubious encoding that includes a Windows drive letter as the
     authority field. This encoding exists in some extant
     implementations, and is supported by the grammar for historical
     reasons.

* `file:///c|/path/to/file`
* `file://c|/path/to/file`
* `file:/c|/path/to/file`
* `file:c|/path/to/file`

   > Various otherwise-invalid URIs that include a disallowed bar
     character "|" in the drive letter. These encodings are supported
     by the grammar for historical reasons.

It also intentionally excludes URIs of the form:

* `file://auth.example.com//host.example.com/path/to/file`

   > An encoding that includes both a non-local authority, and a UNC
     string. The traditional implication is that the shared object
     described by the UNC string may only be accessed from the machine
     `auth.example.com`.


# Methods on file URIs

In the strictest terms, the only operations that can be performed on a
file URI are translating it to and from a file path; subsequent methods
are performed on the resulting file path, and depend entirely on the
file system's APIs.

For example, consider the POSIX `open()`, `read()`, and `close()`
methods {{POSIX}} for reading a file's contents into memory.

The local file system API can only be used if the file URI has a blank
(or absent) authority and the path, when transformed to the local
system's conventions, is not a UNC string. Note that this differs from
the definition in {{RFC1738}} in that previously an authority containing
the text "localhost" was used to refer to the local file system, but in
this specification it translates to a UNC string referring to the host
"localhost".

This specification does not define a mechanism for accessing files
stored on non-local file systems.


## Translating Local File Path to file URI

Below is an algorithmic description of the process used to convert a
file path to an Internationalized Resource Identifier (IRI) 
{{RFC3987}}, which can then be translated to a URI as per Section 3.1
of {{RFC3987}} (see: {{encoding}}).

1.  Resolve the file path to its fully qualified absolute form.

2.  Initialise the URI with the "file:" scheme identifier.

3.  If including an empty authority field, append the "//" sigil to
    the URI.

4.  Append the root directory:

    *   On a DOS- or Windows-based system, assign the drive letter
        (e.g. "c:") as the first path segment, and append it to the
        URI, followed by a slash character "/".

        *   If an empty authority was included at step 3, a slash "/"
            is prepended to the drive letter (e.g. "/c:") to
            distinguish it from the authority.

    *   On an OpenVMS Files-11 system, append a slash "/" to the URI,
        and encode the device name as the first segment as per step 5,
        below, except that the dollars sign character "$" is not
        treated as a reserved character.

    *   On a UNIX-like system, append a slash "/" to the URI, to
        denote the root directory.

5.  For each directory in the path after the root:

    1.  Transform the directory name to a path segment ({{RFC3986}},
        Section 3.3) as per Section 2 of {{RFC3986}}.

    2.  Append the transformed segment and a delimiting slash character
        "/" to the URI.

6.  If the path includes a file name:

    1.  Transform the file name to a path segment as above.

    2.  Append the transformed segment to the URI.

7.  If any non-hierarchical data is required to identify the file (for
    example a version number in a versioning file system):

    1.   Append a question mark character "?" to the URI.

    2.   Transform the non-hierarchical data to a query field
         ({{RFC3986}}, Section 3.4) as per Section 2 of {{RFC3986}}.

    3.  Append the transformed query field to the URI.


Examples:

~~~~~~~~~~
   File Path                      | URIs (ideal, traditional)
   -------------------------------+--------------------------------
   UNIX-Like:                     |
     /path/to/file                | file:/path/to/file
                                  | file:///path/to/file
                                  |
     /path/to/dir/                | file:/path/to/dir/
                                  | file:///path/to/dir/
                                  |
   DOS- or Windows-based:         |
     c:\path\to\file.txt          | file:c:/path/to/file.txt
                                  | file:///c:/path/to/file.txt
                                  |
     c:\path\to\dir\              | file:c:/path/to/dir/
                                  | file:///c:/path/to/dir/
   VMS Files-11:                  |
     ::DISK1:[PATH.TO]FILE.TXT;2  | file:/DISK1/PATH/TO/FILE.TXT?2
                                  | file:///DISK1/PATH/TO/FILE.TXT?2
                                  |
~~~~~~~~~~

__Differences from RFC 1738__

In {{RFC1738}} a file URL always started with the token "file://",
followed by an authority and a "/". That "/" was not considered part
of the path. This implies that the correct encoding for the above
example file path in a UNIX-like environment would have been:

~~~~~~~~~~
     token     + authority + slash + path
   = "file://" + ""        + "/"   + "/path/to/file.txt"
   = "file:////path/to/file.txt"
~~~~~~~~~~

However that construct was never used in practice.


__Exceptions__

DOS/Windows:
: Some implementations leave the leading slash off before
  the drive letter when authority is blank, e.g. `file://c:/...`

DOS/Windows:
: Some implementations replace ":" with "|", and others
  leave it off completely. e.g. `file:///c|/...` or `file:///c/...`
{: vspace="0"}


## Translating UNC String to file URI

A UNC filespace selector string can be directly translated to an
Internationalized Resource Identifier (IRI) {{RFC3987}}, which can
then be translated to a URI as per Section 3.1 of {{RFC3987}} (see:
{{encoding}}).

1.  Initialise the URI with the "file:" scheme identifier.

2.  Append the authority:

    1.  Append the "//" authority sigil to the URI.

    2.  Append the hostname field of the UNC string to the URI.

3.  For each objectname:

    1.  Transform the objectname to a path segment ({{RFC3986}},
        Section 3.3) as per Section 2 of {{RFC3986}}.

    2.  Append a delimiting slash character "/" and the transformed
        segment to the URI.

Example:

~~~~~~~~~~
   UNC String:   \\host.example.com\Share\path\to\file.txt
   URI:          file://host.example.com/Share/path/to/file.txt
~~~~~~~~~~

__Exceptions__

Many implementations accept the full UNC string in the URI path (with
all backslashes "\\" converted to slashes "/").  Additionally, because
{{RFC1738}} said that the first "/" after "file://\[authority\]" wasn't
part of the path, Firefox requires an additional slash before the
UNC string.

For example:

~~~~~~~~~~
   Traditional:
       file:////hostname/share/object/names
       \_____/\__________________________ /
       Scheme     Transformed UNC string

   Firefox:
       file://///hostname/share/object/names
       \_____/|\__________________________ /
       Scheme |    Transformed UNC string
              Extra slash
~~~~~~~~~~


## Translating Non-local File Path to file URI

Translating a non-local file path other than a UNC string to a file URI
follows the same basic algorithm as for local files, above, except that
the authority MUST refer to the network-accesible node that hosts the
file.

For example, in a clustered OpenVMS Files-11 system the authority
would contain the node name. Where the original node reference includes
a username and password in an access control string, they MAY be
transcribed into the userinfo field of the authority ({{RFC3986}},
Section 3.2.1), security considerations ({{security}}) notwithstanding.


<!-- ## Translating file URI to ... -->


## Incompatible File Paths {#incompat}

Some conventional file path formats are known to be incompatible with
the file URI scheme.

### Namespaces {#namespaces}

The Microsoft Windows API defines Win32 Namespaces {{Win32-Namespaces}}
for interacting with files and devices using Windows API functions.
These namespaced paths are prefixed by "\\\\?\\" for Win32 File
Namespaces and "\\\\.\\" for Win32 Device Namespaces. There is also a
special case for UNC file paths {{MS-DTYP}} in Win32 File Namespaces,
referred to as "Long UNC", using the prefix "\\\\?\\UNC\\".

This specification does not define a mechanism for translating
namespaced paths to or from file URIs.


# Encoding {#encoding}

The encoding of a file URI depends on the file system. If the file
system uses a known non-Unicode character encoding, the path SHOULD be
converted to a sequence of characters from the Universal Character Set
{{ISO10646}} normalized according to Normalization Form C (NFC) 
{{UTR15}}, before being translated to a file URI, and conversely a file
URI SHOULD be converted back to the file system's native encoding when
translating to a file path.

> Note that many modern file systems encode directory and file names
> as arbitrary sequences of octets. In those cases, the representation
> as an encoded string often depends on the user's localization
> settings, or defaults to UTF-8 {{STD63}}.

When the file system's encoding is not known the file URI SHOULD be
transported as an Internationalized Resource Identifier (IRI)
{{RFC3987}}.

Example: file IRI:

~~~~~~~~~~
| Bytes of file IRI in a UTF-8 document:
|    66 69 6c 65 3a 43 3a 2f 72 65 c3 a7 75 2e 74 78 74
|
| Interpretation:
|    A file named "recu.txt" with a cedilla on the "c", in the
|    directory "C:\" of a DOS or Windows file system.
|
| Character value sequences of file paths, for various file system
| encodings:
|
|  o UTF-16 (e.g. NTFS):
|       0043 003a 005c 0072 0065 00e7 0075 002e 0074 0078 0074
|
|  o Codepage 437 (e.g. MS-DOS):
|       43 3a 5c 72 65 87 75 2e 74 78 74
~~~~~~~~~~

Counter-example: ambiguous file URI:

~~~~~~~~~~
| File URI, in any ASCII-compatible document:
|    "file:///%E3%81%A1"
|
| Possible interpretations of the file name, depending on the
| (unknown) encoding of the file system:
|
|  o UTF-8:
|       <HIRAGANA LETTER TI (U+3061)>
|
|  o Codepage 437:
|       <GREEK SMALL LETTER PI (U+03C0)>
|       <LATIN SMALL LETTER U WITH DIAERESIS (U+00FC)>
|       <LATIN SMALL LETTER I WITH ACUTE (U+00ED)>
|
|  o EBCDIC:
|       "Ta~"
|
|  o US-ASCII:
|       "%E3%81%A1"
|
| etc.
~~~~~~~~~~


# Security Considerations {#security}

There are many security considerations for URI schemes discussed in
{{RFC3986}}.

File access and the granting of privileges for specific operations
are complex topics, and the use of file URIs can complicate the
security model in effect for file privileges.  Software using file
URIs MUST NOT grant greater access than would be available for other
file access methods.

Additionally, as discussed in the [HP OpenVMS Systems Documentation][1]
"access control strings include sufficient information to allow someone
to break in to the remote account, \[therefore\] they create serious
security exposure." In a similar vein, the presence of a password
in a "user:password" userinfo field is deprecated by {{RFC3986}}.
The userinfo field of a file URI, if present, MUST NOT contain a
password.

[1]: http://h71000.www7.hp.com/doc/84final/ba554_90015/ch03s09.html


# IANA Considerations {#iana-considerations}

In accordance with the guidelines and registration procedures for new
URI schemes {{RFC4395}}, this section provides the information needed
to update the registration of the file URI scheme.

## URI Scheme Name {#iana-name}

file

## Status {#iana-status}

permanent

## URI Scheme Syntax {#iana-syntax}

See {{syntax}}.

## URI Scheme Semantics {#iana-semantics}

(This whole document).

## Encoding Considerations {#iana-encoding}

See {{encoding}}.

## Applications/Protocols That Use This URI Scheme Name {#iana-implementations}

Web browsers:

* Firefox
  * Note: Firefox has an interpretation of RFC 1738 which affects UNC paths.
    See: [Bugzilla#107540][2]
  * [source code repository][src-ff]
* Chromium
  * [source code repository][src-cr]
* Internet Explorer (since version 4)
* Opera

Other applications/protocols:

* Windows API
  * [PathCreateFromUrl function][3], MSDN
  * [UrlCreateFromPath function][4], MSDN
* Perl LWP
  * [source code repository][src-pl]

These lists are non-exhaustive.

[2]: https://bugzilla.mozilla.org/show_bug.cgi?id=107540
[3]: http://msdn.microsoft.com/en-us/library/windows/desktop/bb773581(v=vs.85).aspx
[4]: http://msdn.microsoft.com/en-us/library/windows/desktop/bb773773(v=vs.85).aspx
[src-ff]: https://hg.mozilla.org/mozilla-central/file/5976b9c673f8/netwerk/protocol/file
[src-cr]: http://src.chromium.org/viewvc/chrome/trunk/src/url/url_file.h
[src-pl]: http://cpansearch.perl.org/src/MSCHILLI/libwww-perl-6.08/lib/LWP/Protocol/file.pm

## Interoperability Considerations {#iana-interop}

Due to the convoluted history of the file URI scheme there are many,
varied implementations in existence.  Many have converged over time,
forming a few kernels of closely-related functionality, and RFCXXXX
attempts to accommodate such common functionality. However there will
always be exceptions, and this fact is recognised.

## Security Considerations {#iana-security}

See {{security}}.

## Contact {#iana-contact}

Matthew Kerwin, matthew.kerwin@qut.edu.au

## Author/Change Controller {#iana-author}

This scheme is registered under the IETF tree.  As such, the IETF
maintains change control.

## References {#iana-references}

None.

# Acknowledgements

This specification is derived from {{RFC1738}}, {{RFC3986}}, and
{{I-D.draft-hoffman-file-uri}} (expired); the acknowledgements in
those documents still apply.

Additional thanks to Dave Risney, author of an informative
[IE Blog][5] article, and Dave Thaler for their comments and
suggestions.

[5]: http://blogs.msdn.com/b/ie/archive/2006/12/06/file-uris-in-windows.aspx


--- back

# UNC Syntax

The syntax of a UNC filespace selector string, as defined by
{{MS-DTYP}}, is given here in Augmented Backus-Naur Form (ABNF)
{{RFC5234}} for convenience:

~~~~~~~~~~
   UNC = "\\" hostname "\" sharename \*( "\" objectname )
   hostname   = netbios-name / fqdn / ip-address
   sharename  = <name of share or resource to be accessed>
   objectname = <depends on resource being accessed>
~~~~~~~~~~

* `netbios-name` from {{MS-NBTE}}, [Section 2.2.1](http://msdn.microsoft.com/en-us/library/dd891456.aspx).
* `fqdn` from {{RFC1035}} or {{RFC1123}}
* `ip-address` from Section 2.1 of {{RFC1123}}, or Section 2.2 of {{RFC4291}}.

The precise format of `sharename` depends on the protocol;
see SMB {{MS-SMB}}, NFS {{RFC3530}}, NCP {{NOVELL}}.

The UNC filespace selector string is a null-terminated sequence of
characters from the Universal Character Set {{ISO10646}}.
