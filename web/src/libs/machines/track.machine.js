import { createMachine, assign, send, spawn, interpret } from "xstate";
import { geolocationMachine } from "./geolocation.machine";
import { socketMachine } from "./socket.machine";

const SESSION_LOCAL_STORAGE_KEY = "omw-session-id";

const trackMachine = createMachine({
  id: "trackMachine",
  context: { session: null, geolocationActorRef: null, socketActorRef: null },
  initial: "initializing",
  states: {
    initializing: {
      initial: "idle",
      states: {
        idle: {
          on: {
            "START_CHECK_IN": "checkingIn",
          },
        },
        checkingIn: {
          entry: "getSessionFromLocalStorage",
          initial: "acquiringLocation",
          states: {
            acquiringLocation: {
              entry: "spawnGeolocationActor",
              on: {
                "LOCATION_UPDATED": "connectingSocket",
              },
            },
            connectingSocket: {
              entry: "spawnSocketActor",
              on: {
                "SOCKET_CONNECTED": [
                  { target: "#tracking", cond: "isAlreadyOnboarded" },
                  "#onboarding",
                ],
              },
            },
          },
        },
      },
    },
    onboarding: {
      id: "onboarding",
      entry: "askSocketToJoinOnboardingChannel",
      exit: "askSocketToLeaveOnboardingChannel",
      initial: "initializing",
      states: {
        initializing: {
          on: {
            "CHANNEL_JOINED": "selectingSessionName"
          },
        },
        selectingSessionName: {
          entry: "generateNewSessionName",
          on: {
            "GENERATE_NEW_SESSION_NAME": {
              actions: "generateNewSessionName"
            },
            "NEW_SESSION_NAME_GENERATED": {
              actions: "saveSessionNameToContext"
            },
            "DONE_ONBOARDING": {
              target: "#tracking",
              actions: "persistSessionInLocalStorage"
            }
          }
        },
      },
    },
    tracking: {
      id: "tracking",
      entry: "askSocketToJoinTrackingChannel",
      exit: "askSocketToLeaveTrackingChannel",
      initial: "initializing",
      states: {
        initializing: {
          on: {
            "CHANNEL_JOINED": "syncingLocationChanges"
          }
        },
        syncingLocationChanges: {
          on: {
            "LOCATION_UPDATED": {
              actions: "syncNewLocation"
            },
            "RESET": {
              actions: "clearSessionFromLocalStorage",
              target: "#onboarding"
            }
          }
        },
      }
    },
  },
},
  {
    guards: {
      isAlreadyOnboarded: (ctx, _ev) => isAlreadyOnboarded(ctx.session),
    },
    actions: {
      spawnGeolocationActor: assign({
        geolocationActorRef: () => spawn(geolocationMachine, { sync: true })
      }),
      spawnSocketActor: assign({
        socketActorRef: () => spawn(socketMachine)
      }),
      askSocketToJoinOnboardingChannel: send(
        {
          type: "JOIN_CHANNEL",
          topic: `onboarding`,
          listener: onboardingListener
        },
        { to: (ctx) => ctx.socketActorRef }
      ),
      askSocketToLeaveOnboardingChannel: send(
        {
          type: "LEAVE_CHANNEL",
          topic: "onboarding",
        },
        { to: (ctx) => ctx.socketActorRef }
      ),
      generateNewSessionName: send(
        {
          type: "PUSH",
          topic: "onboarding",
          message: "GENERATE_NEW_SESSION_NAME",
          payload: {},
          notifyBackId: "NEW_SESSION_NAME_GENERATED"
        },
        { to: (ctx) => ctx.socketActorRef },
      ),
      askSocketToJoinTrackingChannel: send(
        (ctx, _ev) => ({
          type: "JOIN_CHANNEL",
          topic: `tracking:${ctx.session}`,
          listener: trackingListener
        }),
        { to: (ctx) => ctx.socketActorRef }
      ),
      askSocketToLeaveTrackingChannel: send(
        (ctx, _ev) => ({
          type: "LEAVE_CHANNEL",
          topic: `tracking:${ctx.session}`,
        }),
        { to: (ctx) => ctx.socketActorRef }
      ),
      syncNewLocation: send(
        (ctx, ev) => ({
          type: "PUSH",
          topic: `tracking:${ctx.session}`,
          message: "NEW_COORDS",
          payload: ev.coords,
        }),
        { to: (ctx) => ctx.socketActorRef },
      ),
      saveSessionNameToContext: assign({
        session: (_ctx, ev) => ev.payload
      }),
      clearSessionFromContext: assign({
        session: null,
      }),
      getSessionFromLocalStorage: assign({
        session: () => window.localStorage.getItem(SESSION_LOCAL_STORAGE_KEY)
      }),
      persistSessionInLocalStorage: (ctx, _ev) => window.localStorage.setItem(SESSION_LOCAL_STORAGE_KEY, ctx.session),
      clearSessionFromLocalStorage: (_ctx, _ev) => window.localStorage.clear(),
    },
  }
);


function onboardingListener(ctx, _ev) {
  return function(sendBack, onReceive) {
    onReceive(ev => {
      if (ev.type == "PUSH") {
        ctx.channel.push(ev.message, ev.payload).receive("ok", (payload) => {
          sendBack({
            type: "RECEIVE",
            notifyBackId: ev.notifyBackId,
            payload
          })
        })
      }
    });
  }
};

function trackingListener(ctx, _ev) {
  return function(_sendBack, onReceive) {
    onReceive(ev => {
      if (ev.type === "PUSH") {
        ctx.channel.push(ev.message, ev.payload);
      }
    });
  }
};


function isAlreadyOnboarded(session) {
  return typeof session === 'string' &&
    session.length > 0 &&
    session.match(/\w+\-\w+/)
}

export const trackService = interpret(trackMachine).start();
