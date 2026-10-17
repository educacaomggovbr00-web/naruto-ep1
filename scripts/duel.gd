extends CanvasLayer

const FLOOR := 378.0
var game: Node2D
var model = preload("res://scripts/duel_model.gd").new()
var active := false
var mode := "offer"
var paused := false
var easy := false
var recorded := false
var clock := 0.0
var shake := 0.0
var notice_text := ""
var notice_time := 0.0
var hit_effects: Array[Dictionary] = []
var held := {}
var keys := {}
var pointers := {}
var queued: Array[String] = []
var root_control: Control
var world_canvas: Node2D
var hud_canvas: Node2D
var controls: Array[Button] = []
var menus: Array[Button] = []
var menu_panel: Panel
var title: Label
var description: Label
var details: Label
var start_button: Button
var back_button: Button
var difficulty_button: Button
var pause_button: Button
var arena: Texture2D
var player_texture: Texture2D
var fire_texture: Texture2D
var mugen: Dictionary
var textures := {}

func _ready() -> void:
	layer = 10
	root_control = Control.new()
	root_control.size = Vector2(960, 540)
	add_child(root_control)
	world_canvas = preload("res://scripts/duel_canvas.gd").new()
	world_canvas.duel = self
	root_control.add_child(world_canvas)
	hud_canvas = preload("res://scripts/duel_canvas.gd").new()
	hud_canvas.duel = self
	hud_canvas.hud = true
	root_control.add_child(hud_canvas)
	for info in [["←",Vector2(24,430),"left"],["→",Vector2(116,430),"right"],["PULAR",Vector2(70,340),"jump"],["DEFESA",Vector2(674,342),"guard"],["ESQUIVA",Vector2(758,342),"dash"],["KATON",Vector2(842,342),"katon"],["GOLPE",Vector2(674,430),"light"],["FORTE",Vector2(758,430),"heavy"],["KUNAI",Vector2(842,430),"kunai"]]:
		var button := make_button(info[0],info[1],Vector2(76,76),root_control)
		button.set_meta("action",info[2])
		var action: String = info[2]
		if action in ["left","right","guard"]:
			button.button_down.connect(func(): held[action]=true)
			button.button_up.connect(func(): held.erase(action))
		else: button.pressed.connect(func(): queued.append(action))
		controls.append(button)
	pause_button = make_button("PAUSA · ESC",Vector2(802,111),Vector2(134,38),root_control)
	pause_button.pressed.connect(pause)
	menu_panel = Panel.new()
	menu_panel.position = Vector2(140,139)
	menu_panel.size = Vector2(680,286)
	menu_panel.add_theme_stylebox_override("panel",game.ui.panel_style())
	root_control.add_child(menu_panel)
	title = game.ui.child_label(menu_panel,"",Vector2(26,18),Vector2(628,35),25,Color("f0cf8b"))
	description = game.ui.child_label(menu_panel,"",Vector2(26,65),Vector2(628,52),15,Color("dee4d7"))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	difficulty_button = make_button("DIFICULDADE: NORMAL",Vector2(26,123),Vector2(628,36),menu_panel)
	difficulty_button.pressed.connect(func(): easy=not easy; difficulty_button.text="DIFICULDADE: ASSISTIDA" if easy else "DIFICULDADE: NORMAL")
	start_button = make_button("COMEÇAR DUELO",Vector2(26,172),Vector2(306,46),menu_panel)
	start_button.pressed.connect(menu_start)
	back_button = make_button("VOLTAR AO RPG",Vector2(348,172),Vector2(306,46),menu_panel)
	back_button.pressed.connect(close)
	details = game.ui.child_label(menu_panel,"",Vector2(26,230),Vector2(628,46),11,Color("aebfb7"))
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menus = [difficulty_button,start_button,back_button]
	hide()

func make_button(text: String, at: Vector2, dimensions: Vector2, parent: Node) -> Button:
	var button := Button.new()
	button.text = text
	button.position = at
	button.size = dimensions
	game.style_button(button)
	button.add_theme_font_size_override("font_size",12)
	parent.add_child(button)
	return button

