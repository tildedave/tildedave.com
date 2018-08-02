---
layout: post
title: 'Very Thin Backends'
is_unlisted: 1
---

_Thin backends_ are application servers that act as a small amount of code wrapping a persistence layer (a database or a web service).  The first attempt at building a thin backend for the Rackspace Cloud Control Panel leveraged [libcloud](http://libcloud.apache.org), thinking that we could rely on the work of an open source library to move quickly.  Our API wrapped the programmatic libcloud API:

```python
from flask import jsonify, get_json

@app.route('/servers', method=['GET'])
def servers_list():
    # servers is an array of libcloud.compute.base.Node
    servers = driver.list_servers()
    return jsonify(servers=[{ 'id': s.name,
                              'name': s.name} for s in servers])

@app.route('/servers', method=['POST'])
def servers_create():
    request = get_json()
    server = driver.create_node(name=request['name'])
    return jsonify(server=[{ 'id': s.name,
                             'name': s.name}])
```

There's something initially appealing about this style of code.  It's very clear how to add new features.  It doesn't demand that you reinvent the wheel for new features: request goes in, appropriate call is made to the libcloud driver, response comes back.  You can give this code to a junior developer, ask them to add five more resources, and they can do it without incident.

However, as we added more and more resources, you ended up maintaining a large number of these wrappers.  To add a new capability to the user interface, you needed to add new wrapper code, add tests (possibly at both the unit and integration level), add documentation, and so forth.  Eventually the sheer amount of this wrapper code became a burden that inhibited change.

We ended up with over a thousand lines of Python code translating libcloud objects back and forth between JSON, including mappings between libcloud states and project-specific states that could be relied on to not change.  Additionally, our team was usually writing the functionality that we needed into libcloud as the library (quite reasonably) didn't yet support our very specific use-cases.  Because of this, every time we needed to access a new field in an upstream API, we'd need to build this field into an external library, and then update our wrapper code to access this field.  Our Python backend ended up as a very specific translation layer between an HTTP request to our application servers and a call into libcloud, which would make another HTTP request to an upstream service API.

Of course, every new feature _also_ needed to be implemented in the user interface, meaning that things like API validation were only checking for bugs in the data forwarded on from the requests as written in JavaScript.  In following our initial design of creating an API for our user interface, we spent most of our time wrapping another service's API with a layer that provided no major value and was just another place to introduce bugs.

## We Didn't Need an API, We Needed a Router

This insight that our Python code was just serving as a translation layer led us to our final solution: a generic router between an XMLHttpRequest made by client to an upstream server-side request.  Data returned from an upstream API would be routed back straight to the client.  Data sent to our app server would be forwarded on upstream.  When a new request needs to be made in the user interface, we build the user interface directly, making an XMLHttpRequest to a generic router endpoint, rather than writing new code that lives at the app server level.

```python
from flask import app, request
import requests

@app.route('/request/<path:remainder>`)
def do_request(remainder):
    if not 'auth_token' in session:
       return ("Unauthenticated", 401)

    _validate_csrf(data['csrftoken'])
    headers = { 'X-Auth-Token': session['auth_token'] }
    if request.method == 'GET':
       response = requests.get(UPSTREAM_BASE + "/" + remainder,
                               headers=headers)
    elif request.method == 'POST':
       response = requests.post(UPSTREAM_BASE + "/" + remainder,
                                data=json.dumps(request.form['data']),
                                headers=headers)
    # also handle DELETE, PUT, etc

    return (response.body, response.code)
```

The real version of the router code is pretty different: it's written in [Twisted](https://twistedmatrix.com/trac/), handles many different upstream servers, supports gzipped encoding, counts response codes and failed connections by upstream API, and has a built-in caching layer.  However the core principle remains that our backend's key responsibility is that of a request router and *not* an API for our user interface.

### Obvious Does Not Mean Necessary

I was directly responsible for our useless translation layer.  This was a bad mistake and I've learned from it by questioning the necessity of every new line of code that gets written.  Is the code actually necessary?  What happens if we follow this code to its logical conclusion?  For a patch introducing a new feature, what happens if every new feature looks exactly like that, replicates all the same patterns with minor changes?  Should we be happy with whatever repetition it contains?  If we don't improve this and have to repeat boilerplate code, are we going to be asked to do this again any time soon, or can we defer this design decision? On a growing project with many new features, these questions have forced my team to find clearer designs that have greatly increased our overall productivity, and they turn on the distinction between code that is obvious and code that is necessary.
