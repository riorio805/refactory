extends RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = """\
🪨Iron			%d
[color="gold"]✨Gold[/color]			%d
[color="mediumpurple"]🔮Iridium[/color]		%d""" % [Player.iron, Player.gold, Player.iridium]
	pass

#🪨Iron			a
#[color="gold"]✨Gold[/color]			a
#[color="purple"]🔮Iridium[/color]		a
#[color="lightblue"]💎Diamond[/color]	%
