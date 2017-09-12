defmodule HelloHipsterStackWeb.UserController do
  use HelloHipsterStackWeb, :controller
  require Logger

  alias HelloHipsterStack.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", data: users)
  end

  def show(conn, %{"id" => id}) do
    try do
      user = Accounts.get_user!(id)
      render conn, "show.json", data: user
    catch
      :error, message ->
        conn
        |> put_status(:bad_request)
        |> render( HelloHipsterStackWeb.ErrorView, "400.json", reason: message )
    end

  end

end
