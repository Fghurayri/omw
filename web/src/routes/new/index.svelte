<script>
  import { onMount } from "svelte";

  import { trackService } from "../../libs/machines/track.machine";
  import Trip from "../../libs/components/tracking/trip.svelte";
  import Onboarding from "../../libs/components/tracking/onboarding.svelte";
  import Indicator from "../../libs/components/tracking/indicator.svelte";
  import Alert from "../../libs/components/tracking/alert.svelte";

  onMount(() => {
    trackService.send("START_CHECK_IN");
  });
</script>

<div class="h-screen bg-gray-200 flex flex-col items-center justify-center text-gray-700">
  <Alert />

  <div
    class="relative h-[28rem] w-4/5 md:w-2/5 bg-white rounded-xl shadow-md flex items-center justify-center"
  >
    <div class="absolute top-4 left-4 z-10">
      <Indicator state={$trackService.toStrings()[0]} />
    </div>
    {#if $trackService.matches("initializing")}
      <p>initializing...</p>
    {/if}

    {#if $trackService.matches("onboarding")}
      <Onboarding session={$trackService.context.session} send={trackService.send} />
    {/if}

    {#if $trackService.matches("tracking")}
      <Trip
        session={$trackService.context.session}
        send={trackService.send}
        location={$trackService.context.geolocationActorRef}
      />
    {/if}
  </div>
</div>
