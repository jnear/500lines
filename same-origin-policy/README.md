Understanding the Same-Origin Policy with Alloy
===============================================

Authors:
* Eunsuk Kang (eskang@mit.edu)
* Santiago Perez De Rosso (sperezde@csail.mit.edu) 
* Daniel Jackson (dnj@mit.edu)

The same-origin policy (SOP) is one of the most important mechanisms for browser security. Despite its widespread adoption by modern browsers, many developers experience a difficulty understanding precisely what the SOP provides, how to bypass it when necessary, and what its security implications are. 

This chapter is soemwhat different from other chapters in this book. Instead of building a working implementation of a browser with the same origin policy, our goal is to construct a concrete, executable _model_ that serves as a simple yet precise documentation of the SOP. Like an implementation, this model can be executed to explore dynamic behaviors of the system; but unlike an implementation, the model omits low-level details that often get in the way of understanding the essential core of the SOP. 

To construct this model, we use [Alloy](http://alloy.mit.edu), a language for modeling and analyzing software design. The latest version of the Alloy Analyzer, required to run the models in this chapter, can be downloaded [here](http://alloy.mit.edu/alloy/download.html). 
