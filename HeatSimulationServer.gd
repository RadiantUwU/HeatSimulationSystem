@tool
extends Node

const _heatobj_class:=preload("res://addons/heatsystem/HeatObject.gd")

enum CapacityType {
	CUSTOM=0,
	
	ALUMINUM=1,
	BORON,BRASS,BRICK,
	COPPER,
	GLASS,GOLD,
	HELIUM,HYDROGEN,
	ICE,IRON,
	LEAD,
	MERCURY,
	NITROGEN,
	WOOD,
	OXYGEN,
	PLATINUM,PLUTONIUM,
	RUBBER,
	SAND,SILLICON,SILVER,STEEL,STEAM,
	THORIUM,TUNGSTEN,
	URANIUM,
	WATER
}
	
const _capacities_table: PackedFloat32Array=[
	0,
	887,
	1106,
	920,
	841,
	385,
	792,
	130,
	5192,
	14300,
	2090,
	462,
	131,
	126,
	1040,
	2380,
	919,
	150,
	140,
	2005,
	881,
	710,
	236,
	468,
	2094,
	118,
	133,
	115,
	4187
]

var _dict:={}

var _mtx:=Mutex.new()

func _destruct()->void:
	_mtx.lock()
	_dict.clear()
	_mtx.unlock()

func get_instances()->int:
	_mtx.lock()
	var l:int = len(_dict)
	_mtx.unlock()
	return l

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_destruct()

static func _temp_update_one(s:Dictionary,o:Dictionary,delta: float) -> void:
	var l:=len(s["neighbors"])
	var c:float = clampf(o["conductivity"]*s["conductivity"],0,1)
	var st:float = s["temperature"]
	var sc:float = s["capacity"]
	var ot:float = o["temperature"]
	var oc:float = o["capacity"]
	var ntt:float = (st*sc+ot*oc)/(sc+oc)
	var nc:=minf(delta,1)*c
	#var nc:=c
	var nt:float = st*(1-nc)+ntt*nc
	s["_newtemp"] += nt/l

func heatobject_create()->int:
	_mtx.lock()
	var id:=randi()
	while id in _dict:
		id=randi()
	var table := {
		"neighbors":[],
		"conductivity":1.0,
		"capacity":1.0,
		"mass":1.0,
		"temperature":273.15,
		"_newtemp":0.0
	}
	_dict[id]=table
	_mtx.unlock()
	return id
func free_id(id: int)->void:
	_mtx.lock()
	if _dict.has(id):
		var table: Dictionary = _dict[id]
		for oid in table["neighbors"]:
			_dict[oid]["neighbors"].erase(id)
		_dict.erase(id)
	else:
		push_error("id "+str(id)+" is not registered.")
		breakpoint
	_mtx.unlock()

func _heatobject_update(o: int,delta: float)->void:
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return
	var table:Dictionary=_dict[o]
	var length:=len(table["neighbors"])
	if length > 0:
		table["_newtemp"]=0.0
		for id in table["neighbors"]:
			_temp_update_one(table,_dict[id],delta)
	else:
		table["_newtemp"]=table["temperature"]
func heatobject_update(delta: float)->void:
	_mtx.lock()
	for obj in _dict:
		_heatobject_update(obj,delta*10)
	for table in _dict.values():
		table["temperature"]=table["_newtemp"]
	_mtx.unlock()

func heatobject_get_temperature(o: int)->float:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return NAN
	var f:float = _dict[o]["temperature"]
	_mtx.unlock()
	return f
func heatobject_set_temperature(o: int,temp: float)->void:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return
	_dict[o]["temperature"]=temp
	_mtx.unlock()

func heatobject_set_capacity(o: int,cap: float)->void:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return
	_dict[o]["capacity"]=cap
	_mtx.unlock()
func heatobject_get_capacity(o: int)->float:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return NAN
	var f:float = _dict[o]["capacity"]
	_mtx.unlock()
	return f

func heatobject_set_conductivity(o: int,cap: float)->void:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return
	_dict[o]["conductivity"]=cap
	_mtx.unlock()
func heatobject_get_conductivity(o: int)->float:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return NAN
	var f:float = _dict[o]["conductivity"]
	_mtx.unlock()
	return f

func heatobject_set_mass(o: int,mass: float)->void:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return
	_dict[o]["mass"]=mass
	_mtx.unlock()
func heatobject_get_mass(o: int)->float:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return NAN
	var f:float = _dict[o]["mass"]
	_mtx.unlock()
	return f

func heatobject_set_capacity_type(o: int,cap: CapacityType)->void:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return
	_dict[o]["capacity"]=_capacities_table[cap]
	_mtx.unlock()
func heatobject_get_capacity_type(o: int)->CapacityType:
	_mtx.lock()
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return CapacityType.CUSTOM
	var f:float = _dict[o]["capacity"]
	_mtx.unlock()
	if f in _capacities_table:
		return _capacities_table.find(f) as CapacityType
	return CapacityType.CUSTOM

func heatobject_add_neighbor(o: int,n: int)->bool:
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return false
	if not _dict.has(n):
		push_error("object "+str(n)+" does not exist.")
		breakpoint
		return false
	if o==n:
		push_error("cannot make object neighbor itself")
		return false
	var tbl1:Dictionary=_dict[o]
	var tbl2:Dictionary=_dict[n]
	if n in tbl1["neighbors"]:
		push_error("object is already neighbor of other object.")
		return false
	tbl1["neighbors"].append(n)
	tbl2["neighbors"].append(o)
	return true
func heatobject_is_neighbor(o: int,n: int)->bool:
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return false
	if not _dict.has(n):
		push_error("object "+str(n)+" does not exist.")
		breakpoint
		return false
	if o==n:
		push_error("cannot make object neighbor itself")
		return false
	var tbl1:Dictionary=_dict[o]
	var tbl2:Dictionary=_dict[n]
	return n in tbl1["neighbors"]
func heatobject_remove_neighbor(o: int,n: int)->bool:
	if not _dict.has(o):
		push_error("object "+str(o)+" does not exist.")
		breakpoint
		return false
	if not _dict.has(n):
		push_error("object "+str(n)+" does not exist.")
		breakpoint
		return false
	if o==n:
		push_error("cannot make object remove itself as a neighbor")
		return false
	var tbl1:Dictionary=_dict[o]
	var tbl2:Dictionary=_dict[n]
	if n not in tbl1["neighbors"]:
		push_error("object is not a neighbor of other object.")
		return false
	tbl1["neighbors"].erase(n)
	tbl2["neighbors"].erase(o)
	return true

func _physics_process(delta: float):
	heatobject_update(delta)
