defmodule HelloHipsterStackWeb.UserView do
  use HelloHipsterStackWeb, :view
  # require Logger


  def render("index.json", %{data: users}) do
    %{
      data: Enum.map(users, &user_json/1)
    }
  end

  def render("user.json", %{user: user}) do
    %{data: user_json(user) }
  end

  defp user_json(user) do
    %{
      display_name: user.display_name,
      email: user.email
      # inserted_at: user.inserted_at,
      # updated_at: user.updated_at
    }
  end
end
