extends CenterContainer

var ws : WebSocketPeer

func connect_to_url(url):
	if url is bool:
		url = $VBoxContainer/UrlLineEdit.text
	
	custom_log("Connecting to url:\n\t%s\n" % url)
	
	ws = WebSocketPeer.new()
	var err = ws.connect_to_url(url)
	if err:
		custom_log("Error connecting to %s:\n\t%s\n" % [url, err])

func _process(_delta):
	if not ws:
		return
	
	ws.poll()
	
	var conn_state : String = {0 : "connecting", 1 : "open", 2 : "closing", 3 : "closed"}[ws.get_ready_state()]
	$VBoxContainer/ConnectionStatusLabel.text = "Connection status: %s" % conn_state
	
	while ws.get_available_packet_count():
		var packet : String = ws.get_packet().get_string_from_ascii()
		custom_log("Received packet:\n\t%s\n" % packet)

func _on_disconnect_button_pressed():
	if ws:
		ws.close(1000, "User demand")

func _on_ping_button_pressed():
	custom_log("Sending ping")
	if ws and ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var err = ws.send("hello from godot".to_ascii_buffer())
		if err:
			custom_log("Error when pinging:\n\t%s\n" % err)
	else:
		custom_log("Cant ping when not connected\n")


func custom_log(text : String):
	var previous_text = $VBoxContainer/LogTextEdit.text
	
	if previous_text:
		text = "\n" + text
	
	$VBoxContainer/LogTextEdit.text += text
