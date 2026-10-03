# Capyscript syntax

Capyscript is a small, dynamically typed, C-like language. A script is a list of `import`s,
`function`s and (optionally) `class`es / `interface`s — nothing else is allowed at the top level.

> **Interpreter versions.** Users update the app and extensions independently, so an extension may
> run on an older interpreter than the one you test with. Features marked **(0.4+)** need
> capyscript 0.4.0, which ships in app builds newer than 0.3.0. Until you're happy to drop older
> app builds, stick to the unmarked subset. See [Compatibility](#compatibility).

### Functions

```capyscript
function add(a, b) {
    return a + b;
}

function greet(name: string, greeting = "Hello"): string {
    return greeting + ", " + name;
}

function main() {
    return add(1, 2); // 3
}
```

Parameters may have types (`int`, `float`, `double`, `string`, `bool`, `any`, `dynamic`, `List`,
`Map`, or a class name) and default values. Types are checked at runtime.

Calling a function with a map literal as the first argument binds its keys to parameter names,
which is how most builtins are called:

```capyscript
response = httpGet({"url": "https://example.com", "throughWeb": true});
```

### Variables and scope

```capyscript
title = "Hello";
var count: int = 3;
```

Variables are **function-scoped**: `if`, `for` and `while` blocks don't create a new scope, so a
variable assigned inside a block is visible after it. A function only sees its own parameters and
variables — never the variables of the function that called it. There are no top-level variables.

### Lambdas

```capyscript
doubled = [1, 2, 3].map(function(x) { return x * 2; });
```

Lambdas capture the variables around them. **(0.4+)** Assigning to a captured variable updates it:

```capyscript
total = 0;
items.forEach(function(item) { total += item.price; });
```

Older interpreters create a lambda-local copy instead; use `reduce` / `fold` or `push` to stay
compatible.

### Operators

`+ - * / %`, comparisons `== != < > <= >=`, `&&` and `||` (short-circuit), `++` / `--` as
statements. `+` concatenates when either side is a string.

**(0.4+)** `!value`, and `+= -= *= /=`. `!`, `&&` and `||` treat `false`, `0` and `null` as false.

### Strings

Double- and single-quoted strings, plus backtick strings for multi-line text such as embedded
JavaScript. **(0.4+)** `"…"` and `'…'` understand `\n \t \r \\ \" \'`; other backslashes are kept as
is, so regex patterns like `"\d+"` work. Backtick strings are always raw.

```capyscript
description = "Pages: " + pages + "\n";
js = `return document.title;`;
```

String methods: `length`, `isEmpty`, `isNotEmpty`, `contains`, `split`, `substring`, `trim`,
`trimLeft`, `trimRight`, `toLowerCase`, `toUpperCase`, `replaceAll`, `replaceFirst`, `startsWith`,
`endsWith`, `indexOf`, `padLeft`, `padRight`.

### Lists and maps

```capyscript
list = [1, 2, 3];
nested = [[0], [1]];
map = {"foo": "bar", "count": 2};

first = list[0];
map["foo"] = "baz";
name = map.foo;
```

List methods: `push` / `add`, `pop`, `insert`, `remove`, `removeAt`, `elementAt`, `indexOf`,
`contains`, `join`, `sublist`, `reversed`, `sort`, `clear`, `map`, `filter` / `where`, `forEach`,
`any`, `every`, `reduce`, `fold`; properties `length`, `first`, `last`, `isEmpty`, `isNotEmpty`.
Map methods: `containsKey`, `containsValue`, `remove`, `clear`, `addAll`; properties `keys`,
`values`.

**(0.4+)** Statements may start with an index: `groups[0].elements.push(chapter);`.

### Control flow

```capyscript
if (status == null) {
    status = "unknown";
} else {
    status = status.trim();
}

for (i = 0; i < items.length; i++) {
    if (items[i] == null) {
        continue;
    }
    print(items[i]);
}
```

The `for` increment also runs after `continue` — **never** write `i = i + 1; continue;`, it skips
the next element.

**(0.4+)** `while (condition) { … }`, `for (item in list) { … }` (iterates map keys for maps), and
`for (;;)` with an empty condition. `break` no longer runs the increment.

### Errors

```capyscript
try {
    data = jsonDecode(response.body);
} catch (e) {
    throw "Unexpected response: " + e;
} finally {
    print("done");
}
```

`throw` accepts any value; `catch (e)` receives the thrown value or the error message.

**(0.4+)** Parse errors report `at line L:C`, and runtime errors carry the call stack, e.g.
`Variable x not found. [at parseChapter ← getConcrete]`.

### Classes

```capyscript
interface Named {
    function getName();
}

class Source implements Named {
    name: string;

    function constructor(name) {
        this.name = name;
    }

    function getName() {
        return this.name;
    }
}

function main() {
    return new Source("MangaDex").getName();
}
```

### Not supported

Ternary operator, string interpolation, top-level variables, `return;` without a value, and
statements that start with a literal, `(` or a call followed by a method (`f().trim();` — assign it
first). Before 0.4 also: `!`, `while`, for-in, compound assignment and string escapes.

### Compatibility

Write extensions that behave the same on old and new interpreters:

- Don't increment the loop variable before `continue`.
- Don't assign to outer variables from a lambda.
- Only read variables a function assigned itself or received as parameters.
- In a named-argument call, don't reuse another parameter's name inside an argument expression
  (`{"cover": base + cover, "data": {"cover": cover}}`).
- Avoid the **(0.4+)** syntax and the `regex` module / encoders until older app builds are dropped.
