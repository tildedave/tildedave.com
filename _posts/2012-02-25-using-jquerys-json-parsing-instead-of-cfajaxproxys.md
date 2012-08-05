---
layout: post
title: 'Using JQuery AJAX instead of CFAJAXProxy'
---

This is a sufficiently wacky enough scenario that I don't think it will be useful for everyone, but I learned a bunch about how JavaScript and ColdFusion interact from client to server so writing this up is probably worthwhile.

This project is a standard ColdFusion backend (CF8) that sits in front of a SQL Server database. Rows are fetched from the database and displayed in a JQuery DataTable widget -- one of the main reasons of using DataTables is the Excel export.

Sometimes we fetch a lot of data to export (on the order of 5MB or more). This is transferred back to the browser as JSON. For most of our requests to the server, we use CFAjaxProxy to instantiate JavaScript objects that make requests to the server on method invocation:

```html
<cfajaxproxy cfc="package.model.BackendService" jsclassname="BackendService">

<script type="text/javascript">
  var service = new BackendService();
  service.fetchAllTheData();
</script>
```

The specific issue I was having was that Firefox died while parsing the returned data with a console error in `cfajax.js`.  Digging into I found that the issue was related to how the browser escapes returned JSON data.

I replaced the method invocation with a call to JQuery's JSON handler:

```javascript
  proxy = new BackendService();
  // OLD CODE
  proxy.fetchAllTheData(arg1, arg2, arg3);

  // NEW CODE
  $.getJSON("/package/model/BackendService.cfc",
    {
      method: "fetchAllTheData",
      returnFormat: "json",
      argumentCollection: JSON.stringify(
        {
          argName1: arg1,
          argName2: arg2,
          argName3: arg3
        }
      ),
      _cf_clientid: window._cf_clientid
    },
    function (data) {
      proxy.callbackHandler(data);
    });
```

This had the happy effects of fixing the bug (always good) while using a more mainstream technology (JQuery 1.6+ over years-old CF8 ajax.js) for browser/server interaction.
