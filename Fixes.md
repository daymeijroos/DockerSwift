* methods that retrieve an id, then use the id to retrieve an object should be broken into two methods, then a third convenience method
* Move models into endpoints except when shared between endpoints
* try to consolidate the 4 run methods into two (one for call->response and another for call->stream)
* clean up deprecated token usage
