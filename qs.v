module main

import os
import json
import flag
import strings
import time
import v.vmod
import benchmark
import termcolor as tc

struct Package {
mut:
	name        string
	bucket      string
	version     string
	description string
	homepage    string
}

fn main() {
	mut b := benchmark.start()

	// Parsing Flags ---------------------------------------------------
	vm := vmod.decode(@VMOD_FILE)!
	mut fp := flag.new_flag_parser(os.args)
	fp.application('qs')
	fp.version(vm.version)
	fp.limit_free_args(0, 1)!
	fp.description('Faster search for scoop packages.')
	fp.skip_executable()
	update_database_flag := fp.bool_opt('update', `u`, 'Update scoop database first before searching.') or {
		false
	}
	update_cache_flag := fp.bool_opt('cache', `c`, 'Manually update the cache file') or { false }
	query := fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		return
	}

	if query.len == 0 {
		println(fp.usage())
		return
	}

	// Updating Sccop Database ------------------------------------------

	if update_database_flag == true {
		println('\nUpdating ....\n')
		result := os.execute_or_exit('scoop update')
		println(result.output)
	}

	// Updating Cache ---------------------------------------------------
	cache_dir := os.join_path(os.home_dir(), '.config', 'cache.json')

	last_mod := time.unix(os.stat(cache_dir)!.mtime).utc_to_local()
	cache_update := if last_mod < time.now().add_days(-3) { true } else { false }

	if update_cache_flag || cache_update {
		println('\nUpdateing Cache file ....')
		create_cache(cache_dir)!
	}

	// b.measure('Parsing flags and checking if cache is out of date. ...')

	// Searching the Packages --------------------------------------------

	json_file := os.read_file(cache_dir)!
	packages := search(query[0], json_file)!

	// b.measure('Search')

	// Printing the Info -------------------------------------------------
	print_info(packages)
	// b.measure('Printing')

	println('Time Spent : ${b.total_duration()}ms')
}

// Searxh for given query in the cached json database
fn search(query string, cache string) ![]Package {
	decoded := json.decode([]Package, cache)!
	mut packages := []Package{}

	for pac in decoded {
		if pac.name.to_lower().contains(query) {
			packages << pac
		}
	}
	return packages
}

// Print package info to terminal
fn print_info(packages []Package) {
	mut pac_info := strings.new_builder(100)

	for pac in packages {
		bucket_name := tc.colorize(text: pac.bucket, fc: .blue)
		pac_name := tc.colorize(text: pac.name, fc: .green)
		pac_url := tc.colorize(text: pac.homepage, fc: .red, style: .dim)

		pac_info.write_string('${pac_name} (${pac.version})\n\tBucket : ${bucket_name}\n\tHomepage : ${pac_url}\n\tDescription : ${pac.description}\n\n')
	}

	print(pac_info)

	unsafe { pac_info.free() }
}
