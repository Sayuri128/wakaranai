# In built modules

## IO

Currently it allows only printing to the console, but in the future it will allow reading and
writing to files.

```capyscript

import "io";

function main() {
    print("Hello World!"); // prints "Hello World!"
}

```
---

### Converter

The converter module is used to convert a string to different formats

```capyscript
import "converter";

function main() {
    print(parseInt("123")); // prints 123
    print(parseDouble("123.45")); // prints 123.45
    print(parseString(123)); // prints "123"
}
```

**(capyscript 0.4+)** Encoders:

```capyscript
import "converter";

function main() {
    print(base64Encode("hello")); // aGVsbG8=
    print(base64Decode("aGVsbG8")); // hello (padding optional)
    print(urlEncode("a b&c")); // a%20b%26c
    print(urlDecode("a%20b%26c")); // a b&c
}
```

---

## Regex

**(capyscript 0.4+)** Regular expressions use Dart/JavaScript syntax. Every function takes an
optional last `flags` argument: `i` (ignore case), `m` (multi-line), `s` (`.` matches newlines).

```capyscript
import "regex";

function main() {
    print(regexTest("chapter \d+", "Chapter 12", "i")); // true
    print(regexMatch("vol\.(\d+) ch\.(\d+)", "vol.3 ch.27")); // [vol.3 ch.27, 3, 27]
    print(regexMatchAll("id=(\d+)", "id=1&id=22")); // [[id=1, 1], [id=22, 22]]
    print(regexSplit("\s*,\s*", "a , b,c")); // [a, b, c]
    print(regexReplace("(\w+)@(\w+)", "a@b", "$2 at $1")); // b at a
}
```

`regexMatch` returns `null` when nothing matches. In `regexReplace`, `$1` inserts a group and `$$`
a literal dollar. Backtick strings are handy for patterns with quotes: `` `"id":\s*(\d+)` ``.

--- 

## Date

The date module is used to parse and format dates. 

```capyscript

import "date";

function main() {
    formatter = createDateFormatter("yyyy-MM-dd HH:mm");
    date = parseDate("2019-01-01 00:00:00"); // Creates a date object from a string
    print(formatter.format(date)); // prints "2019-01-01 00:00"
}

```

---

## HTML

The HTML module is used to parse HTML strings.

```capyscript

import "html";

function main() {
    html = createHTMLParser("<html><body><h1>Hello World!</h1></body></html>");
    print(html.querySelector("h1").text()); // prints "Hello World!"
}

```

`createHTMLParser` returns a `HTMLDocument` object.

Available methods for `HTMLDocument`:

`HTMLDocument` methods:

* `getElementById(str)` returns `HtmlElement`
* `getElementsByClassName(str)` returns `HTMLElement[]`
* `getElementsByTagName(str)` returns `HTMLElement[]`
* `querySelectorAll(str)` returns `HTMLElement[]`
* `querySelector(str)` returns `HTMLElement`

`HTMLDocument` fields:

* `outerHtml` returns `String`
* `text` returns `String`

---- 
`HTMLElement` methods:

* `getElementsByClassName` returns `HTMLElement[]`
* `getElementsByTagName` returns `HTMLElement[]`

`HTMLElement` fields:

* `text` returns `String`
* `outerHtml` returns `String`
* `id` returns `String`
* `classes` returns `String[]`
* `children` returns `HTMLElement[]`
* `attributes` returns `Map<String, String>`

---

## HTTP

The HTTP module is used to make HTTP requests.

```capyscript

import "http";

function main() {
    response = httpGet("https://example.com");
    print(response.body); // prints the response body
}

```

---

`httpGet` has the following signature:

```capyscript

function httpGet(url, params, paths, headers, throughWeb) {
    // ...
}

```

* `url` is the URL to make the request to
* `params` is a map of query parameters
* `paths` is a map of path parameters
* `headers` is a map of headers
* `throughWeb` is a boolean that specifies whether to use the webview to make the request or not

only `url` is required, the rest are optional.

Query values in `params` are URL-encoded for you (from capyscript 0.4; older versions sent them
raw), while `paths` substitutions are inserted verbatim. Requests that don't go through the webview
time out after 60 seconds.

To make it easier to use, you can also use maps as function arguments:

