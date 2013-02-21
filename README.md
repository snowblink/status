# status [![Build Status](https://travis-ci.org/dougdroper/update_status.png?branch=master)](https://travis-ci.org/dougdroper/update_status)

Updates pull requests on github using the statuses api (http://developer.github.com/v3/repos/statuses/), with latest build from Jenkins and QA status

## Usage


<tt>gem install update_status</tt>


on your branch run

$: <tt>status</tt>

This will generate a .status.yml file in the current directory, you will need to edit this file with your credentials.

.status.yml:

```ruby
  :username: Jenkins username
  :password: Jenkins password
  :token: Githubs API token (http://developer.github.com/v3/oauth/)
  :owner: Owner of the repository eg. dougdroper
  :repo: eg. status
  :ci_url: eg. http://ci.jenkins.com
  :qa_required: true
```

add .status.yml to .gitignore

##

When your branch has passed QA

  $: <tt>status -q pass</tt>

You can pass a different branch

  $: <tt>status -b other_feature_branch</tt>

or

  $: <tt>status -b other_feature_branch -q pass</tt>

You can also pass based on the SHA

  $: <tt>status -s SHA -q pass</tt>

When qa_required is false then there is no need to pass in a qa option

help

$: <tt>status -h</tt>

## Github oauth

You need an API token to interact with githubs api

$: curl -u "YOUR GITHUB USERNAME" -d '{"add_scopes":["repo"]}' https://api.github.com/authorizations

```javascript
{
  "id": 1,
  "url": "https://api.github.com/authorizations/1",
  "app": {
    "name": "GitHub API",
    "url": "http://developer.github.com/v3/oauth/#oauth-authorizations-api"
  },
  "token": "NEW TOKEN",
  "note": null,
  "note_url": null,
  "created_at": "2013-02-11T17:02:36Z",
  "updated_at": "2013-02-11T17:02:36Z",
  "scopes": [
  ]
}
```

This generates a new token, now you need to add_scopes to the id of the returned token

$: curl -u "YOUR GITHUB USERNAME" -d '{"add_scopes":["repo"]}' https://api.github.com/authorizations/1

Then add this token in the .status.yml file

## Contributing to status

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Douglas Roper. See LICENSE.txt for
further details.

