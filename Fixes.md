* methods that retrieve an id, then use the id to retrieve an object should be broken into two methods, then a third convenience method
	* mostly resolved, but there are a few more obscure instances where this remains true.
* disabled streaming endpoints
	* uint64 untyped extensions for mb, gb, ms, etc -> RawRepresentable types - currently unused - might be used in disabled endpoints?
