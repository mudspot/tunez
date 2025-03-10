defmodule TunezWeb.Live.Artists.FormLive do
  use TunezWeb, :live_view

  alias Tunez.Domains.Music, as: MusicDomain

  def mount(%{"id" => id} = _params, _session, socket) do
    {:ok, artist} = MusicDomain.get_artist(id)
    form = MusicDomain.form_to_update_artist(artist)

    socket =
      socket
      |> assign(:form, to_form(form))
      |> assign(:page_title, "Updating #{artist.name}")

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    form = MusicDomain.form_to_create_artist()

    socket =
      socket
      |> assign(:form, to_form(form))
      |> assign(:page_title, "New Artist")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header>
      <.h1>{@page_title}</.h1>
    </.header>

    <.simple_form
      :let={form}
      id="artist_form"
      as={:form}
      for={@form}
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={form[:name]} label="Name" />
      <.input field={form[:biography]} type="textarea" label="Biography" />
      <:actions>
        <.button type="primary">Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  def handle_event("validate", %{"form" => form_data}, socket) do
    {:noreply, socket |> update(:form, &AshPhoenix.Form.validate(&1, form_data))}
  end

  def handle_event("save", %{"form" => form_data}, %{assigns: %{form: form}} = socket) do
    case AshPhoenix.Form.submit(form, params: form_data) do
      {:ok, _artist} ->
        socket =
          socket
          |> put_flash(:info, "Artist saved successfully")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, form} ->
        socket =
          socket
          |> put_flash(:error, "Could not save artist data")
          |> assign(:form, form)

        {:noreply, socket}
    end
  end
end
