extends RigidBody3D
class_name Entity3D

@onready var dialog_entity = DialogEntity.new($SubViewport/DialogBubble/RichTextLabel, $SubViewport/DialogBubble/Choices, $SubViewport/DialogBubble)

func _ready():
	$Sprite3D.show()
	add_child(dialog_entity)
