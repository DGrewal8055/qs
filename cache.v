module main

import os
import json

// import benchmark

// create cached json database
fn create_cache(cache_dir string) ! {
	// mut b := benchmark.start()
	dirs := os.ls(os.join_path(os.home_dir(), 'scoop', 'buckets'))!

	mut bucket_dirs := []string{}
	for dir in dirs {
		bucket_dirs << os.home_dir() + '\\scoop\\buckets\\' + dir + '\\bucket'
	}

	// b.measure('Loading Directories ...')
	mut json_files := []string{}

	for dir in bucket_dirs {
		for file in os.ls(dir)! {
			json_files << dir + '\\' + file
		}
	}

	// b.measure('Walk Function')
	mut packages := []Package{}

	mut name := ''
	mut bucket := ''

	for entry in json_files {
		file := os.read_file(entry)!
		package_json := json.decode(Package, file)!

		arr := entry.rsplit_nth('\\', 4)
		bucket = arr[2]
		name = arr[0].split('.')[0]

		packages << Package{
			name: name
			bucket: bucket
			version: package_json.version
			homepage: package_json.homepage
			description: package_json.description
		}
	}

	// b.measure('Json Decode')
	json_encoded := json.encode(packages)
	mut cache := os.create(cache_dir) or {
		println('file not writable. Error ${err}')
		return
	}

	cache.write_string(json_encoded)!
	cache.close()

	// b.measure('Json Encode')
}
