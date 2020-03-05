import json
import argparse
from s3io import S3IO

def lambda_handler(event, context):
    print("Running the envent handler")

    print (event)
    print (context, flush=True)
    s3_L0 = S3IO(event["bucket-name"])
    file_list = ["s3://{}/{}".format(event["bucket-name"],relative_match.replace(event["pattern"],"")) for relative_match in \
        s3_L0.list_keys(prefix=event["instrument-input-folder"],pattern="*{}".format(event["pattern"]))]

    print (" ".join(file_list), flush=True)
    input_instructions = {"instrument-files":{"instrument-file":[{"s3_src_instrument":name+event["pattern"], "s3_dest_las":name+".las", \
        "s3_dest_shp":{"Name":"INPUT_FILES_{}".format(index),"Value":name+".shp"}} \
            for (index,name) in zip(range(len(file_list)),file_list)]}}

    json_str = json.dumps(input_instructions, sort_keys=True, indent=4)
    print(json_str)

    output={}
    output["output"]=json_str
    return {
        'statusCode': 200,
        'body': json.dumps(output)
    }


if __name__ == "__main__":
    print("Starting")
    event={}
    context={}
    event["bucket-name"]="ausseabed-public-bathymetry"
    event["instrument-input-folder"]="L0/20fcc1c2-67c3-4d21-a0b2-5e9d16613211/Multibeam"
    event["pattern"]=".all"
    lambda_handler(event, context)

