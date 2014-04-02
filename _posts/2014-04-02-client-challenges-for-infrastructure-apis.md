---
layout: post
title: 'Client Challenges for Infrastructure APIs'
---

My team integrates with a number of [OpenStack](https://www.openstack.org/) APIs that are primarily concerned with provisioning resources.  Using the OpenStack Compute API (Nova), you can create a virtualized server and use it to power a website.  The API won't configure your site; you'll need to log in using an SSH client such as [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) or [OpenSSH](http://www.openssh.com/) and configure Wordpress yourself.  These APIs replace the old workflow where to get a box set up, you'd have to open a ticket and it would sit in a queue before it got to the right people who would set up your physical machine in a datacenter.  A public cloud offering based on OpenStack (such as Rackspace Cloud Servers) supports on-demand resource creation, so there are no tickets, no physical machines, no special wiring that needs to be done -- new servers are slices of a larger machine that running a virtualization technology such as [KVM](http://www.linux-kvm.org/).  Although system administration tasks on Windows and Linux operating systems are drastically different, the OpenStack Compute API provides a uniform interface for creating, rebooting, imaging, and so on.  I use the term _infrastructure APIs_ to describe these.

I have worked on the Rackspace Cloud Control Panel team for the last three years.  During that time I've written a lot of clients for many different APIs, including just about every OpenStack API offered as part of Rackspace's public cloud offering.   I have contributed to [Apache Libcloud](https://libcloud.apache.org/) and written [littlechef-rackspace](https://github.com/tildedave/littlechef-rackspace), a command-line tool for bootstrapping new Rackspace Cloud servers with Chef.  I've seen new APIs evolve and had opportunities to influence the development of new ones.  In this post I'll go into certain ways that infrastructural APIs can make writing a client more difficult, using examples from OpenStack.  In each of these cases, the client is forced to implement unnecessary logic.

The amount of logic that lives in the client may seem like an abstract concern.  However, if a feature of an API requires information outside of that API for a client to use it properly, that feature can never change without breaking clients.  Clients for Nova such as [fog](http://fog.io), [libcloud](http://libcloud.apache.org), [python-novaclient](https://pypi.python.org/pypi/python-novaclient/), and [Horizon](http://docs.openstack.org/developer/horizon/) must implement this duplicate logic through hardcoding it in.  With numerous clients hardcoding out-of-band information into their implementation, servers will be unable to change without releasing a backwards-incompatible new version.  The end purpose of good API design is to allow clients and servers to continuously improve through dynamic and independent change.

## HTTP APIs and REST

A common way to classify an HTTP APIs is the [Richardson Maturity Model](http://martinfowler.com/articles/richardsonMaturityModel.html), which evaluates APIs on a scale associated with how closely they adhere to [REST](http://en.wikipedia.org/wiki/Representational_state_transfer) (Representational State Transfer); e.g. phase 1, phase 2, or phase 3.  In phase 1, the API provides a list of available _resources_ to operate on; all the servers for a customer are located at the `/servers` URI.  In phase 2, clients interact with those resources through a standard set of HTTP verbs.  For example, to make a new resource a client will `POST` (HTTP create) to the base URI `/resources/`, to update a resource with id `56721`, the client will `PUT` (HTTP update) data to the URI `/resource/56721`.  [Most APIs](http://timelessrepo.com/haters-gonna-hateoas) handle these as they are fairly simple to do.  Less APIs match phase 3, Hypertext as the Engine of Application State (acronymnized as "HATEOAS"), where the API responds with hypertext and allows clients to discover all of the state of the application and the transformations that are permissable between them.

The OpenStack APIs are psuedo-RESTful in that they refer to resources and modify those resources through HTTP verbs.  With the OpenStack v2 API you create a server using the an HTTP `POST` to the `/servers` URI and JSON data:

```bash
> POST /servers
> {
>   "name": "new-server",
>   "imageRef": "84325e03-14c6-47f4-91fe-c9480d3af210",
>   "flavorRef": "0dc9a96f-b3d5-4f5d-afd7-6f86b866a137",
>   "networks": [
>     {
>       "uuid": "00000000-0000-0000-0000-000000000000"
>     }
>   ]
> }
< 202 Accepted
```

In contrast to REST, APIs like AWS EC2 follow a SOAP-RPC model which expose a number of different functions that a client will individually call.  Whereas a REST-inspired HTTP API will request a list of a server resources with `GET /servers`, the EC2 API will list instances through the `DescribeInstances` call.  While I'm going to focus on OpenStack APIs here due to my own familiarity, the issues I'll describe are fairly general.

## What Actions Can a Customer Perform?

Customers looking to manage their resource will sometimes need to perform actions on their resource.  A server might get stuck and need to be rebooted to function normally.  A server might need to be resized to a bigger CPU and disk.  A server may experience a total operating system failure, meaning that a rescue drive will need to be mounted to recover lost data.  These actions correspond to commands that will eventually be executed by the hypervisor.  In KVM, a reboot command is using [`virsh reboot guest-id`](http://virt-tools.org/learning/start-stop-vm-with-command-line/); whatever an infrastructure management API is doing in taking a request from a client, it will eventually result in this command being executed on the underlying hypervisor.  Because of this RPC-nature, management operations do not naturally match the conventions of a RESTful API; when rebooting a server, there is no `REBOOT` HTTP verb that can be executed on a `server`.

To perform these sorts of actions, the Nova API exposes an `/action` URI as a subresource of a server.  To reboot a server, the client sends a POST request:

```bash
> POST /servers/ee5e61ba-b740-11e3-8e67-58946bad6160/action
> {
>  "reboot": {
>    "type": "HARD"
>  }
> }
< 202 Accepted
```

There are [two kinds](http://docs.openstack.org/api/openstack-compute/2/content/Reboot_Server-d1e3371.html) of reboot operations that can be performed: SOFT (operating-system initiated) and HARD (hypervisor-initiated).  A soft reboot is operating-system initiated, while a hard reboot is hypervisor-initiated where the instance is forced to stop and then restart.  Similarly, to mount a rescue drive onto a server, the client sends a POST request:

```bash
> POST /servers/ee5e61ba-b740-11e3-8e67-58946bad6160/action
> {
>  "rescue": null
> }
< 202 Accepted
```

All of these very different actions are accessible through the same URI.  The action that is performed is based on what arguments are sent to the `/action` URI.

### "Action" URIs Force Logic Into The Client

It's important to know which actions on resources are likely to succeed if initiated; nobody likes to try to do something only be told, no, try again later.  However, the implementation of a general `/action` operations put a lot of burden on the API client and all of these must be built with external information to know which operations are supported on an instance at any given moment.

First off, [different hypervisors support different actions](https://wiki.openstack.org/wiki/HypervisorSupportMatrix).  Suppose your account has 2 instances on it.  One's managed by a KVM hypervisor, one's managed by an [Ironic](https://wiki.openstack.org/wiki/Ironic) driver (no live hypervisor).  Both servers have the same `/action` resource; however, rescue mode (accessed by sending `{ "rescue": "none" }` to the `/action` URI) is only available to the instance running under KVM.  The current URI structure only works if you are running a homogenous Nova instance (same hypervisors) and there is some method for a client to discover which actions are supported by your particular install.

Additionally, certain operations are only possible in a certain state.  An `ACTIVE` instance can be [suspended](http://docs.openstack.org/api/openstack-compute/2/content/POST_os-admin-actions-v2_suspend_v2__tenant_id__servers__server_id__action_ext-action.html), putting it into `SUSPENDED` state.  Once `SUSPENDED`, it can be [resumed](http://docs.openstack.org/api/openstack-compute/2/content/POST_os-admin-actions-v2_resume_v2__tenant_id__servers__server_id__action_ext-action.html).  All of these operations are managed through sending different methods to the `/action` URI.  The [OpenStack documentation](https://github.com/openstack/nova/blob/grizzly-2/doc/source/images/PowerStates2.png) contains complicated logic that clients need to adhere to in order to know which actions are possible in which VM state.

[{{ 'http://static.davehking.com/openstack-vm-transitions.png' | img:'style="width: 750px;"' }}](http://docs.openstack.org/developer/nova/devref/vmstates.html)

The `/action` URI requires that clients code these state transitions into their own behavior, or else requests will fail and need to be made at a different time.  After issuing a password reset, the client must wait for the instance to enter the instance to enter the `set_admin_password` task state, then wait for it to go back into `ACTIVE`.  This logic needs to be coded differently for every action that could possibly be initiated against an instance.

### Improving State Transitions Through a Discoverable API

One possibility to improve this API design is to explicitly make a resource corresponding to each kind of action that is supported on a server, and provide links in the server resource.  Rather than an `/action` URI that does different things based on the argument, we add URI for each of the possible actions that can be performed on a server, e.g. `/hard-reboot`, `/soft-reboot`, `/enter-rescue`.

```bash
> GET /servers/ee5e61ba-b740-11e3-8e67-58946bad6160
< {
<  "name": "test-server",
<  "status": "ACTIVE",
<  "links": [
<    {
<      "rel": "hard-reboot",
<      "uri": "/servers/ee5e61ba-b740-11e3-8e67-58946bad6160/hard-reboot"
<    },
<    {
<      "rel": "soft-reboot",
<      "uri": "/servers/ee5e61ba-b740-11e3-8e67-58946bad6160/soft-reboot"
<    }
<  ]
< }

> GET /servers/ee5e61ba-b740-11e3-8e67-58946bad6160/hard-reboot
< 405 Method Not Allowed

# Performs a hard reboot, no body
> POST /servers/ee5e61ba-b740-11e3-8e67-58946bad6160/hard-reboot
< 202 Accepted

> GET /servers/ee5e61ba-b740-11e3-8e67-58946bad6160
< {
<  "name": "test-server",
<  "status": "REBOOTING",
<  "links": [
<  ]
< }
```

Exposing links to relevant actions allows clients to discover which operations are supported on a server at any given moment.  After a reboot request is initiated, no `link`s are returned on the server resource, so a client knows not to initiate a request.  When implementing a different command, such as creating a snapshot of the virtual machine's running state, a client only needs to wait for the server resource to contain a `link` with `rel="create-image"`.  If entire actions are never supported on an instance, that action will never be shown to be possible as there is no link to perform it.

Rather than copying the state diagram from documentation into the code of the client, the client relies on the links available from the server resource to know which states it can go into next.

I think this approach is better but the implementation is still not ideal.  First, clients must guess which HTTP verb is needed to trigger a `hard-reboot` or `soft-reboot` operation.  Additionally, it's not clear how to ideally handle "terminal states" that an instance will enter and _never_ return to a situation where another action is possible (Nova represents this through the `ERROR` state).  Clients need some other information about the API to know when a server has entered this state or they will wait forever.

## How Do We Track Long-Running Requests?

Many management operations in an infrastructure API take a long time before completion.  For example, resizing a server can take over 10 minutes, depending on how large the disk is resized to.  During those 10 minutes, the server is offline and will not serve customer traffic.  Rather than keep the client's request open until the resize has completed, the API returns `202 Accepted` and kicks off a backend process that will resize the server.  The Nova API reifies this in-progress request into the "status" of the server resource. During this time the server is listed as in `RESIZE` state, meaning that it is offline and cannot have normal actions taken on it: reboot, imaging, rescue, etc.

I want to focus on problems that come from the _length_ of this transaction.  With an in-progress action stored in the server status, there's no natural place to update with information about the request such as how long it's taken, how much longer it will take, or even whether or not it has failed.  This approach makes it difficult to handle simultaneous actions that may have different success or failure results because the requests aren't things in themselves.  They are simply reflected in the status of the server and it is up to the client to infer whether they succeeded or failed.

Worse, the Nova API handles failures around certain long-running actions by putting an instance into "ERROR" state.  Resetting an admin password is an asychronous operation that will changes the `root` user password on Linux and the `Administrator` user password on Windows. Because different operating systems have different password requirements, the API cannot validate ahead of time whether or not a password reset will succeed -- a password that succeeds on a Linux server may fail on a Window server.  However, if the request to set the administrator password fails, the instance is put into `ERROR` status, preventing any future action.  For the Rackspace public cloud implementation of Nova, this means a support escalation is required to allow a customer to perform further actions on the instance (such as imaging or rebooting).  This awful behavior is a natural result of coupling instance state with the status of an individual request on that instance.

### Giving Clients Necessary Information With "Request"-specific Resources

Long-running operations are not incompatible with a RESTful API design.  [Other approaches](http://restcookbook.com/Resources/asynchroneous-operations/) create temporary resources to represent an in-flight request.  We could do this by adding a `/requests` resource to the server resource.

```bash
> GET /servers/ee5e61ba-b740-11e3-8e67-58946bad6160/requests
< {
<   "requests": []
< }

> POST /servers/ee5e61ba-b740-11e3-8e67-58946bad6160/hard-reboot
< 202 Accepted
< Location: /servers/ee5e61ba-b740-11e3-8e67-58946bad6160/requests/1

> GET /servers/ee5e61ba-b740-11e3-8e67-58946bad6160/hard-reboot/requests/1
< {
<   "type": "hard-reboot",
<   "status": "ACTIVE"
< }

> GET /servers/ee5e61ba-b740-11e3-8e67-58946bad6160/hard-reboot/requests/1
< {
<   "type": "hard-reboot",
<   "status": "COMPLETED",
<   "completionTime": "Sat, 29 Mar 2014 11:20:42 -0400"
< }
```

These requests provide a place to put information about an individual customer's request.  You can issue a reset password command, have it fail, and then issue another one.  Individual requests can fail without affecting the health of the instance.

## How Do Customers Locate the Right Resource?

A common API feature is where a customer needs to interact with a very specific resource.  The customer doesn't think of their resource as `/servers/0116e1ab-f135-4365-b882-ba7a0c413903`.  If their instance at IP `192.168.7.51` stops  responding, their first action will be to find this server resource to force a reboot.  The first thing that a customer does in interacting with the API is to translate their concept of the resource into the API's language.

Many APIs have too much data to return for the client to list every applicable resource.  For example, the Twitter API will return a maximum of 3200 tweets for the [`/statuses/user_timeline` request](https://dev.twitter.com/docs/api/1.1/get/statuses/user_timeline).  The API has been built to support the expected interaction style here: Twitter returns a large amount of data, the expected customer integration is scrolling through the returned data and asking for more once that returned data has been consumed.

Certain OpenStack APIs similarly introduce pagination to their APIs.  For example, the Rackspace Cloud Database public cloud [implementation](http://docs.rackspace.com/cdb/api/v1.0/cdb-devguide/content/pagination.html) of the [Trove](https://wiki.openstack.org/wiki/Trove) API only returns 20 instances at a time.  Imagine this as implemented in a browser: clients with a large number of instances will see pages and pages and must click 'next' to scroll through each one.  However, when clients are managing their infrastructure, they likely are only interacting with the API because they need to change the configuration of a known existing instance that just happens to be on the third page of results.  This configuration decision leads to a mismatch with customer behavior and forces a suboptimal interaction mode.

These problems are even more clear when the API is meant to manage a large amount of resources.  The Swift API (Object Storage) can support tens of thousands of "containers" and "objects"; objects represent binary data, and containers group them together.  However, the API does not support any search for containers, and only supports [prefix-search](http://docs.openstack.org/api/openstack-object-storage/1.0/content/GET_showContainerDetails_v1__account___container__storage_container_services.html) for objects.  As an example of how this severely limits clients, Swift supports [psuedo-hierarchical folders](http://docs.openstack.org/api/openstack-object-storage/1.0/content/pseudo-hierarchical-folders-directories.html): you name your object something like `photos/animals/kitten.jpg` and then walk through a container using prefix search `photos/`, `photos/animals/`, etc.  Although prefix-based search allows navigating folder structure, there is no way to search a container only for `kitten` files or `jpg` objects that may have different prefix.

### Resource Location is a First-Class Concern

When designing an API, resource location needs to be considered.  It isn't enough that there is a method that clients _can_ use to find a resource; the ways that your API allows customers to find the resource will define the clients that can be built against it.  If the API is meant to deal with large listing of data, a full-feature search, with query parameters that match customer use cases, is essential to a great experience.

(This isn't to say that an API should _never_ paginate -- pagination needs to be done in the case where listing all resources will have a poor customer experience or there is legitimately be too much data to return.)

## Why Do APIs Make These Mistakes?

So far I've talked about several examples of design failures I believe that are present in infrastructure management APIs using examples from a few different OpenStack projects.  I characterize these issues as examples of how these APIs have mistakenly focused on the _infrastructure_ as their main value add.  Do customers care about their instance being in `RESIZING` state?  I don't think so.  They certainly care about their instance being _offline_ during this action.  However, the mechanics of the resize operation are unimportant -- customers just want the resize operation to be finished, or, in the case where it fails, to try again.  Their end goal is for the instance can be resized, and many details of the API hinder this goal.

From a customer perspective, the resources being managed are not intrinsically valuable -- nobody provisions resources just for the sake of having them and nobody interacts with resources just to interact with them.  Fifteen years ago, if you wanted a server, you'd have to call someone on the phone to get it installed in a datacenter.  Service providers moved to ticketing systems to handle more requests at once.  Now you can sign up with an Infrastructure as a Service provider such as Rackspace and make a request to an HTTP API running OpenStack Nova to make a server.  After you have a server, you still have to do all the normal system administration tasks on the data level such as locking down login, setting up custom firewalls, installing and configuring software like Wordpress.  Time spent interacting with an application's infrastructure is a necessary but only instrumental action.

Because of the importance in configuring infrastructure, the requests that a customer makes should be treated as first-class entities.  I've gone into these problems that come from focusing on infrastructure without focusing on requests in depth: how can a client know if it's safe to make a request, how can a client check in on an ongoing request, and how can a client find the appropriate resource to make a request against in the first place?  Everything that inhibits getting these answers is a failure of the API.

_Thanks to Andrew Laski for reviewing an initial draft of this post._
