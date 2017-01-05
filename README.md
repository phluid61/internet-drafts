Where I keep my Internet-Drafts.

In general, these Internet-Drafts are submitted in full conformance with
the provisions of [BCP 78][1] and [BCP 79][2].

[1]: <http://tools.ietf.org/html/bcp78>
[2]: <http://tools.ietf.org/html/bcp79>

See the [LICENSE](LICENSE) file.

Contributing
------------

Each draft contains in its abstract a pointer to the place where
discussion about that draft is held.  Pull requests are welcome.

Please try to ensure that pull requests update the `draft.md`
documents.

### Code of Conduct

Further to the standards, guidelines, and expectations of the IETF,
this particular repository is subject to its own
[Contributor Code of Conduct](code_of_conduct.md)


Tool Chain
----------

    markdown --> xml --> txt

The ultimate source file for each draft is `draft.md`

It is interpreted using the [kramdown-rfc2629][3] parser to produce a
standard [RFC 2629][4] XML file.

The XML file is transformed using [xml2rfc][5] to produce a plain text
internet draft, and a beautiful HTML document.

There is a Makefile in the same directory as each draft to automate
the process.

The entire toolchain was copied from https://github.com/mnot/I-D/


Notes to self
-------------

* <https://tools.ietf.org/tools/idnits/> check for nits
* <https://datatracker.ietf.org/submit/> submit draft


[3]: https://github.com/cabo/kramdown-rfc2629
[4]: https://tools.ietf.org/html/rfc2629
[5]: http://xml2rfc.ietf.org/

