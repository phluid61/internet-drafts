---
title: The file URI Scheme
abbrev: file-uri-scheme
docname: draft-kerwin-file-uri-scheme-00
date: 2014
category: std

ipr: trust200902
area: General
workgroup: Independent Submission
keyword: Internet-Draft

stand_alone: yes #_
pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
 -
    ins: M. Kerwin
    name: Matthew Kerwin
    organization: Queensland University of Technology
    email: matthew.kerwin@qut.edu.au

normative:
  RFC1035:
  RFC1123:
  RFC2119:
  RFC3986:
  RFC3987:
  RFC4921:
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

informative:
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
  GITHUB:
    title: file-uri-scheme GitHub repository
    author:
    - ins: M. Kerwin
      name: Matthew Kerwin
    date: n.d.


--- abstract

This document specifies the file Uniform Resource Identifier (URI) scheme.

**Note to Readers (To be removed by the RFC Editor)**

This draft should be discussed on its github project page ({{GITHUB}}).

--- middle

# Introduction

## What it is/What it's for

A file URI identifies a file on a particular file system.  It can be
used in discussions about the file, and it can be dereferenced to
directly access the file if other conditions are met (locality, etc.)

The file URI scheme is not coupled with a specific protocol.  As such,
there is no well-defined set of methods that can be performed on a file
URI, nor a media type associated with them.  A file URI is simply a
means of describing the location of a file on a particular file system.


## How to use it

In the simplest terms, the only methods that can be performed on a file
URI are translating it to and from a file path; subsequent methods are
performed on the resulting file path, and depend entirely on the file
system's APIs.

For example, consider the POSIX `open()`, `read()`, and `close()`
methods ({{POSIX}}) for reading a file's contents into memory.

If there's a non-blank authority, you can't use the file system.
E.g. SMB, NFS, etc.

(Different from RFC1738 - "localhost" used to mean "", now means a
service on loopback)


## History {#history}

The file URI scheme was first defined in {{RFC1630}}, which, being an
informational RFC, does not specify an Internet standard.  The
definition was standardised in {{RFC1738}}, and the scheme was
registered with the Internet Assigned Numbers Authority (IANA,
{{IANA-URI-Schemes}});  however that definition omitted certain
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

Additionally the WHATWG defines a living URL standard ({{WHATWG-URL}}),
which includes algorithms for interpreting file URIs (as URLs).


## UNC

A Universal Naming Convention (UNC) string does a similar job. It has
three parts: host, share, path. You can translate between UNC paths and
file URIs.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.


# Syntax {#syntax}

~~~~~~~~~~
  file-URI       = f-scheme ":" f-hier-part

  f-scheme       = "file"

  f-hier-part    = "//" auth-path ; file://...
                 / local-path

  auth-path      = [ authority ] path-absolute
                 / unc-path       ; file:////host/share/... *
                 / windows-path   ; file://c:/... **

  local-path     = path-absolute  ; file:/...
                 / windows-path   ; file:c:/...

  unc-path       = 2\*3"/" authority path-absolute

  windows-path   = drive-letter path-absolute
  drive-letter   = ALPHA [ drive-marker ]
  drive-marker   = ":" / "|"

~~~~~~~~~~

\* The 'unc-path' rule within 'auth-path' is there for legacy reasons.  
\*\* The 'windows-path' rule within 'auth-path' allows for dubious URIs that encode a Windows drive letter as the authority component.


# Translations

## Translating File Path

1. Resolve to fully qualified/absolute path
2. On DOS/Windows, put drive letter + ":" in first segment, on UNIX
   path starts with "/"
  1. note: authority, if used, must be followed by a "/"; on
     DOS/Windows this implies "file://authority/c:/.."
3. convert each directory in the path to path segments, e.g. percent
   encoding reserved characters, as per {{RFC3986}}, Section 2.
4. concatenate segments with appropriate "file:" and slashes

... gives an IRI in file system's encoding, which can be translated to
a URI as per {{RFC3987}}, Section 3.1.

Simplest example:

    file:/path/to/file.txt    |  file:c:/path/to/file.txt

Standard example:

    file:///path/to/file.txt  |  file:///c:/path/to/file.txt


### Not RFC1738

In {{RFC1738}} always started with "file://", and first "/" wasn't part
of path (although nobody ever used "file:////path/to/file.txt")

### Deviants

DOS/Windows: Some deviants leave the leading slash off before the drive
letter when authority is blank, e.g. `file://c:/...`

DOS/Windows: Some deviants replace ":" with "|", and others leave it
off completely. e.g. `file:///c|/...` or `file:///c/...`


## Translating UNC

The syntax of a UNC path {{MS-DTYP}}:

~~~~~~~~~~
  UNC = "\\" hostname "\" sharename \*( "\" objectname )
  hostname = netbios-name / fqdn / ip-address
  sharename = <name of share or resource to be accessed>
  objectname = <depends on resource being accessed>
~~~~~~~~~~

o netbios-name from {{MS-NBTE}}, <eref target="http://msdn.microsoft.com/en-us/library/dd891456.aspx">Section 2.2.1</eref>.
o fqdn from {{RFC1035}} or {{RFC1123}}
o ip-address from {{RFC1123}}, Section 2.1, or {{RFC4921}}, Section 2.2.

