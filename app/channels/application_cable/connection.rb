module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player
    def connect
      reject_unauthorized_connection unless request.params[:name]
      self.current_player = request.params[:name]
    end
  end
end
