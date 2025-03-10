defmodule TunezWeb.Live.Albums.FormLive do
  use TunezWeb, :live_view

  alias Tunez.Domains.Music, as: MusicDomain

  def mount(%{"id" => id} = _params, _session, socket) do
    {:ok, album} = MusicDomain.get_album(id, load: [:artist])

    form = MusicDomain.form_to_update_album(album)

    socket =
      socket
      |> assign(form: to_form(form), artist: album.artist)
      |> assign(:page_title, "New Album")

    {:ok, socket}
  end

  def mount(%{"artist_id" => artist_id} = _params, _session, socket) do
    {:ok, artist} = MusicDomain.get_artist(artist_id)

    form =
      MusicDomain.form_to_create_album(
        transform_params: fn _form, params, _context ->
          Map.put(params, "artist_id", artist.id)
        end
      )

    socket =
      socket
      |> assign(form: to_form(form), artist: artist)
      |> assign(:page_title, "New Album")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header>
      <.h1>{@page_title}</.h1>
    </.header>

    <.simple_form
      :let={form}
      id="album_form"
      as={:form}
      for={@form}
      phx-change="validate"
      phx-submit="save"
    >
      <.input name="artist_id" label="Artist" value={@artist.name} disabled />
      <div class="sm:flex gap-8 space-y-8 md:space-y-0">
        <div class="sm:w-3/4"><.input field={form[:name]} label="Name" /></div>
        <div class="sm:w-1/4">
          <.input field={form[:year_released]} label="Year Released" type="number" />
        </div>
      </div>
      <.input field={form[:cover_image_url]} label="Cover Image URL" />

      <:actions>
        <.button type="primary">Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  def track_inputs(assigns) do
    ~H"""
    <.h2>Tracks</.h2>

    <table class="table">
      <thead>
        <tr>
          <th class="px-0">Number</th>
          <th>Name</th>
          <th class="px-0" colspan="2">Duration (M:SS)</th>
        </tr>
      </thead>
      <tbody>
        <.inputs_for :let={track_form} field={@form[:tracks]}>
          <tr>
            <td class="align-top px-0 w-20">
              <.input field={track_form[:number]} type="number" />
            </td>
            <td class="align-top">
              <.input field={track_form[:name]} />
            </td>
            <td class="align-top px-0 w-24">
              <.input field={track_form[:duration]} />
            </td>
            <td class="align-top w-12 pt-5">
              <.button_link
                phx-click="remove-track"
                phx-value-path={track_form.name}
                kind="error"
                size="xs"
                class="mt-0.5"
              >
                <.icon name="hero-trash" class="w-5 h-5" />
              </.button_link>
            </td>
          </tr>
        </.inputs_for>
      </tbody>
    </table>

    <.button_link phx-click="add-track" kind="primary" size="sm" inverse>
      Add Track
    </.button_link>
    """
  end

  def handle_event("validate", %{"form" => form_data}, socket) do
    {:noreply, socket |> update(:form, &AshPhoenix.Form.validate(&1, form_data))}
  end

  def handle_event("save", %{"form" => form_data}, %{assigns: %{form: form}} = socket) do
    case AshPhoenix.Form.submit(form, params: form_data) do
      {:ok, _album} ->
        socket =
          socket
          |> put_flash(:info, "Album saved successfully")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, form} ->
        socket =
          socket
          |> put_flash(:error, "Could not save album data")
          |> assign(:form, form)

        {:noreply, socket}
    end
  end
end
