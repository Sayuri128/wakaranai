# Guides

* [Extensions](extensions.md) — how an extension is structured, the functions it must implement,
  how filters are declared and read, and how to test one.
* [Capyscript syntax](capyscript_syntax.md) — the language itself.
* [Capyscript modules](caypscript_modules.md) — the built-in modules available to scripts.
* [External extension sources](../inapp_docs/external_extension_sources.md) — hosting your own
  extension repository and pointing the app at it.

Templates for new extensions live in [extension_templates](extension_templates), one folder each for
manga, anime, novels and audiobooks. They declare the api 2 fields (`feeds`, `pagination`,
`preferences`, `protectorConfig`) as examples; remove whichever your extension doesn't use.
