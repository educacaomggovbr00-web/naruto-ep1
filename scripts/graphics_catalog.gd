extends RefCounted

const CHARACTER_PACK := {
	"henrique": {"name":"Henrique Uchiha","overworld":true,"battle":true,"player":true},
	"naruto": {"name":"Naruto","overworld":true,"battle":true},
	"sasuke": {"name":"Sasuke","overworld":true,"battle":true},
	"sakura": {"name":"Sakura","overworld":true,"battle":true},
	"kakashi": {"name":"Kakashi","overworld":true,"battle":true},
	"iruka": {"name":"Iruka","overworld":true},
	"mizuki": {"name":"Mizuki","overworld":true},
	"konohamaru": {"name":"Konohamaru","overworld":true},
	"ebisu": {"name":"Ebisu","overworld":true},
	"teuchi": {"name":"Teuchi","overworld":true},
	"ayame": {"name":"Ayame","overworld":true},
	"hiruzen": {"name":"Terceiro Hokage","overworld":true},
	"anbu": {"name":"ANBU","overworld":true},
	"npc_red": {"name":"NPC vermelho","overworld":true},
	"npc_blue": {"name":"NPC azul","overworld":true},
	"npc_white": {"name":"NPC claro","overworld":true},
	"npc_brown": {"name":"NPC marrom","overworld":true}
}

const HENRIQUE_ANIMATIONS := [
	"idle","walk","run","jump","fall","crouch","dodge_roll","slide",
	"punch_combo","kunai_attack","shuriken_throw","katon_fireball",
	"shadow_clone","substitution","hurt","down","get_up","death"
]

const JUTSU_EFFECTS := [
	"fireball","fire_stream","lightning_bolt","lightning_burst",
	"water_wave","water_vortex","smoke","substitution_smoke",
	"kunai_trail","shuriken_spin","fire_slash","lightning_slash",
	"impact_dust","impact_spike","chakra_aura","susanoo_aura"
]

const ITEMS := [
	{"id":"kunai","name":"Kunai","kind":"weapon"},
	{"id":"shuriken","name":"Shuriken","kind":"weapon"},
	{"id":"soldier_pill","name":"Pílula do Soldado","kind":"consumable"},
	{"id":"small_scroll","name":"Pergaminho Pequeno","kind":"quest"},
	{"id":"large_scroll","name":"Pergaminho Grande","kind":"quest"},
	{"id":"ryo_pouch","name":"Bolsa de Ryō","kind":"currency"},
	{"id":"ramen","name":"Ramen","kind":"food"},
	{"id":"dango","name":"Dango","kind":"food"},
	{"id":"water_bottle","name":"Garrafa de Água","kind":"consumable"},
	{"id":"medicine","name":"Remédio Ninja","kind":"consumable"}
]

const MAPS := [
	"central_plaza","academy","ichiraku","streets","henrique_home","training_ground_3","forest"
]

const BATTLE_STAGES := [
	"plaza","forest","bridge","academy","chunin_exam","valley","river","training_ground","interior"
]
