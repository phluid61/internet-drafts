---
title: The file URI Scheme
abbrev: file-scheme
docname: draft-ietf-appsawg-file-scheme-15
date: 2016
category: std

ipr: trust200902
area: General
workgroup: Applications Area Working Group
keyword: Internet-Draft

#obsoletes: 1738
updates: 1738

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
  RFC2119:
  RFC3986:
  RFC5234:
  RFC6454:
  RFC6874:
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
  RFC1630:
  RFC1738:
  RFC2396:
  RFC6838:
  Bash-Tilde:
    title: "Bash Reference Manual: Tilde Expansion"
    author:
    - organization: Free Software Foundation, Inc
    date: 2014-02-02
    target: http://www.gnu.org/software/bash/manual/html_node/Tilde-Expansion.html
  WHATWG-URL:
    title: URL Living Standard
    author:
    - organization: WHATWG
      #url: http://www.whatwg.org/
    date: 2013-05
    target: http://url.spec.whatwg.org/
  MS-DTYP:
    title: Windows Data Types, 2.2.57 UNC
    author:
    - organization: Microsoft Open Specifications
      #url: http://www.microsoft.com/openspecifications/en/us/default.aspx
    date: 2015-10-16
    target: http://msdn.microsoft.com/en-us/library/gg465305.aspx
  POSIX:
    title: IEEE Std 1003.1, 2013 Edition
    #abbrev: POSIX.1-2008
    author:
    - organization: IEEE
    date: 2013
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

  Bug107540:
    title: Bug 107540
    author:
    - organization: Bugzilla@Mozilla
    date: 2007-10
    target: https://bugzilla.mozilla.org/show_bug.cgi?id=107540


--- abstract

This document provides a more complete specification of the "file"
Uniform Resource Identifier (URI) scheme, replacing the very brief
definition in Section 3.10 of RFC 1738.

It defines a common syntax which is intended to interoperate across
the broad spectrum of existing usages.  At the same time it notes
some other current practices around the use of file URIs.

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
{{RFC3986}} that is compatible with most existing usages.  Where
incompatibilities arise they are usually in parts of the scheme that
were underspecified in earlier definitions and have been tightened up
by more recent specifications.  {{diff}} lists significant changes to
syntax.

Extensions to the syntax which might be encountered in practice are
listed in {{nonstandard-syntax}};  these extensions are listed for
informational purposes and are not a requirement of implementation.

The file URI scheme is not coupled with a specific protocol, nor with a
specific media type {{RFC6838}}.  See {{operations}} for a discussion
of operations that can be performed on the object identified by a file
URI.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}} when they
appear in all upper case.  They may also appear in lower or mixed case
as English words, without normative meaning.

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
{{RFC5234}}, importing the `host` and `path-absolute` rules from
{{RFC3986}} (as updated by {{RFC6874}}.)

The generic syntax in {{RFC3986}} includes `path` and `authority`
components, for each of which only a subset is used in the definition
of the file URI scheme.  The relevant subset of `path` is
`path-absolute`, and the subset of `authority` is `file-auth`, given
below.

The syntax definition below is different from those given in
{{RFC1630}} and {{RFC1738}} as it is derived from the generic syntax
of {{RFC3986}}, which post-dates the previous file URI specifications.
{{diff}} enumerates significant differences.

~~~~~~~~~~
   file-URI       = file-scheme ":" file-hier-part

   file-scheme    = "file"

   file-hier-part = ( "//" auth-path )
                  / local-path

   auth-path      = [ file-auth ] path-absolute

   local-path     = path-absolute

   file-auth      = "localhost"
                  / host
~~~~~~~~~~

The `host` is the fully qualified domain name of the system on which
the file is accessible.  This allows a client on another system to know
that it cannot access the file system, or perhaps that it needs to use
some other local mechanism to access the file.

As a special case, the `file-auth` rule can match the string
"localhost" which is interpreted as "the machine from which the URI is
being interpreted," exactly as if no authority were present.
Some current usages of the scheme incorrectly interpret all values in
the authority of a file URI, including "localhost", as non-local.
Yet others interpret any value as local, even if the `host` does not
resolve to the local machine.
To maximize compatibility with previous specifications, users MAY
choose to include an `auth-path` with no `file-auth` when creating a
URI.

