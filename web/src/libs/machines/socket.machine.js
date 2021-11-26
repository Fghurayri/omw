import * as Phoenix from "phoenix";
import { assign, createMachine, forwardTo, send, sendParent, spawn } from "xstate";
import { envVariables } from "../variables";
import { createChannelMachine } from "./channel.machine";

export const socketMachine = createMachine({
  id: "socketMachine",
  context: { socket: null, channelsActorRefs: {} },
  initial: "connecting",
  states: {
    connecting: {
      invoke: {
        id: "connectSocket",
        src: "connectSocket",
      },
      on: {
        "SOCKET_CONNECTED": {
          actions: "saveSocket",
          target: "connected",
        },
      }
    },
    connected: {
      entry: "forwardToParent",
      initial: "ready",
      states: {
        ready: {
          on: {
            "JOIN_CHANNEL": {
              actions: "spawnChannelActor",
              target: "joiningChannel",
            },
            "LEAVE_CHANNEL": {
              target: "leavingChannel",
            },
            "PUSH": {
              actions: "forwardToChannel",
            },
            "RECEIVE": {
              actions: "notifyParentResponseReceived"
            }
          }
        },
        joiningChannel: {
          entry: "askChannelToJoin",
          on: {
            "CHANNEL_JOINED": {
              target: "ready",
              actions: "forwardToParent"
            }
          }
        },
        leavingChannel: {
          entry: "askChannelToLeave",
          on: {
            "CHANNEL_LEFT": "ready"
          },
          exit: "stopAndDeleteChannelActor",
        },
      },
    },
  }
},
  {
    actions: {
      saveSocket: assign({
        socket: (_ctx, ev) => ev.socket
      }),
      forwardToParent: sendParent((_ctx, ev) => ev),
      spawnChannelActor: assign({
        channelsActorRefs: (ctx, ev) => {
          return {
            ...ctx.channelsActorRefs,
            [ev.topic]: spawn(createChannelMachine(ev.listener))
          }
        }
      }),
      askChannelToJoin: send(
        ({ socket }, { topic, payload = {} }) => ({
          type: "JOIN_CHANNEL",
          socket,
          topic,
          payload
        }),
        { to: (ctx, ev) => ctx.channelsActorRefs[ev.topic] }
      ),
      askChannelToLeave: send(
        ({ socket }, { topic, payload = {} }) => ({
          type: "LEAVE_CHANNEL",
          socket,
          topic,
          payload
        }),
        { to: (ctx, ev) => ctx.channelsActorRefs[ev.topic] }
      ),
      stopAndDeleteChannelActor: assign({
        channelsActorRefs: (ctx, ev) => {
          ctx.channelsActorRefs[ev.topic].stop();
          delete ctx.channelsActorRefs[ev.topic]
          return ctx.channelsActorRefs
        }
      }),
      forwardToChannel: forwardTo(
        (ctx, ev) => ctx.channelsActorRefs[ev.topic],
      ),
      notifyParentResponseReceived: sendParent((_ctx, ev) => ({
        type: ev.notifyBackId,
        payload: ev.payload
      })),
    },
    services: {
      connectSocket: (_ctx, _ev) => (sendBack) => {
        let socket = new Phoenix.Socket(envVariables.WS_URL, {})
        socket.connect()
        socket.onOpen(() => sendBack({ type: "SOCKET_CONNECTED", socket }))
      }
    }
  }
)

