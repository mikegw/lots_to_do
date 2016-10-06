## LotsToDo

This app requires a mysql database called lots_to_do and a user with access to that database.
It expects the user to have a password.

To run, clone the repo, cd into the root directory, and run the following commands:

```
bundle install
bundle exec unicorn -c unicorn.rb
```
