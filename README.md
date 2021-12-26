# Omw

![demo](/web/static/demo.gif)

This monorepo holds all the building blocks for the Omw application. The main goal of this application is to scratch my own itch and get a feeling for building non-CRUD based applications using a set of tools that I have been learning.

I have built it using unconventional practices (like the actor model) and tools (like Svelte with SvelteKit, Dart with Flutter, and Elixir with Phoenix).

I have published two blog posts on it:

- [Why Elixir is a Cool and Practical Langauge](https://faisal.sh/posts/why-elixir-is-cool-and-practical-language)
- [Following The Actor Model with XState and Elixir](https://faisal.sh/posts/following-the-actor-model-with-xstate-and-elixir)

This monorepo have three main parts:

- `/api`: The backend application is built using the Phoenix framework to interface with an embedded OTP application. The main goal is to facilitate the real-time tracking of motorcycling trips between the rider and the follower(s).
- `/mobile`: The mobile application is built using Flutter to allow the rider to share their real-time location with others.
- `/web`: The web application is built using SvelteKit to allow others to view a real-time tracking session.

Each folder will contain more detailed documantion.
