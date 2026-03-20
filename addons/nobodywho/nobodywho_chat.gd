class_name NobodyWhoChat
extends Node

signal message_received(role: String, content: String)
signal chat_started
signal chat_ended
signal error_occurred(error: String)

var model: NobodyWhoModel
var conversation_history: Array = []
var system_prompt: String = "You are a helpful assistant."
var is_active: bool = false
var max_history_length: int = 10

enum Role {
	SYSTEM,
	USER,
	ASSISTANT
}


func _ready():
	print("NobodyWhoChat: Placeholder chat node initialized")
	print("Note: This is a placeholder. Download the complete NobodyWho plugin for actual chat functionality.")


func set_model(model_node: NobodyWhoModel) -> void:
	model = model_node
	print("NobodyWhoChat: Model set to ", model.name if model else "null")


func set_system_prompt(prompt: String) -> void:
	system_prompt = prompt
	print("NobodyWhoChat: System prompt updated")


func start_chat() -> void:
	is_active = true
	conversation_history.clear()
	chat_started.emit()
	print("NobodyWhoChat: Chat started")


func end_chat() -> void:
	is_active = false
	chat_ended.emit()
	print("NobodyWhoChat: Chat ended")


func send_message(user_message: String) -> String:
	if not is_active:
		printerr("NobodyWhoChat: Cannot send message - chat is not active")
		return ""
	
	if not model:
		printerr("NobodyWhoChat: Cannot send message - no model set")
		return ""
	
	print("NobodyWhoChat: Sending message: ", user_message)
	
	var message_data = {
		"role": Role.USER,
		"content": user_message
	}
	conversation_history.append(message_data)
	message_received.emit("user", user_message)
	
	var full_prompt = _build_prompt()
	var response = await model.generate(full_prompt)
	
	var response_data = {
		"role": Role.ASSISTANT,
		"content": response
	}
	conversation_history.append(response_data)
	message_received.emit("assistant", response)
	
	_trim_history()
	
	return response


func send_message_async(user_message: String) -> void:
	send_message(user_message)


func get_conversation_history() -> Array:
	return conversation_history.duplicate()


func clear_history() -> void:
	conversation_history.clear()
	print("NobodyWhoChat: Conversation history cleared")


func set_max_history_length(length: int) -> void:
	max_history_length = length
	_trim_history()


func _build_prompt() -> String:
	var prompt = system_prompt + "\n\n"
	
	for message in conversation_history:
		var role_str = "user" if message.role == Role.USER else "assistant"
		prompt += role_str + ": " + message.content + "\n"
	
	prompt += "assistant:"
	
	return prompt


func _trim_history() -> void:
	if conversation_history.size() > max_history_length:
		var remove_count = conversation_history.size() - max_history_length
		conversation_history = conversation_history.slice(remove_count)


func get_chat_info() -> Dictionary:
	return {
		"is_active": is_active,
		"history_length": conversation_history.size(),
		"max_history_length": max_history_length,
		"system_prompt": system_prompt,
		"model_set": model != null
	}
