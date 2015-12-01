---
title: The file URI Scheme
abbrev: file-scheme
docname: draft-ietf-appsawg-file-scheme-06
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
    org: Queensland University of Technology
    abbrev: QUT
    street: Victoria Park Road
    city: Kelvin Grove
    region: QLD
    code: 4059
    country: Australia
    email: matthew.kerwin@qut.edu.au

normative:
  BCP35:
    title: Guidelines and Registration Procedures for URI Schemes
    author:
    - ins: D. Thaler
      name: D. Thaler
      role: editor
    - ins: T. Hansen
      name: T. Hansen
    - ins: T. Hardie
      name: T. Hardie
    date: 2015-06
    seriesinfo:
      BCP: 35
      RFC: 7595
      DOI: 10.17487/RFC7595
    target: http://www.rfc-editor.org/info/bcp35
  RFC1035:
  RFC1123:
  RFC2119:
  RFC3986:
  RFC3987:
  RFC4291:
  RFC5234:
  RFC6874:
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
    target: http://unicode.org/reports/tr15/tr15-18.html

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
      DOI: 10.17487/RFC3629
    target: http://www.rfc-editor.org/info/std63
  RFC1630:
  RFC1738:
  RFC6454:
  RFC7530:
  I-D.hoffman-file-uri:
  WHATWG-URL:
    title: URL Living Standard
    author:
    - organization: WHATWG
      #url: http://www.whatwg.org/
    date: 2013-05
    target: http://url.spec.whatwg.org/
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
    target: https://msdn.microsoft.com/en-au/library/windows/desktop/aa365247(v=vs.85).aspx

  Bug107540:
    title: Bug 107540
    author:
    - organization: Bugzilla@Mozilla
    date: 2007-10
    target: https://bugzilla.mozilla.org/show_bug.cgi?id=107540


--- abstract

This document specifies the "file" Uniform Resource Identifier (URI)
scheme, obsoleting the definition in RFC 1738.

It attempts to define a common core which is intended to interoperate
across the broad spectrum of existing implementations, while at the
same time documenting other current practices.

**Note to Readers (To be removed by the RFC Editor)**

This draft should be discussed on the IETF Applications Area Working
Group discussion list \<apps-discuss@ietf.org>.

--- middle

# Introduction

A file URI identifies a file on a particular file system.  It can be
used in discussions about the file, and if other conditions are met it
can be dereferenced to directly access the file.

The file URI scheme is not coupled with a specific protocol, nor with a
specific media type.  See {{operations}} for a discussion of operations
that can be performed on a file URI.

This document defines a syntax that is compatible with most extant
implementations, while attempting to push towards a stricter subset of
"ideal" constructs.  In many cases it simultaneously acknowledges and
deprecates some less common or outdated constructs.


## History {#history}

The file URI scheme was first defined in {{RFC1630}}, which, being an
informational RFC, does not specify an Internet standard.  The
definition was standardised in {{RFC1738}}, and the scheme was
registered with the Internet Assigned Numbers Authority (IANA);
however that definition omitted certain language included by the former
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
three parts: host, share, and path; see {{unc-syntax}}.  This document
describes but does not specify a means of translating between UNC
filespace selector strings and file URIs in {{ext-unc}}.


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
specification, and importing the `userinfo`, `host` and `path-absolute`
rules from {{RFC3986}} (as updated by {{RFC6874}}.)

The core syntax in {{RFC3986}} includes `path` and `authority`
components, for each of which only a subset is used in the definition
of the file URI scheme.  The relevant subset of `path` is
`path-absolute`, and the subset of `authority` is `file-auth`, given
below.

Please note {{nonstandard-syntax}} that lists some other commonly seen
but nonstandard variations.

~~~~~~~~~~
   file-URI       = file-scheme ":" file-hier-part

   file-scheme    = "file"

   file-hier-part = "//" auth-path
                  / local-path

   auth-path      = [ file-auth ] path-absolute

   local-path     = path-absolute

   file-auth      = [ userinfo "@" ] host
