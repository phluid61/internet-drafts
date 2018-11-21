---
title: The file URI Scheme
abbrev: rfc8089-bis-core
docname: draft-kerwin-rfc8089-bis-core-00
date: 2018
category: std

ipr: trust200902
area: General
workgroup: Applications Area Working Group
keyword: Internet-Draft

obsoletes: 8089

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

informative:
  Bash-Tilde:
    title: "Bash Reference Manual: Tilde Expansion"
    author:
    - organization: Free Software Foundation, Inc
    date: 2014-02-02
    target: http://www.gnu.org/software/bash/manual/html_node/Tilde-Expansion.html
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
  MS-DTYP:
    title: Windows Data Types, 2.2.57 UNC
    author:
    - organization: Microsoft Open Specifications
      #url: http://www.microsoft.com/openspecifications/en/us/default.aspx
    date: 2015-10-16
    target: http://msdn.microsoft.com/en-us/library/gg465305.aspx
  POSIX:
    title: IEEE 1003.1-2017 - IEEE Standard for Information Technology--Portable Operating System Interface (POSIX(R)) Base Specifications, Issue 7
    #abbrev: POSIX.1-2017
    author:
    - organization: IEEE
    date: 2017
  UAX15:
    title: "Unicode Standard Annex #15: Unicode Normalization Forms"
    author:
    - ins: M. Davis
      name: Mark Davis
      #email: markdavis@google.com
      role: editor
    - ins: K. Whistler
      name: Ken Whistler
      #email: ken@unicode.org
      role: editor
    date: 2016-02-24
    target: http://www.unicode.org/reports/tr15/tr15-44.html
  UNICODE:
    title: The Unicode Standard, Version 9.0.0
    author:
    - organization: The Unicode Consortium
      #city: Mountain View
      #region: CA
    date: 2016-06-21
    seriesinfo:
      ISBN: 978-1-936213-13-9
    target: http://www.unicode.org/versions/Unicode9.0.0/
  WHATWG-URL:
    title: URL Standard
    author:
    - organization: WHATWG
      #url: http://www.whatwg.org/
    date: 2016-12-09
    target: https://url.spec.whatwg.org/
  Win32-Namespaces:
    title: Naming Files, Paths, and Namespaces
    author:
    - organization: Microsoft Developer Network
    date: 2013-06
    target: https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
  Zsh-Tilde:
    title: "zsh: 14.7 Filename Expansion"
    #author:
    #- organization: Zsh Web Page Maintainers
    date: 2015-12-08
    target: http://zsh.sourceforge.net/Doc/Release/Expansion.html#Filename-Expansion
  draft-kerwin-rfc8089-bis-info:
    title: Using the file URI Scheme
    author:
    - ins: M. Kerwin
      name: M. Kerwin
    date: 2018


--- abstract

This document provides a specification of the "file" Uniform Resource
Identifier (URI) scheme.  It defines a common syntax which is
intended to interoperate across the broad spectrum of existing
usages.  It obsoletes RFC 8089.


--- note_Note_to_Readers

This draft should be discussed on the IETF Applications Area Working
Group discussion list \<apps-discuss@ietf.org>.


--- middle

# Introduction

A file URI identifies an object (a "file") stored in a structured
object naming and accessing environment on a host (a "file system.")
The URI can be used in discussions about the file, and if other
conditions are met it can be dereferenced to directly access the file.

This document specifies a syntax based on the generic syntax of
{{!RFC3986}} that is compatible with most existing usages.  Where
incompatibilities arise they are usually in parts of the scheme that
were underspecified in earlier definitions and have been tightened up
by more recent specifications.  {{diff}} lists significant changes
from historical syntax definitions.

Extensions to the syntax which might be encountered in practice are
listed in {{draft-kerwin-rfc8089-bis-info}};  those extensions are
given for informational purposes and are not a requirement of
implementation.

