/**
  *  browser.als
  *    A model of a browser
  */
module browser

open http

sig Document {
  src: Url,  -- URL from which this document was originated
  content: Resource -> Time,  -- the content of the document (i.e., DOM)
  -- "document.domain" property, at any time it could match several hosts (if
  -- for example is set to something like *.foo.com)
  domain: Domain -> Time,
}

sig Browser extends Client {
  documents: Document -> Time,  -- documents that browser displays over time
  cookies: Cookie -> Time,  -- cookies stored by the browser over time
}

/* HTTP request sent from a browser to a server */

sig BrowserHttpRequest extends HttpRequest {
  doc: Document
}{
  -- the request comes from a browser
  from in Browser
  -- the cookies being sent exist in the browser at the time of the request
  sentCookies in from.cookies.start
  -- every cookie sent must be scoped to the url of the request
  matchingScope[sentCookies, url]

  -- browser creates a new document to display the content of the response
  documents.end = documents.start + from -> doc
  -- the new document has the response as its contents
  content.end = content.start ++ doc -> response
  -- the new document has the host of the url as its domain
  domain.end = domain.start ++ doc -> url.host
  -- the document's source field is the url of the request
  doc.src = url

  -- new cookies are stored by the browser
  cookies.end = cookies.start + from -> sentCookies
}

pred matchingScope[cookies: set Cookie, url: Url] {
  all c: cookies | url.host in c.domains
}

/* Commands */

run {}

// Can we have two documents with different src but the same "document.domain"
// property at some point in time?
check {
  no disj d1, d2: Document | some t: Time |
    d1.src not in d2.src and d1.domain.t = d2.domain.t
}
