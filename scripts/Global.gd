extends Node

func to_two_digits(n):
	if n < 10:
		return "0"+str(n)
	return str(n)

func to_m_digits(n,m=2):
	var s = str(n)
	var l = s.length()
	for i in range(m-l):
		s = "0" + s
	return s

func get_main():
	return get_node("/root/Main")

func change_face(num):
	get_main().change_face(num)
