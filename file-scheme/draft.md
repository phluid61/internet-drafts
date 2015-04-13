---
title: The file URI Scheme
abbrev: file-scheme
docname: draft-ietf-appsawg-file-scheme-01
date: 2015
category: std

ipr: trust200902
area: General
workgroup: Applications Area Working Group
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
  BCP115:
    title: Guidelines and Registration Procedures for New URI Schemes
    author:
    - ins: T. Hansen
      name: T. Hansen
    - ins: T. Hardie
      name: T. Hardie
    - ins: L. Masinter
      name: L. Masinter
    date: 2006-02
    seriesinfo:
      BCP: 35
      RFC: 4395
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
  #RFC7231:
  I-D.hoffman-file-uri:
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

This document specifies the "file" Uniform Resource Identifier (URI)
scheme, obsoleting the definition in RFC 1738.

It attemps to define a common core which is intended to interoperate
across the broad spectrum of existing implementations, while at the
same time documenting other current practices.

**Note to Readers (To be removed by the RFC Editor)**

This draft should be discussed on the IETF Applications Area Working
Group discussion list <apps-discuss@ietf.org>.

--- middle

# Introduction

A file URI identifies a file on a particular file system.  It can be
used in discussions about the file, and if other conditions are met it
can be dereferenced to directly access the file.

The file URI scheme is not coupled with a specific protocol.  As such,
there is no well-defined set of operations that can be performed on file
URIs, nor a specific media type associated with them.

This document defines a syntax that is compatible with most extant
implementations, while attempting to push towards a stricter subset of
"ideal" constructs.  In many cases it simultaneously acknowledges and
deprecates some less common or outdated constructs.


## History {#history}

The file URI scheme was first defined in {{RFC1630}}, which, being an
informational RFC, does not specify an Internet standard.  The
definition was standardised in {{RFC1738}}, and the scheme was
registered with the Internet Assigned Numbers Authority (IANA);
however that definition omitted certain language included by former
that clarified aspects such as:

* the use of slashes to denote boundaries between directory
  levels of a hierarchical file system; and
* the requirement that client software convert the file URI
  into a file name in the local file name conventions.

The Internet draft {{I-D.hoffman-file-uri}} was written in an
effort to keep the file URI scheme on standards track when {{RFC1738}}
was made obsolete, but that draft expired in 2005.  It enumerated
concerns arising from the various, often conflicting implementations
of the scheme.  It serves as the spiritual predecessor of this document.

Additionally the WHATWG defines a living URL standard {{WHATWG-URL}},
which includes algorithms for interpreting file URIs (as URLs).


## Similar Technologies

The Universal Naming Convention (UNC) {{MS-DTYP}} defines a string
format that can perform a similar role to the file URI scheme in
describing the location of files.  A UNC filespace selector string has
three parts: host, share, and path; see: {{unc-syntax}}.  This document
describes a means of translating between UNC filespace selector strings
and file URIs.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.

Throughout this document the term "local" is used to describe files
that can be accessed directly through the local file system.  It is
important to note that a local file may not be physically located on
the local machine, for example if a networked file system is
transparently mounted into the local file system.


# Syntax {#syntax}

The file URI syntax is defined here in Augmented Backus-Naur Form (ABNF)
{{RFC5234}}, including the core ABNF syntax rule `ALPHA` defined by that
specification, and importing the `userinfo`, `host`, `authority` and
`path-absolute` rules from {{RFC3986}} (as updated by {{RFC6874}}.)

Please note {{nonstandard-syntax}} that lists some other commonly seen
but nonstandard variations.

~~~~~~~~~~
   file-URI       = file-scheme ":" file-hier-part

   file-scheme    = "file"

   file-hier-part = "//" auth-path
                  / local-path

   auth-path      = [ file-auth ] path-absolute

   local-path     = [ drive-letter ] path-absolute

   file-auth      = [ userinfo "@" ] host

   drive-letter   = ALPHA ":"
                  / ALPHA     ; deprecated
~~~~~~~~~~

The syntax definition above is different from those given in
{{RFC1630}} and {{RFC1738}} as it is derived from the generic syntax
of {{RFC3986}}, which post-dates all previous specifications.

Systems exhibit different levels of case-sensitivity.  Unless the file
system is known to be case-insensitive, implementations MUST maintain
the case of file and directory names when translating file URIs to and
from the local system's representation of file paths, and any systems or
devices that transport file URIs MUST NOT alter the case of file URIs
they transport.


# Operations on file URIs  {#operations}