~~~~~~~~~~

The syntax definition above is different from those given in
{{RFC1630}} and {{RFC1738}} as it is derived from the generic syntax
of {{RFC3986}}, which post-dates all previous specifications.

As a special case, the "file-auth" rule can match the string
"localhost" or the empty string; either value is interpreted as "the
machine from which the URI is being interpreted," exactly as if no
authority was present.  To maximise compatibility with previous
specifications, implementations MAY choose to include an empty
"file-auth".

Systems exhibit different levels of case-sensitivity.  Unless the file
system is known to be case-insensitive, implementations MUST maintain
the case of file and directory names when translating file URIs to and
from the local system's representation of file paths, and any systems or
devices that transport file URIs MUST NOT alter the case of file URIs
they transport.


# Operations on file URIs  {#operations}

Implementations that provide dereferencing  ooperations on file URIs
SHOULD, at a minimum, provide a read-like operation to return the
contents of a file located by a file URI.  Additional operations MAY be
provided, such as writing to, creating, and deleting files.  See the
POSIX file and directory operations {{POSIX}} for examples of
standardized operations that can be performed on files.

File URIs can also be translated to and from other, similar constructs,
such as local file paths or UNC strings.

A file URI can be dependably dereferenced or translated to a local file
path only if it is local.  A file URI is considered "local" if it has a
blank or no authority, or the authority is the special string
"localhost".

This specification neither defines nor forbids a mechanism for
accessing non-local files.  See SMB {{MS-SMB}}, NFS {{RFC7530}}, NCP
{{NOVELL}} for examples of protocols that can be used to access files
over a network.  Also see {{ext-unc}} for a discussion on translating
non-local file URIs to and from UNC stings.


## Translating Local File Path to file URI  {#file-to-uri}

Below is an algorithmic description of the process used to convert a
file path to a URI; see {{encoding}}.

1.  Resolve the file path to its fully qualified absolute form.

2.  Initialise the URI with the "file:" scheme identifier.

3.  If including an empty authority field, append the "//" sigil to
    the URI.

4.  Append a slash character "/" to the URI, to signify the path root.

5.  For each directory in the path after the root:

    1.  Transform the directory name to a path segment ({{RFC3986}},
        Section 3.3) as per Section 2 of {{RFC3986}}.

    2.  Append the transformed segment and a delimiting slash character
        "/" to the URI.

6.  If the path includes a file name:

    1.  Transform the file name to a path segment as above.

    2.  Append the transformed segment to the URI.


__Differences from RFC 1738__

In {{RFC1738}} a file URL always started with the token "file://",
followed by an (optionally blank) authority and a "/". That "/" was not
considered part of the path.  This implies that the correct encoding for
a file path in a UNIX-like environment would have been:

~~~~~~~~~~
     token     + authority + slash + path
   = "file://" + ""        + "/"   + "/path/to/file.txt"
   = "file:////path/to/file.txt"
~~~~~~~~~~

However that construct was never observed in practice, and in fact
would have collided with the eventual encoding of UNC strings in URIs
described in {{ext-unc-path}}.


## Translating Non-local File Path to file URI  {#remote-to-uri}

Translating a non-local file path, including a UNC string, to a file
URI follows the same basic algorithm as for local files, above, except
that the authority MUST refer to the network-accesible node that hosts
the file.

For example, in a clustered OpenVMS Files-11 system the authority
would contain the node name.  Where the original node reference
includes a username and password in an access control string, they MAY
be transcribed into the userinfo field of the authority ({{RFC3986}},
Section 3.2.1), security considerations ({{security}}) notwithstanding.

See {{ext-unc}} for an explicit handling of UNC strings.


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

To avoid ambiguity, a file URI SHOULD be transported as an
Internationalized Resource Identifier (IRI) {{RFC3987}}, or as a URI
with non-ASCII characters encoded according to the UTF-8 character
encoding {{STD63}} and percent-encoded as needed ({{RFC3986}},
Section 2.5).

