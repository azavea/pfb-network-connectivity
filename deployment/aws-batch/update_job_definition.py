import argparse
import json
import logging
import os

import boto3

logger = logging.getLogger(__name__)


help = """Updates an AWS Batch job definition via JSON config

For use in CI to create new revisions of the job that modify the Docker image tag.

All other changes should be made to the JSON config.

Prints the job definition name plus revision to STDOUT as 'name:revision'

"""


def main():

    parser = argparse.ArgumentParser(description=help)
    parser.add_argument('job_definition_filename', type=str)
    parser.add_argument('image_url', type=str)

    parser.add_argument('--environment', type=str, default='staging',
                        choices=('development', 'staging', 'production',),
                        help='Launch into a specific environment')
    parser.add_argument('--deregister', action='store_true',
                        help='Deregister old verison of the job definition after updating')
    args = parser.parse_args()

    path_to_config_json = os.path.join('.', 'job-definitions',
                                       args.job_definition_filename)
    with open(path_to_config_json, 'r') as json_file:
        job_definition = json.load(json_file)
        job_definition['jobDefinitionName'] = (job_definition['jobDefinitionName']
                                               .format(environment=args.environment))
        job_definition['containerProperties']['image'] = args.image_url

        client = boto3.client('batch')
        response = client.register_job_definition(**job_definition)

        if args.deregister:
            old_revision = int(response['revision']) - 1
            old_job_definition = '{}:{}'.format(response['jobDefinitionName'], old_revision)
            client.deregister_job_definition(jobDefinition=old_job_definition)

        print('{}:{}'.format(response['jobDefinitionName'], response['revision']), end='')


if __name__ == "__main__":
    main()
