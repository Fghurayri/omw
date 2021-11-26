<script>
  import { Map } from "@beyonk/svelte-mapbox";
  import { envVariables } from "../../../../libs/variables";
  import TrackingMarker from "./marker.svelte";

  export let session;
  export let lat;
  export let lng;
  $: center = { lat, lng };
</script>

<div class="w-52 h-48 md:w-64 lg:w-80 xl:w-96">
  <Map accessToken={envVariables.MAPBOX_KEY} {center} zoom={16} options={{ interactive: false }}>
    <TrackingMarker {lat} {lng} {session} />
  </Map>
</div>