Implementations SHOULD, at a minimum, provide a read-like operation to
return the contents of a file located by a file URI.  Additional
operations MAY be provided, such as writing, creating, and deleting
files.  See the POSIX file and directory operations {{POSIX}} for
examples of standardized operations that can be performed on files.

File URIs can also be translated to and from local file paths or UNC
strings.

A file URI can only be translated to a local file path if it has a
blank or no authority.  Note that this differs from the previous
specification in {{RFC1738}}, in that previously an authority of
"localhost" was used to refer to the local file system, but in this
specification it translates to a UNC string with the host "localhost".

This specification neither defines nor forbids a mechanism for
accessing files stored on non-local file systems.  See SMB {{MS-SMB}},
NFS {{RFC3530}}, NCP {{NOVELL}} for examples of protocols that can be
used to access files over a network.


## Translating Local File Path to file URI  {#file-to-uri}

Below is an algorithmic description of the process used to convert a
file path to an Internationalized Resource Identifier (IRI) 
{{RFC3987}}, which can then be translated to a URI as per Section 3.1
of {{RFC3987}}; see: {{encoding}}.

1.  Resolve the file path to its fully qualified absolute form.

2.  Initialise the URI with the "file:" scheme identifier.

3.  If including an empty authority field, append the "//" sigil to
    the URI.

4.  Append the file system root:

    *   On a DOS- or Windows-based system, assign the drive letter
        (e.g. "c:") as the first path segment, and append it to the
        URI, followed by a slash character "/".

        *   If an empty authority was included at step 3, a slash "/"
            is prepended to the drive letter (e.g. "/c:") to
            distinguish it from the authority.

    *   On an OpenVMS Files-11 system, append a slash "/" to the URI,
        and encode the device name as the first segment as per step 5,
        below, except that the dollars sign character "$" is not
        treated as a reserved character in this segment.

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


Examples:

~~~~~~~~~~
   File Path                      | URIs (minimal, traditional)
   -------------------------------+--------------------------------
   UNIX-like:                     |
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
of the path.  This implies that the correct encoding for the above
example file path in a UNIX-like environment would have been:

~~~~~~~~~~
     token     + authority + slash + path
   = "file://" + ""        + "/"   + "/path/to/file.txt"
   = "file:////path/to/file.txt"
~~~~~~~~~~

However that construct was never used in practice, and in fact would
have collided with the eventual encoding of UNC strings in URIs
described in {{ext-unc}}.


__Exceptions__

DOS/Windows:
: Some implementations leave the leading slash off before
  the drive letter when authority is blank, e.g. `file://c:/...`

DOS/Windows:
: Some implementations replace ":" with "|", and others
  leave it off completely. e.g. `file:///c|/...` or `file:///c/...`
  See {{ext-pipe}}.
{: vspace="0"}


## Translating UNC String to file URI  {#unc-to-uri}

A UNC filespace selector string can be directly translated to an
Internationalized Resource Identifier (IRI) {{RFC3987}}, which can
then be translated to a URI as per Section 3.1 of {{RFC3987}}; see:
{{encoding}}.

1.  Initialise the URI with the "file:" scheme identifier.

2.  Append the authority:

    1.  Append the "//" authority sigil to the URI.

    2.  Append the hostname field of the UNC string to the URI.

3.  Append the sharename:

    1.  Transform the sharename to a path segment ({{RFC3986}},
        Section 3.3) as per Section 2 of {{RFC3986}}.

    2.  Append a delimiting slash character "/" and the transformed
        segment to the URI.

4.  For each objectname:

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
part of the path, some implementations (including Firefox) require an
additional slash before the UNC string.  See {{ext-unc}}.


## Translating Non-local File Path to file URI  {#remote-to-uri}

Translating a non-local file path other than a UNC string to a file URI
follows the same basic algorithm as for local files, above, except that
the authority MUST refer to the network-accesible node that hosts the
file.

For example, in a clustered OpenVMS Files-11 system the authority
would contain the node name.  Where the original node reference
includes a username and password in an access control string, they MAY
be transcribed into the userinfo field of the authority ({{RFC3986}},
Section 3.2.1), security considerations ({{security}}) notwithstanding.


## Incompatible File Paths {#incompat}

Some conventional file path formats are known to be incompatible with
the file URI scheme.


### Win32 Namespaces {#namespaces}

The Microsoft Windows API defines Win32 Namespaces {{Win32-Namespaces}}
for interacting with files and devices using Windows API functions.
These namespaced paths are prefixed by "\\\\?\\" for Win32 File
Namespaces and "\\\\.\\" for Win32 Device Namespaces.  There is also a
special case for UNC file paths in Win32 File Namespaces, referred to as
"Long UNC", using the prefix "\\\\?\\UNC\\".

