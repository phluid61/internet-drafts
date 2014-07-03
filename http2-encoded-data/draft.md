---
title: HTTP/2 Encoded Data
abbrev: http2-encoded-data
docname: draft-kerwin-http2-encoded-data-01
date: 2014
category: info

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

This document introduces a new encoded data frame for use in HTTP/2, and an associated setting parameter.

--- middle

# Introduction {#intro}

This document describes a mechanism for applying encoding, particularly compression, to data transported
between two HTTP/2 hops, analogous to Transfer-Encoding in HTTP/1.1 {{RFC7230}}.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.


# Additions to HTTP/2 {#additions}

This document introduces a new HTTP/2 `ENCODED_DATA` frame type ({{I-D.ietf-httpbis-http2}}, Section 11.2), and a
new setting ({{I-D.ietf-httpbis-http2}}, Section 11.3) to negotiate its use.

Note that while encoding some or all data in a stream might affect the total length of the corresponding HTTP message body,
the `content-length` header, if present, should continue to reflect the total length of the _unencoded_
data. This is particularly relevant when detecting malformed messages ({{I-D.ietf-httpbis-http2}},
Section 8.1.2.5).


## ENCODED_DATA Frame

`ENCODED_DATA` frames (type code=0x10) are semantically identical to `DATA` frames ({{I-D.ietf-httpbis-http2}},
Section 6.1), but have an encoding applied to their payload. Significantly, `ENCODED_DATA` frames are subject
to flow control ({{I-D.ietf-httpbis-http2}}, Section 5.2). Any encoding or decoding context for an `ENCODED_DATA`
frame is _unique to that frame_.

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

                        ENCODED_DATA Frame Payload

The `ENCODED_DATA` frame contains the following fields:

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

The `ENCODED_DATA` frame defines the following flags:

* `END_STREAM` (0x1):
  Bit 1 being set indicates that this frame is the last that the
  endpoint will send for the identified stream. Setting this flag
  causes the stream to enter one of the "half closed" states or the
  "closed" state (Section 5.1).

* `END_SEGMENT` (0x2):
  Bit 2 being set indicates that this frame is the last for the
  current segment. Intermediaries MUST NOT coalesce frames across a
  segment boundary and MUST preserve segment boundaries when
  forwarding frames.

* `PADDED` (0x8):
  Bit 4 being set indicates that the Pad Length field is present.

On receiving an `ENCODED_DATA` frame, an intermediary MAY decode the data and forward it in one or
more `DATA` frames. If the downstream peer does not support the encoding scheme used in the
received frame, as advertised in a `SETTINGS_ACCEPT_ENCODED_DATA` setting, the intermediary MUST
decode the data and either: forward it in one or more DATA frames, or encode it with a scheme
supported by the downstream peer and forward it in one or more `ENCODED_DATA` frames.

An `ENCODED_DATA` frame MUST NOT be sent on a connection before both receiving a `SETTINGS_ACCEPT_ENCODED_DATA`
setting and sending the associated acknowledgement. A sender MUST NOT apply an encoding that
has not first been advertised by the peer in a `SETTINGS_ACCEPT_ENCODED_DATA` setting, or was
advertised with a rank of 0. Endpoints that receive a frame with an encoding they do not
recognise or support MUST treat this as a connection error of type `PROTOCOL_ERROR`.

If an endpoint detects that the payload of an `ENCODED_DATA` frame is incorrectly encoded it MUST
treat this as a stream error (see {{I-D.ietf-httpbis-http2}}, Section 5.4.2) of type `COMPRESSION_ERROR`
({{I-D.ietf-httpbis-http2}}, Section 7).


## SETTINGS_ACCEPT_ENCODED_DATA Setting

This document defines a new `SETTINGS` parameter:

`SETTINGS_ACCEPT_ENCODED_DATA` (code=0x5): Indicates the sender's ability and willingness to
receive `ENCODED_DATA` frames that are encoded using the scheme identified in the Value.

