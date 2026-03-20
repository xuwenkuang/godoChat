class_name NobodyWhoModel
extends Node

signal model_loaded
signal model_unloaded
signal generation_started
signal generation_finished(result: String)
signal generation_error(error: String)

var model_name: String = ""
var model_path: String = ""
var is_loaded: bool = false
var is_generating: bool = false

var max_tokens: int = 2048
var temperature: float = 0.7
var top_p: float = 0.9
var top_k: int = 40

var http_request: HTTPRequest
var api_url: String = ""
var api_key: String = ""
var is_remote: bool = false

var LogWrapper: Node = null
var max_retries: int = 3
var retry_delay: float = 1.0
var current_retry_count: int = 0
var last_request_messages: Array = []

enum RequestType {
	OPENAI,
	CLAUDE,
	CUSTOM,
	KIMI
}


func _ready():
	print("NobodyWhoModel: Placeholder node initialized")
	print("Note: This is a placeholder. Download the complete NobodyWho plugin for actual LLM functionality.")
	_setup_http_request()
	_setup_log_wrapper()


func _setup_http_request() -> void:
	http_request = HTTPRequest.new()
	http_request.timeout = 30.0
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)


func _setup_log_wrapper() -> void:
	LogWrapper = get_node("/root/LogWrapper")
	if not LogWrapper:
		print("NobodyWhoModel: LogWrapper not found, using print instead")


func _send_request_with_retry() -> String:
	while current_retry_count < max_retries:
		_send_remote_request(last_request_messages)
		await http_request.request_completed
		
		var response: String = _get_last_response()
		
		if not response.is_empty():
			return response
		
		current_retry_count += 1
		
		if current_retry_count < max_retries:
			var delay: float = retry_delay * pow(2, current_retry_count - 1)
			_log_info("Request failed, retrying in %.1f seconds (attempt %d/%d)" % [delay, current_retry_count + 1, max_retries])
			await get_tree().create_timer(delay).timeout
	
	return ""


func _log_info(msg: String) -> void:
	if LogWrapper and LogWrapper.has_method("info"):
		LogWrapper.info(self, msg)
	else:
		print("[INFO] " + msg)


func _log_warn(msg: String) -> void:
	if LogWrapper and LogWrapper.has_method("warn"):
		LogWrapper.warn(self, msg)
	else:
		print("[WARN] " + msg)


func _log_debug(msg: String) -> void:
	if LogWrapper and LogWrapper.has_method("debug"):
		LogWrapper.debug(self, msg)
	else:
		print("[DEBUG] " + msg)


func load_model(model_identifier: String) -> void:
	print("NobodyWhoModel: Attempting to load model: ", model_identifier)
	print("Note: Model loading is not implemented in this placeholder version.")


func unload_model() -> void:
	print("NobodyWhoModel: Unloading model")
	is_loaded = false
	model_unloaded.emit()


func generate(prompt: String) -> String:
	print("NobodyWhoModel: Generation requested with prompt: ", prompt)
	print("Note: Text generation is not implemented in this placeholder version.")
	
	is_generating = true
	generation_started.emit()
	
	if is_remote and not api_url.is_empty() and not api_key.is_empty():
		_log_info("Using remote API: " + api_url)
		last_request_messages = [{"role": "user", "content": prompt}]
		current_retry_count = 0
		var response: String = await _send_request_with_retry()
		
		if response.is_empty():
			_log_warn("Remote API returned empty response after all retries")
			var request_type: int = _detect_request_type()
			var placeholder_result = "抱歉，远程API返回了空响应。请检查：\n• API URL 是否正确\n• API Key 是否有效\n• 模型名称是否正确\n• 网络连接是否正常\n\n💡 可用的" + _get_request_type_name(request_type) + "模型:\n" + _get_model_name_suggestion(request_type) + "\n\n如果问题持续存在，请稍后再试。"
			is_generating = false
			generation_finished.emit(placeholder_result)
			return placeholder_result
		
		is_generating = false
		generation_finished.emit(response)
		return response
	
	var placeholder_result = "抱歉，AI 模型未配置。请点击右上角的齿轮图标（⚙）配置模型设置。\n\n您可以选择：\n• OpenAI API（如 GPT-3.5）\n• Claude API\n• Kimi API（Moonshot）\n• 自定义 API\n\n配置完成后即可开始对话！"
	
	is_generating = false
	generation_finished.emit(placeholder_result)
	
	return placeholder_result


