---
title: HTTP/2 Segments
abbrev: http2-segments
docname: draft-kerwin-http2-segments-03
date: 2016
category: exp

ipr: trust200902
area: General
workgroup: 
keyword: Internet-Draft

stand_alone: yes
pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
 - ins: M. Kerwin
   name: Matthew Kerwin
   organization: 
   email: matthew@kerwin.net.au
   uri: http://matthew.kerwin.net.au/

normative:
  RFC2119:
  I-D.ietf-httpbis-http2:

informative:


--- abstract

This document introduces the concept of "segments" to HTTP/2, and adds a
flag to the DATA frame type to allow the expression segments.

A "segment" is a contiguous block of HTTP message data that can be freely
split apart and recombined at any time, allowing transmission in multiple
HTTP/2 frames across network segments with smaller frame size limits
without risk of permanent fragmentation when traversing network segments
with much larger limits.

--- middle

# Introduction

This document extends HTTP/2 {{I-D.ietf-httpbis-http2}} by introducing
the concept of "segments" to HTTP/2, as a mechanism to combat the
effects of fragmentation within a stream. It does this by adding a new
flag to the DATA frame type ({{I-D.ietf-httpbis-http2}}, Section 6.1).

## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.


# Segments  {#segments}

A "segment" is a contiguous region of a HTTP/2 message's payload data
which can be freely fragmented and recombined. A segment is expressed
using the SEGMENT and SEGMENT\_CONTINUES flags ({{flag}}). Any data
within a frame that does not have the SEGMENT or SEGMENT\_CONTINUES
flags set and that does not follow a frame with the SEGMENT\_CONTINUES
flag set does not contain any segmentation information, and MUST NOT be
included in a segment.

Segments can be used to mitigate the effects of fragmentation within a
stream. For example, an endpoint may have a large chunk of data which it
has to transmit via multiple DATA frames in order to comply with frame
size limits. It can mark those frames as a single segment so that any
downstream peer without the same frame size restrictions knows that it
can safely coalesce the frames.


# SETTINGS\_USE\_SEGMENTS Setting {#setting}

The following new SETTINGS parameter ({{I-D.ietf-httpbis-http2}},
Section 6.5.2) is defined:

* `SETTINGS_USE_SEGMENTS` (0xTBA):
  Informs the remote endpoint of whether or not the sender supports the
  SEGMENT\_CONTINUES flag ({{flag}}). A value of 1 indicates that the
  sender supports the flag. Any other value MUST be treated as a
  connection error ({{I-D.ietf-httpbis-http2}}, Section 5.4.1) of type
  PROTOCOL\_ERROR.


# SEGMENT and SEGMENT\_CONTINUES Flag  {#flag}

The following new flags are defined for the DATA frame
({{I-D.ietf-httpbis-http2}}, Section 6.1):

* `SEGMENT` (0x10):
  Bit 5 being set indicates that the current segment begins and ends
  with the current frame.

* `SEGMENT_CONTINUES` (0x20):
  Bit 6 being set indicates that the current segment continues after
  the current frame (see {{segments}}). If the preceding frame did not
  have the SEGMENT\_CONTINUES flag, the current segment begins at the
  start of the current frame.

Intermediaries MUST NOT coalesce frames across a segment boundary and
MUST preserve segment boundaries when forwarding frames.

The SEGMENT and SEGMENT\_CONTINUES flag MUST NOT be set on any frames
unless the remote endpoint has indicated support by sending a
SETTINGS\_USE\_SEGMENTS setting ({{setting}}) with a value of 1.


# Security Considerations  {#security}

In and of itself, segmentation does not introduce any security
concerns. However when used in combination with other features, such
as compression, known and unknown vulnerabilities may be introduced.
See the Use of Compression in HTTP/2 ({{I-D.ietf-httpbis-http2}},
Section 10.6).


# IANA Considerations  {#iana}

This document updates the registry for settings in the "Hypertext
Transfer Protocol (HTTP) 2 Parameters" section.

## HTTP/2 Settings Registry Update

This document updates the "HTTP/2 Settings" registry
({{I-D.ietf-httpbis-http2}}, Section 11.3). The entries in the
following table are registered by this document.

 |-------------------------|------|---------------|---------------|
 | Name                    | Code | Initial Value | Specification |
 |-------------------------|------|---------------|---------------|
 | SETTINGS\_USE\_SEGMENTS | TBD  | N/A           | {{setting}}   |
 |-------------------------|------|---------------|---------------|

--- back