func available() -> bool:
	return game.stage==2 and game.room=="outside" and game.world.district=="training" and game.lines.is_empty() and not game.travelling

func offer() -> bool:
	if not available() or game.ui.modal_open(): return false
	active = true
	mode = "offer"
	paused = false
	recorded = false
	game.ui.release_touches()
	game.motion_velocity = Vector2.ZERO
	game.movement = Vector2.ZERO
	game.attack_flash = 0
	game.dash_time = 0
	game.combat.reset()
	game.ui.hide()
	load_art()
	model.reset_match(easy)
	title.text = "DUELO LIVRE  /  HENRIQUE × NARUTO"
	description.text = "Vença dois rounds. Combine golpes, projéteis e defesa. Volte à exploração ao terminar."
	details.text = "Vitórias: %d · Melhor combo: %d\nA/D mover · W/Espaço pular · J golpe · L forte · U kunai · I Katon · K defesa · Q esquiva" % [game.sparring_stats.wins,game.sparring_stats.best_combo]
	start_button.text = "COMEÇAR DUELO"
	difficulty_button.show()
	menu_panel.show()
	set_controls(false)
	show()
	return true

func load_art() -> void:
	arena = load("res://assets/environments/training-premium.png")
	if ResourceLoader.exists("res://assets/environments/duel-arena.png"): arena = load("res://assets/environments/duel-arena.png")
	player_texture = load("res://assets/characters/attached-henrique.png")
	fire_texture = load("res://assets/characters/katon-fire.png")
	mugen = game.art.character_art.mugen_actions

func release_input() -> void:
	held.clear()
	keys.clear()
	pointers.clear()
	queued.clear()

func menu_start() -> void:
	if mode=="pause":
		paused=false
		mode="fight"
		menu_panel.hide()
		set_controls(true)
		release_input()
		return
	model.reset_match(easy)
	mode="fight"
	paused=false
	recorded=false
	hit_effects.clear()
	menu_panel.hide()
	set_controls(true)
	release_input()

func set_controls(value: bool) -> void:
	for button in controls: button.visible=value
	pause_button.visible=value

func pause() -> void:
	if not active or mode!="fight": return
	paused=true
	mode="pause"
	release_input()
	set_controls(false)
	title.text="DUELO PAUSADO"
	description.text="Respire e retome quando estiver pronto."
	details.text="A luta e seus recursos ficam parados enquanto a pausa está aberta."
	start_button.text="RETOMAR"
	difficulty_button.hide()
	menu_panel.show()

func close(save_result: bool = true) -> void:
	if not active: return
	if save_result and model.phase=="complete": record_result()
	active=false
	paused=false
	release_input()
	game.ui.release_touches()
	game.ui.show()
	hide()
	game.motion_velocity=Vector2.ZERO
	game.movement=Vector2.ZERO
	game.route_guide.reset()
	arena=null
	player_texture=null
	fire_texture=null
	textures.clear()

func record_result() -> void:
	if recorded: return
	recorded=true
	if model.player_rounds>=2:
		game.sparring_stats.wins=mini(9999,int(game.sparring_stats.wins)+1)
		game.visited.sparring_won=true
	game.sparring_stats.best_combo=maxi(int(game.sparring_stats.best_combo),mini(99,model.max_combo))
	game.save_checkpoint(false)

func show_result() -> void:
	record_result()
	mode="result"
	release_input()
	set_controls(false)
	var won: bool=model.player_rounds>=2
	title.text="VITÓRIA NO TREINO" if won else "TREINO CONCLUÍDO"
	description.text="Rounds: %d × %d · Melhor combo: %d\nGolpes acertados: %d · Defesas: %d" % [model.player_rounds,model.enemy_rounds,model.max_combo,model.total_hits,model.blocked_hits]
	details.text="Use a defesa contra projéteis e esquive quando perceber a preparação do golpe. Seu resultado foi registrado."
	start_button.text="REVANCHE"
	difficulty_button.show()
	menu_panel.show()

