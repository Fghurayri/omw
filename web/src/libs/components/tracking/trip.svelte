<script>
  import PurpleButton from "./buttons/purple.svelte";
  import RedButton from "./buttons/red.svelte";
  import Clipboard from "./icons/clipboard.svelte";
  import Trash from "./icons/trash.svelte";
  import TrackingMap from "./map/map.svelte";

  export let session;
  export let send;
  export let location;
</script>

<div class="flex flex-col items-center w-full space-y-8 font-bold">
  <div>
    <TrackingMap
      {session}
      lat={location.state.context.location.latitude}
      lng={location.state.context.location.longitude}
    />
  </div>
  <PurpleButton
    onClick={async () =>
      await navigator.clipboard.writeText(`https://omw.lab.faisal.sh/follow/${session}`)}
    text="copy url"
    icon={Clipboard}
  />
  <RedButton onClick={() => send("RESET")} text="reset session" icon={Trash} />
</div>
