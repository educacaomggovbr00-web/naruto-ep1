extends RefCounted

# Konoha is represented as a connected old-school RPG overworld grid.
# Landmark names come from Naruto sources; exact street placement is a game-layout
# interpretation because the series does not provide one single canonical tile map.

const KONOHA_LOCATIONS := [
	{"id":"hokage_rock","name":"Monumento Hokage","short":"Hokage Rock","x":0,"y":0,"kind":"monument","era":1,"canon":true},
	{"id":"hokage_residence","name":"Residência do Hokage","short":"Hokage","x":1,"y":0,"kind":"government","era":1,"canon":true},
	{"id":"academy","name":"Academia Ninja","short":"Academia","x":2,"y":0,"kind":"academy","era":0,"canon":true},
	{"id":"jonin_station","name":"Estação de Espera Jōnin","short":"Jōnin","x":3,"y":0,"kind":"government","era":1,"canon":true},
	{"id":"archive_library","name":"Biblioteca de Arquivos","short":"Arquivos","x":4,"y":0,"kind":"library","era":1,"canon":true},

	{"id":"hospital","name":"Hospital de Konoha","short":"Hospital","x":0,"y":1,"kind":"hospital","era":1,"canon":true},
	{"id":"north_residential","name":"Bairro Residencial Norte","short":"Resid. Norte","x":1,"y":1,"kind":"residential","era":0,"canon":false},
	{"id":"central_plaza","name":"Praça Central de Konoha","short":"Praça","x":2,"y":1,"kind":"plaza","era":0,"canon":false},
	{"id":"mission_desk","name":"Atribuição de Missões","short":"Missões","x":3,"y":1,"kind":"government","era":1,"canon":true},
	{"id":"commercial_district","name":"Distrito Comercial","short":"Comércio","x":4,"y":1,"kind":"commercial","era":1,"canon":true},

	{"id":"cemetery","name":"Cemitério de Konoha","short":"Cemitério","x":0,"y":2,"kind":"cemetery","era":1,"canon":true},
	{"id":"memorial_stone","name":"Pedra Memorial","short":"Memorial","x":1,"y":2,"kind":"memorial","era":1,"canon":true},
	{"id":"library","name":"Biblioteca de Konoha","short":"Biblioteca","x":2,"y":2,"kind":"library","era":1,"canon":true},
	{"id":"post_office","name":"Correio Central","short":"Correio","x":3,"y":2,"kind":"commercial","era":1,"canon":true},
	{"id":"ichiraku","name":"Ramen Ichiraku","short":"Ichiraku","x":4,"y":2,"kind":"ramen","era":0,"canon":true},

	{"id":"uchiha_district","name":"Distrito Uchiha","short":"Uchiha","x":0,"y":3,"kind":"uchiha","era":0,"canon":true},
	{"id":"military_police","name":"Polícia Militar de Konoha","short":"Polícia","x":1,"y":3,"kind":"uchiha","era":1,"canon":true},
	{"id":"naka_shrine","name":"Santuário Naka","short":"Santuário Naka","x":2,"y":3,"kind":"shrine","era":1,"canon":true},
	{"id":"naka_river","name":"Rio Naka","short":"Rio Naka","x":3,"y":3,"kind":"river","era":1,"canon":true},
	{"id":"dango_shop","name":"Loja de Dango","short":"Dango","x":4,"y":3,"kind":"commercial","era":1,"canon":true},

	{"id":"training_ground_3","name":"Campo de Treinamento 3","short":"Treino 3","x":0,"y":4,"kind":"training","era":1,"canon":true},
	{"id":"training_ground_44","name":"Campo de Treinamento 44","short":"Treino 44","x":1,"y":4,"kind":"training","era":1,"canon":true},
	{"id":"aviary","name":"Aviário de Konoha","short":"Aviário","x":2,"y":4,"kind":"service","era":1,"canon":true},
	{"id":"intelligence_division","name":"Divisão de Inteligência","short":"Inteligência","x":3,"y":4,"kind":"government","era":1,"canon":true},
	{"id":"hot_springs","name":"Fontes Termais de Konoha","short":"Termas","x":4,"y":4,"kind":"hotspring","era":1,"canon":true},

	{"id":"west_residential","name":"Bairro Residencial Oeste","short":"Resid. Oeste","x":0,"y":5,"kind":"residential","era":0,"canon":false},
	{"id":"south_residential","name":"Bairro Residencial Sul","short":"Resid. Sul","x":1,"y":5,"kind":"residential","era":0,"canon":false},
	{"id":"east_residential","name":"Bairro Residencial Leste","short":"Resid. Leste","x":2,"y":5,"kind":"residential","era":0,"canon":false},
	{"id":"orphanage","name":"Orfanato de Konoha","short":"Orfanato","x":3,"y":5,"kind":"residential","era":1,"canon":true},
	{"id":"village_gate","name":"Portão de Konoha","short":"Portão","x":4,"y":5,"kind":"gate","era":0,"canon":true}
]

