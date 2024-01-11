# Israel GTFS Fixer

Israel's Ministry of Transport GTFS feed doesnt entirely follow the specification. This tool fixes the feed to make it compatible with the specification.

## Usage

Run the script from the command line with the following syntax:

```bash
julia main.jl --input_dir /path/to/your/input/directory
```

The script will create a new directory named `input_directory-fixed` where it will store the fixed files.

## Dependencies

This script depends on the following Julia packages:

- ArgParse
- CSV
- DataFrames