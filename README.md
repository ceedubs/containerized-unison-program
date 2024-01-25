# Containerized Unison program

This repository pulls a [Unison][unison] program from [Unison Share][share], compiles it, and builds a Docker image that runs the compiled program. You should be able to fork it, change a few configuration settings, and containerize your own Unison program.

# Build the container

```sh
make build
```

This will print some Docker logs to the terminal and build some images. The main image that we care about will be named `unison-application` and will be now have a `latest` tag and a timestamp-based tag.

# Run the container

```sh
docker run -p 8081:8081 unison-application
```

The default program is a web server that you should now be able to send requests to:

```
❯ curl -i localhost:8081/hello
HTTP/1.1 200 OK
Content-Length: 11

Hello World
```

If you [containerize another Unison program](#configuration), then you may be able to run `docker run unison-application` without exposing port 8081.

# Configuration

To containerize another Unison program, you need to change a few configuration settings at the top of the [Makefile](Makefile):

- `SHARE_USER` (default: `ceedubs`)
  - The handle of the Unison Share user who has published the code
- `SHARE_PROJECT` (default: `httpserver`)
  - The name of the Unison Share project within the scope of the Unison Share user
- `PROJECT_RELEASE` (default: `3.0.2`)
  - The release version of the Unison Share project.
- `MAIN_FUNCTION` (default: `example.main`)
  - The name of the main function to run within the application. This will generally have the type `'{Exception, IO} ()`.

Now you should be able to [build](#build-the-container) and [run](#run-the-container) your own Unison program!

If you would prefer your container to have a name other than `unison-application`, you can find/replace all occurrences of `unison-application` in [Makefile](Makefile) and [docker/Dockerfile][dockerfile].

# Technical details

The code/configuration to build the Docker container is a bit more complex than one might expect. There are a few reasons for this complexity:

## Compiling

The most efficient way to run a Unison program is to first compile it and then to run the compiled binary. This adds a couple of steps to the build.

## Keeping noise out of the image

The methods used to achieve [compiling](#compiling) produce some temporary files that we don't care about for the final image that runs the Unison program. This repository uses [Docker multi-stage builds](https://docs.docker.com/build/building/multi-stage/) to keep the extra files out of the final image, at the cost of a bit of extra noise in the [Dockerfile][dockerfile].

[docker]: https://www.docker.com/
[dockerfile]: docker/Dockerfile
[share]: https://share.unison-lang.org/
[unison]: https://www.unison-lang.org/
