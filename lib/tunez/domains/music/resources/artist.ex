defmodule Tunez.Domains.Music.Resources.Artist do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Domains.Music,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "artists"
    repo Tunez.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    default_accept [:name, :biography]

    # create :compose do
    #   accept [:name, :biography]
    # end

    # update :update do
    #   accept [:name, :biography]
    # end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :biography, :string

    create_timestamp :created_at

    update_timestamp :updated_at do
      allow_nil? true
      default nil
    end
  end
end
