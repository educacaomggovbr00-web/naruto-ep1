extends RefCounted

var xp := 0
var level := 1
var ryo := 100
var mission_rank := "Academia"
var inventory := {"kunai": 10, "shuriken": 5, "soldier_pill": 1}
var completed_missions: Array[String] = []
var unlocked_jutsu := ["kunai", "katon"]

func add_xp(amount: int) -> void:
	xp += maxi(amount, 0)
	while xp >= level * 100:
		xp -= level * 100
		level += 1

func complete_mission(id: String, xp_reward: int, ryo_reward: int) -> void:
	if completed_missions.has(id):
		return
	completed_missions.append(id)
	add_xp(xp_reward)
	ryo += ryo_reward

func unlock_jutsu(id: String) -> void:
	if not unlocked_jutsu.has(id):
		unlocked_jutsu.append(id)

func consume_item(id: String, amount: int = 1) -> bool:
	if int(inventory.get(id, 0)) < amount:
		return false
	inventory[id] = int(inventory[id]) - amount
	return true
