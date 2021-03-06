defmodule Aion.QuestionController do
  use Aion.Web, :controller

  alias Aion.{Question, QuestionTransactions}

  plug(Guardian.Plug.EnsureAuthenticated, handler: __MODULE__)

  def index(conn, _params) do
    questions = Repo.all(Question)
    render(conn, "index.json", questions: questions)
  end

  def create(conn, %{"question" => question, "answers" => answers, "category" => category_id}) do
    transaction =
      QuestionTransactions.create_question_with_answers(question, answers, category_id)

    transaction_result = Repo.transaction(transaction)

    case transaction_result do
      {:ok, %{insert_question: question}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", question_path(conn, :show, question))
        |> render("show.json", question: question)

      {:error, _, _, _} ->
        conn
        |> send_resp(500, "error processing entity")
    end
  end

  def show(conn, %{"id" => id}) do
    question = Repo.get!(Question, id)
    render(conn, "show.json", question: question)
  end

  def update(conn, %{"id" => id, "question" => question_params}) do
    question = Repo.get!(Question, id)
    changeset = Question.changeset(question, question_params)

    case Repo.update(changeset) do
      {:ok, question} ->
        render(conn, "show.json", question: question)

      {:error, changeset} ->
        Errors.unprocessable_entity(conn, changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    question = Repo.get!(Question, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(question)

    send_resp(conn, :no_content, "")
  end

  def unauthenticated(conn, _params) do
    Errors.unauthenticated(conn)
  end
end
