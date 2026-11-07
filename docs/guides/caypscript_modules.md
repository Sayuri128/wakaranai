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
---

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

## Waka Models

The Waka Models module is used to create Waka Models.
It is used to create the models for the manga and anime views.

anime and manga models are in different modules, and you can't use the manga models in the anime and vice versa.

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
