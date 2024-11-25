* methods that retrieve an id, then use the id to retrieve an object should be broken into two methods, then a third convenience method
	* mostly resolved, but there are a few more obscure instances where this remains true.
* Move models into endpoints except when shared between endpoints
* uint64 untyped extensions for mb, gb, ms, etc -> RawRepresentable types
* rename `spec` to `config`
* disabled streaming endpoints
