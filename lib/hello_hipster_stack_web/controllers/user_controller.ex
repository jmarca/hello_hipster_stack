defmodule HelloHipsterStackWeb.UserController do
  use HelloHipsterStackWeb, :controller
  require Logger

  alias HelloHipsterStack.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", data: users)
  end

end
