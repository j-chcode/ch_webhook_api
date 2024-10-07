#include <amxmodx>
#include <webhook>

public plugin_init() {
	register_plugin("[CH] Webhook Log", "v2.1.0", "--chcode");
	register_clcmd("say", "say_handle");
}

public started() {
	new server_info[512];
	
	new map[32];
	get_mapname(map, charsmax(map));
	
	format(server_info, charsmax(server_info), "__**`[Server Started]`**__\n**Map:** `[%s]`  **Players:** `[%d/%d Bots: %d]`", map, (get_playersnum() -get_bots()), get_maxplayers(), get_bots());
	SendWebhook("Server", server_info, CHAT_LOG);
}

public plugin_precache() {
	if(!task_exists(666)) {
		set_task((60.0 * 3.50), "status_task", 666, _, _, "b");
		started();
	}
}

public status_task() {
	new server_info[512];
	
	new map[32];
	get_mapname(map, charsmax(map));
	
	format(server_info, charsmax(server_info), "__**`[Server Status]`**__\n**Map:** `[%s]`  **Players:** `[%d/%d Bots: %d]`", map, (get_playersnum() -get_bots()), get_maxplayers(), get_bots());
	SendWebhook("Server", server_info, CHAT_LOG);
}

public get_bots() {
	new c = 0;
	
	for(new i = 0; i < get_maxplayers(); i++) {
		if(is_user_connected(i) && is_user_bot(i)) {
			c++;
		}
	}
	
	return c;
}

public say_handle(id) {
	new args[512];
	read_args(args, charsmax(args));
	remove_quotes(args);
	remove_color(args, charsmax(args));
	
	new name[64];
	get_user_name(id, name, charsmax(name));
	remove_color(name, charsmax(name));
	
	new message[1024];
	format(message, charsmax(message), "**%s**: %s", name, args);
	
	SendWebhook("Chat Log", message, CHAT_LOG);
}

public client_connect(id) {
	if(is_user_bot(id))
		return;
		
	new name[64];
	get_user_name(id, name, charsmax(name));
	remove_color(name, charsmax(name));
	
	new ip[128];
	get_user_ip(id, ip, charsmax(ip));
	
	if(!strlen(ip)) {
		format(ip, charsmax(ip), "•••.•••.•••.•••");
	}
	
	new text[1024];
	format(text, charsmax(text), "__**`[Connecting]`**__\nIP: ||%s|| %s", ip, name);
	
	SendWebhook("Connect Log", text, CONNECT_LOG);
}

public client_disconnected(id) {
	if(is_user_bot(id))
		return;
		
	new name[64];
	get_user_name(id, name, charsmax(name));
	remove_color(name, charsmax(name));
	
	new ip[128];
	get_user_ip(id, ip, charsmax(ip));
	
	if(!strlen(ip)) {
		format(ip, charsmax(ip), "•••.•••.•••.•••");
	}
	
	new text[1024];
	format(text, charsmax(text), "__**`[Disconnected]`**__\nIP: ||%s|| %s", ip, name);
	
	SendWebhook("Connect Log", text, CONNECT_LOG);
}

public client_putinserver(id) {
	if(is_user_bot(id))
		return;
		
	new name[64];
	get_user_name(id, name, charsmax(name));
	remove_color(name, charsmax(name));
	
	new ip[128];
	get_user_ip(id, ip, charsmax(ip));
	
	if(!strlen(ip)) {
		format(ip, charsmax(ip), "•••.•••.•••.•••");
	}
	
	new text[1024];
	format(text, charsmax(text), "__**`[Connected]`**__\nIP: ||%s|| %s", ip, name);
	
	SendWebhook("Connect Log", text, CONNECT_LOG);
}