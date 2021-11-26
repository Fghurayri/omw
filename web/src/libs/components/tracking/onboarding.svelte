<script>
  import PurpleButton from "./buttons/purple.svelte";
  import BlueButton from "./buttons/blue.svelte";
  import Location from "./icons/location.svelte";
  import Refresh from "./icons/refresh.svelte";

  export let send;
  export let session;
</script>

<div class="flex flex-col items-center w-full space-y-8 font-bold">
  <p>
    {session ?? "loading.."}
  </p>
  <PurpleButton onClick={() => send("DONE_ONBOARDING")} text="start session" icon={Location} />
  <BlueButton onClick={() => send("GENERATE_NEW_SESSION_NAME")} text="change name" icon={Refresh} />
</div>
