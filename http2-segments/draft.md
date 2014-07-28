---
title: HTTP/2 Segments
abbrev: http2-segments
docname: draft-kerwin-http2-segments-01
date: 2014
category: std

ipr: trust200902
area: General
workgroup: 
keyword: Internet-Draft

stand_alone: yes
pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
 -
    ins: M. Kerwin
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
which can be freely fragmented and recombined. A segment is expressed by
marking all but the final frame in the segment with the
`SEGMENT_CONTINUES` flag ({{flag}}). Any data-bearing frame that does
not have the `SEGMENT_CONTINUES` flag set, and does not follow one that
does, comprises a single segment.

Segments can be used to mitigate the effects of fragmentation within a
stream. For example, an endpoint may have a large chunk of data which it
has to transmit via multiple DATA frames in order to comply with frame
size limits. It can mark those frames as a single segment so that any
downstream peer without the same frame size restrictions knows that it
can safely coalesce the frames.


# SEGMENT\_CONTINUES Flag  {#flag}

The following new flag is defined for the `DATA` frame
({{I-D.ietf-httpbis-http2}}, Section 6.1):

* `SEGMENT_CONTINUES` (0x10):
  Bit 5 being set indicates that the current segment continues after
  the current frame (see {{segments}}). Intermediaries MUST NOT
  coalesce frames across a segment boundary and MUST preserve
  segment boundaries when forwarding frames.


# Security Considerations  {#security}


# IANA Considerations  {#iana}

This document has no actions for IANA.

--- back