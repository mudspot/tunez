defmodule Tunez.Domains.Music do
  use Ash.Domain,
    otp_app: :tunez

  resources do
    resource Tunez.Domains.Music.Resources.Artist do
      define :list_artists, action: :read
      define :create_artist, action: :create
      define :get_artist, get_by: :id, action: :read
      define :update_artist, action: :update
      define :destroy_artist, action: :destroy
    end
  end
end
