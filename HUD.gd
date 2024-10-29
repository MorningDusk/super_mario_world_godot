extends CanvasLayer

var coins_label = get_node_or_null("CoinsLabel")
var lives_label = get_node_or_null("LivesLabel")
var level_label = get_node_or_null("LevelLabel")

func _ready():
	await ready  # 모든 노드가 준비될 때까지 대기
	update_hud()

func update_hud():
	
	if coins_label:
		coins_label.text = str(Global.coins)
	if lives_label:
		lives_label.text = "x" + str(Global.lives)
	if level_label:
		level_label.text = "LEVEL " + str(Global.level)
