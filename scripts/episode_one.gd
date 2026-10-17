extends RefCounted

# Story beats are separate from the original prologue stages so v1 saves survive.
var step := 0
var echo_time := 0.0
const SEAT := Vector2(365,285)
const EXAM := Vector2(480,335)
const CLASS_NARUTO := Vector2(575,335)
const MIZUKI := Vector2(590,220)
const TITLES := ["", "Uma manhã em casa", "O caminho para a aula", "Seu lugar na sala", "A avaliação de clonagem", "Naruto no pátio", "De volta para casa", "O fim da aula"]
const GOALS := ["", "Saia de casa e vá à Academia.", "Entre na Academia e fale com Iruka.", "Aproxime-se do lugar marcado e use AÇÃO.", "Vá até o círculo à frente de Iruka e use AÇÃO.", "Saia da Academia e encontre Naruto na praça.", "Volte para casa e examine seus cadernos.", "A manhã terminou. Você pode explorar Konoha."]

func active() -> bool:
	return step > 0

func begin(game: Node2D) -> void:
	if step != 0 or game.stage != 6 or not game.lines.is_empty(): return
	game.world.district="plaza"
	game.layout.district="plaza"
	step=1
	game.stage=2
	game.room="home"
	game.visited.home=true
	game.player=Vector2(730,282)
	game.return_position=Vector2(110,270)
	game.facing=Vector2.DOWN
	game.restart.hide()
	game.day_cycle.set_mode(1)
	game.day_cycle.phase=7.5/24.0
	game.combat.reset()
	game.background.set_area(2,"home",false)
	game.audio.set_night(false)
	game.audio.set_indoor(true)
	game.say(["EPISÓDIO 1 — Uma manhã na Academia", "A luz atravessa a janela. O sonho da noite anterior se desfaz, e os primeiros passos dos moradores chegam da rua.", "Sobre a mesa, os materiais da Academia estão prontos. Hoje é dia de avaliação."])
	game.save_checkpoint(false)

func room_entered(game: Node2D) -> void:
	if step==1 and game.room=="outside": step=2

func extra_actors(game: Node2D) -> Dictionary:
	if game.room=="outside" and game.world.district!="plaza": return {}
	if not active(): return {}
	if game.room=="academy":
		var actors:Dictionary={"Mizuki":MIZUKI}
		if step<=4: actors["Naruto"]=CLASS_NARUTO
		return actors
	if game.room=="outside" and step==5: return {"Mizuki":Vector2(740,265)}
	return {}

