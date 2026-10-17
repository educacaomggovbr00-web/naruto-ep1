extends Control

const CHAPTERS := ["Precisão com kunai", "Controle de chakra", "Encontro na vila", "Rastros na floresta", "A kunai encontrada", "Volta para casa"]
const DISCOVERIES := [
	["academy", "Conhecer a Academia"], ["class_intro", "Conversar com Iruka"],
	["board", "Ler a revisão no quadro"], ["home", "Visitar sua casa"],
	["notes", "Examinar seus cadernos"], ["chakra_drill", "Praticar controle de chakra"]
]

var game: Node2D
var errand_label:Label
var chapter_title: Label
var mission: Label
var guidance: Label
var progress: ProgressBar
var progress_label: Label
var chapter_rows: Array[Label] = []
var discovery_rows: Array[Label] = []
var discovery_label: Label
var close_button: Button

func _ready() -> void:
	size=Vector2(960,540)
	z_index=50
	var shade:=ColorRect.new()
	shade.color=Color(0.025,0.055,0.07,0.87)
	shade.size=size
	add_child(shade)
	var panel:=Panel.new()
	panel.position=Vector2(82,76)
	panel.size=Vector2(796,430)
	panel.add_theme_stylebox_override("panel",game.ui.panel_style())
	add_child(panel)
	text(panel,"DIÁRIO SHINOBI",Vector2(26,17),Vector2(420,30),24,Color("f0ce8a"))
	chapter_title=text(panel,"HENRIQUE UCHIHA  /  A NOITE ANTES DO COMEÇO",Vector2(27,51),Vector2(520,20),11,Color("aebfb9"))
	close_button=Button.new()
	close_button.text="VOLTAR  ·  M"
	close_button.position=Vector2(638,36)
	close_button.size=Vector2(132,44)
	game.style_button(close_button)
	close_button.add_theme_font_size_override("font_size",13)
	close_button.pressed.connect(close)
	panel.add_child(close_button)
	var rule:=ColorRect.new()
	rule.position=Vector2(26,82)
	rule.size=Vector2(744,1)
	rule.color=Color("64736a")
	rule.mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel.add_child(rule)
	text(panel,"OBJETIVO ATUAL",Vector2(27,96),Vector2(430,19),11,Color("d4b87f"))
	mission=text(panel,"",Vector2(27,120),Vector2(435,48),19,Color("f5e7c7"))
	mission.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	guidance=text(panel,"",Vector2(27,174),Vector2(435,92),14,Color("c3d0c5"))
	guidance.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	progress_label=text(panel,"",Vector2(27,275),Vector2(435,20),11,Color("d4b87f"))
	progress=ProgressBar.new()
	progress.position=Vector2(27,302)
	progress.size=Vector2(435,7)
	progress.max_value=6
	progress.show_percentage=false
	for state in ["background","fill"]:
		var style:=StyleBoxFlat.new()
		style.bg_color=Color("d8bd80") if state=="fill" else Color("324b50")
		style.set_corner_radius_all(3)
		progress.add_theme_stylebox_override(state,style)
	panel.add_child(progress)
	# Apply size after replacing theme styles, which initially enforce a taller bar.
	progress.size=Vector2(435,7)
	for i in range(6):
		var row:=text(panel,"",Vector2(27+(i%2)*223,324+(i/2)*23),Vector2(218,21),12,Color.WHITE)
		chapter_rows.append(row)
	text(panel,"EXPLORAÇÃO OPCIONAL",Vector2(501,96),Vector2(269,20),11,Color("d4b87f"))
	discovery_label=text(panel,"",Vector2(501,123),Vector2(269,26),17,Color("f5e7c7"))
	for i in range(DISCOVERIES.size()):
		var row:=text(panel,"",Vector2(501,164+i*29),Vector2(269,29),14,Color.WHITE)
		discovery_rows.append(row)
	errand_label=text(panel,"Estas visitas não bloqueiam a história.\nAs anotações acompanham o save local.",Vector2(501,349),Vector2(267,48),12,Color("aebfb9"))
	errand_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	text(panel,"JOGO PAUSADO  ·  Consulte as anotações com calma.",Vector2(27,403),Vector2(744,18),11,Color("aebfb9"))
	hide()

func text(parent: Node, value: String, at: Vector2, dimensions: Vector2, font_size: int, color: Color) -> Label:
	return game.ui.child_label(parent,value,at,dimensions,font_size,color)

func toggle() -> void:
	if visible:
		close()
		return
	if game.ui.modal_open() or not game.lines.is_empty(): return
	game.ui.release_touches()
	game.movement=Vector2.ZERO
	game.sprinting=false
	game.dash_time=0
	game.attack_flash=0
	refresh()
	show()
	game.ui.refresh_controls()

