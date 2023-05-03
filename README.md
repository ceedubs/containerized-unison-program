# Containerized Unison program

This repository pulls a [Unison][unison] program from [Unison Share][share], compiles it, and builds a Docker image that runs the compiled program. You should be able to fork it, change a few configuration settings, and containerize your own Unison program.

# Build the container

```sh
make build
```

This will print some Docker logs to the terminal and build some images. The main image that we care about will be named `unison-application` and will be now have a `latest` tag and a timestamp-based tag.

# Run the container

```sh
docker run -p 8080:8080 unison-application
```

The default program is a web server that you should now be able to send requests to:

```
❯ curl -i localhost:8080/hello
HTTP/1.1 200 OK
Content-Length: 11

Hello World
```

If you [containerize another Unison program](#configuration), then you may be able to run `docker run unison-application` without exposing port 8080.

# Configuration

To containerize another Unison program, you need to change a few configuration settings at the top of the [Makefile](Makefile):

- `SHARE_USER` (default: `ceedubs`)
  - The handle of the Unison Share user who has published the code
- `SHARE_NAMESPACE` (default: `public.hello_server.latest`)
  - The namespace of the code, relative to the Unison Share user
- `MAIN_FUNCTION` (default: `main`)
  - The name of the main function to run within the application. This will generally have the type `'{Exception, IO} ()`.

Now you should be able to [build](#build-the-container) and [run](#run-the-container) your own Unison program!

If you would prefer your container to have a name other than `unison-application`, you can find/replace all occurrences of `unison-application` in [Makefile](Makefile) and [docker/Dockerfile][dockerfile].

# Technical details

The code/configuration to build the Docker container is a bit more complex than one might expect. There are a few reasons for this complexity:

## Caching

In general caching with Docker can be a bit tricky. Pulling a namespace from [Share][share] is slow enough that you really want to take advantage of the cache, but it isn't a single HTTP request, so it doesn't play nicely with Docker's `ADD` instruction.

This repository takes advantage of the fact that checking the hash of a namespace is much faster than pulling all of it. The `fetch-unison-application-hash` layer fetches the namespace hash, and the `compile-unison-application` layer only pulls the code again if it has changed.

Unfortunately achieving this gets a bit messy and is implemented with a mixture of Docker ARGs, timestamps, `curl`, and `jq`.

## Compiling

The most efficient way to run a Unison program is to first compile it and then to run the compiled binary. This adds a couple of steps to the build.

## Keeping noise out of the image

The methods used to achieve [caching](#caching) and [compiling](#compiling) produce some temporary files that we don't care about for the final image that runs the Unison program. This repository uses [Docker multi-stage builds](https://docs.docker.com/build/building/multi-stage/) to keep the extra files out of the final image, at the cost of a bit of extra noise in the [Dockerfile][dockerfile].

[docker]: https://www.docker.com/
[dockerfile]: docker/Dockerfile
[share]: https://share.unison-lang.org/
[unison]: https://www.unison-lang.org/
