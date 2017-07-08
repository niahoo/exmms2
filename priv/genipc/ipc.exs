# DO NOT edit this file. It is automatically generated by `mix genipc` command.
# The data is extracted from priv/genipc/ipc.xml and written as Elixir data by
# priv/genipc/gen_api_def.py.
    
%{
	version: 24,
	enums: [
		{:'medialib_entry_status', [
			{:NEW, 0},
			{:RESOLVING, 2},
			{:OK, 1},
			{:NOT_AVAILABLE, 3},
			{:REHASH, 4},
		]},
		{:'ipc_command_signal', [
			{:BROADCAST, 33},
			{:SIGNAL, 32},
		]},
		{:'ipc_command_special', [
			{:REPLY, 0},
			{:ERROR, 1},
		]},
		{:'log_level', [
			{:INFO, 4},
			{:COUNT, 6},
			{:UNKNOWN, 0},
			{:DEBUG, 5},
			{:ERROR, 3},
			{:FAIL, 2},
			{:FATAL, 1},
		]},
		{:'c2c_reply_policy', [
			{:NO_REPLY, 0},
			{:SINGLE_REPLY, 1},
			{:MULTI_REPLY, 2},
		]},
		{:'playback_seek_mode', [
			{:SET, 1},
			{:CUR, 0},
		]},
		{:'playback_status', [
			{:PLAY, 1},
			{:PAUSE, 2},
			{:STOP, 0},
		]},
		{:'collection_type', [
			{:NOTEQUAL, 9},
			{:HAS, 5},
			{:LAST, 17},
			{:GREATER, 12},
			{:REFERENCE, 0},
			{:UNION, 2},
			{:UNIVERSE, 1},
			{:COMPLEMENT, 4},
			{:EQUALS, 8},
			{:GREATEREQ, 13},
			{:TOKEN, 7},
			{:SMALLER, 10},
			{:LIMIT, 15},
			{:SMALLEREQ, 11},
			{:INTERSECTION, 3},
			{:MEDIASET, 16},
			{:ORDER, 14},
			{:MATCH, 6},
			{:IDLIST, 17},
		]},
		{:'playlist_position_action', [
			{:MOVE_TO_FRONT, 2},
			{:FORGET, 0},
			{:KEEP, 1},
		]},
		{:'playlist_changed_action', [
			{:SORT, 6},
			{:INSERT, 1},
			{:SHUFFLE, 2},
			{:CLEAR, 4},
			{:MOVE, 5},
			{:UPDATE, 7},
			{:REMOVE, 3},
			{:REPLACE, 8},
			{:ADD, 0},
		]},
		{:'mediainfo_reader_status', [
			{:IDLE, 0},
			{:RUNNING, 1},
		]},
		{:'plugin_type', [
			{:OUTPUT, 1},
			{:ALL, 0},
			{:XFORM, 2},
		]},
		{:'collection_changed_action', [
			{:RENAME, 2},
			{:ADD, 0},
			{:UPDATE, 1},
			{:REMOVE, 3},
		]},
	],
	modules: [
		%{
			module: "Main",
			object_id: 1,
			functions: [
				%{ # hello
					name: :hello,
					doc: "Says hello to the daemon.",
					module: "Main",
					return: :'int',
					args: [
						{:protocol_version, :'int'},
						{:client, :'string'},
					],
					object_id: 1,
					command_id: 32,
					payload: [{:var, :protocol_version}, {:var, :client}],
					signal: false,
				},

				%{ # quit
					name: :quit,
					doc: "Shuts down the daemon.",
					module: "Main",
					return: nil,
					args: [
					],
					object_id: 1,
					command_id: 33,
					payload: [],
					signal: false,
				},

				%{ # list_plugins
					name: :list_plugins,
					doc: "Retrieves the list of available plugins.",
					module: "Main",
					return: :'list',
					args: [
						{:plugin_type, {:'enum-value', :'plugin_type'}},
					],
					object_id: 1,
					command_id: 34,
					payload: [{:var, :plugin_type}],
					signal: false,
				},

				%{ # stats
					name: :stats,
					doc: "Retrieves statistics from the server.",
					module: "Main",
					return: :'dictionary',
					args: [
					],
					object_id: 1,
					command_id: 35,
					payload: [],
					signal: false,
				},

				%{ # broadcast_quit
					name: :broadcast_quit,
					doc: "This broadcast is triggered when the daemon is shutting down.",
					module: "Main",
					return: :'int',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

			],
		},
		%{
			module: "Playlist",
			object_id: 2,
			functions: [
				%{ # replace
					name: :replace,
					doc: "Queries ids from a collection and replaces the playlist with the result.",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
						{:replacement, :'collection'},
						{:action, {:'enum-value', :'playlist_position_action'}},
					],
					object_id: 2,
					command_id: 32,
					payload: [{:var, :name}, {:var, :replacement}, {:var, :action}],
					signal: false,
				},

				%{ # set_next
					name: :set_next,
					doc: "Sets the playlist entry that will be played next.",
					module: "Playlist",
					return: :'int',
					args: [
						{:position, :'int'},
					],
					object_id: 2,
					command_id: 33,
					payload: [{:var, :position}],
					signal: false,
				},

				%{ # set_next_rel
					name: :set_next_rel,
					doc: "Sets the playlist entry that will be played next.",
					module: "Playlist",
					return: :'int',
					args: [
						{:position_delta, :'int'},
					],
					object_id: 2,
					command_id: 34,
					payload: [{:var, :position_delta}],
					signal: false,
				},

				%{ # add_url
					name: :add_url,
					doc: "Adds an URL to the given playlist.",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
						{:url, :'string'},
					],
					object_id: 2,
					command_id: 35,
					payload: [{:var, :name}, {:var, :url}],
					signal: false,
				},

				%{ # add_collection
					name: :add_collection,
					doc: "Adds the contents of a collection to the given playlist.",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
						{:collection, :'collection'},
					],
					object_id: 2,
					command_id: 36,
					payload: [{:var, :name}, {:var, :collection}],
					signal: false,
				},

				%{ # remove_entry
					name: :remove_entry,
					doc: "Removes an entry from the given playlist.",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
						{:position, :'int'},
					],
					object_id: 2,
					command_id: 37,
					payload: [{:var, :name}, {:var, :position}],
					signal: false,
				},

				%{ # move_entry
					name: :move_entry,
					doc: "Moves a playlist entry to a new position (absolute move).",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
						{:position, :'int'},
						{:new_position, :'int'},
					],
					object_id: 2,
					command_id: 38,
					payload: [{:var, :name}, {:var, :position}, {:var, :new_position}],
					signal: false,
				},

				%{ # list_entries
					name: :list_entries,
					doc: "Lists the contents of the given playlist.",
					module: "Playlist",
					return: :'list',
					args: [
						{:name, :'string'},
					],
					object_id: 2,
					command_id: 39,
					payload: [{:var, :name}],
					signal: false,
				},

				%{ # current_pos
					name: :current_pos,
					doc: "Retrieves the current position in the playlist with the given name.",
					module: "Playlist",
					return: :'dictionary',
					args: [
						{:name, :'string'},
					],
					object_id: 2,
					command_id: 40,
					payload: [{:var, :name}],
					signal: false,
				},

				%{ # current_active
					name: :current_active,
					doc: "Retrieves the name of the currently active playlist.",
					module: "Playlist",
					return: :'string',
					args: [
					],
					object_id: 2,
					command_id: 41,
					payload: [],
					signal: false,
				},

				%{ # insert_url
					name: :insert_url,
					doc: "Inserts an URL into the given playlist.",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
						{:position, :'int'},
						{:url, :'string'},
					],
					object_id: 2,
					command_id: 42,
					payload: [{:var, :name}, {:var, :position}, {:var, :url}],
					signal: false,
				},

				%{ # insert_collection
					name: :insert_collection,
					doc: "Inserts the contents of a collection into the given playlist.",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
						{:position, :'int'},
						{:collection, :'collection'},
					],
					object_id: 2,
					command_id: 43,
					payload: [{:var, :name}, {:var, :position}, {:var, :collection}],
					signal: false,
				},

				%{ # load
					name: :load,
					doc: "Loads the playlist with the given name.",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
					],
					object_id: 2,
					command_id: 44,
					payload: [{:var, :name}],
					signal: false,
				},

				%{ # radd
					name: :radd,
					doc: "Adds a directory recursively to the playlist with the given name.",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
						{:url, :'string'},
					],
					object_id: 2,
					command_id: 45,
					payload: [{:var, :name}, {:var, :url}],
					signal: false,
				},

				%{ # rinsert
					name: :rinsert,
					doc: "Insert a directory recursively into the playlist with the given name at the given position.",
					module: "Playlist",
					return: nil,
					args: [
						{:name, :'string'},
						{:position, :'int'},
						{:url, :'string'},
					],
					object_id: 2,
					command_id: 46,
					payload: [{:var, :name}, {:var, :position}, {:var, :url}],
					signal: false,
				},

				%{ # broadcast_changed
					name: :broadcast_changed,
					doc: "This broadcast is triggered when the playlist changes.",
					module: "Playlist",
					return: :'dictionary',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

				%{ # broadcast_current_pos
					name: :broadcast_current_pos,
					doc: "This broadcast is triggered when the position in the playlist changes.",
					module: "Playlist",
					return: :'dictionary',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

				%{ # broadcast_loaded
					name: :broadcast_loaded,
					doc: "This broadcast is triggered when another playlist is loaded.",
					module: "Playlist",
					return: :'string',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

			],
		},
		%{
			module: "Config",
			object_id: 3,
			functions: [
				%{ # get_value
					name: :get_value,
					doc: "Retrieves the value of the config property with the given key.",
					module: "Config",
					return: :'string',
					args: [
						{:key, :'string'},
					],
					object_id: 3,
					command_id: 32,
					payload: [{:var, :key}],
					signal: false,
				},

				%{ # set_value
					name: :set_value,
					doc: "Sets the value of the config property with the given key.",
					module: "Config",
					return: nil,
					args: [
						{:key, :'string'},
						{:value, :'string'},
					],
					object_id: 3,
					command_id: 33,
					payload: [{:var, :key}, {:var, :value}],
					signal: false,
				},

				%{ # register_value
					name: :register_value,
					doc: "Registers a new config property for the connected client.",
					module: "Config",
					return: :'string',
					args: [
						{:key, :'string'},
						{:value, :'string'},
					],
					object_id: 3,
					command_id: 34,
					payload: [{:var, :key}, {:var, :value}],
					signal: false,
				},

				%{ # list_values
					name: :list_values,
					doc: "Retrieves the list of known config properties.",
					module: "Config",
					return: :'dictionary',
					args: [
					],
					object_id: 3,
					command_id: 35,
					payload: [],
					signal: false,
				},

				%{ # broadcast_value_changed
					name: :broadcast_value_changed,
					doc: "This broadcast is triggered when the value of any config property changes.",
					module: "Config",
					return: :'dictionary',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

			],
		},
		%{
			module: "Playback",
			object_id: 4,
			functions: [
				%{ # start
					name: :start,
					doc: "Starts playback.",
					module: "Playback",
					return: nil,
					args: [
					],
					object_id: 4,
					command_id: 32,
					payload: [],
					signal: false,
				},

				%{ # stop
					name: :stop,
					doc: "Stops playback.",
					module: "Playback",
					return: nil,
					args: [
					],
					object_id: 4,
					command_id: 33,
					payload: [],
					signal: false,
				},

				%{ # pause
					name: :pause,
					doc: "Pauses playback.",
					module: "Playback",
					return: nil,
					args: [
					],
					object_id: 4,
					command_id: 34,
					payload: [],
					signal: false,
				},

				%{ # tickle
					name: :tickle,
					doc: "Stops decoding of the current song. This will start decoding of the song set with the playlist_set_next command or the current song again if the playlist_set_next command wasn't executed.",
					module: "Playback",
					return: nil,
					args: [
					],
					object_id: 4,
					command_id: 35,
					payload: [],
					signal: false,
				},

				%{ # playtime
					name: :playtime,
					doc: "Retrieves the current playtime.",
					module: "Playback",
					return: :'int',
					args: [
					],
					object_id: 4,
					command_id: 36,
					payload: [],
					signal: false,
				},

				%{ # seek_ms
					name: :seek_ms,
					doc: "Seeks to a position in the currently played song (given in milliseconds).",
					module: "Playback",
					return: nil,
					args: [
						{:offset, :'int'},
						{:whence, {:'enum-value', :'playback_seek_mode'}},
					],
					object_id: 4,
					command_id: 37,
					payload: [{:var, :offset}, {:var, :whence}],
					signal: false,
				},

				%{ # seek_samples
					name: :seek_samples,
					doc: "Seeks to a position in the currently played song (given in samples).",
					module: "Playback",
					return: nil,
					args: [
						{:offset, :'int'},
						{:whence, {:'enum-value', :'playback_seek_mode'}},
					],
					object_id: 4,
					command_id: 38,
					payload: [{:var, :offset}, {:var, :whence}],
					signal: false,
				},

				%{ # status
					name: :status,
					doc: "Retrieves the current playback status.",
					module: "Playback",
					return: {:'enum-value', :'playback_status'},
					args: [
					],
					object_id: 4,
					command_id: 39,
					payload: [],
					signal: false,
				},

				%{ # current_id
					name: :current_id,
					doc: "Retrieves the ID of the song that's currently being played.",
					module: "Playback",
					return: :'int',
					args: [
					],
					object_id: 4,
					command_id: 40,
					payload: [],
					signal: false,
				},

				%{ # volume_set
					name: :volume_set,
					doc: "Changes the volume for the given channel.",
					module: "Playback",
					return: nil,
					args: [
						{:channel, :'string'},
						{:volume, :'int'},
					],
					object_id: 4,
					command_id: 41,
					payload: [{:var, :channel}, {:var, :volume}],
					signal: false,
				},

				%{ # volume_get
					name: :volume_get,
					doc: "Retrieves the volume of all available channels.",
					module: "Playback",
					return: :'dictionary',
					args: [
					],
					object_id: 4,
					command_id: 42,
					payload: [],
					signal: false,
				},

				%{ # broadcast_status
					name: :broadcast_status,
					doc: "This broadcast is triggered when the playback status changes.",
					module: "Playback",
					return: {:'enum-value', :'playback_status'},
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

				%{ # broadcast_volume_changed
					name: :broadcast_volume_changed,
					doc: "This broadcast is triggered when the playback volume changes.",
					module: "Playback",
					return: :'dictionary',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

				%{ # broadcast_current_id
					name: :broadcast_current_id,
					doc: "This broadcast is triggered when the played song's media ID changes.",
					module: "Playback",
					return: :'int',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

			],
		},
		%{
			module: "Medialib",
			object_id: 5,
			functions: [
				%{ # get_info
					name: :get_info,
					doc: "Retrieves information about a medialib entry.",
					module: "Medialib",
					return: :'dictionary',
					args: [
						{:id, :'int'},
					],
					object_id: 5,
					command_id: 32,
					payload: [{:var, :id}],
					signal: false,
				},

				%{ # import_path
					name: :import_path,
					doc: "Adds a directory recursively to the medialib.",
					module: "Medialib",
					return: nil,
					args: [
						{:directory, :'string'},
					],
					object_id: 5,
					command_id: 33,
					payload: [{:var, :directory}],
					signal: false,
				},

				%{ # rehash
					name: :rehash,
					doc: "Rehashes the medialib. This will make sure that the data in the medialib is the same as the data in the files.",
					module: "Medialib",
					return: nil,
					args: [
						{:id, :'int'},
					],
					object_id: 5,
					command_id: 34,
					payload: [{:var, :id}],
					signal: false,
				},

				%{ # get_id
					name: :get_id,
					doc: "Retrieves the medialib ID that belongs to the given URL.",
					module: "Medialib",
					return: :'int',
					args: [
						{:url, :'string'},
					],
					object_id: 5,
					command_id: 35,
					payload: [{:var, :url}],
					signal: false,
				},

				%{ # remove_entry
					name: :remove_entry,
					doc: "Removes an entry from the medialib.",
					module: "Medialib",
					return: nil,
					args: [
						{:id, :'int'},
					],
					object_id: 5,
					command_id: 36,
					payload: [{:var, :id}],
					signal: false,
				},

				%{ # set_property_string
					name: :set_property_string,
					doc: "Sets a medialib property to a string value.",
					module: "Medialib",
					return: nil,
					args: [
						{:id, :'int'},
						{:source, :'string'},
						{:key, :'string'},
						{:value, :'string'},
					],
					object_id: 5,
					command_id: 37,
					payload: [{:var, :id}, {:var, :source}, {:var, :key}, {:var, :value}],
					signal: false,
				},

				%{ # set_property_int
					name: :set_property_int,
					doc: "Sets a medialib property to an integer value.",
					module: "Medialib",
					return: nil,
					args: [
						{:id, :'int'},
						{:source, :'string'},
						{:key, :'string'},
						{:value, :'int'},
					],
					object_id: 5,
					command_id: 38,
					payload: [{:var, :id}, {:var, :source}, {:var, :key}, {:var, :value}],
					signal: false,
				},

				%{ # remove_property
					name: :remove_property,
					doc: "Removes a propert from a medialib entry.",
					module: "Medialib",
					return: nil,
					args: [
						{:id, :'int'},
						{:source, :'string'},
						{:key, :'string'},
					],
					object_id: 5,
					command_id: 39,
					payload: [{:var, :id}, {:var, :source}, {:var, :key}],
					signal: false,
				},

				%{ # move_entry
					name: :move_entry,
					doc: "Updates the URL of a medialib entry that has been moved to a new location.",
					module: "Medialib",
					return: nil,
					args: [
						{:id, :'int'},
						{:url, :'string'},
					],
					object_id: 5,
					command_id: 40,
					payload: [{:var, :id}, {:var, :url}],
					signal: false,
				},

				%{ # add_entry
					name: :add_entry,
					doc: "Add the given URL to the medialib.",
					module: "Medialib",
					return: nil,
					args: [
						{:url, :'string'},
					],
					object_id: 5,
					command_id: 41,
					payload: [{:var, :url}],
					signal: false,
				},

				%{ # broadcast_entry_added
					name: :broadcast_entry_added,
					doc: "This broadcast is triggered when an entry is added to the medialib.",
					module: "Medialib",
					return: :'int',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

				%{ # broadcast_entry_changed
					name: :broadcast_entry_changed,
					doc: "This broadcast is triggered when the properties of a medialib entry are changed.",
					module: "Medialib",
					return: :'int',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

				%{ # broadcast_entry_removed
					name: :broadcast_entry_removed,
					doc: "This broadcast is triggered when a medialib entry is removed.",
					module: "Medialib",
					return: :'int',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

			],
		},
		%{
			module: "Collection",
			object_id: 6,
			functions: [
				%{ # get
					name: :get,
					doc: "Retrieves the structure of a given collection.",
					module: "Collection",
					return: :'collection',
					args: [
						{:name, :'string'},
						{:namespace, :'string'},
					],
					object_id: 6,
					command_id: 32,
					payload: [{:var, :name}, {:var, :namespace}],
					signal: false,
				},

				%{ # list
					name: :list,
					doc: "Lists the collections in the given namespace.",
					module: "Collection",
					return: :'list',
					args: [
						{:namespace, :'string'},
					],
					object_id: 6,
					command_id: 33,
					payload: [{:var, :namespace}],
					signal: false,
				},

				%{ # save
					name: :save,
					doc: "Save the given collection in the DAG under the given name in the given namespace.",
					module: "Collection",
					return: nil,
					args: [
						{:name, :'string'},
						{:namespace, :'string'},
						{:collection, :'collection'},
					],
					object_id: 6,
					command_id: 34,
					payload: [{:var, :name}, {:var, :namespace}, {:var, :collection}],
					signal: false,
				},

				%{ # remove
					name: :remove,
					doc: "Remove the given collection from the DAG.",
					module: "Collection",
					return: nil,
					args: [
						{:name, :'string'},
						{:namespace, :'string'},
					],
					object_id: 6,
					command_id: 35,
					payload: [{:var, :name}, {:var, :namespace}],
					signal: false,
				},

				%{ # find
					name: :find,
					doc: "Find all collections in the given namespace that contain a given media.",
					module: "Collection",
					return: :'list',
					args: [
						{:id, :'int'},
						{:namespace, :'string'},
					],
					object_id: 6,
					command_id: 36,
					payload: [{:var, :id}, {:var, :namespace}],
					signal: false,
				},

				%{ # rename
					name: :rename,
					doc: "Rename a collection in the given namespace.",
					module: "Collection",
					return: nil,
					args: [
						{:name, :'string'},
						{:new_name, :'string'},
						{:namespace, :'string'},
					],
					object_id: 6,
					command_id: 37,
					payload: [{:var, :name}, {:var, :new_name}, {:var, :namespace}],
					signal: false,
				},

				%{ # query
					name: :query,
					doc: "FIXME.",
					module: "Collection",
					return: :'unknown',
					args: [
						{:collection, :'collection'},
						{:fetch, :'dictionary'},
					],
					object_id: 6,
					command_id: 38,
					payload: [{:var, :collection}, {:var, :fetch}],
					signal: false,
				},

				%{ # query_infos
					name: :query_infos,
					doc: "FIXME.",
					module: "Collection",
					return: :'list',
					args: [
						{:collection, :'collection'},
						{:limit_start, :'int'},
						{:limit_length, :'int'},
						{:properties, :'list', :'string'},
						{:group_by, :'list', :'string'},
					],
					object_id: 6,
					command_id: 39,
					payload: [{:var, :collection}, {:var, :limit_start}, {:var, :limit_length}, {:var, :properties}, {:var, :group_by}],
					signal: false,
				},

				%{ # idlist_from_playlist
					name: :idlist_from_playlist,
					doc: "FIXME.",
					module: "Collection",
					return: :'collection',
					args: [
						{:url, :'string'},
					],
					object_id: 6,
					command_id: 40,
					payload: [{:var, :url}],
					signal: false,
				},

				%{ # broadcast_changed
					name: :broadcast_changed,
					doc: "This broadcast is triggered when a collection is changed.",
					module: "Collection",
					return: :'dictionary',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

			],
		},
		%{
			module: "Visualization",
			object_id: 7,
			functions: [
				%{ # query_version
					name: :query_version,
					doc: "Retrieves the visualization version.",
					module: "Visualization",
					return: :'int',
					args: [
					],
					object_id: 7,
					command_id: 32,
					payload: [],
					signal: false,
				},

				%{ # register
					name: :register,
					doc: "Registers a visualization client.",
					module: "Visualization",
					return: :'int',
					args: [
					],
					object_id: 7,
					command_id: 33,
					payload: [],
					signal: false,
				},

				%{ # init_shm
					name: :init_shm,
					doc: "FIXME.",
					module: "Visualization",
					return: :'int',
					args: [
						{:id, :'int'},
						{:shm_id, :'string'},
					],
					object_id: 7,
					command_id: 34,
					payload: [{:var, :id}, {:var, :shm_id}],
					signal: false,
				},

				%{ # init_udp
					name: :init_udp,
					doc: "FIXME.",
					module: "Visualization",
					return: :'int',
					args: [
						{:id, :'int'},
					],
					object_id: 7,
					command_id: 35,
					payload: [{:var, :id}],
					signal: false,
				},

				%{ # set_property
					name: :set_property,
					doc: "Delivers one property.",
					module: "Visualization",
					return: :'int',
					args: [
						{:id, :'int'},
						{:key, :'string'},
						{:value, :'string'},
					],
					object_id: 7,
					command_id: 36,
					payload: [{:var, :id}, {:var, :key}, {:var, :value}],
					signal: false,
				},

				%{ # set_properties
					name: :set_properties,
					doc: "Delivers one or more properties.",
					module: "Visualization",
					return: :'int',
					args: [
						{:id, :'int'},
						{:properties, :'dictionary', :'string'},
					],
					object_id: 7,
					command_id: 37,
					payload: [{:var, :id}, {:var, :properties}],
					signal: false,
				},

				%{ # shutdown
					name: :shutdown,
					doc: "Shuts down the visualization client.",
					module: "Visualization",
					return: nil,
					args: [
						{:id, :'int'},
					],
					object_id: 7,
					command_id: 38,
					payload: [{:var, :id}],
					signal: false,
				},

			],
		},
		%{
			module: "MediainfoReader",
			object_id: 8,
			functions: [
				%{ # broadcast_status
					name: :broadcast_status,
					doc: "This broadcast is triggered when the status of the mediainfo reader changes.",
					module: "MediainfoReader",
					return: {:'enum-value', :'mediainfo_reader_status'},
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

			],
		},
		%{
			module: "Xform",
			object_id: 9,
			functions: [
				%{ # browse
					name: :browse,
					doc: "Retrieves a list of paths available (directly) under the given path.",
					module: "Xform",
					return: :'list',
					args: [
						{:url, :'string'},
					],
					object_id: 9,
					command_id: 32,
					payload: [{:var, :url}],
					signal: false,
				},

			],
		},
		%{
			module: "Bindata",
			object_id: 10,
			functions: [
				%{ # retrieve
					name: :retrieve,
					doc: "Retrieves a file from the server's bindata directory given the file's hash.",
					module: "Bindata",
					return: :'binary',
					args: [
						{:hash, :'string'},
					],
					object_id: 10,
					command_id: 32,
					payload: [{:var, :hash}],
					signal: false,
				},

				%{ # add
					name: :add,
					doc: "Adds binary data to the server's bindata directory.",
					module: "Bindata",
					return: :'string',
					args: [
						{:raw_data, :'binary'},
					],
					object_id: 10,
					command_id: 33,
					payload: [{:var, :raw_data}],
					signal: false,
				},

				%{ # remove
					name: :remove,
					doc: "Removes binary data from the server's bindata directory.",
					module: "Bindata",
					return: nil,
					args: [
						{:hash, :'string'},
					],
					object_id: 10,
					command_id: 34,
					payload: [{:var, :hash}],
					signal: false,
				},

				%{ # list
					name: :list,
					doc: "Retrieves a list of binary data hashes from the server's bindata directory.",
					module: "Bindata",
					return: :'list',
					args: [
					],
					object_id: 10,
					command_id: 35,
					payload: [],
					signal: false,
				},

			],
		},
		%{
			module: "CollSync",
			object_id: 11,
			functions: [
				%{ # sync
					name: :sync,
					doc: "Save collections to disk.",
					module: "CollSync",
					return: nil,
					args: [
					],
					object_id: 11,
					command_id: 32,
					payload: [],
					signal: false,
				},

			],
		},
		%{
			module: "Courier",
			object_id: 12,
			functions: [
				%{ # send_message
					name: :send_message,
					doc: "Assemble and send a client-to-client message.",
					module: "Courier",
					return: nil,
					args: [
						{:to_client, :'int'},
						{:reply_policy, {:'enum-value', :'c2c_reply_policy'}},
						{:payload, :'dictionary'},
					],
					object_id: 12,
					command_id: 32,
					payload: [{:var, :to_client}, {:var, :reply_policy}, {:var, :payload}],
					signal: false,
				},

				%{ # reply
					name: :reply,
					doc: "Assemble and send a reply to a client-to-client message",
					module: "Courier",
					return: nil,
					args: [
						{:message_id, :'int'},
						{:reply_policy, {:'enum-value', :'c2c_reply_policy'}},
						{:payload, :'dictionary'},
					],
					object_id: 12,
					command_id: 33,
					payload: [{:var, :message_id}, {:var, :reply_policy}, {:var, :payload}],
					signal: false,
				},

				%{ # get_connected_clients
					name: :get_connected_clients,
					doc: "Return a list of connected clients.",
					module: "Courier",
					return: :'list',
					args: [
					],
					object_id: 12,
					command_id: 34,
					payload: [],
					signal: false,
				},

				%{ # ready
					name: :ready,
					doc: "Notify the server that the client's api is ready for query.",
					module: "Courier",
					return: nil,
					args: [
					],
					object_id: 12,
					command_id: 35,
					payload: [],
					signal: false,
				},

				%{ # get_ready_clients
					name: :get_ready_clients,
					doc: "Return a list of clients ready for c2c communication",
					module: "Courier",
					return: :'list',
					args: [
					],
					object_id: 12,
					command_id: 36,
					payload: [],
					signal: false,
				},

				%{ # broadcast_message
					name: :broadcast_message,
					doc: "This broadcast carries client-to-client messages.",
					module: "Courier",
					return: :'dictionary',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

				%{ # broadcast_ready
					name: :broadcast_ready,
					doc: "This broadcast is emitted when a client's services are ready.",
					module: "Courier",
					return: :'int',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

			],
		},
		%{
			module: "IpcManager",
			object_id: 13,
			functions: [
				%{ # broadcast_client_connected
					name: :broadcast_client_connected,
					doc: "This broadcast is emitted when a new client connects.",
					module: "IpcManager",
					return: :'int',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

				%{ # broadcast_client_disconnected
					name: :broadcast_client_disconnected,
					doc: "This broadcast is emitted when a client disconnects.",
					module: "IpcManager",
					return: :'int',
					args: [
					],
					object_id: 0,
					command_id: 33,
					payload: [{:const, 0}],
					signal: false,
				},

			],
		},
	]
}