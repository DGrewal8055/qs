module main

import os
import json
import chalk
import flag
import strings
import v.vmod
// import benchmark

struct Package {
mut:
	name        string
	bucket 		string
	version     string
	description string
	homepage    string
}

fn main() {
	// mut b := benchmark.start()
	dirs := os.ls(os.join_path(os.home_dir(), 'scoop', 'buckets'))!

	mut bucket_dirs := []string{}
	for dir in dirs {
		bucket_dirs << os.home_dir() + '\\scoop\\buckets\\' + dir + '\\bucket'
	}

	vm := vmod.decode(@VMOD_FILE)!
	mut fp := flag.new_flag_parser(os.args)
    fp.application('qs')
    fp.version(vm.version)
    fp.limit_free_args(0, 1)!
    fp.description('Faster search for scoop packages.')
    fp.skip_executable()
    update_flag := fp.bool_opt('update', `u`, 'Update scoop database first before searching.') or {false}
    query := fp.finalize() or {
        eprintln(err)
        println(fp.usage())
        return
    }
	
	if query.len == 0 {
        println(fp.usage())
        return
	}
	if update_flag == true {
		println("\nUpdating ....\n")
		result := os.execute_or_exit("scoop update")
		println(result.output)
	}
	println("Packages ....\n")

	// b.measure('Flag Parsing ...')

	// v_files := os.walk_ext(dir, 'json')
	mut json_files := []string{}

	for dir in bucket_dirs {
		for file in os.ls(dir)! {
			json_files << dir + "\\" + file
		}
	}

	// b.measure('Walk Function')

	mut packages := []Package{}

	mut name := ''
	mut bucket := ''

	for entry in json_files {

		arr := entry.rsplit_nth('\\', 4)
		bucket = arr[2]
		name = arr[0].split('.')[0]

		if name.to_lower().contains(query[0]) {

			file := os.read_file(entry)!
			package_json := json.decode(Package , file)!

			packages << Package{
				name: name
				bucket : bucket
				version: package_json.version
				homepage: package_json.homepage
				description: package_json.description
			}
		}
	}
	// b.measure('For Loop')

	mut	pac_info := strings.new_builder(100)

	for pac in packages {
		bucket_name := chalk.fg(pac.bucket, 'blue') 
		pac_name := chalk.fg(pac.name, 'green')
		pac_url := chalk.fg(chalk.style(pac.homepage, 'dim'), 'light_red')

		pac_info.write_string("${pac_name} (${pac.version})\n\tBucket : ${bucket_name}\n\tHomepage : ${pac_url}\n\tDescription : ${pac.description}\n\n" )
	}
	
	print(pac_info)
	unsafe {
		pac_info.free()
	}

	// b.measure('Printing')

}
