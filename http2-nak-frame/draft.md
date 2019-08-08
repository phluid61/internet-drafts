---
title: HTTP/2 "Dropped Frame" Frame
abbrev: http2-nak-frame
docname: draft-kerwin-http2-nak-frame-02
date: 2017
category: std

ipr: trust200902
area: Applications and Real-Time
workgroup: 
keyword:
 - HTTP
 - H2

stand_alone: yes
pi: [toc, tocindent, sortrefs, symrefs, strict, compact, comments, inline]

author:
 - ins: M. Kerwin
   name: Matthew Kerwin
   organization: 
   email: matthew@kerwin.net.au
   uri: https://matthew.kerwin.net.au/

normative:
  RFC2119:
  RFC7540:
  RFC8174:

informative:


--- abstract

This document defines an extension to the Hypertext Transfer Protocol Version 2 (HTTP/2) that
allows an endpoint to signal to its peer that an unsupported extension frame was discarded.

--- note_Note_to_Readers

The issues list for this draft can be found at <https://github.com/phluid61/internet-drafts/labels/HTTP%2F2%20NAK%20Frame>

The most recent (often unpublished) draft is at <https://phluid61.github.io/internet-drafts/http2-nak-frame/>

--- middle

# Introduction

Out of the box, the Hypertext Transfer Protocol Version 2 (HTTP/2) {{RFC7540}} makes provision for
extension frames to be sent on a connection, with or without prior agreement from either peer, with
the assertion that "implementations MUST discard frames that have unknown or unsupported types"
({{RFC7540}}, Section 5.5).  However it can be useful to explicitly notify the peer if such a frame
is discarded.

This document defines an extension to HTTP/2 that allows a peer to signal that a received frame
was discarded, without altering the stream or connection state ({{RFC7540}}, Section 5.1), and in
particular without triggering an error condition.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED",
"MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they
appear in all capitals, as shown here.

# Additions to HTTP/2 {#additions}

This document introduces a new HTTP/2 frame type ({{RFC7540}}, Section 11.2).


## DROPPED\_FRAME {#dropped-frame}

<cref anchor="NOTE-1" source="MK">This is an experimental value; if standardised, a permanent value will be assigned.</cref>

DROPPED\_FRAME frames (type code=0xf001) can be sent on a connection at any time after the
connection preface except in the middle of a header block ({{RFC7540}}, Section 4.3) to indicate
that a received extension frame was discarded without any other action being taken.

~~~~~~~~~~
  +---------------+
  |   Type (8)    |
  +---------------+
~~~~~~~~~~
{: title="DROPPED_FRAME Frame Payload"}

The DROPPED\_FRAME frame contains a single 8-bit integer containing the value of the Type field
from the discarded frame.

The DROPPED\_FRAME frame does not define any flags.

An endpoint SHOULD send a DROPPED\_FRAME frame for an unknown or unsupported extension frame type
the first time it discards a frame of that type.

An endpoint MAY send a DROPPED\_FRAME frame for a particular frame type only once, even if it
discards multiple frames of that type.

An endpoint that receives a DROPPED\_FRAME frame ought to take it as an indication that the
extension is not supported by the peer, and MAY subsequently choose not to send further frames of
that type or to attempt extension negotiation with the peer.

Receipt of a DROPPED\_FRAME frame does not necessarily mean that all frames on that connection with
the discarded type will be discarded in future.  A transparent intermediary that forwards an
extension frame in one direction and a corresponding DROPPED\_FRAME frame in the other direction
MUST NOT intercept future frames of that type and preemptively reply with a DROPPED\_FRAME frame.

DROPPED\_FRAME frames are not associated with any individual stream.  If a DROPPED\_FRAME frame is
received with a stream identifier field value other than 0x0, the recipient MUST respond with a
connection error ({{RFC7540}}, Section 5.4.1) of type PROTOCOL\_ERROR.

Receipt of a DROPPED\_FRAME frame with a length field value other than 1 MUST be treated as a
connection error ({{RFC7540}}, Section 5.4.1) of type FRAME\_SIZE\_ERROR.

An endpoint MUST NOT send a DROPPED\_FRAME frame with a Type of DROPPED\_FRAME (0xf001).  If a
DROPPED\_FRAME frame is received with a Type field value of 0xf001, the recipient MUST respond with
a connection error ({{RFC7540}}, Section 5.4.1) of type PROTOCOL\_ERROR.
<!-- FIXME: what about core frame types / explicitly negotiated ones / etc? -->

Extensions that define new HTTP/2 frame types MAY specify behaviours in response to DROPPED\_FRAME
frames with those types, however extensions that change the semantics of existing protocol
components, including those defined in this document, MUST be negotiated before being used
({{RFC7540}}, Section 5.5).


# Security Considerations

Receipt of a DROPPED\_FRAME frame does not guarantee that the sending peer will send one for
every frame type it drops, and the absence of a DROPPED\_FRAME frame does not imply that the peer
has not discarded a frame.  Implementations MUST NOT depend on the use of DROPPED\_FRAME frames to
indicate acceptance or rejection of extension frames.


# IANA Considerations  {#iana}

This document updates the registry for frame types in the "Hypertext Transfer Protocol (HTTP) 2
Parameters" section.


## HTTP/2 Frame Type Registry Update

This document updates the "HTTP/2 Frame Type" registry ({{RFC7540}}, Section 11.2).  The entries
in the following table are registered by this document.

 |-----------------------|------|---------------------------|
 | Frame Type            | Code | Section                   |
 |-----------------------|------|---------------------------|
 | DROPPED\_FRAME        | TBD  | {{dropped-frame}}         |
 |-----------------------|------|---------------------------|


--- back

# Changelog

Since -01:

* use experimental value for frame ID

Since -00:

* Largely editorial; clarifications about when a frame can be received and what it
  can reasonably contain.

