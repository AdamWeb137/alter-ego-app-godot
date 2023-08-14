extends Node

func free_time_eligable(_mess_obj, id, mcond):
	if int(id.left(3)) < 3 or int(id.left(3)) == 10:
		return false
	if mcond == "FALSE":
		return false
	return true

func tag_arg(lestring):
	return lestring.split(":")[1]

var script_obj
var free_time_messes = [[],[],[],[],[],[],[],[],[],[],[],[],[]]
var type_messes = [[],[],[],[],[],[],[],[],[],[],[],[],[]]
var time_messes = [[],[],[],[]]
var ranking_messages={}
var lang="en"
func lang_var(v):
	return self[lang][v]
#			Possible keys for current_obj
#			"jump":"",
#			"react_line":"",
#			"react_jump":"",
#			"selects":{},
#			"time":enum int
#			"voicelines":[]
#			"faces":[]
#			"commands":{"keyof mess index":[...commands...]}
#			"eqcond":"VAR:TARGET" (i think i'll put chkvar in here too)
#			"day":"month:day"
#			"event":"month:week#:weekday"
#			"after":"var:0(set to zero) or 1(add one)"

func split_tag(lestring,lefts="<",rights=">"):
	var d1 = lestring.split(lefts)
	var res = []
	for s in d1:
		var d2 = s.split(rights)
		for s2 in d2:
			if s2 == "":
				continue
			res.append(s2.strip_edges())
	return res

var en={"rb":"]","lb":"["}
var jp={"rb":"】","lb":"【"}
var visit_checked=false


func how_many_of_type_free(n):
	return free_time_messes[n].size()

func get_script_obj(lang_to_load="en"):
	var enfile = FileAccess.open("res://lang/"+lang_to_load+".txt",FileAccess.READ)
	var max_chars_per_line=47
	#skip the first 5 lines as they are useless
	for i in range(5):
		enfile.get_line()
	script_obj = {}
	free_time_messes = [[],[],[],[],[],[],[],[],[],[],[],[],[]]
	type_messes = [[],[],[],[],[],[],[],[],[],[],[],[],[]]
	ranking_messages={}
	time_messes = [[],[],[],[]]
	var current_obj=null
	var last_id=null
	var current_cond=null
	lang=lang_to_load
	var current_line=0
	var mess_line=0
	var mess_index=0
	var last_line = ""
	var last_line_was_p=false
	var mtypes = ["000_","001_","002_","003_","004_","005_","006_","007_","008_","009_","010_","011_","012_"]
	while enfile.get_position() < enfile.get_length():
		var line = enfile.get_line()
		if line == "":
			continue
		elif mtypes.has(line.left(4)) and line.length() == 7:
			current_line=0
			mess_line=0
			if current_obj != null:
				if last_line != "":
#					if last_line[last_line.length()-1] == "\n":
#						last_line = last_line.substr(0,last_line.length()-1)
					current_obj.lines.append(last_line.strip_edges())
				script_obj[last_id]=current_obj
				type_messes[int(last_id.left(3))].append(last_id.right(3))
				if free_time_eligable(current_obj, last_id, current_cond):
					free_time_messes[int(last_id.left(3))].append(last_id.right(3))
			current_obj = {
				"lines":[],
				"commands":{}
			}
			last_id = line
			current_cond=null
			last_line = ""
			last_line_was_p = false
			mess_index=0
		elif current_line == 1:
			current_cond = line
			if line.left(3) == "CHK":
				var chk_type = line.substr(3).replace(" ","")
				match chk_type:
					"MOR":
						current_obj["time"]=0
						time_messes[0].append(last_id)
					"DAYTIME":
						current_obj["time"]=1
						time_messes[1].append(last_id)
					"NIGHT":
						current_obj["time"]=2
						time_messes[2].append(last_id)
					"MIDNIGHT":
						current_obj["time"]=3
						time_messes[3].append(last_id)
					_:
						if chk_type.contains("DAY"):
							var daycond = chk_type.replace("DAY(","").replace(")","").replace(",",":")
							current_obj["day"] = daycond
						if chk_type.contains("EVENT"):
							var evcond = chk_type.replace("EVENT(","").replace(")","").replace(",",":")
							current_obj["event"] = evcond
						if chk_type.contains("VARN"):
							current_obj["boolcond"] = chk_type.replace("VARN(","").replace(")","")+":0"
						elif chk_type.contains("VAR"):
							current_obj["boolcond"] = chk_type.replace("VARN(","").replace(")","")+":1"
			if line.left(3) == "IF(":
				current_obj["eqcond"]=line.replace("IF(","").replace(")","").replace("==",":").replace(" ","")
				if current_obj["eqcond"].split(":")[0] == "RANKING":
					var necc_rank = int(current_obj["eqcond"].split(":")[1])
					if not necc_rank in ranking_messages:
						ranking_messages[necc_rank]=[]
					ranking_messages[necc_rank].append(last_id.right(3))
		elif current_line > 1 and line.contains("="):
			var vname = line.replace(" ","").split("=")[0]
			if line.contains("0"):
				current_obj["after"]=vname+":0"
			else:
				current_obj["after"]=vname+":1"
		else:
			var last_too_long = mess_line == 2 and line.length() > max_chars_per_line
			if mess_line>=3 or last_line_was_p or last_too_long:
#				if last_line[last_line.length()-1] == "\n":
#					last_line = last_line.substr(0,last_line.length()-1)
				current_obj.lines.append(last_line.strip_edges())
				last_line_was_p=false
				mess_line=0
				mess_index += 1
				last_line=""
