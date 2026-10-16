extends RefCounted

# Positions are character anchors; furniture rectangles describe painted soles.
const ROOMS := {
	"academy": {
		"title": "ACADEMIA · SALA DE AULA", "image": "res://assets/environments/academy-interior.jpg",
		"bounds": Rect2(85,193,790,273), "spawn": Vector2(480,442),
		"obstacles": [Rect2(304,161,353,40),Rect2(118,231,217,77),Rect2(63,315,262,96),Rect2(632,231,211,77),Rect2(634,315,262,96)],
		"actors": {"Iruka":Vector2(480,220),"Sasuke":Vector2(250,212),"Sakura":Vector2(735,212)},
		"points": [
			{"id":"exit","at":Vector2(480,462),"radius":55.0,"label":"Sair da Academia"},
			{"id":"board","at":Vector2(365,207),"radius":56.0,"label":"Ler o quadro"},
			{"id":"practice","at":Vector2(480,335),"radius":42.0,"label":"Treinar controle de chakra"}
		]
	},
	"home": {
		"title": "CASA DO HENRIQUE", "image": "res://assets/environments/home-interior.jpg",
		"bounds": Rect2(95,184,785,282), "spawn": Vector2(480,439),
		"obstacles": [Rect2(115,132,165,76),Rect2(295,237,354,122),Rect2(611,137,216,125),Rect2(815,150,108,124)],
		"actors": {},
		"points": [
			{"id":"exit","at":Vector2(480,462),"radius":55.0,"label":"Sair de casa"},
			{"id":"bed","at":Vector2(730,282),"radius":65.0,"label":"Descansar na cama"},
			{"id":"desk","at":Vector2(225,220),"radius":60.0,"label":"Examinar os estudos"},
			{"id":"kitchen","at":Vector2(470,207),"radius":58.0,"label":"Examinar a cozinha"}
		]
	}
}
const ACADEMY_DOOR := Vector2(344,235)

func config(room: String) -> Dictionary:
	return ROOMS.get(room,{})

func blocked(at: Vector2, room: String) -> bool:
	var data := config(room)
	for furniture in data["obstacles"]:
		if furniture.has_point(at + Vector2(0,14)): return true
	for actor in data["actors"].values():
		if at.distance_to(actor) < 22: return true
	return false

func nearby(at: Vector2, room: String) -> Dictionary:
	var data := config(room)
	var best: Dictionary = {}
	var distance := INF
	for person in data["actors"]:
		var point: Vector2 = data["actors"][person]
		var d := at.distance_to(point)
		if d < 62 and d < distance:
			distance=d
			best={"id":person,"at":point,"label":"Conversar com "+person}
	for point in data["points"]:
		var d: float = at.distance_to(point["at"])
		if d < float(point["radius"]) and d < distance:
			distance=d
			best=point
	return best
