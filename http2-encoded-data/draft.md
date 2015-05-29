---
title: HTTP/2 Encoded Data
abbrev: http2-encoded-data
docname: draft-kerwin-http2-encoded-data-06
date: 2015
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
  RFC1952:
  RFC2119:
  RFC7540:

informative:
  RFC7230:


--- abstract

This document introduces new frame types for transporting gzip-encoded data between peers in the
Hypertext Transfer Protocol Version 2 (HTTP/2), and an associated error code for handling
invalid encoding.


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

This document introduces two new HTTP/2 frame types ({{RFC7540}}, Section 11.2)
and a new HTTP/2 error code ({{RFC7540}}, Section 7), to allow the compression
of data.

Note that while compressing some or all data in a stream might affect the total length of the
corresponding HTTP message body, the `content-length` header, if present, should continue to
reflect the total length of the _uncompressed_ data. This is particularly relevant when detecting
malformed messages ({{RFC7540}}, Section 8.1.2.6).


## ACCEPT\_GZIPPED\_DATA  {#accept-gzipped-data}

An ACCEPT\_GZIPPED\_DATA frame (type code=0xTBA) is used to indicate the sender's ability and
willingness to receive GZIPPED\_DATA frames.

ACCEPT\_GZIPPED\_DATA always applies to a connection, never a single stream. The stream identifier
for an ACCEPT\_GZIPPED\_DATA frame MUST be zero (0x0). If an endpoint receives an
ACCEPT\_GZIPPED\_DATA frame whose stream identifier field is anything other than 0x0, the endpoint
MUST respond with a connection error (({{RFC7540}}, Section 5.4.1) of type
PROTOCOL\_ERROR.

The payload length of an ACCEPT\_GZIPPED\_DATA frame MUST be zero. An endpoint that receives an
ACCEPT\_GZIPPED\_DATA frame a length other than zero MUST treat this as a
connection error ({{RFC7540}}, Section 5.4.1) of type PROTOCOL\_ERROR.

The ACCEPT\_GZIPPED\_DATA frame defines the following flag:

* DISABLE (0x1):
  When set, bit 0 indicates that this endpoint is not willing or able to receive GZIPPED\_DATA
  frames.

An endpoint may advertise support for GZIPPED\_DATA frames and later decide that it no longer
supports them.  After sending an ACCEPT\_GZIPPED\_DATA with the DISABLE flag set, the endpoint
SHOULD continue to accept GZIPPED\_DATA frames for a reasonable amount of time to account for
frames that are already in flight.

The ACCEPT\_GZIPPED\_DATA frame is not subject to flow control.


## GZIPPED\_DATA  {#gzipped-data}

GZIPPED\_DATA frames (type code=0xTBA) are semantically identical to DATA frames
({{RFC7540}}, Section 6.1), but their payload is encoded using gzip compression.
Gzip compression is an LZ77 coding with a 32 bit CRC that is commonly produced
by the gzip file compression program {{RFC1952}}.
Significantly, GZIPPED\_DATA frames are subject to flow control ({{RFC7540}},
Section 5.2).

Any compression or decompression context for a GZIPPED\_DATA frame is unique to that frame.

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
  Encoded application data. The amount of compressed data is the remainder of the frame
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


A GZIPPED\_DATA frame MUST NOT be sent on a connection before receiving an
ACCEPT\_GZIPPED\_DATA frame.

An intermediary, on receiving a GZIPPED\_DATA frame, MAY decode the data and forward it to its
downstream peer in one or more DATA frames. If the downstream peer has not advertised support
for GZIPPED\_DATA frames (e.g. by sending an ACCEPT\_GZIPPED\_DATA frame) the
intermediary MUST decode the data before forwarding it.

If an endpoint detects that the payload of a GZIPPED\_DATA frame is not encoded correctly,
for example with a mismatched checksum, the endpoint MUST
treat this as a stream error (see {{RFC7540}}, Section 5.4.2) of type
DATA\_ENCODING\_ERROR ({{error}}). The endpoint MAY then choose to immediately send an
ACCEPT\_GZIPPED\_DATA frame with the DISABLE flag set.

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

The total number of padding octets is determined by the value of the Pad Length field. If the
length of the padding is greater than the length of the remainder of the frame payload, the
recipient MUST treat this as a connection error ({{RFC7540}}, Section 5.4.1) of type
PROTOCOL\_ERROR.

Note: A frame can be increased in size by one octet by including a Pad Length field
  with a value of zero.

Padding is a security feature; see Section 10.7 of {{RFC7540}}.


## DATA\_ENCODING\_ERROR  {#error}

The following new error code is defined:

* `DATA_ENCODING_ERROR` (0xTBA):
  The endpoint detected that its peer sent a GZIPPED\_DATA frame with an invalid encoding.


# Fragmentation  {#fragmentation}

Traversing a network segment with small frame size limits introduces the risk of fragmenting an
encoded stream. {::comment}FIXME: provide some advice?{:/comment}


# Security Considerations  {#security}

Further to the Use of Compression in HTTP/2 ({{RFC7540}}, Section 10.6),
intermediaries MUST NOT apply compression to DATA frames, or alter the compression of
GZIPPED\_DATA frames other than decompressing, unless additional information is available
that allows the intermediary to identify the source of data. In particular, frames that
are not compressed cannot be compressed, and frames that are separately compressed cannot
be merged into a single compressed frame.


# IANA Considerations  {#iana}

This document updates the registries for frame types and error codes in
the "Hypertext Transfer Protocol (HTTP) 2 Parameters" section.  This
document also establishes a new registry for HTTP/2 encoding scheme
codes.  This new registry is entered into the "Hypertext Transfer
Protocol (HTTP) 2 Parameters" section. 


## HTTP/2 Frame Type Registry Update

This document updates the "HTTP/2 Frame Type" registry
({{RFC7540}}, Section 11.2).  The entries in the
following table are registered by this document.

 |-----------------------|------|---------------------------|
 | Frame Type            | Code | Section                   |
 |-----------------------|------|---------------------------|
 | ACCEPT\_GZIPPED\_DATA | TBD  | {{accept-gzipped-data}}   |
 |-----------------------|------|---------------------------|
 | GZIPPED\_DATA         | TBD  | {{gzipped-data}}          |
 |-----------------------|------|---------------------------|


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