#			var comsplit = line.replace(">"," ").split("<")

			var comsplit = split_tag(line)
			var reassmbled_line = []
			var i = 0
			while i < comsplit.size():
				var subline = comsplit[i]
				if subline == "P":
					last_line_was_p = true
					i += 1
					continue
				var csplit = subline.split(":")
#				"JP", "TIMEON", "TIMEOFF", "REACT", "REACTE", "CALENDARON", "PICON", "PICOFF",
#				"FACE", "P", "SELECT", "SELECTEND", "VOICE"
				match csplit[0]:
					"JP":
						current_obj["jump"]=csplit[1]
					"REACT":
						current_obj["react_jump"]=csplit[1]
						var rlinesplit = comsplit[i+1].strip_edges().split(self[lang_to_load]["rb"])
						for rsline in rlinesplit:
							if rsline.length() == 0:
								continue
							if rsline[0] == self[lang_to_load]["lb"]:
								var rl = rsline.strip_edges()+self[lang_to_load]["rb"]
								current_obj["react_line"]=rl
								reassmbled_line.append("<REACT>")
							else:
								reassmbled_line.append(rsline.strip_edges())
						#reassmbled_line.append()
						#current_obj["react_line"]=comsplit[i+1].strip_edges()
						#reassmbled_line.append("<REACT>")
						i+=2
					"REACTE", "CALENDARON","SELECTEND":
						i += 1
						continue
					"FACE","VOICE","PICON","PICOFF":
						if str(mess_index) in current_obj["commands"]:
							current_obj["commands"][str(mess_index)].append(subline)
						else:
							current_obj["commands"][str(mess_index)]=[subline]
					"SELECT":
						if not "select" in current_obj:
							current_obj["select"] = []
						var ns = csplit[1]+":"+comsplit[i+1].strip_edges()
						current_obj["select"].append(ns)
						i += 2
					_:
						reassmbled_line.append(subline)
				i += 1
			reassmbled_line = " ".join(reassmbled_line)
#			if reassmbled_line.length() > 50:
#				last_line = last_line.substr(0,last_line.length()-1)
			last_line += reassmbled_line + "\n"
			mess_line += int(reassmbled_line.length() / max_chars_per_line) + 1
			
		current_line += 1
	
	if current_obj != null:
		if last_line != "":
#			if last_line[last_line.length()-1] == "\n":
#				last_line = last_line.substr(0,last_line.length()-1)
			current_obj.lines.append(last_line.strip_edges())
		script_obj[last_id]=current_obj
		type_messes[int(last_id.left(3))].append(last_id.right(3))
		if free_time_eligable(current_obj, last_id, current_cond):
			free_time_messes[int(last_id.left(3))].append(last_id.right(3))

func get_mess(id):
	return script_obj[id]
	
var script_vars
func init_vars():
	if not FileAccess.file_exists("user://scriptvars.save"):
		script_vars = {"MONOKUMAPIC":0, "SHINDAN":0, "VISITNUM":0, "RANKING":0, "URANAI":0}
		return
	var save = FileAccess.open("user://scriptvars.save",FileAccess.READ)
	var text = save.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(text)
	if not parse_result == OK:
		script_vars = {"MONOKUMAPIC":0, "SHINDAN":0, "VISITNUM":0, "RANKING":0, "URANAI":0}
		return
	script_vars = json.get_data()

func save_vars():
	var f = FileAccess.open("user://scriptvars.save",FileAccess.WRITE)
	f.store_string(JSON.stringify(script_vars))

func get_var(v):
	if not v in script_vars:
		script_vars[v] = int(0)
	return int(script_vars[v])
	
func set_var(v,val):
	script_vars[v]=int(val)
	
func add_var(v,n=1):
	set_var(v,get_var(v)+n)

func init():
	var lang = "jp"
	if FileAccess.file_exists("user://lang.save"):
		var lfile = FileAccess.open("user://lang.save", FileAccess.READ)
		lang = lfile.get_as_text().strip_edges()
		if lang != "en" and lang != "jp":
			lang = "jp"
	init_vars()
	get_script_obj(lang)
	
func get_time_of_day():
	var current_time = Time.get_datetime_dict_from_system()
	var h = current_time.hour
	if h >= 5 and h < 12:
		return 0
	elif h >= 12 and h < 6:
		return 1
	elif h >= 6 and h < 24:
		return 2
	else:
		return 3

# can you play this message?
func chk_mess(id):
	var mess = get_mess(id)
	if "time" in mess:
		return get_time_of_day() == mess["time"]
	var t = Time.get_datetime_dict_from_system()
	if "day" in mess:
		var mdsplit = mess["day"].split(":")
		return t.month == int(mdsplit[0]) and t.day == int(mdsplit[1])
	if "event" in mess:
		var wn = int((t.day - 1) / 7) + 1
		var esplit = mess["event"].split(":")
		return t.month == int(esplit[0]) and wn == int(esplit[1]) and t.weekday == int(esplit[2])
	if "boolcond" in mess:
		var vsplit = mess["boolcond"].split(":")
		var vval = get_var(vsplit[0])
		if int(vsplit[1]) == 0:
			return vval == 0
		return vval >= 1
	if "eqcond" in mess:
		var vsplit = mess["eqcond"].split(":")
		return get_var(vsplit[0]) == int(vsplit[1])
	return true

