<script>
  export let onClick;
  export let text;
  export let icon;
</script>

<button
  on:click={onClick}
  class={`bg-red-500 hover:bg-red-700 text-white py-2 px-4 rounded inline-flex justify-center items-center w-56`}
>
  <svelte:component this={icon} />
  <span class="pl-2">{text}</span>
</button>

