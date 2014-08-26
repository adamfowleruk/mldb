[Back to All Tutorials list](all.md)
# A MarkLogic Ontology

I've been working with MarkLogic 7 features a lot recently. These centre around the concept of Subjects, Predicates and Objects - triples. Examples include 'Adam knows Wendy' or 'Wendy likes Cheese'.

As I was implementing MLJS Semantic widgets for MarkLogic 7 I found I needed to define some specific RDF Types and predicates
in order to consistently link semantic subjects to documents. This page describes that effort, and scenarios around why these
approaches were taken.

There are some predicates, or properties, that should stay in the content world, but some that could live in the triple world, or be migrated from relational to triples.

This document tries to summarise ones I have come across. I may create my own ontology for this information. This is a starter document for that ontology.

Properties that should stay as MarkLogic's content properties:-
- created (datetime)
- updated (datetime)
- createdby (ML username)
- updatedby (ML username)

Below are some predicates I've used in the past:-
- graphuri derived_from docuri
- any_subject_iri mentioned_in docuri

And some third party ontologies I've used:-
- FOAF - Friend of a Friend. For modelling people and organisations and their linkages
- Geonames - For places and their locations

Other ideas for predicates that may be useful in MarkLogic
- Concepts around documents - what project are they part of? Who is on the project? What roles do they have on the project? What roles do they have on the document? (Reviewer, originator, etc.)

Some operations this ontology allows:-
- Find all Joint Customers with a Bank balance below 100 GBP, whose Insurance client IDs are mentioned in claims documents, but only those with claims documents that mentioned the word 'pedestrian'
- Find all Senior Geologists in our organisation where they have contributed to documents that have been tagged with the keywords 'geology' and 'iceland'

## MarkLogic Document

It can be useful to describe a MarkLogic Document semantically. This allows you to explicitly specify facts about the document rather than
always embed facts within a document, and thus relate them to the document implicitly. Querying embedded facts with just SPARQL means
that the fact they are contained within a document is never exposed. You need another way to do this.

In various widgets I have support for related documents using a MarkLogic Document RDF Type. Below are its available predicates/types.

| Fact | Predicate | Valid Values | Notes |
| --- | --- | --- | --- |
| RDF Type | a | http://marklogic.com/semantics/ontology/Document | Specifies this Subject is a MarkLogic document itself |
| Has URI | http://marklogic.com/semantics/ontology/Document#uri | E.g. /some/path/to/mydoc.xml | The document's URI within this MarkLogic database |
| Mentions | http://marklogic.com/semantics/ontology/mentions | Links this document to a Subject mentioned within it |

Note: It may be advantageous to use predicates within W3C PROV-O to relate Subjects to a MarkLogic Document, or to describe the document
itself. (E.g. generated_by)

## Linking to a MarkLogic Document

There are then a set of predicates to be used within other Subjects in order to relate them to a document Subject:-

| Predicate | Applies to | Notes |
| --- | --- | --- |
| http://marklogic.com/semantics/ontology/mentioned_in | Any RDF Subject | This subject has been mentioned in the object (A MarkLogicDocument RDF Instance) |
| http://marklogic.com/semantics/ontology/derived_from | A GRAPH ?graph name | Where this set of facts (named graph) were derived from |

## Appendix A: My Semantic Best Practice Recommendations

These recommendations are personal notes and opinions. Please read them with an open mind and decide whether - in your scenario
 - it makes sense to follow them.