```capyscript

function main() {
    response = httpGet({
        "url": "https://example.com",
        "params": {
            "foo": "bar"
        },
        "headers": {
            "User-Agent": "Capyscript"
        },
        "throughWeb": false
    });
    print(response.body); // prints the response body
}

``` 

---

`httpPost` has the same signature as `httpGet`, but it also takes a `body` argument.

``` capyscript

function httpPost(url, params, paths, headers, body, throughWeb) {
    // ...
}

```

```capyscript

function main() {
    response = httpPost({
        "url": "https://example.com",
        "params": {
            "foo": "bar"
        },
        "headers": {
            "User-Agent": "Capyscript"
        },
        "body": "Hello World!",
        "throughWeb": false
    });
    print(response.body); // prints the response body
}

```

Other method in the HTTP module:

* `registerInterceptorController` - registers the interceptor controller, which is basically
  required to start using the WebView for requests. It will later be used to add more functionality
  to the WebView.

* `executeJsScript` - executes a JavaScript script in the webview. This is useful for interacting
  with the webview.

```capyscript
executeJsScript({"code": "return window.__pg"});
```

* `useHeaders` - sets the headers to use for all requests

```capyscript
useHeaders({"headers": {
    "User-Agent": "Capyscript"
  }});
```

* `currentMirror` (api 2) - returns the mirror base URL the next request will try first (the one
  the user picked, else the last one that answered, else the first declared), or `null` when the
  extension declares no `requestPolicy.mirrors`. Useful for building absolute URLs the app loads
  itself, such as image links:

```capyscript
apiBase = currentMirror();
if (apiBase == null) {
    apiBase = "https://api.cdnlibs.org";
}
```

