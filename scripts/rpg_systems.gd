extends RefCounted

# Progression is earned only from completed gameplay objectives and successful technique use.
var xp := 0
var total_xp := 0
var level := 1
var ryo := 100
var mission_rank := "Academia"
var inventory := {"kunai": 10, "shuriken": 5, "soldier_pill": 1}
var completed_missions: Array[String] = []
var unlocked_jutsu := ["kunai", "shuriken", "katon"]
var technique_mastery := {
	"kunai": 0,
	"shuriken": 0,
	"katon": 0,
	"dodge": 0,
	"punch": 0,
	"substitution": 0,
	"clone": 0
}
var real_stats := {
	"precision_hits": 0,
	"successful_training_actions": 0,
	"missions_completed": 0,
	"social_interactions": 0,
	"restraint_choices": 0,
	"initiative_choices": 0
}
var earned_milestones: Array[String] = []

func add_xp(amount: int) -> void:
	var earned := maxi(amount, 0)
	if earned == 0:
		return
	xp += earned
	total_xp += earned
	while xp >= level * 100:
		xp -= level * 100
		level += 1

func award_milestone(id: String, xp_reward: int) -> bool:
	if earned_milestones.has(id):
		return false
	earned_milestones.append(id)
	add_xp(xp_reward)
	return true

func complete_mission(id: String, xp_reward: int, ryo_reward: int) -> void:
	if completed_missions.has(id):
		return
	completed_missions.append(id)
	real_stats["missions_completed"] = int(real_stats["missions_completed"]) + 1
	add_xp(xp_reward)
	ryo += ryo_reward

func unlock_jutsu(id: String) -> void:
	if not unlocked_jutsu.has(id):
		unlocked_jutsu.append(id)

func register_success(action: String, xp_reward: int = 0) -> void:
	if technique_mastery.has(action):
		technique_mastery[action] = int(technique_mastery[action]) + 1
	real_stats["successful_training_actions"] = int(real_stats["successful_training_actions"]) + 1
	if action in ["kunai", "shuriken"]:
		real_stats["precision_hits"] = int(real_stats["precision_hits"]) + 1
	if xp_reward > 0:
		add_xp(xp_reward)

func register_social_interaction() -> void:
	real_stats["social_interactions"] = int(real_stats["social_interactions"]) + 1

func register_personality_choice(kind: String) -> void:
	if kind == "restraint":
		real_stats["restraint_choices"] = int(real_stats["restraint_choices"]) + 1
	elif kind == "initiative":
		real_stats["initiative_choices"] = int(real_stats["initiative_choices"]) + 1

func mastery_label(action: String) -> String:
	var uses := int(technique_mastery.get(action, 0))
	if uses >= 8:
		return "Domínio"
	if uses >= 4:
		return "Consistente"
	if uses >= 1:
		return "Praticado"
	return "Não comprovado"

func personality_summary() -> String:
	var restraint := int(real_stats["restraint_choices"])
	var initiative := int(real_stats["initiative_choices"])
	if restraint > initiative:
		return "Observador • controlado • sarcástico quando relaxa"
	if initiative > restraint:
		return "Direto • competitivo • age antes de falar demais"
	return "Reservado • atento • competitivo sem procurar confusão"

func consume_item(id: String, amount: int = 1) -> bool:
	if int(inventory.get(id, 0)) < amount:
		return false
	inventory[id] = int(inventory[id]) - amount
	return true
