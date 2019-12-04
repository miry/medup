# Medup

[![](https://img.shields.io/github/release/miry/medup.svg?style=flat)](https://github.com/miry/medup/releases)
[![](https://img.shields.io/github/license/miry/medup)](https://raw.githubusercontent.com/miry/medup/master/LICENSE)

Sync all content from Medium with local folder via API

## Usage

1. Generate token on the page https://medium.com/me/settings
1. Create environment variable `MEDIUM_TOKEN=<token>`
1. Run sync command

## Development

1. [Medium API documentation](https://github.com/Medium/medium-api-docs)
1. Verify token with sample query:
```shell
$ curl -H "Authorization: Bearer <token>" https://api.medium.com/v1/me
{"data":{"id":"number","username":"miry","name":"Michael Nikitochkin","url":"https://medium.com/@miry","imageUrl":"https://cdn-images-1.medium.com/fit/c/400/400/0*KgbjgGnH-csHuB8j."}}
```
1. Check public information not covered by API
```shell
$ curl "https://medium.com/@miry?format=json" | cut -c17- && : Remove in the front from response some strange JS code.
```

Pagination
```shell
$ curl "https://medium.com/@miry/latest?format=json&limit=100" | cut -c17- && : Remove in the front from response some strange JS code.
```

Post info
```shell
curl -s -H "Content-Type: application/json" https://medium.com/@miry/c35b40c499e\?format\=json\&limit\=100
```

Stream:
```shell
$ curl -s -H "Content-Type: application/json" "https://medium.com/_/api/users/fdf238948af6/profile/stream" | cut -c17-
```


```
$ curl -s -H "Content-Type: application/json" "https://medium.com/_/api/users/fdf238948af6/profile/stream?limit=100&page=3" | cut -c17- > stream.json
$ cat stream.json| jq ".payload.references.Post[].title"
 $ cat stream.json| jq ".payload.paging "
```
