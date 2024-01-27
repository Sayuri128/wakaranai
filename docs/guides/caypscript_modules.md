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
      "status", statusAnnounce(),
      "alternativeTitles": [],
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
    });
}

```

Parameters:

* `uid` is the unique id of the chapter. This will be used to identify the specific manga
  in the app.
* `title` is the title of the chapter.
* `timestamp` is the timestamp of the chapter. - nullable
* `data` is a map of metadata for the chapter.

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
    });
}

```

Parameters:

* `uid` is the unique id of the video. This will be used to identify the specific anime
  in the app.
* `title` is the title of the video.
* `timestamp` is the timestamp of the video. - nullable
* `type` is the type of the video. It can be one of the following:
    * `typeIframe` - Iframe // Will be rendered in a webview
* `src` is the source of the video. This is the URL of the video.
* `data` is a map of metadata for the video.

---
