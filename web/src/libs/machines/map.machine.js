import { createMachine, assign, sendParent } from "xstate";

const initialCoords = {
  longitude: 0,
  latitude: 0,
  speed: 0,
  heading: 0
};

export const mapMachine = createMachine({
  id: "mapMachine",
  context: {
    mapComponentRef: null,
    coords: initialCoords,
    direction: "",
    zoom: 1,
  },
  initial: "initializing",
  states: {
    initializing: {
      entry: "notifyParentActorReady",
      exit: "notifyParentMapReady",
      on: {
        "MAP_READY": {
          target: "waitingForLocation",
          actions: "saveMapComponentRef",
        },
      }
    },
    waitingForLocation: {
      on: {
        "LOCATION_UPDATED": {
          target: "trackingLocation.hist", // persist latest state (following vs notFollowing)
          actions: ["saveCoordsAndFigureDirection", "flyToLocation"],
        },
      },
    },
    trackingLocation: {
      id: "trackingLocation",
      initial: "notFollowing",
      states: {
        notFollowing: {
          on: {
            "LOCK_CENTER_TRACKING": "following",
            "LOCATION_UPDATED": {
              actions: ["saveCoordsAndFigureDirection"],
            },
          },
        },
        following: {
          on: {
            "UNLOCK_CENTER_TRACKING": "notFollowing",
            "LOCATION_UPDATED": {
              actions: ["saveCoordsAndFigureDirection", "centerMapToNewCoords"],
            },
          },
        },
        hist: {
          type: "history",
        }
      },
      on: {
        "TERMINATED": {
          target: "waitingForLocation",
          actions: "resetCoordsAndDirectionAndMapZoom",
        }
      }
    },
  },
},
  {
    actions: {
      notifyParentActorReady: sendParent("ACTOR_READY"),
      notifyParentMapReady: sendParent("MAP_READY"),
      saveMapComponentRef: assign({
        mapComponentRef: (_ctx, ev) => ev.mapComponent,
      }),
      saveCoordsAndFigureDirection: assign({
        coords: (_ctx, ev) => ({
          ...ev.payload,
          speed: convertMetersPerSecondToMilesPerHour(ev.payload.speed),
        }),
        direction: (_ctx, ev) => calculateScooterIconDirection(ev.payload.heading),
      }),
      flyToLocation: (ctx, { payload }) => ctx.mapComponentRef.flyTo({
        center: [payload.longitude, payload.latitude],
        zoom: 15,
        speed: 2.2,
      }),
      centerMapToNewCoords: (ctx, { payload }) => ctx.mapComponentRef.setCenter([
        payload.longitude,
        payload.latitude
      ]),
      resetCoordsAndDirectionAndMapZoom: assign({
        coords: initialCoords,
        zoom: 1,
        direction: "",
      }),
    },
  }
);


function convertMetersPerSecondToMilesPerHour(speed = 0) {
  return speed == null
    ? "?"
    : parseInt(speed * 2.23694);
}

function calculateScooterIconDirection(heading = 0) {
  return heading == null
    ? ""
    : heading >= 180
      ? `transform: rotateY(0deg) rotate(${heading + 90}deg);`
      : `transform: rotateY(-180deg) rotate(${-1 * heading + 90}deg);`;
}
