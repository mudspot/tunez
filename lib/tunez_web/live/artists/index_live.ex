defmodule TunezWeb.Live.Artists.IndexLive do
  use TunezWeb, :live_view

  require Logger

  alias Tunez.Domains.Music

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Artists")

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    query_text = Map.get(params, "q", "")
    sort_by = Map.get(params, "sort_by") |> validate_sort_by()
    page_params = AshPhoenix.LiveView.page_from_params(params, 12)

    {:ok, page} =
      query_text |> Music.search_artists(page: page_params, query: [sort_input: sort_by])

    socket =
      socket
      |> assign(:sort_by, sort_by)
      |> assign(:query_text, query_text)
      |> assign(:page, page)

    {:noreply, socket}
  end

  def artist_card(assigns) do
    ~H"""
    <div id={"artist-#{@artist.id}"} data-role="artist-card" class="relative mb-2">
      <.link navigate={~p"/artists/#{@artist.id}"}>
        <.cover_image />
      </.link>
    </div>
    <p>
      <.link
        navigate={~p"/artists/#{@artist.id}"}
        class="text-lg font-semibold"
        data-role="artist-name"
      >
        {@artist.name}
      </.link>
    </p>
    """
  end

  def artist_card_album_info(%{artist: %{album_count: 0}} = assigns), do: ~H""

  def artist_card_album_info(assigns) do
    ~H"""
    <span class="mt-2 text-sm leading-6 text-zinc-500">
      {@artist.album_count} {ngettext("album", "albums", @artist.album_count)},
      latest release {@artist.latest_album_year_released}
    </span>
    """
  end

  def pagination_links(assigns) do
    ~H"""
    <div
      :if={AshPhoenix.LiveView.prev_page?(@page) || AshPhoenix.LiveView.next_page?(@page)}
      class="flex justify-center pt-8 space-x-4"
    >
      <.button_link
        data-role="previous-page"
        kind="primary"
        inverse
        patch={~p"/?#{query_string(@page, @query_text, @sort_by, "prev")}"}
        disabled={!AshPhoenix.LiveView.prev_page?(@page)}
      >
        « Previous
      </.button_link>
      <.button_link
        data-role="next-page"
        kind="primary"
        inverse
        patch={~p"/?#{query_string(@page, @query_text, @sort_by, "next")}"}
        disabled={!AshPhoenix.LiveView.next_page?(@page)}
      >
        Next »
      </.button_link>
    </div>
    """
  end

  attr :query, :string, default: ""
  attr :rest, :global, include: ~w(method action phx-submit data-role)
  slot :inner_block, required: false

  def search_box(assigns) do
    ~H"""
    <form class="relative w-fit inline-block" {@rest}>
      <.icon name="hero-magnifying-glass" class="w-4 h-4 m-2 ml-3 absolute bg-base-content/50" />
      <input
        class="input input-bordered rounded-full input-sm pl-8 w-32 sm:w-48"
        name="query"
        value={@query}
      />
      {render_slot(@inner_block)}
    </form>
    """
  end

  def sort_changer(assigns) do
    assigns = assign(assigns, :options, sort_options())

    ~H"""
    <form data-role="artist-sort" class="hidden sm:inline" phx-change="change-sort">
      <.input
        label="sort by:"
        type="select"
        id="sort_by"
        name="sort_by"
        options={@options}
        value={@selected}
        class="px-2 py-0.5 !w-fit !inline-block pr-8 text-sm"
        container_class="!inline-block"
      />
    </form>
    """
  end

  defp sort_options do
    [
      {"recently updated", "-updated_at"},
      {"recently added", "-created_at"},
      {"name", "name"}
    ]
  end

  def validate_sort_by(key) do
    valid_keys = Enum.map(sort_options(), &elem(&1, 1))

    if key in valid_keys do
      key
    else
      List.first(valid_keys)
    end
  end

  defp remove_empty(params) do
    Enum.filter(params, fn {_key, val} -> val != "" end)
  end

  def handle_event("change-sort", %{"sort_by" => sort_by}, socket) do
    params = remove_empty(%{q: socket.assigns.query_text, sort_by: sort_by})
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  def handle_event("search", %{"query" => query}, socket) do
    params = remove_empty(%{q: query})
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  def query_string(page, query_text, sort_by, which) do
    case AshPhoenix.LiveView.page_link_params(page, which) do
      :invalid -> []
      list -> list
    end
    |> Keyword.put(:q, query_text)
    |> Keyword.put(:sort_by, sort_by)
    |> remove_empty()
  end
end
