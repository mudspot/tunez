defmodule Tunez.Domains.Music.Resources.Artist do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Domains.Music,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "artists"
    repo Tunez.Repo
    
    custom_indexes do
      index "name gin_trgm_ops", name: "artists_name_gin_index", using: "GIN"
    end
  end

  actions do
    defaults [:create, :read, :destroy]

    default_accept [:name, :biography]

    # create :compose do
    #   accept [:name, :biography]
    # end

    update :update do
      accept [:name, :biography]
      require_atomic? false

      change Tunez.Domains.Music.Changes.UpdatePreviousNames,
        where: [changing(:name)]
    end
    
    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end
      
      filter expr(contains(name, ^arg(:query)))
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :biography, :string

    attribute :previous_names, {:array, :string}, do: default([])

    create_timestamp :created_at

    update_timestamp :updated_at do
      allow_nil? true
      default nil
    end
  end

  relationships do
    has_many :albums, Tunez.Domains.Music.Resources.Album
  end
end
