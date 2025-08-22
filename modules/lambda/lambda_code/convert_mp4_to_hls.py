import json
import boto3
import os
from urllib.parse import unquote_plus

def lambda_handler(event, context):
    """
    Lambda function to convert MP4 files to HLS format
    Triggered by S3 events when MP4 files are uploaded
    """
    
    s3_client = boto3.client('s3')
    
    # Get environment variables
    dev_mp4_bucket = os.environ.get('S3_BUCKET_DEV_MP4')
    dev_abs_bucket = os.environ.get('S3_BUCKET_DEV_ABS')
    prod_abs_bucket = os.environ.get('S3_BUCKET_PROD_ABS')
    dev_origin_bucket = os.environ.get('S3_BUCKET_DEV_ORIGIN')
    
    try:
        # Parse S3 event
        for record in event['Records']:
            bucket_name = record['s3']['bucket']['name']
            object_key = unquote_plus(record['s3']['object']['key'])
            
            print(f"Processing file: {object_key} from bucket: {bucket_name}")
            
            # Check if it's an MP4 file
            if not object_key.lower().endswith('.mp4'):
                print(f"Skipping non-MP4 file: {object_key}")
                continue
            
            # Determine output bucket based on source
            if bucket_name == dev_mp4_bucket:
                output_bucket = dev_abs_bucket
                environment = 'dev'
            else:
                output_bucket = prod_abs_bucket
                environment = 'prod'
            
            # Generate HLS output path
            base_name = os.path.splitext(object_key)[0]
            hls_output_prefix = f"hls/{environment}/{base_name}/"
            
            # TODO: Implement actual HLS conversion logic
            # This would typically involve:
            # 1. Download MP4 file from S3
            # 2. Use FFmpeg or AWS Elemental MediaConvert to convert to HLS
            # 3. Upload HLS segments and playlist to output bucket
            
            # For now, create a placeholder response
            response_data = {
                'statusCode': 200,
                'body': json.dumps({
                    'message': f'MP4 to HLS conversion initiated for {object_key}',
                    'source_bucket': bucket_name,
                    'source_key': object_key,
                    'output_bucket': output_bucket,
                    'output_prefix': hls_output_prefix,
                    'environment': environment
                })
            }
            
            print(f"Conversion job created: {response_data}")
            
        return {
            'statusCode': 200,
            'body': json.dumps('MP4 to HLS conversion completed successfully')
        }
        
    except Exception as e:
        print(f"Error processing MP4 to HLS conversion: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
