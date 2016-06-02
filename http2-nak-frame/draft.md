---
title: HTTP/2 "Dropped Frame" Frame
abbrev: http2-nak-frame
docname: draft-kerwin-http2-nak-frame-00
date: 2016
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
   uri: http://matthew.kerwin.net.au/

normative:
  RFC2119:
  RFC7540:

informative:


--- abstract

This document defines an extension to the Hypertext Transfer Protocol Version 2 (HTTP/2) that
allows for non-destructive signalling of unsupported extension frames.

**Note to Readers**

The issues list for this draft can be found at https://github.com/phluid61/internet-drafts/labels/HTTP%2F2%20NAK%20Frame

The most recent (often unpublished) draft is at http://phluid61.github.io/internet-drafts/http2-nak-frame/

--- middle

# Introduction

Out of the box, the Hypertext Transfer Protocol Version 2 (HTTP/2) {{RFC7540}} makes provision for
extension frame types to be sent on a connection, with or without prior agreement from either or
both peers, with the assertion that "implementations MUST discard frames that have unknown or
unsupported types" ({{RFC7540}}, Section 5.5).  However it can be useful to explicitly notify the
peer if such a frame is discarded.

This document defines an extension to HTTP/2 that allows a peer to signal that a received frame
was discarded, without altering the stream or connection state ({{RFC7540}}, Section 5.1), and in
particular without triggering an error condition.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.

# Additions to HTTP/2 {#additions}

This document introduces a new HTTP/2 frame type ({{RFC7540}}, Section 11.2).


## DROPPED\_FRAME {#dropped-frame}

DROPPED\_FRAME frames (type code=0xTBA) can be sent on a connection at any time <!-- FIXME --> to
indicate that a received frame was discarded without any action being taken.

~~~~~~~~~~
  +---------------+
  |   Type (8)    |
  +---------------+
~~~~~~~~~~
{: title="DROPPED_FRAME Frame Payload"}

The DROPPED\_FRAME frame contains a single 8-bit integer containing the value of the Type field
from the discarded frame.

The DROPPED\_FRAME frame does not define any flags.

An endpoint SHOULD send a DROPPED\_FRAME frame for an unknown or unsupported frame type the first
time it discards such a frame.

An endpoint MAY send a DROPPED\_FRAME frame for a particular incoming frame type only once, even
if it discards multiple frames of that type.

An endpoint that receives a DROPPED\_FRAME frame ought to take it as an indication that the
extension is not supported by the peer, and MAY subsequently choose to not send further frames of
that type to or to enter into extension negotiations with the peer.

DROPPED\_FRAME frames are not associated with any individual stream.  If a DROPPED\_FRAME frame is
received with a stream identifier field value other than 0x0, the recipient MUST respond with a
connection error ({{RFC7540}}, Section 5.4.1) of type PROTOCOL\_ERROR.

Receipt of a DROPPED\_FRAME frame with a length field value other than 1 MUST be treated as a
connection error ({{RFC7540}}, Section 5.4.1) of type FRAME\_SIZE\_ERROR.

<!--

TODO:

 * warn MUXers about forwarding/coalescing extensions
 * mention the error detection capability

-->

# Security Considerations

<!-- FIXME -->
This specification does not introduce any new security considerations.

# IANA Considerations  {#iana}

This document updates the registriy for frame types in the "Hypertext Transfer Protocol (HTTP) 2
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
