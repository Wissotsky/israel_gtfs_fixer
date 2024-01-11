using ArgParse
using CSV
using DataFrames
#using Filesystem

function create_output_dir(input_dir::String)
    output_dir = input_dir * "-fixed"
    mkdir(output_dir)
    return output_dir
end

function 📄➡️📄(input_dir::String, output_dir::String)
    for file in readdir(input_dir)
        cp(joinpath(input_dir, file), joinpath(output_dir, file), force=true)
    end
end

function process_files(input_dir::String, output_dir::String)
    # read in the files
    print("\r2/10 Loading files")
    df_stops = CSV.read(joinpath(output_dir, "stops.txt"), DataFrame)
    print("\r3/10 Loading files")
    df_translations = CSV.read(joinpath(output_dir, "translations.txt"), DataFrame, delim=",", quoted=false)
    print("\r4/10 Loading files")
    df_fareattributes =  CSV.read(joinpath(output_dir, "fare_attributes.txt"), DataFrame)

    # Fix for stops.txt
    print("\r5/10 Fixing stops ")
    df_stops.zone_id = df_stops.stop_code

    # Fixes for translations.txt
    print("\r6/10 Fixing translations")
    rename!(df_translations, :lang => :language)
    rename!(df_translations,:trans_id => :field_value)
    df_translations[!,:table_name] .= "stops"
    df_translations[!,:field_name] .= "stop_name"

    # Fixes for fare_attributes.txt
    print("\r7/10 Fixing fare attributes")
    select!(df_fareattributes, Not(:agency_id))
    transform!(df_fareattributes, :price => ByRow(x -> ifelse(x <= 5.5, (90*60), missing)) => :transfer_duration)
    transform!(df_fareattributes, :price => ByRow(x -> ifelse(x <= 5.5, missing, 0)) => :transfers)

    # export the files
    print("\r8/10 Exporting stops       ")
    CSV.write(joinpath(output_dir, "stops.txt"), df_stops)
    print("\r9/10 Exporting stops")
    CSV.write(joinpath(output_dir, "translations.txt"), df_translations)
    print("\r10/10 Exporting stops")
    CSV.write(joinpath(output_dir, "fare_attributes.txt"), df_fareattributes)
end

function main()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "input_dir"
            help = "input directory"
            arg_type = String
            required = true
    end

    parsed_args = parse_args(ARGS, s)
    output_dir = create_output_dir(parsed_args["input_dir"])
    print("1/10 Copying files")
    📄➡️📄(parsed_args["input_dir"], output_dir)
    process_files(parsed_args["input_dir"], output_dir)
    print("\rDone! 🎉             ")
end

main()