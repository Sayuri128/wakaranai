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
* `protectorConfig`: Configuration for the protector.
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

where `page` is the page number, `query` is the search query, `filters` is the list of filters
query is a optional parameter, if it's not provided, then the extension should return the home page

filters is currently not used, but it will be used in the future for filtering the results.

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


it has the following signature:

```capyscript

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


## Testing your extension

You can test your extension by creating new github repository and uploading your extension there.
Then you can add the repository to the app - see [here](../inapp_docs/external_extension_sources.md)

I'm also planning to add a way to test your extension locally (or via REST api) without having to upload it to github.


## Example

See existing extension in wakaranai_configs repo [here](https://github.com/Sayuri128/wakaranai_configs) for examples.
