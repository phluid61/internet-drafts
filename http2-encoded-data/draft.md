---
title: HTTP/2 Gzipped Data
abbrev: http2-encoded-data
docname: draft-kerwin-http2-encoded-data-10
date: 2016
category: exp

ipr: trust200902
area: Applications and Real-Time
workgroup: 
keyword:
- HTTP
- H2
- GZIP

stand_alone: yes
pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
 - ins: M. Kerwin
   name: Matthew Kerwin
   organization: 
   email: matthew@kerwin.net.au
   uri: http://matthew.kerwin.net.au/

normative:
  RFC1952:
  RFC2119:
  RFC7540:

informative:
  RFC7230:
  RFC3230:


--- abstract

This document introduces a new frame type for transporting gzip-encoded data between peers in the
Hypertext Transfer Protocol Version 2 (HTTP/2), and an associated error code for handling
invalid encoding.

**Note to Readers**

The issues list for this draft can be found at <https://github.com/phluid61/internet-drafts/labels/HTTP%2F2%20Gzipped%20Data>

The most recent (often unpublished) draft is at <http://phluid61.github.io/internet-drafts/http2-encoded-data/>


--- middle

# Introduction {#intro}

This document introduces a mechanism for applying gzip encoding {{RFC1952}} to data
transported between two endpoints in the Hypertext Transfer Protocol Version 2 (HTTP/2) {{RFC7540}},
analogous to Transfer-Encoding in HTTP/1.1 {{RFC7230}}.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.


# Additions to HTTP/2 {#additions}

This document introduces a new HTTP/2 frame type ({{RFC7540}}, Section 11.2),
a new HTTP/2 setting ({{RFC7540}}, Section 11.3),
and a new HTTP/2 error code ({{RFC7540}}, Section 7), to allow the compression
of data.

Note that while compressing some or all data in a stream might affect the total length of the
corresponding HTTP message body, the `content-length` header, if present, should continue to
reflect the total length of the _uncompressed_ data. This is particularly relevant when detecting
malformed messages ({{RFC7540}}, Section 8.1.2.6).


## SETTINGS\_ACCEPT\_GZIPPED\_DATA  {#accept-gzipped-data}

<cref>This is an experimental value; if standardised, a permanent value will be assigned.</cref>

SETTINGS\_ACCEPT\_GZIPPED\_DATA (0xf000) is used to indicate the sender's ability and
willingness to receive GZIPPED\_DATA frames. An endpoint MUST NOT send a GZIPPED\_DATA
frame unless it receives this setting with a value of 1.

The initial value is 0, which indicates that GZIPPED\_DATA frames are not supported. Any
value other than 0 or 1 MUST be treated as a connection error ({{RFC7540}}, Section 5.4.1)
of type PROTOCOL\_ERROR.

An endpoint may advertise support for GZIPPED\_DATA frames and later decide that it no longer
supports them.  After sending an ACCEPT\_GZIPPED\_DATA setting with the value 0, the endpoint
SHOULD continue to accept GZIPPED\_DATA frames for a reasonable amount of time to account for
frames that may already be in flight.


## GZIPPED\_DATA  {#gzipped-data}

<cref>This is an experimental value; if standardised, a permanent value will be assigned.</cref>

GZIPPED\_DATA frames (type code=0xf000) are semantically identical to DATA frames
({{RFC7540}}, Section 6.1), but their payload is encoded using gzip compression.
Significantly: the order of DATA and GZIPPED\_DATA frames is semantically significant; and
GZIPPED\_DATA frames are subject to flow control ({{RFC7540}}, Section 5.2).
Gzip compression is an LZ77 coding with a 32 bit CRC that is commonly produced
by the gzip file compression program {{RFC1952}}.

Any compression or decompression context for a GZIPPED\_DATA frame is unique to that frame.
An endpoint MAY interleave DATA and GZIPPED\_DATA frames on a single stream.

~~~~~~~~~~
  +---------------+
  |Pad Length? (8)|
  +---------------+-----------------------------------------------+
  |                            Data (*)                         ...
  +---------------------------------------------------------------+
  |                           Padding (*)                       ...
  +---------------------------------------------------------------+
