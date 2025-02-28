defmodule Tunez.Domains.Music.Resources.Artist do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Domains.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshCloak]

  postgres do
    table "artists"
    repo Tunez.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "artists_name_gin_index", using: "GIN"
    end
  end

  cloak do
    # the vault to use to encrypt them
    vault(Tunez.Security.Vault)

    # the attributes to encrypt
    attributes([:secret_nickname])

    # This is just equivalent to always providing `load: fields` on all calls
    decrypt_by_default([:secret_nickname])
  end

  actions do
    defaults [:create, :read, :destroy]

    default_accept [:name, :biography]

    # create :compose do
    #   accept [:name, :biography]
    # end

    update :atomic_test do
      require_atomic? false
      change set_attribute(:name, "Resonanz")

      change set_attribute(
               :biography,
               "Formed in the vibrant and tumultuous Berlin music scene of the early 1990s, Resonanz quickly carved out a niche for themselves within the Neue Deutsche Härte movement, drawing comparisons to pioneering acts like Rammstein. Known for their heavy guitar riffs, electronic synth textures, and commanding vocals, Resonanz combines the aggressive force of metal with the industrial sounds that echo the gritty reality of post-reunification Germany.\n\nTheir lyrics, delivered in a mix of German and occasionally English, explore themes of societal issues, personal strife, and the human condition, often presented through powerful, metaphorical imagery. Resonanz's stage presence is intense and theatrical, featuring elaborate lighting, pyrotechnics, and a stark, industrial aesthetic that complements their sonic assault."
             )
    end

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

    read :with_special_albums do
      argument :year_released, :integer

      filter expr(
               fragment(
                 "id = ANY(SELECT artist_id FROM albums WHERE year_released = ?)",
                 ^arg(:year_released)
               )
             )
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :biography, :string

    attribute :secret_nickname, :string

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
