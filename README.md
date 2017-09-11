# HelloHipsterStack

The Hipster Stack!
==================

This repo describes my version of the Elm hipster stack. The original
setup I found is located on github at
[carleryd/elm-hipster-stack](https://github.com/carleryd/elm-hipster-stack). I
had trouble with that version out of the box, because it wasn’t
originally generated with Phoenix version 1.3, but rather was
converted.

Besides, I think it is instructive to see how this stuff is put together.

Currently my version of the hipster stack does not yet include GraphQL. I’ll get to it when I get there.

-   Elm(version 0.18)
-   Phoenix(version 1.3)
-   GraphQL (TBD)
-   PostgreSQL (9.6.2)

How to rather than git clone
============================

Because it is dumb to just copy and paste this, and because any
“official” hipster stack will quickly get out of date given that the
components (Phoenix and Elm) are rapidly evolving, what follows is how
to get phoenix and elm up and running in the same repo. GraphQL might
follow later, but I’m not using it that much yet (until I get the hang
of phoenix and elm, it seems a bit too much to learn all at once).

Create a phoenix app thingee
----------------------------

Do something like

```
export MYAPP="hello_hipster_stack"
mix phx.new $MYAPP
```

Set up the database
-------------------

One of the online help things I read recommended using Docker to run PostgreSQL. I’m of two minds about that, because while it is great for firing up a blank database during development and test, I’m new to Docker and not really sure how to get the DB to persist to disk between power cycles, etc.

Anyway, first make sure the docker container is running.

```
docker run --rm --name ${MYAPP}-dev-db -p 6543:5432 -d postgres:9.6.2
```

That should work. If it doesn’t, make it work.

The port for the docker DB is mapped to 6543 on your local machine in the above command. I do this because I’m already running a regular version of PostgreSQL on port 5432, and by tunneling the docker DB to a different port, I don’t get conflicts.

This port needs to be entered into the configurations for dev and test.

First for dev, edit `config/dev.exs`, and add the port to the database part as follows. Note that in my testing case, I am using `hello_hipster_stack` as my app name. You should expect to see your app name in the below configuration snippet, of course.

```
# Configure your database
config :hello_hipster_stack, HelloHipsterStack.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "hello_hipster_stack_dev",
  hostname: "localhost",
  port: 6543,  ## add this port (if you're running docker as described)
  pool_size: 10
```

Similarly, edit the file `config/test.exs` to have the correct PostgreSQL port.

```
# Configure your database
config :hello_hipster_stack, HelloHipsterStack.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "hello_hipster_stack_test",
  hostname: "localhost",
  port: 6543,  ## add this port (if you're running docker as described)
  pool: Ecto.Adapters.SQL.Sandbox
```

Deploy the dev database
-----------------------

As described in the Phoenix mix task, create the dev database with the command `mix ecto.create`.

```
cd $MYAPP
mix ecto.create
```

Make sure stuff works
---------------------

Just to make sure the skeleton app is working okay, fire it up.

```
mix phx.server
[info] Running HelloHipsterStackWeb.Endpoint with Cowboy using http://0.0.0.0:4000
11:30:22 - info: compiled 6 files into 2 files, copied 3 in 698 ms
```

Also, the auto-generated tests should pass at this point.

```
mix test
==> connection
Compiling 1 file (.ex)
Generated connection app

  (lots of similar compiling messages)

==> hello_hipster_stack
Compiling 16 files (.ex)
Generated hello_hipster_stack app
....

Finished in 0.05 seconds
4 tests, 0 failures
```

Install Elm
-----------

The next step is to load up Elm in the assets area

```
cd assets
 npm i -S elm elm-brunch
npm WARN deprecated node-uuid@1.4.8: Use uuid module instead

> elm@0.18.0 install /home/james/repos/jem/elixir/phoenix_trials/hello_hipster_stack/assets/node_modules/elm
> node install.js

Downloading Elm binaries from https://dl.bintray.com/elmlang/elm-platform/0.18.0/linux-x64.tar.gz
npm WARN assets No description
npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents@1.1.2 (node_modules/fsevents):
npm WARN notsup SKIPPING OPTIONAL DEPENDENCY: Unsupported platform for fsevents@1.1.2: wanted {"os":"darwin","arch":"any"} (current: {"os":"linux","arch":"x64"})

+ elm-brunch@0.9.0
+ elm@0.18.0
added 177 packages in 14.647s
```

Create basics of Elm package
----------------------------

With Elm installed, the next step is to deploy the needed Elm code and libraries. To keep things somewhat isolated, I’ve been storing everything in a folder called `elm` under `assets`.

Note that the `npm` command run above was run in the `assets` directory. These next commands installing Elm libraries are run in the directory `assets/elm`

```
mkdir elm
cd elm
elm-package install elm-lang/html -y
elm-package install elm-lang/http -y
elm-package install elm-lang/websocket -y
```

These are the libraries I always seem to need. Undoubtedly some other dependencies will arise during development. If any other libraries need to be installed, make sure you first change into the `assets/elm` directory to do so.

Add a basic `Main.elm`
----------------------

To make sure everything is working, create a basic Elm file.

Add the following to a file called `assets/elm/Main.elm`

```
module Main exposing (..)

import Html exposing (Html, text)


main : Html a
main =
    text "Hello, World!"
```

Instruct Brunch to see the Elm sources
--------------------------------------

The next step is to tell Brunch that we want to compile Elm as well as JavaScript. To do that, look for `brunch-config.js` in the `assets` folder and edit it as follows. First the Phoenix paths configuration needs to be changed. The original version is:

```
  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["static", "css", "js", "vendor"],
    // Where to compile files to
    public: "../priv/static"
  },
```

Change that to include the `elm` subdirectory we just created.

```
  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
      watched: ["static", "css", "js", "vendor", "elm"], // add "elm" here
    // Where to compile files to
    public: "../priv/static"
  },
```

Next, scroll down a bit and find the section labeled “plugins:”, and configure the “elmBrunch” plugin.

The original file looks like this:

```
  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    }
  },
```

The new version needs to add the elmBrunch plugin, and configure it. Details on the latest options should be available from the github repo at [madsflensted/elm-brunch](https://github.com/madsflensted/elm-brunch). The following is current as of version 0.9.0

```
  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    },
      elmBrunch: {
          // (required) Set to the elm file(s) containing your "main"
          //            function `elm make` handles all elm
          //            dependencies relative to `elmFolder`
          mainModules: ['Main.elm'],

          // (optional) Set to path where elm-package.json is located,
          //            defaults to project root if your elm files are
          //            not in /app then make sure to configure
          //            paths.watched in main brunch config
          elmFolder: 'elm',

          // (optional) Set to path where `elm-make` is located,
          //            relative to `elmFolder`
          // executablePath: '../node_modules/elm/binwrappers',

          // (optional) Defaults to 'js/' folder in paths.public
          //            relative to `elmFolder`
          outputFolder: '../js',

          // (optional) If specified, all mainModules will be compiled
          //            to a single file This is merged with
          //            outputFolder.
          outputFile: 'elm.js',

          // (optional) add some parameters that are passed to
          //            elm-make
          makeParameters: ['--warn']
      }
  },
```

I had a hard time getting this to work properly. There may be better settings, but this works. Essentially, all of the elm code will be compiled to a file called `elm.js`. This file will be created in the directory `assets/js`. Brunch should then mix down this `elm.js` file with all of the other JavaScript into the standard application deploy directory, `priv/static`.

Link the Elm code in the JS code
--------------------------------

Next, edit the file `assets/js/app.js` to use the Elm code, as follows. The original file looks like this:

```
// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
```

After the commented out line `// import socket from "./socket"`, add the following to import the `elm.js` stuff.

```
import Elm from './elm';
// this might also work
// const Elm = require("./elm")

// get the elm target for the main embed call

const elmDiv = document.querySelector('#elm_target');

if (elmDiv) {
    Elm.Main.embed(elmDiv);
}else{
    // complain if there is nowhere to attach the Elm object
    console.log('no elm div')
}
```

Add the Elm DIV to the index.html page
--------------------------------------

Once the JavaScript is rewritten to find the Elm div and attach the code, the next step is to add that div to the index.html template. Leave the `assets` directory and open up the `index.html.eex` file. As of Phoenix 1.3.0, it is located in the directory `lib/${MYAPP}_web/templates/page/`. In my case, in which MYAPP is defined as hello hipster stack, the directory is `/lib/hello_hipster_stack_web/templates/page/`

The original `index.html.eex` contains a lot of boilerplate Phoenix stuff that is intended to be replaced. Rather than doing that now, just add a div to make sure that the Elm compilation and inclusion is working right. Below all the existing `<div>` elements, add the following element:

```
<div id="elm_target"></div>
```

Initialize git
--------------

Before firing up the app, initialize git. Change to the project root directory and type

```
git init
```

Or use emacs or the editor of your choice to do that for you.

Phoenix comes with a decent starter for .gitignore, but we should add the Elm directories we don’t care about. First ignore the generated elm.js program:

```
 git ignore assets/js/elm.js
Adding pattern(s) to: .gitignore
... adding 'assets/js/elm.js'
```

Then ignore the elm library installation directory.

```
git ignore **/elm-stuff
Adding pattern(s) to: .gitignore
... adding '**/elm-stuff'
```

Depending on your editor and how it is setup, you might need to add ignores for temp files, such as “\*~“, etc. Do so, then do the initial commit.

```
git ignore "*~"
Adding pattern(s) to: .gitignore
... adding '*~'

etc
```

Then

```
git add .
```

Take a look at the files that git will add and make sure that there aren’t any mistakes, temp files, etc.

```
git status
```

If so, fix them. Then commit the initial commit.

```
git commit -m 'initial commit phoenix and elm'
```

Fire up phoenix and see if things work
--------------------------------------

To test things out, fire up the phoenix server. I like to run the server in the Elixir REPL because then I can see when the elm files get recompiled and be warned of any errors.

```
iex -S mix phx.server
```

On my machine and given the way I’ve set things up, I first see an error, and do not see the “Hello World”. The output looks like:

```
 iex -S mix phx.server
Erlang/OTP 19 [erts-8.3] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

[info] Running HelloHipsterStackWeb.Endpoint with Cowboy using http://0.0.0.0:4000
Interactive Elixir (1.5.1) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 13:03:32 - error: Processing of js/app.js failed. Error: Could not load module './elm' from '/home/james/repos/jem/elixir/phoenix_trials/hello_hipster_stack/assets/js'. Make sure the file actually exists.
Stack trace was suppressed. Run with `LOGGY_STACKS=1` to see the trace. ^G
13:03:32 - info: compiled 70 files into 2 files, copied 3 in 1.8 sec
Elm compile: Main.elm, in elm, to ../js/elm.js
13:03:33 - error: Processing of js/app.js failed. Error: Could not load module './elm' from '/home/james/repos/jem/elixir/phoenix_trials/hello_hipster_stack/assets/js'. Make sure the file actually exists.
Stack trace was suppressed. Run with `LOGGY_STACKS=1` to see the trace. ^G
13:03:33 - info: compiled elm.js and 83 cached files into app.js in 1.2 sec
```

However, I think what is really going on is that the Elm is getting compiled down to elm.js, but for whatever reason, the Phoenix tooling doesn’t really get the elm code into the `priv/static/js/app.js`. Refreshing the website doesn’t show the “Hello World”. However, if you shut down the server and restart the server, all is well.

```
 iex -S mix phx.server
Erlang/OTP 19 [erts-8.3] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

[info] Running HelloHipsterStackWeb.Endpoint with Cowboy using http://0.0.0.0:4000
Interactive Elixir (1.5.1) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 13:06:36 - info: compiled 73 files into 2 files, copied 3 in 2.9 sec
Elm compile: Main.elm, in elm, to ../js/elm.js
13:06:37 - info: compiled elm.js and 85 cached files into app.js in 1.2 sec
```

Looking at the website should show the lovely “Hello, World!” message.

Even though the initial Elm to JS pipeline required a server restart, after that point things seem to work fine.

To prove this to yourself, edit the `Main.elm` file to make it say “Hello, World, from Elm!”. When you save that change, you should see the Elixir REPL respond to that change with something like:

```
[debug] Live reload: priv/static/js/app.js
13:10:32 - info: compiled elm.js and 85 cached files into app.js in 1.5 sec
[info] GET /
[debug] Processing with HelloHipsterStackWeb.PageController.index/2
  Parameters: %{}
  Pipelines: [:browser]
[info] Sent 200 in 202µs
```

Switching over to your browser, you should see the new message without having to reload the page.

# Conclusion

I hope this works for you.  It will undoubtedly go out of date, like all hipster fashions, but if you're interested in Elm and Elixir, I hope this repo gets you on your way with the latest and greatest.

# What Phoenix said

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
