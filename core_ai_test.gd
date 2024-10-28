extends CoreAI


# Called when the node enters the scene tree for the first time.
func _ready():
	# Prepare input data as a PackedFloat32Array
	var input_data = PackedFloat32Array([0.1, 0.2, 0.3, 0.4, 0.5])
	# Call the run_inference method
	var output = run_inference(input_data)
	# Check if output is valid
	if output:
		if output is PackedFloat32Array:
			print("Output from CoreAI: ", output)
		else:
			print("Output is not a PackedFloat32Array")
	else:
		print("No output from CoreAI.")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
