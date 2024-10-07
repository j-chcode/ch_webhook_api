#pragma semicolon 1
// #pragma ctrlchar '\'

#include <amxmodx>
#include <curl>
#include <webhook_const>

public plugin_init()
{
	register_plugin("[CH] Webhook API", "v2.53.6", "--chcode");
}

public plugin_natives() {
	register_native("SendWebhook", "_SendWebhook", 1);
}

enum dataStruct { curl_slist: linkedList };

public _SendWebhook(const username[], const content[], hookid)
{
	for(new i = 1; i < 3; i++)
		param_convert(i);
		
	new time[10];
	set_time_format(time, charsmax(time));

	new pass[512];
	format(pass, charsmax(pass), "{ ^"username^": ^"%s^", ^"content^": ^"`[%s]` %s^" }", username, time, content);

	new 
		CURL: g_curl,
		header,
		sData[dataStruct];

	header = curl_slist_append(header, "Content-Type: application/json");
	header = curl_slist_append(header, "User-Agent: curl");

	sData[linkedList] = header;
	g_curl = curl_easy_init();

	curl_easy_setopt(g_curl, CURLOPT_URL, webhook[hookid]);
	curl_easy_setopt(g_curl, CURLOPT_COPYPOSTFIELDS, pass);
	curl_easy_setopt(g_curl, CURLOPT_CUSTOMREQUEST, "POST");
	curl_easy_setopt(g_curl, CURLOPT_HTTPHEADER, header);
	curl_easy_setopt(g_curl, CURLOPT_SSL_VERIFYPEER, false);
	curl_easy_setopt(g_curl, CURLOPT_WRITEFUNCTION, "@responseWrite");

	curl_easy_perform(g_curl, "@requestComplete", sData, dataStruct);

	return PLUGIN_HANDLED;
}

@responseWrite(const data[], const size, const nmemb)
{
    server_print("Response body: \n%s", data);
 
    return size * nmemb; // tell curl how many bytes we handled
}

@requestComplete(CURL: curl, CURLcode: code, const data[dataStruct])
{
    if (code != CURLE_OK) {
        new szError[128];
        curl_easy_strerror(code, szError, charsmax(szError));
        server_print("CURL: %s", szError);
    }

    curl_easy_cleanup(curl);
    curl_slist_free_all(data[linkedList]);
}

stock set_time_format(time[], len) {
	new time_fmt[9][9];
	get_time("%H", time_fmt[0], len);
	get_time("%M", time_fmt[1], len);
	get_time("%S", time_fmt[2], len);
	
	format(time_fmt[0], charsmax(time_fmt), "%d", (str_to_num(time_fmt[0]) + 3));
	if(str_to_num(time_fmt[0]) >= 24)
		format(time_fmt[0], charsmax(time_fmt), "%d", (str_to_num(time_fmt[0]) - 24));
		
	format(time, len, "%s:%s:%s", time_fmt[0], time_fmt[1], time_fmt[2]);
}