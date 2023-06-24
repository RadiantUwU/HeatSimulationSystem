@tool
extends Resource
class_name HeatObject

@export_enum("Custom",
"Aluminum",
"Boron","Brass","Brick",
"Copper",
"Glass","Gold",
"Helium","Hydrogen",
"Ice","Iron",
"Lead", "Mercury", "Nitrogen", "Wood", "Oxygen",
"Platinum","Plutonium",
"Rubber",
"Sand","Sillicon","Silver","Steel","Steam",
"Thorium","Tungsten",
"Uranium",
"Water") var type:int:
	set = _set_type,
	get = _get_type
@export var capacity:=1.0:
	get:
		if Engine.is_editor_hint() or not _inited:
			return capacity
		else:
			return Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_get_capacity(_id)
	set(v):
		if Engine.is_editor_hint() or not _inited:
			capacity = v
		else:
			Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_set_capacity(_id,v)
@export_range(0,1) var conductivity:=1.0:
	get:
		if Engine.is_editor_hint() or not _inited:
			return conductivity
		else:
			return Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_get_conductivity(_id)
	set(v):
		if Engine.is_editor_hint() or not _inited:
			conductivity = v
		else:
			Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_set_conductivity(_id,v)
@export var mass:=1.0:
	get:
		if Engine.is_editor_hint() or not _inited:
			return mass
		else:
			return Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_get_mass(_id)
	set(v):
		if Engine.is_editor_hint() or not _inited:
			mass = v
		else:
			Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_set_mass(_id,v)
@export var temperature:=273.15:
	get:
		if Engine.is_editor_hint() or not _inited:
			return mass
		else:
			return Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_get_temperature(_id)
	set(v):
		if Engine.is_editor_hint() or not _inited:
			mass = v
		else:
			Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_set_temperature(_id,v)
@export var neighbors:Array[HeatObject]=[]:
	get:
		if Engine.is_editor_hint() or not _inited:
			return neighbors
		else:
			push_error("neighbors property is locked, please use add_neighbor() or remove_neighbor()")
			return []
var _id:=0
var _inited:=false
func _add_neighbors()->void:
	var heatsim:Node=Engine.get_main_loop().root.get_node("HeatSimulationServer")
	for i in neighbors:
		if not heatsim.heatobject_is_neighbor(_id,i._id):
			heatsim.heatobject_add_neighbor(_id,i._id)
	_inited = true
func _init()->void:
	if not Engine.is_editor_hint():
		var heatsim:Node=Engine.get_main_loop().root.get_node("HeatSimulationServer")
		_id = heatsim.heatobject_create()
		if type == 0:
			heatsim.heatobject_set_capacity(_id,capacity)
		else:
			heatsim.heatobject_set_capacity_type(_id,type)
		heatsim.heatobject_set_conductivity(_id,conductivity)
		heatsim.heatobject_set_temperature(_id,temperature)
		_add_neighbors.call_deferred()
func _destruct()->void:
	Engine.get_main_loop().root.get_node("HeatSimulationServer").free_id(_id)
func _notification(what)->void:
	if self == null: return
	if what == NOTIFICATION_PREDELETE:
		_destruct()
func get_id()->int:
	return _id
func _get_type()->int:
	if Engine.is_editor_hint() or not _inited:
		return type
	else:
		return Engine.get_main_loop().root.get_node("/root/HeatSimulationServer").heatobject_get_capacity_type(get_id())
func _set_type(v: int)->void:
	if Engine.is_editor_hint() or not _inited:
		type = v
		if v != 0:
			capacity = preload("res://addons/heatsystem/HeatSimulationServer.gd")._capacities_table[v]
	else:
		Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_set_capacity_type(get_id(),v)

func add_neighbor(o: HeatObject)->void:
	Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_add_neighbor(_id,o.get_id())
func remove_neighbor(o: HeatObject)->void:
	Engine.get_main_loop().root.get_node("HeatSimulationServer").heatobject_remove_neighbor(_id,o.get_id())