func interact(game: Node2D) -> bool:
	if not active(): return false
	if game.room=="academy":
		if game.player.distance_to(game.layout.interiors.ROOMS.academy.actors.Iruka)<62:
			if step<=2:
				game.visited.class_intro=true
				step=3
				game.say(["Iruka: Bom dia, Henrique. Pode entrar. Estamos esperando a turma se acomodar.", "Naruto: Hoje eu passo! Vocês vão ver!", "Sakura: Naruto, dá para falar mais baixo?", "Iruka: Cada um no seu lugar. Vou explicar a avaliação."])
			elif step==3: game.say(["Iruka: Seu lugar está no corredor à esquerda, Henrique. A aula já vai começar."])
			elif step==4: game.say(["Iruka: Pode vir até o centro da sala. Vamos avaliar o Bunshin no Jutsu."])
			else: game.say(["Iruka: Por hoje é só. Amanhã conversamos sobre os próximos passos."])
		elif step==3 and game.player.distance_to(SEAT)<43:
			step=4
			game.say(["Henrique chega ao seu lugar. O som das conversas diminui quando Iruka se volta para a turma.", "Iruka: A avaliação de hoje é o Bunshin no Jutsu. Vou chamar um aluno de cada vez.", "Sasuke faz sua demonstração e volta ao lugar. Sakura é chamada em seguida.", "Iruka: Henrique Uchiha. Sua vez."])
		elif step==4 and game.player.distance_to(EXAM)<43:
			step=5
			echo_time=4.0
			game.say(["Henrique reúne chakra. Ao seu lado, a imagem de um clone toma forma por um instante.", "Iruka: Certo. Pode desfazer a técnica e aguardar lá fora.", "Depois da sua avaliação, Naruto tenta criar o próprio clone. A imagem surge caída, sem conseguir se manter.", "Iruka: Naruto... desta vez você não passou.", "Naruto sai em silêncio. Da porta, Mizuki acompanha o movimento dos alunos."])
		elif game.player.distance_to(MIZUKI)<55:
			game.say(["Mizuki: A avaliação deixou a turma agitada. Iruka se preocupa muito com vocês."])
		elif step<=4 and game.player.distance_to(CLASS_NARUTO)<55:
			game.say(["Naruto: Eu treinei! Dessa vez eu vou conseguir a bandana."])
		elif game.player.distance_to(game.layout.interiors.ROOMS.academy.actors.Sasuke)<62:
			game.say(["Sasuke: ...", "Sasuke mantém os olhos à frente, esperando a chamada de Iruka."])
		elif game.player.distance_to(game.layout.interiors.ROOMS.academy.actors.Sakura)<62:
			game.say(["Sakura: Estou tentando lembrar todos os selos. Você também está esperando sua vez?"])
		elif game.player.distance_to(EXAM)<43:
			game.say(["A avaliação terminou. As carteiras começam a ficar vazias."])
		else: return false
	elif game.room=="outside" and step>=5 and game.player.distance_to(game.layout.NARUTO)<95:
		if step==5:
			step=6
			game.say(["Naruto está afastado dos grupos que comemoram a aprovação. Por um momento, ele olha para a Academia.", "Naruto: Não precisa ficar aqui por minha causa. Eu vou dar um jeito.", "Mizuki: Naruto, posso conversar com você depois? Talvez eu consiga ajudar.", "Naruto ergue os olhos. Mizuki espera a praça esvaziar antes de continuar.", "O movimento da saída da aula diminui. Seus cadernos ficaram em casa; você pode voltar para organizar o que aprendeu."])
		else: game.say(["Naruto: Vou ficar por aqui mais um pouco."])
	elif game.room=="home" and game.player.distance_to(Vector2(225,220))<60:
		game.visited.notes=true
		if step==6:
			step=7
			game.day_cycle.mode=0
			game.day_cycle.phase=11.0/24.0
			game.say(["Os cadernos ainda estão abertos na página de clonagem. Ao lado, há espaço para as anotações da aula.", "A manhã termina com o exame para trás e a conversa de Naruto com Mizuki ainda na sua memória.", "FIM DESTA PARTE — A promessa de Mizuki continua na próxima etapa. Você pode continuar explorando a vila."])
		else: game.say(["As anotações registram a aula de hoje: concentração, selos e clonagem."])
	elif game.room=="home" and game.player.distance_to(Vector2(730,282))<65:
		game.say(["A luz da manhã ainda entra pela janela. O dia está apenas começando."])
	else: return false
	game.save_checkpoint(false)
	return true

func prompt(game: Node2D) -> String:
	if not active(): return ""
	if game.room=="academy":
		if step==3 and game.player.distance_to(SEAT)<43: return "Acompanhar a aula"
		if step==4 and game.player.distance_to(EXAM)<43: return "Demonstrar clonagem"
		for name_text in extra_actors(game):
			if game.player.distance_to(extra_actors(game)[name_text])<55: return "Conversar com "+name_text
		if game.player.distance_to(EXAM)<43: return "Observar a sala"
	return ""

func update(game: Node2D, delta: float) -> void:
	if not active(): return
	# Keep the morning coherent while the lesson unfolds, even during exploration.
	if step<7: game.day_cycle.phase=7.5/24.0
	if echo_time>0 and game.lines.is_empty(): echo_time=maxf(0,echo_time-delta)

func draw(game: Node2D) -> void:
	if not active() or game.room!="academy": return
	var at:=SEAT if step==3 else EXAM
	if step in [3,4]:
		game.draw_arc(at+Vector2(0,14),24,0,TAU,32,Color(0.95,0.79,0.42,0.8),2,true)
		game.art.marker(game,at+Vector2(0,55),game.visual_clock)
	if echo_time>0 and step==5:
		# Bunshin uses the original character art; no invented sprite frames.
		var original:Vector2=game.player
		game.player=original+Vector2(70,0)
		game.art.character_art.draw_henrique(game)
		game.player=original