~~~~~~~~~~
{: title="GZIPPED_DATA Frame Payload"}

The GZIPPED\_DATA frame contains the following fields:

* Pad Length:
  An 8-bit field containing the length of the frame padding in units
  of octets. This field is optional and is only present if the
  PADDED flag is set.

* Data:
  Encoded application data. The amount of encoded data is the remainder of the frame
  payload after subtracting the length of the other fields that are
  present.

* Padding:
  Padding octets that contain no application semantic value. Padding
  octets MUST be set to zero when sending and ignored when receiving.

The GZIPPED\_DATA frame defines the following flags:

* `END_STREAM` (0x1):
  Bit 1 being set indicates that this frame is the last that the
  endpoint will send for the identified stream. Setting this flag
  causes the stream to enter one of the "half closed" states or the
  "closed" state ({{RFC7540}}, Section 5.1).

* `PADDED` (0x8):
  Bit 4 being set indicates that the Pad Length field is present.


A GZIPPED\_DATA frame MUST NOT be sent if the ACCEPT\_GZIPPED\_DATA setting
of the peer is set to 0.  See {{experiment}}.

An intermediary, on receiving a GZIPPED\_DATA frame, MAY decode the data and forward it to its
downstream peer in one or more DATA frames. If the downstream peer has not advertised support
for GZIPPED\_DATA frames (by sending an ACCEPT\_GZIPPED\_DATA setting with the value 1) the
intermediary MUST decode the data before forwarding it.

If an endpoint detects that the payload of a GZIPPED\_DATA frame is not encoded correctly,
for example with an incorrect checksum, the endpoint MUST
treat this as a stream error (see {{RFC7540}}, Section 5.4.2) of type
DATA\_ENCODING\_ERROR ({{error}}). The endpoint MAY then choose to immediately send an
ACCEPT\_GZIPPED\_DATA setting with the value 0.

If an intermediary propagates a GZIPPED\_DATA frame from the source peer to the destination peer
without modifying the payload or its encoding, and receives a DATA\_ENCODING\_ERROR from the
receiving peer, it SHOULD pass the error on to the source peer.

GZIPPED\_DATA frames MUST be associated with a stream. If a GZIPPED\_DATA frame is received whose
stream identifier field is 0x0, the recipient MUST respond with a connection error
({{RFC7540}}, Section 5.4.1) of type PROTOCOL\_ERROR.

GZIPPED\_DATA frames are subject to flow control and can only be sent when a stream is in the
"open" or "half closed (remote)" states. The entire GZIPPED\_DATA frame payload is included in flow
control, including the Pad Length and Padding fields if present. If a
GZIPPED\_DATA frame is received whose stream is not in "open" or "half closed (local)" state, the
recipient MUST respond with a stream error ({{RFC7540}}, Section 5.4.2) of type
STREAM\_CLOSED.

GZIPPED\_DATA frames can include padding.  Padding fields and flags are identical to those defined
for DATA frames ({{RFC7540}}, Section 6.1).


## DATA\_ENCODING\_ERROR  {#error}

The following new error code is defined:

* `DATA_ENCODING_ERROR` (0xf0000000):
  The endpoint detected that its peer sent a GZIPPED\_DATA frame with an invalid encoding.

  <cref>This is an experimental value; if standardised, a permanent value will be assigned.</cref>


# Experimental Status  {#experiment}

This extension is classified as an experiment because it alters the base semantics of HTTP/2;
a change that, if specified insufficiently or implemented incorrectly, could result in data loss
that is hard to detect or diagnose.

{{RFC7540}}, Section 5.5, mandates that "implementations MUST discard frames that have unknown
or unsupported types"; so if an endpoint or intermediary mishandles GZIPPED\_DATA frames, for
example by incorrectly emitting an ACCEPT\_GZIPPED\_DATA setting or propagating GZIPPED\_DATA
frames, and those frames are subsequently discarded, data will be lost.  There is no reliable
mechanism to detect such a loss\[\*\].