* format of sharename depends on protocol; see {{MS-SMB}}, {{RFC3530}}, NCP ({{NOVELL}}).

Translates directly to file URI: hostname=:authority, sharename=:first
path segment, objectnames=:subsequent path segments

1. ensure hostname matches authority
2. convert sharename, objectnames to path segments, e.g. percent
   encoding reserved characters, as per RFC3986, Section 2.
3. concatenate with appropriate "file://" and slashes

... gives a UTF-16 IRI, which can be translated to a URI as per
{{RFC3987}}, Section 3.1.

### Deviants

Many implementations accept the full UNC path in the URI path (with
all backslashes converted to slashes).  Additionally, because
{{RFC1738}} said that the first "/" after "file://\[authority\]" wasn't
part of the path, Firefox requires an additional slash.

E.g.:

    file:////hostname/share/object/names
    file://///hostname/share/object/names  ; (FF)


# Semantics {#semantics}


# Encoding {#encoding}

Use-cases:

Transcription
: E.g. a human hearing a spoken URI and entering it into a text file.
  I don’t think there’s any encoding happening here, per se; that
  would be handled by #3 or #4 below.
: Input: analogue signal
: Output: visual representation of a URI, as a character sequence

Manual encoding
: E.g. a human entering a URI as a string literal in a program
  (they’d need to perform all the encoding steps, down to the
  byte/character level.)
: Input: any
: Output: expression of fully encoded URI, as byte sequence

Keyboard to URI encoding
: A UI text box accepting keyboard input; silently percent-encoding
  (or not) as appropriate, etc.
: Input: keypress events/characters
: Output: URI

File path to URI encoding
: `UrlCreateFromPath()`
: Input: file path
: Output: URI

Parsing
: E.g. a browser following a clicked hyperlink. Probably just doing
  enough to detect that it’s a file URI, then relying on #6 to do
  the real work.
: Input: URI
: Output: ?

URI to file path decoding
: `PathCreateFromUrl()`, `CreateURLMonikerEx()`
: Input: URI
: Output: file path

Anything that outputs a URI should use percent-encoded UTF-8, except
in Windows, when it should be \[an IRI?\]


# Security Considerations {#security}


# IANA Considerations {#iana-considerations}

In accordance with the guidelines and registration procedures for new
URI schemes {{RFC4395}}, this section provides the information needed
to update the registration of the file URI scheme.

## URI Scheme Name {#iana.name}

file

## Status {#iana.status}

permanent

## URI Scheme Syntax {#iana.syntax}

See {{syntax}}.

## URI Scheme Semantics {#iana.semantics}

See {{semantics}}.

## Encoding Considerations #{iana.encoding}

See {{encoding}}.

## Applications/Protocols That Use This URI Scheme Name {#iana.implementations}

Web browsers:

* Firefox
  * Note: Firefox has an interpretation of RFC 1738 which affects UNC paths.
    See: <!-- xref target="unc-rfc1738"/ -->, <eref target="https://bugzilla.mozilla.org/show_bug.cgi?id=107540">Bugzilla#107540</eref>
  * <!-- <eref target="https://hg.mozilla.org/mozilla-central/file/5976b9c673f8/netwerk/protocol/file">source code repository</eref> -->
* Chromium
  * <!-- <eref target="http://src.chromium.org/viewvc/chrome/trunk/src/url/url_file.h">source code repository</eref> -->
* Internet Explorer <!-- since 4 -->
* Opera

Other applications/protocols:

* Windows API
  * <eref target="http://msdn.microsoft.com/en-us/library/windows/desktop/bb773581(v=vs.85).aspx">PathCreateFromUrl function</eref>, MSDN
  * <eref target="http://msdn.microsoft.com/en-us/library/windows/desktop/bb773773(v=vs.85).aspx">UrlCreateFromPath function</eref>, MSDN
* Perl LWP
  * <!-- <eref target="http://cpansearch.perl.org/src/GAAS/libwww-perl-6.05/lib/LWP/Protocol/file.pm">source code repository</eref> -->

These lists are non-exhaustive.

## Interoperability Considerations {#iana.interop}

Due to the convoluted history of the file URI scheme there are many,
varied implementations in existence.  Many have converged over time,
forming a few kernels of closely-related functionality, and RFCXXXX
attempts to accommodate such common functionality. However there will
always be exceptions, and this fact is recognised.

<!-- <eref target="http://blogs.msdn.com/b/ie/archive/2006/12/06/file-uris-in-windows.aspx">IE Blog</eref> -->

## Security Considerations {#iana.security}

See {{security}}.

## Contact {#iana.contact}

Matthew Kerwin, matthew.kerwin@qut.edu.au

## Author/Change Controller {#iana.author}

This scheme is registered under the IETF tree.  As such, the IETF
maintains change control.

## References {#iana.references}

None.

# Acknowledgements

This specification is derived from {{RFC1738}}, {{RFC3986}}, and
{{I-D.draft-hoffman-file-uri}} (expired); the acknowledgements in
those documents still apply.


--- back
