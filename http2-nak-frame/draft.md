---
title: HTTP/2 "Dropped Frame" Frame
abbrev: http2-nak-frame
docname: draft-kerwin-http2-nak-frame-00
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
  RFC7540:

informative:


--- abstract

This document defines an extension to the Hypertext Transfer Protocol Version 2 (HTTP/2) that
allows for non-destructive signalling of unsupported extension frames.

--- middle

# Introduction

Out of the box, the Hypertext Transfer Protocol Version 2 (HTTP/2) {{RFC7540}} makes provision for
extension frame types to be sent on a connection, with or without prior agreement from either or
both peers, with the assertion that "implementations MUST discard frames that have unknown or
unsupported types" ({{RFC7540}}, Section 5.5).  However it can be useful to explicitly notify the
peer if such a frame is discarded.

This document defines an extension to HTTP/2 that allows a peer to signal that a received frame
was discarded, without altering the stream or connection state ({{RFC7540}}, Section 5.1), and in
particular without trigger an error condition.


## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.

# Additions to HTTP/2 {#additions}

This document introduces a new HTTP/2 frame type ({{RFC7540}}, Section 11.2).


## DROPPED\_FRAME {#dropped-frame}

DROPPED\_FRAME frames (type code=0xTBA) can be sent on a connection at any time <!-- FIXME --> to
indicate that a received frame was discarded without any action being taken.

The payload of a DROPPED\_FRAME frame contains the Type field from the discarded frame's header.

~~~~~~~~~~
  +---------------+
  |   Type (8)    |
  +---------------+
~~~~~~~~~~
{: title="DROPPED_FRAME Frame Payload"}

An endpoint SHOULD send a DROPPED\_FRAME frame for an unknown or unsupported frame type the first
time it discards such a frame.

An endpoint MAY send a DROPPED\_FRAME frame for a particular incoming frame type only once, even
if it discards multiple frames of that type.

An endpoint that receives a DROPPED\_FRAME frame MAY choose to not send further frames of that
type to this peer, or to take it as an indication that the extension is not supported by the peer,
or to enter into extension negotiations with the peer.

<!--

TODO:

 * warn MUXers about forwarding/coalescing extensions
 * mention the error detection capability

-->

# Security Considerations

<!-- TODO -->

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
