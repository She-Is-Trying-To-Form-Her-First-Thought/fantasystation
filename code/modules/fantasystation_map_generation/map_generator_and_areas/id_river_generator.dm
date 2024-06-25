GLOBAL_LIST_EMPTY(tagged_river_nodes)

/proc/spawn_rivers_by_marker_id(target_node_id, target_z, whitelist_area)
	var/turf/open/edge_turf = /turf/open/misc/muck_slop
	var/turf/open/shallow_turf = /turf/open/water/vintage
	var/turf/open/deep_turf = /turf/open/water/vintage/deep

	var/list/turfs_to_mud = list()
	var/list/turfs_to_shallow = list()
	var/list/turfs_to_deep = list()

	var/list/river_nodes = list()

	for(var/obj/effect/landmark/river_waypoint/fantasystation/river_node in GLOB.tagged_river_nodes)
		if(river_node.id_tag == target_node_id)
			river_nodes += river_node

	//make some randomly pathing rivers
	for(var/obj/effect/landmark/river_waypoint/waypoints as anything in river_nodes)
		if (waypoints.z != target_z || waypoints.connected)
			continue
		waypoints.connected = TRUE
		// Workaround around ChangeTurf that's safe because of when this proc is called
		var/turf/cur_turf = get_turf(waypoints)
		cur_turf = new turf_type(cur_turf)
		var/turf/target_turf = get_turf(pick(river_nodes - waypoints))
		if(!target_turf)
			break
		var/detouring = FALSE
		var/cur_dir = get_dir(cur_turf, target_turf)
		while(cur_turf != target_turf)

			if(detouring) //randomly snake around a bit
				if(prob(20))
					detouring = FALSE
					cur_dir = get_dir(cur_turf, target_turf)
			else if(prob(20))
				detouring = TRUE
				if(prob(50))
					cur_dir = turn(cur_dir, 45)
				else
					cur_dir = turn(cur_dir, -45)
			else
				cur_dir = get_dir(cur_turf, target_turf)

			cur_turf = get_step(cur_turf, cur_dir)
			var/area/new_area = get_area(cur_turf)
			turfs_to_mud += cur_turf

	for(var/turf/turf_to_generate_mud in turfs_to_mud)
		var/turf/mud_turf = new edge_turf(cur_turf)
		turfs_to_shallow += mud_turf
		mud_turf.Spread(40, 5, whitelist_area)

	for(var/turf/turf_to_generate_shallow in turfs_to_shallow)
		var/turf/river_turf = new shallow_turf(cur_turf)
		turfs_to_deep += river_turf
		river_turf.Spread(30, 5, whitelist_area)

	for(var/turf/turf_to_generate_deep in turfs_to_deep)
		var/turf/deep_river_turf = new deep_turf(cur_turf)
		deep_river_turf.Spread(20, 5, whitelist_area)

	for(var/waypoints_spawned in river_nodes)
		qdel(waypoints_spawned)

/obj/effect/landmark/river_waypoint/fantasystation
	name = "fantasy river waypoint"

/obj/effect/landmark/river_waypoint/fantasystation/Initialize(mapload)
	. = ..()
	GLOB.tagged_river_nodes += src