func close() -> void:
	hide()
	game.ui.release_touches()
	game.ui.refresh_controls()

func refresh() -> void:
	errand_label.text="ENTREGA OPCIONAL · Converse com o comerciante na praça para conhecer a encomenda."
	if game.visited.parcel_started: errand_label.text="ENTREGA · Leve o pacote ao Teuchi, no Ichiraku à direita da praça."
	if game.visited.parcel_delivered: errand_label.text="✓ ENTREGA · Pacote entregue a Teuchi. O lámen recuperou seus recursos."
	chapter_title.text="HENRIQUE UCHIHA  /  EPISÓDIO 1 · A MANHÃ NA ACADEMIA" if game.episode.active() else "HENRIQUE UCHIHA  /  A NOITE ANTES DO COMEÇO"
	var stage:int=game.stage
	mission.text="Prólogo concluído" if stage==6 else CHAPTERS[stage]
	if stage==0: mission.text+="  ·  %d / 3" % game.hits
	guidance.text=hint()
	progress.value=mini(stage,6)
	progress_label.text="CAMINHO DO PRÓLOGO  ·  %d / 6 OBJETIVOS CONCLUÍDOS" % mini(stage,6)
	for i in range(CHAPTERS.size()):
		var known:bool=i<=stage
		var mark: String="✓" if i<stage else "›" if i==stage else "·"
		chapter_rows[i].text=mark+"  "+(CHAPTERS[i] if known else "Ainda não revelado")
		chapter_rows[i].modulate=Color("b4d5b4") if i<stage else Color("f0ce8a") if i==stage else Color("829896")
	if game.episode.active():
		mission.text=game.episode.TITLES[game.episode.step]
		guidance.text=game.episode.GOALS[game.episode.step]+" Use E / AÇÃO perto das pessoas e dos pontos marcados. A saída das salas fica embaixo."
		progress.max_value=6
		progress.value=game.episode.step-1
		progress_label.text="EPISÓDIO 1 · %d / 6 ETAPAS CONCLUÍDAS" % (game.episode.step-1)
		for i in range(6):
			var known:bool=i+1<=game.episode.step
			chapter_rows[i].modulate=Color("b4d5b4") if i+1<game.episode.step else Color("f0ce8a") if i+1==game.episode.step else Color("829896")
			chapter_rows[i].text=("✓  " if i+1<game.episode.step else "›  ")+(game.episode.TITLES[i+1] if known else "Ainda não revelado")
	var found:=0
	for i in range(DISCOVERIES.size()):
		var done:bool=game.visited.get(DISCOVERIES[i][0],false)
		if done: found+=1
		discovery_rows[i].text=("✓  " if done else "○  ")+(DISCOVERIES[i][1] if stage>=2 or done else "A descobrir na vila")
		discovery_rows[i].modulate=Color("b4d5b4") if done else Color("aebfb9")
	discovery_label.text="%d de %d anotações" % [found,DISCOVERIES.size()]

func hint() -> String:
	match game.stage:
		0: return "Olhe para o alvo e lance com J / KUNAI. Alcance: 280 passos. Só o contato conta como acerto; ajuste a direção se errar."
		1: return "Olhe para o alvo e use K / KATON. Alcance: 220 passos. Cada tentativa usa 25 de chakra, recuperado com o tempo."
		2:
			if game.room!="outside": return "A saída fica no centro da parte de baixo. Volte à praça para encontrar Naruto, à direita da Academia. Use E / AÇÃO perto dele."
			return "Naruto espera à direita da Academia, na praça. Aproxime-se e use E / AÇÃO. Antes de conversar, você pode visitar a Academia e sua casa."
		3: return "Mantenha de 70 a 230 passos de Mizuki. Ative FURTIVO para se aproximar em silêncio. Acompanhe-o por 12 segundos. Progresso: %d%%." % int(game.trail_progress/12.0*100)
		4: return "Aproxime-se da kunai marcada no chão da floresta e use E / AÇÃO para investigar."
		5:
			if game.room=="home": return "Contorne a mesa pelo lado direito. Aproxime-se da cama, na parte superior direita, e use E / AÇÃO para descansar."
			return "Volte à casa sinalizada à esquerda da vila. Use E / AÇÃO na porta para entrar. Depois, aproxime-se da cama para descansar."
		_: return "Você completou A Noite Antes do Começo. Use CONTINUAR HISTÓRIA para acordar em casa e jogar a manhã na Academia."
