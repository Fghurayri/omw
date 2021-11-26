<script>
  import { Map } from "@beyonk/svelte-mapbox";

  import Marker from "./marker.svelte";
  import Follow from "../buttons/follow.svelte";
  import Following from "../text/following.svelte";
  import Waiting from "../text/waiting.svelte";
  import { envVariables } from "../../../../libs/variables";

  export let service;

  let mapComponent;

  let center = {
    lat: $service.context.coords.latitude,
    lng: $service.context.coords.longitude,
  };
</script>

<div class="h-screen w-screen">
  <div class="absolute left-2 top-2 z-10">
    {#if $service.matches("trackingLocation.notFollowing")}
      <Follow onClick={() => service.send("LOCK_CENTER_TRACKING")} />
    {:else if $service.matches("trackingLocation.following")}
      <Following />
    {:else if $service.matches("waitingForLocation")}
      <Waiting />
    {/if}
  </div>

  <Map
    accessToken={envVariables.MAPBOX_KEY}
    bind:this={mapComponent}
    on:ready={() => service.send({ type: "MAP_READY", mapComponent })}
    on:drag={() => service.send("UNLOCK_CENTER_TRACKING")}
    {center}
    zoom={1}
    options={{ scrollZoom: true }}
  >
    <Marker
      isTracking={$service.matches("trackingLocation")}
      lat={$service.context.coords.latitude}
      lng={$service.context.coords.longitude}
      speed={$service.context.coords.speed}
      direction={$service.context.direction}
    />
  </Map>
</div>
