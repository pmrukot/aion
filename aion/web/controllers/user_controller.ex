defmodule Aion.UserController do
  use Aion.Web, :controller
  alias Guardian.Plug

  plug(Plug.EnsureAuthenticated, handler: __MODULE__)

  def get_user_info(conn, _params) do
    user = Plug.current_resource(conn)
    render(conn, "user.json", user: user)
  end

  def unauthenticated(conn, _params) do
    Errors.unauthenticated(conn)
  end
end
