---
title: HTTP/2 Encoded Data
abbrev: http2-encoded-data
docname: draft-kerwin-http2-encoded-data-04
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
  RFC2119:
  I-D.ietf-httpbis-http2:
  I-D.kerwin-http2-segments:
  Welch:
    title: A Technique for High-Performance Data Compression
    author:
    - ins: T. A. Welch
      name: Terry A. Welch
    date: 1984-06
    seriesinfo:
      IEEE: Computer 17(6)
  RFC1950:
  RFC1951:
  RFC1952:
  RFC5226:

informative:
  RFC7230:


--- abstract

This document introduces new frame types for transporting encoded data between peers in the
Hypertext Transfer Protocol version 2 (HTTP/2), and an associated error code for handling
invalid encoding.


--- middle

# Introduction {#intro}

This document introduces a mechanism for applying encoding, particularly compression, to data
transported between two endpoints in version 2 of the Hypertext Transfer Protocol (HTTP/2),
analogous to Transfer-Encoding in HTTP/1.1 {{RFC7230}}.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.


# Additions to HTTP/2 {#additions}

This document introduces two new HTTP/2 frame types ({{I-D.ietf-httpbis-http2}}, Section 11.2)
and a new HTTP/2 error code ({{I-D.ietf-httpbis-http2}}, Section 7), to allow the application of
encoding, particularly compression, to data.

Note that while encoding some or all data in a stream might affect the total length of the
corresponding HTTP message body, the `content-length` header, if present, should continue to
reflect the total length of the _unencoded_ data. This is particularly relevant when detecting
malformed messages ({{I-D.ietf-httpbis-http2}}, Section 8.1.2.5).


## ACCEPT\_ENCODED\_DATA  {#accept-encoded-data}

An ACCEPT\_ENCODED\_DATA frame (type code=0xTBA) is used to indicate the sender's ability and
willingness to receive ENCODED\_DATA frames that are encoded using the schemes identified in
its payload.