The Value field is further divided into three sub-fields: an unsigned 8-bit encoding
identifier, an unsigned 8-bit rank, and 16 bits of padding.

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    | Encoding (8)  |     Rank (8)      |       Padding (16)        |
    +---------------+-------------------+---------------------------+

The rank fulfils the same role as in the HTTP/1.1 TE header ({{RFC7230}} Section 4.3). The
rank value is an integer in the range 0 through 255, where 1 is the least preferred and 255
is the most preferred; a value of 0 means "not acceptable".

An endpoint that receives a `SETTINGS_ACCEPT_ENCODED_DATA` setting with any unknown or
unsupported encoding identifier MUST ignore that setting.

An endpoint may advertise support for an encoding scheme and later decide that it no longer
supports that scheme.  After sending a `SETTINGS_ACCEPT_ENCODED_DATA` setting with a rank of
0, the endpoint SHOULD continue to accept `ENCODED_DATA` frames using that scheme for a
reasonable amount of time, until the acknowledgement arrives. (See {{I-D.ietf-httpbis-http2}},
Section 6.5.3)

Note that subsequent `SETTINGS_ACCEPT_ENCODED_DATA` parameters _do not_ replace existing
values for the parameter unless they contain the same encoding identifier.  Effectively, one
may consider this specification to introduce 256 new settings parameters, each having a 24-bit
identifier (the 16-bit `SETTINGS` identifier plus the 8-bit encoding parameter) and an 8-bit
value (the encoding rank); however, as support for any given encoding is entirely optional,
an endpoint only need track rankings for those encodings it supports for sending encoded data.


# Encoding Schemes {#schemes}

The following encoding schemes are defined:

* `ENCODING_COMPRESS` (1):
  The "compress" coding is an adaptive Lempel-Ziv-Welch (LZW) coding
  {{Welch}} that is commonly produced by the UNIX file compression program
  "compress".

* `ENCODING_DEFLATE` (2):
  The "deflate" coding is a "zlib" data format {{RFC1950}} containing
  a "deflate" compressed data stream {{RFC1951}} that uses a
  combination of the Lempel-Ziv (LZ77) compression algorithm and
  Huffman coding.

* `ENCODING_GZIP` (3):
  The "gzip" coding is an LZ77 coding with a 32 bit CRC that is
  commonly produced by the gzip file compression program {{RFC1952}}.


# Security Considerations

Further to the Use of Compression in HTTP/2 ({{I-D.ietf-httpbis-http2}}, Section 10.6),
intermediaries MUST NOT apply compression to DATA frames, or alter the compression of
`ENCODED_DATA` frames, other than decompressing, unless additional information is available
that allows the intermediary to identify the source of data. In particular, frames that
are not compressed cannot be compressed, and frames that are separately compressed cannot
be merged into a single compressed frame.


# IANA Considerations

This document updates the registries for frame types and settings in
the "Hypertext Transfer Protocol (HTTP) 2 Parameters" section.  This
document also establishes a new registry for HTTP/2 encoding scheme
codes.  This new registry is entered into the "Hypertext Transfer
Protocol (HTTP) 2 Parameters" section. 


## HTTP/2 Frame Type Registry Update

This document updates the "HTTP/2 Frame Type" registry
({{I-D.ietf-httpbis-http2}}, Section 11.2).  The entries in the
following table are registered by this document.

    +--------------+------+-------------+
    | Frame Type   | Code | Section     |
    +--------------+------+-------------+
    | ENCODED_DATA | TBD  | Section 2.1 |
    +--------------+------+-------------+ 


## HTTP/2 Settings Registry Update

This document updates the "HTTP/2 Settings" registry
({{I-D.ietf-httpbis-http2}}, Section 11.3).  The entries in the
following table are registered by this document.

    +------------------------------+------+-------------+---------------+
    | Name                         | Code | Initial     | Specification |
    |                              |      | Value       |               |
    +------------------------------+------+-------------+---------------+
    | SETTINGS_ACCEPT_ENCODED_DATA | TBD  | N/A         | Section 2.2   |
    +------------------------------+------+-------------+---------------+


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


--- back
