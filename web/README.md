# Omw Web Client

![SvelteKit](https://res.cloudinary.com/fghurayri/image/upload/v1637940729/faisal.sh/lab/omw/web/sveltekit.png)

The main goal of this web application is to enable others to follow a motorcyclist's trip. A secondary goal is to provide a lite version of the mobile app that allows a motorcyclist to share their live location.

It is built using [SvelteKit](https://kit.svelte.dev), which is [Svelte's](https://svelte.dev) meta-framework to build rich and interactive web applications.

## Running Locally

If you have never run a SvelteKit application locally before, ensure you follow the [Get started](https://kit.svelte.dev/docs#introduction-getting-started) guide.

The run command from the root directory is: 

```sh
npm run dev
```

Then, the application should be running successfully on port `3000`.

## Deploying to Production

This project is deployed on [Vercel](https://vercel.com). To deploy a new version to production, simply push to the `main` branch, and Vercel will automatically kick-off the build and release process.

A potential improvement would be to set up a simple CI/CD with tests using Github actions.

## Web High-Level Design

There are two main parts of this web application. The first part is under the `routes/follow/:session` page. It is responsible for facilitating real-time session following. The second part is under the `routes/new` page. It is responsible for allowing the user to start and share a new tracking session.

Since this is a highly interactive web application, I have relied heavily on using state machines and the actor model for orchestrating the UI. The best library to do that is [XState](https://xstate.js.org/docs/).

Each page has a dedicated set of actors. However, there are two shared actor implementations:

- **Socket**: It is responsible for managing the lifecycle of the websocket connection. Moreover, it listens for requests to create subsequent children actors, where each child represents a stateful joined channel.
- **Channel**: It is responsible for facilitating real-time communication using the established websocket connection.

The SvelteKit part is to build an extremely simple UI with no logic other than firing events to the state machine.

### Follow Page

The goal of this page is to follow a live trip. 

![follow page actors](https://res.cloudinary.com/fghurayri/image/upload/v1637942105/faisal.sh/lab/omw/web/follow-actor.png)

In addition to the shared actor implementations, this page mainly has one more actor. The **Map** actor is responsible for holding a reference to the map component for later interactions. 

The supported features are:

- Allow the user to lock the tracking on the target. The map will re-center itself to the real-time location changes.
- Allow the user to unlock the tracking on the target by freely panning the map.
- Gracefully wait for location updates if the motorcyclist loses their internet connection.
- Intelligently remember between the last selected desired tracking option (lock vs unlock) if the location updates are recovered after a disconnection.
- Show the speed and direction if the motorcyclist is using the mobile application.

### Tracking Page

The goal of this page is to create a new tracking session.

![tracking page actors](https://res.cloudinary.com/fghurayri/image/upload/v1637942230/faisal.sh/lab/omw/web/track-actor.png)

In addition to the above actor implementations, this page mainly has one more actor. The **Geolocation** actor is responsible for orchestrating location permission and updates.

The supported features are:

- Allow the user to select a name for the upcoming live tracking session.
- Allow the user to start a live tracking session and copy the associated tracking link.


## Gotchas

There's a deployment to Vercel blocker when the `phoenix` package is imported via `node_modules`. To workaround that, I have copied the `phoenix` package's JS content into the project and imported it like any other local file.