The encoding of a file URI depends on the file system that stores the
identified file.  If the file system uses a known non-Unicode character
encoding, the path SHOULD be converted to a sequence of characters from
the Universal Character Set {{ISO10646}} normalized according to
Normalization Form C (NFC)  {{UTR15}}, before being translated to a
file URI, and conversely a file URI SHOULD be converted back to the
file system's native encoding when dereferencing or translating to a
file path.

> Note that many modern file systems encode directory and file names
> as arbitrary sequences of octets.  In those cases, the representation
> as an encoded string often depends on the user's localization
> settings, or defaults to UTF-8 {{STD63}}.

When the file system's encoding is not known the file URI SHOULD be
transported as an Internationalized Resource Identifier (IRI)
{{RFC3987}} to avoid ambiguity.  See {{iri-vs-uri}} for examples.


# Origins {#origin}

As per {{RFC6454}}, Section 4, when determining the origin of a file
URI implementations MAY return an implementation-defined value.

Historically, user agents have granted content from the file URI
scheme a tremendous amount of privilege.  However, granting all local
files such wide privileges can lead to privilege escalation attacks.
Some user agents have had success granting local files directory-based
privileges, but this approach has not been widely adopted.  Other user
agents use globally unique identifiers for each file URI, which is the
most secure option.


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
leading to significant security concerns regarding denial of service
and unintended data transfer.  It would be impossible for this
specification to list all such significant characters and device names.
Implementers MUST research the reserved names and characters for the
types of storage device that may be attached to their application and
restrict the use of data obtained from URI components accordingly.

Additionally, as discussed in the HP OpenVMS Systems Documentation
\<http://h71000.www7.hp.com/doc/84final/ba554_90015/ch03s09.html>
"access control strings include sufficient information to allow someone
to break in to the remote account, \[therefore\] they create serious
security exposure." In a similar vein, the presence of a password in a
"user:password" userinfo field is deprecated by {{RFC3986}}.  As such,
the userinfo field of a file URI, if present, MUST NOT contain a
password.


# IANA Considerations {#iana-considerations}

This document defines the following URI scheme, so the "Permanent
URI Schemes" registry has been updated accordingly.  This registration
complies with {{BCP35}}.


Scheme name:
:  file

Status:
:  permanent

Applications/protocols that use this scheme name:
:  Commonly used in hypertext documents to refer to files without
   depending on network access.  Supported by major browsers.
:  Windows API (PathCreateFromUrl, UrlCreateFromPath).
:  Perl LWP.

Contact:
:  Matthew Kerwin \<matthew.kerwin@qut.edu.au>

Change Controller:
:  This scheme is registered under the IETF tree.  As such, the IETF
   maintains change control.
{: vspace="0"}


# Acknowledgements

This specification is derived from {{RFC1738}}, {{RFC3986}}, and
{{I-D.hoffman-file-uri}} (expired); the acknowledgements in
those documents still apply.

Additional thanks to Dave Risney, author of the informative
IE Blog article \<http://blogs.msdn.com/b/ie/archive/2006/12/06/file-uris-in-windows.aspx>,
and Dave Thaler for their comments and suggestions.


--- back

# Example URIs  {#examples}

The syntax in {{syntax}} is intended to support file URIs that take the
following forms:

Local files:

* A traditional file URI for a local file, with an empty authority.
  This is the most common format in use today. E.g.:

  * `file:///path/to/file`

* The minimal representation of a local file, with no authority field
  and an absolute path that begins with a slash "/". E.g.:

  * `file:/path/to/file`

Non-local files:

* A non-local file, with an explicit authority. E.g.:

  * `file://host.example.com/path/to/file`

# System-specific Operations

This appendix is not normative; it highlights some observed
behaviours and provides system-specific guidance for interacting
with file URIs and paths.


## POSIX Systems  {#sys-unix}

There is little to say about POSIX file systems; the file URI structure
already closely resembles POSIX file paths.


## DOS- and Windows-Like Systems  {#sys-dos}

When mapping a DOS- or Windows-like file path to a file URI,
implementations typically map the drive letter (e.g. "c:") into the
first path segment.