The file URI scheme is not coupled with a specific protocol, nor with a
specific media type {{?RFC6838}}.  See {{operations}} for a discussion
of operations that can be performed on the object identified by a file
URI.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in
BCP 14 {{!RFC2119}} {{!RFC8174}} when, and only when, they appear in
all capitals, as shown here.

Throughout this document the term "local file" is used to describe
files that can be accessed through the local file system API using only
the information included in the file path, not relying on other
information (such as network addresses.)  It is important to note that
a local file may not be physically located on the local machine, for
example if a networked file system is transparently mounted into the
local file system.

The term "local file URI" is used to describe file URIs which have
no `authority` component, or where the authority is the special string
"localhost" or a fully qualified domain name that resolves to the
machine from which the URI is being interpreted ({{syntax}}).


# Syntax {#syntax}

The file URI syntax is defined here in Augmented Backus-Naur Form (ABNF)
{{!RFC5234}}, importing the `host` and `path-absolute` rules from
{{!RFC3986}} (as updated by {{!RFC6874}}), and `ALPHA` from
{{!RFC5234}}.

The generic syntax in {{!RFC3986}} includes `path` and `authority`
components, for each of which only a subset is used in the definition
of the file URI scheme.  The relevant subset of `path` is
`path-absolute`, and the subset of `authority` is `file-auth`, given
below.

The syntax definition below is different from those given in previous
definitions.  {{diff}} enumerates significant differences.

~~~~~~~~~~
   file-URI       = file-scheme ":" file-hier-part

   file-scheme    = "file"        ; case-insensitive

   file-hier-part = ( "//" auth-path )
                  / local-path

   auth-path      = [ file-auth ] path-absolute

   local-path     = path-absolute
                  / ( drive-letter path-absolute )

   drive-letter   = ALPHA ":"     ; case-insensitive

   file-auth      = "localhost"   ; RFC 3986 "authority", as
                  / host          ;  applicable to a file URI
~~~~~~~~~~


Past specifications mandated an authority component preceded by two
slash characters ("//") in all file URIs;  however in practice
implementations have relaxed this requirement so the `file-hier-part`
rule includes a `local-path` option without an authority component.

The `file-auth` rule can match either:

* the string "localhost", which is interpreted as "the machine from
  which the URI is being interpreted" exactly as if no authority were
  present; or:

* `host` -- the fully qualified domain name of the system on which
  the file is accessible.  It informs a client on another system that
  it cannot access the file system, or perhaps that it needs to use
  some other local mechanism to access the file.

Various implementations have mixed these definitions, for example
interpreting "localhost" as a remote host name, or treating any host
name as "localhost".  So while users and systems MAY include an
`auth-path` when creating a file URI, to maximize compatibility with
previous specifications, they SHOULD NOT include a `file-auth` in the
`auth-path` of any file URI they create.

The path component represents the absolute path to the file in the
file system.  Note that both `auth-path` and `local-path` use the
`path-absolute` rule which begins with a slash character ("/").  In
the case of `auth-path` the slash serves both to separate the path
from the authority, and to represent the {{POSIX}} convention that a
path beginning with a slash character is relative to the root of the
file system.  In `local-path` it solely represents the {{POSIX}}
convention, and MAY be omitted before the drive letter when
representing an absolute path in a MS-DOS or Windows file system.

Some file systems have case-sensitive file naming and some do not.  As
such the file URI scheme supports case sensitivity, in order to retain
the case as given.  Any transport-related handling of the file URI
scheme MUST retain the case as given.  Any mapping to or from a
case-insensitive form is solely the responsibility of the implementation
processing the file URI on behalf of the referenced file system.


# Operations Involving file URIs  {#operations}

See the POSIX file and directory operations {{POSIX}} for examples of
standardized operations that can be performed on files.

A file URI can be dependably dereferenced or translated to a local file
path only if it is local.  A file URI is considered "local" if it has
no `file-auth`, or the `file-auth` is the special string "localhost" or
a fully qualified domain name that resolves to the machine from which
the URI is being interpreted ({{syntax}}).