const LOCATIONS := [
	{"id":"academy","name":"Academia Ninja","era":0},
	{"id":"konoha_plaza","name":"Praça de Konoha","era":0},
	{"id":"ichiraku","name":"Ichiraku Ramen","era":0},
	{"id":"training_ground","name":"Campo de Treino","era":0},
	{"id":"uchiha_district","name":"Distrito Uchiha","era":0},
	{"id":"hokage_office","name":"Gabinete do Hokage","era":1},
	{"id":"konoha_gate","name":"Portão de Konoha","era":1},
	{"id":"forest","name":"Floresta de Konoha","era":1},
	{"id":"land_of_waves","name":"País das Ondas","era":2},
	{"id":"chunin_arena","name":"Arena do Exame Chunin","era":3}
]

const CLASSIC_CAST := [
	{"name":"Naruto Uzumaki","role":"Academia / futuro Time 7","era":0},
	{"name":"Iruka Umino","role":"Instrutor","era":0},
	{"name":"Mizuki","role":"Instrutor","era":0},
	{"name":"Sasuke Uchiha","role":"Aluno / futuro Time 7","era":1},
	{"name":"Sakura Haruno","role":"Aluna / futuro Time 7","era":1},
	{"name":"Kakashi Hatake","role":"Jounin / futuro líder do Time 7","era":1},
	{"name":"Hiruzen Sarutobi","role":"Terceiro Hokage","era":1},
	{"name":"Konohamaru Sarutobi","role":"Neto do Terceiro Hokage / aluno","era":1},
	{"name":"Ebisu","role":"Tutor de Konohamaru","era":1},
	{"name":"Shikamaru Nara","role":"Aluno ninja","era":1},
	{"name":"Hinata Hyuga","role":"Aluna ninja","era":1},
	{"name":"Kiba Inuzuka","role":"Aluno ninja","era":1},
	{"name":"Ino Yamanaka","role":"Aluna ninja","era":1},
	{"name":"Choji Akimichi","role":"Aluno ninja","era":1},
	{"name":"Shino Aburame","role":"Aluno ninja","era":1},
	{"name":"Rock Lee","role":"Genin","era":3},
	{"name":"Neji Hyuga","role":"Genin","era":3},
	{"name":"Tenten","role":"Genin","era":3},
	{"name":"Gaara","role":"Ninja da Areia","era":3},
	{"name":"Tazuna","role":"Cliente da missão do País das Ondas","era":2}
]

const JUTSU := [
	{"id":"kunai","name":"Kunai","cost":0,"kind":"weapon"},
	{"id":"katon","name":"Katon","cost":25,"kind":"fire"},
	{"id":"sharingan","name":"Sharingan","cost":1,"kind":"dojutsu"},
	{"id":"substitution","name":"Kawarimi","cost":12,"kind":"utility"},
	{"id":"clone","name":"Bunshin","cost":10,"kind":"ninjutsu"},
	{"id":"shuriken","name":"Shuriken","cost":0,"kind":"weapon"}
]

const MISSION_RANKS := ["D","C","B","A","S"]

func location(id: String) -> Dictionary:
	for entry in KONOHA_LOCATIONS:
		if String(entry["id"]) == id:
			return entry
	return KONOHA_LOCATIONS[2]

func location_name(id: String) -> String:
	return String(location(id)["name"])

func all_konoha_locations() -> Array:
	return KONOHA_LOCATIONS.duplicate(true)

func neighbor(id: String, direction: String) -> String:
	var here := location(id)
	var dx := 0
	var dy := 0
	match direction:
		"west": dx = -1
		"east": dx = 1
		"north": dy = -1
		"south": dy = 1
		_: return ""
	var target_x := int(here["x"]) + dx
	var target_y := int(here["y"]) + dy
	for entry in KONOHA_LOCATIONS:
		if int(entry["x"]) == target_x and int(entry["y"]) == target_y:
			return String(entry["id"])
	return ""

func unlocked_locations(era: int) -> Array:
	return LOCATIONS.filter(func(entry): return int(entry["era"]) <= era)

func unlocked_cast(era: int) -> Array:
	return CLASSIC_CAST.filter(func(entry): return int(entry["era"]) <= era)
