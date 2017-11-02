defmodule Aion.RoomChannel do
  @moduledoc """
  This module is responsible for providing a commucation between Elixir and Elm. It describes how the backend part
  should react to new messages or events.
  """

  use Phoenix.Channel, log_join: false, log_handle_in: :info
  alias Aion.RoomChannel.Monitor
  alias Aion.{Presence, UserSocket, QuestionChronicle, GuardianSerializer}
  require Logger

  @spec join(String.t, %{}, UserSocket.t) :: {:ok, UserSocket.t}
  def join("rooms:" <> room_id, _params, socket) do
    username = get_user_name(socket)
    # Note: this is a temporary solution.
    # In the future, this function should return an error if a user wants to join a room that does not exist.
    if not Monitor.exists?(room_id) do
        Monitor.create(room_id)
    end

    Monitor.user_joined(room_id, username)
    Logger.info("[channel] #{username} joined room #{room_id}")

    Presence.track(socket, username, %{
          online_at: inspect(System.system_time(:seconds))
    })

    send self(), :after_join
    {:ok, socket}
  end

  def terminate(msg, socket) do
    username = get_user_name(socket)
    room_id = get_room_id(socket)

    Monitor.user_left(room_id, username)
    Presence.untrack(socket, username)
    Logger.info("[channel] #{username} left: " <> Kernel.inspect(msg))

    if Monitor.get_scores(room_id) == [] do
        Monitor.shutdown(room_id)
    end
  end

  def handle_in("new:msg", %{"body" => body}, socket) do
    broadcast! socket, "new:msg", %{body: body}
    {:noreply, socket}
  end

  def handle_in("new:answer", %{"room_id" => room_id, "answer" => answer}, socket) do
    username = get_user_name(socket)
    user_id = get_user_id(socket)
    evaluation = Monitor.new_answer(room_id, answer, username, user_id)
    send_feedback socket, evaluation

    if evaluation == 1.0 do
      send_scores(room_id, socket)
      send_new_question(room_id, socket)
    end

    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    room_id = get_room_id(socket)

    send_scores(room_id, socket)
    send_current_question(room_id, socket)
    {:noreply, socket}
  end

  def handle_info(:question_not_answered, socket) do
    room_id = get_room_id(socket)
    if QuestionChronicle.should_change?(room_id) do
      Logger.info("[channel] Question timed out in room: #{room_id}. Fetching a new one...")
      send_new_question(room_id, socket)
    else
      Logger.debug(fn -> "[channel] Timer went off in room: #{room_id}. Too early, though." end)
    end
    {:noreply, socket}
  end

  intercept ["presence_diff"]

  def handle_out("presence_diff", %{joins: _, leaves: _}, socket) do
      # NOTE: This function currently sends scores.
      # 1. We may update it later to only send the presence diff and handle it
      # properly on the frontend side
      # 2. The send scores here is called only when there are > 1 people in
      # the room. If you're the first person joining the room, you're going
      # to receive the scores from :after_join.
      room_id = get_room_id(socket)
      send_scores(room_id, socket)

      {:noreply, socket}
  end

  defp send_scores(room_id, socket) do
    scores = Monitor.get_scores(room_id)
    broadcast! socket, "user:list", %{users: scores}
  end

  defp send_new_question(room_id, socket) do
    Monitor.new_question(room_id)
    send_current_question(room_id, socket)
  end

  # def send_next_question(room_id, socket) do
    # Monitor.get_next_question(room_id)
#
  # end

  defp send_current_question(room_id, socket) do
    # NOTE: This function is called every time a user joins room / the question changes
    question = Monitor.get_current_question(room_id)
    image_name = if question.image_name == nil, do: "", else: question.image_name

    QuestionChronicle.update_last_change(room_id)
    :timer.send_after(QuestionChronicle.question_timeout_milli, :question_not_answered)

    broadcast! socket, "new:question", %{content: question.content, image_name: image_name}
  end

  defp send_feedback(socket, evaluation) do
    feedback = cond do
      evaluation == 1.0 -> :correct
      evaluation > 0.8 -> :close
      true -> :incorrect
    end

    push socket, "answer:feedback", %{"feedback" => feedback}
  end

  defp get_room_id(socket) do
    "rooms:" <> room_id = socket.topic
    room_id
  end

  defp get_user(socket) do
    {:ok, user} = GuardianSerializer.from_token(socket.assigns.guardian_default_claims["aud"])
    user
  end

  defp get_user_name(socket) do
    get_user(socket).name
  end

  defp get_user_id(socket) do
    get_user(socket).id
  end
end
