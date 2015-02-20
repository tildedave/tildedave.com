---
layout: post
title: 'Introduction to Contexts in React.js'
---


[Contexts](https://facebook.github.io/react/blog/2014/03/28/the-road-to-1.0.html#context) are a feature that will eventually be released in React.js - however, they exist today in an undocumented form.  I spent an afternoon looking into the present implementation and was frustrated by the lack of documentation (justified, as it is a changing feature).  I've pieced together a few code examples that I found helpful.

In React.js a context is a set of attributes that are implicitly passed down from an element to all of its children and grandchildren.

Why would you use a context rather than explicitly passing properties down to child elements?  There are a few different reasons.  You may be building a widget with a large child tree where child elements have the ability to drastically affect the widget's overall state.  If you're not using the Flux pattern (where the parent widget listens to Stores that are affected by Action Creators invoked by the child elements), the idiomatic way to do this is to pass callbacks that affect the overall widget through `props` - this can be a bit awkward when you are passing a callback down several levels.

Another situation where contexts are useful is where you are doing server-side rendering - in this case data comes in that is uniquely associated with the user (e.g. session information).  If your elements require session information this needs to be passed down from parent to child which gets inelegant very quickly.


**Update (2/19/2015):** `React.withContext` is [deprecated](https://github.com/facebook/react/blob/a411f3e0dcac3cada4ce0acf6603bbb8ff7024a6/src/core/ReactContext.js#L54) as of React 0.13-alpha.  You should investigate `getChildContext` with a wrapper component for future-facing code.  Contexts themselves are not going away - they are [planned for React 1.0]((https://facebook.github.io/react/blog/2014/03/28/the-road-to-1.0.html#context) and at ReactConf 2015 the React team [confirmed](https://www.youtube.com/watch?v=EPpkboSKvPI&feature=youtu.be&t=8m50s) that the context feature was staying, with some cool examples of how contexts have been used in the past.

## React.withContext

`React.withContext` will execute a callback with a specified context dictionary.  Any rendered React element inside this callback has access to values from the context.

```js
var A = React.createClass({

    contextTypes: {
        name: React.PropTypes.string.isRequired,
    },

    render: function() {
        return <div>My name is: {this.context.name}</div>;
    }
});

React.withContext({'name': 'Jonas'}, function () {
    // Outputs: "My name is: Jonas"
    React.render(<A />, document.body);
});
```

Any element that wants to access a variable in the context must explicitly a `contextTypes` property.  If this is not declared, it will not be defined in the elements `this.context` variable (and you will likely have errors!).

If you specify a context for an element and that element renders its own children, those children also have access to the context (whether or not their parents specified a `contextTypes` property).

```js
var A = React.createClass({

    render: function() {
         return <B />;
    }
});

var B = React.createClass({

    contextTypes: {
        name: React.PropTypes.string
    },

    render: function() {
        return <div>My name is: {this.context.name}</div>;
    }
});

React.withContext({'name': 'Jonas'}, function () {
   React.render(<A />, document.body);
});
```

To reduce boilerplate, it is possible to mix in the `contextTypes` property to an element using the `mixins` property on an element.

```js
var ContextMixin = {
    contextTypes: {
        name: React.PropTypes.string.isRequired
    },

    getName: function() {
        return this.context.name;
    }
};

var A = React.createClass({

    mixins: [ContextMixin],

    render: function() {
         return <div>My name is {this.getName()}</div>;
    }
});

React.withContext({'name': 'Jonas'}, function () {
    // Outputs: "My name is: Jonas"
    React.render(<A />, document.body);
});
```

If you rely on a context element it is probably best to ensure that its `contextTypes` property is set as required.  That way if you forget to specify a context React will give a warning back:

```js
var A = React.createClass({

    contextTypes: {
        name: React.PropTypes.string.isRequired
    },

    render: function() {
         return <div>My name is {this.context.name}</div>;
    }
});

// Warning: Required context `name` was not specified in `A`.
React.render(<A />, document.body);
```

## getChildContext, childContextTypes, and context

Child contexts allow an element to specify a context that applies to all of its children and grandchildren.  This is done through the `childContextTypes` and `getChildContext` properties.

```js
var A = React.createClass({

    childContextTypes: {
         name: React.PropTypes.string.isRequired
    },

    getChildContext: function() {
         return { name: "Jonas" };
    },

    render: function() {
         return <B />;
    }
});

var B = React.createClass({

    contextTypes: {
        name: React.PropTypes.string.isRequired
    },

    render: function() {
        return <div>My name is: {this.context.name}</div>;
    }
});

// Outputs: "My name is: Jonas"
React.render(<A />, document.body);
```

Similarly to how elements must whitelist the context elements they have access to through `contextTypes`, elements that specify a `getChildContext` property must specify the context elements that are passed down.  Otherwise your code will error!

```js
// This code *does NOT work* becasue of a missing property from childContextTypes
var A = React.createClass({

    childContextTypes: {
         // fruit is not specified, and so it will not be sent to the children of A
         name: React.PropTypes.string.isRequired
    },

    getChildContext: function() {
         return {
             name: "Jonas",
             fruit: "Banana"
         };
    },

    render: function() {
         return <B />;
    }
});

var B = React.createClass({

    contextTypes: {
        fruit: React.PropTypes.string.isRequired
    },

    render: function() {
        return <div>My favorite fruit is: {this.context.fruit}</div>;
    }
});


// Errors: Invariant Violation: A.getChildContext(): key "fruit" is not defined in childContextTypes.
React.render(<A />, document.body);
```

Suppose you have multiple contexts at play in your application.  Elements added to the context through `withContext` and `getChildContext` are both accessible to child elements.  child elements still need to subscribe to the context elements that they want through `contextTypes`.

```js
var A = React.createClass({

    childContextTypes: {
         fruit: React.PropTypes.string.isRequired
    },

    getChildContext: function() {
         return { fruit: "Banana" };
    },

    render: function() {
         return <B />;
    }
});

var B = React.createClass({

    contextTypes: {
        name: React.PropTypes.string.isRequired,
        fruit: React.PropTypes.string.isRequired
    },

    render: function() {
        return <div>My name is: {this.context.name} and my favorite fruit is: {this.context.fruit}</div>;
    }
});

React.withContext({'name': 'Jonas'}, function () {
    // Outputs: "My name is: Jonas and my favorite fruit is: Banana"
    React.render(<A />, document.body);
});
```

Finally, the context that is applied is the closest one to the element.  If you specify a key in the context through `withContext` and then specify an overlapping key through `getChildContext`, the overlapping key wins.

```js
var A = React.createClass({

    childContextTypes: {
         name: React.PropTypes.string.isRequired
    },

    getChildContext: function() {
         return { name: "Sally" };
    },

    render: function() {
         return <B />;
    }
});

var B = React.createClass({

    contextTypes: {
        name: React.PropTypes.string.isRequired
    },

    render: function() {
        return <div>My name is: {this.context.name}</div>;
    }
});

React.withContext({'name': 'Jonas'}, function () {
    // Outputs: "My name is: Sally"
    React.render(<A />, document.body);
});
```

## Caveats

I ran these examples through jsfiddle with React 0.12.  I've played a bit with similar functionality in React 0.10 and it looks like this has roughly the same behavior.  I found the React test suite really helpful in understanding the intended behavior of the context feature: specifically, the [`withContext` tests](https://github.com/facebook/react/blob/0.12-stable/src/core/__tests__/ReactCompositeComponent-test.js#L1101) and the [`getChildContext` tests](https://github.com/facebook/react/blob/0.12-stable/src/core/__tests__/ReactElement-test.js#L100) really helped me understand how contexts were intended to work.

Finally, as contexts are an *undocumented* feature of React.js, _caveat emptor_ - everything I've written here may change completely in an upcoming release and just because you *can* use them today doesn't mean that you necessarily *should*.  Hope you've found this helpful!