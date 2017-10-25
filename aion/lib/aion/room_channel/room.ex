defmodule Aion.RoomChannel.Room do
  @moduledoc """
  This module represents one game room, and fetches resources from the db
  """
  alias Aion.{Repo, Question, Answer, User}
  alias Aion.RoomChannel.{Room, UserRecord, QuestionSet}
  require Logger

  @type t :: %__MODULE__{users: %{String.t => UserRecord.t},
                         users_count: integer,
                         questions: (list Question.t),
                         current_question: Question.t,
                         answers: (list Answer.t)}

  defstruct users: %{},
            users_count: 0,
            questions: [],
            current_question: nil,
            answers: []

  @spec new(integer, [current_question: nil | Question.t]) :: %__MODULE__{}
  def new(room_id, state \\ []) do
    case state do
      [] ->
        %Room{}
        |> load_questions(room_id)
        |> change_question(room_id)

      {:current_question, question} ->
        %Room{current_question: question}

      _ -> Logger.error fn -> "Unexpected state passed to Room.new: #{state}" end
           %Room{}
    end
  end

  @spec evaluate_answer(__MODULE__.t, String.t) :: float
  def evaluate_answer(room, user_answer) do
    room
    |> Map.get(:answers)
    |> Enum.map(&(Map.get(&1, :content)))
    |> Enum.map(fn correct_answer -> Answer.compare_answers(correct_answer, user_answer) end)
    |> Enum.max()
  end

  @spec award_user(__MODULE__.t, String.t, integer, integer) :: __MODULE__.t
  def award_user(room, username, user_id, amount \\ 1) do
    question = Repo.preload(room.current_question, :category)
    category_id = question.category.id
    User.score_point(user_id, category_id)
    update_in room, [Access.key!(:users), Access.key!(username)], &UserRecord.update_score(&1, amount)
  end

  @doc """
  Note: this function's signature will change as soon as we get rid of categories = subject_id = room_id mapping.
  """
  @spec change_question(%__MODULE__{}, integer) :: __MODULE__.t
  def change_question(room, room_id) do
    new_questions_with_answers = QuestionSet.create(room.questions, room_id)
    struct(room, new_questions_with_answers)
  end

  @spec load_questions(%__MODULE__{}, integer) :: __MODULE__.t
  def load_questions(room, room_id) do
    questions =
      room_id
      |> Question.get_questions_by_room_id()
      |> Enum.shuffle()
    struct(room, %{questions: questions})
  end

  @spec add_user(__MODULE__.t, UserRecord.t) :: __MODULE__.t
  def add_user(room, user) do
    updated_users = Map.put(room.users, user.username, user)
    %Room{room | users: updated_users}
  end

  @spec remove_user(__MODULE__.t, String.t) :: __MODULE__.t
  def remove_user(room, username) do
    updated_users = Map.delete(room.users, username)
    %Room{room | users: updated_users}
  end

  @spec get_scores(__MODULE__.t) :: list UserRecord.t
  def get_scores(room) do
    Map.values(room.users)
  end

  @spec get_current_question(__MODULE__.t) :: Question.t
  def get_current_question(room) do
    room.current_question
  end
end