This specification does not define a mechanism for translating
namespaced paths to or from file URIs.


# Encoding {#encoding}

The encoding of a file URI depends on the file system.  If the file
system uses a known non-Unicode character encoding, the path SHOULD be
converted to a sequence of characters from the Universal Character Set
{{ISO10646}} normalized according to Normalization Form C (NFC) 
{{UTR15}}, before being translated to a file URI, and conversely a file
URI SHOULD be converted back to the file system's native encoding when
translating to a file path.

> Note that many modern file systems encode directory and file names
> as arbitrary sequences of octets.  In those cases, the representation
> as an encoded string often depends on the user's localization
> settings, or defaults to UTF-8 {{STD63}}.

When the file system's encoding is not known the file URI SHOULD be
transported as an Internationalized Resource Identifier (IRI)
{{RFC3987}} to avoid ambiguity.  See {{iri-vs-uri}} for examples.



# Security Considerations {#security}

There are many security considerations for URI schemes discussed in
{{RFC3986}}.

File access and the granting of privileges for specific operations
are complex topics, and the use of file URIs can complicate the
security model in effect for file privileges.  Software using file
URIs MUST NOT grant greater access than would be available for other
file access methods.

File systems typically assign an operational meaning to special
characters, such as the "/", "\\", ":", "[", and "]" characters, and
to special device names like ".", "..", "...", "aux", "lpt", etc.
In some cases, merely testing for the existence of such a name will
cause the operating system to pause or invoke unrelated system calls,
leading to significant securt concerns regarding denial of service and
unintended data transfer.  It would be impossible for this
specification to list all such significant characters and device names.
Implementers MUST research the reserved names and characters for the
types of storage device that may be attached to their application and
restrict the use of data obtained from URI components accordingly.

Additionally, as discussed in the HP OpenVMS Systems Documentation
<http://h71000.www7.hp.com/doc/84final/ba554_90015/ch03s09.html>
"access control strings include sufficient information to allow someone
to break in to the remote account, \[therefore\] they create serious
security exposure." In a similar vein, the presence of a password in a
"user:password" userinfo field is deprecated by {{RFC3986}}.  As such,
the userinfo field of a file URI, if present, MUST NOT contain a
password.


# IANA Considerations {#iana-considerations}

IANA maintains the registry of URI Schemes {{BCP115}} at
<http://www.iana.org/assignments/uri-schemes/>.

This document defines the following URI scheme, so the "Permanent
URI Schemes" registry has been updated accordingly.

 |------------|--------------------------|-----------|
 | URI Scheme | Description              | Reference |
 |------------|--------------------------|-----------|
 | file       | Host-specific file names | RFC XXXX  |
 |------------|--------------------------|-----------|

**RFC Editor Note:** Replace XXXX with this RFC's reference.


# Acknowledgements

This specification is derived from {{RFC1738}}, {{RFC3986}}, and
{{I-D.hoffman-file-uri}} (expired); the acknowledgements in
those documents still apply.

Additional thanks to Dave Risney, author of the informative
IE Blog article <http://blogs.msdn.com/b/ie/archive/2006/12/06/file-uris-in-windows.aspx>,
and Dave Thaler for their comments and suggestions.


--- back

# Example URIs  {#examples}

The syntax in {{syntax}} is intended to support file URIs that take the
following forms:

Local files:

* `file:///path/to/file`

   > A "traditional" file URI for a local file, with an empty
     authority.  This is the most common format in use today.

* `file:/path/to/file`

   > A "modern" minimal representation of a local file, with no
     authority field and an absolute path that begins with a slash "/".

* `file:c:/path/to/file`

   > The minimal representation of a local file in a DOS- or
     Windows-based environment, with no authority field and an
     absolute path that begins with a drive letter.

* `file:c/path/to/file`

   > Representations of a local file in a DOS- or Windows-based
     environment, using alternative representations of drive letters.
     This construct is supported for compatibility with historical
     implementations, but deprecated by this specification.

> Note that the "path" element of the first two examples above could
  encode a DOS or Windows drive letter.

Non-local files:

* `file://host.example.com/path/to/file`

   > The representation of a non-local file, with an explicit
     authority.  Note that, unlike in {{RFC1738}}, the string
     "localhost" in the authority signifies a non-local file.


# Nonstandard Syntax Variations  {#nonstandard-syntax}

These variations may be encountered for historical reasons, but are
not supported by the normative syntax of {{syntax}}.

This section is not normative.


## DOS and Windows Drive Letters  {#ext-pipe}

Historically some implementations have used a vertical line character
"\|" instead of a colon ":" in the drive letter construct.  {{RFC3986}}
forbids the use of the vertical line, however it may be necessary to
interpret or update old URIs.