The path component represents the absolute path to the file in the file
system.  See {{system-specific}} for some discussion of system-specific
concerns including absolute file paths and file system roots.

Some file systems have case-sensitive file naming and some do not.  As
such the file URI scheme supports case sensitivity, in order to retain
the case as given.  Any transport-related handling of the file URI
scheme MUST retain the case as given.  Any mapping to or from a
case-insensitive form is solely the responsibility of the implementation
processing the file URI on behalf of the referenced file system.

Also see {{nonstandard-syntax}} that lists some nonstandard syntax
variations that can be encountered in practice.


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
encoded string often depends on the user's localization settings, or
defaults to UTF-8 {{STD63}}.

When a file URI is produced that represents textual data consisting of
characters from the Unicode Standard coded character set {{UNICODE}},
the data SHOULD be encoded as octets according to the UTF-8 character
encoding scheme {{STD63}} before percent-encoding is applied; as per
{{RFC3986}}, Section 2.5.

A decision not to use percent-encoded UTF-8 is outside the scope of
this specification.  It will typically require the use of heuristics or
explicit knowledge about the way the string will be processed.


# Security Considerations {#security}

There are many security considerations for URI schemes discussed in
{{RFC3986}}.

File access and the granting of privileges for specific operations
are complex topics, and the use of file URIs can complicate the
security model in effect for file privileges.

Historically, user agents have granted content from the file URI
scheme a tremendous amount of privilege.  However, granting all local
files such wide privileges can lead to privilege escalation attacks.
Some user agents have had success granting local files directory-based
privileges, but this approach has not been widely adopted.  Other user
agents use globally unique identifiers as the origin for each file URI
{{RFC6454}}, which is the most secure option.

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
and unintended data transfer.  It would be impossible for this
specification to list all such significant characters and device names.
Implementers MUST research the reserved names and characters for the
types of storage device that may be attached to their application and
restrict the use of data obtained from URI components accordingly.

File systems vary in the way they handle case.  Care MUST be taken to
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

Contributions from many members of the IETF and W3C communities --
notably Dave Crocker, Graham Klyne, Tom Petch, and John Klensin -- are
greatly appreciated.

Additional thanks to Dave Risney, author of the informative IE Blog article
\<http://blogs.msdn.com/b/ie/archive/2006/12/06/file-uris-in-windows.aspx>,
and Dave Thaler for their early comments and suggestions; and to Paul
Hoffman, whose earlier work served as an inspiration for this undertaking.


--- back

# Differences from Previous Specifications  {#diff}

The syntax definition in {{syntax}} inherits incremental differences
from the general syntax of {{RFC1738}} made by {{RFC2396}}
({{RFC2396}}, Appendix G) and {{RFC3986}} ({{RFC3986}}, Appendix D).


According to the definition in {{RFC1738}} a file URL always started
with the token "file://", followed by an (optionally blank) host name
and a "/".  The syntax given in {{syntax}} makes the entire authority
component, including the double slashes "//", optional.


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


# Similar Technologies

* The WHATWG defines a living URL standard {{WHATWG-URL}}, which
  includes algorithms for interpreting file URIs (as URLs).

* The Universal Naming Convention (UNC) {{MS-DTYP}} defines a string
  format that can perform a similar role to the file URI scheme in
  describing the location of files, except that files located by UNC
  filespace selector strings are typically stored on a remote machine
  and accessed using a network protocol.  {{ext-unc}} lists some ways
  in which UNC filespace selector strings are currently made to
  interoperate with the file URI scheme.

* The Microsoft Windows API defines Win32 Namespaces
  {{Win32-Namespaces}} for interacting with files and devices using
  Windows API functions.  These namespaced paths are prefixed by
  "\\\\?\\" for Win32 File Namespaces and "\\\\.\\" for Win32 Device
  Namespaces.  There is also a special case for UNC file paths in Win32
  File Namespaces, referred to as "Long UNC", using the prefix
  "\\\\?\\UNC\\".  This specification does not define a mechanism for
  translating namespaced paths to or from file URIs.


# System-Specific Operations  {#system-specific}

