import { createMachine, sendParent, assign } from "xstate";

export const geolocationMachine = createMachine({
  id: "geolocationMachine",
  context: { location: null },
  invoke: {
    id: "getLocation",
    src: "getLocation",
  },
  on: {
    "LOCATION_UPDATED": {
      actions: ["forwardToParent", "saveLocationToContext"],
    }
  }
},
  {
    actions: {
      forwardToParent: sendParent((_ctx, ev) => ev),
      saveLocationToContext: assign({
        location: (_ctx, ev) => ev.coords,
      }),
    },
    services: {
      getLocation: (_ctx, _ev) => (sendBack) => {
        const watchId = navigator.geolocation.watchPosition(
          ({ coords }) => sendBack({
            type: "LOCATION_UPDATED",
            coords: {
              latitude: coords.latitude,
              longitude: coords.longitude,
              speed: coords.speed,
              heading: coords.heading
            }
          }),
          () => sendBack("LOCATION_DENIED"),
          { enableHighAccuracy: true }
        )

        return () => navigator.geolocation.clearWatch(watchId);
      }
    }
  });