For interpreting such URIs, the `drive-letter` rule in {{syntax}} is
replaced with the following:

~~~~~~~~~~
   drive-letter   = ALPHA ":"
                  / ALPHA "|"
                  / ALPHA
~~~~~~~~~~

To update such an old URI, replace the vertical line "\|" with a colon ":".


## UNC Paths  {#ext-unc}

It is common to encounter file URIs that encode entire UNC strings in
the path, usually with backslash "\\" characters replaced with slashes
"/".

To interpret such URIs, the `auth-path` rule in {{syntax}} is replaced
with the following:

~~~~~~~~~~
   auth-path      = [ file-auth ] path-absolute
                  / unc-authority path-absolute

   unc-authority  = 2*3"/" authority
~~~~~~~~~~

> **Fixme** `authority` allows '[' and ']' in IPv6 literals, but
> RFC3986 forbids them in the path, so the `unc-authority` rule
> is not entirely valid.

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

This extended syntax is intended to support URIs that take the
following forms, in addition to those in {{examples}}:

Non-local files:

* `file:////host.example.com/path/to/file`

   > The "traditional" representation of a non-local file, with an
     empty authority and a complete (transformed) UNC string in the
     path.

* `file://///host.example.com/path/to/file`

   > As above, with an extra slash between the empty authority and the
     transformed UNC string, conformant with the definition from
     {{RFC1738}}; see: exceptions in {{unc-to-uri}}.  This
     representation is notably used by the Firefox web browser.


It also further limits the set of file URIs that can be translated to
a local file path to those whose path does not encode a UNC string.



## Backslash as Separator  {#ext-backslash}

Historically some implementations have copied entire file paths into
the path segments of file URIs.  Where DOS or Windows file paths were
copied thus, resulting URI strings contained unencoded backslash "\\"
characters, which are forbidden by both {{RFC1738}} and {{RFC3986}}.

It may be possible to translate or update such an invalid file URI by
replacing all backslashes "\\" with slashes "/", if it can be
determined with reasonable certainty that the backslashes are intended
as path separators.


# Example of IRI vs Percent-Encoded URI  {#iri-vs-uri}

The following examples demonstrate the advantage of encoding file
URIs as IRIs to avoid ambiguity (see {{encoding}}).

Example: file IRI:

~~~~~~~~~~
| Bytes of file IRI in a UTF-8 document:
|    66 69 6c 65 3a 43 3a 2f 72 65 c3 a7 75 2e 74 78 74
|    f  i  l  e  :  c  :  /  r  e  ( c ) u  .  t  x  t
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
|       43   3a   5c   72   65   87   75   2e   74   78   74
~~~~~~~~~~

Counter-example: ambiguous file URI:

~~~~~~~~~~
| Percent-encoded file URI, in any ASCII-compatible document:
|    "file:///%E3%81%A1"
|
| Possible interpretations of the file name, depending on the
| (unknown) encoding of the file system:
|
|  o UTF-8:
|       <HIRAGANA LETTER TI (U+3061)>
|
|  o Codepage 437:
|       <GREEK SMALL LETTER PI (U+03C0)> +
|       <LATIN SMALL LETTER U WITH DIAERESIS (U+00FC)> +
|       <LATIN SMALL LETTER I WITH ACUTE (U+00ED)>
|
|  o EBCDIC:
|       "Ta~"
|
| etc.
~~~~~~~~~~


# UNC Syntax  {#unc-syntax}

The UNC filespace selector string is a null-terminated sequence of
characters from the Universal Character Set {{ISO10646}}.

The syntax of a UNC filespace selector string, as defined by
{{MS-DTYP}}, is given here in Augmented Backus-Naur Form (ABNF)
{{RFC5234}} for convenience.  Note that this definition is informative
only; the normative description is in {{MS-DTYP}}.

~~~~~~~~~~
   UNC = "\\" hostname "\" sharename *( "\" objectname )
   hostname   = netbios-name / fqdn / ip-address
   sharename  = <name of share or resource to be accessed>
   objectname = <depends on resource being accessed>
~~~~~~~~~~

* `netbios-name` from {{MS-NBTE}}, Section 2.2.1<!--http://msdn.microsoft.com/en-us/library/dd891456.aspx-->.
* `fqdn` from {{RFC1035}} or {{RFC1123}}
* `ip-address` from Section 2.1 of {{RFC1123}}, or Section 2.2 of {{RFC4291}}.

The precise format of `sharename` depends on the protocol;
see: SMB {{MS-SMB}}, NFS {{RFC3530}}, NCP {{NOVELL}}.