func _process(delta: float) -> void:
	if not active: return
	clock+=delta
	shake=maxf(0,shake-delta*3)
	notice_time=maxf(0,notice_time-delta)
	for effect in hit_effects: effect.life-=delta
	hit_effects=hit_effects.filter(func(effect):return effect.life>0)
	world_canvas.position=Vector2(sin(clock*83),cos(clock*97))*shake*3 if game.cinematic.motion_enabled else Vector2.ZERO
	if mode=="fight" and not paused:
		var actions: Array[String]=queued.duplicate()
		queued.clear()
		var controls_now := {"move":float(held.get("right",false) or keys.get("right",false))-float(held.get("left",false) or keys.get("left",false)),"guard":held.get("guard",false) or keys.get("guard",false),"actions":actions}
		model.advance(delta,controls_now)
		for event in model.take_events():
			if event.kind in ["hit","block","guard_break"]:
				hit_effects.append({"x":event.x,"life":0.45,"kind":event.kind,"damage":event.get("damage",0)})
				game.audio.play("impact")
				shake=0.8 if event.kind=="hit" else 0.35
			elif event.kind=="launch": game.audio.play(event.action)
			elif event.kind=="notice": notice_text=event.text; notice_time=1.5
		if model.phase=="complete": show_result()

func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and active: pause(); release_input()

func _input(event: InputEvent) -> void:
	if not active: return
	if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey:
		if not event.echo:
			var movement_keys := {KEY_A:"left",KEY_LEFT:"left",KEY_D:"right",KEY_RIGHT:"right",KEY_K:"guard"}
			if movement_keys.has(event.physical_keycode): keys[movement_keys[event.physical_keycode]]=event.pressed
			if event.pressed:
				if event.keycode==KEY_ESCAPE:
					if mode=="fight": pause()
					elif mode=="pause": menu_start()
				elif event.keycode==KEY_ENTER and mode!="fight": menu_start()
				elif mode=="fight":
					var actions := {KEY_W:"jump",KEY_UP:"jump",KEY_SPACE:"jump",KEY_J:"light",KEY_L:"heavy",KEY_U:"kunai",KEY_I:"katon",KEY_Q:"dash"}
					if actions.has(event.keycode): queued.append(actions[event.keycode])
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		if event.pressed:
			var candidates: Array=[]
			if mode=="fight": candidates.append(pause_button)
			else: candidates.append_array(menus)
			if mode=="fight": candidates.append_array(controls)
			for button in candidates:
				if button.is_visible_in_tree() and not button.disabled and button.get_global_rect().has_point(event.position):
					var action: String=button.get_meta("action","")
					if action in ["left","right","guard"]:
						pointers[event.index]=action
						held[action]=true
					elif not action.is_empty(): queued.append(action)
					else: button.pressed.emit()
					break
		elif pointers.has(event.index):
			var action: String=pointers[event.index]
			pointers.erase(event.index)
			if not pointers.values().has(action): held.erase(action)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		if pointers.has(event.index):
			var action: String=pointers[event.index]
			for button in controls:
				if button.get_meta("action")==action and not button.get_global_rect().grow(12).has_point(event.position):
					pointers.erase(event.index)
					if not pointers.values().has(action): held.erase(action)
		get_viewport().set_input_as_handled()

