@tool
extends EditorPlugin


var _starting_visibility = {}
var _dock: Node


func _enter_tree() -> void:
	_dock = preload("res://addons/togglecollisionshape2ds/dock.tscn").instantiate()
	var checkbox = _dock.get_node("%CheckBox")
	checkbox.toggled.connect(_on_toggle_visibility)
	add_control_to_dock(DOCK_SLOT_LEFT_UL, _dock)


func _on_toggle_visibility(hide: bool) -> void:
	for node in _get_nodes_recursively():
		if hide:
			_starting_visibility[node] = node.visible
			node.visible = false
		else:
			if node in _starting_visibility:
				node.visible = _starting_visibility[node]
			else:
				node.visible = true

func _get_nodes_recursively(node: Node = null, type: Variant = CollisionShape2D) -> Array:
	var ret = []
	if node == null:
		node = get_tree().edited_scene_root
	if is_instance_of(node, type):
		ret.append(node)
	for child in node.get_children():
		ret += _get_nodes_recursively(child, type)
	return ret


func _exit_tree() -> void:
	for node in _starting_visibility:
		if is_instance_valid(node):
			node.visible = _starting_visibility[node]
	remove_control_from_docks(_dock)
	_dock.free()
