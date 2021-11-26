import { assign, createMachine, forwardTo, sendParent } from "xstate";

export const createChannelMachine = (listener) => createMachine({
  id: "channelMachine",
  context: {
    channel: null
  },
  initial: "initializing",
  states: {
    initializing: {
      on: {
        "JOIN_CHANNEL": "joiningChannel"
      }
    },
    joiningChannel: {
      invoke: {
        id: "joiningChannel",
        src: "joinChannel",
      },
      on: {
        "CHANNEL_JOINED": {
          target: "joined",
          actions: ["saveChannel", "forwardToParent"]
        },
      },
    },
    joined: {
      invoke: {
        id: "listener",
        src: "setupListener",
      },
      on: {
        "PUSH": {
          actions: "forwardToListener"
        },
        "RECEIVE": {
          actions: "forwardToParent"
        },
        "LEAVE_CHANNEL": "leavingChannel",
      },
    },
    leavingChannel: {
      invoke: {
        id: "leavingChannel",
        src: "leaveChannel",
      },
      on: {
        "CHANNEL_LEFT": "channelLeft",
      },
    },
    channelLeft: {
      entry: "forwardToParent",
      type: "final"
    },
  }
},
  {
    actions: {
      forwardToListener: forwardTo("listener"),
      forwardToParent: sendParent((_ctx, ev) => ev),
      saveChannel: assign({
        channel: (_ctx, ev) => ev.channel
      })
    },
    services: {
      joinChannel: (_ctx, ev) => (sendBack) => {
        let channel = ev.socket.channel(ev.topic, ev.payload)
        channel.join()
          .receive(
            "ok",
            () => sendBack({
              type: "CHANNEL_JOINED",
              channel
            })
          )
      },
      leaveChannel: (ctx, ev) => (sendBack) => {
        const { channel } = ctx;
        channel.leave()
          .receive(
            "ok",
            () => sendBack({
              type: "CHANNEL_LEFT",
              topic: ev.topic
            })
          )
      },
      setupListener: listener,
    }
  });
