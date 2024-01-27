# Capyscript syntax

Capyscript is a language that is very similar to any other C-like language. It has a few differences
though.
There is no classes, only functions, though classes are planned for the future, so it's easier to
structure extensions.

### Functions

There is no return type for functions, and the return type is inferred from the return value.
Functions are defined like this:

```capyscript

function foo(bar) {
    return bar + 1;
}

function main() {
    return foo(1); // returns 2
}

```

### Functions as arguments

Functions can be passed as arguments to other functions. This is useful for callbacks.

```capyscript

function foo(fun) {
    fun();
}

function bar() {
    print("Hello World!");
}

function main() {
    foo(bar); // prints "Hello World!"
}

```

### Variables

In Capyscript, variables are dynamically typed, meaning that you don't have to specify the type of a
variable when you define it.

```capyscript

foo = "Hello";
bar = "World!";
pi = 3.14;

```

### if statements

If statements are defined like this:

```capyscript

var = null;

if(var == null) {
    print("var is null");
} else {
    print("var is not null");
}

```

output:

```
var is null
```

### Arrays

It is possible to define arrays in Capyscript. Nested multidimensional arrays are also supported.

Arrays are defined like this:

```capyscript
arr = [1, 2, 3, 4, 5];
arr2 = [[0], [1], [2]];
```

### for loops

For loops are defined like this:

```capyscript

for (i = 0; i < 10; i++) {
    print(i);
}


function main() {
    arr = [[0], [1], [2]];

    for (i = 0; i < 3; i++) {
        for (j = 0; j < 1; j++) {
            print(arr[i][j]);
        }
    }
}

```

output:

```
0
1
2
```

### Maps

Maps are defined like this:

```capyscript

map = {
    "foo": "bar",
    "bar": "foo"
};

print(map["foo"]); // prints "bar"
print(map["bar"]); // prints "foo"

```
