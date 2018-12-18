---
title: Using the file URI Scheme
abbrev: rfc8089-bis-info
docname: draft-kerwin-rfc8089-bis-info-00
date: 2018
category: info

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
  draft-kerwin-rfc8089-bis-core:
    title: The file URI Scheme
    author:
    - ins: M. Kerwin
      name: M. Kerwin
    date: 2018
  MS-DTYP:
    title: Windows Data Types, 2.2.57 UNC
    author:
    - organization: Microsoft Open Specifications
      #url: https://www.microsoft.com/openspecifications/en/us/default.aspx
    date: 2015-10-16
    target: https://msdn.microsoft.com/en-us/library/gg465305.aspx

informative:
  Bug107540:
    title: Bug 107540
    author:
    - organization: Bugzilla@Mozilla
    date: 2007-10
    target: https://bugzilla.mozilla.org/show_bug.cgi?id=107540
  HTML5.Location:
    title: HTML5
    author:
    - organization: The World Wide Web Consortium
    date: 2014-10-28
    target: "https://www.w3.org/TR/html50/browsers.html#the-location-interface"


--- abstract

This document describes common usages of file URIs, beyond those
prescribed -- and in some cases even allowed -- in the core
specification.


--- note_Note_to_Readers

This draft should be discussed on the GitHub repository
\<https://github.com/phluid61/internet-drafts/labels/rfc8089-bis-info>.


--- middle

# Introduction

The file URI scheme is specified in {{draft-kerwin-rfc8089-bis-core}}.
That specification defines the syntax and describes operations that
can be performed on a core subset of file URIs, necessary for basic
interoperability.  However in the real world there are many uses of
file URIs that do not conform with the core specification, but do
nevertheless exhibit common traits and behaviours.  This document
describes those cases, to provide a pathway for interoperability
beyond the core specification.


## Notational Conventions

This is not a standard, so any prescriptive or normative language is
intended to provide interoperability and/or security, but does not
describe an actual standard requirement.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in
BCP 14 {{!RFC2119}} {{!RFC8174}} when, and only when, they appear in
all capitals, as shown here.

Syntax elements are defined in Augmented Backus-Naur Form (ABNF)
{{!RFC5234}}, where possible using incremental alternative syntax to
extend the core syntax rather than replacing existing definitions.


# Nonstandard Extensions  {#extensions}

These extensions might be encountered by existing usages of the file URI
scheme, but are not supported by the core specification
{{draft-kerwin-rfc8089-bis-core}}.


## Query and Fragment Components  {#query-fragment}

Some resources include active scripts that interact with the resource's
URI, for example JavaScript inspecting the Location interface
{{HTML5.Location}} in a HTML document.  These scripts often inspect
and/or modify the query or fragment components ({{RFC3986}}, Sections
3.4 and 3.5) of the URI.  To support this behaviour for resources with
a file URI, query and fragment components may be handled thus.
\[\[FIXME\]\]


### Query  {#query-component}

\[\[The query component should not be used when dereferencing a file
URI.  This is a security risk, because multiple URIs can point at the
same file.  It also breaks equivalence.\]\]

To allow a query component to be included in a file URI the core `file-URI`
rule can be extended with the following definition:

~~~~~~~~~~
   file-URI       =/ file-scheme ":" file-hier-part "?" query
~~~~~~~~~~

This uses the `query` rule from {{!RFC3986}}.


### Fragment  {#fragment-component}

Fragment components are already syntactically supported by
{{!RFC3986}}, however the semantics of a fragment depend on the content
type of the resource representation.  The file URI scheme does not
have a mechanism for detecting or communicating the content type of
resources, but file and operating systems often do.
\[\[TODO: expand, add security concerns\]\]


## User Information  {#userinfo}

It might be necessary to include user information such as a user name in
a file URI, for example when representing a VMS file path with a node
reference that includes an access control string.

To allow user information to be included in a file URI the core `file-auth`
rule can be extended with the following definition:

~~~~~~~~~~
   file-auth      =/ userinfo "@" host
~~~~~~~~~~