This specification neither defines nor forbids any set of operations
that might be performed on a file identified by a non-local file URI.


# File System Name Encoding {#encoding}

File systems use various encoding schemes to store file and directory
names.  Many modern file systems store file and directory names as
arbitrary sequences of octets, in which case the representation as an
encoded string often depends on the user's localization settings or
defaults to UTF-8 {{STD63}}.

When a file URI is produced that represents textual data consisting of
characters from the Unicode Standard coded character set {{UNICODE}},
the data SHOULD be encoded as octets according to the UTF-8 character
encoding scheme {{STD63}} before percent-encoding is applied; as per
{{!RFC3986}}, Section 2.5.

A decision not to use percent-encoded UTF-8 is outside the scope of
this specification.  It will typically require the use of heuristics or
explicit knowledge about the way the string will be processed.


# Security Considerations {#security}

There are many security considerations for URI schemes discussed in
{{!RFC3986}}.

File access and the granting of privileges for specific operations
are complex topics, and the use of file URIs can complicate the
security model in effect for file privileges.

Historically, user agents have granted content from the file URI
scheme a tremendous amount of privilege.  However, granting all local
files such wide privileges can lead to privilege escalation attacks.
Some user agents have had success granting local files directory-based
privileges, but this approach has not been widely adopted.  Other user
agents use globally unique identifiers as the origin for each file URI
{{!RFC6454}}, which is the most secure option.

Treating a non-local file URI as local or otherwise attempting to
perform local operations on a non-local URI can result in security
problems.
<!-- Barry Lieba - 2016-11-30 -->

File systems typically assign an operational meaning to special
characters, such as the "/", "\\", ":", "\[", and "]" characters, and
to special device names like ".", "..", "...", "aux", "lpt", etc.
In some cases, merely testing for the existence of such a name will
cause the operating system to pause or invoke unrelated system calls,
leading to significant security concerns regarding denial of service
and unintended data transfer.  It would not be possible for this
specification to list all such significant characters and device names.
Implementers should research the reserved names and characters for the
types of storage device that may be attached to their application and
restrict the use of data obtained from URI components accordingly.

File systems vary in the way they handle case.  Care must be taken to
avoid issues resulting from possibly unexpected aliasing from case-only
differences between file paths or URIs, or from mismatched encodings or
Unicode equivalences {{UAX15}} (see {{encoding}}).


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
:  Used in development libraries, such as:

   * Windows Shell (PathCreateFromUrl, UrlCreateFromPath).

   * libwww-perl - The World-Wide Web library for Perl.

Contact:
:  Applications and Real-Time Area \<art@ietf.org>

Change Controller:
:  This scheme is registered under the IETF tree.  As such, the IETF
   maintains change control.

References:
:  This RFC.
{: vspace="0"}


# Acknowledgements

This document is derived directly from {{?RFC8089}}.  All thanks
and acknowledgements in that document apply equally to this.


--- back

# Differences from Previous Specifications  {#diff}

The syntax definition in {{syntax}} inherits incremental differences
from the general syntax of {{?RFC1738}} made by {{?RFC2396}}
({{?RFC2396}}, Appendix G) and {{!RFC3986}} ({{!RFC3986}}, Appendix D).

According to the definition in {{?RFC1738}} a file URL always started
with the token "file://", followed by an (optionally blank) host name
and a "/".  The syntax given in {{syntax}} makes the entire authority
component, including the double slashes "//", optional.

Further, according to {{?RFC1738}} the initial slash character "/"
after the authority was not defined as part of the path component,
where {{!RFC3986}} includes the slash in the path.  As such, in more
modern implementations the path component is often interpreted as a
complete file path, including sequences of empty path segments
(represented as subsequence slashes).

The definition specified in {{?RFC8089}} did not allow for file URIs
with no authority component that start with a MS-DOS or Windows drive
letter (for example "file:c:/").  That syntax is allowed in this
specification.


