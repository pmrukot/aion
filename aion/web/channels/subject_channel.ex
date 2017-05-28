defmodule Aion.SubjectChannel do
  use Phoenix.Channel

  def join("rooms:" <> _private_room_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("new:msg", %{"body" => body}, socket) do
    broadcast! socket, "new:msg", %{body: body}
    {:noreply, socket}
  end
end