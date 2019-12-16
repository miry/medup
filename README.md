<p align="center">
  <a href="#">
    <img src="/img/logo.png?raw=true" width="200"/>
  </a>
</p>

# Medup

[![](https://img.shields.io/github/release/miry/medup.svg?style=flat)](https://github.com/miry/medup/releases)
[![](https://img.shields.io/github/license/miry/medup)](https://raw.githubusercontent.com/miry/medup/master/LICENSE)

> Sync all content from Medium with local folder via API

# Table of Contents

* [Features](#features)
* [Installation](#installation)
* [Getting Started](#getting-started)
* [Contributing](#contributing)
* [Contributors](#contributors)
* [License](#license)

# Features

* Discover all articles from user account available in public
* Download images used inside article

# Installation

...

# Getting Started

Start dumping process via command

```shell
medup -u <medium user> -d <destination folder>
```

By default all articles are going to dump in `posts` folder.

Docker way to make same job:

```shell
docker run -v <path to local articles folder>:/posts -it miry/medup -u miry
```

Run dumping with source code

```shell
crystal run src/cli.cr -- -u miry -d posts/miry
```

In the result directory, you can find 2 format of files: `.json` and `.md`.
- *JSON* format is the raw, what *Medium* returns.
- *Markdown* format is simple implementation of block formated text.

# Contributing

1. Fork it ( https://github.com/miry/medup/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

# Contributors

- [miry](https://github.com/miry) Michael Nikitochkin - creator, maintainer

# License

This project is under the LGPL-3.0 license.

# TODO
- [ ] Installation process
- [ ] Clean code
- [ ] Standardize logging
- [ ] Save in Markdown format with correct images
- [ ] Extract Medium API to a separate shard
- [ ] Create posts from local Markdown articles
- [ ] Update a post content from local files
- [ ] Extract posts from Publishers

# Play ownself

### Medium API

1. [Medium API documentation](https://github.com/Medium/medium-api-docs)
1. Generate token on the page https://medium.com/me/settings
1. Create environment variable `MEDIUM_TOKEN=<token>`

1. Verify token with sample query:
```shell
$ curl -H "Authorization: Bearer <token>" https://api.medium.com/v1/me
{"data":{"id":"number","username":"miry","name":"Michael Nikitochkin","url":"https://medium.com/@miry","imageUrl":"https://cdn-images-1.medium.com/fit/c/400/400/0*KgbjgGnH-csHuB8j."}}
```

### Crawler

1. Check public information not covered by API
```shell
$ curl "https://medium.com/@miry?format=json" | cut -c17- && : Remove in the front from response some strange JS code.
```

2. Pagination
```shell
$ curl "https://medium.com/@miry/latest?format=json&limit=100" | cut -c17- && : Remove in the front from response some strange JS code.
```

3. Post info
```shell
curl -s -H "Content-Type: application/json" https://medium.com/@miry/c35b40c499e\?format\=json\&limit\=100
```

4. Stream:
```shell
$ curl -s -H "Content-Type: application/json" "https://medium.com/_/api/users/fdf238948af6/profile/stream" | cut -c17-
$ curl -s -H "Content-Type: application/json" "https://medium.com/_/api/users/fdf238948af6/profile/stream?limit=100&page=3" | cut -c17- > stream.json
$ cat stream.json| jq ".payload.references.Post[].title"
$ cat stream.json| jq ".payload.paging.next"
```