This appendix is not normative.  It highlights some observed
behaviours and provides system-specific guidance for interacting
with file URIs and paths.  This is not an exhaustive list of operating
or file systems;  rather it is intended to illustrate certain types
of interactions that might be encountered.


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


## DOS- and Windows-Like Systems  {#sys-dos}

When mapping a DOS- or Windows-like file path to a file URI, the drive
letter (e.g. "c:") is typically mapped into the first path segment.

{{nonstandard-syntax}} lists some nonstandard techniques for
interacting with DOS- or Windows-like file paths and URIs.


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
into the authority using the nonstandard syntax extension in
{{ext-userinfo}}.


# Nonstandard Syntax Variations  {#nonstandard-syntax}

These variations may be encountered by existing usages of the file URI
scheme, but are not supported by the normative syntax of {{syntax}}.

This appendix is not normative.


## User Information  {#ext-userinfo}

It might be necessary to include user information such as a user name in
a file URI, for example when mapping a VMS file path with a node
reference that includes an access control string.

To allow user information to be included in a file URI, the `file-auth`
rule in {{syntax}} can be replaced with the following:

~~~~~~~~~~
   file-auth      = "localhost"
                  / [ userinfo "@" ] host
~~~~~~~~~~

This uses the `userinfo` rule from {{RFC3986}}.

As discussed in the HP OpenVMS Systems Documentation
\<http://h71000.www7.hp.com/doc/84final/ba554_90015/ch03s09.html>
"access control strings include sufficient information to allow someone
to break in to the remote account, \[therefore\] they create serious
security exposure."  In a similar vein, the presence of a password in a
"user:password" userinfo field is deprecated by {{RFC3986}}.  Take care
when dealing with information that can be used to identify a user or
grant access to a system.


## DOS and Windows Drive Letters  {#ext-drives}

On Windows- or DOS-like file systems an absolute file path can begin
with a drive letter.  To facilitate this, the `local-path` rule in
{{syntax}} can be replaced with the following:

~~~~~~~~~~
   local-path     = [ drive-letter ] path-absolute

   drive-letter   = ALPHA ":"
~~~~~~~~~~

The `ALPHA` rule is defined in {{RFC5234}}.

This is intended to support the minimal representation of a local file
in a DOS- or Windows-like environment, with no authority field and an
absolute path that begins with a drive letter.  E.g.:

* `file:c:/path/to/file`

URIs of the form `file:///c:/path/to/file` are already supported by the
`path-absolute` rule.

Note that comparison of drive letters in DOS or Windows file paths
is case-insensitive.  In some usages of file URIs drive letters are
canonicalized by converting them to uppercase, and other usages treat
URIs that differ only in the case of the drive letter as identical.


### Relative Resolution  {#ext-relative}

To mimic the behaviour of DOS- or Windows-like file systems, relative
references beginning with a slash "/" can be resolved relative to the
drive letter, when present;  and resolution of ".." dot segments (per
Section 5.2.4 of {{RFC3986}}) can be modified to not ever overwrite the
drive letter.

For example:

~~~~~~~~~~
   base URI:   file:///c:/path/to/file.txt
   rel. ref.:  /some/other/thing.bmp
   resolved:   file:///c:/some/other/thing.bmp

   base URI:   file:///c:/foo.txt
   rel. ref.:  ../bar.txt
   resolved:   file:///c:/bar.txt
~~~~~~~~~~

A relative reference starting with a drive letter would be interpreted
by a generic URI parser as a URI with the drive letter as its scheme.
Instead such a reference ought to be constructed with a leading slash
"/" character (e.g. "/c:/foo.txt").

Relative references with a drive letter followed by a character other
than a slash (e.g. "/c:bar/baz.txt" or "/c:../foo.txt") might not be
accepted as dereferenceable URIs in DOS- or Windows-like systems.


### Vertical Line Character  {#ext-pipe}

Historically some usages of file URIs have included a vertical line
character "\|" instead of a colon ":" in the drive letter construct.
{{RFC3986}} forbids the use of the vertical line, however it may be
necessary to interpret or update old URIs.

For interpreting such URIs, the `auth-path` and `local-path` rules in
{{syntax}} and the `drive-letter` rule above can be replaced with the
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

