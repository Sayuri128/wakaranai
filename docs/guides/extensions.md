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

see [template](./extension_templates/manga/config.json)

Then you need to create a new file called `main.capyscript` which will contain the main script for
all the
functionality of the extension.

see [template](./extension_templates/manga/main.capyscript)

each extension should have the following functions:

* `getGallery` - returns a list of gallery models created with `buildGallery` function

```capyscript

function getGallery(page, query, filters) {

}

```

where `page` is the page number, `query` is the search query, `filters` is the list of filters the
user selected. `query` is an optional parameter — if it's not provided, then the extension should
return the home page. See [Filters](#filters) for the shape of `filters`.

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