Every `httpGet` and `httpPost` goes through the extension's
[request policy](extensions.md#request-policy): its rate limit, its default headers (overridden by
`useHeaders`, which are overridden by the call's own `headers`) and its mirror rewriting and
failover.

---

### Response bytes and charsets

**(api 3)** Every `httpGet`/`httpPost` response also has `bodyBytes`: the raw body as a list of
byte values (null for requests made through the in-app browser). Use it with the
[Bytes](#bytes) module for binary files:

```capyscript
import "http";
import "bytes";

function galleryIds(indexUrl) {
    response = httpGet({"url": indexUrl});
    return bytesToInts(response["bodyBytes"], 4);
}
```

`body` is decoded with the charset the server declares. From api 3 on, `windows-1251`, `koi8-r`
and `koi8-u` are decoded properly (older interpreters turned them into latin1), and when the
server declares no charset and the body is not UTF-8, a `<meta charset>` in the page is honoured.

## JSON

The JSON module is used to encode and decode JSON strings.

```capyscript

import "json";

function main() {
    json = jsonDecode(`{"foo": "bar"}`);
    print(json["foo"]); // prints "bar"
    print(jsonEncode(json)); // prints `{"foo": "bar"}`
}

```

---

## Preferences

**(api 2)** Reads the extension's [preferences](extensions.md#preferences) declared in
`config.json`.

```capyscript
import "preferences";

function chapterLanguages() {
    languages = getPreference("chapterLanguages");
    if (languages == null) {
        return ["en"];
    }
    return languages;
}
```

`getPreference(key)` returns the value the user set, else the declared `default`, else the type's
fallback (`false`, the first option, `[]`, `""` or `0`). It returns `null` for a key the config
doesn't declare, and for every key when the script runs outside the app (for example in tests that
build the client without an extension host), so keep a fallback in the script as above. Values
are a bool for `toggle`, a string for `select` and `text`, a number for `number`, and a list of
strings for `multiselect`.

Keys starting with `__` belong to the app. Read the active mirror with `currentMirror()` and the
gallery page size from the `pageSize` argument of
[`getGallery`](extensions.md#page-size), not with `getPreference`.

---

## Storage

**(api 2)** A small key-value store private to the extension.

```capyscript
import "storage";

function apiToken() {
    token = storageGet("token");
    if (token != null) {
        return token;
    }
    token = fetchToken();
    storageSet("token", token, 3600);
    return token;
}
```

* `storageGet(key)` returns the stored value, or `null` when the key is missing or expired.
* `storageSet(key, value, ttlSeconds)` stores `value`. It must be JSON: `null`, a bool, a
  number, a string, or lists and maps (with string keys) of those; anything else is a script error.
  `ttlSeconds` is optional: a positive number lets the value expire after that many seconds, `null`
  keeps it until it is removed. Zero or negative values are a script error.
* `storageRemove(key)` deletes the value.

Values survive app restarts. Each extension sees only its own keys, nothing is included in the
app's export, and everything is deleted when the extension is removed. Don't use it for large
data such as whole chapter lists; it is meant for tokens, ids and small caches.

---

## Errors

**(api 2)** Fails with a typed error the app can act on; see
[Errors the app understands](extensions.md#errors-the-app-understands) for what the app does with
each kind.

```capyscript
import "errors";

function decodeApiResponse(apiResponse, requestLabel) {
    apiStatusCode = apiResponse["statusCode"];
    if (apiStatusCode >= 200 && apiStatusCode < 300) {
        return jsonDecode(apiResponse["body"]);
    }
    if (apiStatusCode == 404) {
        throwSourceError("notFound", "MangaDex has no such entry (" + requestLabel + ")");
    }
    if (apiStatusCode == 429) {
        throwSourceError("rateLimited", "MangaDex is rate limiting requests (" + requestLabel + ")");
    }
    if (apiStatusCode >= 500) {
        throwSourceError("sourceDown", "MangaDex answered HTTP " + parseString(apiStatusCode));
    }
    throw "HTTP " + parseString(apiStatusCode) + " (" + requestLabel + ")";
}
```

`throwSourceError(kind, message)` takes one of `"loginRequired"`, `"rateLimited"`, `"notFound"`,
`"regionBlocked"`, `"sourceDown"` or `"unsupported"`; any other kind is an ordinary script error.
`message` is optional; keep it short and specific, since the app may show it next to its own
explanation.

The error travels through every script function up to the app. A script `try`/`catch` catches it
like any other error, but the catch variable only receives the message (or the kind name if the
message is empty), and the kind is dropped unless the `catch` block calls `throwSourceError`
again:

```capyscript
try {
    rating = getRating(uid);
} catch (e) {
    rating = null;
}
```

swallows a `rateLimited` from `getRating`, which is fine for optional data but not for the main
request.

Don't write `try { … } finally { … }` without a `catch`: the interpreter swallows the error in that
form. Use `try { … } catch (e) { …; throw e; } finally { … }`, or rethrow with `throwSourceError`
to keep the kind.

## Dependencies

**(api 3)** Shares objects between script functions for as long as the app keeps the extension
client: API clients, class instances, lookup maps. Register them in the optional `onInit()`
hook (see [Lifecycle](extensions.md#lifecycle)) and fetch them anywhere with `inject`.

```capyscript
import "dependencies";
import "graphql";

class Catalog {
    base: string;
    function constructor(base: string) {
        this.base = base;
    }
    function titleUrl(slug: string): string {
        return this.base + "/title/" + slug;
    }
}

function onInit() {
    provide("catalog", new Catalog("https://example.com"));
    provide("api", createGraphQLClient({"url": "https://example.com/graphql"}));
    provideLazy("genres", function() {
        return inject("api").query("{ genres { id name } }")["genres"];
    });
}

function getConcrete(uid, data) {
    catalog = inject("catalog");
    titleUrl = catalog.titleUrl(uid);
}
```

* `provide(name, value)` registers any value and replaces an earlier entry with the same name.
* `provideLazy(name, factory)` registers a function that builds the value on the first
  `inject(name)`. The result is cached; concurrent first calls share one build, and a factory
  that throws is tried again on the next `inject`.
* `inject(name)` returns the value, or fails naming what is registered.
* `isProvided(name)` and `forget(name)` check and remove entries.

Values live in memory only: they are gone after an app restart and are rebuilt (by running
`onInit` again) when the user changes the extension's settings or clears its stored data. Use
[Storage](#storage) for anything that has to survive restarts.

A statement can't start with a call result, so assign first:
`api = inject("api"); api.setHeader("Authorization", token);`.

---

## Bytes

**(api 3)** Binary data as lists of byte values (0-255).

| Function | Result |
|---|---|
| `base64DecodeBytes(text)` | Bytes of base64 or base64url text (padding optional). |
| `base64EncodeBytes(bytes)` | Base64 text. |
| `hexToBytes(text)`, `bytesToHex(bytes)` | Convert between hex strings and bytes. |
| `stringToBytes(text, encoding = "utf-8")` | Encoded text. |
| `bytesToString(bytes, encoding = "utf-8")` | Decoded text. |
| `charCodes(text)`, `fromCharCodes(codes)` | UTF-16 code units, like JavaScript `charCodeAt` / `String.fromCharCode`. |
| `xorBytes(bytes, key)` | Every byte XOR-ed with the key (bytes or a UTF-8 string), repeating the key. |
| `bytesToInts(bytes, size = 4, bigEndian = true, signed = false)` | Consecutive `size`-byte integers. |
| `bitAnd`, `bitOr`, `bitXor`, `shiftLeft`, `shiftRight`, `shiftRightUnsigned`, `bitNot` | Integer bit operations. |
| `toInt32(value)`, `toUint32(value)` | Wrap to 32 bits, like JavaScript `x \| 0` and `x >>> 0`. |

Encodings: `utf-8`, `latin1`, `ascii`, `windows-1251`, `koi8-r`, `koi8-u` (common aliases such as
`cp1251` work too).

---

## Hash

**(api 3)** `md5(input)`, `sha1(input)`, `sha256(input)`, `sha512(input)` and
`hmac(algorithm, key, message)`. Inputs are strings (hashed as UTF-8) or byte lists. The last
optional argument picks the output: `"hex"` (default), `"base64"` or `"bytes"`.

```capyscript
import "hash";

function signedPath(path, secret) {
    return path + "?sig=" + hmac("sha256", secret, path);
}
```

---

## GraphQL

**(api 3)** A GraphQL client that sends its requests through the HTTP module, so the extension's
request policy (rate limit, headers, mirrors) and `useHeaders` apply. It does not go through the
in-app browser.

```capyscript
import "graphql";
import "dependencies";

function onInit() {
    provide("api", createGraphQLClient({
        "url": "https://example.com/graphql",
        "headers": {"Referer": "https://example.com/"}
    }));
}

function getGallery(page, query, filters) {
    data = inject("api").query(
        "query List($page: Int, $search: String) { list(page: $page, search: $search) { id title cover } }",
        {"page": page, "search": query},
        "List"
    );
    return data["list"].map(function(item) {
        return buildGallery({"uid": item["id"], "title": item["title"], "cover": item["cover"], "data": {}});
    });
}
```

`createGraphQLClient(url, headers = {}, method = "POST")` returns a client with:

* `query(query, variables = null, operationName = null)`: the `data` object; fails with the
  server's messages when the response has `errors`.
* `request(query, variables, operationName)`: `{statusCode, data, errors, extensions, headers}`
  without failing on GraphQL errors, for partial results.
* `persisted(sha256Hash, variables, operationName, query = null)`: an Apollo persisted query.
  Pass `null` as the hash to compute it from `query`; when the server does not know the hash and
  `query` is given, the request is repeated once with the query text.
* `setHeader(name, value)`: sets a header for later requests, or removes it when `value` is null.

`method: "GET"` sends `query`, `variables`, `operationName` and `extensions` as URL parameters.
HTTP 429 becomes a `rateLimited` source error. `hashGraphQLQuery(query)` returns the sha256 hex
used by persisted queries.

---

## Waka Models

The Waka Models module is used to create Waka Models.
It is used to create the models for the manga and anime views.

anime, manga, novel and audio models are in different modules, and you can't use the manga models in the anime and vice versa.

---

## Manga Models

### `buildGallery`

```capyscript

import "manga_models";

function main() {
    galleryView = buildGallery({
      uid: "",
      title: "",
      cover: "",
      data: ""
    });
}

```

Parameters:

* `uid` is the unique id of the manga. This will be used to identify the specific manga
  in the app.
* `title` is the title of the manga.
* `cover` is the cover of the manga (image URL).
* `data` is the data of the manga. This is a JSON string that contains all the data of the manga.
  This is used only within the scope of the extension, and is not used by the app itself, so can put any metadata you want in it.

Optional details, shown in the gallery's list layout (older app builds ignore them, so they are safe
to pass; leave out anything the listing page doesn't already give you rather than making extra
requests per title):

* `status` — one of the status builders listed under `buildConcrete` (manga only; anime
  `buildGallery` already takes a required `status`).
* `subtitle` — an alternative or original title, shown under the title.
* `tags` — genres or tags; the first three are shown.
* `year` — release year, a number or a numeric string.
* `rating` — 0–10, a number or a numeric string (`"8,7"` works); values outside are clamped.
* `latestChapter` — the newest chapter or episode, shown verbatim, so include the prefix
  (`"Ch. 120"`, `"Ep. 12"`).

---

### `buildConcrete`

```capyscript

import "manga_models";



function main() {
    concreteView = buildConcrete({
      "uid": "",
      "cover": "",
      "title": "",
      "description": "",
      "tags": [],
      "groups": [],
      "status": statusAnnounce(),
      "alternativeTitles": [],
      "authors": ["Author"],
      "artists": ["Artist"],
      "year": 2019,
      "rating": 8.7,
      "url": "https://example.com/title",
    });
}

```

Parameters:

* `uid` is the unique id of the manga. This will be used to identify the specific manga
  in the app.
* `title` is the title of the manga.
* `cover` is the cover of the manga (image URL).
* `description` is the description of the manga.
* `tags` is a list of tags for the manga.
* `groups` is a list of grouped chapters by language/translators etc.
* `status` is the status of the manga. It can be one of the following:
    * `statusAnnounce` - Announced
    * `statusCanceled` - Cancelled
    * `statusOngoing` - Ongoing
    * `statusPaused` - Paused
    * `statusReleased` - Released
    * `statusUndefined` - Undefined

Optional details, shown under the title in the app (capyscript 0.4+; older app builds ignore them, so
they are safe to pass):

* `authors` / `artists` — lists of names; artists that are also authors are shown once.
* `year` — release year, a number or a numeric string.
* `rating` — 0–10, a number or a numeric string (`"8,7"` works); values outside are clamped.
* `url` — the title's page on the site, opened by the "Open website" link.

The same optional details work in the anime `buildConcrete`.

---

### To create groups, you can use the `buildChapterGroups` function.

```capyscript

import "manga_models";

function main() {
    groups = buildChapterGroups({
      "title": "",
      "elements": [],
    });
}

```

Parameters:

* `title` is the title of the group.
* `elements` is a list of chapters in the group.

---

### To create chapters, you can use the `buildChapter` function.

```capyscript

import "manga_models";
import "date";

function main() {
    chapter = buildChapter({
        "uid": "",
        "title": "",
        "timestamp": parseDate("2019-01-01 00:00:00"),
        "data": {},
        "number": 12.5,
        "volume": 2,
    });
}

```

Parameters:

* `uid` is the unique id of the chapter. This will be used to identify the specific manga
  in the app.
* `title` is the title of the chapter.
* `timestamp` is the timestamp of the chapter. - nullable
* `data` is a map of metadata for the chapter.
* `number` is the chapter number. - optional. An int, a decimal (`12.5`) or a numeric string
  (`"12,5"` works). Negative or unparsable values become `null`.
* `volume` is the volume number. - optional. A whole number or a numeric string; anything else
  becomes `null`.

Older app versions ignore `number` and `volume`, so passing them is always safe.

---

`buildPages`

```capyscript

import "manga_models";

function main() {
    pages = buildPages({
      "uid": "",
      "value": [],
    });
}

```

Parameters:

* `uid` is the unique id of the chapter. This will be used to identify the specific manga
  in the app.
* `value` is a list of pages (image URLs) for the chapter.

---

## Novel Models

`novel_models` is the module for novel extensions (`"type": 2`). It offers the same
`buildGallery`, `buildConcrete`, `buildChapter`, `buildChapterGroups` and status constants
(`statusAnnounce`, `statusCanceled`, `statusOngoing`, `statusPaused`, `statusReleased`,
`statusUndefined`) as [`manga_models`](#manga-models), with the same arguments, plus
`buildNovelChapter` for the chapter text.

### `buildNovelChapter`

```capyscript

import "novel_models";

function getChapterText(uid, data) {
    return buildNovelChapter({
      html: "<p>It was a dark and stormy night.</p>",
      title: "Chapter 1"
    });
}

```

* `html` - the chapter body: HTML (`<p>`, `<br>`, `<em>`, `<strong>`, headings, lists, images)
  or plain text.
* `title` (optional) - the chapter title; the app shows the title from `buildChapter` when it is
  left out.

The result exposes `html` and `title` fields. `getChapterText` may also return a plain string,
which the app treats as `html`.

---

## Audio Models

`audio_models` is the module for audio extensions (`"type": 3`). It offers the same
`buildGallery`, `buildConcrete`, `buildChapter`, `buildChapterGroups` and status constants
(`statusAnnounce`, `statusCanceled`, `statusOngoing`, `statusPaused`, `statusReleased`,
`statusUndefined`) as [`manga_models`](#manga-models), with the same arguments (chapters are the
tracks of the book), plus `buildAudioSource` and `buildAudioMarker` for `getAudioSources`.

### `buildAudioSource`

```capyscript

import "audio_models";

function getAudioSources(uid, data) {
    return [
        buildAudioSource({
          url: "https://example.org/book/part01.m4b",
          format: "m4b",
          quality: "128 kbps",
          headers: {"Referer": "https://example.org/"},
          duration: 3725.5,
          markers: [
            buildAudioMarker({start: 0, title: "Chapter 1"}),
            buildAudioMarker({start: 1810, title: "Chapter 2"})
          ]
        })
    ];
}

```

* `url` - the audio file or HLS playlist; required, surrounding spaces are trimmed.
* `format` (optional) - `mp3`, `m4a`, `m4b` or `hls` (lowercased).
* `quality` (optional) - a label for the quality picker.
* `headers` (optional) - a map of request headers.
* `duration` (optional) - seconds (number or numeric string); non-positive values are dropped.
* `markers` (optional) - a list of markers or `{start, title}` maps; invalid entries are dropped
  and the rest are sorted by `start`.

The result exposes `url`, `format`, `quality`, `headers`, `duration` and `markers` fields.

### `buildAudioMarker`

* `start` - seconds from the beginning of the file; a negative or non-numeric value is an error.
* `title` (optional) - the marker title; the player numbers untitled markers.

---

## Anime Models

### `buildGallery`

```capyscript

import "anime_models";

function main() {
    galleryView = buildGallery({
      uid: "",
      title: "",
      cover: "",
      data: ""
    });
}

```

Parameters:

* `uid` is the unique id of the anime. This will be used to identify the specific anime
  in the app.
* `title` is the title of the anime.
* `cover` is the cover of the anime (image URL).
* `data` is the data of the anime. This is a JSON string that contains all the data of the anime.
  This is used only within the scope of the extension, and is not used by the app itself, so can put any metadata you want in it.
* `status` is the status of the anime, built with the anime status builders.

The optional `subtitle`, `tags`, `year`, `rating` and `latestChapter` described under the manga
`buildGallery` work here too.

---

### `buildConcrete`

```capyscript

import "anime_models";

function main() {
    concreteView = buildConcrete({
      "uid": "",
      "cover": "",
      "title": "",
      "description": "",
      "tags": [],
      "groups": [],
      "alternativeTitles": [],
      "status", statusAnnounce(),
    });
}

```

Parameters:

* `uid` is the unique id of the anime. This will be used to identify the specific anime
  in the app.
* `title` is the title of the anime.
* `cover` is the cover of the anime (image URL).
* `description` is the description of the anime.
* `tags` is a list of tags for the anime.
* `groups` is a list of grouped episodes by language/translators etc.
* `status` is the status of the anime. It can be one of the following:
    * `statusAnnounce` - Announced
    * `statusCanceled` - Cancelled
    * `statusOngoing` - Ongoing
    * `statusPaused` - Paused
    * `statusReleased` - Released
    * `statusUndefined` - Undefined
* `alternativeTitles` is a list of alternative titles for the anime.

---

### To create groups, you can use the `buildAnimeVideoGroup` function.

```capyscript

import "anime_models";

function main() {
    groups = buildAnimeVideoGroup({
      "title": "",
      "videos": [],
    });
}

```

Parameters:

* `title` is the title of the group.
* `videos` is a list of videos in the group.

---

### To create videos, you can use the `buildAnimeVideo` function.

```capyscript
import "anime_models";
import "date";

function main() {
    video = buildAnimeVideo({
        "uid": "",
        "title": "",
        "timestamp": parseDate("2019-01-01 00:00:00"),
        "type": typeIframe(),
        "src": "",
        "data": {},
        "number": 3,
        "season": 1,
    });
}

```

Parameters:

* `uid` is the unique id of the video. This will be used to identify the specific episode
  in the app. Watch history, resume progress, library update checks and downloads are all keyed by
  it, so it must stay the same between runs (the embed URL is a good choice; a signed or
  per-session URL is not).
* `title` is the title of the video.
* `timestamp` is the timestamp of the video. - nullable
* `type` is the type of the video. It can be one of the following:
    * `typeIframe()` - an embed page. Rendered in a webview unless the extension resolves it to
      a playable stream with [`getVideoSources`](extensions.md#getvideosources).
    * `typeDirect()` - `src` is itself a playable stream (HLS, MP4...). The native player plays it
      directly when the extension has no `getVideoSources` or that function returns nothing.
* `src` is the source of the video: the embed page URL for `typeIframe()`, the stream URL for
  `typeDirect()`. It is passed to `getVideoSources` as `src`.
* `data` is a map of metadata for the video. It is passed to `getVideoSources` as `data`.
* `number` is the episode number. - optional. An int, a decimal (`12.5`) or a numeric string.
  The player uses it (with `season`) to find the previous/next episode and to keep the same
  episode when switching dubs/players. Without it the app tries to read a number from the title.
* `season` is the season number. - optional. A whole number or a numeric string.

Older app versions ignore `number` and `season`.

---

### To describe a playable stream, use the `buildAnimeVideoSource` function.

Used only as the return value of `getVideoSources`.

```capyscript
import "anime_models";

function main() {
    source = buildAnimeVideoSource({
        "url": "https://cdn.example.com/ep3/master.m3u8",
        "quality": "1080p",
        "format": "hls",
        "headers": {"Referer": "https://player.example.com/"},
        "subtitles": [
            buildAnimeVideoSubtitle({
                "url": "https://cdn.example.com/ep3/en.vtt",
                "label": "English",
                "language": "en",
                "format": "vtt",
            }),
        ],
    });
}
```

Parameters:

* `url` is the stream URL. - required
* `quality` is a label shown in the quality picker, e.g. `"1080p"`, `"720p"`, `"Auto"`. - optional.
  Labels with a height (`"720p"`) let the app pick the closest quality to the one the user chose
  last time.
* `format` is `"hls"`, `"mp4"` or `"dash"`. - optional. `null` lets the app guess from the URL
  (and, for downloads, from the response).
* `headers` is a map of HTTP headers sent with every request for this stream: the playlist,
  every segment and every key. Put `Referer`, `Origin`, `User-Agent` or CDN specific headers
  here. - optional
* `subtitles` is a list of `buildAnimeVideoSubtitle` results. - optional
* `skip` is a list of `{"type", "start", "end"}` maps marking parts the player offers to skip. -
  optional. `type` is `"intro"`, `"outro"` or `"recap"`; `start` and `end` are seconds from the
  start of the video (numbers or numeric strings). Entries with another type, missing times or
  `end` not after `start` are dropped.
* `audioLabel` is the dub or voice-over of this source, e.g. `"FanVoxUA"`; the player shows it in
  the source picker. - optional
* `preferForDownload` is `true` for a source the downloader should pick over the others, for
  example an H.264 or single-file variant of the same episode. - optional, defaults to `false`

Older app builds ignore `skip`, `audioLabel` and `preferForDownload`.

What Anitube.in.ua returns for the first Black Clover episode on FenixPlay, whose playback API
reports `"intro_start": null, "ending_start": 1340, "ending_end": 1416`:

```capyscript
buildAnimeVideoSource({
    "url": "https://media.fenixplay.xyz/anime/chorna-konyushyna/ep001/…/master.m3u8?token=…",
    "quality": "Auto",
    "format": "hls",
    "headers": {"Referer": "https://fenixplay.xyz/"},
    "skip": [{"type": "outro", "start": 1340, "end": 1416}],
    "audioLabel": "FanVoxUA"
});
```

A plain map with the same keys is accepted instead of `buildAnimeVideoSource`.

---

### To describe a subtitle track, use the `buildAnimeVideoSubtitle` function.

Parameters:

* `url` is the subtitle file URL. - required
* `label` is the name shown in the subtitle picker. - optional
* `language` is a language code like `"en"` or `"uk"`; the app uses it to remember the user's
  choice across episodes. - optional
* `format` is `"vtt"` or `"srt"`. - optional; `null` detects it from the URL or the file content.
* `headers` is a map of HTTP headers for the subtitle request. - optional

A plain map with the same keys is accepted too.

---
