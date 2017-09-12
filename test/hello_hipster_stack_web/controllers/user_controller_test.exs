defmodule HelloHipsterStackWeb.UserControllerTest do
  use HelloHipsterStackWeb.ConnCase
  require Logger

  alias HelloHipsterStack.Accounts

  @user1_attrs %{email: "grobblefruit@kernel.org", display_name: "grobblefruit", password: "surf and skate"}

  @user2_attrs %{email: "coffee@coffee.org", display_name: "espresso", password: "daydream of coffee"}

  @update_attrs %{email: "falada@horsehead.org", display_name: "goose girl", password: "covered in tar and feathers"}

  @bad_attrs %{email: "", display_name: ""}

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
    setup do
      {:ok, user2} = Accounts.create_user(@user2_attrs)
      {:ok, user2: user2}
    end

    test "Edits, and responds with the user if attributes are valid", %{conn: conn, user2: user} do
      response = conn
      |> put(user_path(conn, :update, user.id ), data: %{ attributes: @update_attrs } )
      |> json_response(200)

      expected = %{
        "data" =>
        %{ "email" => @update_attrs.email, "display_name" => @update_attrs.display_name }
      }
      assert response == expected
    end
    test "Returns the unmodified user if attributes object is empty", %{conn: conn, user: user} do

      response = conn
      |>put( user_path(conn, :update, user.id ), data: %{ attributes: %{} } )
      |> json_response(200)

      expected = %{
        "data" =>
        %{ "email" => user.email, "display_name" => user.display_name }
      }
      assert response == expected

    end
    test "Returns an error and does not edit the user if attributes are invalid", %{conn: conn, user: user} do

      response = conn
        |> put( user_path(conn, :update, user.id ), data: %{ attributes: @bad_attrs })
        |> json_response(422)

      assert response["errors"] == %{
        "display_name" => ["can't be blank"],
        "email" => ["can't be blank"]
      }
      # by the way, will crash if attributes are set to nil (not a hash)
    end
  end

  describe "create/2" do
    test "Creates, and responds with a newly created user if attributes are valid", %{conn: conn} do
      response = conn
      |> post( user_path(conn, :create), data: %{ attributes: @user2_attrs } )
      |> json_response(201)
      assert( response["data"] == %{"email"=> @user2_attrs.email,
                                   "display_name" => @user2_attrs.display_name}
      )

    end

    test "Cannot create a user with a duplicate email", %{conn: conn, user: user} do
      response = conn
      |> post( user_path(conn, :create), data: %{ attributes: %{"email" => user.email,
                                                               "display_name" => @user2_attrs.display_name,
                                                               "password" => @user2_attrs.password} } )
      |> json_response(422)
      assert( response["errors"] == %{"email"=>  ["has already been taken"]} )

    end

    test "Returns an error and does not create a user if attributes are invalid", %{conn: conn} do
      response = conn
      |> post( user_path(conn, :create), data: %{ attributes: @bad_attrs })
      |> json_response(422)
      assert( response["errors"] == %{
        "display_name" => ["can't be blank"],
        "email" => ["can't be blank"],
        "password" => ["can't be blank"] }
        )


    end

  end


  test "delete/2 and responds with :ok if the user was deleted"


end
