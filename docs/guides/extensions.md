# Extensions

## Introduction

Extensions are a way to add new sources for manga and anime to the app. Extensions are written in
Capyscript and are loaded dynamically at runtime.
This means that you can add new sources/update existing ones without having to update the app
itself.

First highly recommended step is to read the [Capyscript Syntax](capyscript_syntax.md) guide
and capyscript [in-built modules](caypscript_modules.md).

## Creating manga extension

First of all you need to create a new json file called `config.json` with the following structure

* `uid`: Unique identifier for the script.
* `name`: Name of the source.
* `logoUrl`: URL to the script's logo.
* `type`: Type of script, either `0` for manga or `1` - anime.
* `nsfw`: Indicates whether the script contains NSFW content (true or false).
* `language`: Source language.
* `version`: Version number of the script.
* `filters`: List of filters the source supports — see [Filters](#filters). Use `[]` if there are
  none.
* `protectorConfig`: Configuration for the protector. Use `null` if the source needs no protector.
    * `pingUrl`: URL for ping.
    * `needToLogin`: Indicates whether login is required (true or false).
    * `inAppBrowserInterceptor`: Indicates whether to use in-app browser interceptor (true or
      false).
* `searchAvailable`: Indicates whether search functionality is available (true or false).
* `downloadConfig` (optional): Pacing for downloads, for sources that rate limit (HTTP 429).
  Leave it out to download at full speed.
    * `pageDelayMs`: Pause between page images of a chapter, in milliseconds. Defaults to `0`.
    * `chapterDelayMs`: Pause before each next chapter in the queue, in milliseconds. Defaults to
      `0`.
    * `segmentConcurrency` (api 2): How many HLS segments of one episode are downloaded at the same
      time. Leave it out for the app default of `3`; use `1` for CDNs that throttle parallel
      requests.
    * `episodeDelayMs` (api 2): Pause before each next episode in the queue, in milliseconds.
      Defaults to `0`.

  The app also slows a source down on its own after a 429 and honours `Retry-After`; these values
  are the floor it starts from.
* `apiVersion` (optional): The extension API the script needs, `1` when left out. Set `2` as soon
  as you use anything marked *api 2* in these guides. See [API versions](#api-versions).
* `minAppVersion` (optional): The oldest app release the extension works with, as `"x.y.z"`. See
  [API versions](#api-versions).
* `preferences` (api 2, optional): Settings the user can change for this extension. See
  [Preferences](#preferences).
* `requestPolicy` (api 2, optional): Rate limit, default headers and mirrors for every request
  the script makes. See [Request policy](#request-policy).
* `feeds` (api 2, optional): Alternative listings for the gallery, such as "Popular" or "Latest".
  See [Feeds](#feeds).

see [template](./extension_templates/manga/config.json)

Then you need to create a new file called `main.capyscript` which will contain the main script for
all the
functionality of the extension.

see [template](./extension_templates/manga/main.capyscript)

each extension should have the following functions:

* `getGallery` - returns a list of gallery models created with `buildGallery` function

```capyscript

function getGallery(page, query, filters, feed) {

}

```

where `page` is the page number (the first page is `1`), `query` is the search query, `filters` is
the list of filters the user selected and `feed` is the id of the selected [feed](#feeds). `query`
is `""` when the user is not searching — then the extension should return the home page. See
[Filters](#filters) for the shape of `filters`.

Arguments are bound by name and extra ones are ignored, so an extension without feeds can keep the
three-argument `getGallery(page, query, filters)`.

* `getConcrete` - returns a concrete model created with `buildConcrete` function

it has the following signature:

```capyscript
function getConcrete(uid, data) {

}
```

where `uid` is the uid of the gallery, `data` is the metadata that you can pass to the function from
the `buildGallery` function

* `getPages` - returns a list of page models created with `buildPage` function

it has the following signature:

```capyscript

function getPages(uid, data) {

}
```

where `uid` is the uid of the gallery, `data` is the metadata that you can pass to the function from
the `buildConcrete` function

* `getImageHeaders` - returns a list of headers for image requests

it has the following signature:

```capyscript
function getImageHeaders(uid) {
    return {};
}
```

where `uid` is the uid of the image
e.g. uid for `MangaGalleryView` model or `MangaConcreteView` model or `Pages` model

**OPTIONAL, only if `protectorConfig` is set**

* `passProtector` - It gets called after the app pings the `pingUrl` from `protectorConfig` and gets
  the response, headers, and cookies from the request. You can use it to set specific headers or
  cookies for all following requests using the `useHeaders` function.

it has the following signature:

```capyscript
function passProtector(body, headers, cookies) {
    useHeaders({"headers": headers});
}
```

* `passWebBrowserInterceptorController` - It gets called after the app creates a
  new `WebBrowserInterceptorController` and gets the controller.
  currently, it's just a placeholder for future functionality.

## Creating anime extension

An anime extension uses the same `config.json` with `"type": 1` and the same `getGallery`,
`getConcrete` and optional `passProtector` functions, but builds its models with the
[`anime_models`](caypscript_modules.md#anime-models) module (`buildAnimeVideoGroup`,
`buildAnimeVideo`). It has no `getPages` or `getImageHeaders`.

Each episode is a `buildAnimeVideo` with a stable `uid`. Groups usually stand for one dub or one
player (for example one group per dub and player), and the app keeps the same episode `number`
when the user switches between them.

### getVideoSources

Optional. Lets the app play an episode in its native player, and download it for offline
viewing, instead of the webview embed.

```capyscript
function getVideoSources(uid, src, data) {
    return [
        {
            "url": "https://cdn.example.com/ep3/master.m3u8",
            "quality": "Auto",
            "format": "hls",
            "headers": {"Referer": "https://player.example.com/"},
            "subtitles": [],
        },
    ];
}
```

where `uid`, `src` and `data` are the fields of the `buildAnimeVideo` that was tapped. Return a
list of sources built with `buildAnimeVideoSource` (or plain maps with the same keys); see
[`buildAnimeVideoSource`](caypscript_modules.md#to-describe-a-playable-stream-use-the-buildanimevideosource-function).

How the app uses it:

* If the function exists, it is called every time an episode is played, and again whenever a
  download starts or resumes, so short-lived signed URLs are fine. Don't store them in `data`.
* Several sources can be returned (for example one per quality); the user can switch between
  them. HLS sources with several renditions also get a rendition picker.
* An empty list or an error falls back to playing `src` directly for `typeDirect()` episodes, and
  to the webview player otherwise. The app also falls back when the call takes longer than about
  20 seconds.
* `headers` are sent with every request the player or the downloader makes for that source,
  including HLS segments and AES-128 keys. Some CDNs reject segment requests without the right
  `Referer`, `Origin`, `Accept` or `Accept-Language`.
* Downloads support HLS (including AES-128 encryption and byte ranges) and MP4. DASH and
  DRM-protected streams cannot be downloaded.
* Calls into one extension never run at the same time, so a slow `getVideoSources` delays the
  next call. Make only the requests you need.
* Each source can carry `skip` markers (intro, outro, recap), an `audioLabel` naming the dub or
  voice-over, and `preferForDownload`. Older app builds ignore them, so they need no `apiVersion`
  bump. Only return markers the player or its API actually exposes; never guess them from the
  episode length. See
  [`buildAnimeVideoSource`](caypscript_modules.md#to-describe-a-playable-stream-use-the-buildanimevideosource-function).

Anitube.in.ua, for example, reads FenixPlay's `intro_start`/`ending_end` fields and MoonAnime's
`window.__skipSegments`, and labels every source with the dub the episode group belongs to (kept
in the episode's `data` by `getConcrete`):

```capyscript
fenixSources.push({
    "url": masterUrl,
    "quality": "Auto",
    "format": "hls",
    "headers": fenixStreamHeaders,
    "subtitles": episodeSubtitles,
    "skip": [{"type": "outro", "start": 1340, "end": 1416}],
    "audioLabel": data["dub"]
});
```

Sources behind a Cloudflare-style challenge can use the headless browser through
`protectorConfig` with `inAppBrowserInterceptor: true`, the same way gallery and concrete
requests do.

## Filters

Filters are declared in `config.json`, not in the script. The app builds the filter sheet from that
declaration and passes whatever the user picked into `getGallery` as the third argument.

Every filter shares three fields:

* `type` — one of the types below.
* `paramName` — the label shown in the app.
* `param` — the key you use when building your request.

| `type`                 | Declares                        | User picks                        |
|------------------------|---------------------------------|-----------------------------------|
| `ONE_OF_MULTIPLE`      | `values`, optional `labels`     | one of the listed values          |
| `MULTIPLE_OF_MULTIPLE` | grouped `values`, opt. `labels` | many values, grouped              |
| `ONE_OF_ANY`           | —                               | one free-text value               |
| `MULTIPLE_OF_ANY`      | —                               | many free-text values             |
| `SWITCHER`             | `onValue`, `offValue`           | on / off                          |
| `RANGE`                | `paramMin`, `paramMax`, `min`, `max` | a from/to pair               |

`values` is a list of the raw values sent to the site; `labels` is the matching list of display
names. When `labels` is omitted the raw values are shown. For `MULTIPLE_OF_MULTIPLE` both are lists
of lists, one inner list per group.

Example declaration:

```json
"filters": [
  {
    "type": "ONE_OF_MULTIPLE",
    "paramName": "Status",
    "param": "status[]",
    "values": ["ongoing", "completed", "hiatus", "cancelled"],
    "labels": ["Ongoing", "Completed", "Hiatus", "Cancelled"]
  }
]
```

### Reading filters in the script

Each entry of `filters` holds the original declaration under `filter`, plus the user's selection.
Which key carries the selection depends on the type:

* `ONE_OF_MULTIPLE`, `ONE_OF_ANY` — `selected` is a string
* `MULTIPLE_OF_ANY` — `selected` is a list of strings
* `MULTIPLE_OF_MULTIPLE` — `selected` is a list of lists of strings
* `SWITCHER` — `on` is a boolean
* `RANGE` — `from` and `to` are strings, either of which may be absent

Filters the user left untouched are not included, so you only ever iterate over active ones.

```capyscript
for (i = 0; i < filters.length; i = i + 1) {
    filterData = filters[i];
    filter = filterData["filter"];
    type = filter["type"];

    if (type == "ONE_OF_MULTIPLE" || type == "ONE_OF_ANY" || type == "MULTIPLE_OF_ANY") {
        params[filter["param"]] = filterData["selected"];
    } else if (type == "SWITCHER") {
        if (filterData["on"]) {
            params[filter["param"]] = filter["onValue"];
        }
    } else if (type == "RANGE") {
        params[filter["paramMin"]] = filterData["from"];
        params[filter["paramMax"]] = filterData["to"];
    }
}
```

## API versions

`apiVersion` tells the app which extension API the script was written for. Version `1` is
everything that existed before the fields and modules marked *api 2* in these guides; leave the
field out (or set `1`) if you use none of them. Set `"apiVersion": 2` when the config declares
`preferences`, `requestPolicy`, `feeds`, `downloadConfig.segmentConcurrency` or
`downloadConfig.episodeDelayMs`, or the script imports `preferences`, `storage` or `errors`, or
calls `currentMirror()`. The repository validator reports any api 2 feature used without it.

`minAppVersion` is for everything else that only works from a given release on, such as a new
model field your extension depends on. It is compared with the running app's version.

`tool/build_index.dart` copies both fields into each `index.json` entry, so the app can check an
extension before downloading its script. When an extension needs a newer app (a higher
`apiVersion` than the app supports, or a `minAppVersion` above its version):

* the listing marks it as needing a newer app, and it cannot be installed;
* an installed copy is never updated to that revision: the app keeps running the revision it
  already has, and marks the update as waiting for a newer app.

App releases from before api 2 do not read either field. They download any revision, and an api 2
script fails on them as soon as it touches something they lack (an unknown module import fails
the whole script). Keep api 2 changes on a staging branch until the users of those releases have
updated.

## Feeds

Feeds are alternative listings shown as tabs above the gallery, declared in `config.json`:

```json
"feeds": [
  {"id": "popular", "title": "Popular"},
  {"id": "latest", "title": "Latest updates"}
]
```

The selected feed's `id` arrives as the `feed` argument of `getGallery`; it is `""` when the user
is on the default listing. A search overrides feeds, so treat a non-empty `query` as a search
whatever `feed` holds. MangaDex keeps its old listing for `""`:

```capyscript
function getGallery(page, query, filters, feed) {
    if (query == "" && feed == "latest") {
        return getLatestGallery(page, filters);
    }
    params = {"limit": 20, "offset": 20 * page, "includes": ["cover_art"]};
    if (query != "") {
        params["title"] = query;
    } else if (feed == "popular") {
        params["offset"] = 20 * (page - 1);
        params["order"] = {"followedCount": "desc"};
    }
    ...
}
```

Filters apply to every feed; it is up to the script which of them a feed can honour.

## Preferences

Preferences are per-extension settings the app renders on the extension's page and the script
reads with [`getPreference`](caypscript_modules.md#preferences). Each entry has:

* `key` — the name the script reads. Must be unique within the extension. Don't start it with
  `__`; the app uses that prefix for its own keys such as `__mirror`.
* `type` — `toggle`, `select`, `multiselect`, `text` or `number`. Entries with any other type are
  ignored, so a newer type never breaks an older app.
* `title` — the label in the settings list.
* `summary` (optional) — a line of help under the title.
* `default` (optional) — the value used until the user changes it.
* `options` — `[{"value": "…", "label": "…"}]` for `select` and `multiselect`.

| `type`        | `getPreference` returns | Default when `default` is missing |
|---------------|-------------------------|-----------------------------------|
| `toggle`      | `true` / `false`        | `false`                           |
| `select`      | the chosen `value`      | the first option's `value`        |
| `multiselect` | a list of `value`s      | `[]`                              |
| `text`        | a string                | `""`                              |
| `number`      | a number                | `0`                               |

Anitube.in.ua lets the user reorder its episode groups:

```json
"preferences": [
  {
    "key": "preferredPlayer",
    "type": "select",
    "title": "Preferred player",
    "summary": "Episode lists from this player come first within each dub",
    "default": "auto",
    "options": [
      {"value": "auto", "label": "Site order"},
      {"value": "fenixplay", "label": "FenixPlay"},
      {"value": "ashdi", "label": "Ashdi"}
    ]
  },
  {
    "key": "preferredDubs",
    "type": "text",
    "title": "Preferred dubs",
    "summary": "Dub studio names to list first, comma-separated in order of preference",
    "default": ""
  },
  {
    "key": "hideUnsupportedPlayers",
    "type": "toggle",
    "title": "Hide unsupported players",
    "default": false
  }
]
```

and MangaDex uses a `multiselect` of language codes (`"default": ["en"]`) for its chapter feed.
Preferences are read when a function runs, so a change applies to the next gallery page or title
the user opens. Pick defaults that reproduce the extension's old behaviour, so updating it changes
nothing until the user opts in.

When the extension declares `requestPolicy.mirrors`, the app adds a mirror picker of its own,
stored under the built-in key `__mirror`. Don't declare that key yourself; read the active mirror
with [`currentMirror()`](caypscript_modules.md#http) if the script needs it.

## Request policy

`requestPolicy` applies to every `httpGet` and `httpPost` the script makes:

```json
"requestPolicy": {
  "rateLimit": {"requests": 3, "perSeconds": 2},
  "defaultHeaders": {"Accept-Language": "uk-UA,uk;q=0.9"},
  "userAgent": "Mozilla/5.0 …",
  "mirrors": ["https://api.cdnlibs.org", "https://api.lib.social", "https://api2.mangalib.me"]
}
```

All four fields are optional.

**`rateLimit`** allows at most `requests` request starts in any window of `perSeconds` seconds
(fractions such as `0.5` work). Requests over the limit wait their turn, in order. The limit is
extension-wide: gallery, details and video-source calls, and requests that go through the
webview, all share one budget for as long as the app runs (background tasks such as library
update checks run in a separate isolate and keep their own budget). Size it for the strictest
host the script talks to without starving the others. Anitube.in.ua uses 3 requests per 2 seconds:
opening a FenixPlay episode takes two requests and never waits, a season download is held to
about 1.5 requests a second, and gallery paging is unaffected. `downloadConfig` still paces the
downloads themselves (pages and segments are fetched by the app, not the script).

**Headers** are combined in this order, each step overriding the one before it, with header names
compared case-insensitively:

1. `defaultHeaders`
2. `userAgent` (sent as `User-Agent`)
3. headers set with `useHeaders`, usually from `passProtector`
4. the `headers` argument of the call itself

**`mirrors`** lists base URLs that serve the same site or API. A request whose URL starts with one
of them (followed by `/`, `?`, `#` or nothing; the longest match wins) is sent to the mirrors in
this order instead:

1. the mirror the user picked in the extension settings (`__mirror`);
2. the last mirror that answered, for this extension, since the app started;
3. the remaining mirrors, in the declared order.

With no choice made yet, the first declared mirror is used, so list the host your script's URLs
already use first. A mirror that fails with a connection error (DNS, TLS, refused, timeout) or
answers 5xx is skipped for the next one; the last candidate's answer or error is what the script
gets. Any other status, including 403, 404 and 429, is returned as is without trying the next
mirror. Keep writing your URLs against one host; the policy does the rewriting.

Requests with `throughWeb: true` get the rate limit, the combined headers and the rewrite to the
first mirror candidate, but no failover: the webview reports what it loaded.

Only list hosts that really serve the same content: MangaLib and HentaiLib list
`api.lib.social` and `api2.mangalib.me` next to `api.cdnlibs.org` because all three answer the same
API with the same data.

## Errors the app understands

By default a failed function shows its error message to the user. With the
[`errors`](caypscript_modules.md#errors) module (api 2) the script can tell the app *why* it
failed:

| Kind            | Use it when                                         | The app                                       |
|-----------------|-----------------------------------------------------|-----------------------------------------------|
| `loginRequired` | the source wants a (new) sign-in                    | offers to sign in through the protector page  |
| `rateLimited`   | the source answered 429 or asks you to slow down    | suggests trying again later                   |
| `notFound`      | the title or chapter is gone from the source        | marks it as removed from the source           |
| `regionBlocked` | the source refuses the user's country               | explains that it is blocked in the region     |
| `sourceDown`    | 5xx, maintenance pages, unreachable hosts           | reports the source as unavailable for now     |
| `unsupported`   | the extension cannot handle this title or request  | says the extension does not support it        |

Only throw a kind when the source clearly signals it; a guessed `notFound` tells the user a title
was deleted when it was not. MangaDex maps its status codes directly, but the lib.social API also
answers 404 for chapters it hides from signed-out users, so its decoder asks `/api/auth/me` first:

```capyscript
if(apiStatusCode == 404) {
    sessionCheck = httpGet({"url": "https://api.cdnlibs.org/api/auth/me", "headers": {"Accept": "application/json"}});
    if(sessionCheck["statusCode"] == 401) {
        throwSourceError("loginRequired", "sign in again (" + requestLabel + ")");
    }
    throwSourceError("notFound", "not found on the source (" + requestLabel + ")");
}
```

A typed error passes through any number of script functions to the app. A `try`/`catch` in the
script catches it like any other error, but `e` only holds the message (or the kind's name when the
message is empty) and the kind is lost; call `throwSourceError` again inside the `catch` to pass it
on. `getVideoSources` errors never reach the user, they only make the app fall back to the embed.

Avoid `try { … } finally { … }` without a `catch`: the interpreter swallows the error in that
form, so the function carries on as if nothing failed. Add a `catch` that rethrows.

## Storing data between calls

The [`storage`](caypscript_modules.md#storage) module (api 2) keeps small JSON values for the
extension between calls and app restarts, optionally with an expiry: tokens, a resolved API host,
a cached genre list. It is private to the extension, is not part of the app's export, and is
deleted when the extension is removed.

## Splitting an extension across files

`main.capyscript` does not have to hold everything. A relative import is resolved and inlined before
the script is interpreted, so you can keep helpers in their own files:

```capyscript
import "./utils.capyscript";
import "../shared/parsing.capyscript";
```

Relative paths (`./`, `../`) are fetched and merged into a single script; each file is included only
once, so a shared helper imported from two places is safe. Imports that are not relative — the
built-in modules — are kept as-is and hoisted to the top.

## Testing your extension

Create a GitHub repository with your extension and add it to the app under **Explore → Sources →
+**. See [external extension sources](../inapp_docs/external_extension_sources.md) for the required
repository layout.

When you add the repository you can also pick a **branch**, which lets you keep work-in-progress
extensions on a staging branch and point the app at it without touching your main branch.

For iterating without pushing to GitHub, the app can also read configs from a local HTTP server set
via `LOCAL_REPOSITORY_URL` in `.env`. The server needs to answer two endpoints:

* `GET /configs?category=manga|anime` → `{"configs": [ ... ]}`
* `GET /script?path=<path>` → `{"path": "...", "script": "..."}`

This path is developer-only for now — `RemoteConfigsCubit` has to be switched over to
`RepoConfigsService` in code, so it is not selectable from the UI.

## Example

See existing extension in wakaranai_configs
repo [here](https://github.com/Sayuri128/wakaranai_configs) for examples.