ACCEPT\_ENCODED\_DATA always apply to a connection, never a single stream. The stream identifier
for an ACCEPT\_ENCODED\_DATA frame MUST be zero (0x0). If an endpoint receives an
ACCEPT\_ENCODED\_DATA frame whose stream identifier field is anything other than 0x0, the endpoint
MUST respond with a connection error (({{I-D.ietf-httpbis-http2}}, Section 5.4.1) of type
PROTOCOL\_ERROR.

The payload length of an ACCEPT\_ENCODED\_DATA frame MUST be an exact multiple of 16 bits (2 bytes).
An endpoint that receives an ACCEPT\_ENCODED\_DATA frame with an odd length MUST treat this as a
connection error ({{I-D.ietf-httpbis-http2}}, Section 5.4.1) of type PROTOCOL\_ERROR.

~~~~~~~~~~
   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  | Encoding (8)  |   Rank (8)    | ...
  +---------------+---------------+-------------------------------+
~~~~~~~~~~
{: title="ACCEPT_ENCODED_DATA Frame Payload"}

The ACCEPT\_ENCODED\_DATA frame contains zero or more tuples comprising the following fields:

* Encoding:
  An 8-bit identifier which identifies the encoding being advertised (see {{schemes}}).

* Rank:
  An 8-bit integer value.

The rank fulfils the same role as in the HTTP/1.1 TE header ({{RFC7230}}, Section 4.3). The
rank value is an integer in the range 0 through 255, where 1 is the least preferred and 255
is the most preferred; a value of 0 means "not acceptable".

The ENCODING\_IDENTITY encoding ({{schemes}}) is always acceptable with a default rank of 1, and
MUST NOT be advertised with a rank of 0. And endpoint that receives an ACCEPT\_ENCODED\_DATA frame
including an \{encoding,rank\} tuple of \{ENCODING\_IDENTITY,0\} MUST respond with a connection
error ({{I-D.ietf-httpbis-http2}}, Section 5.4.1) of type PROTOCOL\_ERROR.

An endpoint that receives an ACCEPT\_ENCODED\_DATA frame containing an \{encoding,rank\} tuple
with an unknown or unsupported encoding identifier MUST ignore that tuple.

Each ACCEPT\_ENCODED\_DATA frame fully replaces the set of tuples sent in a previous frame;
if an encoding identifier is omitted from a subsequent ACCEPT\_ENCODED\_DATA frame it is deemed
"not acceptable", with the exception of ENCODING\_IDENTITY which defaults to a rank of 1.

An endpoint may advertise support for an encoding scheme and later decide that it no longer
supports that scheme.  After sending an ACCEPT\_ENCODED\_DATA that omits the encoding identifier
in question, or includes it with a rank of 0, the endpoint SHOULD continue to accept
ENCODED\_DATA frames using that scheme for a reasonable amount of time to account for encoded
frames that are already in flight.

The ACCEPT\_ENCODED\_DATA frame does not define any flags, and is not subject to flow control.


## ENCODED\_DATA  {#encoded-data}

ENCODED\_DATA frames (type code=0xTBA) are semantically identical to DATA frames
({{I-D.ietf-httpbis-http2}}, Section 6.1), but have an encoding applied to their payload.
Significantly, ENCODED\_DATA frames are subject to flow control ({{I-D.ietf-httpbis-http2}},
Section 5.2).

Any encoding or decoding context for an ENCODED\_DATA frame is unique to that frame.

~~~~~~~~~~
   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |Pad Length? (8)|
  +---------------+
  | Encoding (8)  |
  +---------------+-----------------------------------------------+
  |                            Data (*)                         ...
  +---------------------------------------------------------------+
  |                           Padding (*)                       ...
  +---------------------------------------------------------------+
~~~~~~~~~~
{: title="ENCODED_DATA Frame Payload"}

The ENCODED\_DATA frame contains the following fields:

* Pad Length:
  An 8-bit field containing the length of the frame padding in units
  of octets. This field is optional and is only present if the
  PADDED flag is set.

* Encoding:
  An 8-bit identifier which identifies the encoding that has been
  applied to the Data field (see {{schemes}}).

* Data:
  Encoded application data. The amount of encoded data is the remainder of the frame
  payload after subtracting the length of the other fields that are
  present.

* Padding:
  Padding octets that contain no application semantic value. Padding
  octets MUST be set to zero when sending and ignored when receiving.

The ENCODED\_DATA frame defines the following flags:

* `END_STREAM` (0x1):
  Bit 1 being set indicates that this frame is the last that the
  endpoint will send for the identified stream. Setting this flag
  causes the stream to enter one of the "half closed" states or the
  "closed" state ({{I-D.ietf-httpbis-http2}}, Section 5.1).

* `PADDED` (0x8):
  Bit 4 being set indicates that the Pad Length field is present.

* `SEGMENT_CONTINUES` (0x10):
  Bit 5 being set indicates that the current segment continues after
  the current frame ({{I-D.kerwin-http2-segments}}, Section 2).
  Intermediaries MUST NOT coalesce frames across a segment boundary and
  MUST preserve segment boundaries when forwarding frames.

  The SEGMENT\_CONTINUES flag MUST NOT be set on any frames unless the
  remote endpoint has indicated support by sending a SETTINGS\_USE\_SEGMENTS
  setting ({{I-D.kerwin-http2-segments}}, Section 3) with a value of 1.


An ENCODED\_DATA frame MUST NOT be sent on a connection before receiving an ACCEPT\_ENCODED\_DATA
frame. A sender MUST NOT apply an encoding that has not first been advertised by the peer in an
ACCEPT\_ENCODED\_DATA frame, or was advertised with a rank of 0. Endpoints that receive a frame
with an encoding they do not recognise or support MUST treat this as a connection error of type
PROTOCOL\_ERROR.

An intermediary, on receiving an ENCODED\_DATA frame, MAY decode the data and forward it to its
downstream peer in one or more DATA frames. If the received ENCODED\_DATA frame has an encoding
the downstream peer does not support (as advertised in an ACCEPT\_ENCODED\_DATA frame) the
intermediary MUST decode the data before forwarding it. The intermediary MAY re-encode the data
with a scheme supported by the downstream peer and forward it in one or more ENCODED\_DATA frames.

If an endpoint detects that the payload of an ENCODED\_DATA frame is not encoded correctly
according to its declared Encoding, for example with a mismatched checksum, the endpoint MUST
treat this as a stream error (see {{I-D.ietf-httpbis-http2}}, Section 5.4.2) of type
DATA\_ENCODING\_ERROR ({{error}}).

ENCODED\_DATA frames MUST be associated with a stream. If an ENCODED\_DATA frame is received whose
stream identifier field is 0x0, the recipient MUST respond with a connection error
({{I-D.ietf-httpbis-http2}}, Section 5.4.1) of type PROTOCOL\_ERROR.

ENCODED\_DATA frames are subject to flow control and can only be sent when a stream is in the
"open" or "half closed (remote)" states. The entire ENCODED\_DATA frame payload is included in flow
control, including the encoding identifier, and Pad Length and Padding fields if present. If an
ENCODED\_DATA frame is received whose stream is not in "open" or "half closed (local)" state, the
recipient MUST respond with a stream error ({{I-D.ietf-httpbis-http2}}, Section 5.4.2) of type
STREAM\_CLOSED.

The total number of padding octets is determined by the value of the Pad Length field. If the
length of the padding is greater than the length of the remainder of the frame payload, the
recipient MUST treat this as a connection error ({{I-D.ietf-httpbis-http2}}, Section 5.4.1) of type
PROTOCOL\_ERROR.

Note: A frame can be increased in size by one octet by including a Pad Length field
  with a value of zero.

Padding is a security feature; see Section 10.7 of {{I-D.ietf-httpbis-http2}}.


### Fragmentation and Segments {#frag-segments}

Traversing a network segment with small frame size limits introduces the risk of fragmenting an
encoded stream. This can be avoided using segments, as defined in {{I-D.kerwin-http2-segments}}.

An intermediary MAY coalesce multiple adjacent ENCODED\_DATA frames if all of them, with the
optional exception of the final frame in the sequence, have the SEGMENT\_CONTINUES flag set. The
coalesced payload MAY be subsequently emitted in any combination of ENCODED\_DATA and DATA frames.
The payloads of any resulting ENCODED\_DATA frames MUST be correctly encoded according to those
frames' encodings; note that for some encoding schemes this could require that the payloads of the
original frames be decoded and subsequently re-encoded into the new frames, rather than simply
concatenated.


## DATA\_ENCODING\_ERROR  {#error}

The following new error code is defined:

* `DATA_ENCODING_ERROR` (0xTBA):
  The endpoint detected that its peer sent an ENCODED\_DATA frame with an invalid encoding.


# Encoding Schemes  {#schemes}

The following encoding schemes are defined:

* `ENCODING_IDENTITY` (0):
  The identity encoding identifier is used to indicate that no encoding is
  applied.

* `ENCODING_GZIP` (1):
  The gzip coding is an LZ77 coding with a 32 bit CRC that is
  commonly produced by the gzip file compression program {{RFC1952}}.

<!--
+ LZ4 (Yann Collet, http://fastcompression.blogspot.fr/2013/04/lz4-streaming-format-final.html)
-->


# Security Considerations  {#security}

Further to the Use of Compression in HTTP/2 ({{I-D.ietf-httpbis-http2}}, Section 10.6),
intermediaries MUST NOT apply compression to DATA frames, or alter the compression of
ENCODED\_DATA frames other than decompressing, unless additional information is available
that allows the intermediary to identify the source of data. In particular, frames that
are not compressed cannot be compressed, and frames that are separately compressed can only
be merged into a single compressed frame if they occupy the same segment.


# IANA Considerations  {#iana}

This document updates the registries for frame types and error codes in
the "Hypertext Transfer Protocol (HTTP) 2 Parameters" section.  This
document also establishes a new registry for HTTP/2 encoding scheme
codes.  This new registry is entered into the "Hypertext Transfer
Protocol (HTTP) 2 Parameters" section. 


## HTTP/2 Frame Type Registry Update

This document updates the "HTTP/2 Frame Type" registry
({{I-D.ietf-httpbis-http2}}, Section 11.2).  The entries in the
following table are registered by this document.

 |-----------------------|------|---------------------------|
 | Frame Type            | Code | Section                   |
 |-----------------------|------|---------------------------|
 | ACCEPT\_ENCODED\_DATA | TBD  | {{accept-encoded-data}}   |
 |-----------------------|------|---------------------------|
 | ENCODED\_DATA         | TBD  | {{encoded-data}}          |
 |-----------------------|------|---------------------------|


## HTTP/2 Error Code Registry Update

This document updates the "HTTP/2 Error Code" registry
({{I-D.ietf-httpbis-http2}}, Section 11.4).  The entries in the
following table are registered by this document.

 |-----------------------|------|---------------------------|---------------|
 | Name                  | Code | Description               | Specification |
 |-----------------------|------|---------------------------|---------------|
 | DATA\_ENCODING\_ERROR | TBD  | Invalid encoding detected | {{error}}     |
 |-----------------------|------|---------------------------|---------------|


## HTTP/2 Encoding Schemes Registry

This document establishes a registry for encoding scheme codes. The
"HTTP/2 Encoding Schemes" registry manages an 8-bit space. The "HTTP/2
Encoding Schemes" registry operates under either of the "IETF Review"
or "IESG Approval" policies {{RFC5226}} for values between 0x00 and
0xef, with values between 0xf0 and 0xff being reserved for
experimental use.

New entries in this registry require the following information:

* Frame Type:
  A name or label for the encoding scheme.

* Code:
  The 8-bit code assigned to the encoding scheme.

* Specification:
  A reference to a specification that includes a description of the
  encoding scheme.

An initial set of encoding scheme code registrations can be found
in {{schemes}}.


# Acknowledgements

Thanks to Keith Morgan for his advice, input, and editorial contributions.

--- back
