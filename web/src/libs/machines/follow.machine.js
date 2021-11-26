import { assign, createMachine, interpret, spawn, send, forwardTo } from "xstate";
import { mapMachine } from "./map.machine";
import { socketMachine } from "./socket.machine";

const followMachine = createMachine({
  id: "followMachine",
  context: { session: null, socketActorRef: null, mapActorRef: null },
  initial: "initializing",
  states: {
    initializing: {
      id: "initializing",
      initial: "gettingSessionName",
      states: {
        gettingSessionName: {
          on: {
            SAVE_SESSION_NAME: {
              actions: "saveSessionName",
              target: "initializingSocket"
            },
          }
        },
        initializingSocket: {
          entry: "spawnSocketActor",
          on: {
            "SOCKET_CONNECTED": "initializingChannel"
          }
        },
        initializingChannel: {
          entry: "askSocketToJoinChannel",
          on: {
            "CHANNEL_JOINED": "#following"
          }
        },
      }
    },
    following: {
      id: "following",
      entry: "spawnMapActor",
      initial: "initializing",
      states: {
        initializing: {
          initial: "initializingActor",
          states: {
            initializingActor: {
              on: {
                "ACTOR_READY": "initializingMapComponent"
              }
            },
            initializingMapComponent: {
              on: {
                "MAP_READY": "#following.ready",
              }
            },
          },
        },
        ready: {
          on: {
            "LOCATION_UPDATED": {
              actions: "forwardToMapActor",
            },
            "TERMINATED": {
              actions: "forwardToMapActor",
            },
          }
        },
      },
    },
  },
},
  {
    actions: {
      saveSessionName: assign({
        session: (_ctx, ev) => ev.session
      }),
      spawnSocketActor: assign({
        socketActorRef: () => spawn(socketMachine)
      }),
      spawnMapActor: assign({
        mapActorRef: () => spawn(mapMachine, { sync: true })
      }),
      forwardToMapActor: forwardTo(
        (ctx, _ev) => ctx.mapActorRef,
      ),
      askSocketToJoinChannel: send(
        (ctx) => ({
          type: "JOIN_CHANNEL",
          topic: `following:${ctx.session}`,
          listener: followListener
        }),
        { to: (ctx) => ctx.socketActorRef }
      ),
    }
  });


export const followerService = interpret(followMachine).start();

function followListener(ctx, _ev) {
  return function(sendBack, _onReceive) {
    ctx.channel.on("NEW_COORDS", (coords) => {
      sendBack({ type: "RECEIVE", payload: coords, notifyBackId: "LOCATION_UPDATED" })
    });
    ctx.channel.on("TERMINATED", () => {
      sendBack({ type: "RECEIVE", payload: {}, notifyBackId: "TERMINATED" })
    });
  }
}
