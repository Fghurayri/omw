<script>
  export let state;
</script>

{#if state === "initializing"}
  <span class="flex h-3 w-3">
    <span
      class="animate-ping absolute inline-flex h-full w-full rounded-full bg-yellow-400 opacity-75"
    />
    <span class="relative inline-flex rounded-full h-3 w-3 bg-yellow-500" />
  </span>
{/if}
{#if state === "onboarding"}
  <span class="flex h-3 w-3">
    <span
      class="animate-ping absolute inline-flex h-full w-full rounded-full bg-purple-400 opacity-75"
    />
    <span class="relative inline-flex rounded-full h-3 w-3 bg-purple-500" />
  </span>
{/if}
{#if state === "tracking"}
  <span class="flex h-3 w-3">
    <span
      class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"
    />
    <span class="relative inline-flex rounded-full h-3 w-3 bg-green-500" />
  </span>
{/if}
