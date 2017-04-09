defmodule Hermes do
    # used module: https://github.com/xerions/mariaex
    def start() do
        Mariaex.start_link(username: "ecto", database: "mousika")
    end

# Access UserManagement-DB
    defp does_user_exists(p, username) do
        {s, r} = Mariaex.query(p, "SELECT username FROM UserManagement WHERE username like ?", [username])
        case {s, r} do
            {:ok, %Mariaex.Result{num_rows: 0}} -> {:ok, p}
            {:ok, _} -> {:error, "User already exists"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    defp insert_user(p, username, email, passwordHash, salt) do
        {s, r} = Mariaex.query(p, "INSERT INTO UserManagement VALUES(?,?,?,?)", [username, email, passwordHash, salt])
        case {s, r} do
            {:ok, _} -> {:ok, "User inserted"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    def create_user(p, username, email, passwordHash, salt) do
        case does_user_exists(p, username) do
            {:ok, _} -> insert_user(p, username, email, passwordHash, salt)
            {:error, message} -> IO.puts message
        end
    end

    def login_user(p, username) do
        case does_user_exists(p, username) do
            {:ok, _} -> {:ok, "User logged in"}
            {:error, r} -> {:error, r.mariadb.message}
        end
    end

    def update_password(p, username, newPassword, newSalt) do
        case does_user_exists(p, username) do
            {:error, r} -> {:error, r.mariadb.message}
            {:ok, _} ->
                {s, r} = Mariaex.query(p, "UPDATE UserManagement SET passwordHash like ?, salt like ? WHERE email like ?", [newPassword, newSalt, username])
                case {s, r} do
                    {:ok, _} -> {:ok, "Password changed"}
                    {:error, _} -> {:error, r.mariadb.message}
                end
        end
    end

# Access UserProfile-DB
    def get_full_user_profile(username) do
        # get_all_liked_songs(username)
        # get_all_user_records(username)
        # get_footer_user_profile(username)
    end

    def get_footer_user_profile(username) do

    end


# Access UserToSongs-DB
    def like_song(p, username, songID, artist, title, album) do
        {s, r} = Mariaex.query(p, "INSERT INTO UserToSong VALUES(?,?)", [username, songID])
        case {s, r} do
            {:ok, _} ->
                save_liked_song(p, songID, artist, title, album)
                {:ok, "songID linked to username (and saved)"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    def get_all_liked_songs(p, username) do
        {s, r} = Mariaex.query(p, "SELECT song_id FROM UserToSong WHERE username like ?", [username])
        case {s, r} do
            {:ok, _} -> {:ok, r.rows}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    def unlike_song(p, username, songID) do
        {s, r} = Mariaex.query(p, "DELETE FROM UserToSong WHERE username like ? && songID like ?", [username, songID])
        case {s, r} do
            {:ok, _} ->
                {s2, r2} = does_song_link_exists(p, songID)
                case {s2, r2} do
                    {:ok, "Song does not exists"} ->
                        delete_liked_song(p, songID)
                        {:ok, "Song successfully unlinked and deleted with user"}
                    {:ok, _} -> {:ok, "Song successfully unlinked"}
                end
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    defp does_song_link_exists(p, songID) do
        {s, r} = Mariaex.query(p, "SELECT * FROM UserToSong WHERE song_id like ?", [songID])
        case {s, r} do
            {:ok, %Mariaex.Result{num_rows: 0}} -> {:ok, "Song does not exists"}
            {:ok, _} -> {:ok, "Song still exists"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

# Access LikedSongs-DB
    defp save_liked_song(p, songID, artist, title, album) do
        case does_song_exists(p, songID) do
            {:error, r} -> {:error, r}
            {:ok, _} ->
                {s, r} = Mariaex.query(p, "INSERT INTO LikedSongs VALUES(?,?,?,?)", [songID, artist, title, album])
                case {s, r} do
                    {:ok, _} -> {:ok, "Song added to db"}
                    {:error, _} -> {:error, r.mariadb.message}
                end
        end
    end

    defp delete_liked_song(p, songID) do
        {s, r} = Mariaex.query(p, "DELETE FROM LikedSongs WHERE songID like ?", [songID])
        case {s, r} do
            {:ok, _} -> {:ok, "Song removed"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    defp does_song_exists(p, songID) do
        {s, r} = Mariaex.query(p, "SELECT song_id FROM LikedSongs WHERE song_id like ?", [songID])
        case {s, r} do
            {:ok, %Mariaex.Result{num_rows: 0}} -> {:ok, p}
            {:ok, _} -> {:error, "Song already exists in db"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

# Access Records-DB
    def new_record do
        # if record already exists -> update_record()
    end

    defp update_record do

    end

    def update_attempts do

    end

    defp get_all_user_records(username) do

    end

    def get_full_highscore do

    end
end