Some usages of the file URI scheme allow UNC filespace selector strings
{{MS-DTYP}} to be translated to and from file URIs, either by mapping
the equivalent segments of the two schemes (hostname to authority,
sharename+objectnames to path), or by mapping the entire UNC string to
the path segment of a URI.


### file URI with Authority  {#ext-unc-map}

The following is an algorithmic description of the process of
translating a UNC filespace selector string to a file URI by
mapping the equivalent segments of the two schemes:


1.  Initialize the URI with the "file:" scheme identifier.

2.  Append the authority:

    1.  Append the "//" authority sigil to the URI.

    2.  Append the host-name field of the UNC string to the URI.

3.  Append the share-name:

    1.  Transform the share-name to a path segment ({{RFC3986}},
        Section 3.3) to conform to the encoding rules of Section 2 of
        {{RFC3986}}.

    2.  Append a delimiting slash character "/" and the transformed
        segment to the URI.

4.  For each object-name:

    1.  Transform the objectname to a path segment as above.

        The colon character ":" is allowed as a delimiter before
        stream-name and stream-type in the file-name, if present.

    2.  Append a delimiting slash character "/" and the transformed
        segment to the URI.


For example:

~~~~~~~~~~
   UNC String:   \\host.example.com\Share\path\to\file.txt
   URI:          file://host.example.com/Share/path/to/file.txt
~~~~~~~~~~

The inverse algorithm, for translating a file URI to a UNC filespace
selector string, is left as an exercise for the reader.


### file URI with UNC Path  {#ext-unc-path}

It is common to encounter file URIs that encode entire UNC strings in
the path, usually with all backslash "\\" characters replaced with
slashes "/".

To interpret such URIs, the `auth-path` rule in {{syntax}} can be
replaced with the following:

~~~~~~~~~~
   auth-path      = [ file-auth ] path-absolute
                  / unc-authority path-absolute

   unc-authority  = 2*3"/" file-host

   file-host      = inline-IP / IPv4address / reg-name

   inline-IP      = "%5B" ( IPv6address / IPvFuture ) "%5D"
~~~~~~~~~~

This syntax uses the `IPv4address`, `IPv6address`, `IPvFuture`,
and `reg-name` rules from {{RFC3986}}.

> Note that the `file-host` rule is the same as `host` but with
> percent-encoding applied to "\[" and "]" characters.

This extended syntax is intended to support URIs that take the
following forms, in addition to those in {{examples}}:

Non-local files:

* The representation of a non-local file, with an empty authority and a
  complete (transformed) UNC string in the path.  E.g.:

  * `file:////host.example.com/path/to/file`

* As above, with an extra slash between the empty authority and the
  transformed UNC string, as per the syntax defined in {{RFC1738}}.
  E.g.:

  * `file://///host.example.com/path/to/file`

  This representation is notably used by the Firefox web browser.
  See Bugzilla#107540 [Bug107540].

It also further limits the definition of a "local file URI" by
excluding any file URI with a path that encodes a UNC string.


## Backslash as Separator  {#ext-backslash}

Historically some usages have copied entire file paths into the path
components of file URIs.  Where DOS or Windows file paths were thus
copied the resulting URI strings contained unencoded backslash "\\"
characters, which are forbidden by both {{RFC1738}} and {{RFC3986}}.

It may be possible to translate or update such an invalid file URI by
replacing all backslashes "\\" with slashes "/", if it can be
determined with reasonable certainty that the backslashes are intended
as path separators.


# Collected Nonstandard Rules  {#collected}

Here are the collected syntax rules for all optional appendices,
presented for convenience.  This collected syntax is not normative.

~~~~~~~~~~
   file-URI       = file-scheme ":" file-hier-part

   file-scheme    = "file"

   file-hier-part = ( "//" auth-path )
                  / local-path

   auth-path      = [ file-auth ] path-absolute
                  / [ file-auth ] file-absolute
                  / unc-authority path-absolute

   local-path     = [ drive-letter ] path-absolute
                  / file-absolute

   file-auth      = "localhost"
                  / [ userinfo "@" ] host

   unc-authority  = 2*3"/" file-host

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

