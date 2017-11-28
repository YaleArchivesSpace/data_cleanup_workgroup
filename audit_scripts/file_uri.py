#!/usr/bin/python

# Use: Check links in file_version.file_uri. Write retrieved URL and HTTP response codes to outfile. Retrieved url is empty string if connection failed.

# Update
datafile = 'file_uri_prod_20171127.tsv'
outfile = 'file_uri_audit_prod_20171127.tsv'

from check_url import *

# Read header row into headers.
# Read [digital_object_id, repo_id, file_uri] into data.
headers = []
data = []
with open(datafile, 'r') as f:
    headers = f.next().strip('\r\n').split('\t')
    for line in f:
        row = line.strip(' \r\n')
        if row != '':
            data.append(row.split('\t'))

# Check urls. Write output.
out = open(outfile, 'w')
headers += ['retrieved_url', 'http_response_code']
output = '\t'.join(headers) + '\n'
out.write(output)
for row in data:
    response = check_url(row[2], 5)
    row += response
    output = '\t'.join(map(lambda x: str(x), row)) + '\n'
    out.write(output)
out.close()
