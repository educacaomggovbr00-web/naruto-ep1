extends Control

const ZONE_START := 0.38
const ZONE_END := 0.66
const SPEED := 0.48
const GAUGE := Rect2(204,236,552,36)
var game: Node2D
var phase := 0.08
var direction := 1.0
var successes := 0
var tap_lock := 0.0
var paused := false
var finished := false
var feedback: Label
var counter: Label
var confirm_button: Button
var close_button: Button
var portrait: TextureRect
var gauge: Node2D

func _ready() -> void:
	size=Vector2(960,540)
	z_index=55
	var shade:=ColorRect.new()
	shade.size=size
	shade.color=Color(0.025,0.055,0.07,0.82)
	add_child(shade)
	var panel:=Panel.new()
	panel.position=Vector2(164,92)
	panel.size=Vector2(632,386)
	panel.add_theme_stylebox_override("panel",game.ui.panel_style())
	add_child(panel)
	portrait=TextureRect.new()
	portrait.position=Vector2(24,16)
	portrait.size=Vector2(68,86)
	portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel.add_child(portrait)
	game.ui.child_label(panel,"CONTROLE DE CHAKRA",Vector2(110,18),Vector2(498,30),23,Color("f0ce8a"))
	var instructions:Label=game.ui.child_label(panel,"Iruka: Toque quando o marcador entrar na faixa dourada.\nVamos praticar três vezes.",Vector2(110,58),Vector2(490,50),15,Color("c3d0c5"))
	instructions.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	instructions.size=Vector2(490,50)
	game.ui.child_label(panel,"CONCENTRAÇÃO  ·  FAIXA DOURADA = MOMENTO CERTO",Vector2(40,116),Vector2(552,20),11,Color("d4b87f"))
	counter=game.ui.child_label(panel,"",Vector2(40,198),Vector2(552,24),17,Color("f5e7c7"))
	feedback=game.ui.child_label(panel,"",Vector2(40,234),Vector2(552,44),14,Color("c3d0c5"))
	feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	confirm_button=make_button(panel,"CONCENTRAR · E",Vector2(40,290),Vector2(350,54))
	confirm_button.pressed.connect(confirm)
	close_button=make_button(panel,"SAIR · ESC",Vector2(412,290),Vector2(180,54))
	close_button.pressed.connect(close)
	game.ui.child_label(panel,"AULA OPCIONAL  ·  Sem custo de chakra. Esc para sair.",Vector2(40,359),Vector2(552,18),11,Color("aebfb9"))
	gauge=Node2D.new()
	gauge.draw.connect(_draw_gauge)
	add_child(gauge)
	hide()

func make_button(parent: Node, caption: String, at: Vector2, dimensions: Vector2) -> Button:
	var button:=Button.new()
	button.text=caption
	button.position=at
	button.size=dimensions
	game.style_button(button)
	button.add_theme_font_size_override("font_size",15)
	parent.add_child(button)
	return button

func start() -> void:
	if game.ui.modal_open() or not game.lines.is_empty(): return
	if game.stage!=2 or game.room!="academy": return
	if not game.visited["class_intro"] or not game.visited["board"]: return
	if portrait.texture==null:
		var atlas:=AtlasTexture.new()
		atlas.atlas=game.art.character_art.get_cast_texture()
		var crop:Array=game.art.character_art.attached_cast["actors"]["Iruka"]["portrait"]
		atlas.region=Rect2(crop[0],crop[1],crop[2],crop[3])
		portrait.texture=atlas
	phase=0.08
	direction=1.0
	successes=0
	tap_lock=0
	paused=false
	finished=false
	feedback.text="Respire, acompanhe o marcador e concentre o chakra na faixa dourada."
	confirm_button.text="CONCENTRAR · E"
	counter.text="0 / 3 acertos"
	game.ui.release_touches()
	game.movement=Vector2.ZERO
	game.sprinting=false
	game.dash_time=0
	game.attack_flash=0
	show()
	game.ui.refresh_controls()
	gauge.queue_redraw()

func _process(delta: float) -> void:
	if not visible or paused: return
	if finished:
		tap_lock=maxf(0,tap_lock-delta)
		return
	var remaining:=delta
	if tap_lock>0:
		var used:=minf(remaining,tap_lock)
		tap_lock-=used
		remaining-=used
		if tap_lock<=0.000001:
			tap_lock=0
			feedback.text="Observe a faixa dourada e concentre novamente."
	if remaining>0:
		# A triangular wave handles long frames without clamping the cursor at an edge.
		var travel:=phase if direction>0 else 2.0-phase
		travel=fposmod(travel+remaining*SPEED,2.0)
		phase=travel if travel<1.0 else 2.0-travel
		direction=1.0 if travel<1.0 else -1.0
	gauge.queue_redraw()

func confirm() -> void:
	if not visible: return
	if finished:
		if tap_lock>0: return
		close()
		return
	if paused:
		paused=false
		tap_lock=0.25
		confirm_button.text="CONCENTRAR · E"
		feedback.text="Treino retomado. Encontre o ritmo da faixa dourada."
		return
	if tap_lock>0: return
	tap_lock=0.45
	if phase>=ZONE_START and phase<=ZONE_END:
		successes+=1
		game.audio.play("focus")
		counter.text="%d / 3 acertos" % successes
		feedback.text="Iruka: Isso. Mantenha a calma e repita o controle."
		if successes<3:
			phase=0.08
			direction=1.0
		if successes==3:
			finished=true
			game.visited["chakra_drill"]=true
			var saved:bool=game.save_checkpoint(false)
			feedback.text="Iruka: Bom controle, Henrique. Continue praticando assim."
			counter.text="TREINO CONCLUÍDO · Anotação no diário"
			confirm_button.text="VOLTAR À SALA · E"
			if game.savegame.enabled and not saved:
				feedback.text+=" Não foi possível salvar agora; tente em AJUSTES."
	else:
		feedback.text="Ainda fora da faixa. Seus acertos continuam; tente novamente."
	gauge.queue_redraw()

func close() -> void:
	hide()
	paused=false
	game.ui.release_touches()
	game.ui.refresh_controls()

func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and visible and not finished:
		paused=true
		feedback.text="Treino pausado. Toque em RETOMAR quando estiver pronto."
		confirm_button.text="RETOMAR · E"

func _draw_gauge() -> void:
	if not visible: return
	gauge.draw_style_box(game.polish.panel(),GAUGE.grow(3))
	gauge.draw_rect(GAUGE,Color("304c58"))
	gauge.draw_rect(Rect2(GAUGE.position+Vector2(GAUGE.size.x*ZONE_START,0),Vector2(GAUGE.size.x*(ZONE_END-ZONE_START),GAUGE.size.y)),Color("b79450"))
	var x:=GAUGE.position.x+GAUGE.size.x*phase
	gauge.draw_line(Vector2(x,GAUGE.position.y-6),Vector2(x,GAUGE.end.y+6),Color("fff1c9"),4,true)
	gauge.draw_colored_polygon(PackedVector2Array([Vector2(x-6,GAUGE.position.y-12),Vector2(x+6,GAUGE.position.y-12),Vector2(x,GAUGE.position.y-5)]),Color("fff1c9"))
