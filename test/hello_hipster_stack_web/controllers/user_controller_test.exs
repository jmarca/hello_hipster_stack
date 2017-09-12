defmodule HelloHipsterStackWeb.UserControllerTest do
  use HelloHipsterStackWeb.ConnCase
  require Logger

  alias HelloHipsterStack.Accounts

  @user1_attrs %{email: "grobblefruit@kernel.org", display_name: "grobblefruit", password: "surf and skate"}

  @user2_attrs %{email: "coffee@coffee.org", display_name: "espresso", password: "daydream of coffee"}

  @update_attrs %{email: "falada@horsehead.org", display_name: "goose girl", password: "covered in tar and feathers"}

  @bad_attrs %{}

  setup do
    {:ok, user} = Accounts.create_user(@user1_attrs)
    Logger.debug fn -> "setup user, id is #{user.id}" end
    conn = build_conn()
    {:ok, conn: conn, user: user }
  end

  test "index/2 responds with all Users", %{conn: conn, user: user} do

    response = conn
    |> get(user_path(conn, :index))
    |> json_response(200)

    expected = %{
      "data" => [
        %{ "email" => user.email, "display_name" => user.display_name }
      ]
    }

    assert response == expected

  end

  describe "create/2" do
    test "Creates, and responds with a newly created user if attributes are valid"
    test "Returns an error and does not create a user if attributes are invalid"
  end

  describe "show/2" do
    test "Responds with a newly created user if the user is found", %{conn: conn, user: user} do
      response = conn
      |> get(user_path(conn, :show, user.id))
      |> json_response(200)

      expected = %{
        "data" =>
        %{ "email" => user.email, "display_name" => user.display_name }

      }

      assert response == expected
    end

    test "Responds with a message indicating user not found", %{conn: conn} do
      response = conn
      |> get(user_path(conn, :show, -1 ))
      |> json_response(400)

      expected = %{
        "errors" => "Resource not found"
      }

      assert response == expected
    end

  end

  describe "update/2" do
    test "Edits, and responds with the user if attributes are valid"
    test "Returns an error and does not edit the user if attributes are invalid"
  end

  test "delete/2 and responds with :ok if the user was deleted"


end
