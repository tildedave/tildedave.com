---
layout: post
title: 'Clojure: DSLs as Configuration'

---

Configuration has a place within a software project [1].  Some things are truly external to the code and should be accessed out of it.  I think that dependency injection frameworks like [Spring](http://www.springsource.org/) do a good job of this, allowing you to specify the wiring of your objects outside of your program.

However, XML/JSON is just a document.  DSLs (domain-specific languages) are programmable documents.  In Java and C#, libraries like [Fluent NHibernate](http://fluentnhibernate.org/), [Mockito](http://mockito.org/), and [JMock](http://www.jmock.org/) wrap library interaction as a psuedo-DSL, though still recognizably in their original language.  In Ruby, [Rails](http://rubyonrails.org/) and [Chef](http://wiki.opscode.com/display/chef/Home) allow for specifications that seem completely divorced from their original language.

Clojure is a LISP port for the JVM and CLR.  In LISP, macros allow for completely reprogrammable syntax, but they are one of the more advanced features of the language involving some more esoteric syntax.  (In honesty usually I don't feel like I need to change language syntax for my programs!)

## Example Application: Restmock

[Restmock](https://github.com/tildedave/restmock) is a server for serving mostly static content, indexed by a configuration file.  The original reason for it was during the development of a frontend for a REST backend.  During the development lifecycle for a frontend application, there is a lot of minor work that doesn't a semantically rich backend and Restmock was developed in order to allow programmers to move faster during these tasks.

Serving static content is not a difficult task and is easily accomplished with many microframeworks [2] in a lot of different language.  I wanted a flexible application that could have a web 'core' for which would not change often, but which could change its behavior based solely on a external configuration file.  Specifically, I didn't want to have to change any code in the event that I needed to add another document.

Why Clojure?  At work, my team programs primarily in Java.  By bundling a server together with a configuration (with `lein uberjar` [3]), I could distribute a mock service backend that would work out of the box, without any need to install a new compiler or interpreter.

<h1>Configuration Take 1: XML</h1>

My first take on how to configure Restmock was to provide an XML file programmatically specifying routes.

```xml
<route>
  <id>can retrieve all the kittens</id>
  <request>
    <path>/kittens</path>
    <method>:get</method>
  </request>
  <response>
    <type>text</type>
    <config>
      <text>Some adorable kittens!</text>
    </config>
  </response>
</route>
<route>
  <id>can't make a new kitten</id>
  <request>
    <path>/kittens</path>
    <method>:post</method>
  </request>
  <response>
    <type>status</type>
    <config>
      <status>422</status>
    </config>
  </response>
</route>
<route>
  <id>can update a kitten</id>
  <request>
    <path>/kittens/([0-9]+)</path>
    <method>:put</method>
  </request>
  <response>
    <type>status</type>
    <config>
      <status>202</status>
    </config>
  </response>
</route>
<route>
  <id>xml representation of a kitten</id>
  <request>
    <path>/kittens/([0-9]+)</path>
    <method>:get</method>
  </request>
  <response>
    <type>file</type>
    <config>
      <path>cute-kitten.xml</path>
    </config>
  </response>
</route>
```

XML-phobics may cringe, but really this is fine.  It let me achieve my initial goal to distribute a useful server to other team members.  However, it is very inflexible.  There is no way to handle server state; you will always return the same file on the same request.  There is no way to test that your backend is doing the right thing with regards to PUT, POSTs, DELETEs without checking the logs.

<h1>Configuration Take 2: Clojure Macros</h1>

What we are really doing in the above XML is building a server.  There are a few nouns used to build this server:

* *Request criteria*: Does an incoming request match this route?
* *Response*: What should I respond if a request matches my request criteria?

Requests, responses, and the specific types of request criteria and responses end up being the new syntax of our server specification using a Clojure DSL.  The equivalent specification of the above XML file in a macro-based DSL looks like:

```clojure
(routes
 (route "Can retrieve all the kittens"
        (request (uri "/kittens")
                 (method :get))
        (response (text "Some adorable kittens!")))
 (route "Can't make a new kitten"
        (request (uri "/kittens")
                 (method :post))
        (response (status 422)))
 (route "Can update a kitten"
        (request (uri "/kittens/([0-9]+)")
                 (method :put))
        (response (status 202)))
 (route "Kitten XML"
        (request (uri "/kittens/([0-9]+)"))
        (response (xml-file "cute-kitten.xml"))))
```

What should this look like when it is converted into code?

* Request criteria should be a function that takes a request object and returns either true or false.
* Responses should either be HTTP response objects or functions from request objects to HTTP response objects (in case we want to change how responses look for similar requests, i.e. return the ID as part of the XML for a request to `kittens/1`).
* A collection of routes tries each route's request criteria until one is matched, and then returns the response associated with that route.

## Request Criteria Macros

```clojure
(defmacro uri
  "Specifies a criteria of matching a URI"
  [path]
  `(fn [req#]
     (if (nil? (:uri req#))
       false
       (not (nil? (re-matches (re-pattern ~path)
                                     (:uri req#)))))))

(defmacro method
  "Specifies a criteria of matching a HTTP request's method"
  [method]
  `(fn [req#]
     (= ~method (:request-method req#))))

(defmacro request
  "Specifies a list of criteria to match a request on"
  [& criteria]
  `(fn [req#]
     (reduce #(and %1 %2)
             (map #(% req#)
                  (list ~@criteria)))))
```

In the above, there is some unusual syntax associated with making a macro:

* The ``` at the start means to replace the macro with literally the following syntactic form.
* `~` means to evaluate a symbol.
* `req#` tells the interpreter to always expand `req` to a different variable name in different locations to prevent namespace collisions.
* `~@criteria` means to take all the arguments represented by the symbol `criteria` and change them from a list back to a set of arguments.

The request macro first converts each of its criteria into a function from requests to booleans and returns a function from requests to booleans that requires all request criteria to be true.  (It may look a little complicated, but it is "just" a left fold over the boolean values of applying the mapping function to each request!)

## Response Macros

In contract to request criteria macros, response macros are very straightforward.

```clojure
(defmacro response
  "Specifies a response handler"
  [handler]
  `(fn [req#] (~handler req#)))

(defmacro text
  "Specifies a text response handler"
  [text]
  `(text-handler ~text))

(defmacro xml-file
  "Specifies a xml file handler"
  [file]
  `(xml-handler ~file))
```

`text-handler` and `xml-handler` are functions that just wrap the HTTP request with the appropriate headers, set Content-Type, set an appropriate status, etc.

## The Routes Macro

```clojure
(defn route-handler [req]
  (matching-uri-handler
   (list default-route-handler)
   req))

(defmacro routes
  "A routes is a collection of route handlers"
  [& routes]
  `(defn route-handler [req#]
     (matching-uri-handler (list ~@routes) req#)))
```

Wait, what's going on here?  The routes macro is defining a name, and not a generic name -- a very specific name, `route-handler`, that already has a definition.

The reason we define `route-handler` is so that the interpreter knows it is a valid symbol.  The `routes` macro then redefines that symbol to be that of our server specification.  This allows the web server to use the route-handler as the function from requests to responses.

Loading the DSL has a trick to it because of how Clojure namespaces interact:

```clojure
(defn load-restmock-config [file]
  (do
    (binding [*ns* (find-ns 'restmock.dsl)]
      (load-file file))))
```

Clojure doesn't let macros from one namespace define symbols in another.  Therefore, in order to use our `route-handler` trick, we need to, when we load the DSL as a config file, locally bind the namespace to be the one that `route-handler` is defined in.  This is a little technical but not too ugly.

## Conclusion

This is the same configuration, but it is more flexible.  Shared criteria can be defined once outside of the `routes` declarator and used within the specification.  You can write stateful interactions and criterias (more on this coming later!).  The good things about the XML configuration approach are still around: structured configuration that is external to the application.

Macros are an advanced feature of Lisp-like languages, but it is worth taking the time to wade through some more obscure syntax in order to understand when they are the correct solution to a problem.

## Notes

* [1] And yes, sometimes that configuration is in XML.
* [2] Sinatra (Ruby), Tornado (Python), Dancer (Perl), Ring (Clojure)
* [3] https://github.com/technomancy/leiningen

