class CocinaChannel < ApplicationCable::Channel
  def subscribed
    stream_from "cocina_channel"
  end

  def unsubscribed
  end
end
