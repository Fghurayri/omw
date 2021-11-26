<script>
  import { page } from "$app/stores";
  import { onMount } from "svelte";

  import Map from "../../libs/components/following/map/map.svelte";
  import { followerService } from "../../libs/machines/follow.machine";

  const { session } = $page.params;

  onMount(() => {
    followerService.send({
      type: "SAVE_SESSION_NAME",
      session,
    });
  });
</script>

{#if $followerService.matches("following")}
  <Map service={$followerService.context.mapActorRef} />
{/if}