func draw_fighter(canvas: Node2D, actor: Dictionary, is_player: bool) -> void:
	var at := Vector2(actor.x,FLOOR-actor.height)
	canvas.draw_set_transform(Vector2(actor.x,FLOOR+3),0,Vector2(1,0.25))
	canvas.draw_circle(Vector2.ZERO,31-maxf(0,actor.height)*0.06,Color(0.035,0.06,0.06,0.34))
	canvas.draw_set_transform(at,0,Vector2(actor.facing,1))
	var tint := Color("f1b7a0") if actor.state=="hurt" else Color.WHITE
	if actor.state=="dash": tint.a=0.65
	if is_player:
		var action := "run" if actor.state=="dash" else "walk" if actor.state=="walk" else "katon" if actor.state=="katon" else "kunai" if actor.state in ["light","heavy","kunai"] else "dodge" if actor.state=="guard" else "idle"
		var frames: Array=game.art.character_art.attached_player.actions[action]
		var index := int(clock*(10 if action in ["walk","run"] else 4))%frames.size()
		if actor.state in model.ACTIONS:
			index=mini(int(actor.elapsed/model.ACTIONS[actor.state].duration*frames.size()),frames.size()-1)
		var frame: Dictionary=frames[index]
		var r: Array=frame.rect
		var origin: Array=frame.origin
		canvas.draw_texture_rect_region(player_texture,Rect2(-Vector2(origin[0],origin[1])*1.45,Vector2(r[2],r[3])*1.45),Rect2(r[0],r[1],r[2],r[3]),tint)
	else:
		var action := "run" if actor.state in ["dash","light","heavy"] else "walk" if actor.state=="walk" else "crouch" if actor.state=="guard" else "idle"
		var frames: Array=mugen[action]
		var frame: Dictionary=frames[int(clock*9)%frames.size()]
		var path: String="res://assets/mugen/naruto/"+str(frame.file)
		if not textures.has(path): textures[path]=load(path)
		var texture: Texture2D=textures[path]
		var axis: Array=frame.axis
		var offset: Array=frame.offset
		canvas.draw_texture_rect(texture,Rect2(Vector2(offset[0]-axis[0],offset[1]-axis[1])*1.1,texture.get_size()*1.1),false,tint)
	canvas.draw_set_transform(Vector2.ZERO)
	if actor.state=="guard": canvas.draw_arc(at+Vector2(actor.facing*22,-65),45,-1.2 if actor.facing>0 else PI-1.2,1.2 if actor.facing>0 else PI+1.2,24,Color(0.5,0.85,1,0.75),3,true)
	if actor.state in ["light","heavy"] and actor.elapsed<model.ACTIONS[actor.state].windup+0.10:
		var progress: float=actor.elapsed/model.ACTIONS[actor.state].duration
		canvas.draw_arc(at+Vector2(actor.facing*42,-62),35+progress*28,-1.3 if actor.facing>0 else PI-1.3,1.0 if actor.facing>0 else PI+1.0,16,Color(1,0.88,0.58,0.8),3,true)

func draw_world(canvas: Node2D) -> void:
	if arena==null: return
	canvas.draw_texture_rect(arena,Rect2(0,0,960,540),false)
	canvas.draw_rect(Rect2(0,0,960,540),Color(0.015,0.035,0.06,0.10))
	draw_fighter(canvas,model.player,true)
	draw_fighter(canvas,model.enemy,false)
	for shot in model.shots:
		var at := Vector2(shot.x,FLOOR-shot.height)
		canvas.draw_set_transform(at,0,Vector2(shot.direction,1))
		if shot.kind=="katon":
			canvas.draw_circle(Vector2.ZERO,40,Color(1,0.4,0.1,0.12))
			canvas.draw_texture_rect(fire_texture,Rect2(-48,-38,90,76),false)
		else:
			canvas.draw_line(Vector2(-48,0),Vector2(-18,0),Color(0.85,0.94,1,0.7),3,true)
			canvas.draw_texture_rect(game.art.KUNAI,Rect2(-16,-7,32,14),false)
		canvas.draw_set_transform(Vector2.ZERO)
	for effect in hit_effects:
		var p: float=1-effect.life/0.45
		var at := Vector2(effect.x,FLOOR-65)
		var color := Color("9de2f1") if effect.kind=="block" else Color("ffca70")
		color.a=1-p
		canvas.draw_arc(at,10+p*42,0,TAU,24,color,3,true)
		for i in range(8):
			var ray := Vector2.RIGHT.rotated(i*TAU/8)
			canvas.draw_line(at+ray*(8+p*12),at+ray*(16+p*32),color,2,true)
		canvas.draw_string(ThemeDB.fallback_font,at+Vector2(-12,-35-p*25),"DEFESA" if effect.kind=="block" else "QUEBRA" if effect.kind=="guard_break" else str(int(effect.damage)),HORIZONTAL_ALIGNMENT_LEFT,-1,16,color)
	if model.enemy.state in model.ACTIONS and model.enemy.elapsed<model.enemy.windup:
		canvas.draw_string(ThemeDB.fallback_font,Vector2(model.enemy.x-56,FLOOR-model.enemy.height-150),"PREPARE-SE",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("ffd58a"))

