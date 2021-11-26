# Omw API

![Elixir & Phoenix](https://res.cloudinary.com/fghurayri/image/upload/v1637940351/faisal.sh/lab/omw/api/elixir-phoenix.jpg)

The main goal of this API is to facilitate the real-time tracking of motorcycling trips between the rider and the follower(s).

It is built on top of the [Phoenix Framework](https://www.phoenixframework.org), which is the most popular web framework in the [Elixir language](https://elixir-lang.org).

## Running Dev Environment Locally

If you have never run a Phoenix application locally before, ensure you follow the [Installation](https://hexdocs.pm/phoenix/installation.html#content) and the [Up and running](https://hexdocs.pm/phoenix/up_and_running.html#content) guides.

To run the project locally, run the following command from the root Phoenix directory: 

```sh
mix phx.server
```

Then, the application should be running successfully on port `4000`.

A potential improvement would be to provide a Docker Compose file to abstract away the required local dependencies.

## Deploying To Production

This project is deployed on [Fly.io](https://fly.io) using Elixir Releases along with Docker.

The deployment is done in the local client machine. The only caveat when deploying a new version is the need to workaround Mac M1's inability to build the Docker image locally. The reason is limitations in some of the image layers to work nicely with the Arm architecture. To workaround that, the flag `--remote-only` is needed. It will do the building step using Fly.io's Docker daemon.

To deploy, you need to be logged into Fly from the CLI. Then, the deploy command from the root Phoenix directory is: 

```sh
flyctl deploy --remote-only
```

A potential improvement would be to set up a simple CI/CD with tests using Github actions.

## API High-Level Design

### The Phoenix Application

Phoenix is a batteries-included web application framework. This Phoenix project is extremely lean as it is only used as an interfacing layer to connect the web and mobile clients with the core OTP application.

**This API does not**:

- Serve web pages
- Expose JSON REST APIs
- Host static assets
- Orchestrate authentication and authorization
- Declare and maintain data through DB connection and schema

All the above features were excluded when I first created this project. No unused code is there.

The only used feature from this framework is the Phoenix Channels. It provides excellent support for real-time communication through websockets.

The `UserSocket` module is the only exposed endpoint to serve websocket requests. It supports the following three channels:

- **Onboarding Channel**: The `onboarding` channel helps to onboard the motorcyclist into the application. At this stage, the onboarding flow has a single step - allowing the user to generate a unique mnemonic to be the identifier for the live tracking session.
- **Tracking Channel**: The `tracking:*` channel is a write-only channel that accepts live-location updates from the web and mobile clients. The `*` part in the channel name is the selected mnemonic in the onboarding step.
- **Following Channel**: The `following:*` channel is read-only. The web client uses it to live track a session. The `*` part in the channel name is the selected mnemonic in the onboarding step.

The reason for having multiple channels instead of a single channel like `omw:{onboarding,tracking,following}:*` is mainly for code organization.

### The OTP Application

[OTP](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html) is a set of tools and practices to help build scalable and fault-tolerant distributed systems in the application layer.

This project has three main modules:

- **Dictionary:** This module is responsible for providing mnemonics. Each mnemonic can be used as a potential unique identifier for an upcoming live tracking session. It is built using the `Agent` OTP Elixir module since it is has a simple read-only API.
- **Tracker:** This module is responsible for creating and maintaining the live tracking sessions. It has a simple data structure called `Session` that holds the session id (the selected mnemonic), coordinates, speed, and heading of the tracked motorcycle. It is built using the `GenServer` OTP Elixir module since it requires a customized read and write interface as well as separating each session into its process. A `DynamicSupervisor` is used to create, monitor, and terminate each process.
- **Registry:** This module is in-memory key-value process storage that is responsible for holding a reference (the mnemonic) to the tracked session (the `pid` of the tracked session created by the `GenServer`). It currently lives inside the `tracker` module because I think, at this time, it is responsible for holding a reference to the tracked session (tightly coupled).

### Optimizations

Since each tracking session is an OTP process, there is potential for zombie processes of tracking sessions that are no longer used actively. To workaround that, the `terminate` callback in the `tracking:*` channel is implemented to ensure proper garbage collection for such processes. Once the motorcyclist's websocket connection is closed, the associated tracking process will self-terminate too.

