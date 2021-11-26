<script>
  import { Marker } from "@beyonk/svelte-mapbox";

  export let isTracking;
  export let lat;
  export let lng;
  export let speed;
  export let direction;
</script>

<Marker {lat} {lng} popup={false}>
  {#if isTracking}
    <div class="p-2 rounded-full bg-white font-bold">
      {speed} mph
    </div>
    <p class="text-4xl" style={direction}>🛵</p>
  {/if}
</Marker>