- For triples that should always be modified when the document content is modified, store within the document (or a document property) - Example: You have done entity extraction on a document and found a &lt;person-name&gt;Adam Fowler&lt;/person-name&gt; and a &lt;organisation-name&gt;MarkLogic&lt;/organisation-name&gt; and your document creation process also expresses the fact 'Adam Fowler member_of MarkLogic' (issues around automatic assertions aside…)
- Conversely, only ever store triples in a document that should be replaced/updated every time the document is updated. Specifically, do NOT embed 'reference facts' that are not directly implied by the document. (i.e. don't 'enrich' your extracted facts within the document by adding wider facts around them) - to do so means you may inadvertantly blow away reference facts, or duplicate them across multiple documents.
- Some document extracted 'facts' may require different security settings to the document, or different security to other facts extracted from the document. In this case store them in an XML document (NOT just a named graph) tightly linked to the document. This is easy to update via triggers or similar when you update the document - Example: /some/path/to/mydoc.xml/paragraph1.xml or /some/path/to/mydoc.xml/topsecret.xml), with the appropriate security set on it
- Add a derived_from fact to named graphs you create to link the whole lot of facts as a single set back to the MarkLogic document)
- Create a MarkLogic ontology that has RDF types including MarkLogicDocument with predicates like 'mentioned_in' and 'derived_from' (See: https://github.com/adamfowleruk/mljs/blob/oct13/tutorials/901-ontology.md - this is a work in progress, should be finished at the end of the month)
- Whether embedding facts or storing them separately, always link back to the 'originating' document (where applicable) via a 'derived_from' to a MarkLogicDocument entity
- Never rely on extracting the graph name for any target subject/fact - E.g. if in the below example we perform some complex SPARQL to find our Originating Document subject, we should store a 'has_uri' predicate on that subject, NOT require knowing the name of the graph (which is the document uri, in the below example) in order to find the originating document
- Remember that a MarkLogic document can have multiple collections, whereas using the W3C graph store protocol you can only update or replace a named graph - thus if you want to store the fact once and have it part of 'multiple graph names' you are better of creating an XML document via XQuery/REST that contains sem:triples and adding it to multiple collections, rather than using the graph store protocol REST endpoint to save these facts twice - once against each collection. (As MarkLogic implements named graphs as collections, this works well - only issue being scalability as by default ML splits at around the 100 triples per doc mark).

I believe we should also take a look at PROV-O when it comes to asserting facts about how a named graph / triple was derived.

I would also like to see a MarkLogic specific extension to the REST graph store endpoint allowing multiple named graphs rather than the single one required by the W3C spec… I'll get around to documenting all this soon and them submit relevant RFEs as required and chat to Buxton et al.

## Appendix B: Using PROV-O with MarkLogic

The below is from an email I sent detailing where PROV-O may be of use to a customer of MarkLogic.

Lets say you do a document upload and it's converted to XHTML. As part of the conversion process you record info about the conversion and requesting user as triples within the XHTML document. This makes sense because they 'belong' to that rendering. If the rendering is updated, those facts should be updated. This is a good fit for embedded triples.

Let's say that it's a claim document instead. You know the client ID because it's been enriched in the doc, or provided by a user at some point. This is embedded within the doc - 'Document relates to Customer 1234'. In addition to doing this, separately you're pulling in facts (data) from a relational DB about Clients, Accounts and balances. This is pulled in to the triple store through RDB2RDF so exists only within the triple store, separately for the document. This makes sense because there could be many or no claim documents for a particular customer.

Now let's say you want to pull back all customers with claims that mention pedestrians… Pretty straightforward in XQuery… something like this (cant remember exact syntax) :-

```xquery
sem:sparql( "select distinct ?subject, ?custnum where { ?subject a /ns/Customer . ?subject has_customer_number ?custnum . }", cts:term-query("pedestrian") )
```

Pretty easy… But what if you want to combine this with checking their associated balance was &lt; 100… you may be tempted to alter the Sparql to do this:-

```sparql
select distinct ?subject, ?custnum where {
  ?subject a /ns/Customer .
  ?subject has_customer_number ?custnum .
  ?subject has_account ?acc .
  ?acc has_balance ?bal .
  FILTER (?bal &lt; "100"^^&lt;xs:double&gt; )
}
```

All fine… except it will never return any results, because the cts:term-query is restricting the documents that the triples are checked against. Because the account and balance facts exist external to a matching document, they will never be present, thus the above query will always return nothing.

This leaves you with needing a way to answer the sparql query first to return a list of candidate document URIs instead - basically the pattern in reverse. Now you could just do this:-

```
&lt;/ns/Customer/1234&gt; &lt;mentioned_in&gt; "/mydocs/some/uri/claim.xml" .
```

The problem with this though is that you cannot hang other facts off of the URI. E.g. generated_by etc from PROV-O. This leaves us with having to use some sort of Entity class for MarkLogic documents. Indeed, if we do this and adopt the PROV-O relationships we find they are actually a very good fit. They support use cases of documents being updated over time, and altered as part of software processes. They can handle things like original documents, xhtml renderings, versions of documents, or alterations (E.g. enrichments) via external software agents.

So in the above example, you would embed facts like these in the document:-

/docs/some/uri/claim.xml:-
```
&lt;/docs/some/uri/claim.xml&gt; a &lt;MarkLogicDocument&gt; .
&lt;/docs/some/uri/claim.xml&gt; has_uri "/docs/some/uri/claim.xml" .
&lt;/docs/some/uri/claim.xml&gt; prov:version_of &lt;/docs/some/uri/claim.docx&gt; .
&lt;/ns/Customer1234&gt; mentioned_in &lt;/docs/some/uri/claim.xml&gt;
```

Elsewhere in the triple store you have this customers record, accounts and balances.

You can now do this in just sparql:-

```sparql
select distinct ?subject, ?custnum, ?claimsdocuri where {
  ?subject a /ns/Customer .
  ?subject has_customer_number ?custnum .
  ?subject has_account ?acc .
  ?acc has_balance ?bal .
  FILTER (?bal &lt; "100"^^&lt;xs:double&gt; )
  ?subject mentioned_in ?mldoc .
  ?mldoc has_uri ?claimsdocuri .
}
```

Then you can take those URIs and do a document-query with your term query to get the relevant docs.

I think this use case will be a lot more common, searching through semantic information to arrive at content, rather than searching content to give a list of candidate facts to search. You'd never be quite sure you'd got all the relevant facts by restricting the sparql to results in particular documents. That potential gap in knowledge would worry me.

Of course the problem is that you may pull back hundreds of URIs and end up building a mammoth structured/cts search to search over them. I think a cts:sparql-doc-query() that expects ?docuri as a returned binding to give you a set of document URIs would be very, very powerful. I could then submit sparql as one query to my standard content search endpoint /v1/search within a structured query. So you can still do sparql against /v1/graphs/sparql but you also have the option of a combined query against /v1/search.

As it stands there is *no way* you can do a combined sparql and content search in a single hit via the REST API at the moment. You have to do it in two steps.

You also get other benefits from using PROV-O in that you can save facts about every document edit in the triple store (rather than just against the document) so that even if you weren't using DLS you could at least keep a record of who edited what, when, and how.

- - - -

[Back to All Tutorials list](all.md)