# Example URIs  {#examples}

The syntax in {{syntax}} is intended to support file URIs that take the
following forms:

Local files:

* A traditional file URI for a local file, with an empty authority.
  This is the most common format in use today. E.g.:

  * `file:///path/to/file`

* The minimal representation of a local file, with no authority field
  and an absolute path that begins with a slash "/" or MS-DOS or
  Windows drive letter. E.g.:

  * `file:/path/to/file`
  * `file:c:/path/to/file`

Non-local files:

* A non-local file, with an explicit authority. E.g.:

  * `file://host.example.com/path/to/file`


# Similar Technologies

* The WHATWG URL specification {{WHATWG-URL}} defines browser behavior
  for a variety of inputs, including file URIs.  As a living document,
  it changes to reflect updates in browser behavior.  As a result, its
  algorithms and syntax definitions may or may not be consistent with
  this specification.  Implementors should be aware of this possible
  discrepancy if they expect to share file URIs with browsers that
  follow the WHATWG specification.

* The Universal Naming Convention (UNC) {{MS-DTYP}} defines a string
  format that can perform a similar role to the file URI scheme in
  describing the location of files, except that files located by UNC
  filespace selector strings are typically stored on a remote machine
  and accessed using a network protocol.

* The Microsoft Windows API defines Win32 Namespaces
  {{Win32-Namespaces}} for interacting with files and devices using
  Windows API functions.  These namespaced paths are prefixed by
  "\\\\?\\" for Win32 File Namespaces and "\\\\.\\" for Win32 Device
  Namespaces.  There is also a special case for UNC file paths in Win32
  File Namespaces, referred to as "Long UNC", using the prefix
  "\\\\?\\UNC\\".  This specification does not define a mechanism for
  translating namespaced paths to or from file URIs.


# System-Specific Operations  {#system-specific}

This appendix is not normative, and does not include requirements for
conformance or interoperability.  It highlights some observed
behaviours and provides system-specific guidance for interacting
with file URIs and file system paths.

This is not an exhaustive list of operating or file systems;  rather,
it is intended to illustrate certain types of interactions that
might be encountered.


## POSIX Systems  {#sys-unix}

In a POSIX file system the root of the file system is represented as a
directory with a zero-length name, usually written as "/";  the
presence of this root in a file URI can be taken as given by the
initial slash in the `path-absolute` rule.

Common UNIX shells such as the Bourne-Again SHell (bash) and Z Shell
(zsh) provide a function known as "tilde expansion" {{Bash-Tilde}} or
"filename expansion" {{Zsh-Tilde}}, where a path that begins with a
tilde character "~" can be expanded out to a special directory name.
No such facility exists using the file URI scheme;  a tilde in a file
URI is always just a tilde.


## MS-DOS and Windows Systems  {#sys-dos}

When mapping a MS-DOS or Windows file path to a file URI, the drive
letter (e.g. "c:") is typically mapped into the first path segment.

{{draft-kerwin-rfc8089-bis-info}} lists some nonstandard techniques
for interacting with MS-DOS or Windows file paths and URIs.


## Mac OS X Systems  {#sys-osx}

The HFS+ file system uses a nonstandard normalization form, similar
to Normalization Form D {{UAX15}}.  Take care when transforming HFS+
file paths to and from URIs ({{encoding}}).


## OpenVMS Files-11 Systems  {#sys-vms}

When mapping a VMS file path to a file URI, the device name is mapped
into the first path segment.  Note that the dollars sign "\$" is
a reserved character per the definition in {{RFC3986}}, Section 2.2,
so should be percent-encoded if present in the device name.

If the VMS file path includes a node reference, that reference is used
as the authority.  Where the original node reference includes a user
name and password in an access control string, they can be transcribed
into the authority using a nonstandard syntax extension described in
{{draft-kerwin-rfc8089-bis-info}}.

