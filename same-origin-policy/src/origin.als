/**
  *  origin.als
  *    A model of the notion of origin per the SOP
  */
module origin

open http
open browser

// An origin is defined as a triple (protocol, host, port) where port is
// optional
sig Origin {
  protocol: Protocol,
  host: Domain,
  port: lone Port
}

fun origin[u: Url] : Origin {
  {o: Origin | o.protocol = u.protocol and o.host = u.host and o.port = u.port }
}

fun origin[u: Url, h: Domain] : Origin {
  {o: Origin | o.protocol = u.protocol and o.host = h and o.port = u.port }
}

fact {
  no disj o1, o2: Origin |
    o1 != o2 and o1.protocol = o2.protocol and o1.host = o2.host and
    o1.port = o2.port
}

run {}