See {{ext-drives}} for explicit (but non-normative and strictly
optional) rules for interacting with DOS- or Windows-like file paths
and URIs.


## Mac OS X Systems  {#sys-osx}

The HFS+ file system uses a non-standard normalization form, similar
to Normalization Form D.  Take care when transforming HFS+ file paths
to and from URIs using Normalization Form C {{encoding}}.


## OpenVMS Files-11 Systems  {#sys-vms}

When mapping a VMS file path to a file URI, map the device name
into the first path segment.  Note that the dollars sign "$" is
a reserved character per the definition in {{RFC3986}}, Section 2.2,
so should be percent-encoded if present in the device name.

If the VMS file path includes a node reference, use that as the
authority.  Where the original node reference includes a username and
password in an access control string, they can be transcribed into the
userinfo field of the authority ({{RFC3986}}, Section 3.2.1), security
considerations ({{security}}) notwithstanding.


# Nonstandard Syntax Variations  {#nonstandard-syntax}

These variations may be encountered for historical reasons, but are
not supported by the normative syntax of {{syntax}}.

This appendix is not normative.


## DOS and Windows Drive Letters  {#ext-drives}

On Windows- or DOS-based file systems a absolute file path can begin
with a drive letter.  To facilitate this, the `local-path` rule in
{{syntax}} can be replaced with the following:

~~~~~~~~~~
   local-path     = [ drive-letter ] path-absolute

   drive-letter   = ALPHA ":"
~~~~~~~~~~

This is intended to support the minimal representation of a local file
in a DOS- or Windows-based environment, with no authority field and an
absolute path that begins with a drive letter.  E.g.:

* `file:c:/path/to/file`

URIs of the form `file:///c:/path/to/file` are already supported by the
`path-absolute` rule.

Note that comparison of drive letters in DOS or Windows file paths
is case-insensitive.  Some implementations therefore canonicalize drive
letters in file URIs by converting them to uppercase.


### Relative Paths  {#ext-relative}

In DOS- or Windows-based file systems, relative paths beginning with
a slash "/" should be resolved relative to the drive letter, and
resolution of ".." dot segments (per Section 5.2.4 of {{RFC3986}})
should not ever overwrite the drive letter.

e.g.:

~~~~~~~~~~
   base:       file:///c:/path/to/file.txt
   rel. URI:   /some/other/thing.bmp
   resolved:   file:///c:/some/other/thing.bmp

   base:       file:///c:/foo.txt
   rel. URI:   ../../bar.txt
   resolved:   file:///c:/bar.txt
~~~~~~~~~~

Relative paths with a drive letter followed by a character other than
a slash (e.g. "c:bar/baz.txt" or "c:../foo.txt") should not be
accepted as dereferenceable URIs in DOS or Windows systems.


### Vertical Bar Character  {#ext-pipe}

Historically some implementations have used a vertical line character
"\|" instead of a colon ":" in the drive letter construct.  {{RFC3986}}
forbids the use of the vertical line, however it may be necessary to
interpret or update old URIs.

For interpreting such URIs, the `auth-path` and `local-path` rules in
{{syntax}} and the `drive-letter` rule above are replaced with the
following:

~~~~~~~~~~
   auth-path      = [ file-auth ] path-absolute
                  / [ file-auth ] file-absolute

   local-path     = [ drive-letter ] path-absolute
                  / file-absolute

   file-absolute  = "/" drive-letter path-absolute

   drive-letter   = ALPHA ":"
                  / ALPHA "|"
~~~~~~~~~~

This is intended to support regular DOS or Windows file URIs with
vertical line characters in the drive letter construct.  E.g.:

* `file:///c|/path/to/file`
* `file:/c|/path/to/file`
* `file:c|/path/to/file`

To update such an old URI, replace the vertical line "\|" with a
colon ":".


## UNC Strings  {#ext-unc}

A UNC filespace selector string can be directly translated to a
URI; see {{encoding}}.  The following is an algorithmic description
of the process of translating a UNC string to a file URI:


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


