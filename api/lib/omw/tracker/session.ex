defmodule Omw.Tracker.Session do
  @derive Jason.Encoder
  defstruct [:slug, :longitude, :latitude, :speed, :heading]

  def new(slug) do
    %__MODULE__{
      slug: slug,
      longitude: nil,
      latitude: nil,
      speed: nil,
      heading: nil
    }
  end

  def update(session, new_info) do
    %__MODULE__{
      session
      | longitude: new_info["longitude"],
        latitude: new_info["latitude"],
        speed: new_info["speed"],
        heading: new_info["heading"]
    }
  end
end
