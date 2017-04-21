defmodule HermesTest do
    use ExUnit.Case
    doctest Hermes

    test "Check Connection" do
        {:ok, _} = Hermes.start()
    end

    test "Create User" do
        {:ok, p} = Hermes.start()
        {_, m} = Hermes.create_user(p, "username1", "email1", "passwordHash1", "salt1")
        {_, m} = Hermes.create_user(p, "username2", "email2", "passwordHash2", "salt2")
        # IO.puts m
    end

    test "Update Password" do
        {:ok, p} = Hermes.start()
        {_, m} = Hermes.update_password(p, "username1", "newPassword1", "newSalt1")
        {_, m} = Hermes.update_password(p, "username2", "newPassword2", "newSalt2")
        # IO.puts m
    end

    test "like Songs" do
        {:ok, p} = Hermes.start()
        # several users like the same song
        Hermes.like_song(p, "username1", "songID6", "artist", "title", "album")
        Hermes.like_song(p, "username2", "songID6", "artist", "title", "album")
        Hermes.like_song(p, "username3", "songID6", "artist", "title", "album")
        Hermes.like_song(p, "username4", "songID6", "artist", "title", "album")

        # one user liked different songs
        Hermes.like_song(p, "username5", "song1", "artist", "title", "album")
        Hermes.like_song(p, "username5", "song2", "artist", "title", "album")
        Hermes.like_song(p, "username5", "song3", "artist", "title", "album")
        Hermes.like_song(p, "username5", "song4", "artist", "title", "album")
    end

    test "show Songs" do
        {:ok, p} = Hermes.start()
        {_, m, _} = Hermes.get_all_liked_songs(p,"username1")
        # IO.puts m
        {_, m, _} = Hermes.get_all_liked_songs(p,"username2")
        # IO.puts m
        {_, m, _} = Hermes.get_all_liked_songs(p,"username3")
        # IO.puts m
        {_, m, _} = Hermes.get_all_liked_songs(p,"username4")
        # IO.puts m
        {_, m, _} = Hermes.get_all_liked_songs(p,"username5")
        # IO.puts m
    end

    test "delete Songs" do
        {:ok, p} = Hermes.start()
        {_, m} = Hermes.unlike_song(p, "username5", "song4")
        # IO.puts m
    end

    test "create record" do
        {:ok, p} = Hermes.start()
        {_, m} = Hermes.create_record(p, "song_id_1")
        # IO.puts m
    end

    test "create record_the_same" do
        {:ok, p} = Hermes.start()
        {_, m} = Hermes.create_record(p, "song_id_1")
        # IO.puts m
    end

    test "create record_the_different" do
        {:ok, p} = Hermes.start()
        {_, m} = Hermes.create_record(p, "song_id_2")
        # IO.puts m
    end

    test "update record" do
        {:ok, p} = Hermes.start()
        {r, m} = Hermes.update_record(p, "song_id_1", "user1", 123456, DateTime.utc_now |> DateTime.to_unix, 123)
        {r, m} = Hermes.update_record(p, "song_id_2", "user2", 987654, DateTime.utc_now |> DateTime.to_unix, 546)
    end

    test "update user profile" do
        {:ok, p} = Hermes.start()
        {r, m} = Hermes.update_user_profiles(p, "username2", 1, 2, 3, 4, 5)
        # IO.puts m
    end

    test "get user profile" do
        {:ok, p} = Hermes.start()
        {r, m} = Hermes.get_full_user_profile(p, "username2")
        IO.inspect m
    end

    test "get all highscores" do
        {:ok, p} = Hermes.start()
        {_, m} = Hermes.get_full_highscore(p)
        # IO.inspect m
    end


end