func bar(canvas: Node2D, rect: Rect2, value: float, color: Color, reverse: bool = false) -> void:
	canvas.draw_rect(rect.grow(2),Color("162a32"))
	canvas.draw_rect(rect,Color("3b3736"))
	var width := rect.size.x*clampf(value/100,0,1)
	canvas.draw_rect(Rect2(rect.position+Vector2(rect.size.x-width if reverse else 0,0),Vector2(width,rect.size.y)),color)

func draw_hud(canvas: Node2D) -> void:
	canvas.draw_rect(Rect2(0,0,960,108),Color(0.025,0.055,0.07,0.94))
	canvas.draw_string(ThemeDB.fallback_font,Vector2(30,29),"HENRIQUE UCHIHA",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("ffe1a2"))
	canvas.draw_string(ThemeDB.fallback_font,Vector2(720,29),"NARUTO · TREINO",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("ffe1a2"))
	bar(canvas,Rect2(30,41,356,18),model.player.hp,Color("8ac17c"))
	bar(canvas,Rect2(574,41,356,18),model.enemy.hp,Color("d99666"),true)
	bar(canvas,Rect2(30,71,220,6),model.player.chakra,Color("76ccd8"))
	bar(canvas,Rect2(710,71,220,6),model.enemy.chakra,Color("76ccd8"),true)
	bar(canvas,Rect2(30,85,155,4),model.player.stamina,Color("d7ba79"))
	bar(canvas,Rect2(205,85,181,4),model.player.guard,Color("adaddb"))
	canvas.draw_string(ThemeDB.fallback_font,Vector2(437,55),"%02d"%int(ceil(model.clock)),HORIZONTAL_ALIGNMENT_LEFT,-1,35,Color("ffedc6"))
	canvas.draw_string(ThemeDB.fallback_font,Vector2(412,86),"MELHOR DE 3",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("c6d0c4"))
	for i in range(2):
		canvas.draw_circle(Vector2(276+i*22,76),7,Color("e8c577") if i<model.player_rounds else Color("34474b"))
		canvas.draw_circle(Vector2(662+i*22,76),7,Color("e8c577") if i<model.enemy_rounds else Color("34474b"))
	canvas.draw_string(ThemeDB.fallback_font,Vector2(30,102),"FÔLEGO",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("d7ba79"))
	canvas.draw_string(ThemeDB.fallback_font,Vector2(205,102),"GUARDA",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("adaddb"))
	if notice_time>0 and mode=="fight":
		canvas.draw_style_box(game.ui.panel_style(),Rect2(230,155,500,32))
		canvas.draw_string(ThemeDB.fallback_font,Vector2(242,177),notice_text,HORIZONTAL_ALIGNMENT_CENTER,476,14,Color("ffe0a3"))
	if model.player.combo>=2:
		canvas.draw_string(ThemeDB.fallback_font,Vector2(30,166),"%d ACERTOS"%model.player.combo,HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("ffe2a1"))
	if mode=="fight" and model.phase in ["intro","round_over"]:
		var text := "ROUND %d"%(model.player_rounds+model.enemy_rounds+1) if model.phase=="intro" else "EMPATE" if model.round_winner=="draw" else "ROUND VENCIDO" if model.round_winner=="player" else "ROUND DO ADVERSÁRIO"
		canvas.draw_style_box(game.ui.panel_style(),Rect2(260,162,440,59))
		canvas.draw_string(ThemeDB.fallback_font,Vector2(285,201),text,HORIZONTAL_ALIGNMENT_CENTER,390,25,Color("ffe1a2"))
