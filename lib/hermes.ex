defmodule Hermes do
# used module: https://github.com/xerions/mariaex

# IDEAS: add function to delete user from all databases

    def start(username) do
        Mariaex.start_link(username: username, database: "mousika")
    end

# Access UserManagement-DB
    defp does_user_not_exists(p, username) do
        {s, r} = Mariaex.query(p, "SELECT username FROM UserManagement WHERE username = ?", [username])
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

    # untested function
    def get_password_hash_and_salt(p, username) do
        {s, r} = Mariaex.query(p, "SELECT password_hash, salt FROM UserManagement WHERE username = ?", [username])
        case {s, r} do
            {:ok, _} ->
                {:ok, r.rows, 0}
            {:error, _} -> {:error, r.mariadb.message, 1}
        end
    end

    def create_user(p, username, email, passwordHash, salt) do
        case does_user_not_exists(p, username) do
            {:ok, _} ->
                insert_user(p, username, email, passwordHash, salt)
                create_user_profile(p, username)
            {:error, message} -> {:error, message}
        end
    end

    def login_user(p, username) do
        case does_user_not_exists(p, username) do
            {:ok, _} -> {:ok, "User logged in"}
            {:error, r} -> {:error, r.mariadb.message}
        end
    end

    def update_password(p, username, newPassword, newSalt) do
        case does_user_not_exists(p, username) do
            {:ok, r} -> {:error, r.mariadb.message}
            {:error, _} ->
                {s, r} = Mariaex.query(p, "UPDATE UserManagement SET password_hash = ?, salt = ? WHERE username = ?", [newPassword, newSalt, username])
                case {s, r} do
                    {:ok, _} -> {:ok, "password successfully changed"}
                    {:error, _} -> {:error, r.mariadb.message}
                end
        end
    end

# Access UserProfile-DB
    defp create_user_profile(p, username) do
        {s, r} = Mariaex.query(p, "INSERT INTO UserProfiles(username) VALUES(?)", [username])
        case {s, r} do
            {:ok, _} -> {:ok, "successfully new user profile added"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    def update_user_profiles(p, userName, xp, songsPlayed, songsCorrect, songsWon, gamesWon) do
        {s, r} = Mariaex.query(p, "UPDATE UserProfiles SET experience = ?, songs_played = ?, songs_correct = ?, songs_won = ?, games_won = ? WHERE username = ?", [xp, songsPlayed, songsCorrect, songsWon, gamesWon, userName])
        case {s, r} do
            {:ok, _} -> {:ok, "successfully updated user profile"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    def get_full_user_profile(p, username) do
        {_, r1, c1} = get_footer_user_profile(p, username)
        {_, r2, c2} = get_all_liked_songs(p, username)
        {_, r3, c3} = get_all_user_records(p, username)
        case c1 + c2 + c3 do
            0 -> {:ok, r1 ++ r2 ++ r3}
            1 -> {:error, r1}
            2 -> {:error, r2}
            3 -> {:error, "error in footer- and songs-db-function call"}
            4 -> {:error, r3}
            5 -> {:error, "error in footer- and records-db-function call"}
            6 -> {:error, "error in songs- and records-db-function call"}
            7 -> {:error, "error in footer-, songs- and records-db-function call"}
        end
    end

    def get_footer_user_profile(p, username) do
        {s, r} = Mariaex.query(p, "SELECT experience, songs_won, games_won FROM UserProfiles WHERE username = ?", [username])
        case {s, r} do
            {:ok, _} ->
                {:ok, r.rows, 0}
            {:error, _} -> {:error, r.mariadb.message, 1}
        end
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
        {s, r} = Mariaex.query(p, "SELECT song_id FROM UserToSong WHERE username = ?", [username])
        case {s, r} do
            {:ok, _} -> {:ok, r.rows, 0}
            {:error, _} -> {:error, r.mariadb.message, 2}
        end
    end

    def unlike_song(p, username, songID) do
        {s, r} = Mariaex.query(p, "DELETE FROM UserToSong WHERE username = ? && song_id = ?", [username, songID])
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
        {s, r} = Mariaex.query(p, "SELECT * FROM UserToSong WHERE song_id = ?", [songID])
        case {s, r} do
            {:ok, %Mariaex.Result{num_rows: 0}} -> {:ok, "Song does not exists"}
            {:ok, _} -> {:ok, "Song still exists"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

# Access LikedSongs-DB
    defp save_liked_song(p, songID, artist, title, album) do
        case liked_song_is_new_to_db(p, songID) do
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
        {s, r} = Mariaex.query(p, "DELETE FROM LikedSongs WHERE songID = ?", [songID])
        case {s, r} do
            {:ok, _} -> {:ok, "Song removed"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    defp liked_song_is_new_to_db(p, songID) do
        {s, r} = Mariaex.query(p, "SELECT song_id FROM LikedSongs WHERE song_id = ?", [songID])
        case {s, r} do
            {:ok, %Mariaex.Result{num_rows: 0}} -> {:ok, p}
            {:ok, _} -> {:error, "Song already exists in db"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

# Access Records-DB
    defp song_record_is_new_to_db(p, songID) do
        {s, r} = Mariaex.query(p, "SELECT song_id FROM Records WHERE song_id = ?", [songID])
        case {s, r} do
            {:ok, %Mariaex.Result{num_rows: 0}} -> {:ok, p}
            {:ok, _} -> {:error, "Song already exists in db"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    def create_record(p, songID) do
    # To call if new songs are generated
        case song_record_is_new_to_db(p, songID) do
            {:error, r} -> {:error, r}
            {:ok, _} ->
                {s, r} = Mariaex.query(p, "INSERT INTO Records(song_id, username) VALUES(?,?)", [songID, "Max Mustermann"])
                case {s, r} do
                    {:ok, _} -> {:ok, "successfully new record created"}
                    {:error, _} -> {:error, r.mariadb.message}
                end
        end
    end

    def update_record(p, songID, userName, bestTime, recordDate, atteMpts) do
        {s, r} = Mariaex.query(p, "UPDATE `Records` SET `username` = ?, `best_time` = ?, `record_date` = ?, `attempts` = ? WHERE `song_id` = ?", [userName, bestTime, recordDate, atteMpts, songID])
        case {s, r} do
            {:ok, _} -> {:ok, "successfully updated"}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end

    defp get_all_user_records(p, username) do
        {s, r} = Mariaex.query(p, "SELECT song_id FROM Records WHERE username = ?", [username])
        case {s, r} do
            {:ok, _} -> {:error, r.rows, 0}
            {:error, _} -> {:error, r.mariadb.message, 4}
        end
    end

    def get_full_highscore(p) do
        {s, r} = Mariaex.query(p, "SELECT * FROM Records")
        case {s, r} do
            {:ok, _} -> {:ok, r.rows}
            {:error, _} -> {:error, r.mariadb.message}
        end
    end
end
