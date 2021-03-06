defmodule Discuss.TopicController do
  use Discuss.Web, :controller

  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:update, :edit, :delete]


  def new(conn, _params) do
    changeset = Discuss.Topic.changeset(%Discuss.Topic{}, %{})

    render conn, "new.html", changeset: changeset
  end


  def create(conn,  %{"topic" => topic}) do
    changeset= conn.assigns.user
    |> build_assoc(:topics)
    |> Discuss.Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} -> 
        conn 
        |> put_flash(:info, "Topic Created!")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset}->         
        render(conn, "new.html", changeset: changeset)
    end

  end

  def index(conn, _params) do
    topics = Repo.all(Discuss.Topic)
    render(conn, "index.html", topics: topics)
  end

  def show(conn, %{"id"=> topic_id}) do
    topic = Repo.get!(Discuss.Topic, topic_id)

    render conn, "show.html", topic: topic
  end

  def edit(conn, %{"id"=>topic_id}) do
    topic = Repo.get(Discuss.Topic, topic_id)
    changeset = Discuss.Topic.changeset(topic)

    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id"=>id, "topic" => topic}) do
    old_topic = Repo.get(Discuss.Topic, id)
    changeset = Discuss.Topic.changeset(old_topic, topic)
  

    case Repo.update(changeset) do
      {:ok, _topic} -> 
        conn 
        |> put_flash(:info, "Topic Updated!")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} -> render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    Repo.get!(Discuss.Topic, id)
    |> Repo.delete!
    |>IO.inspect
    
    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn

    if conn && Repo.get(Discuss.Topic, topic_id).user_id == conn.assigns.user.id do
      conn

    else
      conn
      |> put_flash(:error, "You cannot edit that")
      |> redirect(to: topic_path(conn, :index))
      |> halt() 
    end
  end

  


end