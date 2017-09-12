defmodule HelloHipsterStackWeb.UserController do
  use HelloHipsterStackWeb, :controller
  require Logger

  alias HelloHipsterStack.Accounts

  plug :scrub_params, "data" when action in [:create, :update]

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

  def update(conn, %{"id" => id, "data" => %{"attributes" => user_params}}) do
    user = Accounts.get_user!(id)
    # user = Guardian.Plug.current_resource(conn)

    # Logger.error fn -> "in update, user params = #{user_params["display_name"]} and other stuff" end

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        render(conn, "show.json", data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render( HelloHipsterStackWeb.ErrorView, "error.json", changeset: changeset)
    end
  end

end
