module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player, :player_id
    def connect
      reject_unauthorized_connection unless request.params[:name]
      self.current_player = request.params[:name]
      self.player_id = SecureRandom.uuid
    end
  end
end