func _send_remote_request(messages: Array) -> void:
	var request_type: int = _detect_request_type()
	var headers: PackedStringArray = []
	var body: Dictionary = {}
	
	if not _validate_model_name(request_type, model_name):
		var error_msg = "Invalid model name '" + model_name + "' for " + _get_request_type_name(request_type) + " API. " + _get_model_name_suggestion(request_type)
		_log_warn(error_msg)
		generation_error.emit(error_msg)
		is_generating = false
		return
	
	match request_type:
		RequestType.OPENAI:
			headers = PackedStringArray([
				"Content-Type: application/json",
				"Authorization: Bearer " + api_key
			])
			body = {
				"model": model_name,
				"messages": messages,
				"temperature": temperature,
				"max_tokens": max_tokens
			}
		
		RequestType.CLAUDE:
			headers = PackedStringArray([
				"Content-Type: application/json",
				"x-api-key: " + api_key,
				"anthropic-version: 2023-06-01"
			])
			body = {
				"model": model_name,
				"messages": messages,
				"max_tokens": max_tokens,
				"temperature": temperature
			}
		
		RequestType.KIMI:
			headers = PackedStringArray([
				"Content-Type: application/json",
				"Authorization: Bearer " + api_key
			])
			body = {
				"model": model_name,
				"messages": messages,
				"temperature": temperature,
				"max_tokens": max_tokens
			}
		
		RequestType.CUSTOM:
			headers = PackedStringArray([
				"Content-Type: application/json",
				"Authorization: Bearer " + api_key
			])
			body = {
				"model": model_name,
				"messages": messages,
				"temperature": temperature,
				"max_tokens": max_tokens
			}
	
	var json_body: String = JSON.stringify(body)
	_log_debug("Sending request to: " + api_url)
	_log_debug("Request body: " + json_body)
	var error: Error = http_request.request(api_url, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		var error_msg = "Failed to send HTTP request: " + str(error)
		_log_warn(error_msg)
		generation_error.emit(error_msg)
		is_generating = false


func _detect_request_type() -> int:
	if "anthropic.com" in api_url.to_lower():
		return RequestType.CLAUDE
	elif "openai.com" in api_url.to_lower():
		return RequestType.OPENAI
	elif "moonshot.cn" in api_url.to_lower():
		return RequestType.KIMI
	else:
		return RequestType.CUSTOM


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		var error_msg = "HTTP request failed with result: " + str(result)
		
		if result == 44:
			error_msg += " (网络连接错误)"
			error_msg += "\n\n可能原因：\n• 网络连接不稳定\n• 防火墙阻止了连接\n• API服务器暂时不可用\n\n💡 建议：\n• 检查网络连接\n• 稍后再试\n• 如果问题持续，请更换网络环境"
		
		_log_warn(error_msg)
		generation_error.emit(error_msg)
		return
	
	if response_code != 200:
		var error_message: String = body.get_string_from_utf8()
		var error_msg = "API returned error code " + str(response_code) + ": " + error_message
		
		if response_code == 429:
			error_msg += "\n\n⚠️ 服务器过载\n\nAPI服务器当前负载过高，正在自动重试...\n\n请稍候片刻，系统会自动重新发送请求。"
		elif response_code == 404 and "model" in error_message.to_lower():
			var request_type: int = _detect_request_type()
			var model_hint: String = _get_model_name_suggestion(request_type)
			error_msg += "\n\n💡 提示: " + model_hint
			error_msg += "\n\n请在设置中更正模型名称。"
		elif response_code >= 500:
			error_msg += "\n\n⚠️ 服务器错误\n\nAPI服务器出现问题，正在自动重试..."
		
		_log_warn(error_msg)
		generation_error.emit(error_msg)
		return
	
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		var error_msg = "Failed to parse JSON response: " + body.get_string_from_utf8()
		_log_warn(error_msg)
		generation_error.emit(error_msg)
		return
	
	var response_data: Dictionary = json.data
	_log_debug("API response received: " + str(response_data))
	var response_text: String = _extract_response_text(response_data)
	
	if not response_text.is_empty():
		_last_response = response_text
		_log_debug("Successfully extracted response text")
	else:
		var error_msg = "Empty response from API. Response data: " + str(response_data)
		_log_warn(error_msg)
		generation_error.emit(error_msg)


var _last_response: String = ""


func _extract_response_text(response_data: Dictionary) -> String:
	_log_debug("Extracting response text from: " + str(response_data))
	
	if response_data.has("choices"):
		var choices: Array = response_data["choices"]
		_log_debug("Found choices array with size: " + str(choices.size()))
		if not choices.is_empty():
			var choice: Dictionary = choices[0]
			_log_debug("Processing choice: " + str(choice))
			if choice.has("message"):
				var message: Dictionary = choice["message"]
				if message.has("content"):
					var content: String = message["content"]
					_log_debug("Extracted content from message: " + content)
					return content
			elif choice.has("text"):
				var text: String = choice["text"]
				_log_debug("Extracted text from choice: " + text)
				return text
	
	if response_data.has("content"):
		var content: Array = response_data["content"]
		_log_debug("Found content array with size: " + str(content.size()))
		if not content.is_empty():
			var content_block: Dictionary = content[0]
			if content_block.has("text"):
				var text: String = content_block["text"]
				_log_debug("Extracted text from content block: " + text)
				return text
	
	if response_data.has("text"):
		var text: String = response_data["text"]
		_log_debug("Extracted text from root: " + text)
		return text
	
	if response_data.has("message"):
		var message: Dictionary = response_data["message"]
		if message.has("content"):
			var content: String = message["content"]
			_log_debug("Extracted content from message at root: " + content)
			return content
	
	_log_warn("Could not extract text from response. Available keys: " + str(response_data.keys()))
	return ""


func _get_last_response() -> String:
	return _last_response


func _validate_model_name(request_type: int, model_name: String) -> bool:
	match request_type:
		RequestType.KIMI:
			var valid_kimi_models = ["moonshot-v1-8k", "moonshot-v1-32k", "moonshot-v1-128k"]
			return model_name in valid_kimi_models
		RequestType.OPENAI:
			var valid_openai_models = ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo", "gpt-4o", "gpt-4o-mini"]
			return model_name in valid_openai_models
		RequestType.CLAUDE:
			var valid_claude_models = ["claude-3-sonnet-20240229", "claude-3-opus-20240229", "claude-3-haiku-20240307"]
			return model_name in valid_claude_models
		_:
			return true


func _get_request_type_name(request_type: int) -> String:
	match request_type:
		RequestType.OPENAI:
			return "OpenAI"
		RequestType.CLAUDE:
			return "Claude"
		RequestType.KIMI:
			return "Kimi (Moonshot)"
		_:
			return "Custom"


func _get_model_name_suggestion(request_type: int) -> String:
	match request_type:
		RequestType.KIMI:
			return "Valid models are: moonshot-v1-8k, moonshot-v1-32k, moonshot-v1-128k"
		RequestType.OPENAI:
			return "Valid models are: gpt-3.5-turbo, gpt-4, gpt-4-turbo, gpt-4o, gpt-4o-mini"
		RequestType.CLAUDE:
			return "Valid models are: claude-3-sonnet-20240229, claude-3-opus-20240229, claude-3-haiku-20240307"
		_:
			return "Please check the API documentation for valid model names"


func generate_async(prompt: String) -> void:
	print("NobodyWhoModel: Async generation requested")
	generate(prompt)


func set_generation_parameters(max_tok: int = 2048, temp: float = 0.7, tp: float = 0.9, tk: int = 40) -> void:
	max_tokens = max_tok
	temperature = temp
	top_p = tp
	top_k = tk
	print("NobodyWhoModel: Generation parameters updated")


func set_remote_config(api_url: String, api_key: String, model_name: String) -> void:
	self.api_url = api_url
	self.api_key = api_key
	self.model_name = model_name
	is_remote = true
	
	print("NobodyWhoModel: Remote config set")


func get_model_info() -> Dictionary:
	return {
		"name": model_name,
		"path": model_path,
		"is_loaded": is_loaded,
		"max_tokens": max_tokens,
		"temperature": temperature,
		"top_p": top_p,
		"top_k": top_k,
		"is_remote": is_remote,
		"api_url": api_url
	}