<script>
  import { Marker } from "@beyonk/svelte-mapbox";

  export let session;
  export let lat;
  export let lng;
</script>

<Marker {lat} {lng} popup={false}>
  <div class="p-2 rounded-full bg-white text-gray-600 font-bold -ml-4">
    {session}
  </div>
  <p class="text-3xl">🛵</p>
</Marker>