This uses the `userinfo` rule from {{!RFC3986}}.

<!--
As discussed in the HP OpenVMS Guide to System Security
\<https://support.hpe.com/hpsc/doc/public/display?docId=emr_na-c04621379>
"access control strings include sufficient information to allow someone
to break in to the remote account, \[therefore\] they create serious
security exposure."
-->
The presence of a password in a "user:password" userinfo field is
deprecated by {{!RFC3986}}, Section 3.2.1.  Implementers MUST take
care when dealing with information that can be used to identify a
user or grant access to a system, including generation, transmission,
and storage of said information.


## MS-DOS and Windows Drive Letters  {#drives}

On MS-DOS or Windows file systems an absolute file path can begin
with a drive letter.  This is supported by the core syntax
explicitly in the `local-path` rule and implicitly in `auth-path`.

Note that comparison of drive letters in MS-DOS or Windows file paths
is case-insensitive.  In some usages of file URIs drive letters are
canonicalized by converting them to uppercase, and other usages treat
URIs that differ only in the case of the drive letter as identical.

Historically some usages of file URIs have misused drive letters in
several ways:

* Encoding the drive letter in the URI's authority component.

* Omitting the colon ":" from the drive letter, or replacing it with
  a vertical line "\|" character.

* A combination of the two.


### Drive Letter Authority  {#drive-authority}

To accommodate historical file URIs that have a drive letter encoded
in the authority, the core `file-auth` rule case be extended with the
following definition:

~~~~~~~~~~
   file-auth      =/ drive-letter
~~~~~~~~~~

For example:

* `file://c:/file/to/path`


### Vertical Line Character  {#pipe}

{{!RFC3986}} forbids the vertical line "\|" character from appearing
unescaped in any portion of a URI, however it might be necessary to
interpret or update old file URIs that include it.

To accommodate historical file URIs that have a vertical line "\|"
character instead of a colon ":" in the drive letter construct the
`auth-path`, `local-path`, and `drive-letter` rules in the core
specification can be extended with the following definitions:

~~~~~~~~~~
   auth-path      =/ [ file-auth ] file-absolute

   local-path     =/ file-absolute

   drive-letter   =/ ALPHA "|"

   file-absolute  = "/" drive-letter path-absolute
~~~~~~~~~~

This is intended to support MS-DOS or Windows file URIs with vertical
line characters in the drive letter construct.  For example:

* `file:///c|/path/to/file`
* `file:/c|/path/to/file`
* `file:c|/path/to/file`

It can also be paired with the expansion in {{drive-authority}}.  For
example:

* `file://c|/path/to/file`

To update such an old URI, replace the vertical line "\|" character
with a colon ":".


### Letter-Only Drive Letter {#letter-only}

To accommodate historical file URIs that don't use either a colon ":"
or vertical line "\|" character in the drive letter construct the
core `drive-letter` rule can be expanded with the following
definition:

~~~~~~~~~~
   drive-letter   =/ ALPHA
~~~~~~~~~~

For example:

* `file:///c/path/to/file`
* `file:/c/path/to/file`
* `file:c/path/to/file`

It can also be paired with the expansion in {{drive-authority}}.  For
example:

* `file://c/path/to/file`

Care MUST be taken when interpreting all such file URIs, as this
interpretation can only be applied if it can be determined with
reasonable certainty that the drive letters are intended as such.


## MS-DOS and Windows Relative Resolution  {#dos-relative}

To mimic the behaviour of MS-DOS or Windows file systems, relative
references beginning with a slash "/" SHOULD be resolved relative to
the drive letter, when present;  and resolution of ".." dot segments
(per Section 5.2.4 of {{!RFC3986}}) SHOULD be modified to not ever
overwrite the drive letter.

For example:

~~~~~~~~~~
   base URI:   file:///c:/path/to/file.txt
   rel. ref.:  /some/other/thing.bmp
   resolved:   file:///c:/some/other/thing.bmp

   base URI:   file:///c:/foo.txt
   rel. ref.:  ../bar.txt
   resolved:   file:///c:/bar.txt
