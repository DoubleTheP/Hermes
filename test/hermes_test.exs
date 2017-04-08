defmodule HermesTest do
    use ExUnit.Case
    doctest Hermes

    test "Check Connection" do
        {:ok, _} = Hermes.start()
    end

    test "Create User" do
        {:ok, p} = Hermes.start()
        Hermes.create_user(p, "username", "emai", "passwordHash", "salt")
    end

end