The experiment therefore is to explore the robustness of the HTTP/2 ecosystem in the presence of
such potential failures.

\[\*\] For some unreliable mechanisms (i.e. not guaranteed to be in use in all cases, and/or
requiring inspection of HTTP headers) see:

* Section 8.1.2.6 of [RFC7540], for using the content-length header to detect malformed messages

* [RFC3230], for HTTP instance digests


# Security Considerations  {#security}

Further to the Use of Compression in HTTP/2 ({{RFC7540}}, Section 10.6),
intermediaries MUST NOT apply compression to DATA frames, or alter the compression of
GZIPPED\_DATA frames other than decompressing, unless additional information is available
that allows the intermediary to identify the source of data. In particular, frames that
are not compressed cannot be compressed, and frames that are separately compressed cannot
be merged into a single compressed frame.


# IANA Considerations  {#iana}

This document updates the registries for frame types, settings, and error codes in
the "Hypertext Transfer Protocol (HTTP) 2 Parameters" section.


## HTTP/2 Frame Type Registry Update

This document updates the "HTTP/2 Frame Type" registry
({{RFC7540}}, Section 11.2).  The entries in the
following table are registered by this document.

 |-----------------------|------|---------------------------|
 | Frame Type            | Code | Section                   |
 |-----------------------|------|---------------------------|
 | GZIPPED\_DATA         | TBD  | {{gzipped-data}}          |
 |-----------------------|------|---------------------------|


## HTTP/2 Settings Registry Update

This document updates the "HTTP/2 Settings" registry
({{RFC7540}}, Section 11.3).  The entries in the
following table are registered by this document.

 |-----------------------|------|---------------|---------------------------|
 | Frame Type            | Code | Initial Value | Specification             |
 |-----------------------|------|---------------|---------------------------|
 | ACCEPT\_GZIPPED\_DATA | TBD  | 0             | {{accept-gzipped-data}}   |
 |-----------------------|------|---------------|---------------------------|


## HTTP/2 Error Code Registry Update

This document updates the "HTTP/2 Error Code" registry
({{RFC7540}}, Section 11.4).  The entries in the
following table are registered by this document.

 |-----------------------|------|---------------------------|---------------|
 | Name                  | Code | Description               | Specification |
 |-----------------------|------|---------------------------|---------------|
 | DATA\_ENCODING\_ERROR | TBD  | Invalid encoding detected | {{error}}     |
 |-----------------------|------|---------------------------|---------------|


# Acknowledgements

Thanks to Keith Morgan for his advice, input, and editorial contributions.

--- back

# Changelog

Since -09:

 * (editorial) use 'cref' elements for notes

Since -08:

 * use experimental values for frame/setting/error codes

Since -07:

 * define "reliable" in the 'experimental' section, and provide pointers
   to potential workarounds
 * remove fragmentation, since the text added no value

Since -06:

 * change document title from "Encoded" to "Gzipped"
 * improve text under GZIPPED\_DATA ({{gzipped-data}})
 * clarify that GZIPPED\_DATA and DATA can be interleaved
 * explain experimental status and risks of broken implementations

Since -05:

 * changed ACCEPT\_ENCODED\_DATA back from a frame to a setting, since it
   carries a single scalar value now

Since -04:

 * reduced encoding options to only gzip (suggested by Martin Thomson)
 * remove fragmentation and segment stuff, including reference to 'http2-segments' I-D
 * updated HTTP/2 reference from I-D to (freshly published) RFC7230

Since -03:

 * added 'identity' encoding; removed 'compress' and 'zlib' (suggested by PHK)
 * added SEGMENT flag, for segments that don't continue
 * clarified that ACCEPT is for a connection, and ENCODED\_DATA is for a stream
 * copied "padding" text from HTTP/2 draft

Since -02:

 * moved all discussion of fragmentation and segments to its own section

Since -01:

 * referenced new draft-kerwin-http2-segments to handle fragmentation

Since -00:

 * changed ACCEPT\_ENCODED\_DATA from a complex setting to a frame
 * improved IANA Considerations section (with lots of input from Keith Morgan)

