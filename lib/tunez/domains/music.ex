defmodule Tunez.Domains.Music do
  use Ash.Domain,
    otp_app: :tunez,
    extensions: [AshPhoenix]

  resources do
    resource Tunez.Domains.Music.Resources.Artist do
      define :list_artists, action: :read
      define :create_artist, action: :create
      define :get_artist, get_by: :id, action: :read
      define :update_artist, action: :update
      define :destroy_artist, action: :destroy
      define :search_artists, action: :search, args: [:query]
    end

    resource Tunez.Domains.Music.Resources.Album do
      define :create_album, action: :create
      define :get_album, get_by: :id, action: :read
      define :update_album, action: :update
      define :destroy_album, action: :destroy
    end
  end
end
