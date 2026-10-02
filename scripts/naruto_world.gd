extends RefCounted

# Lightweight Naruto-classic content registry. Entries unlock by story era instead of
# spawning every character at once. This keeps the 2D RPG coherent and Android-friendly.
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
	{"name":"Gaara","role":"Ninja da Areia","era":3}
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

func unlocked_locations(era: int) -> Array:
	return LOCATIONS.filter(func(entry): return int(entry["era"]) <= era)

func unlocked_cast(era: int) -> Array:
	return CLASSIC_CAST.filter(func(entry): return int(entry["era"]) <= era)