~~~~~~~~~~

However given that this behaviour is not supported by the core
specification nor the generic URI specification in {{!RFC3986}},
implementations MUST take care when implementing this extension.


## UNC Strings  {#unc}

Some usages of the file URI scheme allow UNC filespace selector strings
{{MS-DTYP}} to be translated to and from file URIs, either by mapping
the entire UNC string to the path segment of a URI, or by mapping the
equivalent segments of the two schemes (hostname \<=> authority,
sharename+objectnames \<=> path),

In either case it is not uncommon to encounter a dollar sign "$" in
the sharename segment of a UNC filespace selector string, for example
"\\\\localhost\\c$\\foo.txt", or the equivalent position in a file URI.
The dollar sign symbol is a reserved character ({{!RFC3986}}, Section
2.2) but does not carry special meaning when it appears in these
positions without percent-encoding ({{!RFC3986}}, Section 2.1).


### file URI with UNC Path  {#unc-path}

It is common to encounter file URIs that encode entire UNC strings in
the path, usually with all backslash "\\" characters replaced with
slashes "/".

To interpret such URIs, the core `auth-path` rule can be extended
with the following definitions:

~~~~~~~~~~
   auth-path      =/ unc-authority path-absolute

   unc-authority  = 2*3"/" file-host

   file-host      = inline-IP / IPv4address / reg-name

   inline-IP      = "%5B" ( IPv6address / IPvFuture ) "%5D"
~~~~~~~~~~

This syntax uses the `IPv4address`, `IPv6address`, `IPvFuture`,
and `reg-name` rules from {{!RFC3986}}.

> Note that the `file-host` rule is the same as `host` but with
> percent-encoding applied to "\[" and "]" characters.

This extended syntax is intended to support URIs that take the
following forms:

* The representation of a non-local file, with an empty authority and
  a complete (transformed) UNC string in the path.  E.g.:

  * `file:////host.example.com/path/to/file`

* As above, with an extra slash between the empty authority and the
  two slashes of the transformed UNC string, as per the syntax
  defined in {{?RFC1738}}.  E.g.:

  * `file://///host.example.com/path/to/file`

  This representation is notably used by the Firefox web browser.
  See Bugzilla#107540 [Bug107540].

It also further limits the definition of a "local file URI"
({{draft-kerwin-rfc8089-bis-core}}, Section 1.1) by excluding any
file URI with a path that encodes a UNC string.


### file URI with Authority  {#unc-map}

It is less common, but not unheard of, to encounter implementations
that transform UNC filespace selector strings into file URIs and
vice versa by mapping the equivalent segments of the two schemes.

The following is an algorithmic description of the process of
translating a UNC filespace selector string to a file URI.  It
uses the syntactic elements defined in {{MS-DTYP}}.


1.  Initialize a new URI with the "file:" scheme identifier.

2.  Append the authority:

    1.  Append the "//" authority sigil to the URI.

    2.  Append the host-name field of the UNC string to the URI
        as its `host` component.  If the host-name field is the
        string "localhost" this can produce an ambiguous file URI,
        and the field SHOULD be replaced with a fully qualified
        domain name or address.

3.  Append the share-name:

    1.  Transform the share-name to a path segment ({{!RFC3986}},
        Section 3.3) to conform to the encoding rules of Section 2 of
        {{!RFC3986}}.

    2.  Append a delimiting slash character "/" and the transformed
        segment to the URI.

4.  For each object-name:

    1.  Transform the object-name to a path segment as above.

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


## Backslash as Separator  {#backslash}

Historically some usages of file URIs have naively copied entire file
paths into the path components of file URIs.  Where MS-DOS or Windows
file paths were thus copied the resulting URI strings contained
unencoded backslash "\\" characters, which are forbidden by both
{{?RFC1738}} and {{!RFC3986}}.

It might be possible to translate or update such an invalid file URI by
replacing all backslashes "\\" with slashes "/", if it can be
determined with reasonable certainty that the backslashes are intended
as path separators.


# Security Considerations

TO DO

--- back