## UNC Paths  {#ext-unc-path}

It is common to encounter file URIs that encode entire UNC strings in
the path, usually with all backslash "\\" characters replaced with
slashes "/".

To interpret such URIs, the `auth-path` rule in {{syntax}} is replaced
with the following:

~~~~~~~~~~
   auth-path      = [ file-auth ] path-absolute
                  / unc-authority path-absolute

   unc-authority  = 2*3"/" [ userinfo "@" ] file-host

   file-host      = inline-IP / IPv4address / reg-name

   inline-IP      = "%5B" ( IPv6address / IPvFuture ) "%5D"
~~~~~~~~~~

This syntax uses the `userinfo`, `IPv4address, `IPv6address`,
`IPvFuture`, and `reg-name` rules from {{RFC3986}}.

> Note that the `file-host` rule is the same as `host` but with
> percent-encoding applied to "[" and "]" characters.

This extended syntax is intended to support URIs that take the
following forms, in addition to those in {{examples}}:

Non-local files:

* The "traditional" representation of a non-local file, with an empty
  authority and a complete (transformed) UNC string in the path.  E.g.:

  * `file:////host.example.com/path/to/file`

* As above, with an extra slash between the empty authority and the
  transformed UNC string, conformant with the definition from
  {{RFC1738}}.  E.g.:

  * `file://///host.example.com/path/to/file`

  This representation is notably used by the Firefox web browser.
  See Bugzilla#107540 [Bug107540].

It also further limits the set of file URIs that can be translated to
a local file path to those with a path that does not encode a UNC
string.


## Backslash as Separator  {#ext-backslash}

Historically some implementations have copied entire file paths into
the path components of file URIs.  Where DOS or Windows file paths were
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
| encoding of the file system:
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
see: SMB {{MS-SMB}}, NFS {{RFC7530}}, NCP {{NOVELL}}.

# Collected Rules  {#collected}

Here are the collected syntax rules for all optional appendices,
presented for convenience.  This collected syntax is not normative.

~~~~~~~~~~
   file-URI       = file-scheme ":" file-hier-part

   file-scheme    = "file"

   file-hier-part = "//" auth-path
                  / local-path

   auth-path      = [ file-auth ] path-absolute
                  / [ file-auth ] file-absolute
                  / unc-authority path-absolute

   local-path     = [ drive-letter ] path-absolute
                  / file-absolute

   file-auth      = [ userinfo "@" ] host

   unc-authority  = 2*3"/" [ userinfo "@" ] file-host

   file-host      = inline-IP / IPv4address / reg-name

   inline-IP      = "%5B" ( IPv6address / IPvFuture ) "%5D"

   file-absolute  = "/" drive-letter path-absolute

   drive-letter   = ALPHA ":"
                  / ALPHA "|"
~~~~~~~~~~

This collected syntax is intended to support file URIs that take the
following forms:

Local files:

* A traditional file URI for a local file, with an empty authority.
  E.g.:

  * `file:///path/to/file`

* The minimal representation of a local file, with no authority
  field and an absolute path that begins with a slash "/".  E.g.:

  * `file:/path/to/file`

* The minimal representation of a local file in a DOS- or
  Windows-based environment, with no authority field and an
  absolute path that begins with a drive letter.  E.g.:

  * `file:c:/path/to/file`

* Regular DOS or Windows file URIs, with vertical line characters
  in the drive letter construct.  E.g.:

  * `file:///c|/path/to/file`
  * `file:/c|/path/to/file`
  * `file:c|/path/to/file`

Non-local files:

* The representation of a non-local file, with an explicit authority.
  E.g.:

  * `file://host.example.com/path/to/file`

* The "traditional" representation of a non-local file, with an
  empty authority and a complete (transformed) UNC string in the
  path.  E.g.:

  * `file:////host.example.com/path/to/file`

* As above, with an extra slash between the empty authority and the
  transformed UNC string.  E.g.:

  * `file://///host.example.com/path/to/file`

