module main

import os
import json
import flag
import strings
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

	// Getting All Packages ---------------------------------------------------
	
	packages_files := create_package_array()!
	// b.measure('Getting all Package files. ...')

	// Searching the Packages --------------------------------------------

	result_packages := search(query[0], packages_files)!
	// b.measure('Searching')

	// Printing the Info -------------------------------------------------

	print_info(result_packages)
	// b.measure('Printing')

	println('Time Spent : ${b.total_duration()}ms')
}

// Search for given query in the all packages 
fn search(query string, files []string) ![]Package {
	 mut packages := []Package{}
	 mut package := Package{}

	for pac_file in files {
		if pac_file.to_lower().contains(query) {
			json_file := os.read_file(pac_file)!

			package = json.decode(Package, json_file)!
			package.name = os.file_name(pac_file).before(".")
			package.bucket = os.dir(pac_file).after("buckets\\").before("\\bucket")

			packages << package
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

		pac_info.write_string(' ${pac_name} (${pac.version})\n\t Bucket: ${bucket_name}\n\t Url: ${pac_url}\n\t Description: ${pac.description}\n\n')
	}

	print(pac_info)

	unsafe { pac_info.free() }
}

fn create_package_array() ![]string {
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

	return json_files

}